# Flutter UI & UX Flow: Edge-First AI Gallery & Document Assistant

This document maps all AI backend capabilities directly to Flutter UI screens, widgets, state management, and user interaction flows.

---

## Screen 1: Onboarding & Privacy Assurance

### 1. Visual Layout
* **Headline:** "Private, Intelligent Gallery"
* **Privacy Shield Card:**
  * Icon: 🔒 Glowing green privacy badge
  * Copy: *"Your personal photos never leave your device. All semantic search and standard document indexing runs 100% on-device using local Apple/Google AI models."*
* **Permission Request Button:** `[ Grant Gallery Access ]`
  * Android: `READ_MEDIA_IMAGES` (API 33+) or `READ_EXTERNAL_STORAGE` (< API 33).
  * Handles Android 14 partial access ("Select Photos and Videos").

### 2. State Transition
* Once permissions are granted, navigate directly to **Main Gallery Screen (Screen 2)**.
* Trigger background indexing service in the native layer (WorkManager).

---

## Screen 2: Main Gallery Grid & Background Indexing

### 1. Visual Layout
* **App Bar:**
  * App Title: `Gallery AI`
  * Action: Search Icon (taps into Screen 3) / Settings Icon
* **Indexing Banner (Collapsible):**
  * Appears automatically during initial indexing:
    ```
    ┌────────────────────────────────────────────────────────┐
    │ ⚡ Indexing Gallery: 342 / 1,250 photos (27%)          │
    │ [████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░]                │
    │ On-device processing • Low battery impact              │
    └────────────────────────────────────────────────────────┘
    ```
* **Filter Pills (Horizontal Scrolling):**
  * `[ All ]` (Active)
  * `[ 📸 Photos ]` (Filtered by `classification = 'Photo'`)
  * `[ 📄 All Documents ]` (Filtered by `classification = 'Document'`)
  * `[ 🧾 Financial Receipts ]` (Filtered by `doc_type = 'Financial'`)
  * `[ 🪪 Certificates & IDs ]` (Filtered by `doc_type = 'Informational'`)
* **Gallery Grid:**
  * 3-column responsive photo grid using `MediaStore` thumbnail caching.
  * Badges overlaid on cards:
    * Documents display a subtle document icon in the top right corner.
    * Financial receipts display a green `$` pill tag with the extracted total.

---

## Screen 3: Natural Language Search & Smart Filter Bar

### 1. Visual Layout
* **Search Field:**
  * Placeholder: *"Search anything... 'my dog on the grass', 'grocery receipt', 'bonafide certificate'"*
  * Clear button `(X)`
* **Instant Filter Chips (Auto-suggested):**
  * `[ 📍 Near Me ]`
  * `[ 📅 Last Month ]`
  * `[ 🧾 Hardware Expenses ]`
  * `[ 🪪 IDs & Cards ]`
* **Thinking State (Micro-animation):**
  * Shimmer or pulsing gradient indicator (< 200ms) while ONNX text embedding runs.

---

## Screen 4: Search Results & Financial Analytics Dashboard

### 1. Dynamic Results Header
Depending on the intent parsed from the user's query:

#### Scenario A: Financial Analytics Intent (e.g. "Sum my grocery expenses for October")
* **Summary Widget:**
  ```
  ┌────────────────────────────────────────────────────────┐
  │ 💰 October Grocery Total                               │
  │ $348.50 USD                                            │
  │ 8 Verified Receipts • 1 Queued for Cloud Sync          │
  └────────────────────────────────────────────────────────┘
  ```
* Followed by a list of matching receipt cards sorted by date.

#### Scenario B: Semantic Image Search Intent (e.g. "sunset at the beach")
* Ordered Grid of photos ranked by Cosine Similarity score.
* Percentage match indicator for debugging/transparency (e.g. `94% match`).

#### Scenario C: Informational Document Search (e.g. "university bonafide certificate")
* List of document cards with snippet highlighting matching words from the SQLite FTS5 table:
  * *"NATIONAL UNIVERSITY... <b>BONAFIDE CERTIFICATE</b>... Student Name: Sarah Khan"*

---

## Screen 5: Document Viewer & Smart Inspector Overlay

When the user taps on any Document or Receipt card:

### 1. Screen Layout
* **Top Area:** Full pinch-to-zoom high-resolution image preview.
* **Bottom Sheet (Draggable Inspector):**
  * **Header:**
    * Document Category Pill: `Financial Receipt` or `Informational Document`
    * Verification Badge:
      * 🟢 `Verified Offline` (Regex math passed: Subtotal + Tax == Total)
      * 🔵 `Cloud Enhanced` (Extracted via Gemini 3.1 Flash-Lite)
      * 🟡 `Pending Cloud Sync` (Math failed, waiting for network)
  * **Extracted Fields (Editable):**
    * **Vendor:** `Walmart Supercenter` `[ Edit ]`
    * **Date:** `2026-10-02` `[ Edit ]`
    * **Subtotal:** `$80.00`
    * **Tax:** `$8.00`
    * **Total Amount:** `$88.00`
  * **Action Bar:**
    * `[ Share Receipt Data ]`
    * `[ Re-run Local OCR ]`
    * `[ Delete ]`

### 2. Interactive Editing
* If the user taps `[ Edit ]`, an inline text field opens.
* Upon saving:
  1. Updates the `documents` table in SQLite (`user_edited = 1`).
  2. Updates analytical aggregations immediately.

---

## Screen 6: Cloud Fallback Sync & Connectivity States

### 1. Offline / Airplane Mode
* Semantic search and local document extraction continue functioning with zero degradation.
* If a receipt math check fails while offline:
  * Badge displays: 🟡 `Pending Cloud Sync (Offline)`.
  * Item is stored in `cloud_queue` table.
* When connectivity is restored:
  * Flutter background worker dequeues items and posts to `/extract`.
  * Badge smoothly updates to 🔵 `Cloud Enhanced`.
