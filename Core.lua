-- Attune-Turtle Core Functionality
-- Based on Attune by Cixi/Goosy
-- Backported to TurtleWoW (1.12) by SirClaver420

-- Initialize addon table if it doesn't exist yet
AttuneTurtle = AttuneTurtle or {}
local AT = AttuneTurtle  -- Local reference for faster access

-- Initialize addon variables if they don't exist yet
AT.playerName = AT.playerName or UnitName("player")
AT.realmName = AT.realmName or GetRealmName()
AT.mainFrame = AT.mainFrame or nil
AT.selectedAttunement = AT.selectedAttunement or "Onyxia" -- Default selected attunement

-- Define colors if they don't exist yet
AT.colors = AT.colors or {
    title = "|cffFFD100",
    green = "|cff00FF00",
    white = "|cffFFFFFF",
    yellow = "|cffffff00",
}

-- Frame for handling events
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Debug function for development
function AT_Debug(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00AttuneTurtle|r: " .. msg)
end

-- Called when the addon is loaded
function AT_OnLoad()
    -- Initialize saved variables if they don't exist
    if not AttuneTurtle_Data then
        AttuneTurtle_Data = {
            characters = {},
            settings = {
                minimapButton = true,
                showCompleted = true,
            },
        }
    end
    
    -- Create this character's data if it doesn't exist
    local fullPlayerName = AT.playerName .. "-" .. AT.realmName
    if not AttuneTurtle_Data.characters[fullPlayerName] then
        local _, playerClass = UnitClass("player")
        local playerLevel = UnitLevel("player")
        local _, playerFaction = UnitFactionGroup("player")
        
        AttuneTurtle_Data.characters[fullPlayerName] = {
            attunements = {},
            class = playerClass,
            level = playerLevel,
            faction = playerFaction,
        }
    end
    
    -- Create the UI immediately
    AT_CreateMainFrame()
    
    -- Register slash commands
    SLASH_ATTUNETURTLE1 = "/attune"
    SLASH_ATTUNETURTLE2 = "/at"
    SlashCmdList["ATTUNETURTLE"] = AT_HandleSlashCommand
    
    AT_Debug("Addon loaded successfully")
end

-- Handle events properly with argument passing
eventFrame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "Attune-Turtle" then
        AT_OnLoad()
    elseif event == "PLAYER_ENTERING_WORLD" then
        AT_Debug("Welcome to Attune-Turtle! Type /attune to open the attunement tracker.")
    end
end)

-- Handle slash commands
function AT_HandleSlashCommand(msg)
    local command = string.lower(msg)
    
    if command == "" then
        AT_ToggleMainFrame()
    elseif command == "help" then
        AT_Debug("Available commands:")
        AT_Debug("/attune - Opens the main window")
        AT_Debug("/attune help - Shows this help message")
    else
        AT_ToggleMainFrame()
    end
end

-- Toggle the main frame
function AT_ToggleMainFrame()
    if AT.mainFrame then
        if AT.mainFrame:IsShown() then
            AT.mainFrame:Hide()
        else
            AT.mainFrame:Show()
        end
    else
        AT_Debug("Error: Main frame not initialized.")
    end
end