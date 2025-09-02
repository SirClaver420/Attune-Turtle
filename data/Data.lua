-- Attune-Turtle Data
-- Contains all the attunement data

-- Initialize the AttuneTurtle table first
AttuneTurtle = AttuneTurtle or {}
local AT = AttuneTurtle  -- Local reference for faster access

-- Version information
AT.version = "v.1.0.0"
AT.author = "SirClaver420"

-- Icons for attunements
AT.icons = {
    dungeonKey = "Interface\\Icons\\INV_Misc_Key_11",
    scroll = "Interface\\Icons\\INV_Misc_Note_01",
    item = "Interface\\Icons\\INV_Misc_Bag_08",
    quest = "Interface\\Icons\\INV_Misc_Note_01",
    kill = "Interface\\Icons\\Ability_Warrior_DecisiveStrike",
    level = "Interface\\Icons\\INV_Misc_Gem_Pearl_02",
    interact = "Interface\\Icons\\INV_Misc_Gear_02",
    reward = "Interface\\Icons\\INV_Misc_Gem_Sapphire_02",
    checkmark = "Interface\\Buttons\\UI-CheckBox-Check",
    raid = {
        MC = "Interface\\Icons\\INV_Hammer_Unique_Sulfuras", -- Sulfuras icon
        Onyxia = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
        BWL = "Interface\\Icons\\INV_Misc_Head_Dragon_Black",
        Naxx = "Interface\\Icons\\INV_Jewelry_Talisman_13", -- The Restrained Essence of Sapphiron icon
    }
}

-- Categories for organization (ordered by level requirement)
AT.categories = {
    {
        name = "Dungeons / Keys",
        expanded = true,
        items = {
            "MaraudonScepter",      -- Level 46-55
            "ZFMallet",             -- Level 44-54 
            "ScholomanceKey",       -- Level 58-60
            "UBRSKey",             -- Level 55-60
            "DMKey",               -- Level 55-60
        }
    },
    {
        name = "Attunements",
        expanded = true,
        items = {
            "MC",                   -- Level 60
            "Onyxia",              -- Level 60 (55+ to start)
            "BWL",                 -- Level 60
            "Naxx",                -- Level 60
        }
    }
}

-- Define attunements data structure
AT.attunements = {
    -- Dungeons / Keys section (ordered by level)
    ["MaraudonScepter"] = {
        name = "Maraudon Scepter",
        faction = "Both",
        phase = 1,
        minLevel = 46,
        maxLevel = 55,
        icon = "Interface\\Icons\\INV_Staff_16",
        category = "Dungeons / Keys",
        completed = true,
        steps = {
            {
                id = "MARA_001",
                text = "Collect Celebration of Life from Maraudon",
                location = "Desolace",
                type = "item",
                completed = false,
                x = 0,
                y = 0,
            },
            {
                id = "MARA_002",
                text = "Complete 'The Scepter of Celebras' quest",
                location = "Desolace",
                type = "quest",
                previousStep = "MARA_001",
                completed = false,
                x = 0,
                y = 60,
            },
            {
                id = "MARA_003",
                text = "Receive Scepter of Celebras",
                location = "Desolace",
                type = "reward",
                previousStep = "MARA_002",
                completed = false,
                x = 0,
                y = 120,
            },
        },
    },
    
    ["ZFMallet"] = {
        name = "Zul'Farrak Mallet",
        faction = "Both",
        phase = 1,
        minLevel = 44,
        maxLevel = 54,
        icon = "Interface\\Icons\\INV_Hammer_19",
        category = "Dungeons / Keys",
        completed = false,
        steps = {
            {
                id = "ZF_001",
                text = "Obtain Sacred Mallet",
                location = "Zul'Farrak",
                type = "quest",
                completed = false,
                x = 0,
                y = 0,
            },
            {
                id = "ZF_002",
                text = "Use mallet to summon Gahz'rilla",
                location = "Zul'Farrak",
                type = "interact",
                previousStep = "ZF_001",
                completed = false,
                x = 0,
                y = 60,
            },
        },
    },
    
    ["ScholomanceKey"] = {
        name = "Scholomance Key",
        faction = "Both",
        phase = 1,
        minLevel = 58,
        maxLevel = 60,
        category = "Dungeons / Keys",
        icon = "Interface\\Icons\\INV_Misc_Key_11",
        completed = false,
        steps = {
            {
                id = "SCHOLO_001",
                text = "Collect Skeleton Key from Scholomance",
                location = "Western Plaguelands",
                type = "item",
                completed = false,
                x = 0,
                y = 0,
            },
            {
                id = "SCHOLO_002",
                text = "Complete 'Scholomance' quest",
                location = "Western Plaguelands",
                type = "quest",
                previousStep = "SCHOLO_001",
                completed = false,
                x = 0,
                y = 60,
            },
            {
                id = "SCHOLO_003",
                text = "Receive Skeleton Key",
                location = "Western Plaguelands",
                type = "reward",
                previousStep = "SCHOLO_002",
                completed = false,
                x = 0,
                y = 120,
            },
        },
    },
    
    ["UBRSKey"] = {
        name = "UBRS Key",
        faction = "Both",
        phase = 1,
        minLevel = 55,
        maxLevel = 60,
        icon = "Interface\\Icons\\INV_Misc_Key_10",
        category = "Dungeons / Keys",
        completed = false,
        steps = {
            {
                id = "UBRS_001",
                text = "Obtain Unadorned Seal of Ascension",
                location = "Lower Blackrock Spire",
                type = "item",
                completed = false,
                x = 0,
                y = 0,
            },
            {
                id = "UBRS_002",
                text = "Collect 3 Gemstones",
                location = "Lower Blackrock Spire",
                type = "item",
                previousStep = "UBRS_001",
                completed = false,
                x = 0,
                y = 60,
            },
            {
                id = "UBRS_003",
                text = "Kill General Drakkisath for Blood",
                location = "Upper Blackrock Spire",
                type = "kill",
                previousStep = "UBRS_002",
                completed = false,
                x = 0,
                y = 120,
            },
            {
                id = "UBRS_004",
                text = "Receive Seal of Ascension",
                location = "Blackrock Mountain",
                type = "reward",
                previousStep = "UBRS_003",
                completed = false,
                x = 0,
                y = 180,
            },
        },
    },
    
    ["DMKey"] = {
        name = "Dire Maul Key",
        faction = "Both",
        phase = 1,
        minLevel = 55,
        maxLevel = 60,
        icon = "Interface\\Icons\\INV_Misc_Key_13",
        category = "Dungeons / Keys",
        completed = true,
        steps = {
            {
                id = "DM_001",
                text = "Obtain Crescent Key",
                location = "Dire Maul",
                type = "quest",
                completed = false,
                x = 0,
                y = 0,
            },
        },
    },
    
    -- Raid attunements (all level 60)
    ["MC"] = {
        name = "Molten Core",
        faction = "Both",
        phase = 1,
        minLevel = 60,
        category = "Attunements",
        icon = AT.icons.raid.MC,
        completed = true,
        steps = {
            {
                id = "MC_001",
                text = "Attune by entering Blackrock Depths and touching the Core Fragment",
                location = "Blackrock Depths",
                type = "interact",
                completed = false,
                x = 0,
                y = 0,
            },
        },
    },
    
    ["Onyxia"] = {
        name = "Onyxia's Lair",
        faction = "Alliance", -- Different for Horde
        phase = 1,
        minLevel = 55,
        category = "Attunements",
        icon = AT.icons.raid.Onyxia,
        completed = false,
        steps = {
            {
                id = "ONY_001",
                text = "Reach level 55",
                location = "Character progression",
                type = "level",
                completed = false,
                x = 0,
                y = 0,
            },
            {
                id = "ONY_002",
                text = "Warlord's Command",
                location = "Burning Steppes",
                type = "quest",
                questId = 4974,
                previousStep = "ONY_001",
                completed = false,
                x = 0,
                y = 60,
            },
            {
                id = "ONY_003",
                text = "Important Blackrock Documents",
                location = "Burning Steppes",
                type = "item",
                itemId = 12562,
                previousStep = "ONY_002",
                completed = false,
                x = -150,
                y = 120,
            },
            {
                id = "ONY_004",
                text = "Overlord Wyrmthalak",
                location = "Lower Blackrock Spire",
                type = "kill",
                mobId = 9568,
                previousStep = "ONY_002",
                completed = false,
                x = -50,
                y = 120,
            },
            {
                id = "ONY_005",
                text = "War Master Voone",
                location = "Lower Blackrock Spire",
                type = "kill",
                mobId = 9237,
                previousStep = "ONY_002",
                completed = false,
                x = 50,
                y = 120,
            },
            {
                id = "ONY_006",
                text = "Highlord Omokk",
                location = "Lower Blackrock Spire",
                type = "kill",
                mobId = 9196,
                previousStep = "ONY_002",
                completed = false,
                x = 150,
                y = 120,
            },
            {
                id = "ONY_007",
                text = "Eitrigg's Wisdom",
                location = "Orgrimmar",
                type = "quest",
                questId = 4941,
                previousStep = {"ONY_003", "ONY_004", "ONY_005", "ONY_006"},
                completed = false,
                x = 0,
                y = 180,
            },
            {
                id = "ONY_008",
                text = "For The Horde!",
                location = "Orgrimmar",
                type = "quest",
                questId = 4974,
                previousStep = "ONY_007",
                completed = false,
                x = 0,
                y = 240,
            },
        },
    },
    
    ["BWL"] = {
        name = "Blackwing Lair",
        faction = "Both",
        phase = 3,
        minLevel = 60,
        category = "Attunements",
        icon = AT.icons.raid.BWL,
        completed = true,
        steps = {
            {
                id = "BWL_001",
                text = "Obtain Drakefire Amulet by completing Drakkisath's Demise",
                location = "Upper Blackrock Spire",
                type = "quest",
                questId = 6502,
                completed = false,
                x = 0,
                y = 0,
            },
        },
    },
    
    ["Naxx"] = {
        name = "Naxxramas",
        faction = "Both",
        phase = 6,
        minLevel = 60,
        category = "Attunements",
        icon = AT.icons.raid.Naxx,
        completed = true,
        steps = {
            {
                id = "NAXX_001",
                text = "The Dread Citadel - Naxxramas",
                location = "Eastern Plaguelands",
                type = "quest",
                questId = 9121,
                completed = false,
                x = 0,
                y = 0,
            },
            {
                id = "NAXX_002",
                text = "The Dread Citadel - Naxxramas (2)",
                location = "Eastern Plaguelands",
                type = "quest",
                questId = 9122,
                previousStep = "NAXX_001",
                completed = false,
                x = 0,
                y = 60,
            },
            {
                id = "NAXX_003",
                text = "The Dread Citadel - Naxxramas (3)",
                location = "Eastern Plaguelands",
                type = "quest",
                questId = 9123,
                previousStep = "NAXX_002",
                completed = false,
                x = 0,
                y = 120,
            },
        },
    },
}

-- Function to check if player has completed a quest
function AT_HasCompletedQuest(questID)
    -- This is placeholder - vanilla WoW doesn't have direct API for checking completed quests
    -- We'll need to implement a manual tracking system later
    return false
end

-- Function to check step completion
function AT_CheckStepCompletion(stepID)
    -- Will be implemented in future updates
    return false
end

-- Function to check if an attunement is completed
function AT_IsAttunementCompleted(attunementKey)
    if not attunementKey or not AT.attunements[attunementKey] then
        return false
    end
    
    return AT.attunements[attunementKey].completed or false
end