# Attune-Turtle Migration Log

Chronological record of structural or behavioral changes.  
Format: [Step] Date (UTC) - Summary

## Step 0.1 (Baseline)
- Initial addon scaffold: window, sidebar, landing page, basic data file.
- Minimap button present.
- Simple slash commands (/attune, /at).
- No debug framework beyond a raw AT_Debug flag.

## Step 0.2 (Initial Debug & Version Bump)
- Added Core/Debug.lua scaffolding (channel concept, TestIcon harness).
- Introduced version 1.0.3.
- First attempt embedded AceHook early (caused silent load failure due to misaligned TOC paths after directory restructuring).
- Identified root cause: TOC paths pointed to old locations (Core.lua moved into /core, etc.).

## Step 0.2 (Recovery / Safe Base: 0.2 retry → 0.2a → 0.2b)
- Rebuilt TOC with correct lowercase directory paths.
- Removed premature AceHook embedding; reverted to plain table namespace.
- Added ShowOptions() alias (unified with button call).
- Restored minimap button creation on PLAYER_LOGIN using LibDBIcon.
- Unified right-click minimap and main window "Options" button to the same placeholder function.
- Added debug prints around minimap creation for diagnostics.
- Confirmed stable load: slash commands work, resize works, categories collapse, no errors.

## Step 0.3 (Housekeeping Kickoff – Option A Plan)
(Planning marker kept for historical clarity.)
- Add MigrationLog.md (this file).
- Extend debug framework (channel toggling).
- Wording consistency to “Options”.

## Step 0.3b (Expanded Debug Framework)
- Added channel management: /attune debug <channel>, list, all, off.
- Introduced status summaries.
- Still used Lua 5.1+ patterns initially.

## Step 0.3c (Lua 5.0 Compatibility & Operational Verification)
- Replaced Debug.lua with strictly Lua 5.0–compatible code (removed '#' length operator and any string:match reliance).
- Replaced Core.lua parsing logic (now uses string.find / string.sub).
- Verified in-game:
  - /attune debug (master toggle)
  - /attune debug ui (channel toggling)
  - /attune debug all / off / list all functioning.
- Result: Stable baseline with working selective and all-channel debug modes.

## Conventions Going Forward
- Each change introduced in its own “micro-step” (0.x[a|b|c|…]).
- Only modify unrelated files when required by the exact step goal.
- All Lua must remain Lua 5.0-compatible (no '#', no ipairs reliance on metamethods, avoid string.match if colon syntax risk, etc.).

## Pending / Upcoming (Roadmap Snapshot)
- 0.3d: Minimal tooltip attachment helper (no global hooks yet). Add safe AT:AttachTooltip(frame, config).
- 0.4: Registry + StepModel skeleton (migrate one attunement to new normalized format).
- 0.5: Icon fallback & resolution retries (ITEM_INFO_RECEIVED integration).
- 0.6: Progress persistence per character (DB schema expansion).
- 0.7: Real Options frame (replacing placeholder print).
- Later: Search, automation hooks, plugin-style extension points.

(End of file)