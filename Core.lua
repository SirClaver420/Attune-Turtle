-- Attune-Turtle Core
-- Main addon logic and initialization

-- Initialize the addon
AttuneTurtle = LibStub("AceHook-3.0"):Embed({})
local AT = AttuneTurtle

-- Database defaults
local defaults = {
    profile = {
        minimap = {
            hide = false,
            minimapPos = 225,
            radius = 80,
        },
        attunements = {},
        categoryStates = {
            ["Dungeons / Keys"] = true,
            ["Attunements"] = true,
        },
        firstTime = true,
    }
}

-- Initialize database and settings
function AT:InitializeDatabase()
    -- Create saved variables structure
    AttuneTurtleDB = AttuneTurtleDB or {}
    
    -- Set up defaults
    for key, value in pairs(defaults.profile) do
        if AttuneTurtleDB[key] == nil then
            AttuneTurtleDB[key] = value
        end
    end
    
    AT.db = AttuneTurtleDB
    AT_Debug("Database initialized")
end

-- Create LibDataBroker object
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
            
            -- Add attunement status
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

-- Toggle main frame visibility
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

-- Show settings (placeholder for future settings panel)
function AT:ShowSettings()
    print("|cff00ff00Attune Turtle:|r Settings panel coming soon!")
end

-- Check if player has completed a specific attunement
function AT:IsAttunementCompleted(attunementKey)
    if not AT.db or not AT.db.attunements then
        return false
    end
    return AT.db.attunements[attunementKey] and AT.db.attunements[attunementKey].completed
end

-- Mark attunement as completed
function AT:SetAttunementCompleted(attunementKey, completed)
    if not AT.db.attunements then
        AT.db.attunements = {}
    end
    if not AT.db.attunements[attunementKey] then
        AT.db.attunements[attunementKey] = {}
    end
    AT.db.attunements[attunementKey].completed = completed
    
    -- Update UI if needed
    if AT.mainFrame and AT.mainFrame:IsVisible() then
        -- Refresh current view
        if AT.selectedAttunement == attunementKey then
            AT_CreateAttunementView(attunementKey)
        end
    end
end

-- Hook quest completion events
function AT:HookQuestEvents()
    -- Hook quest completion
    AT:SecureHook("QuestRewardCompleteButton_OnClick", function()
        AT:CheckQuestCompletion()
    end)
    
    -- Hook quest log updates
    AT:SecureHook("SelectQuestLogEntry", function()
        AT:CheckQuestProgress()
    end)
end

-- Check for quest completion
function AT:CheckQuestCompletion()
    local questTitle = GetTitleText()
    if not questTitle then return end
    
    -- Check against our attunement quests
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

-- Mark a specific step as completed
function AT:MarkStepCompleted(attunementKey, stepId)
    if not AT.db.attunements then
        AT.db.attunements = {}
    end
    if not AT.db.attunements[attunementKey] then
        AT.db.attunements[attunementKey] = { steps = {} }
    end
    if not AT.db.attunements[attunementKey].steps then
        AT.db.attunements[attunementKey].steps = {}
    end
    
    AT.db.attunements[attunementKey].steps[stepId] = true
    
    print("|cff00ff00Attune Turtle:|r Step completed for " .. (AT.attunements[attunementKey] and AT.attunements[attunementKey].name or attunementKey))
end

-- Check quest progress
function AT:CheckQuestProgress()
    -- Implementation for checking current quest log state
    -- This will be expanded in future versions
end

-- Debug function
function AT_Debug(message)
    if AT.debug then
        print("|cff00ff00[Attune Debug]:|r " .. tostring(message))
    end
end

-- Event frame for initialization
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("VARIABLES_LOADED")

eventFrame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "Attune-Turtle" then
        AT:InitializeDatabase()
        AT:CreateDataBroker()
        
    elseif event == "VARIABLES_LOADED" then
        AT_CreateMinimapButton()
        
    elseif event == "PLAYER_LOGIN" then
        AT:HookQuestEvents()
        
        -- Show welcome message for first-time users
        if AT.db.firstTime then
            print("|cff00ff00Attune Turtle|r loaded! Type |cffffffff/attune|r to open or click the minimap icon.")
            AT.db.firstTime = false
        end
        
        -- Unregister events we don't need anymore
        eventFrame:UnregisterEvent("ADDON_LOADED")
        eventFrame:UnregisterEvent("PLAYER_LOGIN")
        eventFrame:UnregisterEvent("VARIABLES_LOADED")
    end
end)

-- Slash commands
SLASH_ATTUNE1 = "/attune"
SLASH_ATTUNE2 = "/at"
SlashCmdList["ATTUNE"] = function(msg)
    if msg == "debug" then
        AT.debug = not AT.debug
        print("|cff00ff00Attune Turtle:|r Debug mode " .. (AT.debug and "enabled" or "disabled"))
    elseif msg == "reset" then
        AT.db.minimap.hide = false
        AT.db.minimap.minimapPos = 225
        LibStub("LibDBIcon-1.0"):Refresh("AttuneTurtle", AT.db.minimap)
        print("|cff00ff00Attune Turtle:|r Minimap icon reset")
    else
        AT:ToggleMainFrame()
    end
end