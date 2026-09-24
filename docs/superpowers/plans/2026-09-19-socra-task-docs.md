# SocraTask Docs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Draft `prompt.md` (product/functionality/architecture) + `design.md` (visual/Liquid Glass/specs) for SocraTask.

**Architecture:** Flutter + SocraGlassRenderer abstraction (Full/Standard/Lite backends), Drift/SQLite local-first, Ollama + BYOK AI routing; docs-first, then phased code slices.

**Tech Stack:** Flutter 3.41+ (Dart 3.5+), FragmentShader custom glass, Drift/SQLite FTS5, Ollama local inference, Flatpak/.rpm + Win/macOS/mobile bundles.

**Spec:** This plan IS the spec for the docs phase (approved brainstorming: Flutter+SocraGlass, Phase 1 docs). Executors read this + user brief in chat history.

## Global Constraints

- Fedora KDE Plasma 6.8 Wayland-first is primary target; identical Liquid Glass on Win/macOS/Linux/Android/iOS.
- No Impeller-only techniques; every glass effect needs Full/Standard/Lite fallback.
- Local-first offline useful; cloud sync/collab optional, account optional.
- No emoji as UI icons; coherent icon family.
- Accessibility first-class (keyboard, SR, focus, contrast, reduced-motion/transparency, scalable type).
- No placeholders in docs; every feature defines states: empty/loading/skeleton/success/failure/offline/permission-denied/invalid/retry/undo.
- `prompt.md` = product/functionality/architecture/AI/platform; `design.md` = visual/glass/layout/tokens/motion/a11y/page specs; complementary, minimal overlap.

---

## File Structure

- `prompt.md` — vision, unified object model, per-module functional specs (Dashboard, Calendar, Tasks, Notes+whiteboard, Documents separate, Flashcards FSRS, Habits, Focus/Blocking, Timers, Stopwatch, Alarms, AI 4-modes, Voice, Search, Templates, Automations, Notifications, Analytics, Settings, Account, integrations), architecture layers, offline/sync, perf, privacy/security, import/export.
- `design.md` — tokens with exact values, SocraGlass per-component tuning + physics/timings, icon/motion systems, responsive rules, a11y, page-by-page layouts for all 20+ surfaces.
- `docs/superpowers/plans/2026-09-19-socra-task-docs.md` — this plan.

---

### Task 1: Draft prompt.md v1

**Files:**
- Create: `prompt.md`
- Test: manual read-through (no code tests; docs phase)

**Interfaces:**
- Consumes: user brief + research (liquid_glass_widgets 1.6.0, liquid_glass_easy 4.3.x, Tauri 2.10, Ollama HW guide, Plasma 6.8 Wayland notes)
- Produces: functional + architecture source of truth that `design.md` references (no visual values duplicated)

- [ ] **Step 1: Write prompt.md with sections:** vision/principles, object model (Task→Event→Note→Doc→Deck→Session), each module (what/where/controls/behavior/states/offline/sizes/integrations/edge cases), AI routing (Fast/General/Deep/Auto + BYOK), voice, search, templates, automations, notifications, architecture layers, offline/sync/conflicts, perf, security, import/export.
- [ ] **Step 2: Verify file exists and renders:** `ls -lh prompt.md && wc -l prompt.md`
- [ ] **Step 3: Checkpoint — report how-to-check to user and STOP for review**

### Task 2: Draft design.md v1 (system)

**Files:**
- Create: `design.md` (part 1: tokens, glass, components, motion, a11y, responsive)

**Interfaces:**
- Consumes: `prompt.md` module list (to size components)
- Produces: token table + `Glass*` primitive specs used by Task 3 page designs

- [ ] **Step 1: Write design tokens (exact px/dp values):** type scale, spacing 4/8pt, radii, borders, elevation, palettes, control sizes (touch 44px, toolbar 56/64, sidebar 280-320, modals 480/720/960, max-width 1200), breakpoints (<600/600-1024/>1024/>1600), glass params per component size, springs (stiffness 300/damping 28), durations (120/200/350ms), reduced-motion/transparency Lite fallback.
- [ ] **Step 2: Verify:** `ls -lh design.md && wc -l design.md`
- [ ] **Step 3: Checkpoint — report how-to-check, STOP for review**

### Task 3: design.md v2 page-by-page (tweak review)

**Files:**
- Modify: `design.md` (append page specs: Dashboard, Calendar, Tasks, Notes canvas, Documents, Flashcards, Habits, Focus, Timers, Stopwatch, Alarms, Blocking, AI, Voice, Search, Templates, Notifications, Analytics, Settings, Account, Automations)

**Interfaces:**
- Consumes: Task 2 tokens + Task 1 module specs
- Produces: tweak-ready layout specs (one section per page with layout, components, states, responsive, a11y, microinteractions)

- [ ] **Step 1: Append one section per page with ASCII/layout description + component list + state table + responsive notes.**
- [ ] **Step 2: Verify:** `grep -c "^## " design.md` (expect 20+ page sections)
- [ ] **Step 3: Checkpoint — per-page tweak review with user, STOP**

### Task 4: Self-review + verification pass

- [ ] **Step 1: Placeholder scan:** `grep -rn "TBD\|TODO\|standard functionality" prompt.md design.md` → must be empty (fix inline).
- [ ] **Step 2: Coverage check:** every module in prompt.md has a page section in design.md; every Glass component used on pages is defined in system section.
- [ ] **Step 3: Report final how-to-check summary to user.**
