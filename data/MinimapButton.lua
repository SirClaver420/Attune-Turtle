-- Attune-Turtle Minimap Button
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