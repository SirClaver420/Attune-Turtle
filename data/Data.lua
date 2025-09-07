-- Attune-Turtle v1.0.3 - Data.lua
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
                text = "This is a placeholder for the Zul'Farrak Mallet attunement steps.",
                itemID = 9240 -- Mallet of Zul'Farrak
            }
        }
    },
    maraudon = {
        name = "Maraudon Scepter",
        icon = "Interface\\Icons\\INV_Staff_10",
        steps = {
            {
                title = "Scepter of Celebras",
                text = "This is a placeholder for the Maraudon Scepter attunement steps.",
                itemID = 17182 -- Scepter of Celebras
            }
        }
    },
    ubrs = {
        name = "UBRS Key",
        icon = "Interface\\Icons\\INV_Jewelry_Ring_31", -- Corrected icon for the ring
        steps = {
            {
                title = "Seal of Ascension",
                text = "This is a placeholder for the UBRS Key attunement steps.",
                itemID = 12382 -- Seal of Ascension
            }
        }
    },
    diremaul = {
        name = "Dire Maul Key",
        icon = "Interface\\Icons\\INV_Misc_Key_09",
        steps = {
            {
                title = "Crescent Key",
                text = "This is a placeholder for the Dire Maul Key attunement steps.",
                itemID = 18268 -- Crescent Key
            }
        }
    },
    scholomance = {
        name = "Scholomance Key",
        icon = "Interface\\Icons\\INV_Misc_Key_14",
        steps = {
            {
                title = "Skeleton Key",
                text = "This is a placeholder for the Scholomance Key attunement steps.",
                itemID = 13704 -- Skeleton Key
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
        -- *** CHANGE: Corrected the icon path to one that exists in the client ***
        icon = "Interface\\Icons\\inv_misc_orb_01",
        steps = {
            {
                title = "The Dread Citadel",
                text = "Attunement requires Honored reputation with the Argent Dawn. Speak to Archmage Angela Dosantos at Light's Hope Chapel.",
                -- *** CHANGE: Corrected the icon path for the step view as well ***
                icon = "Interface\\Icons\\inv_misc_orb_01"
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