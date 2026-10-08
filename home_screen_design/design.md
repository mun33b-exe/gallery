# Gallery Library — Design Specification

## 1. Overview

This document defines the UI design for the **Your Library** screen of the personal gallery assistant app.

The design direction is:

- Minimal and modern
- White-first interface
- iOS-inspired
- Spacious layout
- Soft rounded surfaces
- Subtle shadows rather than heavy borders
- Large, confident typography
- Small pastel accent colors used only to distinguish actions/categories
- Photography remains the visual focus
- AI assistant is the primary interaction on the screen

The screen should feel closer to a polished consumer product such as Google Photos, Apple Photos, or a modern AI productivity app rather than a dashboard full of cards.

---

## 2. Screen Structure

### A. System / Status Area

- Standard iOS status bar.
- White background.
- Dark system icons.
- Content starts below the safe area.

### B. Header

Content:

- Small greeting: `Good morning,`
- Main heading: `Your Library`
- Circular profile button on the right.
- Optional small green online/status indicator.

Typography:

- Greeting: 17–18 px, medium, muted gray.
- Main heading: 42–48 px, bold/extra-bold.
- Main heading color: `#111827`.

Spacing:

- 24 px horizontal page padding.
- Approximately 8 px between greeting and heading.
- Generous bottom spacing before the assistant card.

---

## 3. AI Gallery Assistant

This is the most important card on the screen.

### Card

- White background.
- Very subtle border/shadow.
- 24–28 px corner radius.
- Internal padding: 20–24 px.
- No large decorative illustration that competes with the content.

### Header

Icon:

- `Sparkles`
- Small circular/pastel container.
- Accent: warm orange.

Title:

`Your personal Gallery Assistant`

Subtitle:

`Find photos, people, places and more using simple search.`

The title should be visually dominant; the subtitle should remain secondary.

### Search

Large search field:

`Search Photos`

Elements:

- Search icon on the left.
- Placeholder text.
- Filter/settings button on the right.
- Very light gray surface: approximately `#F3F4F6`.
- 18–22 px corner radius.
- Height approximately 56–60 px.

### Smart Suggestions

Below the search field, provide lightweight shortcut cards.

Recommended categories:

1. People
2. Places
3. Favorites
4. Recently added

Each shortcut:

- Small colored circular icon.
- Category name.
- Right chevron.
- Very light pastel background.
- Rounded pill/card shape.
- Avoid strong borders.

Recommended accent mapping:

| Category | Accent |
|---|---|
| People | Green |
| Places | Orange |
| Favorites | Red/Pink |
| Recently added | Purple |

---

## 4. Suggestions / Memories

Place this section **directly below the AI Assistant**.

Section header:

- `Suggestions`
- `See all` + chevron on the right.

Use a horizontal scrolling collection of visual memory cards.

Example cards:

### Best of September
- Mountain/travel imagery
- `42 photos`

### Selfies
- Group/selfie imagery
- `128 photos`

### Two years ago
- A meaningful location or event
- `96 photos`

### Videos
- Travel/video imagery
- `32 videos`

Design:

- Approximately 210–230 px wide per card on a typical mobile layout.
- 250–270 px height.
- 20–24 px corner radius.
- Full-bleed photography.
- Bottom gradient overlay for readable text.
- White title.
- Small metadata.
- Circular arrow button in the bottom-right.

The cards should visually communicate **memories**, not look like generic feature cards.

---

## 5. Recent

Section header:

- `Recent`
- `See all` + chevron.

Use an asymmetric masonry-like gallery layout.

Recommended composition:

- Large landscape photo.
- Smaller portrait/square photo.
- Document preview.
- Chat/message preview.
- Group/family photo.

Keep image corners consistently rounded.

Avoid putting excessive labels over every image. Use small contextual icons only when needed.

---

## 6. Bottom Navigation

Use a floating/pill-style navigation system.

Primary navigation:

- `Library` — selected
- `Explore`

Secondary floating action:

- Search

Selected Library:

- Dark navy/black pill.
- White icon and text.

Unselected Explore:

- White/transparent surface.
- Dark gray icon/text.

Search:

- Separate circular floating button.
- White surface.
- Subtle border/shadow.

---

# 7. Color System

### Base

| Token | Hex |
|---|---|
| Background | `#FFFFFF` |
| Primary text | `#111827` |
| Secondary text | `#6B7280` |
| Tertiary text | `#9CA3AF` |
| Search surface | `#F3F4F6` |
| Divider | `#E5E7EB` |

### Accent Colors

| Purpose | Hex |
|---|---|
| Green | `#22A06B` |
| Soft green | `#EAF8F0` |
| Orange | `#F59E0B` |
| Soft orange | `#FFF4E5` |
| Pink | `#FEECEF` |
| Purple | `#F1EDFF` |
| Blue | `#EEF5FF` |

Use accents sparingly. The interface should remain predominantly white.

---

# 8. Typography

Recommended primary font:

**Inter** or **SF Pro Display / SF Pro Text** on Apple platforms.

Suggested hierarchy:

| Element | Size | Weight |
|---|---:|---|
| Greeting | 17–18 px | 500 |
| Main heading | 44–48 px | 700–800 |
| Section heading | 28–32 px | 700 |
| Assistant title | 20–22 px | 650–700 |
| Assistant subtitle | 15–16 px | 400–500 |
| Search placeholder | 16–17 px | 400 |
| Suggestion title | 17–19 px | 600 |
| Metadata | 13–14 px | 400–500 |
| Navigation label | 16–17 px | 600 |

Do not use too many font weights.

---

# 9. Icon System

Use **Lucide Icons** consistently throughout the application.

Lucide provides lightweight SVG icons with consistent stroke styling and customizable size/color/stroke width.

Official icon library:

https://lucide.dev/

## Icons used / mapped to this screen

### Header

**User**
- Purpose: Profile/account button
- URL: https://lucide.dev/icons/user

### AI Assistant

**Sparkles**
- Purpose: AI assistant indicator
- URL: https://lucide.dev/icons/sparkles

**Search**
- Purpose: Search photos
- URL: https://lucide.dev/icons/search

**Sliders Horizontal**
- Purpose: Search filters
- URL: https://lucide.dev/icons/sliders-horizontal

### Smart Search Suggestions

**Users Round**
- Purpose: People
- URL: https://lucide.dev/icons/users-round

**Map Pin**
- Purpose: Places
- URL: https://lucide.dev/icons/map-pin

**Heart**
- Purpose: Favorites
- URL: https://lucide.dev/icons/heart

**Clock**
- Purpose: Recently added / time-based memories
- URL: https://lucide.dev/icons/clock

### Suggestion / Memory Cards

**Arrow Right**
- Purpose: Open a suggestion/memory
- URL: https://lucide.dev/icons/arrow-right

### Recent Gallery

**Image**
- Purpose: Photo/image media indicator
- URL: https://lucide.dev/icons/image

**Coffee**
- Purpose: Context indicator for food/cafe imagery
- URL: https://lucide.dev/icons/coffee

**File Text**
- Purpose: Document preview indicator
- URL: https://lucide.dev/icons/file-text

**Message Circle**
- Purpose: Chat/message preview indicator
- URL: https://lucide.dev/icons/message-circle

**Users**
- Purpose: Group/family photo indicator
- URL: https://lucide.dev/icons/users

### Navigation

**Book Open**
- Purpose: Library tab
- URL: https://lucide.dev/icons/book-open

**Compass**
- Purpose: Explore tab
- URL: https://lucide.dev/icons/compass

**Search**
- Purpose: Floating search action
- URL: https://lucide.dev/icons/search

### Navigation / General

**Chevron Right**
- Purpose: Small directional affordance
- URL: https://lucide.dev/icons/chevron-right

---

# 10. Icon Specifications

Default:

- Stroke width: `2px`
- Stroke linecap: round
- Stroke linejoin: round
- Standard size: 20–24 px
- Navigation icons: 22–24 px
- Large contextual icons: 22–28 px

Do not mix filled Material icons with Lucide outline icons.

The icon language should remain consistent across the entire app.

---

# 11. Component Behavior

## AI Search

The search field should support natural-language queries such as:

- `Photos from September`
- `My selfies`
- `Photos with Ali`
- `Pictures from Islamabad`
- `Documents from last month`
- `Videos from my trip`

The shortcut categories are convenience entry points, not replacements for search.

## Suggestions

Suggestions should be dynamic and generated from available gallery data.

Potential suggestion types:

- Best of September
- This week
- Last weekend
- Selfies
- Family
- Trips
- Two years ago
- Recently added
- Favorite photos
- Screenshots
- Videos
- Documents

Avoid showing all categories simultaneously. Prioritize the most relevant memories.

---

# 12. Layout Principles

1. White space is intentional.
2. Do not make every section look like a separate boxed dashboard.
3. Use cards only where grouping improves usability.
4. Photography should dominate visual sections.
5. AI search should be the primary action.
6. Suggestions should feel personal and dynamic.
7. Use horizontal scrolling for memory collections.
8. Use large typography for hierarchy instead of excessive decoration.
9. Keep shadows extremely subtle.
10. Avoid gradients unless they improve text readability over photography.

---

# 13. Responsive / Flutter Notes

Recommended Flutter structure:

```text
LibraryScreen
├── SafeArea
│   └── CustomScrollView
│       ├── LibraryHeader
│       ├── GalleryAssistantCard
│       │   ├── AssistantHeader
│       │   ├── GallerySearchField
│       │   └── SmartSearchShortcuts
│       ├── SuggestionsSection
│       │   └── HorizontalSuggestionList
│       └── RecentSection
│           └── GalleryMasonryGrid
└── FloatingBottomNavigation
```

Recommended implementation:

- `CustomScrollView`
- `SliverToBoxAdapter`
- `SliverPadding`
- `ListView.separated` for horizontal suggestions
- `GridView` / masonry layout for recent media
- Reusable card components
- Centralized theme tokens
- SVG icons through a consistent icon package or local SVG assets

---

# 14. Design Quality Rules

### Do

- Keep the interface calm and premium.
- Maintain consistent 20–28 px corner radii.
- Use one primary text color.
- Use soft pastel backgrounds for categories.
- Keep photography high quality.
- Make search immediately discoverable.
- Use concise copy.

### Don't

- Add unnecessary gradients.
- Use thick borders.
- Use too many colors.
- Put every feature inside a card.
- Use giant decorative illustrations.
- Mix icon families.
- Overload the home screen with statistics.
- Bring back the previous `10,000 items indexed` card unless it serves a clear product purpose.

---

# 15. Reference Design Direction

The final direction is intentionally closer to a modern consumer gallery product:

**White canvas → strong typography → AI search → personalized memories → recent media → simple navigation.**

The AI assistant is now the primary hero interaction, while the former indexed-item statistic card has been removed from the home screen.
