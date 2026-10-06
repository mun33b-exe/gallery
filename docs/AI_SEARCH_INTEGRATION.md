# AI Search Integration Guide

This document outlines the architecture, domain contracts, and implementation guidelines for integrating a real AI/ML search engine into the Gallery application.

---

## 1. Architectural Overview

The AI search frontend has been engineered following Clean Architecture principles under strict adherence to `PROJECT_RULES.md` (Sections 2.2, 8.3, and 8.4):

- **Complete Decoupling**: The UI layer (`SearchScreen`, `SuggestedPromptsView`) and presentation BLoC (`SearchCubit`, `SearchState`) are strictly agnostic to whether the search engine runs on-device (e.g., MobileCLIP, ONNX Runtime Mobile, TensorFlow Lite, local vector index) or as a remote cloud service.
- **Privacy Boundary (Section 8.4)**: The default architecture ensures all photo indexing and query processing can happen entirely on-device with zero photo uploads or search queries sent over the network.
- **Clean Swappability**: Switching from the current `MockAiPhotoSearchRepository` to a production engine requires only implementing `AiPhotoSearchRepository` and passing the new instance to `GalleryApp(searchRepository: ...)`.

```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│   SearchScreen  ◄──►  SearchCubit  ◄──►  SearchState   │
└───────────────────────────▲────────────────────────────┘
                            │ depends only on contract
┌───────────────────────────▼────────────────────────────┐
│                      Domain Layer                      │
│             AiPhotoSearchRepository (Interface)        │
└───────────────────────────▲────────────────────────────┘
                            │ implemented by
     ┌──────────────────────┴──────────────────────┐
     │                                             │
┌────┴───────────────────────────┐   ┌─────────────┴─────────────┐
│  MockAiPhotoSearchRepository   │   │ Future On-Device / Cloud  │
│    (Deterministic mock/CI)     │   │      AI Implementation    │
└────────────────────────────────┘   └───────────────────────────┘
```

---

## 2. Domain Contract

The domain contract is defined in `lib/features/search/domain/ai_photo_search_repository.dart`:

```dart
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
```

### Method Specifications

| Method | Parameters | Return Type | Description |
|---|---|---|---|
| `searchPhotos` | `required String query` | `Future<List<PhotoModel>>` | Performs semantic matching of `query` against the photo collection. Must return photos ranked by similarity score. |
| `getSuggestedPrompts` | None | `Future<List<String>>` | Returns a list of curated or dynamically discovered prompt examples (e.g., "Show photos of dogs"). |
| `getRecentSearches` | None | `Future<List<String>>` | Returns stored user query strings in reverse-chronological order. |
| `saveRecentSearch` | `String query` | `Future<void>` | Persists `query` into local storage (deduplicated, max 10 entries). |
| `clearRecentSearches` | None | `Future<void>` | Clears all stored search queries. |

---

## 3. Implementing an On-Device Search Engine (Recommended)

To preserve user privacy and provide offline search capabilities, an on-device vector search engine using lightweight multimodal embeddings is recommended.

### Step 1: Add Machine Learning Dependencies

Add mobile inference packages to `pubspec.yaml`:
```yaml
dependencies:
  # Example: ONNX Runtime Mobile or TFLite Flutter
  onnxruntime: ^x.y.z
  # Local SQLite with vector extension or lightweight vector index
  sqlite3: ^x.y.z
```

### Step 2: Implement `OnDeviceAiPhotoSearchRepository`

Create `lib/features/search/data/on_device_ai_photo_search_repository.dart`:

```dart
import 'dart:isolate';
import '../../gallery/domain/photo_model.dart';
import '../../gallery/domain/photo_repository.dart';
import '../domain/ai_photo_search_repository.dart';

class OnDeviceAiPhotoSearchRepository implements AiPhotoSearchRepository {
  final PhotoRepository photoRepository;
  // Local vector index / SQLite instance

  OnDeviceAiPhotoSearchRepository({required this.photoRepository});

  @override
  Future<List<PhotoModel>> searchPhotos({required String query}) async {
    // 1. Offload text embedding generation to a background isolate:
    //    final queryVector = await compute(_embedQueryText, query);

    // 2. Query local vector database (e.g. cosine distance):
    //    final matchedIds = await _vectorDb.findNearest(queryVector, topK: 50);

    // 3. Resolve matched IDs into PhotoModel instances:
    //    return photoRepository.getPhotosByIds(matchedIds);
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getSuggestedPrompts() async {
    return [
      'Show photos of dogs',
      'Find photos from my birthday',
      'Show beach photos',
      'Find photos with cars',
      'Sunset by the ocean',
    ];
  }

  @override
  Future<List<String>> getRecentSearches() async {
    // Retrieve from SharedPreferences / SecureStorage
    return [];
  }

  @override
  Future<void> saveRecentSearch(String query) async {
    // Save to SharedPreferences / SecureStorage
  }

  @override
  Future<void> clearRecentSearches() async {
    // Clear SharedPreferences / SecureStorage
  }
}
```

### Step 3: Offload Heavy Inference from UI Thread

> **CRITICAL**: Never run text embedding models or vector scans directly on the main UI isolate. Always use `compute(...)` or long-running worker `Isolate`s to ensure 60/120 FPS UI smoothness.

---

## 4. Implementing a Cloud Search Engine (Alternative)

If an enterprise cloud backend is preferred:

```dart
class CloudAiPhotoSearchRepository implements AiPhotoSearchRepository {
  final http.Client httpClient;
  final String apiBaseUrl;

  CloudAiPhotoSearchRepository({required this.httpClient, required this.apiBaseUrl});

  @override
  Future<List<PhotoModel>> searchPhotos({required String query}) async {
    final response = await httpClient.post(
      Uri.parse('$apiBaseUrl/search'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query}),
    );
    // Parse response into List<PhotoModel>
    ...
  }
  ...
}
```

---

## 5. Wiring into the Application

Inject your new repository into `GalleryApp` in `lib/main.dart` or during composition:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Instantiate your AI search repository
  final searchRepo = OnDeviceAiPhotoSearchRepository(
    photoRepository: DevicePhotoRepository(),
  );

  runApp(
    GalleryApp(
      searchRepository: searchRepo,
    ),
  );
}
```

---

## 6. Testing Your Implementation

Ensure your repository fulfills the behavioral contracts by creating unit tests mirroring `test/features/search/search_cubit_test.dart`:

1. **Empty Query**: Empty or whitespace queries should not throw, but return initial prompts.
2. **Zero Results**: Returns an empty list (`[]`), triggering `SearchEmpty` state.
3. **Error Handling**: Throws meaningful exceptions on model loading or inference failures, triggering `SearchError` state with user-facing retry capability.
4. **Recent Searches**: Respects deduplication, limits to 10 entries, and handles clearing cleanly.
