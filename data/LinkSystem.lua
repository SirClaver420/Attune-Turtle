-- Attune-Turtle Link System
-- Handles clickable links to Turtle WoW database

local AT = AttuneTurtle

-- Initialize link system
AT.linkSystem = {}

-- Base URLs for Turtle WoW database
AT.linkSystem.baseUrls = {
    quest = "https://database.turtle-wow.org/quest/",
    item = "https://database.turtle-wow.org/item/", 
    npc = "https://database.turtle-wow.org/npc/",
    zone = "https://database.turtle-wow.org/zone/"
}

-- Create link popup frame
function AT:CreateLinkPopup()
    if AT.linkPopup then return end
    
    -- Main popup frame
    AT.linkPopup = CreateFrame("Frame", "ATLinkPopup", UIParent)
    AT.linkPopup:SetWidth(500)
    AT.linkPopup:SetHeight(120)
    AT.linkPopup:SetPoint("CENTER")
    AT.linkPopup:SetFrameStrata("DIALOG")
    AT.linkPopup:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    AT.linkPopup:SetBackdropColor(0, 0, 0, 0.9)
    AT.linkPopup:EnableMouse(true)
    
    -- Title
    local title = AT.linkPopup:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    title:SetPoint("TOP", AT.linkPopup, "TOP", 0, -15)
    title:SetText("|cfffff000Copy Link to Turtle WoW Database|r")
    
    -- Instructions
    local instructions = AT.linkPopup:CreateFontString(nil, "OVERLAY")
    instructions:SetFont("Fonts\\FRIZQT__.TTF", 11)
    instructions:SetPoint("TOP", title, "BOTTOM", 0, -10)
    instructions:SetText("|cffffffffPress Ctrl+C to copy, then Alt+Tab to your browser|r")
    
    -- Edit box for the link
    local editBox = CreateFrame("EditBox", "ATLinkEditBox", AT.linkPopup)
    editBox:SetWidth(460)
    editBox:SetHeight(20)
    editBox:SetPoint("TOP", instructions, "BOTTOM", 0, -15)
    editBox:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    editBox:SetBackdropColor(1, 1, 1, 0.9)
    editBox:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    editBox:SetFont("Fonts\\FRIZQT__.TTF", 11)
    editBox:SetTextColor(0, 0, 0, 1)
    editBox:SetAutoFocus(true)
    editBox:SetMaxLetters(200)
    AT.linkPopup.editBox = editBox
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, AT.linkPopup, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", AT.linkPopup, "TOPRIGHT", -5, -5)
    closeBtn:SetScript("OnClick", function() AT.linkPopup:Hide() end)
    
    -- Auto-hide after 10 seconds
    AT.linkPopup:SetScript("OnShow", function()
        AT.linkPopup.timer = 10
        AT.linkPopup:SetScript("OnUpdate", function()
            AT.linkPopup.timer = AT.linkPopup.timer - arg1
            if AT.linkPopup.timer <= 0 then
                AT.linkPopup:Hide()
                AT.linkPopup:SetScript("OnUpdate", nil)
            end
        end)
    end)
    
    AT.linkPopup:Hide()
end

-- Show link popup with specific URL
function AT:ShowLink(linkType, id, name)
    if not AT.linkPopup then
        AT:CreateLinkPopup()
    end
    
    local url = AT.linkSystem.baseUrls[linkType]
    if not url then
        print("|cff00ff00Attune Turtle:|r Unknown link type: " .. tostring(linkType))
        return
    end
    
    local fullUrl = url .. tostring(id)
    
    AT.linkPopup.editBox:SetText(fullUrl)
    AT.linkPopup.editBox:HighlightText()
    AT.linkPopup:Show()
    
    -- Debug info
    if AT.debug then
        print("|cff00ff00[Attune Debug]:|r Showing link for " .. linkType .. " ID " .. tostring(id) .. " (" .. tostring(name) .. ")")
    end
end

-- Create clickable text
function AT:CreateClickableText(parent, text, linkType, id, name)
    local clickableText = parent:CreateFontString(nil, "OVERLAY")
    clickableText:SetFont("Fonts\\FRIZQT__.TTF", 11)
    clickableText:SetText("|cff4080ff[" .. text .. "]|r") -- Blue clickable color
    
    -- Create invisible button over the text for clicking
    local button = CreateFrame("Button", nil, parent)
    button:SetPoint("TOPLEFT", clickableText, "TOPLEFT")
    button:SetPoint("BOTTOMRIGHT", clickableText, "BOTTOMRIGHT")
    button:SetScript("OnClick", function()
        AT:ShowLink(linkType, id, name)
    end)
    
    -- Hover effect
    button:SetScript("OnEnter", function()
        clickableText:SetText("|cff80c0ff[" .. text .. "]|r") -- Lighter blue on hover
    end)
    
    button:SetScript("OnLeave", function()
        clickableText:SetText("|cff4080ff[" .. text .. "]|r") -- Back to normal
    end)
    
    return clickableText, button
end