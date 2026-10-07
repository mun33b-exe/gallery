import 'package:flutter/foundation.dart';
import 'package:gallery/core/database/gallery_database_service.dart';
import 'package:gallery/core/services/preferences_service.dart';
import 'package:gallery/features/gallery/domain/photo_model.dart';
import 'package:gallery/features/gallery/domain/photo_repository.dart';
import 'package:gallery_ai_engine/gallery_ai_engine.dart';
import 'package:path/path.dart' as p;

import '../domain/ai_photo_search_repository.dart';

/// Concrete on-device implementation of [AiPhotoSearchRepository].
/// Embeds queries with [TextEngine] (MobileCLIP-S2 text encoder),
/// ranks indexed photo embeddings from SQLite via cosine similarity off-thread,
/// and returns matching [PhotoModel] collections.
class OnDeviceAiPhotoSearchRepository implements AiPhotoSearchRepository {
  final GalleryDatabaseService databaseService;
  final TextEngine _textEngine;
  final PreferencesService? preferencesService;
  final PhotoRepository? photoRepository;
  final double minSimilarityThreshold;
  final int maxResults;

  static const List<String> kDefaultSuggestedPrompts = [
    'Show photos of dogs',
    'Find photos from my birthday',
    'Show beach photos',
    'Find photos with cars',
    'Sunset by the ocean',
  ];

  OnDeviceAiPhotoSearchRepository({
    required this.databaseService,
    TextEngine? textEngine,
    this.preferencesService,
    this.photoRepository,
    this.minSimilarityThreshold = 0.15,
    this.maxResults = 30,
  }) : _textEngine = textEngine ?? TextEngine(runner: _stubRunner);

  static Future<List<double>> _stubRunner(
    String modelName,
    List<dynamic> tokens,
    List<int> shape,
  ) async {
    // Graceful zero vector stub if no runner is provided
    return List<double>.filled(512, 0.0);
  }

  @override
  Future<List<PhotoModel>> searchPhotos({required String query}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    // 1. Embed search query into 512-D L2-normalized vector
    final queryVector = await _textEngine.embedQuery(trimmed);

    // 2. Fetch all indexed photos with embeddings from SQLite
    final rows = databaseService.db.select('''
      SELECT media_id, file_path, capture_date, latitude, longitude,
             city, classification, confidence, embedding
      FROM photos;
      ''');

    if (rows.isEmpty) {
      await saveRecentSearch(trimmed);
      return const [];
    }

    // 3. Score & rank via compute isolate to prevent UI frame drops
    final payload = _IsolateRankingPayload(
      queryVector: queryVector,
      rawPhotos: rows.map((r) => Map<String, dynamic>.from(r)).toList(),
      minThreshold: minSimilarityThreshold,
      topK: maxResults,
    );

    final rankedMatches = await compute(_rankPhotosInIsolate, payload);

    // 4. Resolve cached AssetEntity thumbnails if PhotoRepository is present
    List<PhotoModel>? cachedPhotos;
    if (photoRepository != null) {
      try {
        cachedPhotos = await photoRepository!.getPhotos();
      } catch (_) {
        cachedPhotos = null;
      }
    }

    final cachedMap = {
      if (cachedPhotos != null)
        for (final p in cachedPhotos) p.id: p,
    };

    // 5. Map ranked matches to PhotoModel instances
    final results = <PhotoModel>[];
    for (final match in rankedMatches) {
      final cached = cachedMap[match.mediaId];
      if (cached != null) {
        results.add(cached);
      } else {
        results.add(
          PhotoModel(
            id: match.mediaId,
            title: p.basename(match.filePath),
            width: 1920,
            height: 1080,
            createDateTime: match.createDateTime,
            isFavorite: false,
          ),
        );
      }
    }

    // 6. Record query to recent search history
    await saveRecentSearch(trimmed);

    return results;
  }

  @override
  Future<List<String>> getSuggestedPrompts() async {
    return List.unmodifiable(kDefaultSuggestedPrompts);
  }

  @override
  Future<List<String>> getRecentSearches() async {
    return preferencesService?.getRecentSearches() ?? const [];
  }

  @override
  Future<void> saveRecentSearch(String query) async {
    await preferencesService?.saveRecentSearch(query);
  }

  @override
  Future<void> clearRecentSearches() async {
    await preferencesService?.clearRecentSearches();
  }
}

class _IsolateRankingPayload {
  final List<double> queryVector;
  final List<Map<String, dynamic>> rawPhotos;
  final double minThreshold;
  final int topK;

  _IsolateRankingPayload({
    required this.queryVector,
    required this.rawPhotos,
    required this.minThreshold,
    required this.topK,
  });
}

class _RankedMatch {
  final String mediaId;
  final String filePath;
  final DateTime createDateTime;
  final double score;

  _RankedMatch({
    required this.mediaId,
    required this.filePath,
    required this.createDateTime,
    required this.score,
  });
}

List<_RankedMatch> _rankPhotosInIsolate(_IsolateRankingPayload payload) {
  final matches = <_RankedMatch>[];

  for (final row in payload.rawPhotos) {
    final embeddingBlob = row['embedding'];
    if (embeddingBlob is! Uint8List) continue;

    final vector = _unpackEmbedding(embeddingBlob);
    if (vector.length != payload.queryVector.length) continue;

    final score = VectorMath.cosineSimilarity(payload.queryVector, vector);
    if (score >= payload.minThreshold) {
      final captureDateStr = row['capture_date'] as String?;
      final createDateTime = captureDateStr != null
          ? (DateTime.tryParse(captureDateStr) ?? DateTime.now())
          : DateTime.now();

      matches.add(
        _RankedMatch(
          mediaId: row['media_id'] as String,
          filePath: row['file_path'] as String,
          createDateTime: createDateTime,
          score: score,
        ),
      );
    }
  }

  matches.sort((a, b) => b.score.compareTo(a.score));
  if (matches.length > payload.topK) {
    return matches.sublist(0, payload.topK);
  }
  return matches;
}

List<double> _unpackEmbedding(Uint8List blob) {
  final byteData = ByteData.sublistView(blob);
  final count = blob.lengthInBytes ~/ 4;
  final vector = List<double>.filled(count, 0.0);
  for (int i = 0; i < count; i++) {
    vector[i] = byteData.getFloat32(i * 4, Endian.little);
  }
  return vector;
}
