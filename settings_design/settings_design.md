# Settings — Design Specification

## 1. Overview

This document defines the design system and implementation guidance for the **Settings** screen of the personal gallery assistant application.

The screen must remain visually consistent with the previously designed:

- **Library Home**
- **AI Gallery Search**

The overall design language is:

- Clean minimal iOS-inspired UI
- White-first background
- Dark navy typography
- Soft rounded cards
- Very subtle shadows
- Generous whitespace
- Orange as the primary product/action accent
- Soft pastel secondary accents
- Consistent outline iconography
- No dominant purple or green branding

The Settings screen should feel like part of the same application rather than a separate module.

---

# 2. Design Principles

The Settings screen should prioritize:

1. Clear grouping
2. Easy scanning
3. Minimal visual noise
4. Strong typography hierarchy
5. Consistent card geometry
6. Clear account/privacy controls
7. Safe treatment of destructive actions

The hierarchy is:

```text
Settings
   ↓
Account
   ↓
Appearance & Themes
   ↓
Privacy & Permissions
   ↓
About Application
   ↓
Sign Out
```

---

# 3. Screen Layout

Recommended screen structure:

```text
SafeArea
│
├── SettingsHeader
│   ├── BackButton
│   ├── Title
│   └── ProfileButton
│
├── AccountSection
│   └── AccountCard
│
├── AppearanceSection
│   └── ThemeSelectionCard
│       ├── Dark
│       ├── Light
│       └── Midnight Blue
│
├── PrivacySection
│   ├── LocalPrivacyCard
│   └── PhotoPermissionCard
│
├── AboutSection
│   └── AppInformationCard
│
└── SignOutButton
```

Use a vertically scrolling screen so the layout remains comfortable on smaller devices.

---

# 4. Header

The header contains:

- Back button
- `Settings`
- Profile/account button

### Back Button

Use:

- Circular light-gray/white surface
- Approximately 48–52 px
- Chevron-left icon
- Dark navy icon
- Very subtle shadow

### Title

```text
Settings
```

Recommended:

- 30–32 px
- Weight: 700
- Color: `#111827`

### Profile Button

- Circular white surface
- 48–56 px
- User icon
- Very subtle shadow
- Optional small orange notification/status dot

The header should visually match the Library screen's profile control.

---

# 5. Account Section

## Account Card

Content:

**User Account & Entitlements**

Description:

`Manage membership tier, view profile, and sign out`

The card contains:

- User icon inside a soft-orange circular background
- Title
- Description
- Chevron-right

Recommended:

```text
Card radius: 24 px
Padding: 20–24 px
Min height: 112–128 px
```

### Icon

Use:

**User Round**

Official Lucide icon:

https://lucide.dev/icons/user-round

The icon should use the primary orange accent.

---

# 6. Appearance & Themes

Section title:

**Appearance & Themes**

Use an orange Sun icon next to the heading if section icons are used.

The theme selector is a single rounded container with three options:

```text
Dark
Dark mode

Light
Light mode        selected

Midnight Blue
Dark mode
```

### Theme Rows

Each row contains:

- Theme icon
- Theme name
- Short description
- Radio/check selection control

Recommended row height:

```text
72–88 px
```

Recommended horizontal padding:

```text
16–20 px
```

Use subtle separators between rows.

---

# 7. Selected Theme

The current theme is **Light**.

Selected state:

- Very soft orange background
- Orange radio/check indicator
- Dark navy title
- Secondary gray description

Example:

```text
┌──────────────────────────────────────────────┐
│  ☼   Light                         ◉        │
│      Light mode                             │
└──────────────────────────────────────────────┘
```

Do not use a saturated orange row.

The orange should act as an accent only.

---

# 8. Theme Icons

### Dark

Use:

**Moon**

https://lucide.dev/icons/moon

### Light

Use:

**Sun**

https://lucide.dev/icons/sun

### Midnight Blue

Use:

**Moon Star**

https://lucide.dev/icons/moon-star

Theme icons can use subtle blue/gray/orange backgrounds according to the theme.

---

# 9. Privacy & Permissions

Section title:

**Privacy & Permissions**

Use:

**Shield**

https://lucide.dev/icons/shield

The section contains two major controls.

---

# 10. Local-Only Privacy Guarantee

Card title:

**Local-Only Privacy Guarantee**

Description:

`Your photos and media files never leave your device. All thumbnails, albums, and AI search indices are stored locally and are never uploaded to any remote server.`

### Card Design

- White/very-light surface
- Rounded 24 px
- Soft shadow
- Shield icon in a soft-orange circle
- Title in dark navy
- Description in muted gray

The privacy statement should be highly readable but not visually aggressive.

### Icon

Use:

**Shield**

https://lucide.dev/icons/shield

---

# 11. Photo Library Permission

Second privacy card:

**Photo Library Permission**

Status:

`Limited Access`

Action:

`Manage`

### Layout

```text
[Image icon]   Photo Library Permission
               Limited Access                    Manage >
```

The status should use the orange accent to indicate that access is limited and requires attention.

The `Manage` action can be rendered as a subtle warm-orange pill.

### Icon

Use:

**Images**

https://lucide.dev/icons/images

---

# 12. About Application

Section title:

**About Application**

Use:

**Info**

https://lucide.dev/icons/info

The information card contains:

```text
App Version             1.0.0 (Build 1)
Target Platforms        Android & iOS
Storage Engine          On-Device PhotoManager
Backend Auth            Supabase Auth
```

Each row has:

- Label on the left
- Value aligned right
- Subtle divider

---

# 13. About Information Typography

Labels:

- 16–17 px
- Regular/medium
- `#64748B`

Values:

- 16–17 px
- Semibold
- `#111827`

Do not make technical metadata visually larger than the main Settings content.

---

# 14. About Icons

Use small circular icon containers on the left of each row.

### App Version

**Package**

https://lucide.dev/icons/package

### Target Platforms

**Smartphone**

https://lucide.dev/icons/smartphone

### Storage Engine

**Database**

https://lucide.dev/icons/database

### Backend Auth

**Code 2**

https://lucide.dev/icons/code-2

These icons should remain subtle and secondary.

---

# 15. Sign Out

The Sign Out action is destructive and should therefore be visually distinct.

Recommended design:

- Full-width rounded button
- Very light warm-red/orange background
- Orange/red icon
- Orange/red text
- No heavy border

Example:

```text
┌──────────────────────────────────────────────┐
│                 ⇥  Sign Out                  │
└──────────────────────────────────────────────┘
```

Recommended:

```text
Height: 64–68 px
Radius: 32–34 px
```

Do not make the button bright saturated red unless the product later establishes red as its destructive-action color.

For consistency with the current visual system, a soft warm-orange treatment is acceptable.

### Icon

Use:

**Log Out**

https://lucide.dev/icons/log-out

---

# 16. Sign-Out Confirmation

Tapping Sign Out should not immediately sign the user out.

Show a confirmation dialog/sheet:

```text
Sign out?

Are you sure you want to sign out of your account?

Cancel                 Sign Out
```

The destructive action should remain visually distinct.

Recommended:

- Bottom sheet or native confirmation dialog
- White surface
- 24 px radius
- Minimal copy
- Clear Cancel action

---

# 17. Color Tokens

## Base

| Token | Hex |
|---|---|
| Background | `#FFFFFF` |
| Primary text | `#111827` |
| Secondary text | `#64748B` |
| Muted text | `#94A3B8` |
| Surface | `#FFFFFF` |
| Soft surface | `#F8FAFC` |
| Search/neutral surface | `#F3F4F6` |
| Divider | `#E5E7EB` |

## Primary Accent

| Token | Hex |
|---|---|
| Brand Orange | `#FF7A00` |
| Dark Orange | `#E96800` |
| Soft Orange | `#FFF1E5` |

## Secondary Pastels

| Token | Hex |
|---|---|
| Soft Blue | `#EEF6FF` |
| Soft Green | `#EEF9F3` |
| Soft Red | `#FFF0F1` |
| Soft Purple | `#F3F0FF` |
| Soft Yellow | `#FFF8E8` |

Secondary colors should only support categorization and state.

---

# 18. Typography

Use the same font system as Library and AI Search.

Recommended:

**Inter** or **SF Pro Display / SF Pro Text**

| Element | Size | Weight |
|---|---:|---:|
| Screen title | 30–32 px | 700 |
| Section heading | 22–26 px | 700 |
| Card title | 18–20 px | 600–700 |
| Card description | 15–16 px | 400–500 |
| Setting label | 16–17 px | 400–500 |
| Setting value | 16–17 px | 600 |
| Button text | 17–18 px | 600 |

Maintain a strong dark-navy hierarchy.

---

# 19. Spacing System

Use the same 8 px spacing system as the rest of the application.

```text
4 px   — micro spacing
8 px   — icon/text gap
12 px  — compact spacing
16 px  — standard spacing
20 px  — card padding
24 px  — section spacing
32 px  — major separation
40 px  — screen-level separation
```

Recommended horizontal page padding:

```text
24–32 px
```

---

# 20. Card System

All major settings cards should use the same visual language.

### Standard Card

```text
Background: #FFFFFF
Radius: 24 px
Border: none or #E5E7EB at 1 px
Shadow: very subtle
Padding: 20–24 px
```

Avoid:

- Heavy outlines
- Deep shadows
- Sharp corners
- Excessive gradients
- Neumorphism with strong highlights

The cards should feel lightweight.

---

# 21. Icon System

Use **Lucide Icons** consistently across the application.

Official library:

https://lucide.dev/

## Full icon list used on this screen

### Navigation

**Chevron Left**

https://lucide.dev/icons/chevron-left

### Profile / Account

**User Round**

https://lucide.dev/icons/user-round

### Account Card

**User Round**

https://lucide.dev/icons/user-round

### Appearance

**Sun**

https://lucide.dev/icons/sun

**Moon**

https://lucide.dev/icons/moon

**Moon Star**

https://lucide.dev/icons/moon-star

### Privacy

**Shield**

https://lucide.dev/icons/shield

**Images**

https://lucide.dev/icons/images

### About

**Info**

https://lucide.dev/icons/info

**Package**

https://lucide.dev/icons/package

**Smartphone**

https://lucide.dev/icons/smartphone

**Database**

https://lucide.dev/icons/database

**Code 2**

https://lucide.dev/icons/code-2

### Navigation / Actions

**Chevron Right**

https://lucide.dev/icons/chevron-right

**Log Out**

https://lucide.dev/icons/log-out

---

# 22. Icon Specifications

Default:

```text
Stroke width: 2 px
Line cap: Round
Line join: Round
```

Recommended sizes:

```text
Header: 22–24 px
Section icon: 22–24 px
Card icon: 22–26 px
Small metadata icon: 18–20 px
Action icon: 20–22 px
```

Keep the same Lucide outline style used by Library and AI Search.

Do not mix icon families.

---

# 23. Interaction States

Every interactive setting needs at least:

```text
Default
Pressed
Selected
Disabled
```

### Selected Theme

- Soft orange background
- Orange indicator
- Dark navy text

### Pressed Card

- Slightly darker surface
- Very subtle scale/opacity response

### Disabled

- Reduced opacity
- No strong accent color

---

# 24. Photo Permission States

The permission row should support:

### Full Access

```text
Photo Library Permission
Full Access
```

### Limited Access

```text
Photo Library Permission
Limited Access
```

### No Access

```text
Photo Library Permission
No Access
```

The status color can change according to severity, but orange should remain the primary attention color.

---

# 25. Account & Entitlements

The account screen opened from the account card can contain:

```text
Profile
Membership
Usage
Account information
Sign out
```

The main Settings screen should not become overloaded with account details.

The card acts as the entry point.

---

# 26. Theme Selection Behavior

Theme selection should update the application globally.

Available themes:

```text
Light
Dark
Midnight Blue
```

The current design uses:

```text
Light
```

Changing the theme should affect:

- Library
- AI Search
- Settings
- Navigation
- Cards
- Text
- Icons
- Input fields

All screens should share the same design tokens.

---

# 27. Accessibility

Every interactive element should have an accessible label.

Examples:

```text
Back
Open profile
Open account settings
Select dark theme
Select light theme
Select midnight blue theme
Manage photo permissions
Sign out
```

Do not communicate state through color alone.

Radio controls should include semantic selection state.

---

# 28. Responsive Behavior

The screen should work across:

- iPhone compact
- iPhone standard
- iPhone Pro Max
- Android phones
- Larger accessibility text sizes

For narrow devices:

- Cards remain full width
- Text wraps naturally
- Right-side values may move beneath labels if required
- Horizontal padding can reduce to 20 px

Never allow text to clip.

---

# 29. Flutter Implementation

Recommended widget hierarchy:

```text
SettingsScreen
│
├── SafeArea
│   └── CustomScrollView
│       ├── SettingsHeader
│       ├── AccountCard
│       ├── AppearanceSection
│       │   └── ThemeSelectionCard
│       ├── PrivacySection
│       │   ├── PrivacyGuaranteeCard
│       │   └── PhotoPermissionCard
│       ├── AboutSection
│       │   └── AppInformationCard
│       └── SignOutButton
│
└── SignOutConfirmationSheet
```

Recommended reusable components:

```text
SettingsHeader
SettingsSectionHeader
AccountSettingsCard
ThemeOptionTile
PrivacyGuaranteeCard
PhotoPermissionTile
AppInfoCard
AppInfoRow
DestructiveActionButton
```

---

# 30. Suggested Flutter Theme Tokens

Example structure:

```dart
class AppColors {
  static const background = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF111827);
  static const secondaryText = Color(0xFF64748B);
  static const mutedText = Color(0xFF94A3B8);

  static const accent = Color(0xFFFF7A00);
  static const accentDark = Color(0xFFE96800);
  static const accentSoft = Color(0xFFFFF1E5);

  static const surface = Color(0xFFFFFFFF);
  static const neutralSurface = Color(0xFFF3F4F6);
  static const divider = Color(0xFFE5E7EB);
}
```

These tokens should be centralized rather than hard-coded inside widgets.

---

# 31. Clean Architecture Considerations

Settings should be treated as a feature.

Recommended:

```text
features/
└── settings/
    ├── data/
    │   ├── datasources/
    │   ├── models/
    │   └── repositories/
    │
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    │
    └── presentation/
        ├── bloc/
        ├── pages/
        └── widgets/
```

Potential use cases:

```text
GetAccountDetails
UpdateTheme
GetPhotoPermissionStatus
OpenPhotoPermissionSettings
GetAppInformation
SignOut
```

---

# 32. Settings State

Recommended BLoC states:

```text
SettingsInitial
SettingsLoading
SettingsLoaded
SettingsUpdating
SettingsUpdateSuccess
SettingsFailure
```

Theme state:

```text
AppTheme
├── light
├── dark
└── midnightBlue
```

Photo permission:

```text
PhotoPermission
├── full
├── limited
└── denied
```

---

# 33. Privacy UX

The privacy statement must be technically accurate.

Do not display a claim such as:

> “Your photos never leave your device.”

unless the actual implementation guarantees that behavior.

If AI processing, cloud inference, backups, analytics, or synchronization ever transmit gallery-derived data, update the copy accordingly.

This is not just a UI concern; it is a product/legal trust statement.

---

# 34. Design Rules

## Do

- Keep the screen white and spacious.
- Use dark navy for primary text.
- Use orange as the main accent.
- Use soft pastel icon backgrounds.
- Keep cards rounded and lightweight.
- Use consistent 24 px card radii.
- Keep descriptions short.
- Make privacy information easy to understand.
- Use clear selection states.
- Make Sign Out clearly distinguishable.
- Maintain the exact visual language of Library and AI Search.

## Don't

- Bring back the dominant purple treatment.
- Make green the primary brand color.
- Use large decorative illustrations.
- Use heavy borders.
- Use strong shadows.
- Overload settings with unnecessary options.
- Put every setting into a separate giant card.
- Use saturated colors across the entire interface.
- Hide important permission status.
- Immediately sign users out without confirmation.

---

# 35. Final Design Direction

The Settings screen should feel like the natural third part of the product's design system:

```text
LIBRARY
White + Navy + Orange AI
        ↓
AI SEARCH
White + Navy + Orange AI
        ↓
SETTINGS
White + Navy + Orange actions
```

The shared visual language is:

```text
White canvas
      +
Dark navy typography
      +
Orange primary accent
      +
Soft pastel secondary accents
      +
Rounded cards
      +
Subtle shadows
      +
Lucide outline icons
      +
Generous whitespace
      +
iOS-inspired interaction patterns
```

The Settings screen should be calm and functional. It should support configuration without becoming visually heavier than the Library or AI Search screens.
