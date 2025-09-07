# Attune-Turtle Architecture Plan (v1.0.3 Baseline)

Status: Draft (Step 0.1)  
Authoring Session Date: (Fill after adding)  
This document is the authoritative design reference for the upcoming refactor and feature expansion.

---

## 1. Core Goals

1. Reliable icon + tooltip system (no invisible textures, supports items, quests, spells later).
2. Structured data registration model (attunements & steps can be added modularly).
3. Future automation (quest completion, item possession, level, faction checks).
4. Minimal-risk incremental migration (addon remains usable after every step).
5. Search, text token expansion, and optional source/metadata lines—staged in later phases.
6. Extensibility: allow future “plugin” files to register new attunements without editing core.
7. Turtle WoW compatibility: leverage extended APIs where stable, but degrade gracefully if absent.

---

## 2. Current Pain / Limitations (v1.0.2 state)

| Aspect | Limitation | Impact |
|--------|------------|--------|
| Icon handling | Direct SetTexture without validation or caching awareness | Invisible/missing icons hard to debug |
| Tooltip logic | None central; per-frame not hooked | No hover detail; cannot expand later |
| Data layout | Single Data.lua monolith | Hard to extend / register externally |
| UI rendering | Mixed concerns (layout + logic + data formatting) | Refactors become risky |
| Progress tracking | Manual toggles only | No retention of per-step state granularity |
| Event model | Some quest hooks only | Cannot yet drive dynamic completion |
| Version drift | Screenshot shows 1.0.3 idea, TOC still 1.0.2 | Potential confusion while testing |

---

## 3. Planned Modular Structure

Target directory tree (phased—files introduced gradually):

```
Attune-Turtle/
  Attune-Turtle.toc
  Core/
    Init.lua              (bootstrap: namespace, saved vars, slash, version)
    Registry.lua          (attunement & step registration API)
    StepModel.lua         (schema validation + normalization)
    Tooltip.lua           (frame attach helpers, item/quest/spell tooltip resolution)
    Events.lua            (central event dispatcher: ITEM_INFO_RECEIVED, QUEST_TURNED_IN, etc.)
    Automation.lua        (later: evaluation of step completion)
    Debug.lua             (debug toggles, icon test harness)
  UI/
    MainFrame.lua         (window creation, sizing, persistence)
    Sidebar.lua           (category + attunement listing)
    AttunementView.lua    (linear or graph layout for steps)
    Widgets.lua           (reusable small components: step button, icon wrapper)
  Data/
    Icons.lua             (central icon map)
    Attunements.lua       (baseline built-in definitions)
    Categories.lua        (sidebar grouping)
    (Future: split large raid chains into separate files)
  Extensions/
    (Optional third-party or future plugin attunements)
  docs/
    ArchitecturePlan.md   (this file)
    MigrationLog.md       (we will add after first refactor step)
```

Initially we DO NOT delete existing files; we introduce new ones and migrate logic piece by piece, then retire old modules once parity is achieved.

---

## 4. Step / Attunement Data Model (Draft)

A normalized `Step` table after registration:

```lua
{
  id = "ony_reach_level",
  attunementKey = "onyxia",
  order = 1,                 -- auto-assigned if linear
  type = "level" | "quest" | "item" | "kill" | "talk" | "travel" | "faction" | "custom",
  title = "Reach level 55",
  subtext = "Minimum required",
  description = "Optional long form guidance (future)",
  itemID = 12345,            -- for type=item (optional)
  questID = 6543,            -- for type=quest (future expansion)
  npcID = 9999,              -- for talk/kill if known (future)
  mapID = 1415,              -- optional world position support (future)
  x = nil, y = nil,          -- graph coordinates (if flowchart mode)
  previous = { "some_step_id", ... } OR "single_id" OR nil,
  requirements = {           -- evaluation input for Automation
     level = 55,
     quests = { 6543 },      -- must be completed
     items = { { id=12345, count=1 } },
     faction = { name="Argent Dawn", standing="Honored" },
  },
  iconOverride = "Interface\\Icons\\INV_Scroll_05",  -- optional manual icon
  autoIcon = true,            -- if true, system may derive from item/spell/quest or fallback by type
  flags = { optional=false, repeatable=false },
}
```

Attunement definition:

```lua
{
  key = "onyxia",
  name = "Onyxia's Lair",
  category = "Attunements",   -- maps to sidebar category
  icon = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
  steps = { ...raw step tables... },  -- normalized during registration
  meta = {
     factionVariant = { Alliance = "...", Horde = "..." }, -- later
     notes = "Any extra future metadata"
  }
}
```

Registration flow:

1. `Registry:RegisterAttunement(key, defTable)`
2. Validates & normalizes each step via `StepModel.Normalize(step, context)`
3. Builds internal indexes:
   - `Registry.attunements[key]`
   - `Registry.stepsByAttunement[key][stepID]`
4. Emits debugging info if anomalies encountered (duplicate IDs, dangling previous references).

---

## 5. Icon Resolution Algorithm (Phase 2 Design)

Priority order when setting a step icon:
1. `step.iconOverride` if provided.
2. If `step.type == "item"` and `itemID` cached: use `GetItemIcon(itemID)`.
3. If `step.type == "quest"` and quest has icon (later: custom map / book icon).
4. Type fallback mapping (from Icons.lua):
   - level → Spell_Holy_DivineSpirit (existing)
   - quest → INV_Scroll_03
   - item → INV_Box_01
   - kill → INV_Sword_27
   - talk → GossipFrame\AvailableQuestIcon
   - travel → INV_Misc_Map_01
   - faction → Achievement_Reputation_?? (if available on Turtle; fallback to INV_Scroll_05)
5. Default fallback: `Interface\\Icons\\INV_Misc_QuestionMark`

If item not cached:
- Assign temporary placeholder (question mark)
- Queue a retry on `ITEM_INFO_RECEIVED` (store outstanding itemIDs -> frames)
- Reapply icon quietly (no flicker) once info available.

Debug mode logs:
`[Attune Debug][Icon] step=ony_reach_level tried=Interface\\Icons\\INV_Misc_QuestionMark (item uncached)`

---

## 6. Tooltip System (Initial Scope)

Phase 1 (minimal):
- Explicit attach per step frame:
  - OnEnter:
    - If step.itemID then GameTooltip:SetOwner(frame, "ANCHOR_RIGHT"); GameTooltip:SetHyperlink("item:"..itemID)
    - Else show a custom simple header + description (phase later)
  - OnLeave: GameTooltip:Hide()

Phase 2:
- Add caching / delayed item resolution (if nil).
- Add progress line (Completed / Not Completed).
- Add optional “Requires: Argent Dawn (Honored)” line if requirements present.
- Provide hook surface for future “Show Source” style augmentation (similar to AtlasLoot but scoped).

Phase 3:
- Multi-entity tooltips (e.g., a step requiring multiple items).
- Shift-click linking (allow sending item or step link to chat—custom link format maybe `[AttuneStep:onyxia:ony_kill_overlord]`)

We intentionally DO NOT global-hook all tooltip Set* functions early (unneeded risk). We can escalate if advanced augmentation (like scanning arbitrary item displays) becomes necessary.

---

## 7. Event & Automation Plan (Future)

Events to register centrally:
- `ITEM_INFO_RECEIVED` (icon retries)
- `PLAYER_LEVEL_UP` (re-evaluate level-based steps)
- `QUEST_TURNED_IN` (quest completions)
- `BAG_UPDATE` (item possession checks)
- `UPDATE_FACTION` (faction standing for steps like Naxx entry)
- `PLAYER_ENTERING_WORLD` (startup sync)

Automation pass:
- For each attunement active => evaluate incomplete steps:
  - Level: compare UnitLevel
  - Quest: Turtle may offer improved APIs; fallback parsing the quest log
  - Item possession: scan bags (GetItemCount)
  - Faction: GetFactionInfoByName
- When true, mark step completed and raise a UI refresh signal (deferred / throttled to avoid spam).

We maintain:
`Progress[attunementKey].steps[stepID] = true|false`
`Progress[attunementKey].completed = true|false (derived)`

---

## 8. Migration Phases & Concrete Tasks

| Phase | Objective | Concrete Initial Tasks |
|-------|-----------|------------------------|
| 0 | Planning & Diagnostics | (a) Add this doc (b) Add MigrationLog.md later |
| 1 | Introduce Debug & Safer Icon Path | Add Core/Debug.lua with toggle; wrap SetTexture tests |
| 2 | Tooltip Foundation | Add Core/Tooltip.lua; attach to existing sidebar + title icons; simple item tooltips |
| 3 | Registry & StepModel | Add Core/Registry.lua & StepModel.lua; migrate existing attunements through adapter |
| 4 | UI Segmentation | Break UI.lua into MainFrame.lua, Sidebar.lua, AttunementView.lua |
| 5 | Icon Retry & Requirements | Add item caching retry + requirement metadata parsing |
| 6 | Automation Base | Implement Events.lua + basic completion marking |
| 7 | Search + Tokenization (Optional) | Introduce lightweight search over normalized steps |
| 8 | Advanced Tooltip Meta | Add progress lines, requirement lines, future expansions |
| 9 | External Plugin Support | Document plugin registration contract |
| 10 | Optimization / Cleanup | Remove deprecated old monolithic files |

We WILL keep the addon functional at each boundary before proceeding.

---

## 9. Load Order Strategy (TOC Adaptation – Coming Later)

Proposed future TOC ordering:

```
## Libraries...
Core/Init.lua
Core/Debug.lua          (safe early)
Data/Icons.lua
Data/Attunements.lua
Data/Categories.lua
Core/StepModel.lua
Core/Registry.lua
Core/Tooltip.lua
Core/Events.lua
Core/Automation.lua
UI/MainFrame.lua
UI/Sidebar.lua
UI/AttunementView.lua
UI/Widgets.lua
```

During migration we temporarily keep original `Core.lua`, `data/Data.lua`, `data/UI.lua` until parity reached.

---

## 10. Namespacing & Globals

- Primary table: `AttuneTurtle` (alias `AT`)
- Subtables committed after Step 1:
  - `AT.Registry`
  - `AT.UI`
  - `AT.Tooltip`
  - `AT.Debug`
  - `AT.Automation`
  - `AT.Events`
- Avoid creating free globals except for saved variables + slash handler root.

---

## 11. Debug Facilities (Design)

`/attune debug` (already exists) extended to show sub-modes:

Planned:
- `/attune debug icons`
- `/attune debug tooltip`
- `/attune debug steps ony...` (filter)
Internally: `AT.Debug:IsEnabled("icons")` gating logs.

All debug text prefixed:
`[Attune Debug][icons] ...`

---

## 12. Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Breaking live UI during file split | Migrate in additive layers; do not remove old file until new module verified |
| Tooltip taint or mis-hook | Do not do global hooking initially |
| Performance regression (automation scanning) | Throttle evaluation; only re-evaluate categories impacted by the triggering event |
| Data inconsistency after refactor | Add StepModel validate pass; print anomalies under debug |
| Duplicate step IDs from future plugins | Registry rejects duplicates with clear debug warning |

---

## 13. Compatibility With Possible Future Branching (Faction / Path Split)

We will allow `step.variants = { Alliance = {...override fields...}, Horde = {...} }` (Phase 5+).  
Normalization selects variant at registration (or at render time if dynamic).

---

## 14. Potential Future Enhancements (Not in Immediate Scope)

- Graph mode: draw directional connectors (already partly done in current flowchart concept).
- Export/import of progress (serialize to a compressed string).
- Chat link for steps: `[AttuneStep:attunementKey:stepID]`.
- Map pin integration (if Turtle exposes or compatible with MapNote frameworks).
- Locale extraction tool stub (prepare for localization).

---

## 15. Immediate Next Concrete Tasks AFTER This Doc

1. Add `Core/Debug.lua` with:
   - `AT.Debug = { channels = {}, Enable(chan), Disable(chan), Is(chan) }`
   - Integrate with existing `/attune debug` (treat it as master toggle).
   - Provide test function: `AT.Debug:TestIcon(texturePath)` to attempt SetTexture on a hidden texture region and confirm success (log outcome).
2. Bump TOC Version to 1.0.3.
3. No behavioral change yet—only scaffolding.

We will do these in Step 0.2 after you confirm this file is added.

---

## 16. Acceptance Criteria for Phase 1 (End)

- `docs/ArchitecturePlan.md` present.
- `Core/Debug.lua` operational.
- Version in TOC = 1.0.3.
- Addon loads with zero Lua errors.
- `/attune debug` still toggles legacy debug prints; new channels callable but unused gracefully.

---

## 17. Open Questions (Track Here)

- Do we want a *Graph Mode Toggle* early or postpone until after registry migration?
- Should progress store timestamps of first completion? (Future analytics)
- Do we store per-character + global template separately? (Probably yes later)

(We will append answers as we proceed.)

---

## 18. Change Log (Architecture Document Only)

- v1.0.3‑A (Initial draft added) – Planning baseline.
- (Add entries as we refine.)

---

End of document.