-- Attune-Turtle v1.0.3 - core/Core.lua
-- Step 0.3c (compat fix): Remove Lua 5.1 string:match usage; keep debug integration; wording unified to "Options".

AttuneTurtle = AttuneTurtle or {}
local AT = AttuneTurtle

AT.version = "1.0.3"
AT.author  = "SirClaver420"

--------------------------------------------------
-- Simple debug shim
--------------------------------------------------
function AT_Debug(msg)
    if AT.debug then
        if AT.Debug and AT.Debug.Print then
            AT.Debug:Print("general", tostring(msg))
        else
            print("|cff00ff00[Attune Debug]:|r " .. tostring(msg))
        end
    end
end

--------------------------------------------------
-- Saved Variables
--------------------------------------------------
local defaults = {
    minimap = {
        hide = false,
        minimapPos = 225,
        radius = 80,
    },
    width = 1024,
    height = 600,
    attunements = {},
    categoryStates = {
        ["Dungeons / Keys"] = true,
        ["Attunements"] = true,
    },
    firstTime = true,
}

local function CopyDefaults(src, dst)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then dst[k] = {} end
            CopyDefaults(v, dst[k])
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

function AT:InitializeDatabase()
    AttuneTurtleDB = AttuneTurtleDB or {}
    CopyDefaults(defaults, AttuneTurtleDB)
    AT.db = AttuneTurtleDB
    AT_Debug("Database initialized")
end

--------------------------------------------------
-- DataBroker / Minimap
--------------------------------------------------
function AT:CreateDataBroker()
    local ok, LDB = pcall(LibStub, "LibDataBroker-1.1")
    if not ok or not LDB then
        AT_Debug("LibDataBroker missing - skipping minimap object.")
        return
    end

    AT.dataObj = LDB:NewDataObject("AttuneTurtle", {
        type = "launcher",
        text = "Attune Turtle",
        icon = "Interface\\Icons\\INV_Misc_Book_09",
        OnClick = function(_, button)
            if button == "LeftButton" then
                AT:ToggleMainFrame()
            elseif button == "RightButton" then
                AT:ShowOptions()
            end
        end,
        OnTooltipShow = function(tt)
            tt:AddLine("|cff00ff00Attune Turtle|r")
            tt:AddLine(" ")
            tt:AddLine("|cffffff00Left-click:|r Open attunement tracker")
            tt:AddLine("|cffffff00Right-click:|r Open options")
            local completed, total = 0, 0
            if AT.attunements then
                for key in pairs(AT.attunements) do
                    total = total + 1
                    if AT:IsAttunementCompleted(key) then
                        completed = completed + 1
                    end
                end
            end
            tt:AddLine(" ")
            tt:AddLine("|cffaaccffProgress: " .. completed .. "/" .. total .. " completed|r")
        end,
    })
end

--------------------------------------------------
-- UI
--------------------------------------------------
function AT:ToggleMainFrame()
    if AT.mainFrame and AT.mainFrame:IsVisible() then
        AT.mainFrame:Hide()
    else
        if not AT.mainFrame then
            if type(AT_CreateMainFrame) == "function" then
                AT_CreateMainFrame()
            else
                print("|cff00ff00Attune Turtle:|r UI creation function missing (AT_CreateMainFrame).")
                return
            end
        end
        AT.mainFrame:Show()
    end
end

function AT:ShowOptions()
    print("|cff00ff00Attune Turtle:|r Options panel coming soon!")
end

--------------------------------------------------
-- Attunement state
--------------------------------------------------
function AT:IsAttunementCompleted(attunementKey)
    local db = AT.db
    if not db or not db.attunements then return false end
    local a = db.attunements[attunementKey]
    return a and a.completed or false
end

function AT:SetAttunementCompleted(attunementKey, completed)
    if not AT.db.attunements[attunementKey] then
        AT.db.attunements[attunementKey] = {}
    end
    AT.db.attunements[attunementKey].completed = completed and true or false

    if AT.mainFrame and AT.mainFrame:IsVisible() and AT.selectedAttunement == attunementKey then
        if type(AT_CreateAttunementView) == "function" then
            AT_CreateAttunementView(attunementKey)
        end
    end
end

function AT:MarkStepCompleted(attunementKey, stepId)
    if not AT.db.attunements[attunementKey] then
        AT.db.attunements[attunementKey] = { steps = {} }
    end
    if not AT.db.attunements[attunementKey].steps then
        AT.db.attunements[attunementKey].steps = {}
    end
    AT.db.attunements[attunementKey].steps[stepId] = true
    print("|cff00ff00Attune Turtle:|r Step completed for " ..
        ((AT.attunements and AT.attunements[attunementKey] and AT.attunements[attunementKey].name) or attunementKey))
end

--------------------------------------------------
-- Placeholder quest hooks
--------------------------------------------------
function AT:HookQuestEvents()
    -- Empty for now
end

--------------------------------------------------
-- Help / Slash (Lua 5.0 safe parsing)
--------------------------------------------------
local function PrintHelp()
    print("|cff00ff00Attune Turtle|r - Commands:")
    print("  /attune or /at           - Toggle main window")
    print("  /attune help             - Show help")
    print("  /attune version          - Show version")
    print("  /attune reset            - Reset options")
    print("  /attune debug            - Toggle master debug")
    print("  /attune debug list       - List debug channels")
    print("  /attune debug all        - Toggle all-channel mode")
    print("  /attune debug off        - Force debug off")
    print("  /attune debug <channel>  - Toggle channel")
end

SLASH_ATTUNE1 = "/attune"
SLASH_ATTUNE2 = "/at"
SlashCmdList["ATTUNE"] = function(msg)
    msg = msg or ""
    -- Trim
    msg = string.gsub(msg, "^%s+", "")
    msg = string.gsub(msg, "%s+$", "")

    if msg == "" then
        AT:ToggleMainFrame()
        return
    end

    -- Manual split (first space)
    local firstSpace = string.find(msg, " ")
    local cmd, rest
    if firstSpace then
        cmd = string.sub(msg, 1, firstSpace - 1)
        rest = string.sub(msg, firstSpace + 1)
    else
        cmd = msg
        rest = ""
    end
    cmd = string.lower(cmd)
    rest = rest or ""

    if cmd == "help" then
        PrintHelp()
    elseif cmd == "version" then
        print("|cff00ff00Attune Turtle:|r Version " .. AT.version .. " by " .. AT.author)
    elseif cmd == "reset" then
        AttuneTurtleDB = nil
        AT:InitializeDatabase()
        if AT.mainFrame then
            AT.mainFrame:Hide()
            AT.mainFrame = nil
        end
        print("|cff00ff00Attune Turtle:|r Options reset.")
    elseif cmd == "debug" then
        if AT.Debug and AT.Debug.HandleSlash then
            AT.Debug:HandleSlash(rest)
        else
            AT.debug = not AT.debug
            print("|cff00ff00Attune Turtle:|r Debug mode " .. (AT.debug and "ENABLED" or "DISABLED") .. " (basic)")
        end
    else
        PrintHelp()
    end
end

--------------------------------------------------
-- Events
--------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "Attune-Turtle" then
        AT:InitializeDatabase()
        AT:CreateDataBroker()
        AT:HookQuestEvents()
        AT_Debug("ADDON_LOADED complete")
    elseif event == "PLAYER_LOGIN" then
        if type(AT_CreateMinimapButton) == "function" then
            AT_Debug("Attempting minimap button creation...")
            AT_CreateMinimapButton()
        else
            AT_Debug("Minimap button function not found at PLAYER_LOGIN")
        end

        if AT.db.firstTime then
            print("|cff00ff00Attune Turtle|r [v" .. AT.version .. "] loaded for the first time! Type /attune to open.")
            AT.db.firstTime = false
        else
            print("|cff00ff00Attune Turtle|r [v" .. AT.version .. "] loaded. Type /attune help for commands.")
        end
        eventFrame:UnregisterEvent("ADDON_LOADED")
        eventFrame:UnregisterEvent("PLAYER_LOGIN")
    end
end)

AT_Debug("Core.lua loaded (compat fix).")