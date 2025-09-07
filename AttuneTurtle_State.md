This file contains the complete state of the Attune-Turtle addon.

### `Attune-Turtle.toc`

```toc name=Attune-Turtle.toc
## Interface: 11200
## Title: |cff00ff00Attune|r |cffffffffTurtle|r
## Notes: Track attunement progress for dungeons and raids on Turtle WoW
## Author: SirClaver420
## Version: 1.0.2
## SavedVariables: AttuneTurtleDB
## DefaultState: Enabled
## LoadOnDemand: 0

# @version 1.0.2

# Libraries
libs\LibStub.lua
libs\AceCore-3.0.lua
libs\CallbackHandler-1.0.lua
libs\AceHook-3.0.lua
libs\LibDataBroker-1.1.lua
libs\LibDBIcon-1.0.lua

# Core files
Core.lua
data\Data.lua
data\UI.lua
data\MinimapButton.lua
```

### `Core.lua`

```lua name=Core.lua
-- Attune-Turtle v1.0.2 - Core.lua
-- Main addon logic and initialization

-- Initialize the addon's main table
AttuneTurtle = LibStub("AceHook-3.0"):Embed({})
local AT = AttuneTurtle

-- Version information
AT.version = "1.0.2" -- Version updated for new feature
AT.author = "SirClaver420"

-- Database defaults
local defaults = {
    profile = {
        minimap = {
            hide = false,
            minimapPos = 225,
            radius = 80,
        },
        -- Window dimensions
        width = 1024,
        height = 600,
        -- Attunement progress
        attunements = {},
        categoryStates = {
            ["Dungeons / Keys"] = true,
            ["Attunements"] = true,
        },
        firstTime = true,
    }
}

-- Initialize the saved variables database
function AT:InitializeDatabase()
    -- This ensures the global DB table exists.
    AttuneTurtleDB = AttuneTurtleDB or {}
    
    -- Populate the database with default values if they don't exist.
    for key, value in pairs(defaults.profile) do
        if AttuneTurtleDB[key] == nil then
            AttuneTurtleDB[key] = value
        end
    end
    
    -- Create a local reference for easier access throughout the addon.
    AT.db = AttuneTurtleDB
    AT_Debug("Database initialized")
end

-- Create the LibDataBroker object for the minimap icon
function AT:CreateDataBroker()
    local LDB = LibStub("LibDataBroker-1.1")
    
    AT.dataObj = LDB:NewDataObject("AttuneTurtle", {
        type = "launcher",
        text = "Attune Turtle",
        icon = "Interface\\Icons\\INV_Misc_Book_09",
        OnClick = function(clickedframe, button)
            if button == "LeftButton" then
                AT:ToggleMainFrame()
            elseif button == "RightButton" then
                AT:ShowSettings()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("|cff00ff00Attune Turtle|r")
            tooltip:AddLine(" ")
            tooltip:AddLine("|cffffff00Left-click:|r Open attunement tracker")
            tooltip:AddLine("|cffffff00Right-click:|r Open settings")
            
            -- Add attunement status (placeholder logic)
            local completed = 0
            local total = 0
            for key, attunement in pairs(AT.attunements) do
                total = total + 1
                if AT:IsAttunementCompleted(key) then
                    completed = completed + 1
                end
            end
            
            tooltip:AddLine(" ")
            tooltip:AddLine("|cffaaccffProgress: " .. completed .. "/" .. total .. " completed|r")
        end,
    })
end

-- Toggle the main frame's visibility
function AT:ToggleMainFrame()
    if AT.mainFrame and AT.mainFrame:IsVisible() then
        AT.mainFrame:Hide()
    else
        if not AT.mainFrame then
            AT_CreateMainFrame()
        end
        AT.mainFrame:Show()
    end
end

-- Placeholder for future settings panel
function AT:ShowSettings()
    print("|cff00ff00Attune Turtle:|r Settings panel coming soon!")
end

-- Check if an attunement is marked as completed in the database
function AT:IsAttunementCompleted(attunementKey)
    if not AT.db or not AT.db.attunements then
        return false
    end
    return AT.db.attunements[attunementKey] and AT.db.attunements[attunementKey].completed
end

-- Mark an attunement as completed in the database
function AT:SetAttunementCompleted(attunementKey, completed)
    if not AT.db.attunements then AT.db.attunements = {} end
    if not AT.db.attunements[attunementKey] then AT.db.attunements[attunementKey] = {} end
    AT.db.attunements[attunementKey].completed = completed
    
    -- Refresh the UI if it's open
    if AT.mainFrame and AT.mainFrame:IsVisible() and AT.selectedAttunement == attunementKey then
        AT_CreateAttunementView(attunementKey)
    end
end

-- Hook game events to enable automatic progress tracking
function AT:HookQuestEvents()
    AT:SecureHook("QuestRewardCompleteButton_OnClick", function()
        AT:CheckQuestCompletion()
    end)
    
    AT:SecureHook("SelectQuestLogEntry", function()
        AT:CheckQuestProgress()
    end)
end

-- Check for quest completion when a quest is turned in
function AT:CheckQuestCompletion()
    local questTitle = GetTitleText()
    if not questTitle then return end
    
    for attunementKey, attunement in pairs(AT.attunements) do
        if attunement.steps then
            for i, step in ipairs(attunement.steps) do
                if step.type == "quest" and step.text and string.find(step.text, questTitle) then
                    AT:MarkStepCompleted(attunementKey, step.id)
                end
            end
        end
    end
end

-- Mark a specific step as completed in the database
function AT:MarkStepCompleted(attunementKey, stepId)
    if not AT.db.attunements then AT.db.attunements = {} end
    if not AT.db.attunements[attunementKey] then AT.db.attunements[attunementKey] = { steps = {} } end
    if not AT.db.attunements[attunementKey].steps then AT.db.attunements[attunementKey].steps = {} end
    
    AT.db.attunements[attunementKey].steps[stepId] = true
    
    print("|cff00ff00Attune Turtle:|r Step completed for " .. (AT.attunements[attunementKey] and AT.attunements[attunementKey].name or attunementKey))
end

-- Placeholder for checking the player's quest log
function AT:CheckQuestProgress()
    -- This will be expanded in future versions
end

-- Display help information in the chat window
function AT:ShowHelp()
    print("|cff00ff00Attune Turtle|r - Available Commands:")
    print("  |cffffff00/attune|r or |cffffffff/at|r - Toggle the main window.")
    print("  |cffffff00/attune help|r - Show this help message.")
    print("  |cffffff00/attune version|r - Display addon version.")
    print("  |cffffff00/attune debug|r - Toggle debug mode.")
    print("  |cffffff00/attune reset|r - Reset addon settings (including window size).")
end

-- Debug function for internal use
function AT_Debug(message)
    if AT.debug then
        print("|cff00ff00[Attune Debug]:|r " .. tostring(message))
    end
end

-- Event frame for handling addon initialization events
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("VARIABLES_LOADED")

eventFrame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "Attune-Turtle" then
        -- This event fires when our addon's files are loaded.
        -- We initialize the database and DataBroker object here.
        AT:InitializeDatabase()
        AT:CreateDataBroker()
        
    elseif event == "VARIABLES_LOADED" then
        -- This event fires after saved variables are loaded.
        -- This is the correct time to create the minimap button.
        AT_CreateMinimapButton()
        
    elseif event == "PLAYER_LOGIN" then
        -- This event fires when the player enters the world.
        AT:HookQuestEvents()
        
        -- Show a login message every time.
        if AT.db.firstTime then
            print("|cff00ff00Attune Turtle|r [v" .. AT.version .. "] loaded for the first time! Type |cffffffff/attune|r to open.")
            AT.db.firstTime = false
        else
            print("|cff00ff00Attune Turtle|r [v" .. AT.version .. "] loaded. Type |cffffffff/attune help|r for commands.")
        end
        
        -- Unregister events we only need once.
        eventFrame:UnregisterEvent("ADDON_LOADED")
        eventFrame:UnregisterEvent("PLAYER_LOGIN")
        eventFrame:UnregisterEvent("VARIABLES_LOADED")
    end
end)

-- Slash command handler
SLASH_ATTUNE1 = "/attune"
SLASH_ATTUNE2 = "/at"
SlashCmdList["ATTUNE"] = function(msg)
    msg = string.lower(msg or "")
    
    if msg == "debug" then
        AT.debug = not AT.debug
        print("|cff00ff00Attune Turtle:|r Debug mode " .. (AT.debug and "enabled" or "disabled"))
    elseif msg == "reset" then
        -- Reset all settings to default
        AttuneTurtleDB = nil
        AT:InitializeDatabase()
        if AT.mainFrame then
            AT.mainFrame:Hide()
            AT.mainFrame = nil
        end
        AT:ResetMinimapButton()
        print("|cff00ff00Attune Turtle:|r All settings have been reset to default.")
    elseif msg == "version" then
        print("|cff00ff00Attune Turtle:|r Version " .. AT.version .. " by " .. AT.author)
    elseif msg == "help" then
        AT:ShowHelp()
    else
        AT:ToggleMainFrame()
    end
end
```

### `data/Data.lua`

```lua name=data/Data.lua
-- Attune-Turtle v1.0.0 - Data.lua
-- Contains all data for attunements

-- Make sure AttuneTurtle exists
AttuneTurtle = AttuneTurtle or {}
local AT = AttuneTurtle

-- Icon paths for different step types
AT.icons = {
    ring = "Interface\\Icons\\INV_Jewelry_Ring_03",
    quest = "Interface\\Icons\\INV_Scroll_03",
    item = "Interface\\Icons\\INV_Box_01",
    kill = "Interface\\Icons\\INV_Sword_27",
    talk = "Interface\\GossipFrame\\AvailableQuestIcon",
    travel = "Interface\\Icons\\INV_Misc_Map_01",
    dungeon = "Interface\\Icons\\INV_Misc_Rune_01",
    level = "Interface\\Icons\\Spell_Holy_DivineSpirit",
    scroll = "Interface\\Icons\\INV_Scroll_05", -- Default/fallback
}

-- Attunement data
AT.attunements = {
    -- Dungeons / Keys
    zulfarrak = {
        name = "Zul'Farrak Mallet",
        icon = "Interface\\Icons\\INV_Hammer_15",
        steps = {
            {
                title = "Gahz'rilla",
                text = "This is a placeholder for the Zul'Farrak Mallet attunement steps."
            }
        }
    },
    maraudon = {
        name = "Maraudon Scepter",
        icon = "Interface\\Icons\\INV_Staff_10",
        steps = {
            {
                title = "Scepter of Celebras",
                text = "This is a placeholder for the Maraudon Scepter attunement steps."
            }
        }
    },
    ubrs = {
        name = "UBRS Key",
        icon = "Interface\\Icons\\INV_Misc_Key_11",
        steps = {
            {
                title = "Seal of Ascension",
                text = "This is a placeholder for the UBRS Key attunement steps."
            }
        }
    },
    diremaul = {
        name = "Dire Maul Key",
        icon = "Interface\\Icons\\INV_Misc_Key_09",
        steps = {
            {
                title = "Crescent Key",
                text = "This is a placeholder for the Dire Maul Key attunement steps."
            }
        }
    },
    scholomance = {
        name = "Scholomance Key",
        icon = "Interface\\Icons\\INV_Misc_Key_14",
        steps = {
            {
                title = "Skeleton Key",
                text = "This is a placeholder for the Scholomance Key attunement steps."
            }
        }
    },

    -- Attunements (Raids)
    moltencore = {
        name = "Molten Core",
        icon = "Interface\\Icons\\INV_Misc_Rune_06",
        steps = {
            {
                title = "Attunement to the Core",
                text = "Find Lothos Riftwaker in Blackrock Mountain to get the quest 'Attunement to the Core'. You can enter Molten Core through a window in Blackrock Depths, or by speaking to Lothos Riftwaker once attuned."
            }
        }
    },
    onyxia = {
        name = "Onyxia's Lair",
        icon = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
        steps = {
            {
                title = "Onyxia's Lair Attunement",
                text = "This is a placeholder for the Onyxia's Lair attunement steps. It involves a long quest chain for both Horde and Alliance."
            }
        }
        --[[ --- ADVANCED FLOWCHART DATA - HIDDEN FOR NOW ---
        steps = {
            {
                id = "ony_reach_level",
                title = "Reach level 55",
                subtext = "Required minimum",
                type = "level",
                check = { type = "level", value = 55 },
                x = 0, y = -100
            },
            {
                id = "ony_warlords_command",
                title = "Warlord's Command",
                subtext = "Quest in Badlands",
                type = "quest",
                previousStep = "ony_reach_level",
                x = 0, y = -190
            },
            {
                id = "ony_kill_warchief",
                title = "Important Blackrock...",
                subtext = "Item in Lower Blackrock...",
                type = "item",
                previousStep = "ony_warlords_command",
                x = -300, y = -280
            },
            {
                id = "ony_kill_overlord",
                title = "Overlord Wyrmthalak",
                subtext = "Kill in Lower Blackrock...",
                type = "kill",
                previousStep = "ony_warlords_command",
                x = -100, y = -280
            },
            {
                id = "ony_kill_warmaster",
                title = "War Master Voone",
                subtext = "Kill in Lower Blackrock...",
                type = "kill",
                previousStep = "ony_warlords_command",
                x = 100, y = -280
            },
            {
                id = "ony_kill_highlord",
                title = "Highlord Omokk",
                subtext = "Kill in Lower Blackrock...",
                type = "kill",
                previousStep = "ony_warlords_command",
                x = 300, y = -280
            },
            {
                id = "ony_eirtriggs_wisdom",
                title = "Eitrigg's Wisdom",
                subtext = "Quest in Orgrimmar",
                type = "quest",
                previousStep = { "ony_kill_warchief", "ony_kill_overlord", "ony_kill_warmaster", "ony_kill_highlord" },
                x = 0, y = -370
            },
            {
                id = "ony_for_the_horde",
                title = "For The Horde!",
                subtext = "Quest in Orgrimmar",
                type = "quest",
                previousStep = "ony_eirtriggs_wisdom",
                x = 0, y = -460
            }
        }
        --]]
    },
    blackwinglair = {
        name = "Blackwing Lair",
        icon = "Interface\\Icons\\Spell_Shadow_DeathAndDecay",
        steps = {
            {
                title = "Blackhand's Command",
                text = "Click the orb behind General Drakkisath in UBRS to complete the attunement."
            }
        }
    },
    naxxramas = {
        name = "Naxxramas",
        icon = "Interface\\Icons\\INV_Misc_Bone_07",
        steps = {
            {
                title = "The Dread Citadel",
                text = "Attunement requires Honored reputation with the Argent Dawn. Speak to Archmage Angela Dosantos at Light's Hope Chapel."
            }
        }
    }
}

-- Category data for the sidebar
AT.categories = {
    {
        name = "Dungeons / Keys",
        expanded = true, -- Default to expanded
        items = { "zulfarrak", "maraudon", "ubrs", "diremaul", "scholomance" }
    },
    {
        name = "Attunements",
        expanded = true, -- Default to expanded
        items = { "moltencore", "onyxia", "blackwinglair", "naxxramas" }
    }
}
```

### `data/UI.lua`

```lua name=data/UI.lua
-- Attune-Turtle v1.0.2 - UI.lua
-- Contains all UI-related functions

-- Make sure AttuneTurtle exists
AttuneTurtle = AttuneTurtle or {}
local AT = AttuneTurtle  -- Local reference for faster access

-- This function will be called whenever the window is resized to redraw the layout.
function AT_RefreshLayout()
    if not AT.mainFrame then return end
    
    -- If we have a view selected, redraw it. Otherwise, redraw the landing page.
    if AT.selectedAttunement then
        AT_CreateAttunementView(AT.selectedAttunement)
    else
        AT_CreateLandingPage()
    end
    
    -- Always update the scroll range after a resize.
    if AT.UpdateScrollRange then
        AT.UpdateScrollRange()
    end
end

-- Create the main UI frame
function AT_CreateMainFrame()
    -- Main frame
    AT.mainFrame = CreateFrame("Frame", "AttuneTurtleMainFrame", UIParent)
    -- Use saved dimensions, falling back to defaults
    AT.mainFrame:SetWidth(AT.db.width or 1024)
    AT.mainFrame:SetHeight(AT.db.height or 600)
    AT.mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    AT.mainFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    AT.mainFrame:SetBackdropColor(0, 0, 0, 0.8)
    AT.mainFrame:EnableMouse(true)
    AT.mainFrame:SetMovable(true)
    AT.mainFrame:SetResizable(true) -- Make the frame resizable
    AT.mainFrame:SetMinResize(600, 400) -- Set minimum dimensions
    
    -- Register for ESC key
    tinsert(UISpecialFrames, "AttuneTurtleMainFrame")
    
    -- Make the entire frame draggable
    AT.mainFrame:RegisterForDrag("LeftButton")
    AT.mainFrame:SetScript("OnDragStart", function() 
        if not AT.mainFrame.isSizing then -- Only start moving if we are not resizing
            AT.mainFrame:StartMoving()
        end
    end)
    AT.mainFrame:SetScript("OnDragStop", function() 
        AT.mainFrame:StopMovingOrSizing()
        -- Save position and size
        AT.db.width = AT.mainFrame:GetWidth()
        AT.db.height = AT.mainFrame:GetHeight()
    end)
    
    -- Title bar
    local titleBar = CreateFrame("Frame", nil, AT.mainFrame)
    titleBar:SetPoint("TOPLEFT", AT.mainFrame, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", AT.mainFrame, "TOPRIGHT", 0, 0)
    titleBar:SetHeight(25)
    
    -- Title text
    local title = titleBar:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    title:SetPoint("TOP", titleBar, "TOP", 0, -10)
    title:SetText("|cff00ff00Attune|r |cffffffffTurtle|r")
    
    -- Top-level close button
    local topCloseButton = CreateFrame("Button", nil, AT.mainFrame, "UIPanelCloseButton")
    topCloseButton:SetPoint("TOPRIGHT", AT.mainFrame, "TOPRIGHT", -5, -5)
    topCloseButton:SetScript("OnClick", function() AT.mainFrame:Hide() end)
    
    -- A single bottom panel to hold all bottom elements for consistent alignment.
    local bottomPanel = CreateFrame("Frame", nil, AT.mainFrame)
    bottomPanel:SetHeight(30) -- Adjusted height for tighter fit
    bottomPanel:SetPoint("BOTTOMLEFT", AT.mainFrame, "BOTTOMLEFT", 5, 5)
    bottomPanel:SetPoint("BOTTOMRIGHT", AT.mainFrame, "BOTTOMRIGHT", -25, 5) -- MOVED 20px to the left to make space

    -- Close button (anchored to the bottom right of the panel)
    local closeBtn = CreateFrame("Button", nil, bottomPanel, "UIPanelButtonTemplate")
    closeBtn:SetWidth(80)
    closeBtn:SetHeight(25)
    closeBtn:SetText("Close")
    closeBtn:SetPoint("RIGHT", bottomPanel, "RIGHT", 0, 0)
    closeBtn:SetScript("OnClick", function() AT.mainFrame:Hide() end)

    -- Options button (anchored to the Close button)
    local optionsBtn = CreateFrame("Button", nil, bottomPanel, "UIPanelButtonTemplate")
    optionsBtn:SetWidth(80)
    optionsBtn:SetHeight(25)
    optionsBtn:SetText("Options")
    optionsBtn:SetPoint("RIGHT", closeBtn, "LEFT", -2, 0)
    optionsBtn:SetScript("OnClick", function()
        print("|cff00ff00Attune Turtle:|r Options panel coming soon!")
    end)

    -- Version panel (stretches to fill remaining space)
    local versionPanel = CreateFrame("Frame", nil, bottomPanel)
    versionPanel:SetHeight(25)
    versionPanel:SetPoint("LEFT", bottomPanel, "LEFT", 0, 0)
    versionPanel:SetPoint("RIGHT", optionsBtn, "LEFT", -5, 0)
    versionPanel:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    versionPanel:SetBackdropColor(0, 0, 0, 0.7)

    -- Version text
    local versionText = versionPanel:CreateFontString(nil, "OVERLAY")
    versionText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    versionText:SetPoint("LEFT", versionPanel, "LEFT", 12, 0)
    versionText:SetText("|cffd4af37Attune " .. (AT.version or "1.0.2") .. " by " .. (AT.author or "SirClaver420") .. "|r")

    -- Create sidebar (left panel), now anchored to the bottom panel for perfect alignment
    AT.sidebarFrame = CreateFrame("Frame", "AttuneTurtleSidebar", AT.mainFrame)
    AT.sidebarFrame:SetWidth(200)
    AT.sidebarFrame:SetPoint("TOPLEFT", AT.mainFrame, "TOPLEFT", 5, -30)
    AT.sidebarFrame:SetPoint("BOTTOMLEFT", bottomPanel, "TOPLEFT", 0, 2) -- Anchor to the top of the bottom panel
    AT.sidebarFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    AT.sidebarFrame:SetBackdropColor(0, 0, 0, 0.5)
    
    -- Create main content area, also anchored to the bottom panel
    AT.contentFrame = CreateFrame("Frame", "AttuneTurtleContent", AT.mainFrame)
    AT.contentFrame:SetPoint("TOPLEFT", AT.sidebarFrame, "TOPRIGHT", 2, 0)
    AT.contentFrame:SetPoint("BOTTOMRIGHT", bottomPanel, "TOPRIGHT", 0, 2) -- Anchor to the top of the bottom panel
    AT.contentFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    AT.contentFrame:SetBackdropColor(0, 0, 0, 0.3)
    
    -- Create simple scroll frame
    AT.scrollFrame = CreateFrame("ScrollFrame", "AttuneTurtleScrollFrame", AT.contentFrame)
    AT.scrollFrame:SetPoint("TOPLEFT", AT.contentFrame, "TOPLEFT", 8, -8)
    AT.scrollFrame:SetPoint("BOTTOMRIGHT", AT.contentFrame, "BOTTOMRIGHT", -30, 8)
    
    -- Create scroll bar
    AT.scrollBar = CreateFrame("Slider", "AttuneTurtleScrollBar", AT.scrollFrame)
    AT.scrollBar:SetPoint("TOPRIGHT", AT.contentFrame, "TOPRIGHT", -8, -8)
    AT.scrollBar:SetPoint("BOTTOMRIGHT", AT.contentFrame, "BOTTOMRIGHT", -8, 8)
    AT.scrollBar:SetWidth(16)
    AT.scrollBar:SetMinMaxValues(0, 100)
    AT.scrollBar:SetValue(0)
    AT.scrollBar:SetValueStep(1)
    
    AT.scrollBar:SetBackdrop({
        bgFile = "Interface/Buttons/UI-SliderBar-Background",
        edgeFile = "Interface/Buttons/UI-SliderBar-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    
    local scrollThumb = AT.scrollBar:CreateTexture(nil, "OVERLAY")
    scrollThumb:SetTexture("Interface/Buttons/UI-SliderBar-Button-Horizontal")
    scrollThumb:SetWidth(16)
    scrollThumb:SetHeight(24)
    AT.scrollBar:SetThumbTexture(scrollThumb)
    
    AT.scrollChild = CreateFrame("Frame", "AttuneTurtleScrollChild", AT.scrollFrame)
    AT.scrollChild:SetWidth(1)
    AT.scrollChild:SetHeight(1)
    AT.scrollFrame:SetScrollChild(AT.scrollChild)
    
    local function UpdateScrollRange()
        local contentHeight = AT.scrollChild:GetHeight()
        local frameHeight = AT.scrollFrame:GetHeight()
        if frameHeight < 0 then frameHeight = 0 end
        local maxScroll = math.max(0, contentHeight - frameHeight)
        AT.scrollBar:SetMinMaxValues(0, maxScroll)
        if maxScroll > 0 then AT.scrollBar:Show() else AT.scrollBar:Hide() end
    end
    
    AT.scrollBar:SetScript("OnValueChanged", function()
        AT.scrollFrame:SetVerticalScroll(AT.scrollBar:GetValue())
    end)
    
    AT.scrollFrame:EnableMouseWheel(true)
    AT.scrollFrame:SetScript("OnMouseWheel", function()
        local delta = arg1 -- Use arg1 for mouse wheel delta
        local current = AT.scrollBar:GetValue()
        local min, max = AT.scrollBar:GetMinMaxValues()
        local newValue = current - (delta * 20)
        AT.scrollBar:SetValue(math.max(min, math.min(max, newValue)))
    end)
    
    AT.UpdateScrollRange = UpdateScrollRange
    
    -- Create the resize handle button
    local resizeButton = CreateFrame("Button", "AttuneTurtleResizeButton", AT.mainFrame)
    resizeButton:SetFrameStrata("HIGH") -- Set strata to be on top
    resizeButton:SetPoint("BOTTOMRIGHT", AT.mainFrame, "BOTTOMRIGHT", -3, 3)
    resizeButton:SetWidth(16)
    resizeButton:SetHeight(16)
    resizeButton:SetFrameLevel(AT.mainFrame:GetFrameLevel() + 5)
    
    local resizeTexture = resizeButton:CreateTexture(nil, "ARTWORK")
    resizeTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-Size-Up")
    resizeTexture:SetAllPoints()

    resizeButton:SetScript("OnMouseDown", function()
        AT.mainFrame:StartSizing("BOTTOMRIGHT")
        AT.mainFrame.isSizing = true
    end)
    resizeButton:SetScript("OnMouseUp", function()
        AT.mainFrame:StopMovingOrSizing()
        AT.mainFrame.isSizing = false
        -- Save the new dimensions
        AT.db.width = AT.mainFrame:GetWidth()
        AT.db.height = AT.mainFrame:GetHeight()
        -- Refresh the internal layout
        AT_RefreshLayout()
    end)
    
    AT.categoryStates = AT.db.categoryStates or {}
    
    AT.selectedAttunement = nil
    
    AT_PopulateSidebar()
    
    AT.mainFrame:SetScript("OnShow", function()
        -- OnShow, we want to show the landing page.
        AT_CreateLandingPage()
    end)
    
    AT.mainFrame:Hide()
end

-- Create the landing page
function AT_CreateLandingPage()
    if not AT.scrollChild or not AT.contentFrame then return end
    
    local children = {AT.scrollChild:GetChildren()}
    for _, child in ipairs(children) do child:Hide(); child:SetParent(nil) end
    local regions = {AT.scrollChild:GetRegions()}
    for _, region in ipairs(regions) do
        if region:GetObjectType() == "FontString" or region:GetObjectType() == "Texture" then region:Hide(); region:SetParent(nil) end
    end
    
    local availableWidth = AT.contentFrame:GetWidth() - 60
    if availableWidth <= 0 then return end -- Don't draw if frame is too small
    AT.scrollChild:SetWidth(availableWidth)
    
    local welcomeIcon = AT.scrollChild:CreateTexture(nil, "ARTWORK")
    welcomeIcon:SetWidth(48); welcomeIcon:SetHeight(48)
    welcomeIcon:SetPoint("TOP", AT.scrollChild, "TOP", 0, -30)
    welcomeIcon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    
    local welcomeTitle = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    welcomeTitle:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
    welcomeTitle:SetPoint("TOP", welcomeIcon, "TOP", 0, 20)
    welcomeTitle:SetPoint("LEFT", welcomeIcon, "RIGHT", 15)
    welcomeTitle:SetText("|cff00ff00Welcome to Attune Turtle!|r")
    
    local descText = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    descText:SetFont("Fonts\\FRIZQT__.TTF", 14)
    descText:SetPoint("TOP", welcomeIcon, "BOTTOM", 0, -30)
    descText:SetWidth(availableWidth - 20)
    descText:SetJustifyH("CENTER")
    descText:SetText("|cffffffffAttune Turtle helps you track your attunement progress for dungeons and raids.|r")
    
    local featuresTitle = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    featuresTitle:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    featuresTitle:SetPoint("TOP", descText, "BOTTOM", 0, -40)
    featuresTitle:SetText("|cffffff00Features:|r")
    
    local featuresContainer = CreateFrame("Frame", nil, AT.scrollChild)
    featuresContainer:SetWidth(320); featuresContainer:SetHeight(100)
    featuresContainer:SetPoint("TOP", featuresTitle, "BOTTOM", 0, -20)
    
    local feature1Icon = featuresContainer:CreateTexture(nil, "ARTWORK")
    feature1Icon:SetWidth(16); feature1Icon:SetHeight(16)
    feature1Icon:SetPoint("TOPLEFT", featuresContainer, "TOPLEFT", 0, 0)
    feature1Icon:SetTexture("Interface\\Icons\\INV_Misc_Key_11")
    
    local feature1Text = featuresContainer:CreateFontString(nil, "OVERLAY")
    feature1Text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    feature1Text:SetPoint("LEFT", feature1Icon, "RIGHT", 10, 0)
    feature1Text:SetWidth(290); feature1Text:SetJustifyH("LEFT")
    feature1Text:SetText("|cffffffffTrack dungeon key requirements and steps|r")
    
    local feature2Icon = featuresContainer:CreateTexture(nil, "ARTWORK")
    feature2Icon:SetWidth(16); feature2Icon:SetHeight(16)
    feature2Icon:SetPoint("TOP", feature1Icon, "BOTTOM", 0, -15)
    feature2Icon:SetTexture("Interface\\Icons\\INV_Hammer_Unique_Sulfuras")
    
    local feature2Text = featuresContainer:CreateFontString(nil, "OVERLAY")
    feature2Text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    feature2Text:SetPoint("LEFT", feature2Icon, "RIGHT", 10, 0)
    feature2Text:SetWidth(290); feature2Text:SetJustifyH("LEFT")
    feature2Text:SetText("|cffffffffView raid attunement chains and progress|r")
    
    local feature3Icon = featuresContainer:CreateTexture(nil, "ARTWORK")
    feature3Icon:SetWidth(16); feature3Icon:SetHeight(16)
    feature3Icon:SetPoint("TOP", feature2Icon, "BOTTOM", 0, -15)
    feature3Icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
    
    local feature3Text = featuresContainer:CreateFontString(nil, "OVERLAY")
    feature3Text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    feature3Text:SetPoint("LEFT", feature3Icon, "RIGHT", 10, 0)
    feature3Text:SetWidth(290); feature3Text:SetJustifyH("LEFT")
    feature3Text:SetText("|cffffffffStep-by-step quest and item guidance|r")
    
    local startTitle = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    startTitle:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    startTitle:SetPoint("TOP", featuresContainer, "BOTTOM", 0, -40)
    startTitle:SetText("|cffffff00Getting Started:|r")
    
    local startText = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    startText:SetFont("Fonts\\FRIZQT__.TTF", 12)
    startText:SetPoint("TOP", startTitle, "BOTTOM", 0, -15)
    startText:SetWidth(availableWidth - 20)
    startText:SetJustifyH("CENTER")
    startText:SetText("|cffffffffSelect a dungeon or raid from the left panel to view its attunement requirements.\n\nEach step will show you exactly what you need to do and where to go.|r")
    
    -- RE-ADDED THE MISSING TEXT
    local turtleNote = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    turtleNote:SetFont("Fonts\\FRIZQT__.TTF", 11)
    turtleNote:SetPoint("TOP", startText, "BOTTOM", 0, -30)
    turtleNote:SetWidth(availableWidth - 60)
    turtleNote:SetJustifyH("CENTER")
    turtleNote:SetTextColor(0.8, 0.8, 1.0)
    turtleNote:SetText("|cffaaccffOptimized for Turtle WoW - Happy adventuring!|r")
    
    local extraContent = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    extraContent:SetFont("Fonts\\FRIZQT__.TTF", 10)
    extraContent:SetPoint("TOP", turtleNote, "BOTTOM", 0, -50)
    extraContent:SetWidth(availableWidth - 60)
    extraContent:SetJustifyH("CENTER")
    extraContent:SetTextColor(0.5, 0.5, 0.5)
    extraContent:SetText("|cff808080Additional Features Coming Soon:\n\n• Quest completion tracking (if possible)\n• Progress saving\n• Character-specific progress\n• Export/Import functionality\n• Custom notes\n\n\n\nThis content extends beyond the visible area to test scrolling functionality.\n\n\n\nEnd of content.|r")
    
    AT.scrollChild:SetHeight(800) -- INCREASED HEIGHT TO MAKE SCROLLING NECESSARY
    
    if AT.UpdateScrollRange then AT.UpdateScrollRange() end
    if AT.scrollBar then AT.scrollBar:SetValue(0) end
    
    AT.selectedAttunement = nil
    
    if AT.sidebarItems then
        for key, item in pairs(AT.sidebarItems) do
            if item and item.SetSelected then item:SetSelected(false) end
        end
    end
    
    if AT.homeButton and AT.homeButton.SetSelected then AT.homeButton:SetSelected(true) end
end

function AT_SelectAttunement(attunementKey)
    if not attunementKey or not AT.attunements[attunementKey] then return end
    
    AT.selectedAttunement = attunementKey
    
    if AT.sidebarItems then
        for key, item in pairs(AT.sidebarItems) do
            if item and item.SetSelected then item:SetSelected(key == attunementKey) end
        end
    end
    
    if AT.homeButton and AT.homeButton.SetSelected then AT.homeButton:SetSelected(false) end
    
    AT_CreateAttunementView(attunementKey)
end

function AT_CreateHomeButton(yPos)
    local itemFrame = CreateFrame("Button", "ATItem_Home", AT.sidebarFrame)
    itemFrame:SetHeight(20)
    itemFrame:SetPoint("TOPLEFT", AT.sidebarFrame, "TOPLEFT", 15, yPos)
    itemFrame:SetPoint("TOPRIGHT", AT.sidebarFrame, "TOPRIGHT", -5, yPos)
    itemFrame:EnableMouse(true)
    
    local icon = itemFrame:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(16); icon:SetHeight(16)
    icon:SetPoint("LEFT", itemFrame, "LEFT", 0, 0)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    
    local text = itemFrame:CreateFontString(nil, "OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
    text:SetText("|cffffffffHome|r")
    
    itemFrame.SetSelected = function(frame, selected)
        if selected then frame:LockHighlight() else frame:UnlockHighlight() end
    end
    
    itemFrame:SetScript("OnClick", AT_CreateLandingPage)
    itemFrame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    AT.homeButton = itemFrame
    return itemFrame
end

function AT_CreateSidebarItem(attunementKey, yPos)
    local attunement = AT.attunements[attunementKey]
    if not attunement then return nil end
    
    local itemFrame = CreateFrame("Button", "ATItem_" .. attunementKey, AT.sidebarFrame)
    itemFrame:SetHeight(20)
    itemFrame:SetPoint("TOPLEFT", AT.sidebarFrame, "TOPLEFT", 15, yPos)
    itemFrame:SetPoint("TOPRIGHT", AT.sidebarFrame, "TOPRIGHT", -5, yPos)
    itemFrame:EnableMouse(true)
    
    local icon = itemFrame:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(16); icon:SetHeight(16)
    icon:SetPoint("LEFT", itemFrame, "LEFT", 0, 0)
    icon:SetTexture(attunement.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    
    local text = itemFrame:CreateFontString(nil, "OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
    text:SetText("|cffffffff" .. attunement.name .. "|r")
    
    itemFrame.attunementKey = attunementKey
    
    itemFrame.SetSelected = function(frame, selected)
        if selected then frame:LockHighlight() else frame:UnlockHighlight() end
    end
    
    itemFrame:SetScript("OnClick", function() AT_SelectAttunement(itemFrame.attunementKey) end)
    itemFrame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    itemFrame:SetSelected(attunementKey == AT.selectedAttunement)
    return itemFrame
end

function AT_CreateCategoryHeader(categoryName, yPos)
    local isExpanded = AT.db.categoryStates[categoryName]
    
    local headerFrame = CreateFrame("Button", nil, AT.sidebarFrame)
    headerFrame:SetHeight(20)
    headerFrame:SetPoint("TOPLEFT", AT.sidebarFrame, "TOPLEFT", 5, yPos)
    headerFrame:SetPoint("TOPRIGHT", AT.sidebarFrame, "TOPRIGHT", -5, yPos)
    headerFrame:EnableMouse(true)
    
    local headerText = headerFrame:CreateFontString(nil, "OVERLAY")
    headerText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    headerText:SetPoint("LEFT", headerFrame, "LEFT", 10, 0)
    headerText:SetText("|cffffff00" .. categoryName .. "|r")
    
    local expandBtn = headerFrame:CreateTexture(nil, "ARTWORK")
    expandBtn:SetWidth(16); expandBtn:SetHeight(16)
    expandBtn:SetPoint("RIGHT", headerFrame, "RIGHT", -5, 0)
    expandBtn:SetTexture(isExpanded and "Interface\\Buttons\\UI-MinusButton-Up" or "Interface\\Buttons\\UI-PlusButton-Up")
    
    headerFrame.categoryName = categoryName
    
    headerFrame:SetScript("OnClick", function()
        -- Note: We refer to the button as 'headerFrame' here, not 'self'
        AT.db.categoryStates[headerFrame.categoryName] = not AT.db.categoryStates[headerFrame.categoryName]
        AT_PopulateSidebar()
    end)
    
    headerFrame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    return headerFrame
end

function AT_PopulateSidebar()
    if AT.sidebarElements then
        for _, element in ipairs(AT.sidebarElements) do element:Hide() end
    end
    
    AT.sidebarElements = {}
    AT.sidebarItems = AT.sidebarItems or {}
    
    local yPos = -10
    
    local homeButton = AT_CreateHomeButton(yPos)
    table.insert(AT.sidebarElements, homeButton)
    yPos = yPos - 25
    
    for i, category in ipairs(AT.categories) do
        local isExpanded = AT.db.categoryStates[category.name]
        local header = AT_CreateCategoryHeader(category.name, yPos)
        table.insert(AT.sidebarElements, header)
        yPos = yPos - 25
        
        if isExpanded then
            for _, attunementKey in ipairs(category.items) do
                local item = AT_CreateSidebarItem(attunementKey, yPos)
                if item then
                    table.insert(AT.sidebarElements, item)
                    AT.sidebarItems[attunementKey] = item
                    yPos = yPos - 20
                end
            end
        end
    end
end

function AT:CheckStepStatus(step)
    if not step.check then return false end
    if step.check.type == "level" then return (UnitLevel("player") >= step.check.value) end
    return false
end

function AT_CreateAttunementView(attunementKey)
    attunementKey = attunementKey or AT.selectedAttunement
    if not attunementKey or not AT.attunements[attunementKey] then return end
    if not AT.contentFrame or AT.contentFrame:GetWidth() <= 1 then return end

    if AT.scrollChild then
        local children = {AT.scrollChild:GetChildren()}
        for _, child in ipairs(children) do child:Hide(); child:SetParent(nil) end
        local regions = {AT.scrollChild:GetRegions()}
        for _, region in ipairs(regions) do
            if region:GetObjectType() == "FontString" or region:GetObjectType() == "Texture" then region:Hide(); region:SetParent(nil) end
        end
    end
    
    local attunementData = AT.attunements[attunementKey]
    if not attunementData then return end
    
    local availableWidth = AT.contentFrame:GetWidth() - 40
    if availableWidth <= 0 then return end
    AT.scrollChild:SetWidth(availableWidth)
    
    local titleIcon = AT.scrollChild:CreateTexture(nil, "ARTWORK")
    titleIcon:SetWidth(32); titleIcon:SetHeight(32)
    titleIcon:SetPoint("TOPLEFT", AT.scrollChild, "TOPLEFT", 15, -15)
    titleIcon:SetTexture(attunementData.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    
    local attunementTitle = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    attunementTitle:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
    attunementTitle:SetPoint("LEFT", titleIcon, "RIGHT", 10, 0)
    attunementTitle:SetText(attunementData.name)
    
    if not attunementData.steps[1] or not attunementData.steps[1].x then
        local currentY = -80
        for i, step in ipairs(attunementData.steps) do
            local fallbackText = AT.scrollChild:CreateFontString(nil, "OVERLAY")
            fallbackText:SetFont("Fonts\\FRIZQT__.TTF", 12)
            fallbackText:SetPoint("TOPLEFT", AT.scrollChild, "TOPLEFT", 20, currentY)
            fallbackText:SetWidth(availableWidth - 40)
            fallbackText:SetJustifyH("LEFT")
            fallbackText:SetText((step.title or "Step " .. i) .. ": " .. (step.text or "No details available."))
            currentY = currentY - fallbackText:GetHeight() - 10
        end
        AT.scrollChild:SetHeight(math.abs(currentY) + 50)
        if AT.UpdateScrollRange then AT.UpdateScrollRange() end
        if AT.scrollBar then AT.scrollBar:SetValue(0) end
        return
    end

    local stepFrames = {}
    local minY = 0

    for i, step in ipairs(attunementData.steps) do
        local stepBox = CreateFrame("Frame", "AttuneTurtleStep_" .. step.id, AT.scrollChild)
        stepBox:SetWidth(180); stepBox:SetHeight(45)
        stepBox:SetPoint("CENTER", AT.scrollChild, "TOPLEFT", step.x + (availableWidth/2), step.y - 80)
        stepBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })

        if AT:CheckStepStatus(step) then stepBox:SetBackdropColor(0.1, 0.6, 0.1, 0.8) else stepBox:SetBackdropColor(0.15, 0.15, 0.15, 0.8) end

        local typeIcon = stepBox:CreateTexture(nil, "ARTWORK")
        typeIcon:SetWidth(28); typeIcon:SetHeight(28)
        typeIcon:SetPoint("LEFT", stepBox, "LEFT", 8, 0)
        typeIcon:SetTexture(AT.icons[step.type] or AT.icons.scroll)

        local stepTitle = stepBox:CreateFontString(nil, "OVERLAY")
        stepTitle:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        stepTitle:SetPoint("TOPLEFT", typeIcon, "RIGHT", 8, 5)
        stepTitle:SetWidth(130); stepTitle:SetJustifyH("LEFT")
        stepTitle:SetText(step.title or "Unknown Step")

        local stepSubtext = stepBox:CreateFontString(nil, "OVERLAY")
        stepSubtext:SetFont("Fonts\\FRIZQT__.TTF", 10)
        stepSubtext:SetPoint("TOPLEFT", stepTitle, "BOTTOMLEFT", 0, -2)
        stepSubtext:SetWidth(130); stepSubtext:SetJustifyH("LEFT")
        stepSubtext:SetTextColor(0.8, 0.8, 0.8)
        stepSubtext:SetText(step.subtext or "")

        stepFrames[step.id] = stepBox
        minY = math.min(minY, step.y - 45)
    end

    for i, step in ipairs(attunementData.steps) do
        if step.previousStep then
            local toFrame = stepFrames[step.id]
            
            local function drawVerticalLine(fromFrame, toFrame)
                if fromFrame and toFrame then
                    local line = AT.scrollChild:CreateTexture(nil, "BACKGROUND")
                    line:SetTexture("Interface\\Buttons\\WHITE8X8")
                    line:SetPoint("TOP", fromFrame, "BOTTOM")
                    line:SetPoint("BOTTOM", toFrame, "TOP")
                    line:SetWidth(3)
                    line:SetVertexColor(0.2, 0.6, 0.2, 0.7)
                end
            end

            if type(step.previousStep) == "table" then
                local fromFrames = {}
                for _, prevId in ipairs(step.previousStep) do
                    if stepFrames[prevId] then table.insert(fromFrames, stepFrames[prevId]) end
                end
                
                if table.getn(fromFrames) > 0 then
                    local hLine = AT.scrollChild:CreateTexture(nil, "BACKGROUND")
                    hLine:SetTexture("Interface\\Buttons\\WHITE8X8")
                    hLine:SetPoint("LEFT", fromFrames[1], "BOTTOM", 0, -10)
                    hLine:SetPoint("RIGHT", fromFrames[table.getn(fromFrames)], "BOTTOM", 0, -10)
                    hLine:SetHeight(3)
                    hLine:SetVertexColor(0.2, 0.6, 0.2, 0.7)

                    for _, fromFrame in ipairs(fromFrames) do
                        local vLine = AT.scrollChild:CreateTexture(nil, "BACKGROUND")
                        vLine:SetTexture("Interface\\Buttons\\WHITE8X8")
                        vLine:SetPoint("TOP", fromFrame, "BOTTOM")
                        vLine:SetPoint("BOTTOM", hLine, "TOP", fromFrame:GetCenter() - hLine:GetLeft(), 0)
                        vLine:SetWidth(3)
                        vLine:SetVertexColor(0.2, 0.6, 0.2, 0.7)
                    end
                    
                    local mainVLine = AT.scrollChild:CreateTexture(nil, "BACKGROUND")
                    mainVLine:SetTexture("Interface\\Buttons\\WHITE8X8")
                    mainVLine:SetPoint("TOP", hLine, "BOTTOM", toFrame:GetCenter() - hLine:GetLeft(), 0)
                    mainVLine:SetPoint("BOTTOM", toFrame, "TOP")
                    mainVLine:SetWidth(3)
                    mainVLine:SetVertexColor(0.2, 0.6, 0.2, 0.7)
                end
            else
                drawVerticalLine(stepFrames[step.previousStep], toFrame)
            end
        end
    end

    AT.scrollChild:SetHeight(math.abs(minY) + 100)
    if AT.UpdateScrollRange then AT.UpdateScrollRange() end
    if AT.scrollBar then AT.scrollBar:SetValue(0) end
end
```

### `data/MinimapButton.lua`

```lua name=data/MinimapButton.lua
-- Attune-Turtle v1.0.0 - MinimapButton.lua
-- Handles minimap icon integration

local AT = AttuneTurtle

-- Create minimap icon using LibDBIcon
function AT_CreateMinimapButton()
    if not AT.dataObj then
        AT_Debug("DataBroker object not found, cannot create minimap button")
        return
    end
    
    local icon = LibStub("LibDBIcon-1.0")
    if not icon then
        AT_Debug("LibDBIcon not found, cannot create minimap button")
        return
    end
    
    icon:Register("AttuneTurtle", AT.dataObj, AT.db.minimap)
    AT_Debug("Minimap button created successfully")
end

-- Show/hide minimap button
function AT:ToggleMinimapButton()
    if not AT.db.minimap then return end
    
    AT.db.minimap.hide = not AT.db.minimap.hide
    local icon = LibStub("LibDBIcon-1.0")
    
    if AT.db.minimap.hide then
        icon:Hide("AttuneTurtle")
        print("|cff00ff00Attune Turtle:|r Minimap button hidden")
    else
        icon:Show("AttuneTurtle")
        print("|cff00ff00Attune Turtle:|r Minimap button shown")
    end
end

-- Reset minimap button position
function AT:ResetMinimapButton()
    if not AT.db.minimap then return end
    
    AT.db.minimap.minimapPos = 225
    AT.db.minimap.hide = false
    
    local icon = LibStub("LibDBIcon-1.0")
    icon:Refresh("AttuneTurtle", AT.db.minimap)
    icon:Show("AttuneTurtle")
    
    print("|cff00ff00Attune Turtle:|r Minimap button reset to default position")
end
```

### `libs/LibStub.lua`

```lua name=libs/LibStub.lua
-- LibStub is a simple versioning stub meant for use in Libraries.  http://www.wowace.com/wiki/LibStub for more info
-- LibStub is hereby placed in the Public Domain Credits: Kaelten, Cladhaire, ckknight, Mikk, Ammo, Nevcairiel, joshborke
local LIBSTUB_MAJOR, LIBSTUB_MINOR = "LibStub", 2  -- NEVER MAKE THIS AN SVN REVISION! IT NEEDS TO BE USABLE IN ALL REPOS!
local _G = getfenv()
local strfind, strfmt = string.find, string.format
local LibStub = _G[LIBSTUB_MAJOR]

if not LibStub or LibStub.minor < LIBSTUB_MINOR then
	LibStub = LibStub or { libs = {}, minors = {} }
	_G[LIBSTUB_MAJOR] = LibStub
	LibStub.minor = LIBSTUB_MINOR
	
	function LibStub:NewLibrary(major, minor)
		assert(type(major) == "string", "Bad argument #2 to `NewLibrary' (string expected)")
		local _,_,num = strfind(minor, "(%d+)")
		minor = assert(tonumber(num), "Minor version must either be a number or contain a number.")
		
		local oldminor = self.minors[major]
		if oldminor and oldminor >= minor then return nil end
		self.minors[major], self.libs[major] = minor, self.libs[major] or {}
		return self.libs[major], oldminor
	end
	
	function LibStub:GetLibrary(major, silent)
		if not self.libs[major] and not silent then
			error(strfmt("Cannot find a library instance of %q.", tostring(major)), 2)
		end
		return self.libs[major], self.minors[major]
	end
	
	function LibStub:IterateLibraries() return pairs(self.libs) end
	setmetatable(LibStub, { __call = LibStub.GetLibrary })
end
```

### `libs/AceCore-3.0.lua`

```lua name=libs/AceCore-3.0.lua
local ACECORE_MAJOR, ACECORE_MINOR = "AceCore-3.0", 2
local AceCore, oldminor = LibStub:NewLibrary(ACECORE_MAJOR, ACECORE_MINOR)

if not AceCore then return end -- No upgrade needed

AceCore._G = AceCore._G or getfenv()
local _G = AceCore._G
local strsub, strgsub, strfind = string.sub, string.gsub, string.find
local tremove, tconcat = table.remove, table.concat
local tgetn, tsetn = table.getn, table.setn

local new, del
do
local list = setmetatable({}, {__mode = "k"})
function new()
	local t = next(list)
	if not t then
		return {}
	end
	list[t] = nil
	return t
end

function del(t)
	setmetatable(t, nil)
	for k in pairs(t) do
		t[k] = nil
	end
	tsetn(t,0)
	list[t] = true
end

print = print or function(text)
	DEFAULT_CHAT_FRAME:AddMessage(text)
end

-- debug
function AceCore.listcount()
	local count = 0
	for k in list do
		count = count + 1
	end
	return count
end
end	-- AceCore.new, AceCore.del
AceCore.new, AceCore.del = new, del

local function errorhandler(err)
	return geterrorhandler()(err)
end
AceCore.errorhandler = errorhandler

local function CreateSafeDispatcher(argCount)
	local code = [[
		local errorhandler = LibStub("AceCore-3.0").errorhandler
		local method, UP_ARGS
		local function call()
			local func, ARGS = method, UP_ARGS
			method, UP_ARGS = nil, NILS
			return func(ARGS)
		end
		return function(func, ARGS)
			method, UP_ARGS = func, ARGS
			return xpcall(call, errorhandler)
		end
	]]
	local c = 4*argCount-1
	local s = "b01,b02,b03,b04,b05,b06,b07,b08,b09,b10,b11,b12,b13,b14,b15,b16,b17,b18,b19,b20"
	code = strgsub(code, "UP_ARGS", string.sub(s,1,c))
	s = "a01,a02,a03,a04,a05,a06,a07,a08,a09,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20"
	code = strgsub(code, "ARGS", string.sub(s,1,c))
	s = "nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil"
	code = strgsub(code, "NILS", string.sub(s,1,c))
	return assert(loadstring(code, "safecall SafeDispatcher["..tostring(argCount).."]"))()
end

local SafeDispatchers = setmetatable({}, {__index=function(self, argCount)
	local dispatcher
	if not tonumber(argCount) then dbg(debugstack()) end
	if argCount > 0 then
		dispatcher = CreateSafeDispatcher(argCount)
	else
		dispatcher = function(func) return xpcall(func,errorhandler) end
	end
	rawset(self, argCount, dispatcher)
	return dispatcher
end})

local function safecall(func,argc,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
	-- we check to see if the func is passed is actually a function here and don't error when it isn't
	-- this safecall is used for optional functions like OnInitialize OnEnable etc. When they are not
	-- present execution should continue without hinderance
	if type(func) == "function" then
		return SafeDispatchers[argc](func,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
	end
end
AceCore.safecall = safecall

local function CreateDispatcher(argCount)
	local code = [[
		return function(func,ARGS)
			return func(ARGS)
		end
	]]
	local s = "a01,a02,a03,a04,a05,a06,a07,a08,a09,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20"
	code = strgsub(code, "ARGS", string.sub(s,1,4*argCount-1))
	return assert(loadstring(code, "call Dispatcher["..tostring(argCount).."]"))()
end

AceCore.Dispatchers = setmetatable({}, {__index=function(self, argCount)
	local dispatcher
	if argCount > 0 then
		dispatcher = CreateDispatcher(argCount)
	else
		dispatcher = function(func) return func() end
	end
	rawset(self, argCount, dispatcher)
	return dispatcher
end})

-- some string functions
-- vanilla available string operations:
--    sub, gfind, rep, gsub, char, dump, find, upper, len, format, byte, lower
-- we will just replace every string.match with string.find in the code
function AceCore.strtrim(s)
	return strgsub(s, "^%s*(.-)%s*$", "%1")
end

local function strsplit(delim, s, n)
	if n and n < 2 then return s end
	beg = beg or 1
	local i,j = string.find(s,delim,beg)
	if not i then
		return s, nil
	end
	return string.sub(s,1,j-1), strsplit(delim, string.sub(s,j+1), n and n-1 or nil)
end
AceCore.strsplit = strsplit

-- Ace3v: fonctions copied from AceHook-2.1
local protFuncs = {
	CameraOrSelectOrMoveStart = true, 	CameraOrSelectOrMoveStop = true,
	TurnOrActionStart = true,			TurnOrActionStop = true,
	PitchUpStart = true,				PitchUpStop = true,
	PitchDownStart = true,				PitchDownStop = true,
	MoveBackwardStart = true,			MoveBackwardStop = true,
	MoveForwardStart = true,			MoveForwardStop = true,
	Jump = true,						StrafeLeftStart = true,
	StrafeLeftStop = true,				StrafeRightStart = true,
	StrafeRightStop = true,				ToggleMouseMove = true,
	ToggleRun = true,					TurnLeftStart = true,
	TurnLeftStop = true,				TurnRightStart = true,
	TurnRightStop = true,
}

local function issecurevariable(x)
	return protFuncs[x] and 1 or nil
end
AceCore.issecurevariable = issecurevariable

local function hooksecurefunc(arg1, arg2, arg3)
	if type(arg1) == "string" then
		arg1, arg2, arg3 = _G, arg1, arg2
	end
	local orig = arg1[arg2]
	if type(orig) ~= "function" then
		error("The function "..arg2.." does not exist", 2)
	end
	arg1[arg2] = function(...)
		local tmp = {orig(unpack(arg))}
		arg3(unpack(arg))
		return unpack(tmp)
	end
end
AceCore.hooksecurefunc = hooksecurefunc

-- pickfirstset() - picks the first non-nil value and returns it
local function pickfirstset(argc,a1,a2,a3,a4,a5,a6,a7,a8,a9,a10)
	if (argc <= 1) or (a1 ~= nil) then
		return a1
	else
		return pickfirstset(argc-1,a2,a3,a4,a5,a6,a7,a8,a9,a10)
	end
end
AceCore.pickfirstset = pickfirstset

local function countargs(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10)
	if (a1 == nil) then return 0 end
	return 1 + countargs(a2,a3,a4,a5,a6,a7,a8,a9,a10)
end
AceCore.countargs = countargs

-- wipe preserves metatable
function AceCore.wipe(t)
	for k,v in pairs(t) do t[k] = nil end
	tsetn(t,0)
	return t
end

function AceCore.truncate(t,e)
	e = e or tgetn(t)
	for i=1,e do
		if t[i] == nil then
			tsetn(t,i-1)
			return
		end
	end
	tsetn(t,e)
end
```

### `libs/CallbackHandler-1.0.lua`

```lua name=libs/CallbackHandler-1.0.lua
--[[ $Id: CallbackHandler-1.0.lua 1131 2015-06-04 07:29:24Z nevcairiel $ ]]
local MAJOR, MINOR = "CallbackHandler-1.0", 6
local CallbackHandler = LibStub:NewLibrary(MAJOR, MINOR)

if not CallbackHandler then return end -- No upgrade needed

-- Lua APIs
local tconcat, tinsert, tgetn, tsetn = table.concat, table.insert, table.getn, table.setn
local assert, error, loadstring = assert, error, loadstring
local setmetatable, rawset, rawget = setmetatable, rawset, rawget
local next, pairs, type, tostring = next, pairs, type, tostring
local strgsub = string.gsub

local new, del
do
local list = setmetatable({}, {__mode = "k"})
function new()
	local t = next(list)
	if not t then
		return {}
	end
	list[t] = nil
	return t
end

function del(t)
	setmetatable(t, nil)
	for k in pairs(t) do
		t[k] = nil
	end
	tsetn(t,0)
	list[t] = true
end
end

local meta = {__index = function(tbl, key) rawset(tbl, key, new()) return tbl[key] end}

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: geterrorhandler

local function errorhandler(err)
	return geterrorhandler()(err)
end
CallbackHandler.errorhandler = errorhandler

local function CreateDispatcher(argCount)
	local code = [[
		local xpcall, errorhandler = xpcall, LibStub("CallbackHandler-1.0").errorhandler
		local method, UP_ARGS
		local function call()
			local func, ARGS = method, UP_ARGS
			method, UP_ARGS = nil, NILS
			return func(ARGS)
		end
		return function(handlers, ARGS)
			local index
			index, method = next(handlers)
			if not method then return end
			repeat
				UP_ARGS = ARGS
				xpcall(call, errorhandler)
				index, method = next(handlers, index)
			until not method
		end
	]]
	local c = 4*argCount-1
	local s = "b01,b02,b03,b04,b05,b06,b07,b08,b09,b10"
	code = strgsub(code, "UP_ARGS", string.sub(s,1,c))
	s = "a01,a02,a03,a04,a05,a06,a07,a08,a09,a10"
	code = strgsub(code, "ARGS", string.sub(s,1,c))
	s = "nil,nil,nil,nil,nil,nil,nil,nil,nil,nil"
	code = strgsub(code, "NILS", string.sub(s,1,c))
	return assert(loadstring(code, "safecall Dispatcher["..tostring(argCount).."]"))()
end

local Dispatchers = setmetatable({}, {__index=function(self, argCount)
	local dispatcher = CreateDispatcher(argCount)
	rawset(self, argCount, dispatcher)
	return dispatcher
end})

--------------------------------------------------------------------------
-- CallbackHandler:New
--
--   target            - target object to embed public APIs in
--   RegisterName      - name of the callback registration API, default "RegisterCallback"
--   UnregisterName    - name of the callback unregistration API, default "UnregisterCallback"
--   UnregisterAllName - name of the API to unregister all callbacks, default "UnregisterAllCallbacks". false == don't publish this API.
function CallbackHandler:New(target, RegisterName, UnregisterName, UnregisterAllName)

	RegisterName = RegisterName or "RegisterCallback"
	UnregisterName = UnregisterName or "UnregisterCallback"
	if UnregisterAllName==nil then	-- false is used to indicate "don't want this method"
		UnregisterAllName = "UnregisterAllCallbacks"
	end

	-- we declare all objects and exported APIs inside this closure to quickly gain access
	-- to e.g. function names, the "target" parameter, etc


	-- Create the registry object
	local events = setmetatable({}, meta)
	local registry = { recurse=0, events=events }

	-- registry:Fire() - fires the given event/message into the registry
	function registry:Fire(eventname, argc, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
		if not rawget(events, eventname) or not next(events[eventname]) then return end
		local oldrecurse = registry.recurse
		registry.recurse = oldrecurse + 1

		argc = argc or 0
		Dispatchers[argc+1](events[eventname], eventname, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)

		registry.recurse = oldrecurse

		if registry.insertQueue and oldrecurse==0 then
			-- Something in one of our callbacks wanted to register more callbacks; they got queued
			for eventname,callbacks in pairs(registry.insertQueue) do
				local first = not rawget(events, eventname) or not next(events[eventname])	-- test for empty before. not test for one member after. that one member may have been overwritten.
				for self,func in pairs(callbacks) do
					events[eventname][self] = func
					-- fire OnUsed callback?
					if first and registry.OnUsed then
						registry.OnUsed(registry, target, eventname)
						first = nil
					end
				end
				del(callbacks)
			end
			del(registry.insertQueue)
			registry.insertQueue = nil
		end
	end

	-- Registration of a callback, handles:
	--   self["method"], leads to self["method"](self, ...)
	--   self with function ref, leads to functionref(...)
	--   "addonId" (instead of self) with function ref, leads to functionref(...)
	-- all with an optional arg, which, if present, gets passed as first argument (after self if present)
	target[RegisterName] = function(self, eventname, method, ...)
		if type(eventname) ~= "string" then
			error("Usage: "..RegisterName.."(eventname, method[, arg]): 'eventname' - string expected.", 2)
		end

		method = method or eventname

		local first = not rawget(events, eventname) or not next(events[eventname])	-- test for empty before. not test for one member after. that one member may have been overwritten.

		if type(method) ~= "string" and type(method) ~= "function" then
			error("Usage: "..RegisterName.."(eventname, method[, arg]): 'method' - string or function expected.", 2)
		end

		local regfunc
		local a1 = arg[1]

		if type(method) == "string" then
			-- self["method"] calling style
			if type(self) ~= "table" then
				error("Usage: "..RegisterName.."(eventname, method[, arg]): self was not a table?", 2)
			elseif self==target then
				error("Usage: "..RegisterName.."(eventname, method[, arg]): do not use Library:"..RegisterName.."(), use your own 'self'.", 2)
			elseif type(self[method]) ~= "function" then
				error("Usage: "..RegisterName.."(eventname, method[, arg]): 'method' - method '"..tostring(method).."' not found on 'self'.", 2)
			end

			if tgetn(arg) >= 1 then
				regfunc = function (...) return self[method](self,a1,unpack(arg)) end
			else
				regfunc = function (...) return self[method](self,unpack(arg)) end
			end
		else
			-- function ref with self=object or self="addonId"
			if type(self)~="table" and type(self)~="string" then
				error("Usage: "..RegisterName.."(self or addonId, eventname, method[, arg]): 'self or addonId': table or string expected.", 2)
			end

			if tgetn(arg) >= 1 then
				regfunc = function (...) return method(a1, unpack(arg)) end
			else
				regfunc = method
			end
		end


		if events[eventname][self] or registry.recurse<1 then
		-- if registry.recurse<1 then
			-- we're overwriting an existing entry, or not currently recursing. just set it.
			events[eventname][self] = regfunc
			-- fire OnUsed callback?
			if registry.OnUsed and first then
				registry.OnUsed(registry, target, eventname)
			end
		else
			-- we're currently processing a callback in this registry, so delay the registration of this new entry!
			-- yes, we're a bit wasteful on garbage, but this is a fringe case, so we're picking low implementation overhead over garbage efficiency
			registry.insertQueue = registry.insertQueue or setmetatable(new(),meta)
			registry.insertQueue[eventname][self] = regfunc
		end
	end

	-- Unregister a callback
	target[UnregisterName] = function(self, eventname)
		if not self or self==target then
			error("Usage: "..UnregisterName.."(eventname): bad 'self'", 2)
		end
		if type(eventname) ~= "string" then
			error("Usage: "..UnregisterName.."(eventname): 'eventname' - string expected.", 2)
		end
		if rawget(events, eventname) and events[eventname][self] then
			events[eventname][self] = nil

			-- Fire OnUnused callback?
			if registry.OnUnused and not next(events[eventname]) then
				registry.OnUnused(registry, target, eventname)
			end

			if rawget(events, eventname) and not next(events[eventname]) then
				del(events[eventname])
				events[eventname] = nil
			end
		end
		if registry.insertQueue and rawget(registry.insertQueue, eventname) and registry.insertQueue[eventname][self] then
			registry.insertQueue[eventname][self] = nil
		end
	end

	-- OPTIONAL: Unregister all callbacks for given selfs/addonIds
	if UnregisterAllName then
		target[UnregisterAllName] = function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10)
			if not a1 then
				error("Usage: "..UnregisterAllName.."([whatFor]): missing 'self' or 'addonId' to unregister events for.", 2)
			end
			if a1 == target then
				error("Usage: "..UnregisterAllName.."([whatFor]): supply a meaningful 'self' or 'addonId'", 2)
			end

			-- use our registry table as argument table
			registry[1] = a1
			registry[2] = a2
			registry[3] = a3
			registry[4] = a4
			registry[5] = a5
			registry[6] = a6
			registry[7] = a7
			registry[8] = a8
			registry[9] = a9
			registry[10] = a10
			for i=1,10 do
				local self = registry[i]
				registry[i] = nil
				if self then
					if registry.insertQueue then
						for eventname, callbacks in pairs(registry.insertQueue) do
							if callbacks[self] then
								callbacks[self] = nil
							end
						end
					end
					for eventname, callbacks in pairs(events) do
						if callbacks[self] then
							callbacks[self] = nil
							-- Fire OnUnused callback?
							if registry.OnUnused and not next(callbacks) then
								registry.OnUnused(registry, target, eventname)
							end
						end
					end
				end
			end
		end
	end

	return registry
end

-- CallbackHandler purposefully does NOT do explicit embedding. Nor does it
-- try to upgrade old implicit embeds since the system is selfcontained and
-- relies on closures to work.
```

### `libs/AceHook-3.0.lua`

```lua name=libs/AceHook-3.0.lua
--- **AceHook-3.0** offers safe Hooking/Unhooking of functions, methods and frame scripts.
-- Using AceHook-3.0 is recommended when you need to unhook your hooks again, so the hook chain isn't broken
-- when you manually restore the original function.
--
-- **AceHook-3.0** can be embeded into your addon, either explicitly by calling AceHook:Embed(MyAddon) or by
-- specifying it as an embeded library in your AceAddon. All functions will be available on your addon object
-- and can be accessed directly, without having to explicitly call AceHook itself.\\
-- It is recommended to embed AceHook, otherwise you'll have to specify a custom `self` on all calls you
-- make into AceHook.
-- @class file
-- @name AceHook-3.0
-- @release $Id: AceHook-3.0.lua 1118 2014-10-12 08:21:54Z nevcairiel $
local ACEHOOK_MAJOR, ACEHOOK_MINOR = "AceHook-3.0", 8
local AceHook, oldminor = LibStub:NewLibrary(ACEHOOK_MAJOR, ACEHOOK_MINOR)

if not AceHook then return end -- No upgrade needed

local AceCore = LibStub("AceCore-3.0")
local new, del = AceCore.new, AceCore.del

AceHook.embeded = AceHook.embeded or {}
AceHook.registry = AceHook.registry or setmetatable({}, {__index = function(tbl, key) tbl[key] = {} return tbl[key] end })
AceHook.handlers = AceHook.handlers or {}
AceHook.actives = AceHook.actives or {}
AceHook.scripts = AceHook.scripts or {}
AceHook.onceSecure = AceHook.onceSecure or {}
AceHook.hooks = AceHook.hooks or {}

-- local upvalues
local registry = AceHook.registry
local handlers = AceHook.handlers
local actives = AceHook.actives
local scripts = AceHook.scripts
local onceSecure = AceHook.onceSecure

-- Lua APIs
local pairs, next, type = pairs, next, type
local format = string.format
local assert, error = assert, error

-- WoW APIs
local hooksecurefunc, issecurevariable = AceCore.hooksecurefunc, AceCore.issecurevariable

local _G = AceCore._G

local protectedScripts = {
	OnClick = true,
}

-- upgrading of embeded is done at the bottom of the file

local mixins = {
	"Hook", "SecureHook",
	"HookScript", "SecureHookScript",
	"Unhook", "UnhookAll",
	"IsHooked",
	"RawHook", "RawHookScript"
}

-- AceHook:Embed( target )
-- target (object) - target object to embed AceHook in
--
-- Embeds AceEevent into the target object making the functions from the mixins list available on target:..
function AceHook:Embed( target )
	for k, v in pairs( mixins ) do
		target[v] = self[v]
	end
	self.embeded[target] = true
	-- inject the hooks table safely
	target.hooks = target.hooks or {}
	return target
end

-- AceHook:OnEmbedDisable( target )
-- target (object) - target object that is being disabled
--
-- Unhooks all hooks when the target disables.
-- this method should be called by the target manually or by an addon framework
function AceHook:OnEmbedDisable( target )
	target:UnhookAll()
end

-- failsafe means even the hooking method fails, the original method will
-- always be called
local function createHook(self, handler, orig, secure, failsafe)
	local uid
	local method = type(handler) == "string"
	-- Ace3v: when this function called in the "hook" function, we have
	--        failsafe = not (raw or secure), so the first check condition
	--        is same as "if failsafe" or "if not raw and not secure"
	if failsafe and not secure then
		-- failsafe hook creation
		uid = function(...)
			if actives[uid] then
				if method then
					self[handler](self,unpack(arg))
				else
					handler(unpack(arg))
				end
			end
			return orig(unpack(arg))
		end
		-- /failsafe hook
	else
		-- all other hooks
		uid = function(...)
			if actives[uid] then
				if method then
					return self[handler](self,unpack(arg))
				else
					return handler(unpack(arg))
				end
			elseif not secure then -- backup on non secure
				return orig(unpack(arg))
			end
		end
		-- /hook
	end
	return uid
end

local function donothing() end

-- @param self
-- @param obj			nil or a frame object, use with script = true
-- @param method		string, the name of a global function or the name of an object method
-- @param handler		function, or string when it's a method of 'self', if nil then will use the same value as method
-- @param script		boolean, must be true, if the hooked object is a frame
-- @param secure		boolean, if hooking a secure script, if true the original script will be called first, else later
-- @param raw			boolean, if raw hooking (replacing the original method)
-- @param forceSecure	boolean, if forcing to hook a secure method
-- @param usage
local function hook(self, obj, method, handler, script, secure, raw, forceSecure, usage)
	if not handler then handler = method end

	-- These asserts make sure AceHooks's devs play by the rules.
	assert(not script or type(script) == "boolean")
	assert(not secure or type(secure) == "boolean")
	assert(not raw or type(raw) == "boolean")
	assert(not forceSecure or type(forceSecure) == "boolean")
	assert(usage)

	-- Error checking Battery!
	if obj and type(obj) ~= "table" then
		error(format("%s: 'object' - nil or table expected got %s", usage, type(obj)), 3)
	end
	if type(method) ~= "string" then
		error(format("%s: 'method' - string expected got %s", usage, type(method)), 3)
	end
	if type(handler) ~= "string" and type(handler) ~= "function" then
		error(format("%s: 'handler' - nil, string, or function expected got %s", usage, type(handler)), 3)
	end
	if type(handler) == "string" and type(self[handler]) ~= "function" then
		error(format("%s: 'handler' - Handler specified does not exist at self[handler]", usage), 3)
	end
	if script then
		if not obj or not obj.GetScript or not obj:HasScript(method) then
			error(format("%s: You can only hook a script on a frame object", usage), 3)
		end
		if not secure and obj.IsProtected and obj:IsProtected() and protectedScripts[method] then
			error(format("Cannot hook secure script %q; Use SecureHookScript(obj, method, [handler]) instead.", method), 3)
		end
	else
		local issecure
		if obj then
			issecure = onceSecure[obj] and onceSecure[obj][method] or issecurevariable(obj, method)
		else
			issecure = onceSecure[method] or issecurevariable(method)
		end
		if issecure then
			if forceSecure then
				if obj then
					onceSecure[obj] = onceSecure[obj] or {}
					onceSecure[obj][method] = true
				else
					onceSecure[method] = true
				end
			elseif not secure then
				error(format("%s: Attempt to hook secure function %s. Use `SecureHook' or add `true' to the argument list to override.", usage, method), 3)
			end
		end
	end

	local uid
	if obj then
		uid = registry[self][obj] and registry[self][obj][method]
	else
		uid = registry[self][method]
	end

	if uid then
		if actives[uid] then
			-- Only two sane choices exist here.  We either a) error 100% of the time or b) always unhook and then hook
			-- choice b would likely lead to odd debuging conditions or other mysteries so we're going with a.
			error(format("Attempting to rehook already active hook %s.", method))
		end

		if handlers[uid] == handler then -- turn on a decative hook, note enclosures break this ability, small memory leak
			actives[uid] = true
			return
		elseif obj then -- is there any reason not to call unhook instead of doing the following several lines?
			if self.hooks and self.hooks[obj] then
				self.hooks[obj][method] = nil
			end
			registry[self][obj][method] = nil
		else
			if self.hooks then
				self.hooks[method] = nil
			end
			registry[self][method] = nil
		end
		handlers[uid], actives[uid], scripts[uid] = nil, nil, nil
		uid = nil
	end

	local orig
	if script then
		-- Sometimes there is not a original function for a script.
		orig = obj:GetScript(method) or donothing
	elseif obj then
		orig = obj[method]
	else
		orig = _G[method]
	end

	if not orig then
		error(format("%s: Attempting to hook a non existing target", usage), 3)
	end

	uid = createHook(self, handler, orig, secure, not (raw or secure))

	if obj then
		registry[self][obj] = registry[self][obj] or new()
		registry[self][obj][method] = uid

		if not secure then
			self.hooks[obj] = self.hooks[obj] or new()
			self.hooks[obj][method] = orig
		end

		if script then
			if not secure then
				obj:SetScript(method, uid)
			else
				obj:SetScript(method, function(...)
					local tmp = {orig(unpack(arg))}
					uid(unpack(arg))
					return unpack(tmp)
				end)
				--obj:HookScript(method, uid)	-- Ace3v: vanilla frame has no HookScript
			end
		else
			if not secure then
				obj[method] = uid
			else
				hooksecurefunc(obj, method, uid)
			end
		end
	else
		registry[self][method] = uid

		if not secure then
			_G[method] = uid
			self.hooks[method] = orig
		else
			hooksecurefunc(method, uid)
		end
	end

	actives[uid], handlers[uid], scripts[uid] = true, handler, script and true or nil
end

--- Hook a function or a method on an object.
-- The hook created will be a "safe hook", that means that your handler will be called
-- before the hooked function ("Pre-Hook"), and you don't have to call the original function yourself,
-- however you cannot stop the execution of the function, or modify any of the arguments/return values.\\
-- This type of hook is typically used if you need to know if some function got called, and don't want to modify it.
-- @paramsig [object], method, [handler], [hookSecure]
-- @param object The object to hook a method from
-- @param method If object was specified, the name of the method, or the name of the function to hook.
-- @param handler The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked function)
-- @param hookSecure If true, AceHook will allow hooking of secure functions.
-- @usage
-- -- create an addon with AceHook embeded
-- MyAddon = LibStub("AceAddon-3.0"):NewAddon("HookDemo", "AceHook-3.0")
--
-- function MyAddon:OnEnable()
--   -- Hook ActionButton_UpdateHotkeys, overwriting the secure status
--   self:Hook("ActionButton_UpdateHotkeys", true)
-- end
--
-- function MyAddon:ActionButton_UpdateHotkeys(button, type)
--   print(button:GetName() .. " is updating its HotKey")
-- end
function AceHook:Hook(object, method, handler, hookSecure)
	if type(object) == "string" then
		method, handler, hookSecure, object = object, method, handler, nil
	end

	if handler == true then
		handler, hookSecure = nil, true
	end

	hook(self, object, method, handler, false, false, false, hookSecure or false, "Usage: Hook([object], method, [handler], [hookSecure])")
end

--- RawHook a function or a method on an object.
-- The hook created will be a "raw hook", that means that your handler will completly replace
-- the original function, and your handler has to call the original function (or not, depending on your intentions).\\
-- The original function will be stored in `self.hooks[object][method]` or `self.hooks[functionName]` respectively.\\
-- This type of hook can be used for all purposes, and is usually the most common case when you need to modify arguments
-- or want to control execution of the original function.
-- @paramsig [object], method, [handler], [hookSecure]
-- @param object The object to hook a method from
-- @param method If object was specified, the name of the method, or the name of the function to hook.
-- @param handler The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked function)
-- @param hookSecure If true, AceHook will allow hooking of secure functions.
-- @usage
-- -- create an addon with AceHook embeded
-- MyAddon = LibStub("AceAddon-3.0"):NewAddon("HookDemo", "AceHook-3.0")
--
-- function MyAddon:OnEnable()
--   -- Hook ActionButton_UpdateHotkeys, overwriting the secure status
--   self:RawHook("ActionButton_UpdateHotkeys", true)
-- end
--
-- function MyAddon:ActionButton_UpdateHotkeys(button, type)
--   if button:GetName() == "MyButton" then
--     -- do stuff here
--   else
--     self.hooks.ActionButton_UpdateHotkeys(button, type)
--   end
-- end
function AceHook:RawHook(object, method, handler, hookSecure)
	if type(object) == "string" then
		method, handler, hookSecure, object = object, method, handler, nil
	end

	if handler == true then
		handler, hookSecure = nil, true
	end

	hook(self, object, method, handler, false, false, true, hookSecure or false,  "Usage: RawHook([object], method, [handler], [hookSecure])")
end

--- SecureHook a function or a method on an object.
-- This function is a wrapper around the `hooksecurefunc` function in the WoW API. Using AceHook
-- extends the functionality of secure hooks, and adds the ability to unhook once the hook isn't
-- required anymore, or the addon is being disabled.\\
-- Secure Hooks should be used if the secure-status of the function is vital to its function,
-- and taint would block execution. Secure Hooks are always called after the original function was called
-- ("Post Hook"), and you cannot modify the arguments, return values or control the execution.
-- @paramsig [object], method, [handler]
-- @param object The object to hook a method from
-- @param method If object was specified, the name of the method, or the name of the function to hook.
-- @param handler The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked function)
function AceHook:SecureHook(object, method, handler)
	if type(object) == "string" then
		method, handler, object = object, method, nil
	end

	hook(self, object, method, handler, false, true, false, false,  "Usage: SecureHook([object], method, [handler])")
end

--- Hook a script handler on a frame.
-- The hook created will be a "safe hook", that means that your handler will be called
-- before the hooked script ("Pre-Hook"), and you don't have to call the original function yourself,
-- however you cannot stop the execution of the function, or modify any of the arguments/return values.\\
-- This is the frame script equivalent of the :Hook safe-hook. It would typically be used to be notified
-- when a certain event happens to a frame.
-- @paramsig frame, script, [handler]
-- @param frame The Frame to hook the script on
-- @param script The script to hook
-- @param handler The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked script)
-- @usage
-- -- create an addon with AceHook embeded
-- MyAddon = LibStub("AceAddon-3.0"):NewAddon("HookDemo", "AceHook-3.0")
--
-- function MyAddon:OnEnable()
--   -- Hook the OnShow of FriendsFrame
--   self:HookScript(FriendsFrame, "OnShow", "FriendsFrameOnShow")
-- end
--
-- function MyAddon:FriendsFrameOnShow(frame)
--   print("The FriendsFrame was shown!")
-- end
function AceHook:HookScript(frame, script, handler)
	hook(self, frame, script, handler, true, false, false, false,  "Usage: HookScript(object, method, [handler])")
end

--- RawHook a script handler on a frame.
-- The hook created will be a "raw hook", that means that your handler will completly replace
-- the original script, and your handler has to call the original script (or not, depending on your intentions).\\
-- The original script will be stored in `self.hooks[frame][script]`.\\
-- This type of hook can be used for all purposes, and is usually the most common case when you need to modify arguments
-- or want to control execution of the original script.
-- @paramsig frame, script, [handler]
-- @param frame The Frame to hook the script on
-- @param script The script to hook
-- @param handler The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked script)
-- @usage
-- -- create an addon with AceHook embeded
-- MyAddon = LibStub("AceAddon-3.0"):NewAddon("HookDemo", "AceHook-3.0")
--
-- function MyAddon:OnEnable()
--   -- Hook the OnShow of FriendsFrame
--   self:RawHookScript(FriendsFrame, "OnShow", "FriendsFrameOnShow")
-- end
--
-- function MyAddon:FriendsFrameOnShow(frame)
--   -- Call the original function
--   self.hooks[frame].OnShow(frame)
--   -- Do our processing
--   -- .. stuff
-- end
function AceHook:RawHookScript(frame, script, handler)
	hook(self, frame, script, handler, true, false, true, false, "Usage: RawHookScript(object, method, [handler])")
end

--- SecureHook a script handler on a frame.
-- This function is a wrapper around the `frame:HookScript` function in the WoW API. Using AceHook
-- extends the functionality of secure hooks, and adds the ability to unhook once the hook isn't
-- required anymore, or the addon is being disabled.\\
-- Secure Hooks should be used if the secure-status of the function is vital to its function,
-- and taint would block execution. Secure Hooks are always called after the original function was called
-- ("Post Hook"), and you cannot modify the arguments, return values or control the execution.
-- @paramsig frame, script, [handler]
-- @param frame The Frame to hook the script on
-- @param script The script to hook
-- @param handler The handler for the hook, a funcref or a method name. (Defaults to the name of the hooked script)
function AceHook:SecureHookScript(frame, script, handler)
	hook(self, frame, script, handler, true, true, false, false, "Usage: SecureHookScript(object, method, [handler])")
end

--- Unhook from the specified function, method or script.
-- @paramsig [obj], method
-- @param obj The object or frame to unhook from
-- @param method The name of the method, function or script to unhook from.
function AceHook:Unhook(obj, method)
	local usage = "Usage: Unhook([obj], method)"
	if type(obj) == "string" then
		method, obj = obj, nil
	end

	if obj and type(obj) ~= "table" then
		error(format("%s: 'obj' - expecting nil or table got %s", usage, type(obj)), 2)
	end
	if type(method) ~= "string" then
		error(format("%s: 'method' - expeting string got %s", usage, type(method)), 2)
	end

	local uid
	if obj then
		uid = registry[self][obj] and registry[self][obj][method]
	else
		uid = registry[self][method]
	end

	if not uid or not actives[uid] then
		-- Declining to error on an unneeded unhook since the end effect is the same and this would just be annoying.
		return false
	end

	actives[uid], handlers[uid] = nil, nil

	if obj then
		local tmp = registry[self][obj]
		tmp[method] = nil
		if not next(tmp) then
			del(tmp)
			registry[self][obj] = nil
		end

		-- if the hook reference doesnt exist, then its a secure hook, just bail out and dont do any unhooking
		if not self.hooks[obj] or not self.hooks[obj][method] then return true end

		if scripts[uid] and obj:GetScript(method) == uid then  -- unhooks scripts
			obj:SetScript(method, self.hooks[obj][method] ~= donothing and self.hooks[obj][method] or nil)
			scripts[uid] = nil
		elseif obj and self.hooks[obj] and self.hooks[obj][method] and obj[method] == uid then -- unhooks methods
			obj[method] = self.hooks[obj][method]
		end

		tmp = self.hooks[obj]
		tmp[method] = nil
		if not next(tmp) then
			del(tmp)
			self.hooks[obj] = nil
		end
	else
		registry[self][method] = nil

		-- if self.hooks[method] doesn't exist, then this is a SecureHook, just bail out
		if not self.hooks[method] then return true end

		if self.hooks[method] and _G[method] == uid then -- unhooks functions
			_G[method] = self.hooks[method]
		end

		self.hooks[method] = nil
	end
	return true
end

--- Unhook all existing hooks for this addon.
function AceHook:UnhookAll()
	for key, value in pairs(registry[self]) do
		if type(key) == "table" then
			for method in pairs(value) do
				self:Unhook(key, method)
			end
		else
			self:Unhook(key)
		end
	end
end

--- Check if the specific function, method or script is already hooked.
-- @paramsig [obj], method
-- @param obj The object or frame to unhook from
-- @param method The name of the method, function or script to unhook from.
function AceHook:IsHooked(obj, method)
	-- we don't check if registry[self] exists, this is done by evil magicks in the metatable
	if type(obj) == "string" then
		if registry[self][obj] and actives[registry[self][obj]] then
			return true, handlers[registry[self][obj]]
		end
	else
		if registry[self][obj] and registry[self][obj][method] and actives[registry[self][obj][method]] then
			return true, handlers[registry[self][obj][method]]
		end
	end

	return false, nil
end

--- Upgrade our old embeded
for target, v in pairs( AceHook.embeded ) do
	AceHook:Embed( target )
end
```

### `libs/LibDataBroker-1.1.lua`

```lua name=libs/LibDataBroker-1.1.lua

assert(LibStub, "LibDataBroker-1.1 requires LibStub")
assert(LibStub:GetLibrary("CallbackHandler-1.0", true), "LibDataBroker-1.1 requires CallbackHandler-1.0")

local lib, oldminor = LibStub:NewLibrary("LibDataBroker-1.1", 4)
if not lib then return end
oldminor = oldminor or 0


lib.callbacks = lib.callbacks or LibStub:GetLibrary("CallbackHandler-1.0"):New(lib)
lib.attributestorage, lib.namestorage, lib.proxystorage = lib.attributestorage or {}, lib.namestorage or {}, lib.proxystorage or {}
local attributestorage, namestorage, callbacks = lib.attributestorage, lib.namestorage, lib.callbacks

if oldminor < 2 then
	lib.domt = {
		__metatable = "access denied",
		__index = function(self, key) return attributestorage[self] and attributestorage[self][key] end,
	}
end

if oldminor < 3 then
	lib.domt.__newindex = function(self, key, value)
		if not attributestorage[self] then attributestorage[self] = {} end
		if attributestorage[self][key] == value then return end
		attributestorage[self][key] = value
		local name = namestorage[self]
		if not name then return end
		callbacks:Fire("LibDataBroker_AttributeChanged", name, key, value, self)
		callbacks:Fire("LibDataBroker_AttributeChanged_"..name, name, key, value, self)
		callbacks:Fire("LibDataBroker_AttributeChanged_"..name.."_"..key, name, key, value, self)
		callbacks:Fire("LibDataBroker_AttributeChanged__"..key, name, key, value, self)
	end
end

if oldminor < 2 then
	function lib:NewDataObject(name, dataobj)
		if self.proxystorage[name] then return end

		if dataobj then
			assert(type(dataobj) == "table", "Invalid dataobj, must be nil or a table")
			self.attributestorage[dataobj] = {}
			for i,v in pairs(dataobj) do
				self.attributestorage[dataobj][i] = v
				dataobj[i] = nil
			end
		end
		dataobj = setmetatable(dataobj or {}, self.domt)
		self.proxystorage[name], self.namestorage[dataobj] = dataobj, name
		self.callbacks:Fire("LibDataBroker_DataObjectCreated", name, dataobj)
		return dataobj
	end
end

if oldminor < 1 then
	function lib:DataObjectIterator()
		return pairs(self.proxystorage)
	end

	function lib:GetDataObjectByName(dataobjectname)
		return self.proxystorage[dataobjectname]
	end

	function lib:GetNameByDataObject(dataobject)
		return self.namestorage[dataobject]
	end
end

if oldminor < 4 then
	local next = pairs(attributestorage)
	function lib:pairs(dataobject_or_name)
		local t = type(dataobject_or_name)
		assert(t == "string" or t == "table", "Usage: ldb:pairs('dataobjectname') or ldb:pairs(dataobject)")

		local dataobj = self.proxystorage[dataobject_or_name] or dataobject_or_name
		assert(attributestorage[dataobj], "Data object not found")

		return next, attributestorage[dataobj], nil
	end

	local ipairs_iter = ipairs(attributestorage)
	function lib:ipairs(dataobject_or_name)
		local t = type(dataobject_or_name)
		assert(t == "string" or t == "table", "Usage: ldb:ipairs('dataobjectname') or ldb:ipairs(dataobject)")

		local dataobj = self.proxystorage[dataobject_or_name] or dataobject_or_name
		assert(attributestorage[dataobj], "Data object not found")

		return ipairs_iter, attributestorage[dataobj], 0
	end
end
```

### `libs/LibDBIcon-1.0.lua`

```lua name=libs/LibDBIcon-1.0.lua

-----------------------------------------------------------------------
-- LibDBIcon-1.0
--
-- Allows addons to easily create a lightweight minimap icon as an alternative to heavier LDB displays.
--

local DBICON10 = "LibDBIcon-1.0"
local DBICON10_MINOR = 44 -- Bump on changes
if not LibStub then error(DBICON10 .. " requires LibStub.") end
local ldb = LibStub("LibDataBroker-1.1", true)
if not ldb then error(DBICON10 .. " requires LibDataBroker-1.1.") end
local lib = LibStub:NewLibrary(DBICON10, DBICON10_MINOR)
if not lib then return end

LibStub("AceHook-3.0"):Embed(lib)
lib.objects = lib.objects or {}
lib.callbackRegistered = lib.callbackRegistered or nil
lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
lib.notCreated = lib.notCreated or {}
lib.radius = lib.radius or 5
lib.tooltip = lib.tooltip or CreateFrame("GameTooltip", "LibDBIconTooltip", UIParent, "GameTooltipTemplate")
local next, Minimap = next, Minimap
local tgetn = table.tgetn
local isDraggingButton = false

function lib:IconCallback(event, name, key, value)
	if lib.objects[name] then
		if key == "icon" then
			lib.objects[name].icon:SetTexture(value)
		elseif key == "iconCoords" then
			lib.objects[name].icon:UpdateCoord()
		elseif key == "iconR" then
			local _, g, b = lib.objects[name].icon:GetVertexColor()
			lib.objects[name].icon:SetVertexColor(value, g, b)
		elseif key == "iconG" then
			local r, _, b = lib.objects[name].icon:GetVertexColor()
			lib.objects[name].icon:SetVertexColor(r, value, b)
		elseif key == "iconB" then
			local r, g = lib.objects[name].icon:GetVertexColor()
			lib.objects[name].icon:SetVertexColor(r, g, value)
		end
	end
end
if not lib.callbackRegistered then
	ldb.RegisterCallback(lib, "LibDataBroker_AttributeChanged__icon", "IconCallback")
	ldb.RegisterCallback(lib, "LibDataBroker_AttributeChanged__iconCoords", "IconCallback")
	ldb.RegisterCallback(lib, "LibDataBroker_AttributeChanged__iconR", "IconCallback")
	ldb.RegisterCallback(lib, "LibDataBroker_AttributeChanged__iconG", "IconCallback")
	ldb.RegisterCallback(lib, "LibDataBroker_AttributeChanged__iconB", "IconCallback")
	lib.callbackRegistered = true
end

local function getAnchors(frame)
	local x, y = frame:GetCenter()
	if not x or not y then return "CENTER" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

local function onEnter()
	if isDraggingButton then return end

	for _, button in next, lib.objects do
		if button.showOnMouseover then
			--button.fadeOut:Stop()
			button:SetAlpha(1)
		end
	end

	local obj = this.dataObject
	if obj.OnTooltipShow then
		lib.tooltip:SetOwner(this, "ANCHOR_NONE")
		lib.tooltip:SetPoint(getAnchors(this))
		obj.OnTooltipShow(lib.tooltip)
		lib.tooltip:Show()
	elseif obj.OnEnter then
		obj.OnEnter()
	end
end

local function onLeave()
	lib.tooltip:Hide()

	if not isDraggingButton then
		for _, button in next, lib.objects do
			if button.showOnMouseover then
				--button.fadeOut:Play()
			end
		end
	end

	local obj = this.dataObject
	if obj.OnLeave then
		obj.OnLeave()
	end
end

--------------------------------------------------------------------------------

local onDragStart, updatePosition

do
	local minimapShapes = {
		["ROUND"] = {true, true, true, true},
		["SQUARE"] = {false, false, false, false},
		["CORNER-TOPLEFT"] = {false, false, false, true},
		["CORNER-TOPRIGHT"] = {false, false, true, false},
		["CORNER-BOTTOMLEFT"] = {false, true, false, false},
		["CORNER-BOTTOMRIGHT"] = {true, false, false, false},
		["SIDE-LEFT"] = {false, true, false, true},
		["SIDE-RIGHT"] = {true, false, true, false},
		["SIDE-TOP"] = {false, false, true, true},
		["SIDE-BOTTOM"] = {true, true, false, false},
		["TRICORNER-TOPLEFT"] = {false, true, true, true},
		["TRICORNER-TOPRIGHT"] = {true, false, true, true},
		["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
		["TRICORNER-BOTTOMRIGHT"] = {true, true, true, false},
	}

	local rad, cos, sin, sqrt, max, min = math.rad, math.cos, math.sin, math.sqrt, math.max, math.min
	function updatePosition(button, position)
		local angle = rad(position or 225)
		local x, y, q = cos(angle), sin(angle), 1
		if x < 0 then q = q + 1 end
		if y > 0 then q = q + 2 end
		local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
		local quadTable = minimapShapes[minimapShape]
		local w = (Minimap:GetWidth() / 2) + lib.radius
		local h = (Minimap:GetHeight() / 2) + lib.radius
		if quadTable[q] then
			x, y = x*w, y*h
		else
			local diagRadiusW = sqrt(2*(w)^2)-10
			local diagRadiusH = sqrt(2*(h)^2)-10
			x = max(-w, min(x*diagRadiusW, w))
			y = max(-h, min(y*diagRadiusH, h))
		end
		button:SetPoint("CENTER", Minimap, "CENTER", x, y)
	end
end

local function onClick( )
	if this.dataObject.OnClick then
		this.dataObject.OnClick( this, arg1)
	end
end

local function onMouseDown()
	this.isMouseDown = true
	this.icon:UpdateCoord()
end

local function onMouseUp()
	this.isMouseDown = false
	this.icon:UpdateCoord()
end

local fmod = function(x, y)
    return x - math.floor(x / y) * y
end

do
	local deg, atan2 = math.deg, math.atan2
	local function onUpdate()
		local mx, my = Minimap:GetCenter()
		local px, py = GetCursorPosition()
		local scale = Minimap:GetEffectiveScale()
		px, py = px / scale, py / scale
		local pos = 225
		if this.db then
			pos = fmod(deg(atan2(py - my, px - mx)) , 360)
			this.db.minimapPos = pos
		else
			pos = fmod(deg(atan2(py - my, px - mx)) , 360)
			this.minimapPos = pos
		end
		updatePosition(this, pos)
	end

	function onDragStart()
		this:LockHighlight()
		this.isMouseDown = true
		this.icon:UpdateCoord()
		this:SetScript("OnUpdate", onUpdate)
		isDraggingButton = true
		lib.tooltip:Hide()
		for _, button in next, lib.objects do
			if button.showOnMouseover then
				--button.fadeOut:Stop()
				button:SetAlpha(1)
			end
		end
	end
end

local function onDragStop()
	this:SetScript("OnUpdate", nil)
	this.isMouseDown = false
	this.icon:UpdateCoord()
	this:UnlockHighlight()
	isDraggingButton = false
	for _, button in next, lib.objects do
		if button.showOnMouseover then
			--button.fadeOut:Play()
		end
	end
end

local defaultCoords = {0, 1, 0, 1}
local function updateCoord(self)
	local coords = self:GetParent().dataObject.iconCoords or defaultCoords
	local deltaX, deltaY = 0, 0
	if not self:GetParent().isMouseDown then
		deltaX = (coords[2] - coords[1]) * 0.05
		deltaY = (coords[4] - coords[3]) * 0.05
	end
	self:SetTexCoord(coords[1] + deltaX, coords[2] - deltaX, coords[3] + deltaY, coords[4] - deltaY)
end

local function createButton(name, object, db)
	local button = CreateFrame("Button", "LibDBIcon10_"..name, Minimap)
	button.dataObject = object
	button.db = db
	button:SetFrameStrata("MEDIUM")
	button:SetWidth(31)
	button:SetHeight(31)
	button:SetFrameLevel(8)
	button:SetFrameStrata("HIGH")
	button:SetFrameLevel(7)
	button:EnableMouse(true)
	--button:EnableMouseWheel(true)
	button:SetMovable(true)
	button:RegisterForClicks("LeftButtonUp","RightButtonUp")
	button:RegisterForDrag("LeftButton")
	button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetWidth(53)
	overlay:SetHeight(53)
	overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	overlay:SetPoint("TOPLEFT",0,0)
	local background = button:CreateTexture(nil, "BACKGROUND")
	background:SetWidth(20)
	background:SetHeight(20)
	background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
	background:SetPoint("TOPLEFT", 7, -5)
	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetWidth(17)
	icon:SetHeight(17)
	icon:SetTexture(object.icon)
	icon:SetPoint("TOPLEFT", 7, -6)
	button.icon = icon
	icon.parent = button
	button.isMouseDown = false

	local r, g, b = icon:GetVertexColor()
	icon:SetVertexColor(object.iconR or r, object.iconG or g, object.iconB or b)

	icon.UpdateCoord = updateCoord
	icon:UpdateCoord()

	button:SetScript("OnEnter", onEnter)
	button:SetScript("OnLeave", onLeave)
	button:SetScript("OnClick",  onClick)
	if not db or not db.lock then
		button:SetScript("OnDragStart", onDragStart)
		button:SetScript("OnDragStop", onDragStop)
	end
	button:SetScript("OnMouseDown", onMouseDown)
	button:SetScript("OnMouseUp", onMouseUp)
--[[
	button.fadeOut = button:CreateAnimationGroup()
	local animOut = button.fadeOut:CreateAnimation("Alpha")
	animOut:SetOrder(1)
	animOut:SetDuration(0.2)
	animOut:SetFromAlpha(1)
	animOut:SetToAlpha(0)
	animOut:SetStartDelay(1)
	button.fadeOut:SetToFinalAlpha(true)
]]
	lib.objects[name] = button

	if lib.loggedIn then
		updatePosition(button, db and db.minimapPos)
		if not db or not db.hide then
			button:Show()
		else
			button:Hide()
		end
	end
	lib.callbacks:Fire("LibDBIcon_IconCreated", button, name) -- Fire 'Icon Created' callback
end

-- We could use a metatable.__index on lib.objects, but then we'd create
-- the icons when checking things like :IsRegistered, which is not necessary.
local function check(name)
	if lib.notCreated[name] then
		createButton(name, lib.notCreated[name][1], lib.notCreated[name][2])
		lib.notCreated[name] = nil
	end
end

-- Wait a bit with the initial positioning to let any GetMinimapShape addons
-- load up.
if not lib.loggedIn then
	local f = CreateFrame("Frame")
	f:SetScript("OnEvent", function()
		for _, button in next, lib.objects do
			updatePosition(button, button.db and button.db.minimapPos)
			if not button.db or not button.db.hide then
				button:Show()
			else
				button:Hide()
			end
		end
		lib.loggedIn = true
		this:SetScript("OnEvent", nil)
	end)
	f:RegisterEvent("PLAYER_LOGIN")
end

local function getDatabase(name)
	return lib.notCreated[name] and lib.notCreated[name][2] or lib.objects[name].db
end

function lib:Register(name, object, db)
	if not object.icon then error("Can't register LDB objects without icons set!") end
	if lib.objects[name] or lib.notCreated[name] then error(DBICON10.. ": Object '".. name .."' is already registered.") end
	if not db or not db.hide then
		createButton(name, object, db)
	else
		lib.notCreated[name] = {object, db}
	end
end

function lib:Lock(name)
	if not lib:IsRegistered(name) then return end
	if lib.objects[name] then
		lib.objects[name]:SetScript("OnDragStart", nil)
		lib.objects[name]:SetScript("OnDragStop", nil)
	end
	local db = getDatabase(name)
	if db then
		db.lock = true
	end
end

function lib:Unlock(name)
	if not lib:IsRegistered(name) then return end
	if lib.objects[name] then
		lib.objects[name]:SetScript("OnDragStart", onDragStart)
		lib.objects[name]:SetScript("OnDragStop", onDragStop)
	end
	local db = getDatabase(name)
	if db then
		db.lock = nil
	end
end

function lib:Hide(name)
	if not lib.objects[name] then return end
	lib.objects[name]:Hide()
end

function lib:Show(name)
	check(name)
	local button = lib.objects[name]
	if button then
		button:Show()
		updatePosition(button, button.db and button.db.minimapPos or button.minimapPos)
	end
end

function lib:IsRegistered(name)
	return (lib.objects[name] or lib.notCreated[name]) and true or false
end

function lib:Refresh(name, db)
	check(name)
	local button = lib.objects[name]
	if db then
		button.db = db
	end
	updatePosition(button, button.db and button.db.minimapPos or button.minimapPos)
	if not button.db or not button.db.hide then
		button:Show()
	else
		button:Hide()
	end
	if not button.db or not button.db.lock then
		button:SetScript("OnDragStart", onDragStart)
		button:SetScript("OnDragStop", onDragStop)
	else
		button:SetScript("OnDragStart", nil)
		button:SetScript("OnDragStop", nil)
	end
end

function lib:GetMinimapButton(name)
	return lib.objects[name]
end

do
	local function OnMinimapEnter()
		if isDraggingButton then return end
		for _, button in next, lib.objects do
			if button.showOnMouseover then
			--	button.fadeOut:Stop()
				button:SetAlpha(1)
			end
		end
	end
	local function OnMinimapLeave()
		if isDraggingButton then return end
		for _, button in next, lib.objects do
			if button.showOnMouseover then
			--	button.fadeOut:Play()
			end
		end
	end
	lib:HookScript(Minimap, "OnEnter", OnMinimapEnter)
	lib:HookScript(Minimap, "OnLeave", OnMinimapLeave)

	function lib:ShowOnEnter(name, value)
		local button = lib.objects[name]
		if button then
			if value then
				button.showOnMouseover = true
			--	button.fadeOut:Stop()
				button:SetAlpha(0)
			else
				button.showOnMouseover = false
			--	button.fadeOut:Stop()
				button:SetAlpha(1)
			end
		end
	end
end

function lib:GetButtonList()
	local t = {}
	for name in next, lib.objects do
		tinsert(t, name)
	end
return t
end

function lib:SetButtonRadius(radius)
	if type(radius) == "number" then
		lib.radius = radius
		for _, button in next, lib.objects do
			updatePosition(button, button.db and button.db.minimapPos or button.minimapPos)
		end
	end
end

function lib:SetButtonToPosition(button, position)
	updatePosition(lib.objects[button] or button, position)
end

-- Upgrade!
for name, button in next, lib.objects do
	local db = getDatabase(name)
	if not db or not db.lock then
		button:SetScript("OnDragStart", onDragStart)
		button:SetScript("OnDragStop", onDragStop)
	end
	button:SetScript("OnEnter", onEnter)
	button:SetScript("OnLeave", onLeave)
	button:SetScript("OnClick", onClick)
	button:SetScript("OnMouseDown", onMouseDown)
	button:SetScript("OnMouseUp", onMouseUp)
--[[
	if not button.fadeOut then -- Upgrade to 39
		button.fadeOut = button:CreateAnimationGroup()
		local animOut = button.fadeOut:CreateAnimation("Alpha")
		animOut:SetOrder(1)
		animOut:SetDuration(0.2)
		animOut:SetFromAlpha(1)
		animOut:SetToAlpha(0)
		animOut:SetStartDelay(1)
		button.fadeOut:SetToFinalAlpha(true)
	end
	]]
end
lib:SetButtonRadius(lib.radius) -- Upgrade to 40
```

### `README.md`

````markdown name=README.md
# Attune-Turtle

## Current Version: `1.0.2`

An addon for Turtle WoW that helps players track their attunement progress for dungeons and raids. This is a custom version inspired by the original [Attune](https://www.curseforge.com/wow/addons/attune) addon, tailored specifically for the Turtle WoW 1.12 client.

---

### Screenshot

![Attune-Turtle Screenshot](https://raw.githubusercontent.com/SirClaver420/Attune-Turtle/main/img/main_window_06092025.png)

---

### A Note from the Author

Hey there! 👋

I'm just a regular player who decided to try making their first WoW addon. Before this, I had zero experience with programming—I literally started from "what is Lua?" and "how do WoW addons even work?"

I loved the original Attune addon during Season of Discovery and was surprised I couldn't find anything similar for Turtle WoW. So, I thought... "I wonder if I could make one myself?" Spoiler alert: it's way harder than I expected, but also way more fun!

I'm learning everything as I go with the help of AI tools like GitHub Copilot, working on this in my spare time after work. This is a passion project for the love of the game and the Turtle WoW community.

**Please Note:** I am not affiliated with the Turtle WoW team, Blizzard, or any official entities whatsoever.

This also means that I'm definitely a noob developer learning as I go. If you find bugs or have suggestions, please be patient! Your feedback, bug reports, and contributions are essential to making this addon great. 😅

- SirClaver#1050 (Discord)

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Roadmap](#roadmap)
- [Version History](#version-history)
- [Versioning](#versioning)
- [Contributing](#contributing)
- [Acknowledgements](#acknowledgements)
- [License](#license)

---

## Features

- **Attunement Tracking:** Clear, step-by-step guides for all major attunements.
- **Dynamic UI:** Main window is fully resizable and remembers its position and dimensions.
- **Dungeon & Raid Keys:** Track progress for essential keys like the Mallet of Zul'Farrak, UBRS key, and more.
- **Intuitive UI:** A clean, modern interface to easily view your progress.
- **Minimap Button:** Quick access via a LibDataBroker (LDB) minimap icon.
- **Turtle WoW Specific:** Data and quests are tailored for the Turtle WoW server environment.

---

## Installation

1.  Download the latest version from the [releases page](https://github.com/SirClaver420/Attune-Turtle/releases).
2.  Unzip the downloaded file.
3.  Copy the `Attune-Turtle` folder into your `World of Warcraft\Interface\AddOns` directory.
4.  Restart World of Warcraft.

---

## Usage

-   **Slash Commands:**
    -   `/attune` or `/at`: Toggles the main window.
    -   `/attune options`: Shows the options panel (coming soon).
    -   `/attune help`: Shows a list of available commands.
    -   `/attune version`: Displays the current addon version.
    -   `/attune reset`: Resets addon options to default, including window size and position.

-   **Minimap Icon:**
    -   **Left-Click:** Toggles the main window.
    -   **Right-Click:** Opens the options menu (coming soon).

---

## Roadmap

This addon is under active development. The goal is to first build a robust, feature-rich foundation before populating all the attunement data.

### Phase 1: UI Foundation (v1.0.2) - ✅ Complete

-   ✅ Build a stable UI window.
-   ✅ Make the main window resizable and dynamic.
-   ✅ Create the sidebar, content area, and scroll frames.
-   ✅ Implement a landing page and basic attunement views.
-   ✅ Add a minimap icon and slash commands.
-   ✅ Populate with placeholder data for major attunements.

### Phase 2: Advanced Features (Next Up)

The primary focus is on building the core systems that will power the addon.

-   **Per-Character Progress:**
    -   🔳 Modify the database (`SavedVariables`) to store attunement progress on a per-character basis.
-   **Automatic Faction Detection:**
    -   🔳 Implement logic to automatically detect the player's faction (Horde/Alliance) to display the correct quest lines.
-   **Automation Engine:**
    -   🔳 Create a system to automatically check for quest completions.
    -   🔳 Add checks for required items in the player's inventory.
    -   🔳 Visually mark steps as "complete" in the UI based on player progress.
-   **Advanced UI Features:**
    -   🔳 Implement rich tooltips that show item/quest details on hover.
    -   🔳 Create a dedicated options panel for user customization.

### Phase 3: Content & Data Population

Once the foundation is complete, the focus will shift to adding all the specific attunement data.

-   **Data Implementation:**
    -   🔳 Implement step-by-step data for all keys (Mallet of Zul'Farrak, UBRS Key, etc.).
    -   🔳 Implement step-by-step data for all raid attunements (MC, BWL, Naxxramas).
    -   🔳 Add data for custom raids like **Emerald Sanctum**.
    -   🔳 Ensure data for both Horde and Alliance quest chains is complete.

---

## Version History

-   **v1.0.2 (2025-09-06)**
    -   Implemented a fully resizable and draggable main window.
    -   Window size and position are now saved between sessions.
    -   Fixed numerous bugs related to UI scripts and frame handling.
-   **v1.0.1 (2025-09-06)**
    -   Finalized and polished the static UI layout.
    -   Cleaned up code and added comments across all files.
    -   Improved the addon loading message in chat.
    -   Updated the project roadmap for the next phase of development.
-   **v1.0.0 (2025-09-06)**
    -   Initial release.
    -   Established core UI, data structure, and basic functionality.

---

## Versioning

This project follows a semantic versioning pattern of **MAJOR.MINOR.PATCH**.

-   **MAJOR (1.x.x):** Incremented for massive, potentially incompatible changes or the completion of a major development phase (e.g., the release of automatic progress tracking).
-   **MINOR (x.1.x):** Incremented when new, significant features are added, such as interactive tooltips, database links, or a new attunement section for a custom raid.
-   **PATCH (x.x.1):** Incremented for backwards-compatible bug fixes, text corrections, or other small tweaks.

---

## Contributing

Contributions are welcome! If you find a bug, have a suggestion, or want to contribute code, please open an issue or submit a pull request on the [GitHub repository](https://github.com/SirClaver420/Attune-Turtle).

---

## Acknowledgements

This addon would not have been possible without the incredible work of the addon community and the resources they provide. A special thanks goes to:

-   **CixiDelmont** for creating the original [Attune addon](https://www.curseforge.com/wow/addons/attune), which was the inspiration for this entire project.
-   The authors of the **Ace3 library framework**, whose work provides the stable and powerful foundation for this addon. This includes LibStub, AceCore, AceHook, CallbackHandler, LibDataBroker, and LibDBIcon.
-   The creators of other fantastic Turtle WoW addons like **AtlasLoot**, **pfUI**, and **ShaguDPS** which served as invaluable references for learning how to code in this environment.
-   **Wowhead** and the **Turtle WoW Wiki** for being indispensable resources for game data.
-   This project was developed with the assistance of **GitHub Copilot**, which helped guide the development process and write the code.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.