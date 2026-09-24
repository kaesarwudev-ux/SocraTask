# SocraTask — Visual / Layout Design (`design.md`)

> Companion to `prompt.md`. This file defines LOOK, FEEL, MOTION. `prompt.md` defines behavior. Cross-reference, don't repeat.

## 1. Identity: Material 3, clean and fast

SocraTask uses Flutter Material 3 with the SocraTask seed color — no custom
shaders, no third-party glass kits. Depth comes from tonal surfaces +
elevation, not blur. Every component is a stock M3 widget themed once in
`ThemeData`, so all platforms render identically with zero GPU-specific code.

Interaction basics: press = M3 ripple + 100ms scale to 0.97 on icon buttons;
hover = pointer cursor + state-layer tint (desktop); focus = 2px accent
outline; disabled = 40% opacity; loading = linear/circular progress;
reduced-motion = instant state changes, no animation.

## 2. Tokens (exact values — use these, no ad-hoc)

Typography (system stack: Inter/`Noto Sans` on Fedora, SF on macOS, Segoe on Win, Roboto on Android; mono: JetBrains Mono):
- Display 32/40, H1 24/32, H2 20/28, H3 16/24, Body 14/20, Caption 12/16, Tiny 11/14. Letter-spacing: headings -0.01em, body 0, caps +0.06em. Weights: regular 400, medium 500, semibold 600, bold 700 (never faux-bold).

Spacing (4pt base): 4, 8, 12, 16, 20, 24, 32, 48. Micro: icon↔label gap 8; control inner padding: btn `12h×16w` (small `8×12`), chip `6×10`, card 16–20, section gap 24, page margin desktop 32 / tablet 24 / phone 16; gutters: grid 16, columns gap 16; toolbar items gap 8, groups gap 16.

Shape: chips/buttons 12–14, cards 18–20, panels/toolbars 20–24, sheets/dialogs 24–28, FAB 16. Border 1px (`outlineVariant` 60%), focused 2px accent.

Elevation (light / dark same offsets): L1 `0 1 2 rgba(0,0,0,.08)`, L2 `0 4 12 .10`, L3 `0 8 24 .14`, L4 `0 16 40 .18`.

Color: light bg `#F6F7F9`, surface `#FFFFFF`, dark bg `#0E1116`, surface `#171B22`; accent `#4F7CFF` (dark `#7AA2FF`); success `#2FA36B`, warn `#D9932A`, danger `#E5484D`; all text ≥4.5:1, non-color cues (icon + label) required. Colorblind-safe palette (Okabe-Ito derived).

Density: comfortable (default) / compact (row h 40→32, for thousands of tasks).

Breakpoints: phone <600 (1-col, bottom nav/sheet), tablet 600–1024 (2-col, collapsible rail 72↔280), desktop >1024 (3-col, rail 280–320 + detail), ultrawide >1600 (max-content 1200 centered + side minimap). Touch targets ≥44×44 (compact ≥40), stylus hover preview.

Motion: instant 100 (toggle), quick 150 (hover), standard 200 (open/close), expressive 350 (sheet/modal); easing `cubic-bezier(.2,.8,.2,1)`; page transitions 200 fade+slide 12px.

## 3. Components (stock Material 3 — use directly, themed once)

Buttons: `FilledButton` (primary), `TextButton`/`OutlinedButton` (secondary),
`IconButton` (toolbar), `FloatingActionButton` (page primary action).
Cards/panels: `Card` (padding 16, 20 large). Inputs: `TextField`/`TextFormField`,
`Checkbox`/`CheckboxListTile`, `Switch`, `Slider`, `SegmentedButton`.
Nav: `NavigationBar` (phone), `NavigationRail` (tablet/desktop),
`AppBar`/`TabBar`, `Drawer`/`NavigationDrawer` (settings).
Overlays: `AlertDialog` (480), `Dialog` (720/960), `ModalBottomSheet`,
`MenuAnchor`, `Tooltip`, `SnackBar` (undo), `BottomSheet`.
Every clickable shows `SystemMouseCursors.click` on hover (desktop);
disabled shows basic cursor at 40% opacity. No custom component library —
if M3 lacks it, compose from M3 primitives.

Icons: Material Symbols 20px (dense 18, touch 22), 2px optical padding,
consistent bounding box; animated only for state (play→pause morph 150ms).

## 4. Layout Rules

Fitts: primary actions ≥48px, corners for destructive need confirm. Hick: ≤7 items per toolbar, overflow → `MenuAnchor`. Proximity: related controls grouped in `Card` with 12 inner gap; sections separated 24. Hierarchy: H1 per page only, cards carry H2. Baseline: 4px grid, vertical rhythm 8.

## 5. Page-by-Page Specs (tell me what to change per page)

### 5.1 Dashboard
Desktop: left rail 280 (nav + focus status) | center 3-col widget grid (card 20p, gap 16, Upcoming spans 2) | right AI box 320. Tablet: rail collapses 72 icons, grid 2-col. Phone: 1-col stack + bottom nav (Home/Tasks/Calendar/Notes/More), widgets collapsible. Widget header: drag-handle (left, 6-dot) + collapse + hide. Empty widgets show CTA, never blank.

### 5.2 Calendar
Desktop: mini-cal 280 left + week grid (time gutter 56w, 48px/hour, now-line accent 2px) + inspector 320 right. Tablet: 3-day + bottom sheet inspector. Phone: agenda list first, day dots header, FAB “+ Event”. Event chip: 4px color bar + title 13 medium + time 12. Drag: ghost chip + snap 15m; resize: bottom handle 8px. Conflict: red dashed overlap + “Find free slot” button.

### 5.3 Tasks
Desktop: list (row h 48, checkbox 22, P1 red dot + label) + detail pane 380. Tablet: list + sheet. Phone: list + full-screen detail. Kanban: columns 280w, cards 12p. Quick-add bar top (text field + date chips). Bulk bar appears on multi-select.

### 5.4 Notes + Whiteboard
Top: toolbar (pen/shape/text/ink-toggle/zoom %) 64h. Left: block palette 240 (collapsible). Center: infinite canvas (dot grid 24px, rulers 24h). Right: properties 280 (stroke/fill/font when selected) + backlinks tab. Bottom-right: minimap 160×100 + zoom +/-. Phone: toolbar bottom 56, palette → sheet, minimap hidden default. Selection: 1.5px accent outline + 8 handles 10px. Ink: 2–4px pressure, beautify toggle in toolbar.

### 5.5 Documents
Centered page (A4 794×1123 @96dpi scaled, margins visual 72px guides), page gap 24, shadow L2. Top: ribbon-tabs (Home/Insert/Layout/Review) 48h + formatting bar 48h. Left: navigation pane 260 (headings/pages). Right: comments/track 300 (toggle). Phone: single toolbar + overflow, pages stack full-width.

### 5.6 Flashcards
Deck grid (card 180×120, due badge). Review: centered card 640 max, Q 20 semibold, flip (tap/Space, 200ms Y-rotate with reduced-motion → fade), grade buttons Again/Hard/Good/Easy (44h, color + label). Stats: heatmap 7×26 squares 12px.

### 5.7 Habits / Focus / Timers / Stopwatch / Alarms / Blocking
Habits: rows with 7-dot week (16px circles), consistency bar. Focus: big timer 48 tabular-nums + profile chips + Start (64h primary). Timers: grid of cards (name 14, time 32 mono, progress ring 4px). Stopwatch: 56 mono + lap table (lap/best highlighted). Alarms: list rows (time 24, toggle right) + edit sheet. Blocking: profile cards + domain list (mono 13) + emergency button (danger, requires type-to-confirm).

### 5.8 AI / Voice / Search / Templates / Automations / Notifications / Analytics / Settings / Account
AI: right-side panel 360 (desktop) / sheet (mobile); mode switcher segmented (Fast/General/Deep/Auto) + “ran locally” badge + source chips (click → opens object). Voice: waveform 64h + live transcript + “→Note/Task/Deck” buttons. Search: top palette (`Ctrl+K`, 680w centered, filters as chips, results grouped). Templates: gallery grid 200 cards + preview. Automations: trigger→condition→action flow (nodes 220w, edges 2px). Notifications: center 400 grouped by day, inline actions. Analytics: 3 stat cards + line/bar (non-color + pattern). Settings: left nav 240 + form rows 56h with inline help + Reset per section. Account: status card + sync toggle + backup targets.

Responsive + a11y per page: keyboard (`/` search, `c` new, arrows navigate, `?` shortcuts sheet), screen-reader landmarks (`nav/main/complementary`), focus-visible 2px, 200% text scaling without breakage (cards wrap, no fixed heights except toolbar).
