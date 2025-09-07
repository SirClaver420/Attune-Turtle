-- Attune-Turtle v1.0.3 - core/Debug.lua
-- Step 0.3b (Lua 5.0 compatibility): Expanded debug framework (channels, master toggle)
-- NOTE: Lua 5.0 (Vanilla) has no '#' length operator; all length checks use manual counting.

if not AttuneTurtle then return end
local AT = AttuneTurtle

AT.Debug = AT.Debug or {}
local D = AT.Debug

-- State
D.channels = D.channels or {}
D.all = D.all or false  -- when true, every channel prints (if master enabled)

-- Master flag is AT.debug
local function MasterEnabled()
    return AT.debug == true
end

--------------------------------------------------
-- Helpers
--------------------------------------------------
local function CountKeys(tbl)
    local c = 0
    for _ in pairs(tbl) do c = c + 1 end
    return c
end

--------------------------------------------------
-- Core output
--------------------------------------------------
function D:Print(channel, msg)
    if channel == "force" then
        print("|cff00ff00[Attune Debug]:|r " .. tostring(msg))
        return
    end
    if not MasterEnabled() then return end
    if self.all or channel == "general" or self.channels[channel] then
        print("|cff00ff00[Attune Debug][" .. channel .. "]|r " .. tostring(msg))
    end
end

--------------------------------------------------
-- Master control
--------------------------------------------------
function D:ToggleMaster()
    AT.debug = not AT.debug
    self:Print("force", "Master debug " .. (AT.debug and "ENABLED" or "DISABLED"))
    if AT.debug then
        self:StatusSummary()
    end
end

function D:SetMaster(on)
    local new = (on == true)
    if AT.debug == new then
        self:Print("force", "Master debug already " .. (new and "ENABLED" or "DISABLED"))
        return
    end
    AT.debug = new
    self:Print("force", "Master debug " .. (new and "ENABLED" or "DISABLED"))
    if new then
        self:StatusSummary()
    end
end

--------------------------------------------------
-- Channel management
--------------------------------------------------
function D:ToggleChannel(name)
    name = string.lower(name or "")
    if name == "" then return end
    if self.channels[name] then
        self.channels[name] = nil
        self:Print("force", "Channel '" .. name .. "' disabled")
    else
        self.channels[name] = true
        self:Print("force", "Channel '" .. name .. "' enabled")
    end
    if MasterEnabled() then
        self:StatusSummary()
    end
end

function D:SetAll(on)
    self.all = (on == true)
    self:Print("force", "'All channels' mode " .. (self.all and "ENABLED" or "DISABLED"))
    if MasterEnabled() then
        self:StatusSummary()
    end
end

function D:ListChannels()
    local list = {}
    for k in pairs(self.channels) do
        table.insert(list, k)
    end
    table.sort(list)
    local count = CountKeys(self.channels)
    if count == 0 then
        self:Print("force", "Active channels: (none)")
    else
        self:Print("force", "Active channels: " .. table.concat(list, ", "))
    end
end

function D:StatusSummary()
    local master = MasterEnabled() and "ON" or "OFF"
    local mode = self.all and "ALL" or "SELECTIVE"
    local count = CountKeys(self.channels)
    self:Print("force", "Status => Master:" .. master .. " Mode:" .. mode .. " Channels:" .. count)
end

--------------------------------------------------
-- Slash support (Core.lua delegates here)
--------------------------------------------------
function D:HandleSlash(rest)
    rest = (rest or "")
    -- Trim (Lua 5.0 safe)
    rest = string.gsub(rest, "^%s+", "")
    rest = string.gsub(rest, "%s+$", "")

    if rest == "" then
        self:ToggleMaster()
        return
    elseif rest == "off" then
        self:SetMaster(false)
        return
    elseif rest == "on" then
        self:SetMaster(true)
        return
    elseif rest == "list" then
        self:ListChannels()
        return
    elseif rest == "all" then
        self:SetAll(not self.all)
        return
    else
        self:ToggleChannel(rest)
        return
    end
end

--------------------------------------------------
-- Backward-compat shims
--------------------------------------------------
function D:Enable(channel)  self.channels[channel] = true end
function D:Disable(channel) self.channels[channel] = nil  end
function D:Is(channel)
    if not MasterEnabled() then return false end
    if self.all then return true end
    return self.channels[channel] == true
end

--------------------------------------------------
-- Self-test (only fires if master already on)
--------------------------------------------------
local function SelfTest()
    if not MasterEnabled() then return end
    D:Print("general", "Debug framework initialized (Lua 5.0 safe).")
end

SelfTest()