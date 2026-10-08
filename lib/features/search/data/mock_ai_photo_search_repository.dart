import 'package:gallery/features/gallery/domain/photo_model.dart';

import '../domain/ai_photo_search_repository.dart';
import '../domain/search_message_model.dart';

/// In-memory mock implementation of [AiPhotoSearchRepository].
/// Provides deterministic natural-language query responses, prompt suggestions,
/// conversational reasoning, and recent query persistence for testing and headless CI.
class MockAiPhotoSearchRepository implements AiPhotoSearchRepository {
  final Duration simulatedDelay;
  final List<PhotoModel> _photos;
  final List<String> _recentSearches;

  static const List<String> kDefaultSuggestedPrompts = [
    'Show photos of dogs',
    'Find photos from my birthday',
    'Show beach photos',
    'Find photos with cars',
    'Hilly areas',
    'Show payment receipts',
  ];

  MockAiPhotoSearchRepository({
    this.simulatedDelay = Duration.zero,
    List<PhotoModel>? photos,
    List<String>? initialRecentSearches,
  }) : _photos = photos ?? _generateMockPhotos(),
       _recentSearches = initialRecentSearches != null
           ? List.of(initialRecentSearches)
           : ['dogs', 'beach sunset', 'internet bill', 'Hassan salary'];

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
      PhotoModel(
        id: 'ai_hilly_1',
        title: 'Northern_Hills_Landscape.jpg',
        width: 3840,
        height: 2160,
        createDateTime: now.subtract(const Duration(days: 12)),
        isFavorite: true,
      ),
      PhotoModel(
        id: 'ai_hilly_2',
        title: 'Alpine_Valley_View.jpg',
        width: 2560,
        height: 1440,
        createDateTime: now.subtract(const Duration(days: 13)),
        isFavorite: false,
      ),
      PhotoModel(
        id: 'ai_hilly_3',
        title: 'Misty_Pine_Mountains.jpg',
        width: 1920,
        height: 1080,
        createDateTime: now.subtract(const Duration(days: 14)),
        isFavorite: false,
      ),
      PhotoModel(
        id: 'ai_hilly_4',
        title: 'Sunlit_Hilltop_Trail.jpg',
        width: 1920,
        height: 1080,
        createDateTime: now.subtract(const Duration(days: 15)),
        isFavorite: true,
      ),
      PhotoModel(
        id: 'ai_bill_1',
        title: 'PTCL_Broadband_Invoice_Sep2025.jpg',
        width: 1080,
        height: 1920,
        createDateTime: now.subtract(const Duration(days: 18)),
        isFavorite: false,
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
    if (normalized.contains('hilly') || normalized.contains('mountain')) {
      return _photos
          .where(
            (p) =>
                (p.title ?? '').toLowerCase().contains('hill') ||
                (p.title ?? '').toLowerCase().contains('mountain') ||
                (p.title ?? '').toLowerCase().contains('alpine'),
          )
          .toList();
    }

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

    if (normalized.contains('bill') ||
        normalized.contains('receipt') ||
        normalized.contains('ptcl')) {
      return _photos
          .where(
            (p) =>
                (p.title ?? '').toLowerCase().contains('bill') ||
                (p.title ?? '').toLowerCase().contains('invoice'),
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
  Future<SearchMessage> processAiQuery(String query) async {
    final normalized = query.trim().toLowerCase();
    final results = await searchPhotos(query: query);

    // Document reasoning query
    if (normalized.contains('internet') ||
        normalized.contains('bill') ||
        normalized.contains('ptcl') ||
        normalized.contains('last date')) {
      final billPhoto = _photos.firstWhere(
        (p) => p.id == 'ai_bill_1',
        orElse: () => _photos.first,
      );
      return SearchMessage(
        id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
        isUser: false,
        text: 'Based on the payment receipt screenshots in your gallery, the last date to pay your internet bill is:',
        photos: [billPhoto],
        documentEvidence: DocumentEvidenceModel(
          serviceName: 'PTCL Broadband',
          dueDate: '25 September 2025',
          amount: 'Rs 3,450',
          receiptPhoto: billPhoto,
        ),
        sourceContext: 'Based on 1 payment receipt in your gallery',
        timestamp: DateTime.now(),
      );
    }

    // Financial analysis query (subscriptions or salary)
    if (normalized.contains('subscription') ||
        normalized.contains('spend') ||
        normalized.contains('salary') ||
        normalized.contains('hassan')) {
      if (normalized.contains('salary') || normalized.contains('hassan')) {
        return SearchMessage(
          id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
          isUser: false,
          text: 'You paid Hassan Rs 185,000 in salary last year based on payment receipts.',
          financialBreakdown: const FinancialBreakdownModel(
            category: 'Salary Payments (Hassan)',
            totalAmount: 'Rs 185,000',
            items: [
              FinancialItemModel(title: 'January - March', amount: 'Rs 50,000'),
              FinancialItemModel(title: 'April - June', amount: 'Rs 50,000'),
              FinancialItemModel(
                title: 'July - September',
                amount: 'Rs 45,000',
              ),
              FinancialItemModel(
                title: 'October - December',
                amount: 'Rs 40,000',
              ),
            ],
          ),
          sourceContext: 'Based on 12 salary receipts in your gallery',
          timestamp: DateTime.now(),
        );
      } else {
        return SearchMessage(
          id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
          isUser: false,
          text: 'You spent Rs 8,450 on subscriptions last month.',
          financialBreakdown: const FinancialBreakdownModel(
            category: 'Monthly Subscriptions',
            totalAmount: 'Rs 8,450',
            items: [
              FinancialItemModel(
                title: 'Netflix 4K Premium',
                amount: 'Rs 1,100',
              ),
              FinancialItemModel(title: 'Spotify Family', amount: 'Rs 450'),
              FinancialItemModel(title: 'Google One 2TB', amount: 'Rs 900'),
              FinancialItemModel(title: 'AWS Cloud Server', amount: 'Rs 6,000'),
            ],
          ),
          sourceContext: 'Based on 4 receipts in your gallery',
          timestamp: DateTime.now(),
        );
      }
    }

    // Visual photo search query (hilly areas)
    if (normalized.contains('hilly') || normalized.contains('mountain')) {
      return SearchMessage(
        id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
        isUser: false,
        text: 'Here are 42 photos of hilly areas from your gallery.',
        photos: results,
        totalCount: 42,
        sourceContext: 'From your gallery',
        timestamp: DateTime.now(),
      );
    }

    // Default photo search response
    return SearchMessage(
      id: 'msg_${DateTime.now().microsecondsSinceEpoch}',
      isUser: false,
      text: results.isNotEmpty
          ? 'Found ${results.length} photos for "$query"'
          : 'We couldn\'t find any photos matching "$query". Try a different natural-language prompt.',
      photos: results,
      totalCount: results.length,
      sourceContext: results.isNotEmpty ? 'From your gallery' : null,
      timestamp: DateTime.now(),
    );
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
