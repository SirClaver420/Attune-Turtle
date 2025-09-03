-- Attune-Turtle UI
-- Contains all UI-related functions

-- Make sure AttuneTurtle exists
AttuneTurtle = AttuneTurtle or {}
local AT = AttuneTurtle  -- Local reference for faster access

-- Add the RefreshIcons function to update dynamic icons
function AT:RefreshIcons(itemID)
    -- Update any icon frames associated with this item ID
    if AT.iconFrames and AT.iconFrames[itemID] then
        local texture = AT:GetItemIcon(itemID)
        for _, frameData in pairs(AT.iconFrames[itemID]) do
            if frameData.icon then
                frameData.icon:SetTexture(texture)
            end
        end
    end
    
    -- Also refresh the main view if needed
    if AT.mainFrame and AT.mainFrame:IsVisible() then
        if AT.selectedAttunement then
            local attunement = AT.attunements[AT.selectedAttunement]
            if attunement and attunement.itemID == itemID then
                AT_CreateAttunementView(AT.selectedAttunement)
            end
        end
    end
end

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
    AT.sidebarFrame:SetPoint("BOTTOMLEFT", AT.mainFrame, "BOTTOMLEFT", 10, 45) -- Raised to make room for bigger bottom panel
    AT.sidebarFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    AT.sidebarFrame:SetBackdropColor(0, 0, 0, 0.5)
    
    -- Create main content area (this will be the container for the scroll frame)
    AT.contentFrame = CreateFrame("Frame", "AttuneTurtleContent", AT.mainFrame)
    AT.contentFrame:SetPoint("TOPLEFT", AT.sidebarFrame, "TOPRIGHT", 10, 0)
    AT.contentFrame:SetPoint("BOTTOMRIGHT", AT.mainFrame, "BOTTOMRIGHT", -10, 45) -- Raised to make room for bigger bottom panel
    AT.contentFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    AT.contentFrame:SetBackdropColor(0, 0, 0, 0.3)
    
    -- Create simple scroll frame using basic WoW components
    AT.scrollFrame = CreateFrame("ScrollFrame", "AttuneTurtleScrollFrame", AT.contentFrame)
    AT.scrollFrame:SetPoint("TOPLEFT", AT.contentFrame, "TOPLEFT", 8, -8)
    AT.scrollFrame:SetPoint("BOTTOMRIGHT", AT.contentFrame, "BOTTOMRIGHT", -30, 8) -- More room for scrollbar
    
    -- Create scroll bar
    AT.scrollBar = CreateFrame("Slider", "AttuneTurtleScrollBar", AT.scrollFrame)
    AT.scrollBar:SetPoint("TOPRIGHT", AT.contentFrame, "TOPRIGHT", -8, -8)
    AT.scrollBar:SetPoint("BOTTOMRIGHT", AT.contentFrame, "BOTTOMRIGHT", -8, 8)
    AT.scrollBar:SetWidth(16)
    AT.scrollBar:SetMinMaxValues(0, 100)
    AT.scrollBar:SetValue(0)
    AT.scrollBar:SetValueStep(1)
    
    -- Add scroll bar textures
    AT.scrollBar:SetBackdrop({
        bgFile = "Interface/Buttons/UI-SliderBar-Background",
        edgeFile = "Interface/Buttons/UI-SliderBar-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    
    local scrollThumb = AT.scrollBar:CreateTexture(nil, "OVERLAY")
    scrollThumb:SetTexture("Interface/Buttons/UI-SliderBar-Button-Horizontal")
    scrollThumb:SetWidth(16)
    scrollThumb:SetHeight(24)
    AT.scrollBar:SetThumbTexture(scrollThumb)
    
    -- Create the scrollable content container
    AT.scrollChild = CreateFrame("Frame", "AttuneTurtleScrollChild", AT.scrollFrame)
    AT.scrollChild:SetWidth(1) -- Will be set dynamically
    AT.scrollChild:SetHeight(1) -- Will be set dynamically
    AT.scrollFrame:SetScrollChild(AT.scrollChild)
    
    -- Custom scrolling logic
    local function UpdateScrollRange()
        local contentHeight = AT.scrollChild:GetHeight()
        local frameHeight = AT.scrollFrame:GetHeight()
        local maxScroll = math.max(0, contentHeight - frameHeight)
        
        AT.scrollBar:SetMinMaxValues(0, maxScroll)
        
        if maxScroll > 0 then
            AT.scrollBar:Show()
        else
            AT.scrollBar:Hide()
        end
    end
    
    AT.scrollBar:SetScript("OnValueChanged", function()
        local value = AT.scrollBar:GetValue()
        AT.scrollFrame:SetVerticalScroll(value)
    end)
    
    -- Enable mouse wheel scrolling
    AT.scrollFrame:EnableMouseWheel(true)
    AT.scrollFrame:SetScript("OnMouseWheel", function()
        local delta = arg1
        local current = AT.scrollBar:GetValue()
        local min, max = AT.scrollBar:GetMinMaxValues()
        
        local newValue = current - (delta * 20)
        newValue = math.max(min, math.min(max, newValue))
        
        AT.scrollBar:SetValue(newValue)
    end)
    
    -- Store the update function for later use
    AT.UpdateScrollRange = UpdateScrollRange
    
    -- BIGGER Bottom panel area (almost touching the sides)
    local bottomPanel = CreateFrame("Frame", nil, AT.mainFrame)
    bottomPanel:SetHeight(35) -- Made taller
    bottomPanel:SetPoint("BOTTOMLEFT", AT.mainFrame, "BOTTOMLEFT", 10, 5)
    bottomPanel:SetPoint("BOTTOMRIGHT", AT.mainFrame, "BOTTOMRIGHT", -10, 5)
    
    -- LARGER Version panel at bottom left (almost touching close button)
    local versionPanel = CreateFrame("Frame", nil, AT.mainFrame)
    versionPanel:SetHeight(25) -- Made taller
    versionPanel:SetWidth(600) -- Made much wider (almost the full width)
    versionPanel:SetPoint("BOTTOMLEFT", AT.mainFrame, "BOTTOMLEFT", 10, 10)
    
    -- Add backdrop to version panel to match original Attune
    versionPanel:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    versionPanel:SetBackdropColor(0, 0, 0, 0.7) -- Dark background like in original
    
    -- Version text
    local versionText = versionPanel:CreateFontString(nil, "OVERLAY")
    versionText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE") -- Made slightly larger
    versionText:SetPoint("LEFT", versionPanel, "LEFT", 12, 0)
    versionText:SetText("|cffd4af37Attune " .. AT.version .. " by " .. AT.author .. "|r") -- Gold color like in original
    
    -- Close button (bottom right) - now positioned to almost touch the version panel
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
    
    -- Set to no default selection - we'll show landing page instead
    AT.selectedAttunement = nil
    
    -- Populate the sidebar with attunement listings
    AT_PopulateSidebar()
    
    -- Add OnShow script to show landing page when frame is first shown
    AT.mainFrame:SetScript("OnShow", function()
        -- Small delay to ensure frame dimensions are calculated
        local initTimer = CreateFrame("Frame")
        initTimer.timeElapsed = 0
        initTimer:SetScript("OnUpdate", function()
            initTimer.timeElapsed = initTimer.timeElapsed + arg1
            if initTimer.timeElapsed >= 0.1 then -- 100ms delay
                initTimer:SetScript("OnUpdate", nil)
                AT_CreateLandingPage() -- Show landing page instead of attunement
            end
        end)
    end)
    
    -- Hide by default
    AT.mainFrame:Hide()
end

-- Create the landing page
function AT_CreateLandingPage()
    -- Clear any existing content
    if AT.scrollChild then
        local children = {AT.scrollChild:GetChildren()}
        for _, child in ipairs(children) do
            child:Hide()
            child:SetParent(nil)
        end
        
        local regions = {AT.scrollChild:GetRegions()}
        for _, region in ipairs(regions) do
            if region:GetObjectType() == "FontString" or region:GetObjectType() == "Texture" then
                region:Hide()
                region:SetParent(nil)
            end
        end
    end
    
    -- Calculate available width
    local availableWidth = AT.contentFrame:GetWidth() - 60 -- Account for scrollbar
    AT.scrollChild:SetWidth(availableWidth)
    
    -- Welcome title with Attune logo/icon - CENTERED
    local welcomeIcon = AT.scrollChild:CreateTexture(nil, "ARTWORK")
    welcomeIcon:SetWidth(48)
    welcomeIcon:SetHeight(48)
    welcomeIcon:SetPoint("TOP", AT.scrollChild, "TOP", -50, -30)
    welcomeIcon:SetTexture("Interface\\Icons\\INV_Misc_Book_09") -- Nice book icon for welcome
    
    local welcomeTitle = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    welcomeTitle:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
    welcomeTitle:SetPoint("LEFT", welcomeIcon, "RIGHT", 15, 0)
    welcomeTitle:SetText("|cff00ff00Welcome to Attune Turtle!|r")
    
    -- Description text - CENTERED
    local descText = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    descText:SetFont("Fonts\\FRIZQT__.TTF", 14)
    descText:SetPoint("TOP", welcomeIcon, "BOTTOM", 50, -30)
    descText:SetWidth(availableWidth - 60)
    descText:SetJustifyH("CENTER")
    descText:SetText("|cffffffffAttune Turtle helps you track your attunement progress for dungeons and raids.|r")
    
    -- Features title - CENTERED
    local featuresTitle = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    featuresTitle:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    featuresTitle:SetPoint("TOP", descText, "BOTTOM", 0, -40)
    featuresTitle:SetText("|cffffff00Features:|r")
    
    -- Create a container for centered features
    local featuresContainer = CreateFrame("Frame", nil, AT.scrollChild)
    featuresContainer:SetWidth(320)
    featuresContainer:SetHeight(100)
    featuresContainer:SetPoint("TOP", featuresTitle, "BOTTOM", 0, -20)
    
    -- Feature 1 - CENTERED in container
    local feature1Icon = featuresContainer:CreateTexture(nil, "ARTWORK")
    feature1Icon:SetWidth(16)
    feature1Icon:SetHeight(16)
    feature1Icon:SetPoint("TOPLEFT", featuresContainer, "TOPLEFT", 0, 0)
    feature1Icon:SetTexture("Interface\\Icons\\INV_Misc_Key_11")
    
    local feature1Text = featuresContainer:CreateFontString(nil, "OVERLAY")
    feature1Text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    feature1Text:SetPoint("LEFT", feature1Icon, "RIGHT", 10, 0)
    feature1Text:SetWidth(290)
    feature1Text:SetJustifyH("LEFT")
    feature1Text:SetText("|cffffffffTrack dungeon key requirements and steps|r")
    
    -- Feature 2 - CENTERED in container
    local feature2Icon = featuresContainer:CreateTexture(nil, "ARTWORK")
    feature2Icon:SetWidth(16)
    feature2Icon:SetHeight(16)
    feature2Icon:SetPoint("TOP", feature1Icon, "BOTTOM", 0, -15)
    feature2Icon:SetTexture("Interface\\Icons\\INV_Hammer_Unique_Sulfuras")
    
    local feature2Text = featuresContainer:CreateFontString(nil, "OVERLAY")
    feature2Text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    feature2Text:SetPoint("LEFT", feature2Icon, "RIGHT", 10, 0)
    feature2Text:SetWidth(290)
    feature2Text:SetJustifyH("LEFT")
    feature2Text:SetText("|cffffffffView raid attunement chains and progress|r")
    
    -- Feature 3 - CENTERED in container
    local feature3Icon = featuresContainer:CreateTexture(nil, "ARTWORK")
    feature3Icon:SetWidth(16)
    feature3Icon:SetHeight(16)
    feature3Icon:SetPoint("TOP", feature2Icon, "BOTTOM", 0, -15)
    feature3Icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
    
    local feature3Text = featuresContainer:CreateFontString(nil, "OVERLAY")
    feature3Text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    feature3Text:SetPoint("LEFT", feature3Icon, "RIGHT", 10, 0)
    feature3Text:SetWidth(290)
    feature3Text:SetJustifyH("LEFT")
    feature3Text:SetText("|cffffffffStep-by-step quest and item guidance|r")
    
    -- Getting started title - CENTERED
    local startTitle = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    startTitle:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    startTitle:SetPoint("TOP", featuresContainer, "BOTTOM", 0, -40)
    startTitle:SetText("|cffffff00Getting Started:|r")
    
    -- Getting started text - CENTERED
    local startText = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    startText:SetFont("Fonts\\FRIZQT__.TTF", 12)
    startText:SetPoint("TOP", startTitle, "BOTTOM", 0, -15)
    startText:SetWidth(availableWidth - 60)
    startText:SetJustifyH("CENTER")
    startText:SetText("|cffffffffSelect a dungeon or raid from the left panel to view its attunement requirements.\n\nEach step will show you exactly what you need to do and where to go.|r")
    
    -- Turtle WoW specific note - CENTERED
    local turtleNote = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    turtleNote:SetFont("Fonts\\FRIZQT__.TTF", 11)
    turtleNote:SetPoint("TOP", startText, "BOTTOM", 0, -30)
    turtleNote:SetWidth(availableWidth - 60)
    turtleNote:SetJustifyH("CENTER")
    turtleNote:SetTextColor(0.8, 0.8, 1.0) -- Light blue
    turtleNote:SetText("|cffaaccffOptimized for Turtle WoW - Happy adventuring!|r")
    
    -- Add some extra scrollable content to test scrolling with UPDATED TEXT
    local extraContent = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    extraContent:SetFont("Fonts\\FRIZQT__.TTF", 10)
    extraContent:SetPoint("TOP", turtleNote, "BOTTOM", 0, -50)
    extraContent:SetWidth(availableWidth - 60)
    extraContent:SetJustifyH("CENTER")
    extraContent:SetTextColor(0.5, 0.5, 0.5)
    extraContent:SetText("|cff808080Additional Features Coming Soon:\n\n• Quest completion tracking (if possible)\n• Progress saving\n• Character-specific progress\n• Export/Import functionality\n• Custom notes\n\n\n\nThis content extends beyond the visible area to test scrolling functionality.\n\n\n\nEnd of content.|r")
    
    -- Set scroll child height for proper scrolling
    local totalHeight = 800 -- Make it tall enough to require scrolling
    AT.scrollChild:SetHeight(totalHeight)
    
    -- Update scroll range
    if AT.UpdateScrollRange then
        AT.UpdateScrollRange()
    end
    
    -- Reset scroll position to top
    if AT.scrollBar then
        AT.scrollBar:SetValue(0)
    end
    
    -- Clear any selected attunement
    AT.selectedAttunement = nil
    
    -- Update sidebar to show no selection
    if AT.sidebarItems then
        for key, item in pairs(AT.sidebarItems) do
            if item and item.SetSelected then
                item:SetSelected(false)
            end
        end
    end
    
    -- Update home button selection
    if AT.homeButton and AT.homeButton.SetSelected then
        AT.homeButton:SetSelected(true)
    end
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
    
    -- Clear home button selection
    if AT.homeButton and AT.homeButton.SetSelected then
        AT.homeButton:SetSelected(false)
    end
    
    AT_CreateAttunementView(attunementKey)
end

-- Create a home button for the landing page
function AT_CreateHomeButton(yPos)
    local itemFrame = CreateFrame("Button", "ATItem_Home", AT.sidebarFrame)
    itemFrame:SetHeight(20)
    itemFrame:SetPoint("TOPLEFT", AT.sidebarFrame, "TOPLEFT", 15, yPos)
    itemFrame:SetPoint("TOPRIGHT", AT.sidebarFrame, "TOPRIGHT", -5, yPos)
    itemFrame:EnableMouse(true)
    
    -- Create the item icon
    local icon = itemFrame:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(16)
    icon:SetHeight(16)
    icon:SetPoint("LEFT", itemFrame, "LEFT", 0, 0)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09") -- Home/book icon
    
    -- Create the item text
    local text = itemFrame:CreateFontString(nil, "OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
    text:SetText("|cffffffffHome|r")
    
    -- Set selected appearance function
    itemFrame.SetSelected = function(frame, selected)
        if selected then
            frame:LockHighlight()
        else
            frame:UnlockHighlight()
        end
    end
    
    -- Handle clicks on the home button
    itemFrame:SetScript("OnClick", function()
        AT_CreateLandingPage()
    end)
    
    -- Highlight on hover
    itemFrame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    
    -- Store reference for selection management
    AT.homeButton = itemFrame
    
    return itemFrame
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
    -- Use our new GetAttunementIcon function
    icon:SetTexture(AT:GetAttunementIcon(attunement))
    
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
    
    -- Handle clicks on the item
    itemFrame:SetScript("OnClick", function()
        local key = itemFrame.attunementKey
        if key then
            AT_SelectAttunement(key)
        end
    end)
    
    -- Highlight on hover
    itemFrame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    
    -- Set initial selected state (will be false for landing page)
    itemFrame:SetSelected(attunementKey == AT.selectedAttunement)
    
    -- Store the item frame for later updates if the icon loads dynamically
    if attunement.itemID then
        if not AT.iconFrames then AT.iconFrames = {} end
        if not AT.iconFrames[attunement.itemID] then AT.iconFrames[attunement.itemID] = {} end
        table.insert(AT.iconFrames[attunement.itemID], {frame = itemFrame, icon = icon})
    end
    
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
    
    -- Toggle expansion when clicked
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
    
    -- Add Home button at the top
    local homeButton = AT_CreateHomeButton(yPos)
    table.insert(AT.sidebarElements, homeButton)
    yPos = yPos - 25 -- Move down after home button
    
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

-- Create the attunement flowchart view with better panel alignment
function AT_CreateAttunementView(attunementKey)
    -- Use parameter or fallback to selected attunement
    attunementKey = attunementKey or AT.selectedAttunement
    
    -- Safety check
    if not attunementKey or not AT.attunements[attunementKey] then
        AT_Debug("Error creating view: Invalid attunement key: " .. (attunementKey or "nil"))
        return
    end

    -- Safety check - make sure frames exist and are visible
    if not AT.contentFrame or not AT.scrollFrame or not AT.scrollChild then
        AT_Debug("Frames not ready yet, skipping content creation")
        return
    end
    
    -- Wait for frame to be properly sized
    if AT.contentFrame:GetWidth() <= 1 then
        AT_Debug("Content frame not sized yet, delaying...")
        -- Retry after a short delay
        local retryTimer = CreateFrame("Frame")
        retryTimer.timeElapsed = 0
        retryTimer:SetScript("OnUpdate", function()
            retryTimer.timeElapsed = retryTimer.timeElapsed + arg1
            if retryTimer.timeElapsed >= 0.05 then -- 50ms delay
                retryTimer:SetScript("OnUpdate", nil)
                AT_CreateAttunementView(attunementKey)
            end
        end)
        return
    end

    -- Clear previous content from scroll child
    if AT.scrollChild then
        local children = {AT.scrollChild:GetChildren()}
        for _, child in ipairs(children) do
            child:Hide()
            child:SetParent(nil)
        end
        
        local regions = {AT.scrollChild:GetRegions()}
        for _, region in ipairs(regions) do
            if region:GetObjectType() == "FontString" or region:GetObjectType() == "Texture" then
                region:Hide()
                region:SetParent(nil)
            end
        end
    end
    
    -- Get the selected attunement data
    local attunementData = AT.attunements[attunementKey]
    if not attunementData then
        local noDataText = AT.scrollChild:CreateFontString(nil, "OVERLAY")
        noDataText:SetFont("Fonts\\FRIZQT__.TTF", 14)
        noDataText:SetPoint("CENTER", AT.scrollChild, "CENTER", 0, 0)
        noDataText:SetText("No attunement data available for " .. tostring(attunementKey))
        return
    end
    
    -- Calculate available width (account for scrollbar)
    local availableWidth = AT.contentFrame:GetWidth() - 60
    
    -- Set scroll child width to match available space
    AT.scrollChild:SetWidth(availableWidth)
    
    -- Add attunement title with icon
    local titleIcon = AT.scrollChild:CreateTexture(nil, "ARTWORK")
    titleIcon:SetWidth(32)
    titleIcon:SetHeight(32)
    titleIcon:SetPoint("TOPLEFT", AT.scrollChild, "TOPLEFT", 15, -15)
    -- Use our new GetAttunementIcon function
    titleIcon:SetTexture(AT:GetAttunementIcon(attunementData))
    
    local attunementTitle = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    attunementTitle:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
    attunementTitle:SetPoint("LEFT", titleIcon, "RIGHT", 10, 0)
    attunementTitle:SetText(attunementData.name)
    
    -- Create step boxes with better alignment (like original Attune)
    local totalHeight = 70 -- Start after title
    
    if attunementData.steps then
        local yPos = -80 -- Start below the title
        local stepWidth = availableWidth - 30 -- Leave margins
        
        for i, step in ipairs(attunementData.steps) do
            -- Create step panel (similar to original Attune style)
            local stepBox = CreateFrame("Frame", "AttuneTurtleStep" .. i .. "_" .. attunementKey, AT.scrollChild)
            stepBox:SetWidth(stepWidth)
            stepBox:SetHeight(60) -- Taller panels like original
            stepBox:SetPoint("TOPLEFT", AT.scrollChild, "TOPLEFT", 15, yPos)
            stepBox:SetBackdrop({
                bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
                tile = true, tileSize = 16, edgeSize = 16,
                insets = { left = 4, right = 4, top = 4, bottom = 4 }
            })
            stepBox:SetBackdropColor(0, 0.4, 0, 0.6) -- Darker green like original
            
            -- Add appropriate icon based on step type
            local typeIcon = stepBox:CreateTexture(nil, "ARTWORK")
            typeIcon:SetWidth(32) -- Larger icons like original
            typeIcon:SetHeight(32)
            typeIcon:SetPoint("LEFT", stepBox, "LEFT", 12, 0)
            
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
            
            -- Step text - better positioning like original
            local stepText = stepBox:CreateFontString(nil, "OVERLAY")
            stepText:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE") -- Slightly larger, outlined
            stepText:SetPoint("LEFT", typeIcon, "RIGHT", 15, 8) -- Position above center
            stepText:SetWidth(stepWidth - 80)
            stepText:SetJustifyH("LEFT")
            stepText:SetTextColor(1, 1, 1) -- Pure white like original
            stepText:SetText(step.text)
            
            -- Step location - positioned below step text
            if step.location then
                local locationText = stepBox:CreateFontString(nil, "OVERLAY")
                locationText:SetFont("Fonts\\FRIZQT__.TTF", 11)
                locationText:SetPoint("LEFT", typeIcon, "RIGHT", 15, -8)
                locationText:SetWidth(stepWidth - 80)
                locationText:SetJustifyH("LEFT")
                locationText:SetTextColor(0.9, 0.9, 0.6) -- Yellowish like original
                locationText:SetText(step.location)
            end
            
            yPos = yPos - 70 -- More spacing between panels
            totalHeight = totalHeight + 70
            
            -- Connection line between steps
            if i > 1 then
                local line = AT.scrollChild:CreateTexture(nil, "ARTWORK")
                line:SetTexture("Interface/Buttons/WHITE8X8") -- Simple line
                line:SetHeight(10)
                line:SetWidth(2)
                line:SetPoint("TOP", stepBox, "TOP", 0, 10)
                line:SetVertexColor(0.5, 0.8, 0.5) -- Green line
            end
        end
    end
    
    -- Set the total height of the scroll child
    AT.scrollChild:SetHeight(totalHeight + 50) -- Add some padding at bottom
    
    -- Update scroll range
    if AT.UpdateScrollRange then
        AT.UpdateScrollRange()
    end
    
    -- Reset scroll position to top
    if AT.scrollBar then
        AT.scrollBar:SetValue(0)
    end
end