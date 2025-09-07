-- Attune-Turtle v1.0.3 - Core.lua
-- Main addon logic and initialization

-- Initialize the addon's main table
AttuneTurtle = LibStub("AceHook-3.0"):Embed({})
local AT = AttuneTurtle

-- Version information
AT.version = "1.0.3" -- Version updated for new feature
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
                -- *** CHANGE: Use ShowOptions instead of ShowSettings ***
                AT:ShowOptions()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("|cff00ff00Attune Turtle|r")
            tooltip:AddLine(" ")
            tooltip:AddLine("|cffffff00Left-click:|r Open attunement tracker")
            -- *** CHANGE: Use "Options" instead of "settings" ***
            tooltip:AddLine("|cffffff00Right-click:|r Open options")
            
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

-- *** CHANGE: Renamed function from ShowSettings to ShowOptions ***
function AT:ShowOptions()
    print("|cff00ff00Attune Turtle:|r Options panel coming soon!")
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
    -- *** CHANGE: Use "options" instead of "settings" ***
    print("  |cffffff00/attune reset|r - Reset addon options (including window size).")
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
        -- Reset all options to default
        AttuneTurtleDB = nil
        AT:InitializeDatabase()
        if AT.mainFrame then
            AT.mainFrame:Hide()
            AT.mainFrame = nil
        end
        AT:ResetMinimapButton()
        -- *** CHANGE: Use "options" instead of "settings" ***
        print("|cff00ff00Attune Turtle:|r All options have been reset to default.")
    elseif msg == "version" then
        print("|cff00ff00Attune Turtle:|r Version " .. AT.version .. " by " .. AT.author)
    elseif msg == "help" then
        AT:ShowHelp()
    else
        AT:ToggleMainFrame()
    end
end