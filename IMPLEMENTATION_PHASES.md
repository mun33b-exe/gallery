# AI Gallery App — Implementation Phases

**Companion rules:** `PROJECT_RULES.md`
**Purpose:** Define the controlled implementation sequence for the Flutter frontend
**Workflow:** Plan → obtain approval → implement → validate → summarize → Gemini audit → close phase

---

## How to use this file

1. Antigravity must read `PROJECT_RULES.md` first.
2. Antigravity must read the current phase in this file.
3. Antigravity must inspect the existing project state.
4. Antigravity must prepare an implementation plan.
5. Work starts only after explicit approval of that plan.
6. Antigravity implements only the approved phase scope.
7. Antigravity runs the required checks and creates a phase summary.
8. Gemini audits the implementation and summary against both project files.
9. The phase is closed only after audit findings are resolved or explicitly accepted.
10. The next phase must not begin before the previous phase is closed.

The phases are ordered to keep the app simple, testable, and ready for future AI integration without implementing the AI model itself.

---

# Phase 0 — Project confirmation and development foundation

## Objective

Confirm the Flutter project identity, target platforms, development environment, and baseline constraints before feature work begins.

## Scope

- Confirm or create the Flutter project.
- Confirm Android and iOS targets, if both are required.
- Confirm minimum supported OS versions.
- Confirm package-management and linting expectations.
- Create the base folder structure.
- Add the project rules and phase files to the project repository.
- Establish the initial README and development commands.

## Expected deliverables

- Flutter project builds in the intended environment.
- Initial feature-first directory structure.
- Baseline analysis and test configuration.
- Documented assumptions and target platforms.

## Exit criteria

- Baseline app launches.
- `dart format`, `flutter analyze`, and available tests run successfully.
- Project scope and target platforms are recorded.
- Antigravity phase summary is created and Gemini audit is complete.

---

# Phase 1 — App shell, design system, responsive system, and themes

## Objective

Build the reusable application shell and design foundation before implementing feature screens.

## Scope

- App entry point and dependency initialization.
- App theme architecture.
- Color constants and semantic color roles.
- Typography, spacing, radii, and common component constants.
- Extensible theme definitions and central theme registry.
- Theme selection state and initial theme-selection UI.
- Required `lib/core/responsive/responsive.dart` utility.
- Responsive navigation shell placeholder.
- Shared buttons, text fields, cards, loading indicators, and empty/error components where useful.

## Required design outcomes

- More than one theme can be registered.
- Adding a theme to the central list makes it available to the selection UI.
- Changing the selected theme updates the app without restart.
- No feature screen uses arbitrary color literals.
- Layout decisions use the responsive utility and available constraints.

## Exit criteria

- App shell renders correctly on small and large phone layouts.
- Theme registry and selection work.
- Responsive utility has tests for representative widths.
- Design constants are centralized.
- Gemini audits the design-system implementation.

---

# Phase 2 — Navigation and authentication frontend

## Objective

Create the authentication experience and route structure using replaceable mock data services.

## Scope

- Splash or session-loading screen.
- Welcome/onboarding screen if approved by the product design.
- Login screen.
- Registration screen.
- Forgot-password screen or placeholder flow.
- Profile/logout UI foundation.
- `AuthBloc` or `AuthCubit`.
- `AuthRepository` interface.
- Mock authentication repository.
- GoRouter route guards and authenticated/unauthenticated redirects.
- Validation, loading, error, and success states.

## Out of scope

- Production authentication backend.
- Real email delivery.
- Social login unless separately approved.
- Billing or subscription purchase.

## Exit criteria

- Mock login and logout work end-to-end.
- Protected routes redirect correctly.
- Invalid form input is handled accessibly.
- Loading and error states are visible.
- Gemini audits navigation and authentication boundaries.

---

# Phase 3 — Device photo access and gallery foundation

## Objective

Display device photos through a clean platform abstraction with correct permission handling.

## Scope

- Select and document the approved media-library package.
- Android and iOS permission configuration.
- Permission request, denied, restricted, and limited-access states.
- `PhotoModel` or equivalent application-level model.
- `PhotoRepository` interface.
- Platform media data source.
- `GalleryBloc` or equivalent.
- Initial photo loading and refresh.
- Responsive photo grid with thumbnails.
- Loading, empty, permission, and failure states.
- Pagination or incremental loading if required for performance.

## Privacy and performance requirements

- Do not transmit photos to a server.
- Do not load unnecessary full-resolution images in the grid.
- Avoid blocking the UI while media is loaded.
- Handle a device with zero photos.

## Exit criteria

- User can grant permission and see available photos.
- Denied and limited permission states have usable UI.
- Gallery works across representative screen widths.
- Scrolling and thumbnail loading are acceptable.
- Tests cover repository/BLoC state transitions where practical.
- Gemini audits platform access and privacy boundaries.

---

# Phase 4 — Photo viewer and basic photo interactions

## Objective

Allow users to open, browse, and interact with individual photos.

## Scope

- Full-screen photo viewer.
- Swipe navigation between photos.
- Pinch-to-zoom where supported by the chosen implementation.
- Basic metadata display.
- Favorite/unfavorite UI and state contract.
- Share action placeholder or platform share integration only if approved.
- Delete action placeholder unless deletion is explicitly approved.
- Error handling for unavailable or removed media.

## Exit criteria

- A photo opens from the gallery and can be browsed.
- Viewer behavior is responsive and accessible.
- Photo actions do not bypass repository boundaries.
- Destructive actions are not implemented without explicit approval.
- Gemini audits viewer behavior and interaction scope.

---

# Phase 5 — Basic categories and filtering

## Objective

Provide the non-AI gallery organization expected from a basic photo-gallery app.

## Scope

- Categories screen or category selector.
- All photos.
- Recent photos.
- Favorites.
- Device/provider categories such as screenshots, downloads, camera, or selfies only when reliably available.
- Category-specific loading, empty, and error states.
- Category filtering through repository/BLoC contracts.
- Responsive category UI.

## Important boundary

Categories must be based on available device metadata or explicit local rules. Do not claim AI-generated categories in this phase.

## Exit criteria

- Category list is clear and usable.
- Selecting a category displays the correct filtered photos.
- Unsupported categories are hidden or clearly marked unavailable.
- Gemini audits category semantics and platform assumptions.

---

# Phase 6 — AI-search frontend scaffold

## Objective

Create the complete AI-search user experience while keeping the actual model and search intelligence outside this project.

## Scope

- AI Search navigation entry.
- Search input and natural-language query UI.
- Suggested prompts.
- Recent search history UI.
- `SearchBloc`.
- `AiPhotoSearchRepository` interface.
- Mock AI-search repository.
- Searching, results, empty, error, retry, and unavailable-service states.
- Reusable result grid using the same `PhotoModel` as the gallery.
- Optional selected-photo handoff contract for future AI processing.
- Integration documentation for the future AI developer.

## Examples of supported UI queries

- “Show photos of dogs.”
- “Find photos from my birthday.”
- “Show beach photos.”
- “Find photos with cars.”

The examples are UI prompts only. The AI model is not implemented in this phase.

## Integration requirements

- The UI must not know whether the future service is local or remote.
- The repository contract must be replaceable without rewriting widgets.
- The app must not upload photos unless a separate approved requirement defines consent, transport, authentication, and privacy behavior.

## Exit criteria

- Mock search can demonstrate every major UI state.
- Search results open in the existing viewer.
- Contract and integration notes are documented.
- Gemini audits that no AI implementation has been incorrectly claimed.

---

# Phase 7 — Profile, settings, and premium-readiness foundation

## Objective

Complete user-facing account settings and prepare the UI for future premium entitlements without implementing payments.

## Scope

- Profile screen.
- Theme selection screen.
- Permission status entry point.
- App settings and information.
- Placeholder premium feature cards or locked states if approved.
- Basic user entitlement model/interface.
- Logout flow.
- Local persistence for theme and non-sensitive preferences.

## Out of scope

- Payment processing.
- Subscription purchase.
- Store billing integration.
- Real entitlement verification unless a backend already exists and is explicitly included.

## Exit criteria

- User can view profile and change the selected theme.
- Preferences behave consistently after restart if persistence is implemented.
- Premium placeholders do not imply an active purchase system.
- Gemini audits scope and user messaging.

---

# Phase 8 — Quality, performance, accessibility, and integration readiness

## Objective

Harden the frontend for handoff to the AI/backend team and future production work.

## Scope

- Cross-screen responsive review.
- Theme contrast review for every registered theme.
- Accessibility review.
- Gallery performance review.
- Image caching and memory review.
- Error-state consistency review.
- BLoC and repository test coverage improvement.
- Integration contract review for authentication, photos, and AI search.
- Remove debug code and unresolved placeholder behavior.
- Create final frontend handoff documentation.

## Exit criteria

- `dart format` is clean.
- `flutter analyze` has no unapproved findings.
- Relevant tests pass.
- Major flows have been manually validated.
- No privacy or scope violations are present.
- AI integration handoff is clear.
- Gemini completes the final audit.

---

# Phase summary template

At the end of every phase, Antigravity must create a summary using this structure:

```markdown
# Phase [number] Summary — [phase name]

## Status
- Ready for Gemini audit: Yes/No
- Phase closed: Yes/No

## Approved objective

## Implemented work
- 

## Files created or modified
- 

## Requirements and rules verified
- [ ] Rules file was read before implementation
- [ ] Approved scope was followed
- [ ] KISS principle was followed
- [ ] Responsive logic uses responsive.dart
- [ ] Colors and theme values use centralized constants
- [ ] Theme registry was updated if a theme changed
- [ ] BLoC/Cubit boundaries are respected
- [ ] Repository/platform boundaries are respected
- [ ] AI remains a scaffold unless explicitly approved
- [ ] Permission, loading, empty, and error states were considered

## Validation performed
- Commands:
  - 
- Tests:
  - 
- Devices or screen sizes checked:
  - 

## Deviations from the approved plan
- None / list deviations

## Known limitations and deferred work
- 

## Gemini audit checklist
- [ ] Functionality matches the approved plan
- [ ] No out-of-scope implementation was added
- [ ] Architecture remains integration-ready
- [ ] Responsive behavior is acceptable
- [ ] Theme behavior is acceptable
- [ ] Code quality checks pass
- [ ] Privacy boundary is respected
- [ ] Findings resolved or explicitly accepted

## Recommendation

Proceed to Phase [next number] / Return for corrections / Await user decision
```

---

# Phase approval template

Before implementation, Antigravity must provide:

```markdown
# Implementation Plan — Phase [number]

## Objective

## Requirements addressed

## Files expected to change

## Architecture and data flow

## UI and responsive approach

## State-management approach

## Dependencies

## Testing and validation

## Risks and assumptions

## Out of scope

## Approval request

Please approve this plan before implementation begins.
```
