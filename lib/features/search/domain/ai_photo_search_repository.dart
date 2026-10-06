import 'package:gallery/features/gallery/domain/photo_model.dart';

/// Replaceable domain contract for AI-powered natural-language photo search.
/// Completely decoupled from whether the future engine is on-device
/// (e.g. MobileCLIP, TFLite, local vector database) or a cloud backend.
abstract class AiPhotoSearchRepository {
  /// Executes a natural-language search query and returns matching photos.
  Future<List<PhotoModel>> searchPhotos({required String query});

  /// Retrieves recommended prompt suggestions to guide user queries.
  Future<List<String>> getSuggestedPrompts();

  /// Retrieves the list of recent user search queries.
  Future<List<String>> getRecentSearches();

  /// Records a submitted query into recent search history.
  Future<void> saveRecentSearch(String query);

  /// Clears all stored recent searches.
  Future<void> clearRecentSearches();
}
