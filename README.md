# AI Gallery App

A responsive Flutter frontend for a modern photo gallery application featuring device media access, category filtering, a full-screen photo viewer, an extensible theme engine, authentication flows, and an AI-search integration scaffold.

---

## 1. Project Principles & Architecture

This project strictly follows the architecture and quality standards defined in [PROJECT_RULES.md](PROJECT_RULES.md) and [IMPLEMENTATION_PHASES.md](IMPLEMENTATION_PHASES.md):

- **KISS (Keep It Simple)**: Prefer straightforward solutions; avoid premature optimization or speculative layers.
- **Separation of Concerns**: Unidirectional dependency: `UI / Widgets` -> `Bloc / Cubit` -> `Repository Interface` -> `Data Source / Platform Service`.
- **Feature-First Organization**: Code is organized by domain and feature in `lib/features/`.
- **Centralized Responsiveness**: All responsive scaling, breakpoints, and grid column determinations are centralized in `lib/core/responsive/responsive.dart`.
- **Extensible Design & Theme Engine**: All colors, typography, and spacing use centralized constants, supporting dynamic theme switching.
- **Privacy & AI Integration Boundary**: Device media remains strictly local. The AI-search feature is implemented against clean repository contracts with mock implementations until an AI backend service is officially integrated.

---

## 2. Directory Structure

```text
lib/
├── app/
│   ├── app.dart                   # Root application widget
│   ├── theme/                     # App colors, themes, spacing, typography
│   └── router/                    # Route configurations and navigation guards
├── core/
│   ├── constants/                 # Core application constants
│   ├── error/                     # Failure and exception abstractions
│   ├── responsive/                # Centralized responsive calculation utilities
│   └── utils/                     # General helper utilities
├── features/
│   ├── auth/                      # Authentication UI, BLoC, and repository contracts
│   ├── gallery/                   # Photo grid, permissions, and media repository
│   ├── categories/                # Category listing and filtering logic
│   ├── ai_search/                 # AI-search UI scaffold and mock repository
│   ├── photo_viewer/              # Fullscreen photo viewer and interactions
│   └── profile/                   # User profile, theme selection, and settings
├── injection_container.dart       # Dependency injection setup
└── main.dart                      # Application entry point
```

---

## 3. Development Environment & Targets

- **Framework**: Flutter (Channel `stable`, version `3.47.2+`)
- **Language**: Dart (`3.13.2+`)
- **Target Platforms**:
  - Android (minSdk 21+, targetSdk 34+)
  - iOS (iOS 12.0+)

---

## 4. Development Commands

### Format Code
```bash
dart format .
```

### Static Analysis
```bash
flutter analyze
```

### Run Tests
```bash
flutter test
```

### Run Application
```bash
# Run on connected device or simulator
flutter run
```

---

## 5. Implementation Roadmap

- [x] **Phase 0 — Project confirmation and development foundation**
- [x] **Phase 1 — App shell, design system, responsive system, and themes** (Completed, ready for audit)
- [ ] **Phase 2 — Navigation and authentication frontend**
- [ ] **Phase 3 — Device photo access and gallery foundation**
- [ ] **Phase 4 — Photo viewer and basic photo interactions**
- [ ] **Phase 5 — Basic categories and filtering**
- [ ] **Phase 6 — AI-search frontend scaffold**
- [ ] **Phase 7 — Profile, settings, and premium-readiness foundation**
- [ ] **Phase 8 — Quality, performance, accessibility, and integration readiness**
