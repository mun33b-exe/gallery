import 'package:gallery/features/gallery/domain/photo_model.dart';

import '../domain/ai_photo_search_repository.dart';

/// In-memory mock implementation of [AiPhotoSearchRepository].
/// Provides deterministic natural-language query responses, prompt suggestions,
/// and recent query persistence for testing and headless CI.
class MockAiPhotoSearchRepository implements AiPhotoSearchRepository {
  final Duration simulatedDelay;
  final List<PhotoModel> _photos;
  final List<String> _recentSearches;

  static const List<String> kDefaultSuggestedPrompts = [
    'Show photos of dogs',
    'Find photos from my birthday',
    'Show beach photos',
    'Find photos with cars',
    'Sunset by the ocean',
  ];

  MockAiPhotoSearchRepository({
    this.simulatedDelay = Duration.zero,
    List<PhotoModel>? photos,
    List<String>? initialRecentSearches,
  }) : _photos = photos ?? _generateMockPhotos(),
       _recentSearches = initialRecentSearches != null
           ? List.of(initialRecentSearches)
           : ['dogs', 'beach sunset'];

  static List<PhotoModel> _generateMockPhotos() {
    final now = DateTime.now();
    return [
      PhotoModel(
        id: 'ai_dog_1',
        title: 'Golden_Retriever_Park.jpg',
        width: 1920,
        height: 1080,
        createDateTime: now.subtract(const Duration(days: 2)),
        isFavorite: true,
      ),
      PhotoModel(
        id: 'ai_dog_2',
        title: 'Puppy_Playing_Grass.jpg',
        width: 1920,
        height: 1080,
        createDateTime: now.subtract(const Duration(days: 3)),
        isFavorite: false,
      ),
      PhotoModel(
        id: 'ai_beach_1',
        title: 'Tropical_Beach_Sunset.jpg',
        width: 3840,
        height: 2160,
        createDateTime: now.subtract(const Duration(days: 5)),
        isFavorite: true,
      ),
      PhotoModel(
        id: 'ai_car_1',
        title: 'Vintage_Sports_Car.jpg',
        width: 1920,
        height: 1080,
        createDateTime: now.subtract(const Duration(days: 10)),
        isFavorite: false,
      ),
      PhotoModel(
        id: 'ai_birthday_1',
        title: 'Birthday_Cake_Celebration.jpg',
        width: 1920,
        height: 1080,
        createDateTime: now.subtract(const Duration(days: 20)),
        isFavorite: true,
      ),
    ];
  }

  @override
  Future<List<PhotoModel>> searchPhotos({required String query}) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    final normalized = query.trim().toLowerCase();

    // 1. Simulate service error state
    if (normalized.startsWith('error') || normalized.startsWith('fail')) {
      throw Exception('Simulated AI search engine failure. Please try again.');
    }

    // 2. Explicit empty result trigger
    if (normalized == 'empty' || normalized == 'nonexistent') {
      return [];
    }

    // 3. Match against semantic query concepts
    if (normalized.contains('dog') || normalized.contains('puppy')) {
      return _photos
          .where(
            (p) =>
                (p.title ?? '').toLowerCase().contains('dog') ||
                (p.title ?? '').toLowerCase().contains('puppy') ||
                (p.title ?? '').toLowerCase().contains('retriever'),
          )
          .toList();
    }

    if (normalized.contains('beach') ||
        normalized.contains('ocean') ||
        normalized.contains('sunset')) {
      return _photos
          .where(
            (p) =>
                (p.title ?? '').toLowerCase().contains('beach') ||
                (p.title ?? '').toLowerCase().contains('sunset'),
          )
          .toList();
    }

    if (normalized.contains('car') || normalized.contains('vehicle')) {
      return _photos
          .where((p) => (p.title ?? '').toLowerCase().contains('car'))
          .toList();
    }

    if (normalized.contains('birthday') ||
        normalized.contains('cake') ||
        normalized.contains('party')) {
      return _photos
          .where(
            (p) =>
                (p.title ?? '').toLowerCase().contains('birthday') ||
                (p.title ?? '').toLowerCase().contains('cake'),
          )
          .toList();
    }

    // 4. Fallback search against title/id
    final directMatches = _photos
        .where(
          (p) =>
              (p.title ?? '').toLowerCase().contains(normalized) ||
              p.id.toLowerCase().contains(normalized),
        )
        .toList();

    return directMatches;
  }

  @override
  Future<List<String>> getSuggestedPrompts() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    return List.unmodifiable(kDefaultSuggestedPrompts);
  }

  @override
  Future<List<String>> getRecentSearches() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    return List.unmodifiable(_recentSearches);
  }

  @override
  Future<void> saveRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    _recentSearches.removeWhere(
      (q) => q.toLowerCase() == trimmed.toLowerCase(),
    );
    _recentSearches.insert(0, trimmed);
    if (_recentSearches.length > 10) {
      _recentSearches.removeLast();
    }
  }

  @override
  Future<void> clearRecentSearches() async {
    _recentSearches.clear();
  }
}
