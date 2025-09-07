-- Attune-Turtle v1.0.3 - Tooltip.lua
-- Manages all tooltip display logic.

-- Make sure AttuneTurtle exists
AttuneTurtle = AttuneTurtle or {}
local AT = AttuneTurtle  -- Local reference for faster access

-- Function to show an item tooltip
-- It will be called when the mouse enters a UI element that has an itemID.
function AT:ShowItemTooltip(frame, itemID)
    if not itemID then return end

    -- Use the standard GameTooltip, anchored to the frame that was hovered over.
    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
    GameTooltip:SetItemByID(itemID)
    GameTooltip:Show()
end

-- Function to hide the tooltip
-- It will be called when the mouse leaves the UI element.
function AT:HideTooltip()
    GameTooltip:Hide()
end