# AI Pipeline Integration — Phased Implementation Guide

**Companion documents:** `PROJECT_RULES.md`, `IMPLEMENTATION_PHASES.md`, `END_TO_END_FLOW.md`, `README.md` (AI Export), `UI_FLOW.md`
**Objective:** Incrementally integrate the on-device AI pipeline (`gallery_ai_engine`, ONNX models, SQLite-vec/FTS5, and background worker) into the Flutter gallery app without regressing the 108 existing tests or blocking the UI thread.
**Mandatory Lifecycle:** Plan -> Obtain Approval -> Implement -> Validate -> Summarize -> Gemini Audit -> Close Phase.

---

## Architecture Principles for AI Integration

1. **Zero UI Thread Stutter:**
   - Model inference, tensor transformations, and image resizing MUST run off the UI isolate (via Dart Isolates / `compute` or native background tasks).
2. **Decoupled Architecture & Headless CI Safety:**
   - The UI and Cubits depend exclusively on domain contracts (`AiPhotoSearchRepository`, `PhotoRepository`).
   - The production app injects `OnDeviceAiPhotoSearchRepository`.
   - Headless unit and widget tests MUST continue using `MockAiPhotoSearchRepository` to avoid `MissingPluginException` or native library load errors.
3. **Local Privacy Boundary (Section 8.4):**
   - Media indexing and embeddings are 100% on-device.
   - Cloud escalation (Gemini fallback) is only queued for receipts that fail the mathematical sanity gate and only when explicit user connectivity exists.
4. **Platform Adaptability (Rule 5.3):**
   - UI elements (progress banners, document sheets, financial widgets) must provide native Material 3 styling on Android and Cupertino styling on iOS.

---

# Phase 7.1 — Native Bindings, Asset Setup, and Offline Database Engine

## Objective
Establish the native dependencies (`onnxruntime`, `sqlite3_flutter_libs`), bundle the pre-trained ONNX models, and initialize the local SQLite database schema (with vector tables and FTS5) without breaking automated test suites.

## Scope
1. **Asset Configuration:**
   - Place models in `assets/models/`:
     - `vision_model.onnx` (MobileCLIP-S2 vision encoder)
     - `text_model.onnx` (MobileCLIP-S2 text encoder)
     - `weights.json` (Linear classifier head)
     - `ch_PP-OCRv4_det_infer.onnx` & `ch_PP-OCRv4_rec_infer.onnx` (OCR engine)
   - Declare all model assets in root `pubspec.yaml`.
2. **Package Integration:**
   - Link `gallery_ai_engine` as a local path package dependency (`./ai_pipeline_export/dart_module` or `packages/gallery_ai_engine`).
   - Add `onnxruntime: ^2.4.0` and `sqlite3_flutter_libs: ^0.5.24` to `pubspec.yaml`.
   - Configure Android NDK / minimum SDK and iOS Podfile settings if required by ONNX runtime.
3. **Database Foundation:**
   - Create `GalleryDatabaseService` wrapping `sqlite3` to execute `GalleryDatabaseSchema` (creating tables: `photos`, `documents`, `receipts`, and `fts_documents`).
4. **Test Protection:**
   - Configure conditional database/engine instantiation so headless test runs use an in-memory SQLite double without requiring physical ONNX runtime binaries.

## Exit Criteria
- App builds successfully on physical Android and iOS devices.
- Model assets are loaded into app bundle memory without `AssetNotFoundException`.
- Database initializes tables correctly.
- All existing 108 tests continue passing headlessly (`flutter test`).
- Gemini audits and signs off on Phase 7.1.

---

# Phase 7.2 — On-Device Semantic Photo Search Engine

## Objective
Connect natural-language semantic photo search (`"dog on grass"`, `"sunset at the beach"`) by implementing `OnDeviceAiPhotoSearchRepository` over `GalleryAIEngine.semanticSearch(...)`, replacing the mock in production while keeping UI screens untouched.

## Scope
1. **Repository Implementation:**
   - Create `OnDeviceAiPhotoSearchRepository` implementing the existing `AiPhotoSearchRepository` interface:
     - `searchPhotos({required String query})`:
       1. Encodes query into a 512-D vector using `text_model.onnx`.
       2. Runs vector cosine similarity search against indexed records in SQLite.
       3. Maps top-K matches into `PhotoModel` instances.
     - `getSuggestedPrompts()` and `getRecentSearches()`.
2. **Dependency Injection:**
   - Wire `OnDeviceAiPhotoSearchRepository` into `injection_container.dart` / `lib/main.dart`.
   - Ensure `SearchCubit` and `SearchScreen` require ZERO structural or API changes.
3. **Testing:**
   - Unit tests for vector math and rank-ordering using known vector fixtures.
   - Verify `SearchScreen` renders real semantic search results and navigates seamlessly to `PhotoViewerScreen`.

## Exit Criteria
- Searching `"dog"` or `"beach"` executes semantic vector scoring and displays matching photos.
- Search result tiles open directly in `PhotoViewerScreen`.
- Headless widget tests continue using `MockAiPhotoSearchRepository`.
- `flutter analyze` has 0 warnings; all tests pass.
- Gemini audits and signs off on Phase 7.2.

---

# Phase 7.3 — Background Gallery Indexing Engine & Isolate Worker

## Objective
Implement background photo indexing that processes device images off the UI thread (EXIF extraction -> vision embedding -> linear classification -> database storage) with a live, platform-adaptive progress banner in the gallery.

## Scope
1. **Background Worker (The Gauntlet):**
   - Implement indexing worker running in a dedicated background isolate (`compute` or `Isolate.spawn`).
   - For each unprocessed photo:
     - Step A: Read metadata (capture date, coordinates).
     - Step B: Resize image to 256x256 and run `vision_model.onnx` -> 512-D vector.
     - Step C: Linear classifier head (`weights.json`) assigns label: `Photo`, `Document`, or `Uncertain`.
     - Step D: Save embedding and classification into SQLite.
2. **Progress State Management:**
   - Create `IndexingCubit` (states: `IndexingIdle`, `IndexingInProgress(processed, total, percentage)`, `IndexingPaused`, `IndexingComplete`).
3. **Adaptive UI Indexing Banner (Rule 5.3):**
   - Embed collapsible progress banner at the top of `GalleryScreen`:
     - Android: Material 3 LinearProgressIndicator with theme elevation.
     - iOS: Cupertino-styled progress bar with native typography and icons.
   - Shows live count (e.g., *"⚡ Indexing Gallery: 342 / 1,250 photos (27%)"*).
4. **Performance Protection:**
   - Indexing runs only when the app is active or charging; halts if battery drops below 15%.
   - Gallery scrolling must maintain 60 FPS while indexing executes in the background.

## Exit Criteria
- Indexing advances through unindexed device photos without UI frame drops.
- Indexed vectors and classifications persist across app restarts.
- Progress banner accurately updates and auto-dismisses upon completion.
- Gemini audits and signs off on Phase 7.3.

---

# Phase 7.4 — Document OCR, Mathematical Sanity Gate, and Financial Analytics

## Objective
Implement document intelligence: offline PP-OCRv4 text extraction, regex sanity gating for receipts, full-text FTS5 search, financial analytics aggregations, and the smart document inspector overlay.

## Scope
1. **Document Pipeline:**
   - When classified as `Document`:
     - Run offline OCR (PP-OCRv4) to extract text lines.
     - Evaluate `DocumentSanityGate`:
       - If informational (ID cards, certificates): Index into SQLite FTS5.
       - If financial (receipts): Extract Subtotal, Tax, Total and check invariant `|Subtotal + Tax - Total| <= 0.05`.
       - If math passes: Save structured JSON to SQLite `receipts`.
       - If math fails: Queue in `cloud_queue` table for optional user-approved Gemini cloud sync.
2. **Category Tabs Integration:**
   - Enhance Phase 5 category bar with AI-backed filters:
     - `[ 📸 Photos ]` (`classification = 'Photo'`)
     - `[ 📄 All Documents ]` (`classification = 'Document'`)
     - `[ 🧾 Financial Receipts ]` (`doc_type = 'Financial'`)
     - `[ 🪪 Certificates & IDs ]` (`doc_type = 'Informational'`)
3. **Financial Analytics UI in Search:**
   - When search detects an expense query (e.g., *"Sum my hardware expenses for October"*):
     - Renders Financial Analytics Card showing aggregated total, currency, and verified receipt count.
4. **Smart Document Inspector Overlay (Screen 5 in UI_FLOW):**
   - Bottom sheet overlay in `PhotoViewerScreen` for document assets showing extracted vendor, date, and amounts with editable fields.
   - Rule 5.3: Material bottom sheet on Android vs. Cupertino modal sheet on iOS.

## Exit Criteria
- Receipts with valid math are indexed 100% offline.
- Natural-language queries for spending render correct financial calculation cards.
- Document text is searchable via FTS5.
- Document inspector allows editing extracted totals and updates SQLite instantly.
- Full test suite passes; Gemini audits and completes final phase sign-off.