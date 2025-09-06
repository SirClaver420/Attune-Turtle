-- Attune-Turtle Data
-- Contains all data for attunements

-- Make sure AttuneTurtle exists
AttuneTurtle = AttuneTurtle or {}
local AT = AttuneTurtle  -- Local reference

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
                x = 0, y = -190 -- Increased Y spacing
            },
            {
                id = "ony_kill_warchief",
                title = "Important Blackrock...",
                subtext = "Item in Lower Blackrock...",
                type = "item",
                previousStep = "ony_warlords_command",
                x = -300, y = -280 -- Spread out X, Increased Y spacing
            },
            {
                id = "ony_kill_overlord",
                title = "Overlord Wyrmthalak",
                subtext = "Kill in Lower Blackrock...",
                type = "kill",
                previousStep = "ony_warlords_command",
                x = -100, y = -280 -- Spread out X, Increased Y spacing
            },
            {
                id = "ony_kill_warmaster",
                title = "War Master Voone",
                subtext = "Kill in Lower Blackrock...",
                type = "kill",
                previousStep = "ony_warlords_command",
                x = 100, y = -280 -- Spread out X, Increased Y spacing
            },
            {
                id = "ony_kill_highlord",
                title = "Highlord Omokk",
                subtext = "Kill in Lower Blackrock...",
                type = "kill",
                previousStep = "ony_warlords_command",
                x = 300, y = -280 -- Spread out X, Increased Y spacing
            },
            {
                id = "ony_eirtriggs_wisdom",
                title = "Eitrigg's Wisdom",
                subtext = "Quest in Orgrimmar",
                type = "quest",
                previousStep = { "ony_kill_warchief", "ony_kill_overlord", "ony_kill_warmaster", "ony_kill_highlord" },
                x = 0, y = -370 -- Increased Y spacing
            },
            {
                id = "ony_for_the_horde",
                title = "For The Horde!",
                subtext = "Quest in Orgrimmar",
                type = "quest",
                previousStep = "ony_eirtriggs_wisdom",
                x = 0, y = -460 -- Increased Y spacing
            }
        }
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