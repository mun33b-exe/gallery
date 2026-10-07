import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:gallery/core/database/gallery_database_service.dart';
import 'package:gallery/core/services/preferences_service.dart';
import 'package:gallery/features/search/data/on_device_ai_photo_search_repository.dart';
import 'package:gallery_ai_engine/gallery_ai_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OnDeviceAiPhotoSearchRepository Unit Tests', () {
    late GalleryDatabaseService dbService;
    late PreferencesService preferencesService;
    late OnDeviceAiPhotoSearchRepository repository;

    // Fixed unit vectors for deterministic testing
    late List<double> dogQueryVector;

    List<double> createUnitVector({
      required int primaryIndex,
      double value = 1.0,
    }) {
      final vec = List<double>.filled(512, 0.0);
      vec[primaryIndex] = value;
      // Add slight spread
      for (int i = 0; i < 10; i++) {
        vec[(primaryIndex + i) % 512] += 0.05;
      }
      return _normalize(vec);
    }

    Uint8List packVector(List<double> vector) {
      final byteData = ByteData(vector.length * 4);
      for (int i = 0; i < vector.length; i++) {
        byteData.setFloat32(i * 4, vector[i], Endian.little);
      }
      return byteData.buffer.asUint8List();
    }

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      preferencesService = PreferencesService(prefs);

      dbService = GalleryDatabaseService.inMemory();

      dogQueryVector = createUnitVector(primaryIndex: 10);

      // Seed SQLite with test photos
      final dogPhotoVector = createUnitVector(
        primaryIndex: 10,
      ); // Matches dogQueryVector closely
      final beachPhotoVector = createUnitVector(
        primaryIndex: 50,
      ); // Matches beachQueryVector
      final carPhotoVector = createUnitVector(
        primaryIndex: 150,
      ); // Orthogonal to dog & beach

      final db = dbService.db;
      db.execute(
        '''
        INSERT INTO photos (
          media_id, file_path, capture_date, classification, confidence, embedding, indexed_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?), (?, ?, ?, ?, ?, ?, ?), (?, ?, ?, ?, ?, ?, ?);
        ''',
        [
          // Photo 1: Dog
          'photo_dog_001',
          '/storage/DCIM/golden_retriever.jpg',
          '2026-10-01T12:00:00Z',
          'Photo',
          0.99,
          packVector(dogPhotoVector),
          '2026-10-01T12:05:00Z',

          // Photo 2: Beach
          'photo_beach_001',
          '/storage/DCIM/sunset_beach.jpg',
          '2026-10-02T18:00:00Z',
          'Photo',
          0.95,
          packVector(beachPhotoVector),
          '2026-10-02T18:05:00Z',

          // Photo 3: Car
          'photo_car_001',
          '/storage/DCIM/sports_car.jpg',
          '2026-10-03T10:00:00Z',
          'Photo',
          0.97,
          packVector(carPhotoVector),
          '2026-10-03T10:05:00Z',
        ],
      );

      // Deterministic TextEngine using mock runner
      Future<List<double>> mockRunner(
        String modelName,
        List<dynamic> tokens,
        List<int> shape,
      ) async {
        return dogQueryVector;
      }

      repository = OnDeviceAiPhotoSearchRepository(
        databaseService: dbService,
        textEngine: TextEngine(runner: mockRunner),
        preferencesService: preferencesService,
        minSimilarityThreshold: 0.15,
      );
    });

    tearDown(() {
      dbService.close();
    });

    test('searchPhotos ranks aligned photos highest and filters below threshold', () async {
      final results = await repository.searchPhotos(query: 'dogs in park');

      expect(results, isNotEmpty);
      expect(results.first.id, equals('photo_dog_001'));
      expect(results.first.title, equals('golden_retriever.jpg'));

      // The orthogonal car photo should be below the 0.15 similarity threshold
      final resultIds = results.map((p) => p.id).toSet();
      expect(resultIds, contains('photo_dog_001'));
      expect(resultIds, isNot(contains('photo_car_001')));
    });

    test(
      'searchPhotos returns empty list immediately for blank/whitespace query',
      () async {
        final emptyResults = await repository.searchPhotos(query: '   ');
        expect(emptyResults, isEmpty);
      },
    );

    test('searchPhotos respects custom high similarity threshold', () async {
      final partialMatchVector = createUnitVector(primaryIndex: 20);
      final highThresholdRepo = OnDeviceAiPhotoSearchRepository(
        databaseService: dbService,
        textEngine: TextEngine(
          runner: (name, tokens, shape) async => partialMatchVector,
        ),
        preferencesService: preferencesService,
        minSimilarityThreshold: 0.90,
      );

      final results = await highThresholdRepo.searchPhotos(
        query: 'distant match',
      );
      expect(results, isEmpty);
    });

    test('recent searches save, retrieve, deduplicate, and clear via PreferencesService', () async {
      await repository.saveRecentSearch('golden retriever');
      await repository.saveRecentSearch('sunset beach');
      await repository.saveRecentSearch(
        'golden retriever',
      ); // Duplicate re-inserted at top

      final recent = await repository.getRecentSearches();
      expect(recent, equals(['golden retriever', 'sunset beach']));

      await repository.clearRecentSearches();
      final afterClear = await repository.getRecentSearches();
      expect(afterClear, isEmpty);
    });

    test('getSuggestedPrompts returns starter prompt collection', () async {
      final prompts = await repository.getSuggestedPrompts();
      expect(prompts, isNotEmpty);
      expect(prompts, contains('Show photos of dogs'));
      expect(prompts, contains('Show beach photos'));
    });
  });
}

List<double> _normalize(List<double> v) {
  double sumSq = 0.0;
  for (final x in v) {
    sumSq += x * x;
  }
  final norm = math.sqrt(sumSq);
  if (norm < 1e-12) return v;
  return v.map((x) => x / norm).toList();
}
