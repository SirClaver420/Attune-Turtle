-- Attune-Turtle UI
-- Contains all UI-related functions

-- Make sure AttuneTurtle exists
AttuneTurtle = AttuneTurtle or {}
local AT = AttuneTurtle  -- Local reference for faster access

-- Create the main UI frame
function AT_CreateMainFrame()
    -- Main frame
    AT.mainFrame = CreateFrame("Frame", "AttuneTurtleMainFrame", UIParent)
    AT.mainFrame:SetWidth(800)
    AT.mainFrame:SetHeight(600)
    AT.mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    AT.mainFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    AT.mainFrame:SetBackdropColor(0, 0, 0, 0.8)
    AT.mainFrame:EnableMouse(true)
    AT.mainFrame:SetMovable(true)
    
    -- Register for ESC key
    tinsert(UISpecialFrames, "AttuneTurtleMainFrame")
    
    -- Make the entire frame draggable
    AT.mainFrame:RegisterForDrag("LeftButton")
    AT.mainFrame:SetScript("OnDragStart", function() 
        AT.mainFrame:StartMoving() 
    end)
    AT.mainFrame:SetScript("OnDragStop", function() 
        AT.mainFrame:StopMovingOrSizing() 
    end)
    
    -- Title bar
    local titleBar = CreateFrame("Frame", nil, AT.mainFrame)
    titleBar:SetPoint("TOPLEFT", AT.mainFrame, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", AT.mainFrame, "TOPRIGHT", 0, 0)
    titleBar:SetHeight(25)
    
    -- Title text
    local title = titleBar:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    title:SetPoint("TOP", titleBar, "TOP", 0, -10)
    title:SetText("|cff00ff00Attune|r |cffffffffTurtle|r")
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, AT.mainFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", AT.mainFrame, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() AT.mainFrame:Hide() end)
    
    -- Create sidebar (left panel)
    AT.sidebarFrame = CreateFrame("Frame", "AttuneTurtleSidebar", AT.mainFrame)
    AT.sidebarFrame:SetWidth(200)
    AT.sidebarFrame:SetPoint("TOPLEFT", AT.mainFrame, "TOPLEFT", 10, -30)
    AT.sidebarFrame:SetPoint("BOTTOMLEFT", AT.mainFrame, "BOTTOMLEFT", 10, 40)
    AT.sidebarFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    AT.sidebarFrame:SetBackdropColor(0, 0, 0, 0.5)
    
    -- Create main content area
    AT.contentFrame = CreateFrame("Frame", "AttuneTurtleContent", AT.mainFrame)
    AT.contentFrame:SetPoint("TOPLEFT", AT.sidebarFrame, "TOPRIGHT", 10, 0)
    AT.contentFrame:SetPoint("BOTTOMRIGHT", AT.mainFrame, "BOTTOMRIGHT", -10, 40)
    AT.contentFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    AT.contentFrame:SetBackdropColor(0, 0, 0, 0.3)
    
    -- Bottom panel
    local bottomPanel = CreateFrame("Frame", nil, AT.mainFrame)
    bottomPanel:SetHeight(30)
    bottomPanel:SetPoint("BOTTOMLEFT", AT.mainFrame, "BOTTOMLEFT", 10, 5)
    bottomPanel:SetPoint("BOTTOMRIGHT", AT.mainFrame, "BOTTOMRIGHT", -10, 5)
    
    -- Version panel at bottom left (like original Attune)
    local versionFrame = CreateFrame("Frame", nil, AT.mainFrame)
    versionFrame:SetHeight(20)
    versionFrame:SetWidth(300)
    versionFrame:SetPoint("BOTTOMLEFT", AT.mainFrame, "BOTTOMLEFT", 10, 10)
    
    -- Version text
    local versionText = versionFrame:CreateFontString(nil, "OVERLAY")
    versionText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    versionText:SetPoint("LEFT", versionFrame, "LEFT", 0, 0)
    versionText:SetText("|cffd4af37Attune " .. AT.version .. " by " .. AT.author .. "|r") -- Gold color like in original
    
    -- Close button (bottom right)
    local closeBtn = CreateFrame("Button", nil, bottomPanel, "UIPanelButtonTemplate")
    closeBtn:SetWidth(80)
    closeBtn:SetHeight(25)
    closeBtn:SetText("Close")
    closeBtn:SetPoint("BOTTOMRIGHT", bottomPanel, "BOTTOMRIGHT", 0, 0)
    closeBtn:SetScript("OnClick", function() AT.mainFrame:Hide() end)
    
    -- Store category states
    AT.categoryStates = {}
    for i, category in ipairs(AT.categories) do
        AT.categoryStates[category.name] = category.expanded
    end
    
    -- Populate the sidebar with attunement listings
    AT_PopulateSidebar()
    
    -- Create initial content view
    AT_CreateAttunementView(AT.selectedAttunement)
    
    -- Hide by default
    AT.mainFrame:Hide()
end

-- Function to set the selected attunement and update view
function AT_SelectAttunement(attunementKey)
    if not attunementKey or not AT.attunements[attunementKey] then
        AT_Debug("Error: Invalid attunement key: " .. (attunementKey or "nil"))
        return
    end
    
    AT.selectedAttunement = attunementKey
    
    -- Update selected state in sidebar items
    if AT.sidebarItems then
        for key, item in pairs(AT.sidebarItems) do
            if item and item.SetSelected then
                item:SetSelected(key == attunementKey)
            end
        end
    end
    
    AT_CreateAttunementView(attunementKey)
end

-- Create a sidebar item for an attunement
function AT_CreateSidebarItem(attunementKey, yPos)
    local attunement = AT.attunements[attunementKey]
    if not attunement then return nil end
    
    -- Create the button frame
    local itemFrame = CreateFrame("Button", "ATItem_" .. attunementKey, AT.sidebarFrame)
    itemFrame:SetHeight(20)
    itemFrame:SetPoint("TOPLEFT", AT.sidebarFrame, "TOPLEFT", 15, yPos)
    itemFrame:SetPoint("TOPRIGHT", AT.sidebarFrame, "TOPRIGHT", -5, yPos)
    itemFrame:EnableMouse(true)
    
    -- Create the item icon
    local icon = itemFrame:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(16)
    icon:SetHeight(16)
    icon:SetPoint("LEFT", itemFrame, "LEFT", 0, 0)
    icon:SetTexture(attunement.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    
    -- Create the item text
    local text = itemFrame:CreateFontString(nil, "OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
    
    -- Set text to white for all items regardless of completion
    text:SetText("|cffffffff" .. attunement.name .. "|r")
    
    -- Store the attunement key with the frame for the OnClick handler
    itemFrame.attunementKey = attunementKey
    
    -- Set selected appearance function
    itemFrame.SetSelected = function(frame, selected)
        if selected then
            frame:LockHighlight()
        else
            frame:UnlockHighlight()
        end
    end
    
    -- Handle clicks on the item - FIX: Use a direct reference instead of 'self'
    itemFrame:SetScript("OnClick", function()
        local key = itemFrame.attunementKey
        if key then
            AT_SelectAttunement(key)
        end
    end)
    
    -- Highlight on hover
    itemFrame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    
    -- Set initial selected state
    itemFrame:SetSelected(attunementKey == AT.selectedAttunement)
    
    return itemFrame
end

-- Create a category header in the sidebar
function AT_CreateCategoryHeader(categoryName, yPos)
    -- Get the expanded state from stored settings
    local isExpanded = AT.categoryStates[categoryName]
    
    -- Category header
    local headerFrame = CreateFrame("Button", nil, AT.sidebarFrame)
    headerFrame:SetHeight(20)
    headerFrame:SetPoint("TOPLEFT", AT.sidebarFrame, "TOPLEFT", 5, yPos)
    headerFrame:SetPoint("TOPRIGHT", AT.sidebarFrame, "TOPRIGHT", -5, yPos)
    headerFrame:EnableMouse(true)
    
    -- Category title text - use yellowish WoW color
    local headerText = headerFrame:CreateFontString(nil, "OVERLAY")
    headerText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    headerText:SetPoint("LEFT", headerFrame, "LEFT", 10, 0)
    headerText:SetText("|cffffff00" .. categoryName .. "|r") -- WoW yellowish color
    
    -- Expand/collapse indicator
    local expandBtn = headerFrame:CreateTexture(nil, "ARTWORK")
    expandBtn:SetWidth(16)
    expandBtn:SetHeight(16)
    expandBtn:SetPoint("RIGHT", headerFrame, "RIGHT", -5, 0)
    expandBtn:SetTexture(isExpanded and "Interface\\Buttons\\UI-MinusButton-Up" or "Interface\\Buttons\\UI-PlusButton-Up")
    
    headerFrame.expanded = isExpanded
    headerFrame.expandBtn = expandBtn
    headerFrame.categoryName = categoryName
    
    -- Toggle expansion when clicked - FIX: Use stored variables instead of 'self'
    headerFrame:SetScript("OnClick", function()
        local newExpanded = not headerFrame.expanded
        headerFrame.expanded = newExpanded
        headerFrame.expandBtn:SetTexture(newExpanded and "Interface\\Buttons\\UI-MinusButton-Up" or "Interface\\Buttons\\UI-PlusButton-Up")
        
        -- Store the new state
        AT.categoryStates[categoryName] = newExpanded
        
        -- Update sidebar without changing the selected attunement
        AT_PopulateSidebar()
    end)
    
    -- Highlight on hover
    headerFrame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    
    return headerFrame
end

-- Populate the sidebar with attunement listings
function AT_PopulateSidebar()
    -- Clear existing elements
    if AT.sidebarElements then
        for _, element in ipairs(AT.sidebarElements) do
            element:Hide()
        end
    end
    
    AT.sidebarElements = {}
    AT.sidebarItems = AT.sidebarItems or {}
    
    local yPos = -10 -- Start position
    
    -- Process each category
    for i, category in ipairs(AT.categories) do
        -- Get the category's expanded state from stored settings
        local isExpanded = AT.categoryStates[category.name]
        
        -- Create category header
        local header = AT_CreateCategoryHeader(category.name, yPos)
        table.insert(AT.sidebarElements, header)
        
        yPos = yPos - 25 -- Move down for items
        
        -- If category is expanded, show its items
        if isExpanded then
            for _, attunementKey in ipairs(category.items) do
                local attunement = AT.attunements[attunementKey]
                if attunement then
                    -- Create sidebar item for this attunement
                    local item = AT_CreateSidebarItem(attunementKey, yPos)
                    if item then
                        table.insert(AT.sidebarElements, item)
                        AT.sidebarItems[attunementKey] = item
                        yPos = yPos - 20 -- Move down for next item
                    end
                end
            end
        end
    end
end

-- Create the attunement flowchart view
function AT_CreateAttunementView(attunementKey)
    -- Use parameter or fallback to selected attunement
    attunementKey = attunementKey or AT.selectedAttunement
    
    -- Safety check
    if not attunementKey or not AT.attunements[attunementKey] then
        AT_Debug("Error creating view: Invalid attunement key: " .. (attunementKey or "nil"))
        return
    end

    -- Clear previous content
    if AT.contentFrame.scrollFrame then
        AT.contentFrame.scrollFrame:Hide()
        AT.contentFrame.scrollFrame = nil
    end
    
    -- Create a ScrollFrame for the flowchart
    AT.contentFrame.scrollFrame = CreateFrame("ScrollFrame", "AttuneTurtleScrollFrame", AT.contentFrame)
    AT.contentFrame.scrollFrame:SetPoint("TOPLEFT", AT.contentFrame, "TOPLEFT", 5, -5)
    AT.contentFrame.scrollFrame:SetPoint("BOTTOMRIGHT", AT.contentFrame, "BOTTOMRIGHT", -25, 5) -- Leave space for scrollbar
    
    -- Create the scrollable content frame
    AT.contentFrame.flowchart = CreateFrame("Frame", "AttuneTurtleFlowchart", AT.contentFrame.scrollFrame)
    AT.contentFrame.flowchart:SetWidth(AT.contentFrame.scrollFrame:GetWidth() - 10)
    AT.contentFrame.flowchart:SetHeight(1) -- Will be resized based on content
    
    -- Set up the ScrollFrame
    AT.contentFrame.scrollFrame:SetScrollChild(AT.contentFrame.flowchart)
    AT.contentFrame.scrollFrame:EnableMouseWheel(true)
    AT.contentFrame.scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local current = self:GetVerticalScroll()
        local maxScroll = self:GetVerticalScrollRange()
        local newScroll = math.max(0, math.min(maxScroll, current - (delta * 20)))
        self:SetVerticalScroll(newScroll)
    end)
    
    -- Get the selected attunement data
    local attunementData = AT.attunements[attunementKey]
    if not attunementData then
        -- Show an error or placeholder
        local noDataText = AT.contentFrame.flowchart:CreateFontString(nil, "OVERLAY")
        noDataText:SetFont("Fonts\\FRIZQT__.TTF", 14)
        noDataText:SetPoint("CENTER", AT.contentFrame.flowchart, "CENTER", 0, 0)
        noDataText:SetText("No attunement data available for " .. tostring(attunementKey))
        return
    end
    
    -- Add attunement title with icon
    local titleIcon = AT.contentFrame.flowchart:CreateTexture(nil, "ARTWORK")
    titleIcon:SetWidth(32)
    titleIcon:SetHeight(32)
    titleIcon:SetPoint("TOPLEFT", AT.contentFrame.flowchart, "TOPLEFT", 10, -10)
    titleIcon:SetTexture(attunementData.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    
    local attunementTitle = AT.contentFrame.flowchart:CreateFontString(nil, "OVERLAY")
    attunementTitle:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
    attunementTitle:SetPoint("LEFT", titleIcon, "RIGHT", 10, 0)
    attunementTitle:SetText(attunementData.name)
    
    -- Create step boxes based on the attunement data
    if attunementData.steps then
        -- Calculate total content height needed
        local titleHeight = 60
        local stepHeight = 60 -- Reduced from 70 for better spacing
        local stepSpacing = 10
        local totalSteps = #attunementData.steps
        local totalContentHeight = titleHeight + (totalSteps * stepHeight) + (math.max(0, totalSteps - 1) * stepSpacing) + 20 -- Extra padding
        
        -- Set the flowchart height to contain all content
        AT.contentFrame.flowchart:SetHeight(math.max(totalContentHeight, AT.contentFrame.scrollFrame:GetHeight()))
        
        -- Create a simple vertical list of steps
        local yPos = -titleHeight -- Start below the title
        
        for i, step in ipairs(attunementData.steps) do
            -- Create a green border box for this step
            local stepBox = CreateFrame("Frame", "AttuneTurtleStep" .. i, AT.contentFrame.flowchart)
            stepBox:SetWidth(320)
            stepBox:SetHeight(50)
            stepBox:SetPoint("TOP", AT.contentFrame.flowchart, "TOP", 0, yPos)
            stepBox:SetBackdrop({
                bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
                tile = true, tileSize = 16, edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            stepBox:SetBackdropColor(0, 0.5, 0, 0.5) -- Green background
            
            -- Add appropriate icon based on step type
            local typeIcon = stepBox:CreateTexture(nil, "ARTWORK")
            typeIcon:SetWidth(24)
            typeIcon:SetHeight(24)
            typeIcon:SetPoint("LEFT", stepBox, "LEFT", 10, 0)
            
            -- Set icon based on step type
            if step.type == "quest" then
                typeIcon:SetTexture(AT.icons.quest)
            elseif step.type == "item" then
                typeIcon:SetTexture(AT.icons.item)
            elseif step.type == "kill" then
                typeIcon:SetTexture(AT.icons.kill)
            elseif step.type == "level" then
                typeIcon:SetTexture(AT.icons.level)
            elseif step.type == "interact" then
                typeIcon:SetTexture(AT.icons.interact)
            elseif step.type == "reward" then
                typeIcon:SetTexture(AT.icons.reward)
            else
                typeIcon:SetTexture(AT.icons.scroll)
            end
            
            -- Step text
            local stepText = stepBox:CreateFontString(nil, "OVERLAY")
            stepText:SetFont("Fonts\\FRIZQT__.TTF", 12)
            stepText:SetPoint("TOP", stepBox, "TOP", 0, -10)
            stepText:SetWidth(260)
            stepText:SetText(step.text)
            
            -- Step location
            if step.location then
                local locationText = stepBox:CreateFontString(nil, "OVERLAY")
                locationText:SetFont("Fonts\\FRIZQT__.TTF", 10)
                locationText:SetPoint("BOTTOM", stepBox, "BOTTOM", 0, 5)
                locationText:SetText(step.location)
            end
            
            yPos = yPos - stepHeight -- Move down for next step
            
            -- If this step has a previous step, draw a connection line
            if step.previousStep and i > 1 then
                -- Simple vertical line for now - we'll improve this later
                local line = AT.contentFrame.flowchart:CreateTexture(nil, "ARTWORK")
                line:SetTexture("Interface/TRIBUTEFRAME/HorizontalTick")
                line:SetHeight(10) -- Reduced line height for better spacing
                line:SetWidth(2)   -- Width of the line
                line:SetPoint("TOP", stepBox, "TOP", 0, 10)
            end
        end
    end
end