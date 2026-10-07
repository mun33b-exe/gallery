# Zero-to-End: The Complete App Lifecycle

This document provides the definitive, chronological sequence of events for the entire application—from the moment the user installs it, to executing complex AI analytics queries.

---

## Stage 1: Installation & Onboarding
1. **App Launch:** User downloads the app and opens it.
2. **Permissions:** Flutter requests `READ_MEDIA_IMAGES` (Android) or `PHPhotoLibrary` (iOS). 
3. **Privacy Promise:** A UI splash screen guarantees: *"Your personal photos never leave this device. We use on-device Apple/Google AI to index your gallery."*
4. **Initial Scan:** Flutter queries the OS `MediaStore` for the total count of images and displays the main Gallery Grid.

---

## Stage 2: The Background Indexing Engine (The Gauntlet)
*This happens silently while the phone is plugged in or the app is in the background.*

1. **Trigger:** Flutter queues the unprocessed `media_ids` to an Android `WorkManager` (background thread).
2. **Step A: Metadata (EXIF):** Native OS extracts Capture Date, Latitude, and Longitude. Saved to SQLite `exif_metadata`.
3. **Step B: Embed (Vision Model):** Image is resized to 256x256, fed into `vision_model.onnx`. A 512-D vector is returned.
4. **Step C: Route (Classifier):** The 512-D vector is multiplied by `weights.json` (Linear Head). 
   - Label is assigned: `Photo`, `Document`, or `Uncertain`.
5. **Step D: Branching:**
   - **If `Photo`:** The 512-D vector is saved to SQLite-vec. **Processing ends.**
   - **If `Document`:** Image passes to Step E.
6. **Step E: Read (Local OCR):** Image is passed to `PP-OCRv4` ONNX models. Raw text is extracted.
7. **Step F: Parse (Regex Sanity Gate):**
   - Look for financial keywords (`Total`, `Tax`).
   - If missing: It's an informational document (ID card). Save raw text to SQLite. **Processing ends.**
   - If present: Extract `Total`, `Subtotal`, `Tax`. Run math: `abs((Subtotal + Tax) - Total) <= 0.05`.
   - **If Math Passes:** Save structured JSON to SQLite. **Processing ends.**
   - **If Math Fails:** Add to `cloud_upload_queue`.
8. **Step G: Cloud Fallback (Gemini API):** When the user has an internet connection, images in the queue are sent to the FastAPI backend. Gemini 3.1 Flash-Lite forcefully extracts the receipt JSON. Saved to SQLite.

---

## Stage 3: The Search & Analytics UI
1. **The Search Bar:** The user taps the search bar at the top of the gallery.
2. **The Input:** The user types a complex query: *"Sum my hardware expenses for October"* or *"Show me pictures of my dog at the beach in New York"*.
3. **The 'Thinking' State:** A micro-animation plays while the app processes the query (takes < 200ms).

---

## Stage 4: The Query Execution Flow (The Brain)
*What happens under the hood when the user hits 'Search'.*

1. **Intent Routing (Cloud/Local LLM):** The user's text is sent to the Cloud Intent Router (or a local NLP parser). It converts the text into structured JSON commands.
2. **Example A (Semantic Search):** *"Pictures of my dog in New York in 2026"*
   - **Intent Parser Output:** `{"concept": "my dog", "location": "New York", "year": "2026"}`
   - **Flutter Action:** 
     1. Pass `"my dog"` to `text_model.onnx` -> Gets 512-D Vector.
     2. Run SQL: `SELECT * FROM photos WHERE location='New York' AND date LIKE '2026%' ORDER BY vector_distance(...)`
     3. **UI Updates instantly** with dog photos.
3. **Example B (Analytics):** *"Sum my hardware expenses for October"*
   - **Intent Parser Output:** `{"intent": "sum", "category": "hardware", "month": "10"}`
   - **Flutter Action:** 
     1. Run SQL: `SELECT SUM(total_amount), currency FROM receipts WHERE category='hardware' AND strftime('%m', date) = '10' GROUP BY currency`
     2. **UI Updates instantly** showing a financial widget (e.g., "$450.00 USD") with the matching receipts listed below it!

---

## Stage 5: The Document Viewer
1. **Tapping a Result:** The user taps on a receipt from the search results.
2. **The Smart Overlay:** An overlay appears at the bottom of the screen showing:
   - **Vendor:** Home Depot
   - **Date:** 10/14/2026
   - **Total:** $45.99
3. **Editing:** If the user notices the AI got the total wrong, they tap `[ Edit ]`, fix the number, and it instantly updates the SQLite database and refreshes the Analytics sums.

---

## Stage 6: Maintenance & Syncing
1. **Taking a New Photo:** The OS `ContentObserver` notifies Flutter. The photo enters Stage 2 instantly.
2. **Deleting a Photo:** If a user deletes a photo from their OS gallery, the `ContentObserver` fires, and Flutter deletes the vector and JSON from the SQLite database to save space.
3. **Airplane Mode:** If the user has no internet, Semantic Search (dogs, beaches) and Local OCR continue working flawlessly because ONNX is 100% offline. Only the Gemini Fallback Queue and the NLP Intent Parser pause until the connection returns.
