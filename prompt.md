# SocraTask — Product / Functionality / Architecture Prompt (`prompt.md`)

> Companion to `design.md`. This file defines WHAT SocraTask does, HOW it behaves, and HOW it is built. `design.md` defines what it LOOKS like. Do not duplicate visual token values here — reference `design.md`.

## 1. Vision & Principles

SocraTask is a local-first, cross-platform productivity ecosystem (Fedora KDE Plasma primary; Windows, macOS, Linux, Android, iOS, tablets, touch, high-DPI). It feels like one environment, not mini-apps: Tasks, Calendar, Notes+whiteboard, Documents (separate Word-class app), Flashcards, Habits, Focus/Blocking, Timers, Stopwatch, Alarms, AI, Voice, Search, Templates, Automations, Notifications, Analytics, Settings, Account, Integrations share one object graph.

Principles:
- Local-first: tasks/notes/calendar/docs/flashcards/search/timers work offline. Cloud sync, collab, backup, external AI are optional.
- No account required for core use. Account only unlocks sync/backup/share.
- Privacy: local inference default (Ollama), BYOK secrets in OS keystore, no secret logging, revocation.
- Cohesive, not bloated: every feature must justify itself via researched user pain (Reddit/app reviews/GitHub issues: e.g. Todoist recurring pain, Notion offline pain, Anki sync pain, Google Calendar timezone pain, Word bloat pain).
- Weak-AI-proof: every feature below states purpose, location, controls, behavior, states, offline, responsive, integrations, a11y, edge cases.

Assumed stack (locked): Flutter 3.47+ / Dart 3.13+, stock Material 3 widgets only (no custom shader kits), Drift/SQLite + FTS5, Ollama local inference, OS keystore for BYOK.

## 2. Unified Object & Relationship Model

Single SQLite DB, tables: `objects(id, type, title, body_ref, created_at, updated_at, deleted_at, version)`, `relations(from_id, to_id, kind)`, `attachments`, `history`. Kinds: `task↔event`, `event↔note`, `note↔deck`, `doc↔deck`, `habit↔event`, `timer↔task`, `focus↔block_profile`.

Rules:
- References, not copies: converting Note→Flashcards creates Deck with `source_refs`; edits to source flag deck as `stale` (banner + one-tap resync), never silent duplicate.
- Every destructive action reversible: soft-delete 30d trash + undo snackbar (8s) + history restore.
- Versioning: each object keeps revision list (who/when/diff); conflict resolution: last-writer-wins with 3-way merge UI for text, field-level merge for dates/tags.
- Offline: all writes local + `sync_queue`; on reconnect push/pull, show sync badge (clean/dirty/error).

## 3. Module Specs (each MUST implement all states: empty/loading/skeleton/success/failure/offline/permission-denied/invalid/retry/undo)

### 3.1 Dashboard
Purpose: glanceable day control. Location: default launch screen. Widgets: Upcoming events, Due tasks, Habits today, Active timer, Focus status, Due flashcards, Recent notes/docs, Stats streak, AI quick box, Quick-add.
Behavior: grid, movable/resizable/collapsible/hideable; layouts per form-factor (desktop 3-col, tablet 2-col, phone 1-col + bottom nav). Empty: illustration + “Add first task” CTA. Offline: cached snapshot + badge. Edge: 0 widgets → prompts to reset to defaults.

### 3.2 Calendar (Google-Calendar-class)
Views: day / week / work-week / month / year / agenda / timeline. Multi-calendars with colors, show/hide, ICS import/export/subscription URL.
Event fields: title, calendars, date/time + all-day, recurrence (RRULE daily/weekly/monthly/yearly + custom + exceptions: edit this/future/all), reminders (5m–1w, multi), timezone (per-event + display tz), location + link, participants, description (rich), attachments, categories/tags, availability (busy/free), templates, focus-time flag.
Interactions: drag-to-move, edge-resize, click-to-create (15m snap, Shift=exact), conflict banner (overlap detection + suggest next free slot), tasks/habits/deadlines overlay toggle.
States: offline editing fully allowed, queued sync; import failure shows row-level errors; invalid (end<start) blocks save with inline message.
Responsive: desktop side mini-calendar + 7-day; tablet 3-day + collapsible nav; phone agenda-first + day dots.
Integrations: Task due→event mirror, Habit→event, Focus session→auto “Do Not Disturb” event, AI “plan study around free time” writes events (always confirm screen).

### 3.3 Tasks (Todoist/Linear-class)
Fields: title, notes (rich), project, labels/tags, priority P1–P4, status (inbox/next/doing/waiting/done/cancelled), due + start dates, recurrence, reminders, subtasks (infinite, with progress bar), dependencies (blocked-by, blocks; cycle detection), estimates, time-tracked (link Timers/Focus), attachments, comments, checklists, templates, history, completion stats.
Views: inbox/today/upcoming/project/label/priority/kanban; sort/filter/save. Quick-add (`q` or `+`): parses “Buy milk tomorrow p2 #home”.
Behavior: swipe-complete on touch, `Ctrl/Cmd+Enter` completes, undo restores; overdue auto-rolls with “Reschedule” bulk bar; recurring completion creates next instance, keeps history.
Edge: dependency cycle → error + highlight chain; deleted project → tasks move to Inbox, banner explains.

### 3.4 Notes + Whiteboard (ONE object canvas, NOT text-editor-with-attachment)
Blocks + free canvas coexist: typed blocks (headings, bullets, numbered, checklist, quote, code + inline code, links, tables, callouts, images/files, embeds, tags, properties, backlinks) can be dragged onto canvas as cards; shapes/arrows connect them.
Canvas: infinite (virtualized tiling, only visible viewport renders), zoom 10–400% (pinch/`Ctrl+wheel`), pan (space-drag/two-finger), minimap, grid/dots/lines + rulers + snap + smart/alignment guides, select/multi-select (shift/lasso), group/ungroup, lock/hide, z-order, duplicate, rotate/resize, arrow-key nudge (1px, Shift=10px), touch + stylus.
Shapes: rect, rounded-rect, circle, ellipse, triangle, line, arrow (uni/bi), polygon, star, callout, flowchart (process/decision/doc/data), auto-beautify rough strokes (Ramer-Douglas-Peucker + shape fit; crooked line→straight, rough circle→circle; threshold slider; never touches handwriting text strokes until conversion).
Handwriting pipeline (algorithmic, NO generative AI required): ink strokes → idle `config.delayMs` (default 1200, 500–3000) → classify text vs drawing (stroke density/linearity) → OCR (on-device: Tesseract/MLKit, NOT cloud) → feature extract (slant, x-height, baseline variance, letter width, spacing, stroke structure) → nearest-neighbor match against bundled handwriting-style font DB (keep top-3) → render as editable text object preserving bold/italic/underline/strike/caps/lists/paragraphs/layout; original ink preserved underneath; Revert button + toggle Ink/Text; user can change font after (stays in handwriting family until manual override); object is selectable/draggable/resizable/rotatable/typable.
Comments, version history per note, templates, backlinks pane, minimap.
Offline: full. Large canvas: tile cache + thumbnail; 10k-object stress target 60fps pan on mid GPU, Lite fallback on weak.

### 3.5 Documents (SEPARATE Word-class app, not Notes mode)
Pages, paper sizes (A4/Letter/Legal/custom), portrait/landscape, margins, columns, headers/footers, page numbers, section/page breaks.
Styles/themes, font manager (system + bundled handwriting-compatible + fallback chain), paragraph (align, indent, tabs, line/paragraph spacing), lists (multi-level), tables (merge/split, header repeat), images (wrap: inline/square/tight/behind, alt text), shapes/charts/diagrams, links/bookmarks/cross-refs, footnotes/endnotes, citations/bibliography, TOC/captions, comments, track-changes (accept/reject), compare, spelling/grammar (local Hunspell + optional AI), find/replace (regex), navigation pane (headings/pages/results), accessibility checker, doc properties, export PDF/DOCX/HTML/MD/TXT + print with preview, version history, collab-ready architecture (OT-ready model, but local-first v1: share via export/sync).
States: huge docs virtualized (page windowing); corrupt file → recovery pane with last-good snapshot.

### 3.6 Flashcards (Anki-class, FSRS)
Sources: select in Notes/Docs/Calendar/Tasks/Whiteboard → “Make flashcards”; auto-extract (headings→Q, cloze `{{c1::}}` detection) always opens review-before-save screen.
Types: basic, cloze, reversed, multiple-choice, true/false, image-occlusion-lite, diagram (label pin), handwriting (write answer with stylus → compare), audio (TTS record).
Scheduling: FSRS (modern) with SM-2 fallback toggle; ease/interval/difficulty, bury/suspend, leech detection, custom study + exam mode (no scheduling pollutes), streaks.
Stats: retention curve, due forecast, review heatmap. Import/export: Anki `.apkg`-compatible CSV/TSV + JSON.
Edge: empty deck → “Add cards” wizard; audio permission denied → text-only fallback.

### 3.7 Habits
Cadence: daily/weekly/monthly + flexible (e.g. 3×/week, every Tue/Thu), targets + minimums (e.g. 10 pushups, min 5), streak + streak-freeze, skip/miss/recover, stacking (“after coffee”), reminders (contextual: time/location/focus-end), calendar overlay, stats/trends/history, notes per check-in, templates.
Anti-pressure mode: hides streaks, shows consistency % + gentle copy. Changing schedule never deletes history; keeps audit.

### 3.8 Focus + App/Website Blocking (serious system)
Profiles: Study/Work/Sleep/Custom with block sets + schedule + session link.
Blocking: apps (process/window class), sites (domains, wildcard `*.youtube.com`, URL regex), categories, whitelist>blacklist, temp (15m–8h) + recurring + session-bound, emergency override (configurable friction: type phrase + 60s wait + reason logged), history + stats.
OS abstraction `BlockEngine`: Linux (Wayland: `xdg-desktop-portal` + `/etc/hosts` helper + browser extension fallback — document Wayland limits honestly; X11 legacy via `wmctrl`), Windows (WFP/hosts + extension), macOS (Network Extension/ScreenTime API + extension), Android (Accessibility + VPN loopback), iOS (ScreenTime/FamilyControls). Unified UX, per-OS capability matrix in-app.
Anti-circumvention: researched from Cold Turkey/Freedom/Forest — block extension uninstall during session, DNS fallback warning, reboot-persistence; always respects user control (master off with logged override, no hidden persistence).

### 3.9 Timers (advanced)
Modes: countdown, count-up, multi + named, presets, recurring, intervals (Tabata/HIIT custom rounds), Pomodoro (work/short/long cycles, auto-cycle toggle).
Behavior: pause/resume/restart, background run (foreground service where needed), persistence across reboot/close (restore + “missed while away” dialog), per-timer sound+vibrate+visual/silent, sound preview, floating mini + always-on-top (where supported), lock-screen/widget hooks, keyboard (`Space` start/pause, `R` reset), quick-start (`Ctrl/Cmd+K` “25m focus”).
Links: task/focus/habit/calendar. Stats/history/templates. Edge: 0-duration invalid; system杀 → notification fallback fires.

### 3.10 Stopwatch
Start/pause/resume/reset, laps + splits, best/avg/delta highlighting, named sessions, task/focus link, history + CSV export. Inputs: mouse (big button), keyboard (`Space` lap, `S` start/stop), touch (48px target), screen-reader announces laps politely.

### 3.11 Alarms
One-time/recurring/weekday/custom, label, sound (bundled + custom file) + gradual volume, vibrate, snooze (configurable 1–30m, max repeats), linked task/habit/routine, sleep/wake workflow (wind-down reminder + morning checklist). Anti-miss: requires math/scan dismiss optional, power-save exemption prompt, “alarm in 8h” pre-confirm.

### 3.12 AI Assistant (universal, cross-object)
Understands Task/Event/Note/Doc/Deck/Session graph — no copy-paste. Examples: “notes→flashcards”, “plan 3 study blocks around free time + block YouTube”, “handwriting→structured note”, “revision plan from this doc”.
Routing (explainable, overridable): Fast (autocomplete, rewrite-lite, classify; 1–3B local), General (planning, everyday QA; 7–8B local or cheap cloud), Deep Thinking (hard reasoning/code/large plans; 14–32B local or flagship cloud), Auto (router picks by task-type + reasoning-need + modality + context + privacy + latency + HW). Vision tasks route only to vision-capable models.
Local: Ollama (or llama.cpp fallback). First-run optional stress test: CPU/RAM/GPU/VRAM/storage/throughput → recommends mode + model (e.g. `qwen3:8b` vs `llama3.1:8b`) with honest “CPU-only 70B unusable” warnings.
BYOK: OpenAI, Anthropic/Claude, Google/Gemini, DeepSeek, Qwen, Mistral, xAI/Grok — per-provider key, priority order, secure OS keystore, no logging, one-tap revoke, per-task provider override.
Privacy: local-first badge on every answer (“ran locally” vs “used cloud + what was sent”), redaction toggle for PII.

### 3.13 Voice
Local/privacy-preserving STT (Sherpa-ONNX/Vosk/whisper.cpp tier by device), dictation into any field, “Hey Socra” optional offline wake (disabled default), voice commands (“start 25 minute focus”, “add task…”), voice notes with waveform + timestamps + speaker segments (best-effort) + editable transcript → one-tap to Note/Task/Flashcards; punctuation auto + voice-search. Mic denied → typed fallback + settings deep-link.

### 3.14 Search (universal, local)
Across notes/docs/tasks/events/habits/decks/files/tags/transcripts. Fuzzy + exact (`" "`), filters (`type:`, `tag:`, `date:`, `deck:`), date ranges, ranking (recency + match + linked-boost), recent/saved searches, FTS5 + on-device embeddings hybrid (no cloud required). Large index: background indexing, incremental, pause on battery-saver.

### 3.15 Templates
For notes/docs/tasks/projects/habits/events/decks/focus/timers/workflows. Variables (`{{date}}`, `{{title}}`), defaults, dynamic dates (+7d), linked-content scaffolds, categories, system + personal, import/export JSON. Applying never overwrites: inserts or creates new with link.

### 3.16 Automations (workflow engine)
Triggers: time, event start/end, task done, habit done, timer done, note/doc edited, focus start/end, block start, streak risk. Actions: create task/event/note, start timer/focus/block, generate deck, notify, tag, AI transform (with confirm). Conditions + multi-action chains + dry-run + run log + disable-all kill switch.

### 3.17 Notifications
Unified manager: scheduled/reminders/timer/focus/AI, priority (low/default/high/critical alarm), batching (digest mode), quiet hours (per-profile), grouping, snooze + inline actions (Complete/Snooze/Start). Per-OS channel mapping; missing permission → setup card, never silent fail.

### 3.18 Analytics, Settings, Account, Integrations
Analytics: completion %, focus hours, habit consistency, review retention, block saves — all local, export CSV, no telemetry without opt-in.
Settings sections (each with defaults + reset): General, Appearance, Accessibility, Notifications, AI, Local Models, Providers, Privacy, Security, Sync, Storage, Search, Calendar, Tasks, Notes, Documents, Whiteboard, Flashcards, Habits, Focus, Timers, Voice, Automations, Shortcuts, Integrations, Account, Developer, Advanced.
Account: optional; enables E2E-encrypted sync/backup/share workspaces. Guest mode fully usable.
Integrations: Google/Outlook cal (import/subscribe), WebDAV/S3 backup targets, browser extension for blocking, share-sheet intents; all toggleable, all offline-safe.

## 4. Architecture (modular, no giant files)

Layers: `presentation (Flutter widgets)` → `application services (use-cases)` → `domain (entities, pure Dart)` → `data (Drift DAOs, repos)` → `platform (BlockEngine, notifs, TTS/STT, keystore, FS)` → `ai-routing (Ollama client, provider adapters)` → `sync/indexing`. Dependency rule: inward only; no UI business logic; feature folders `features/<name>/{domain,data,presentation}` + `core/*` shared.
Perf: virtualized lists/canvases/docs, pagination (50–100/window), debounced search (150ms), image downscale + WebP cache, 60fps budget on mid hardware, reduced-motion support.
Security: SQLCipher optional, Argon2 for lock, OS keystore for keys, share sandbox, export redaction.

## 5. Delivery Order (for implementation AI)

Docs (this + design.md) → foundation (nav, Material theme) → tasks/calendar/habits → notes-canvas + docs → flashcards/search → timers/focus/blocking → AI/voice/automations → polish/a11y/perf → packaging (Flatpak primary, .rpm/AppImage, MSIX/dmg/APK/IPA).
