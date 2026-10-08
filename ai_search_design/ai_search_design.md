# AI Gallery Search — Design Specification

## 1. Overview

The **AI Search** screen is a conversational gallery assistant. Users can ask natural-language questions about photos, people, places, screenshots, bills, receipts, payments and other personal records.

Example queries:

- “Show me all the pictures of hilly areas.”
- “What is the last date to pay the internet bill?”
- “How much salary have I paid to Hassan last year based on payment receipts?”
- “How much did I spend on subscription last month?”

AI responses may contain **text, images, document evidence, or a combination of all three**.

The visual language must match the Library home screen:

- White-first
- Minimal and modern
- iOS-inspired
- Spacious
- Rounded surfaces
- Subtle shadows
- Dark navy typography
- **Orange as the primary AI accent**
- Pastel secondary colors
- No dominant purple or green branding

---

## 2. Design Philosophy

The screen should feel like a **personal assistant for the user's gallery**, not a generic chatbot.

```text
AI Search
   ↓
Suggested Searches
   ↓
Recent Searches
   ↓
Example Queries
   ↓
Conversation
   ↓
Evidence / Results
   ↓
Persistent AI Input
```

When the user starts searching, the conversation becomes the primary content.

---

## 3. Header

Content:

- Circular back button
- `AI Search`
- `Find photos, people, places and more`

### Back Button

- 48–56 px circular light-gray surface
- Chevron-left icon
- Minimal/no visible border

### Typography

| Element | Size | Weight | Color |
|---|---:|---:|---|
| AI Search | 30–32 px | 700 | `#111827` |
| Subtitle | 16–17 px | 400 | `#6B7280` |

---

## 4. Color System

### Base

| Token | Hex |
|---|---|
| Background | `#FFFFFF` |
| Primary text | `#111827` |
| Secondary text | `#6B7280` |
| Muted text | `#94A3B8` |
| Search surface | `#F3F4F6` |
| Border | `#E5E7EB` |

### Primary AI Accent

| Token | Hex |
|---|---|
| AI Orange | `#FF7A00` |
| Soft AI Orange | `#FFF1E5` |
| AI Orange Dark | `#E96800` |

Orange is used for:

- Sparkles / AI identity
- AI response indicators
- Highlighted semantic terms
- Clear action
- Send button
- AI input icon

### Secondary Pastels

| Purpose | Hex |
|---|---|
| Soft Blue | `#EEF6FF` |
| Soft Red | `#FFF0F1` |
| Soft Green | `#EEF9F3` |
| Soft Purple | `#F3F0FF` |
| Soft Yellow | `#FFF8E8` |

Secondary colors should identify categories, **not become the brand color**.

---

## 5. Suggested Searches

Section:

**Suggested Searches** — `See all >`

Use a two-column grid.

Recommended suggestions:

1. Show photos of dogs
2. Find photos from my birthday
3. Show beach photos
4. Find photos with cars
5. Hilly areas
6. Show payment receipts

Each card contains:

- Contextual icon
- Short query
- Chevron-right
- Very light pastel background
- Rounded corners

Recommended height: `72–82 px`

Recommended radius: `20–24 px`

These are shortcuts, not major feature cards.

---

## 6. Suggested Search Color Mapping

| Search type | Accent |
|---|---|
| Photos | Soft blue |
| Birthday | Soft red/pink |
| Beach | Soft orange |
| Cars | Soft green |
| Places | Soft orange |
| Receipts | Soft blue |

---

## 7. Recent Searches

Section:

**Recent Searches** — `Clear`

Use a clock icon.

Example chips:

- dogs
- beach sunset
- internet bill
- Hassan salary

Chip specifications:

- Height: `48–52 px`
- Radius: `24–26 px`
- Light gray background
- Search icon
- Compact horizontal padding

Use horizontal scrolling when required.

---

## 8. Example Queries

Section:

**Example Queries**

These cards demonstrate the actual intelligence of the product.

### Visual Search

`Show me all the pictures of hilly areas`

### Document Reasoning

`What is the last date to pay the internet bill?`

### Financial Analysis

`How much did I spend on subscription last month?`

Use the AI orange accent only on the important semantic phrase rather than coloring the whole sentence.

---

## 9. Conversation Layout

After a query is submitted:

```text
                         ┌──────────────────────┐
                         │ User question        │
                         └──────────────────────┘
                                             User
AI
┌──────────────────────────────────────────────┐
│ AI response                                  │
│                                              │
│ [images / documents / structured answer]    │
└──────────────────────────────────────────────┘
```

### User Message

- Right aligned
- Soft warm-orange background
- Dark navy text
- Rounded bubble
- User avatar beside the bubble

Do not use a saturated orange bubble.

### AI Response

- Left aligned
- Small orange Sparkles identity icon
- White/very-light card
- Dark navy text
- Evidence or media directly below the answer

---

## 10. Photo Search Response

Example:

> Here are **42 photos** of hilly areas from your gallery.

Then:

```text
[ photo ] [ photo ] [ photo ] [ +38 ]
```

Specifications:

- Four visible thumbnails
- 14–16 px radius
- Small consistent gaps
- Last thumbnail may use a `+38` overlay
- `See all >` opens the full result collection

The result should feel like a gallery preview rather than a generic chatbot attachment.

---

## 11. Document / Receipt Response

For bills, receipts and screenshots, return a structured evidence card.

Example:

```text
Based on the payment receipt screenshots
in your gallery, the last date to pay
your internet bill is:

┌─────────────────────────────────────────┐
│ Calendar   25 September 2025        img │
│            PTCL Broadband                │
└─────────────────────────────────────────┘
```

The card contains:

- Contextual document icon
- Extracted answer
- Service/provider name
- Receipt thumbnail
- Expand/open action

The answer is visually dominant.

---

## 12. Evidence & Trust

Whenever the AI derives information from personal images, make the source clear.

Examples:

- `Based on the payment receipt screenshots in your gallery`
- `Found in your gallery`
- `Based on 3 receipts`
- `See source`

This is especially important for:

- Money
- Bills
- Salaries
- Payments
- Dates
- Personal records

Users should be able to inspect the underlying evidence.

---

## 13. Supported Result Types

### Text only

```text
You spent Rs 8,450 on subscriptions last month.
```

### Images only

```text
Here are 42 photos from hilly areas.

[image] [image] [image] [+38]
```

### Text + Images

```text
I found 42 photos from hilly areas.

[image] [image] [image] [+38]
```

### Text + Document

```text
Your internet bill was due on 25 September 2025.

[receipt preview]
```

### Aggregated answer

For financial questions, prefer structured data:

```text
You paid Hassan Rs 185,000 in salary last year.

Jan       Rs 15,000
Feb       Rs 15,000
Mar       Rs 20,000
...
Total     Rs 185,000

See payment receipts →
```

---

## 14. Persistent AI Input

The input stays fixed at the bottom.

```text
┌────────────────────────────────────────────────┐
│ ✦ Search photos with AI...       🎙       ↑   │
└────────────────────────────────────────────────┘
```

Placeholder:

`Search photos with AI (e.g. 'dogs', 'bills', 'Hassan')...`

Elements:

- Sparkles
- Text field
- Microphone
- Circular orange send button

Input specifications:

- White surface
- Very subtle border/shadow
- 28–32 px radius
- Send button: `#FF7A00`
- Send icon: white

---

## 15. Input States

### Empty

Show placeholder.

### Typing

Show typed query and active send action.

### Listening

Show active microphone state.

### Processing

Show a lightweight loading indicator.

### Response

Automatically scroll to the latest response.

---

## 16. Conversation Behavior

Support follow-up questions while retaining context.

Example:

```text
User:
Show me all the pictures of hilly areas.

AI:
Here are 42 photos...

User:
Only show the ones from 2025.

AI:
I found 13 photos from 2025.
```

The conversation should behave as a continuous gallery search session.

---

## 17. Natural Language Search

### Photos

```text
Show me pictures of mountains.
Find photos from my birthday.
Show me photos with Hassan.
Find pictures from Islamabad.
Show me beach photos.
```

### Documents

```text
Show my internet bills.
Find payment receipts.
Show electricity bills from last year.
```

### Financial

```text
How much did I spend on subscriptions last month?
How much salary did I pay Hassan last year?
What was my highest monthly expense?
```

### Time-based

```text
What was the last internet bill?
When did I last pay PTCL?
Show photos from two years ago.
```

---

## 18. Component Hierarchy

```text
AISearchScreen
│
├── SafeArea
│   └── CustomScrollView
│       ├── AISearchHeader
│       ├── SuggestedSearchesSection
│       │   └── SuggestedSearchGrid
│       ├── RecentSearchesSection
│       │   └── RecentSearchChips
│       ├── ExampleQueriesSection
│       │   └── ExampleQueryCards
│       └── ConversationList
│           ├── UserMessageBubble
│           ├── AITextResponse
│           ├── AIPhotoResult
│           └── AIDocumentResult
│
└── BottomAIInput
    ├── Sparkles
    ├── TextField
    ├── Microphone
    └── SendButton
```

---

## 19. Flutter Architecture

Recommended feature-first Clean Architecture structure:

```text
features/
└── ai_search/
    ├── data/
    │   ├── datasources/
    │   ├── models/
    │   └── repositories/
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    └── presentation/
        ├── bloc/
        ├── pages/
        └── widgets/
```

Reusable widgets:

```text
AISearchHeader
SuggestedSearchCard
RecentSearchChip
ExampleQueryCard
UserQueryBubble
AIResponseCard
PhotoResultCard
DocumentResultCard
AIInputBar
```

---

## 20. State Management

Recommended states:

```text
AISearchInitial
AISearchLoading
AISearchSuccess
AISearchFailure
AISearchListening
```

A conversation message can contain multiple result types:

```text
SearchMessage
├── role
├── text
├── images
├── documents
├── metadata
└── timestamp
```

This allows one AI response to contain text plus images or evidence.

---

## 21. Typography

Use the same font family as the Library screen.

Recommended:

**Inter** or **SF Pro Display / SF Pro Text**

| Element | Size | Weight |
|---|---:|---:|
| Screen title | 30–32 px | 700 |
| Subtitle | 16–17 px | 400 |
| Section heading | 23–26 px | 700 |
| Search/query text | 15–17 px | 500 |
| AI response | 16–17 px | 400–500 |
| Important result | 20–22 px | 700 |
| Metadata | 13–14 px | 400–500 |
| Input placeholder | 15–16 px | 400 |

---

## 22. Spacing

Use an 8 px base system.

```text
4 px   — micro
8 px   — icon/text gap
12 px  — chip spacing
16 px  — normal spacing
20 px  — card padding
24 px  — section spacing
32 px  — major separation
40 px  — screen-level separation
```

Do not compress the screen simply to show more content.

---

## 23. Icon System

Use **Lucide Icons** consistently across the product.

Official library:

https://lucide.dev/

### Header

**Chevron Left**  
Back navigation  
https://lucide.dev/icons/chevron-left

### AI

**Sparkles**  
AI identity, AI response and AI input  
https://lucide.dev/icons/sparkles

### Suggested Searches

**Image** — photo search  
https://lucide.dev/icons/image

**Cake** — birthday  
https://lucide.dev/icons/cake

**Sun** — beach/outdoor  
https://lucide.dev/icons/sun

**Car** — vehicle search  
https://lucide.dev/icons/car

**Map Pin** — location/hilly areas  
https://lucide.dev/icons/map-pin

**Receipt** — payment receipts  
https://lucide.dev/icons/receipt

### Recent Searches

**Clock** — recent searches  
https://lucide.dev/icons/clock

**Search** — search query indicator  
https://lucide.dev/icons/search

### Example Queries

**Message Circle** — conversational examples  
https://lucide.dev/icons/message-circle

**Image** — visual search  
https://lucide.dev/icons/image

**Receipt** — bill/receipt query  
https://lucide.dev/icons/receipt

**Chart No Axes Combined** — spending analysis  
https://lucide.dev/icons/chart-no-axes-combined

### Conversation / Results

**Chevron Right** — open result / See all  
https://lucide.dev/icons/chevron-right

**Calendar Days** — due date  
https://lucide.dev/icons/calendar-days

**Maximize 2** — expand receipt/photo  
https://lucide.dev/icons/maximize-2

### AI Input

**Mic** — voice search  
https://lucide.dev/icons/mic

**Arrow Up** — send  
https://lucide.dev/icons/arrow-up

---

## 24. Icon Specifications

```text
Stroke width: 2 px
Line cap: Round
Line join: Round
```

Recommended sizes:

```text
Header: 22–24 px
Section: 22–24 px
Card: 20–22 px
AI icon: 22–26 px
Search: 22–24 px
Send: 22–24 px
```

Do not mix filled Material icons with Lucide outline icons.

---

## 25. Accessibility

Every interactive icon requires an accessible label:

```text
Back
See all suggested searches
Clear recent searches
Open photo collection
Open receipt
Start voice search
Send message
```

Never rely on color alone for state.

Maintain sufficient contrast for text and icons.

---

## 26. Loading

Use subtle skeleton states instead of a large spinner.

Photo result:

```text
[ skeleton ] [ skeleton ] [ skeleton ] [ skeleton ]
```

Text response:

```text
████████████████
██████████
██████████████
```

Keep animations lightweight.

---

## 27. Empty State

If there are no previous searches:

```text
Start searching your gallery

Ask anything about your photos,
screenshots and documents.
```

Show a few useful example prompts underneath.

---

## 28. Error State

Example:

```text
I couldn't find enough information in your gallery.

Try:
• Using a different phrase
• Adding a date or person
• Checking your screenshots
```

Provide a retry action.

---

## 29. Privacy / Source Context

Since the assistant searches personal gallery content, make the source explicit.

Useful labels:

- `From your gallery`
- `Found in your photos`
- `Based on your screenshots`
- `Based on 3 receipts`

Do not imply external information when the answer was extracted from the user's gallery.

---

## 30. Design Rules

### Do

- Keep the interface predominantly white.
- Use orange as the AI identity.
- Use pastel colors only for secondary categories.
- Keep user messages warm and subtle.
- Make AI answers evidence-driven.
- Show source images for extracted information.
- Make photo results visually rich.
- Keep the input permanently accessible.
- Maintain the Library screen's typography and spacing.
- Use structured cards for financial/document answers.

### Don't

- Use purple as the primary AI color.
- Use green as the primary AI color.
- Fill large areas with orange.
- Turn every response into a giant card.
- Overuse icons.
- Hide evidence behind multiple navigation layers.
- Make the screen look like a generic ChatGPT clone.
- Use heavy borders.
- Use excessive gradients.
- Overcrowd the conversation.

---

## 31. Final Product Direction

The experience should communicate:

> **Ask your gallery anything.**

The Library screen introduces the Gallery Assistant; this screen turns it into a conversational interface capable of understanding:

```text
Photos
People
Places
Dates
Documents
Bills
Receipts
Payments
Subscriptions
Personal records
```

Final visual language:

```text
White background
      +
Dark navy typography
      +
Orange AI identity
      +
Soft pastel categories
      +
Rounded cards
      +
Subtle shadows
      +
Photography / evidence
      +
Conversational interaction
```

The objective is not to build a generic chatbot. It is to make the user's **entire gallery queryable through natural language**, while making every important answer understandable and traceable to the user's own photos and screenshots.
