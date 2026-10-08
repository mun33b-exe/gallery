# Profile — Design Specification

## 1. Overview

This document defines the design system and implementation guidance for the **Profile** screen of the personal gallery assistant application.

The Profile screen must remain visually consistent with the existing:

- Library Home
- AI Gallery Search
- Settings

The shared product language is:

- White-first interface
- Minimal and modern
- iOS-inspired
- Dark navy typography
- Orange as the primary product/action accent
- Soft pastel secondary colors
- Rounded cards
- Subtle shadows
- Generous whitespace
- Consistent Lucide outline icons

The Profile screen should feel like an account and membership hub rather than a conventional settings page.

---

# 2. Screen Purpose

The Profile screen allows the user to:

1. View their account identity.
2. Understand their current membership.
3. Preview upcoming premium capabilities.
4. Access future feature previews.
5. Sign out safely.

The information hierarchy is:

```text
Profile
   ↓
Account identity
   ↓
Plan & Membership
   ↓
Upcoming Pro Features
   ↓
Premium feature previews
   ↓
Sign Out
```

---

# 3. Overall Layout

Recommended structure:

```text
SafeArea
│
├── ProfileHeader
│   ├── BackButton
│   ├── Title
│   └── SettingsButton
│
├── AccountIdentityCard
│
├── MembershipCard
│
├── UpcomingFeaturesHeader
│
├── ProFeatureCard
├── ProFeatureCard
├── ProFeatureCard
│
└── SignOutButton
```

Use a vertical scroll view so the screen remains usable on compact devices.

---

# 4. Header

The header contains:

- Back button
- `Profile`
- Settings button

### Title

```text
Profile
```

Recommended:

- Size: 30–32 px
- Weight: 700
- Color: `#111827`

### Subtitle

The redesigned version may optionally use:

```text
Manage your account and plan
```

Recommended:

- 16–17 px
- Weight: 400
- Color: `#6B7280`

The subtitle should only be used if there is enough vertical space.

---

# 5. Back Button

Use a circular light neutral button.

Specifications:

```text
Size: 48–52 px
Radius: 24–26 px
Background: #F8FAFC
Icon: #334155
```

Icon:

**Chevron Left**

https://lucide.dev/icons/chevron-left

Do not use the saturated purple back arrow from the original screen.

---

# 6. Settings Button

Place a circular settings button on the right side of the header.

Specifications:

```text
Size: 48–52 px
Radius: 24–26 px
Background: #FFFFFF
Border: #E5E7EB
Shadow: subtle
```

Icon:

**Settings**

https://lucide.dev/icons/settings

The icon should use dark navy rather than purple.

Tapping it can navigate to the main Settings screen.

---

# 7. Account Identity Card

The account card introduces the current user.

Example:

```text
┌────────────────────────────────────────────────┐
│                                                │
│   [ M ]    Muneeb                              │
│            mtpicsdesigner@gmail.com          > │
│                                                │
└────────────────────────────────────────────────┘
```

### Avatar

Use a circular avatar.

Recommended:

```text
Size: 112–128 px
Background: #FFF1E5
Letter: #FF7A00
```

The initial can be:

```text
M
```

Typography:

- 40–48 px
- Weight: 600–700

If the user has a profile image, replace the initial with the image while preserving the same circular geometry.

---

# 8. Account Information

Name:

```text
Muneeb
```

Email:

```text
mtpicsdesigner@gmail.com
```

Name:

- 30–34 px
- Bold
- `#111827`

Email:

- 17–19 px
- Regular
- `#64748B`

Avoid displaying unnecessary account metadata on this screen.

---

# 9. Account Card Interaction

The account identity card may be tappable.

Recommended affordance:

- Chevron-right at the far right
- Subtle pressed state
- No large button

Icon:

**Chevron Right**

https://lucide.dev/icons/chevron-right

Possible destination:

```text
Account Details
```

---

# 10. Plan & Membership

The membership card communicates the user's current plan.

Title:

```text
Plan & Membership
```

Current status:

```text
Free Plan
```

Description:

```text
Your account is currently on the Free Plan. Local device
media management, responsive filtering, and natural-language
search preview are active.
```

The exact feature list should always reflect the actual product capabilities.

---

# 11. Membership Card Design

Recommended:

```text
Background: #FFFFFF
Radius: 24 px
Padding: 20–24 px
Border: #E5E7EB or none
Shadow: subtle
```

Top row:

```text
[ Crown ]    Plan & Membership                 Free Plan
```

The Free Plan label should be an orange-tinted pill.

Example:

```text
┌──────────────────────────────────────────────┐
│  👑  Plan & Membership              Free Plan│
│                                              │
│  Your account is currently on the Free Plan. │
│  Local device media management...            │
└──────────────────────────────────────────────┘
```

---

# 12. Membership Icon

Use:

**Crown**

https://lucide.dev/icons/crown

Icon container:

```text
Background: #FFF1E5
Icon: #FF7A00
```

Do not use a purple crown.

---

# 13. Plan Badge

Current:

```text
Free Plan
```

Recommended:

```text
Background: #FFF1E5
Text: #E96800
Radius: 20 px
Padding: 10–14 px horizontal
```

The badge should be visually noticeable but not dominant.

---

# 14. Membership Description

Use secondary text.

Recommended:

```text
Font size: 15–16 px
Line height: 1.45–1.55
Color: #64748B
```

Avoid overly technical language.

The user should understand what they currently have without needing to read documentation.

---

# 15. Upcoming Pro Features

Section title:

```text
Upcoming Pro Features
```

Use an orange Sparkles icon.

Subtitle:

```text
Previewing future premium enhancements
(Coming Soon — no store billing required).
```

The wording should only be used if the application actually plans to introduce these features.

---

# 16. Upcoming Features Header

Recommended layout:

```text
✦  Upcoming Pro Features
   Previewing future premium enhancements
   (Coming Soon — no store billing required).
```

Title:

- 24–26 px
- Weight: 700
- Dark navy

Subtitle:

- 15–16 px
- Weight: 400
- `#94A3B8`

Icon:

**Sparkles**

https://lucide.dev/icons/sparkles

Primary AI/product accent:

```text
#FF7A00
```

---

# 17. Pro Feature Cards

Each premium feature is represented by a compact horizontal card.

Current examples:

1. Unlimited On-Device AI Search
2. Lossless RAW & HDR Export
3. Semantic Face & Event Clustering

Structure:

```text
┌──────────────────────────────────────────────────┐
│ [icon]  Feature title                  Preview > │
│         Feature description                       │
└──────────────────────────────────────────────────┘
```

Recommended:

```text
Radius: 22–24 px
Padding: 20 px
Background: #FFFFFF
Border: #E5E7EB or none
Shadow: very subtle
```

---

# 18. Feature Card 1 — Unlimited On-Device AI Search

Title:

```text
Unlimited On-Device AI Search
```

Description:

```text
Instant semantic photo discovery powered by local
on-device neural vectors with zero photo uploads.
```

Icon:

**Search**

https://lucide.dev/icons/search

Suggested icon treatment:

```text
Background: #EEF6FF
Icon: #2563EB
```

This is a good place to use blue because the feature represents search rather than the primary product brand.

---

# 19. Feature Card 2 — Lossless RAW & HDR Export

Title:

```text
Lossless RAW & HDR Export
```

Description:

```text
Export full-fidelity DNG, Apple ProRAW, and UltraHDR
photos without compression.
```

Icon:

**Images**

https://lucide.dev/icons/images

Suggested treatment:

```text
Background: #FFF1E5
Icon: #FF7A00
```

This connects photography to the product's primary orange accent.

---

# 20. Feature Card 3 — Semantic Face & Event Clustering

Title:

```text
Semantic Face & Event Clustering
```

Description:

```text
Private on-device face clustering and automatic
life-event album generation.
```

Icon:

**Users Round**

https://lucide.dev/icons/users-round

Suggested treatment:

```text
Background: #EEF9F3
Icon: #159A68
```

Green is used only as a secondary semantic color and should not become a dominant branding color.

---

# 21. Preview Action

Each feature can have:

```text
Preview >
```

Recommended design:

- Soft orange pill
- Orange text
- Chevron-right
- Compact horizontal padding

Example:

```text
┌───────────────┐
│ Preview    >  │
└───────────────┘
```

Specifications:

```text
Background: #FFF1E5
Text: #E96800
Radius: 20–22 px
```

The action should communicate that the feature is not yet generally available.

---

# 22. Feature Preview Behavior

Tapping `Preview` can open a lightweight detail sheet.

Example:

```text
Unlimited On-Device AI Search

Coming Soon

Search your entire photo library using natural
language without uploading your photos.

[ Got it ]
```

Do not make preview features appear purchasable unless billing is actually implemented.

---

# 23. Sign Out

Sign Out is a destructive account action and should be visually distinct.

Recommended redesign:

```text
┌────────────────────────────────────────────────┐
│                 ⇥  Sign Out                    │
└────────────────────────────────────────────────┘
```

Use a soft warm-red/orange surface rather than saturated purple.

Recommended:

```text
Background: #FFF1ED
Text: #E96800
Icon: #E96800
Height: 64–68 px
Radius: 32–34 px
```

Icon:

**Log Out**

https://lucide.dev/icons/log-out

The button should be separated from the feature cards by approximately 32–40 px.

---

# 24. Sign-Out Confirmation

Never immediately sign the user out.

Show a confirmation sheet/dialog:

```text
Sign out?

Are you sure you want to sign out of your account?

Cancel                    Sign Out
```

The destructive action should be clearly identifiable.

---

# 25. Color System

## Base

| Token | Hex |
|---|---|
| Background | `#FFFFFF` |
| Primary text | `#111827` |
| Secondary text | `#64748B` |
| Muted text | `#94A3B8` |
| Surface | `#FFFFFF` |
| Soft surface | `#F8FAFC` |
| Neutral surface | `#F3F4F6` |
| Divider | `#E5E7EB` |

## Primary Accent

| Token | Hex |
|---|---|
| Orange | `#FF7A00` |
| Dark Orange | `#E96800` |
| Soft Orange | `#FFF1E5` |

## Secondary Accents

| Token | Hex |
|---|---|
| Soft Blue | `#EEF6FF` |
| Blue | `#2563EB` |
| Soft Green | `#EEF9F3` |
| Green | `#159A68` |
| Soft Red | `#FFF0F1` |
| Soft Purple | `#F3F0FF` |

Purple should not be used as the primary product color.

---

# 26. Typography

Use the same font system as Library, AI Search and Settings.

Recommended:

**Inter** or **SF Pro Display / SF Pro Text**

| Element | Size | Weight |
|---|---:|---:|
| Screen title | 30–32 px | 700 |
| Subtitle | 16–17 px | 400 |
| User name | 30–34 px | 700 |
| Email | 17–19 px | 400 |
| Section heading | 24–26 px | 700 |
| Card title | 18–20 px | 650–700 |
| Card description | 15–16 px | 400–500 |
| Badge | 14–15 px | 600 |
| Button text | 17–18 px | 600 |

---

# 27. Spacing System

Use the shared 8 px spacing system.

```text
4 px   — micro
8 px   — icon/text gap
12 px  — compact spacing
16 px  — standard spacing
20 px  — card padding
24 px  — section spacing
32 px  — major separation
40 px  — screen-level separation
```

Recommended page padding:

```text
24–32 px
```

Recommended card-to-card spacing:

```text
16 px
```

---

# 28. Card Geometry

All cards should share the same visual language.

Standard:

```text
Radius: 22–24 px
Padding: 20–24 px
Background: #FFFFFF
Border: none or 1 px #E5E7EB
Shadow: very subtle
```

Avoid:

- Heavy borders
- Deep shadows
- Sharp corners
- Glassmorphism
- Strong gradients
- Excessive decoration

---

# 29. Icon System

Use **Lucide Icons** consistently.

Official library:

https://lucide.dev/

### Navigation

**Chevron Left**

https://lucide.dev/icons/chevron-left

**Settings**

https://lucide.dev/icons/settings

**Chevron Right**

https://lucide.dev/icons/chevron-right

### Account

**User Round**

https://lucide.dev/icons/user-round

### Membership

**Crown**

https://lucide.dev/icons/crown

### Upcoming Features

**Sparkles**

https://lucide.dev/icons/sparkles

### Pro Features

**Search**

https://lucide.dev/icons/search

**Images**

https://lucide.dev/icons/images

**Users Round**

https://lucide.dev/icons/users-round

### Account Action

**Log Out**

https://lucide.dev/icons/log-out

---

# 30. Icon Specifications

Default:

```text
Stroke width: 2 px
Line cap: Round
Line join: Round
```

Recommended:

```text
Header icons: 22–24 px
Card icons: 22–26 px
Feature icons: 22–26 px
Action icons: 20–22 px
```

Do not mix Material, Font Awesome and Lucide icon styles.

---

# 31. Interaction States

Interactive elements should support:

```text
Default
Pressed
Selected
Disabled
Loading
```

### Feature Preview

Default:

- Soft orange Preview pill

Pressed:

- Slightly darker orange surface
- Tiny opacity/scale response

### Sign Out

Pressed:

- Slightly darker warm-red/orange surface

### Account Card

Pressed:

- Very subtle neutral background change

---

# 32. Responsive Behavior

The Profile screen must work on:

- Compact iPhones
- Standard iPhones
- Pro Max devices
- Android phones
- Larger accessibility font sizes

For narrow screens:

- Cards remain full width.
- Feature descriptions wrap.
- Preview action can remain aligned to the top-right.
- If space becomes insufficient, the Preview action can move below the description.
- No text should clip.

---

# 33. Accessibility

Every interactive element needs a semantic label.

Examples:

```text
Back
Open settings
Open account details
View membership
Preview Unlimited On-Device AI Search
Preview Lossless RAW & HDR Export
Preview Semantic Face & Event Clustering
Sign out
```

Do not rely on color alone.

Feature cards should remain understandable without their icons.

---

# 34. Flutter Widget Hierarchy

Recommended:

```text
ProfileScreen
│
├── SafeArea
│   └── CustomScrollView
│       ├── ProfileHeader
│       ├── AccountIdentityCard
│       ├── MembershipCard
│       ├── UpcomingFeaturesHeader
│       ├── ProFeatureCard
│       ├── ProFeatureCard
│       ├── ProFeatureCard
│       └── SignOutButton
│
└── SignOutConfirmationSheet
```

Reusable widgets:

```text
ProfileHeader
AccountIdentityCard
MembershipCard
PlanBadge
UpcomingFeaturesHeader
ProFeatureCard
FeaturePreviewButton
DestructiveActionButton
```

---

# 35. Flutter Clean Architecture

Recommended feature structure:

```text
features/
└── profile/
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
GetProfile
GetMembership
GetUpcomingFeatures
OpenFeaturePreview
SignOut
```

---

# 36. BLoC State

Recommended:

```text
ProfileInitial
ProfileLoading
ProfileLoaded
ProfileFeaturePreviewLoading
ProfileFeaturePreviewLoaded
ProfileSigningOut
ProfileSignedOut
ProfileFailure
```

The profile should not contain hard-coded account information in production.

Use the authenticated account/session to populate:

```text
Name
Email
Avatar
Membership
Available features
```

---

# 37. Membership Model

Recommended domain structure:

```text
Membership
├── planName
├── planType
├── description
├── activeFeatures
├── upcomingFeatures
└── expiresAt
```

For example:

```text
planName: Free Plan
planType: free
```

This makes the UI scalable when Pro plans are introduced.

---

# 38. Feature Model

Recommended:

```text
UpcomingFeature
├── id
├── title
├── description
├── icon
├── accent
├── status
└── isPreviewable
```

Example status:

```text
comingSoon
preview
available
```

This prevents the UI from being tightly coupled to a fixed list of features.

---

# 39. Product Trust Rules

The Profile screen contains product promises, especially around privacy and future capabilities.

Only show claims that are technically true.

For example:

> “Zero photo uploads”

should only be displayed if the corresponding feature actually guarantees that photos are never uploaded.

Likewise:

> “On-device”

should only be used for processing that genuinely occurs on-device.

Avoid marketing language that overstates the current implementation.

---

# 40. Design Rules

## Do

- Keep the screen predominantly white.
- Use dark navy typography.
- Use orange as the main accent.
- Use blue/green/pastel accents only for feature categorization.
- Keep cards lightweight.
- Make the current plan immediately understandable.
- Clearly label upcoming features.
- Make previews feel optional rather than purchasable.
- Keep Sign Out visually separate.
- Use the same geometry and typography as the Library, AI Search and Settings screens.

## Don't

- Use purple as the primary brand color.
- Use saturated green as the primary brand color.
- Make the screen look like a pricing page.
- Add unnecessary subscription/payment controls before billing exists.
- Use huge illustrations.
- Use heavy shadows.
- Use excessive gradients.
- Make every feature card visually identical in accent color.
- Claim privacy or on-device behavior that the implementation does not guarantee.

---

# 41. Final Design Direction

The Profile screen is the account-focused counterpart to the Library and AI Search screens.

The complete product language is:

```text
LIBRARY
White + Navy + Orange AI
        ↓
AI SEARCH
White + Navy + Orange AI
        ↓
SETTINGS
White + Navy + Orange controls
        ↓
PROFILE
White + Navy + Orange account/membership
```

Shared visual system:

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
iOS-inspired interactions
```

The Profile screen should feel premium without looking like a subscription sales page. Its primary job is to make the user's identity, current plan and future capabilities immediately understandable.
