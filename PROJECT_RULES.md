# AI Gallery App — Project Rules and Development Standards

**Document status:** Mandatory
**Audience:** Antigravity, Gemini, Flutter developers, reviewers, and future contributors
**Project scope:** Flutter frontend for a photo gallery app with authentication, basic gallery categories, and an AI-search integration scaffold

---

## 1. Mandatory operating procedure for Antigravity

These rules are binding for every implementation task.

### 1.1 Read-before-action rule

Before inspecting, changing, creating, deleting, or refactoring any code, Antigravity **must read this file first**:

```text
PROJECT_RULES.md
```

Antigravity must then read the relevant section of:

```text
IMPLEMENTATION_PHASES.md
```

If either file is missing, unclear, or contradictory, Antigravity must stop and report the issue before making implementation changes.

### 1.2 Planning and approval gate

For every phase or non-trivial task, Antigravity must first create an implementation plan containing:

- Objective and scope
- Requirements being addressed
- Files and folders expected to change
- Proposed architecture and data flow
- Dependencies or packages required
- UI and responsive-design approach
- State-management approach
- Error, loading, empty, and permission states
- Testing and validation plan
- Risks, assumptions, and out-of-scope items

Antigravity must present the plan for approval before implementation begins. **No implementation work may start before explicit approval.**

### 1.3 End-of-phase audit handoff

At the end of every phase, Antigravity must create a phase summary before moving to the next phase. The summary must include:

- What was implemented
- Files created or modified
- Features completed
- Rules and requirements satisfied
- Tests and validation performed
- Known limitations or deferred work
- Any deviations from the approved plan
- Recommended audit checks for Gemini
- Whether the phase is ready for approval

Gemini reviews the summary and implementation against this rules file and the phase file. Antigravity must address audit findings before the phase is considered complete.

### 1.4 No silent assumptions

If a requirement can materially affect architecture, user experience, security, permissions, integration, or future premium functionality, Antigravity must state the assumption and request clarification or approval.

For low-risk details, Antigravity may choose a sensible default but must record it in the phase summary.

---

## 2. Product scope and boundaries

### 2.1 In scope for the Flutter frontend

- Responsive photo-gallery UI
- Device photo permission handling
- Displaying photos available on the device
- Basic photo categories and filters
- Photo grid and full-screen photo viewer
- Authentication UI and replaceable authentication repository
- Main navigation and route protection
- AI-search UI scaffold
- Mock AI-search repository and integration contracts
- Loading, error, empty, permission, and offline states
- Theme selection and extensible theme definitions
- Clean interfaces for future backend and AI integration

### 2.2 Explicitly out of scope unless separately approved

- Training or implementing the AI model
- Face recognition, object detection, embeddings, or vector search
- AI indexing pipeline
- Production backend development
- Payment processing or subscription billing
- App-store publishing
- Uploading photos to a server without an approved product and privacy decision
- Collecting or transmitting personal photo data by default

The frontend must be designed for future integration but must not pretend that AI functionality is implemented when it is only mocked.

---

## 3. Core engineering principles

### 3.1 KISS — Keep It Simple

- Prefer the simplest design that meets the current requirement.
- Do not introduce abstractions without a clear current or integration-related reason.
- Avoid speculative features and premature optimization.
- Keep widgets focused and readable.
- Prefer composition over deeply nested inheritance.
- Do not duplicate business rules across screens.

### 3.2 Separation of concerns

Use the following direction of dependency:

```text
UI / Widgets
    ↓
Bloc or Cubit
    ↓
Use case or application service (when useful)
    ↓
Repository interface
    ↓
Data source / platform service / remote service
```

Widgets must not directly call device APIs, authentication services, local storage, or future AI APIs.

### 3.3 Feature-first organization

Code must be organized primarily by feature, not by a single global folder of all widgets or all models.

Recommended structure:

```text
lib/
├── app/
├── core/
├── features/
│   ├── auth/
│   ├── gallery/
│   ├── categories/
│   ├── ai_search/
│   ├── photo_viewer/
│   └── profile/
└── injection_container.dart
```

Each feature should use `data`, `domain`, and `presentation` only when that separation provides real value. KISS applies: do not create empty ceremony-only layers.

---

## 4. Required technology standards

- **Framework:** Flutter
- **Language:** Dart
- **State management:** `flutter_bloc` using BLoC or Cubit
- **Navigation:** `go_router`
- **Design:** Responsive layouts for phones and tablets
- **Formatting:** `dart format`
- **Static analysis:** `flutter analyze`
- **Testing:** Flutter unit, widget, and integration tests as appropriate
- **Dependency management:** Use `pubspec.yaml`; do not manually copy package source into the project

Package choices must be documented in the implementation plan and approved when they affect platform permissions, media access, authentication, or architecture.

---

## 5. Responsive design standard

### 5.1 Central responsive utility is mandatory

All responsive calculations must be centralized in:

```text
lib/core/responsive/responsive.dart
```

The file should contain shared utilities for:

- Screen width and height
- Device size classes
- Horizontal and vertical spacing
- Responsive padding and margins
- Gallery column calculation
- Responsive font or component scaling only when necessary
- Orientation or available-width decisions

Do not scatter raw `MediaQuery` calculations throughout the application.

### 5.2 Layout rules

- Use available constraints rather than fixed screen assumptions.
- Prefer `LayoutBuilder`, adaptive grids, flexible widgets, and minimum item widths.
- Avoid hard-coded widths that break on smaller phones.
- Avoid device-specific conditionals unless there is a documented platform reason.
- Test at minimum on a small phone, a normal phone, a large phone, and a tablet-sized layout.
- UI must remain usable with text scaling and accessibility settings.
- Do not use `ScreenUtil` or another responsive package unless explicitly approved; the project already has a required centralized `responsive.dart` approach.

Example gallery principle:

```dart
final columns = Responsive.galleryColumns(context);
```

The exact algorithm may evolve, but it must remain centralized and testable.

---

## 6. Colors, typography, spacing, and themes

### 6.1 Constants only

Do not place arbitrary colors, text styles, spacing values, radii, or durations directly inside feature widgets when they are reusable or part of the design system.

Recommended locations:

```text
lib/app/theme/app_colors.dart
lib/app/theme/app_theme.dart
lib/app/theme/app_text_styles.dart
lib/app/theme/app_spacing.dart
```

Use semantic names such as `surfacePrimary`, `textSecondary`, `accent`, and `error` rather than names tied to a single screen.

### 6.2 Multiple themes are required to be supported

The theme system must be extensible. Each theme must have:

- A stable unique name or identifier
- A display name
- A complete color scheme
- Light/dark behavior defined clearly
- Text and component styling compatibility
- A place in the registered theme list

Adding a theme must mean adding it to the central theme registry/list, not modifying many unrelated screens.

Recommended conceptual model:

```dart
class AppThemeDefinition {
  final String id;
  final String name;
  final ThemeData themeData;
}
```

Recommended registry concept:

```dart
class AppThemes {
  static const List<AppThemeDefinition> available = [
    // Add every supported theme here.
  ];
}
```

The selected theme must be rendered by the app and exposed in the theme-selection UI. The selected theme should be persisted locally when persistence is implemented.

### 6.3 Theme rules

- Widgets must use `Theme.of(context)` or semantic theme extensions.
- Avoid direct use of raw color literals in feature code.
- Every registered theme must be checked for readable contrast.
- Theme selection must update the UI without restarting the app.
- A default theme must always exist.
- A newly added theme must be included in the list shown to the user automatically.

---

## 7. State-management standards

Use BLoC/Cubit for state that affects UI or application behavior.

Recommended responsibilities:

- `AuthBloc` or `AuthCubit`: session state, login, registration, logout
- `GalleryBloc`: permissions, loading, refresh, pagination, selection
- `CategoryCubit` or `CategoryBloc`: category loading and filtering
- `SearchBloc`: query submission, loading, results, errors, recent searches
- `ThemeCubit`: selected theme and persistence state

State must explicitly represent at least the relevant loading, loaded, empty, and failure conditions. Avoid boolean state combinations that can represent contradictory states.

BLoCs must not contain widget-specific layout logic.

---

## 8. Photo and AI integration contracts

### 8.1 Photo abstraction

The UI should work with an application-level photo model, not directly with a platform-specific asset object.

The model may include:

- Stable photo ID
- Local reference or path, when permitted
- Creation date
- Dimensions
- Favorite status
- Basic categories
- Optional metadata

### 8.2 Repository abstraction

The gallery must use a replaceable repository interface for device media access. The platform-specific implementation belongs in the data layer.

### 8.3 AI search scaffold

The AI-search frontend must use a replaceable contract such as:

```dart
abstract class AiPhotoSearchRepository {
  Future<List<PhotoModel>> searchPhotos({
    required String query,
  });
}
```

The initial implementation may be a mock repository. The UI must support:

- Initial state
- Query input
- Suggested searches
- Searching state
- Results state
- Empty results
- Error state
- Retry

The contract must not assume whether the future AI system is local, remote, REST-based, GraphQL-based, or provided by another Flutter module.

### 8.4 Privacy boundary

No photo should be uploaded, shared, or transmitted to a remote service by the frontend unless that behavior is explicitly approved and implemented with clear user-facing consent.

---

## 9. Authentication and premium readiness

- Authentication UI must be separated from authentication implementation.
- Use an `AuthRepository` interface and a mock implementation until the backend exists.
- GoRouter must support authenticated and unauthenticated route states.
- Do not implement payment or billing in the frontend scope without a separately approved requirement.
- Premium readiness may include a user entitlement model and locked-feature UI placeholders, but no fake purchase flow.
- Logged-out, loading, authenticated, and authentication-error states must be handled explicitly.

---

## 10. UX, accessibility, and error handling

Every feature must define:

- Loading state
- Empty state
- Error state
- Retry behavior where meaningful
- Permission-denied state where applicable
- Offline or unavailable-service behavior where applicable

Accessibility requirements:

- Use meaningful semantic labels for icons and image actions.
- Maintain readable contrast across every registered theme.
- Support text scaling without clipping important controls.
- Ensure touch targets are appropriately sized.
- Do not communicate important information by color alone.

---

## 11. Code quality standards

- Run `dart format` on changed Dart files.
- Run `flutter analyze` before phase completion.
- Add or update tests for changed behavior.
- Avoid `dynamic` unless there is a documented boundary reason.
- Avoid unnecessary global mutable state.
- Use null safety correctly; do not silence errors with careless `!` operators.
- Do not leave debug prints, dead code, placeholder TODOs, or commented-out implementations in completed work unless documented.
- Use descriptive names and small, focused methods.
- Keep public interfaces documented when their purpose is not obvious.

---

## 12. Definition of done for each phase

A phase is complete only when:

- The approved scope is implemented.
- The app builds successfully for the intended target.
- `dart format` has been run.
- `flutter analyze` has been run with no unapproved issues.
- Relevant tests pass.
- Responsive behavior has been checked.
- Loading, empty, error, and permission states are addressed.
- No out-of-scope AI or backend behavior has been invented.
- Antigravity has produced the required phase summary.
- Gemini has had an opportunity to audit the work.
- Any audit findings are resolved or explicitly deferred with approval.

---

## 13. Required response format for Antigravity

### Before implementation

```text
1. Rules and phase file read
2. Current project state
3. Requested phase/task
4. Implementation plan
5. Files expected to change
6. Risks and assumptions
7. Approval requested
```

### After implementation

```text
1. Phase completed
2. What was implemented
3. Files changed
4. Tests and commands run
5. Responsive/theme/accessibility checks
6. Deviations from plan
7. Known limitations
8. Gemini audit checklist
9. Approval requested to close the phase
```

These response formats are mandatory for traceability.
