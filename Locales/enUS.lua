-- Get the library
local L = LibStub("AceLocale-3.0"):NewLocale("Attune-Turtle", "enUS", true)
if not L then return end

-- Version 1.0.1
-- English localization file

-- Core.lua
L["LDB_TOOLTIP_HEADER"] = "|cff00ff00Attune Turtle|r"
L["LDB_TOOLTIP_HINT_LCLICK"] = "|cffffff00Left-click:|r Open attunement tracker"
L["LDB_TOOLTIP_HINT_RCLICK"] = "|cffffff00Right-click:|r Open settings"
L["LDB_TOOLTIP_PROGRESS"] = "|cffaaccffProgress: %s/%s completed|r"
L["SETTINGS_SOON"] = "|cff00ff00Attune Turtle:|r Settings panel coming soon!"
L["STEP_COMPLETED"] = "|cff00ff00Attune Turtle:|r Step completed for %s"
L["WELCOME_MSG_FIRST"] = "|cff00ff00Attune Turtle|r [v%s] loaded! Type |cffffffff/attune|r to open or click the minimap icon."
L["WELCOME_MSG_NORMAL"] = "|cff00ff00Attune Turtle|r [v%s] loaded! Type |cffffffff/attune help|r for commands."
L["DEBUG_ENABLED"] = "|cff00ff00Attune Turtle:|r Debug mode enabled"
L["DEBUG_DISABLED"] = "|cff00ff00Attune Turtle:|r Debug mode disabled"
L["MINIMAP_RESET"] = "|cff00ff00Attune Turtle:|r Minimap icon reset"
L["VERSION_INFO"] = "|cff00ff00Attune Turtle:|r Version %s by %s"
L["HELP_HEADER"] = "|cff00ff00Attune Turtle|r - Available Commands:"
L["HELP_TOGGLE"] = "|cffffffff/attune|r or |cffffffff/at|r - Open the main window"
L["HELP_HELP"] = "|cffffffff/attune help|r - Show this help message"
L["HELP_VERSION"] = "|cffffffff/attune version|r - Display addon version info"
L["HELP_DEBUG"] = "|cffffffff/attune debug|r - Toggle debug mode"
L["HELP_RESET"] = "|cffffffff/attune reset|r - Reset minimap button position"

-- UI.lua
L["ADDON_TITLE"] = "|cff00ff00Attune|r |cffffffffTurtle|r"
L["VERSION_TEXT"] = "|cffd4af37Attune %s by %s|r"
L["CLOSE_BUTTON"] = "Close"
L["SIDEBAR_HOME"] = "|cffffffffHome|r"
L["SIDEBAR_CATEGORY_HEADER"] = "|cffffff00%s|r" -- %s is the category name
L["SIDEBAR_ITEM_TEXT"] = "|cffffffff%s|r" -- %s is the attunement name
L["LANDING_WELCOME_TITLE"] = "|cff00ff00Welcome to Attune Turtle!|r"
L["LANDING_DESCRIPTION"] = "|cffffffffAttune Turtle helps you track your attunement progress for dungeons and raids.|r"
L["LANDING_FEATURES_TITLE"] = "|cffffff00Features:|r"
L["LANDING_FEATURE_1"] = "|cffffffffTrack dungeon key requirements and steps|r"
L["LANDING_FEATURE_2"] = "|cffffffffView raid attunement chains and progress|r"
L["LANDING_FEATURE_3"] = "|cffffffffStep-by-step quest and item guidance|r"
L["LANDING_GETTING_STARTED_TITLE"] = "|cffffff00Getting Started:|r"
L["LANDING_GETTING_STARTED_TEXT"] = "|cffffffffSelect a dungeon or raid from the left panel to view its attunement requirements.\n\nEach step will show you exactly what you need to do and where to go.|r"
L["LANDING_TURTLE_NOTE"] = "|cffaaccffOptimized for Turtle WoW - Happy adventuring!|r"
L["LANDING_FOOTER_TEXT"] = "|cff808080Additional Features Coming Soon:\n\n• Quest completion tracking (if possible)\n• Progress saving\n• Character-specific progress\n• Export/Import functionality\n• Custom notes\n\n\n\nThis content extends beyond the visible area to test scrolling functionality.\n\n\n\nEnd of content.|r"
L["UNKNOWN_STEP"] = "Unknown Step"
L["NO_DETAILS_AVAILABLE"] = "No details available."
L["STEP_TITLE"] = "Step %d"

-- MinimapButton.lua
L["MINIMAP_HIDDEN"] = "|cff00ff00Attune Turtle:|r Minimap button hidden"
L["MINIMAP_SHOWN"] = "|cff00ff00Attune Turtle:|r Minimap button shown"
L["MINIMAP_RESET_DEFAULT"] = "|cff00ff00Attune Turtle:|r Minimap button reset to default position"