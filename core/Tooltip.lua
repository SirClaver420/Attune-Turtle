-- Attune-Turtle v1.0.3 - core/Tooltip.lua
-- Step 0.3d Part 1: Add reusable tooltip attachment helper (Lua 5.0 safe).
-- Existing ShowItemTooltip / HideTooltip preserved for backward compatibility.

AttuneTurtle = AttuneTurtle or {}
local AT = AttuneTurtle

---------------------------------------------------------------------
-- Existing simple item tooltip helpers (unchanged)
---------------------------------------------------------------------
function AT:ShowItemTooltip(frame, itemID)
    if not itemID then return end
    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
    GameTooltip:SetItemByID(itemID)
    GameTooltip:Show()
end

function AT:HideTooltip()
    GameTooltip:Hide()
end

---------------------------------------------------------------------
-- New generic tooltip attachment helper
-- Usage:
--   AT:AttachTooltip(frame, {
--       text  = "Single line"            -- OR
--       lines = { "Line 1", "Line 2" }   -- OR table entries { text, r,g,b, wrap }
--       itemID = 12345                   -- (optional) show item tooltip first
--       anchor = "ANCHOR_RIGHT"          -- (optional) default if absent
--   })
--
-- Rules:
-- - If itemID is present, we call SetItemByID BEFORE adding custom lines.
-- - If both text and lines are given, 'lines' wins.
-- - String line entries -> white (1,1,1).
-- - Table entries: { text, r, g, b, wrap } (r,g,b default 1,1,1; wrap default nil).
-- - Silent no-op if frame is nil.
-- - If re-attached, only data is updated; scripts not duplicated.
-- - Lua 5.0 compatible (no '#' length, no colon-based match reliance).
---------------------------------------------------------------------
function AT:AttachTooltip(frame, config)
    if not frame then return end

    if frame._attuneTooltipHooked then
        -- Update data only
        frame._attuneTooltipData = config
        return
    end

    frame._attuneTooltipData = config

    frame:SetScript("OnEnter", function()
        local cfg = frame._attuneTooltipData
        if not cfg then return end

        local anchor = cfg.anchor or "ANCHOR_RIGHT"
        GameTooltip:SetOwner(this, anchor)

        -- Optional item tooltip
        if cfg.itemID then
            GameTooltip:SetItemByID(cfg.itemID)
        end

        -- Determine lines
        local lines = cfg.lines
        if (not lines) and cfg.text then
            lines = { cfg.text }
        end

        if lines then
            local i = 1
            while lines[i] do
                local entry = lines[i]
                if type(entry) == "string" then
                    if entry ~= "" then
                        GameTooltip:AddLine(entry, 1, 1, 1, 1)
                    end
                elseif type(entry) == "table" then
                    local t = entry[1]
                    if t and t ~= "" then
                        local r = entry[2] or 1
                        local g = entry[3] or 1
                        local b = entry[4] or 1
                        local wrap = entry[5]
                        GameTooltip:AddLine(t, r, g, b, wrap)
                    end
                end
                i = i + 1
            end
        end

        GameTooltip:Show()
    end)

    -- Preserve existing OnLeave if present
    local oldLeave = frame:GetScript("OnLeave")
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
        if oldLeave then oldLeave() end
    end)

    frame._attuneTooltipHooked = true
end

---------------------------------------------------------------------
-- Optional detach (not fully removing scripts to avoid conflicts)
---------------------------------------------------------------------
function AT:DetachTooltip(frame)
    if not frame or not frame._attuneTooltipHooked then return end
    frame._attuneTooltipData = nil
    -- Leaving scripts in place to avoid clobbering others; can refine later.
end

---------------------------------------------------------------------
-- Debug self-test (fires only if debug master ON and 'ui' channel or all)
---------------------------------------------------------------------
local function SelfTest()
    if not AT.Debug or not AT.Debug.Is then return end
    if AT.Debug:Is("ui") then
        AT.Debug:Print("ui", "Tooltip helper loaded (Step 0.3d Part 1).")
    end
end

SelfTest()