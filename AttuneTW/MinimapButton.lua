-- Attune-Turtle Minimap Button
-- Based on AutoLFM's minimap button

-- Initialize minimap button global
AttuneTurtleMinimapBtn = nil

-- Function to initialize the minimap button
function AT_InitMinimapButton()
    if AttuneTurtleMinimapBtn then
        AttuneTurtleMinimapBtn:Show()
        return
    end

    if not AttuneTurtle_Data then
        AttuneTurtle_Data = {}
    end

    -- Create the button
    AttuneTurtleMinimapBtn = CreateFrame("Button", "AttuneTurtleMinimapBtn", Minimap)
    AttuneTurtleMinimapBtn:SetFrameStrata("LOW")
    AttuneTurtleMinimapBtn:SetHeight(24)
    AttuneTurtleMinimapBtn:SetWidth(24)

    -- Position the button using saved values or defaults
    local posX = AttuneTurtle_Data.minimapBtnX or -10
    local posY = AttuneTurtle_Data.minimapBtnY or -10
    AttuneTurtleMinimapBtn:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", posX, posY)

    -- Border texture
    local borderTexture = AttuneTurtleMinimapBtn:CreateTexture(nil, "BORDER")
    borderTexture:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    borderTexture:SetHeight(54)
    borderTexture:SetWidth(54)
    borderTexture:SetPoint("TOPLEFT", -4, 3)

    -- Icon (use a default icon for now, can be replaced later)
    AttuneTurtleMinimapBtn:SetNormalTexture("Interface\\Icons\\INV_Misc_Note_01")
    AttuneTurtleMinimapBtn:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9) -- Trim the borders

    -- Highlight effect
    AttuneTurtleMinimapBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- Pushed texture (when clicked)
    AttuneTurtleMinimapBtn:SetPushedTexture("Interface\\Icons\\INV_Misc_Note_01")
    AttuneTurtleMinimapBtn:GetPushedTexture():SetTexCoord(0.15, 0.85, 0.15, 0.85) -- Shrink the texture slightly

    -- Tooltip on hover
    AttuneTurtleMinimapBtn:SetScript("OnEnter", function()
        GameTooltip:SetOwner(AttuneTurtleMinimapBtn, "ANCHOR_RIGHT")
        GameTooltip:SetText("|cff00ff00Attune|r |cffffffffTurtle")
        GameTooltip:AddLine("Click to toggle Attune-Turtle interface.", 1, 1, 1)
        GameTooltip:AddLine("Ctrl + Click to move.", 1, 1, 1)
        GameTooltip:Show()
    end)
    
    AttuneTurtleMinimapBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Left click to toggle interface unless Ctrl is pressed
    AttuneTurtleMinimapBtn:SetScript("OnClick", function()
        if IsControlKeyDown() then return end
        AT_ToggleMainFrame()
    end)

    -- Make it movable with Ctrl + left click
    AttuneTurtleMinimapBtn:SetMovable(true)
    AttuneTurtleMinimapBtn:EnableMouse(true)
    AttuneTurtleMinimapBtn:RegisterForDrag("LeftButton")

    AttuneTurtleMinimapBtn:SetScript("OnMouseDown", function(self, button)
        if IsControlKeyDown() then
            AttuneTurtleMinimapBtn:StartMoving()
        end
    end)

    AttuneTurtleMinimapBtn:SetScript("OnMouseUp", function(self, button)
        AttuneTurtleMinimapBtn:StopMovingOrSizing()
        local point, relativeTo, relativePoint, xOfs, yOfs = AttuneTurtleMinimapBtn:GetPoint()
        AttuneTurtle_Data.minimapBtnX = xOfs
        AttuneTurtle_Data.minimapBtnY = yOfs
    end)

    AttuneTurtleMinimapBtn:Show()
end

-- Initialize when Core.lua loads
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if arg1 == "Attune-Turtle" then
        -- Wait a bit to ensure all addon data is loaded
        C_Timer.After(1, function() AT_InitMinimapButton() end)
    end
end)