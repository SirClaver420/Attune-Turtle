-- Attune-Turtle v1.0.3 - UI.lua
-- Contains all UI-related functions

-- Make sure AttuneTurtle exists
AttuneTurtle = AttuneTurtle or {}
local AT = AttuneTurtle  -- Local reference for faster access

-- This function will be called whenever the window is resized to redraw the layout.
function AT_RefreshLayout()
    if not AT.mainFrame then return end
    
    -- If we have a view selected, redraw it. Otherwise, redraw the landing page.
    if AT.selectedAttunement then
        AT_CreateAttunementView(AT.selectedAttunement)
    else
        AT_CreateLandingPage()
    end
    
    -- Always update the scroll range after a resize.
    if AT.UpdateScrollRange then
        AT.UpdateScrollRange()
    end
end

-- Create the main UI frame
function AT_CreateMainFrame()
    -- Main frame
    AT.mainFrame = CreateFrame("Frame", "AttuneTurtleMainFrame", UIParent)
    -- Use saved dimensions, falling back to defaults
    AT.mainFrame:SetWidth(AT.db.width or 1024)
    AT.mainFrame:SetHeight(AT.db.height or 600)
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
    AT.mainFrame:SetResizable(true) -- Make the frame resizable
    AT.mainFrame:SetMinResize(600, 400) -- Set minimum dimensions
    
    -- Register for ESC key
    tinsert(UISpecialFrames, "AttuneTurtleMainFrame")
    
    -- Make the entire frame draggable
    AT.mainFrame:RegisterForDrag("LeftButton")
    AT.mainFrame:SetScript("OnDragStart", function() 
        if not AT.mainFrame.isSizing then -- Only start moving if we are not resizing
            AT.mainFrame:StartMoving()
        end
    end)
    AT.mainFrame:SetScript("OnDragStop", function() 
        AT.mainFrame:StopMovingOrSizing()
        -- Save position and size
        AT.db.width = AT.mainFrame:GetWidth()
        AT.db.height = AT.mainFrame:GetHeight()
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
    
    -- Top-level close button
    local topCloseButton = CreateFrame("Button", nil, AT.mainFrame, "UIPanelCloseButton")
    topCloseButton:SetPoint("TOPRIGHT", AT.mainFrame, "TOPRIGHT", -5, -5)
    topCloseButton:SetScript("OnClick", function() AT.mainFrame:Hide() end)
    
    -- A single bottom panel to hold all bottom elements for consistent alignment.
    local bottomPanel = CreateFrame("Frame", nil, AT.mainFrame)
    bottomPanel:SetHeight(30) -- Adjusted height for tighter fit
    bottomPanel:SetPoint("BOTTOMLEFT", AT.mainFrame, "BOTTOMLEFT", 5, 5)
    bottomPanel:SetPoint("BOTTOMRIGHT", AT.mainFrame, "BOTTOMRIGHT", -5, 5)

    -- Close button (anchored to the bottom right of the panel)
    local closeBtn = CreateFrame("Button", nil, bottomPanel, "UIPanelButtonTemplate")
    closeBtn:SetWidth(80)
    closeBtn:SetHeight(25)
    closeBtn:SetText("Close")
    closeBtn:SetPoint("RIGHT", bottomPanel, "RIGHT", 0, 0)
    closeBtn:SetScript("OnClick", function() AT.mainFrame:Hide() end)

    -- Options button (anchored to the Close button)
    local optionsBtn = CreateFrame("Button", nil, bottomPanel, "UIPanelButtonTemplate")
    optionsBtn:SetWidth(80)
    optionsBtn:SetHeight(25)
    optionsBtn:SetText("Options")
    optionsBtn:SetPoint("RIGHT", closeBtn, "LEFT", -2, 0)
    optionsBtn:SetScript("OnClick", function()
        AT:ShowOptions() -- *** FIX: Changed ShowSettings to ShowOptions ***
    end)

    -- Version panel (stretches to fill remaining space)
    local versionPanel = CreateFrame("Frame", nil, bottomPanel)
    versionPanel:SetHeight(25)
    versionPanel:SetPoint("LEFT", bottomPanel, "LEFT", 0, 0)
    versionPanel:SetPoint("RIGHT", optionsBtn, "LEFT", -5, 0)
    versionPanel:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    versionPanel:SetBackdropColor(0, 0, 0, 0.7)

    -- Version text
    local versionText = versionPanel:CreateFontString(nil, "OVERLAY")
    versionText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    versionText:SetPoint("LEFT", versionPanel, "LEFT", 12, 0)
    -- *** CHANGE: Updated version string ***
    versionText:SetText("|cffd4af37Attune " .. (AT.version or "1.0.3") .. " by " .. (AT.author or "SirClaver420") .. "|r")

    -- Create sidebar (left panel), now anchored to the bottom panel for perfect alignment
    AT.sidebarFrame = CreateFrame("Frame", "AttuneTurtleSidebar", AT.mainFrame)
    AT.sidebarFrame:SetWidth(200)
    AT.sidebarFrame:SetPoint("TOPLEFT", AT.mainFrame, "TOPLEFT", 5, -30)
    AT.sidebarFrame:SetPoint("BOTTOMLEFT", bottomPanel, "TOPLEFT", 0, 2) -- Anchor to the top of the bottom panel
    AT.sidebarFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    AT.sidebarFrame:SetBackdropColor(0, 0, 0, 0.5)
    
    -- Create main content area, also anchored to the bottom panel
    AT.contentFrame = CreateFrame("Frame", "AttuneTurtleContent", AT.mainFrame)
    AT.contentFrame:SetPoint("TOPLEFT", AT.sidebarFrame, "TOPRIGHT", 2, 0)
    AT.contentFrame:SetPoint("BOTTOMRIGHT", bottomPanel, "TOPRIGHT", 0, 2) -- Anchor to the top of the bottom panel
    AT.contentFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    AT.contentFrame:SetBackdropColor(0, 0, 0, 0.3)
    
    -- Create simple scroll frame
    AT.scrollFrame = CreateFrame("ScrollFrame", "AttuneTurtleScrollFrame", AT.contentFrame)
    AT.scrollFrame:SetPoint("TOPLEFT", AT.contentFrame, "TOPLEFT", 8, -8)
    AT.scrollFrame:SetPoint("BOTTOMRIGHT", AT.contentFrame, "BOTTOMRIGHT", -30, 8)
    
    -- Create scroll bar
    AT.scrollBar = CreateFrame("Slider", "AttuneTurtleScrollBar", AT.scrollFrame)
    AT.scrollBar:SetPoint("TOPRIGHT", AT.contentFrame, "TOPRIGHT", -8, -8)
    AT.scrollBar:SetPoint("BOTTOMRIGHT", AT.contentFrame, "BOTTOMRIGHT", -8, 8)
    AT.scrollBar:SetWidth(16)
    AT.scrollBar:SetMinMaxValues(0, 100)
    AT.scrollBar:SetValue(0)
    AT.scrollBar:SetValueStep(1)
    
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
    
    AT.scrollChild = CreateFrame("Frame", "AttuneTurtleScrollChild", AT.scrollFrame)
    AT.scrollChild:SetWidth(1)
    AT.scrollChild:SetHeight(1)
    AT.scrollFrame:SetScrollChild(AT.scrollChild)
    
    local function UpdateScrollRange()
        local contentHeight = AT.scrollChild:GetHeight()
        local frameHeight = AT.scrollFrame:GetHeight()
        if frameHeight < 0 then frameHeight = 0 end
        local maxScroll = math.max(0, contentHeight - frameHeight)
        AT.scrollBar:SetMinMaxValues(0, maxScroll)
        if maxScroll > 0 then AT.scrollBar:Show() else AT.scrollBar:Hide() end
    end
    
    AT.scrollBar:SetScript("OnValueChanged", function()
        AT.scrollFrame:SetVerticalScroll(AT.scrollBar:GetValue())
    end)
    
    AT.scrollFrame:EnableMouseWheel(true)
    AT.scrollFrame:SetScript("OnMouseWheel", function()
        local delta = arg1 -- Use arg1 for mouse wheel delta
        local current = AT.scrollBar:GetValue()
        local min, max = AT.scrollBar:GetMinMaxValues()
        local newValue = current - (delta * 20)
        AT.scrollBar:SetValue(math.max(min, math.min(max, newValue)))
    end)
    
    AT.UpdateScrollRange = UpdateScrollRange
    
    -- Create the resize handle button
    local resizeButton = CreateFrame("Button", "AttuneTurtleResizeButton", AT.mainFrame)
    resizeButton:SetFrameStrata("HIGH") -- Set strata to be on top
    resizeButton:SetPoint("BOTTOMRIGHT", AT.mainFrame, "BOTTOMRIGHT", -3, 3)
    resizeButton:SetWidth(16)
    resizeButton:SetHeight(16)
    resizeButton:SetFrameLevel(AT.mainFrame:GetFrameLevel() + 5)
    
    local resizeTexture = resizeButton:CreateTexture(nil, "ARTWORK")
    resizeTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-Size-Up")
    resizeTexture:SetAllPoints()

    resizeButton:SetScript("OnMouseDown", function()
        AT.mainFrame:StartSizing("BOTTOMRIGHT")
        AT.mainFrame.isSizing = true
    end)
    resizeButton:SetScript("OnMouseUp", function()
        AT.mainFrame:StopMovingOrSizing()
        AT.mainFrame.isSizing = false
        -- Save the new dimensions
        AT.db.width = AT.mainFrame:GetWidth()
        AT.db.height = AT.mainFrame:GetHeight()
        -- Refresh the internal layout
        AT_RefreshLayout()
    end)
    
    AT.categoryStates = AT.db.categoryStates or {}
    
    AT.selectedAttunement = nil
    
    AT_PopulateSidebar()
    
    AT.mainFrame:SetScript("OnShow", function()
        -- OnShow, we want to show the landing page.
        AT_CreateLandingPage()
    end)
    
    AT.mainFrame:Hide()
end

-- Create the landing page
function AT_CreateLandingPage()
    if not AT.scrollChild or not AT.contentFrame then return end
    
    local children = {AT.scrollChild:GetChildren()}
    for _, child in ipairs(children) do child:Hide(); child:SetParent(nil) end
    local regions = {AT.scrollChild:GetRegions()}
    for _, region in ipairs(regions) do
        if region:GetObjectType() == "FontString" or region:GetObjectType() == "Texture" then region:Hide(); region:SetParent(nil) end
    end
    
    local availableWidth = AT.contentFrame:GetWidth() - 60
    if availableWidth <= 0 then return end -- Don't draw if frame is too small
    AT.scrollChild:SetWidth(availableWidth)
    
    local welcomeTitle = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    welcomeTitle:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
    welcomeTitle:SetPoint("TOP", AT.scrollChild, "TOP", 0, -40)
    welcomeTitle:SetWidth(availableWidth - 20)
    welcomeTitle:SetJustifyH("CENTER")
    welcomeTitle:SetText("|cff00ff00Welcome to Attune Turtle!|r")

    local welcomeIcon = AT.scrollChild:CreateTexture(nil, "ARTWORK")
    welcomeIcon:SetWidth(48); welcomeIcon:SetHeight(48)
    welcomeIcon:SetPoint("TOP", welcomeTitle, "BOTTOM", 0, -15)
    welcomeIcon:SetPoint("CENTER", AT.scrollChild, "CENTER", 0, 150) -- Adjust vertical offset as needed
    welcomeIcon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    
    local descText = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    descText:SetFont("Fonts\\FRIZQT__.TTF", 14)
    descText:SetPoint("TOP", welcomeIcon, "BOTTOM", 0, -20)
    descText:SetWidth(availableWidth - 20)
    descText:SetJustifyH("CENTER")
    descText:SetText("|cffffffffAttune Turtle helps you track your attunement progress for dungeons and raids.|r")
    
    local featuresTitle = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    featuresTitle:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    featuresTitle:SetPoint("TOP", descText, "BOTTOM", 0, -40)
    featuresTitle:SetText("|cffffff00Features:|r")
    
    local featuresContainer = CreateFrame("Frame", nil, AT.scrollChild)
    featuresContainer:SetWidth(320); featuresContainer:SetHeight(100)
    featuresContainer:SetPoint("TOP", featuresTitle, "BOTTOM", 0, -20)
    
    local feature1Icon = featuresContainer:CreateTexture(nil, "ARTWORK")
    feature1Icon:SetWidth(16); feature1Icon:SetHeight(16)
    feature1Icon:SetPoint("TOPLEFT", featuresContainer, "TOPLEFT", 0, 0)
    feature1Icon:SetTexture("Interface\\Icons\\INV_Misc_Key_11")
    
    local feature1Text = featuresContainer:CreateFontString(nil, "OVERLAY")
    feature1Text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    feature1Text:SetPoint("LEFT", feature1Icon, "RIGHT", 10, 0)
    feature1Text:SetWidth(290); feature1Text:SetJustifyH("LEFT")
    feature1Text:SetText("|cffffffffTrack dungeon key requirements and steps|r")
    
    local feature2Icon = featuresContainer:CreateTexture(nil, "ARTWORK")
    feature2Icon:SetWidth(16); feature2Icon:SetHeight(16)
    feature2Icon:SetPoint("TOP", feature1Icon, "BOTTOM", 0, -15)
    feature2Icon:SetTexture("Interface\\Icons\\INV_Hammer_Unique_Sulfuras")
    
    local feature2Text = featuresContainer:CreateFontString(nil, "OVERLAY")
    feature2Text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    feature2Text:SetPoint("LEFT", feature2Icon, "RIGHT", 10, 0)
    feature2Text:SetWidth(290); feature2Text:SetJustifyH("LEFT")
    feature2Text:SetText("|cffffffffView raid attunement chains and progress|r")
    
    local feature3Icon = featuresContainer:CreateTexture(nil, "ARTWORK")
    feature3Icon:SetWidth(16); feature3Icon:SetHeight(16)
    feature3Icon:SetPoint("TOP", feature2Icon, "BOTTOM", 0, -15)
    feature3Icon:SetTexture("Interface\\Icons\\INV_Misc_Note_01")
    
    local feature3Text = featuresContainer:CreateFontString(nil, "OVERLAY")
    feature3Text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    feature3Text:SetPoint("LEFT", feature3Icon, "RIGHT", 10, 0)
    feature3Text:SetWidth(290); feature3Text:SetJustifyH("LEFT")
    feature3Text:SetText("|cffffffffStep-by-step quest and item guidance|r")
    
    local startTitle = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    startTitle:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    startTitle:SetPoint("TOP", featuresContainer, "BOTTOM", 0, -40)
    startTitle:SetText("|cffffff00Getting Started:|r")
    
    local startText = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    startText:SetFont("Fonts\\FRIZQT__.TTF", 12)
    startText:SetPoint("TOP", startTitle, "BOTTOM", 0, -15)
    startText:SetWidth(availableWidth - 20)
    startText:SetJustifyH("CENTER")
    startText:SetText("|cffffffffSelect a dungeon or raid from the left panel to view its attunement requirements.\n\nEach step will show you exactly what you need to do and where to go.|r")
    
    local turtleNote = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    turtleNote:SetFont("Fonts\\FRIZQT__.TTF", 11)
    turtleNote:SetPoint("TOP", startText, "BOTTOM", 0, -30)
    turtleNote:SetWidth(availableWidth - 60)
    turtleNote:SetJustifyH("CENTER")
    turtleNote:SetTextColor(0.8, 0.8, 1.0)
    turtleNote:SetText("|cffaaccffOptimized for Turtle WoW - Happy adventuring!|r")
    
    local extraContent = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    extraContent:SetFont("Fonts\\FRIZQT__.TTF", 10)
    extraContent:SetPoint("TOP", turtleNote, "BOTTOM", 0, -50)
    extraContent:SetWidth(availableWidth - 60)
    extraContent:SetJustifyH("CENTER")
    extraContent:SetTextColor(0.5, 0.5, 0.5)
    extraContent:SetText("|cff808080Additional Features Coming Soon:\n\n• Quest completion tracking (if possible)\n• Progress saving\n• Character-specific progress\n• Export/Import functionality\n• Custom notes\n\n\n\nThis content extends beyond the visible area to test scrolling functionality.\n\n\n\nEnd of content.|r")
    
    AT.scrollChild:SetHeight(800) -- INCREASED HEIGHT TO MAKE SCROLLING NECESSARY
    
    if AT.UpdateScrollRange then AT.UpdateScrollRange() end
    if AT.scrollBar then AT.scrollBar:SetValue(0) end
    
    AT.selectedAttunement = nil
    
    if AT.sidebarItems then
        for key, item in pairs(AT.sidebarItems) do
            if item and item.SetSelected then item:SetSelected(false) end
        end
    end
    
    if AT.homeButton and AT.homeButton.SetSelected then AT.homeButton:SetSelected(true) end
end

function AT_SelectAttunement(attunementKey)
    if not attunementKey or not AT.attunements[attunementKey] then return end
    
    AT.selectedAttunement = attunementKey
    
    if AT.sidebarItems then
        for key, item in pairs(AT.sidebarItems) do
            if item and item.SetSelected then item:SetSelected(key == attunementKey) end
        end
    end
    
    if AT.homeButton and AT.homeButton.SetSelected then AT.homeButton:SetSelected(false) end
    
    AT_CreateAttunementView(attunementKey)
end

function AT_CreateHomeButton(yPos)
    local itemFrame = CreateFrame("Button", "ATItem_Home", AT.sidebarFrame)
    itemFrame:SetHeight(20)
    itemFrame:SetPoint("TOPLEFT", AT.sidebarFrame, "TOPLEFT", 15, yPos)
    itemFrame:SetPoint("TOPRIGHT", AT.sidebarFrame, "TOPRIGHT", -5, yPos)
    itemFrame:EnableMouse(true)
    
    local icon = itemFrame:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(16); icon:SetHeight(16)
    icon:SetPoint("LEFT", itemFrame, "LEFT", 0, 0)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    
    local text = itemFrame:CreateFontString(nil, "OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
    text:SetText("|cffffffffHome|r")
    
    itemFrame.SetSelected = function(frame, selected)
        if selected then frame:LockHighlight() else frame:UnlockHighlight() end
    end
    
    itemFrame:SetScript("OnClick", AT_CreateLandingPage)
    itemFrame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    AT.homeButton = itemFrame
    return itemFrame
end

function AT_CreateSidebarItem(attunementKey, yPos)
    local attunement = AT.attunements[attunementKey]
    if not attunement then return nil end
    
    local itemFrame = CreateFrame("Button", "ATItem_" .. attunementKey, AT.sidebarFrame)
    itemFrame:SetHeight(20)
    itemFrame:SetPoint("TOPLEFT", AT.sidebarFrame, "TOPLEFT", 15, yPos)
    itemFrame:SetPoint("TOPRIGHT", AT.sidebarFrame, "TOPRIGHT", -5, yPos)
    itemFrame:EnableMouse(true)
    
    local icon = itemFrame:CreateTexture(nil, "ARTWORK")
    icon:SetWidth(16); icon:SetHeight(16)
    icon:SetPoint("LEFT", itemFrame, "LEFT", 0, 0)
    icon:SetTexture(attunement.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    
    local text = itemFrame:CreateFontString(nil, "OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", 12)
    text:SetPoint("LEFT", icon, "RIGHT", 5, 0)
    text:SetText("|cffffffff" .. attunement.name .. "|r")
    
    itemFrame.attunementKey = attunementKey
    
    itemFrame.SetSelected = function(frame, selected)
        if selected then frame:LockHighlight() else frame:UnlockHighlight() end
    end
    
    itemFrame:SetScript("OnClick", function() AT_SelectAttunement(itemFrame.attunementKey) end)
    itemFrame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    itemFrame:SetSelected(attunementKey == AT.selectedAttunement)
    return itemFrame
end

function AT_CreateCategoryHeader(categoryName, yPos)
    local isExpanded = AT.db.categoryStates[categoryName]
    
    local headerFrame = CreateFrame("Button", nil, AT.sidebarFrame)
    headerFrame:SetHeight(20)
    headerFrame:SetPoint("TOPLEFT", AT.sidebarFrame, "TOPLEFT", 5, yPos)
    headerFrame:SetPoint("TOPRIGHT", AT.sidebarFrame, "TOPRIGHT", -5, yPos)
    headerFrame:EnableMouse(true)
    
    local headerText = headerFrame:CreateFontString(nil, "OVERLAY")
    headerText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    headerText:SetPoint("LEFT", headerFrame, "LEFT", 10, 0)
    headerText:SetText("|cffffff00" .. categoryName .. "|r")
    
    local expandBtn = headerFrame:CreateTexture(nil, "ARTWORK")
    expandBtn:SetWidth(16); expandBtn:SetHeight(16)
    expandBtn:SetPoint("RIGHT", headerFrame, "RIGHT", -5, 0)
    expandBtn:SetTexture(isExpanded and "Interface\\Buttons\\UI-MinusButton-Up" or "Interface\\Buttons\\UI-PlusButton-Up")
    
    headerFrame.categoryName = categoryName
    
    headerFrame:SetScript("OnClick", function()
        -- Note: We refer to the button as 'headerFrame' here, not 'self'
        AT.db.categoryStates[headerFrame.categoryName] = not AT.db.categoryStates[headerFrame.categoryName]
        AT_PopulateSidebar()
    end)
    
    headerFrame:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
    return headerFrame
end

function AT_PopulateSidebar()
    if AT.sidebarElements then
        for _, element in ipairs(AT.sidebarElements) do element:Hide() end
    end
    
    AT.sidebarElements = {}
    AT.sidebarItems = AT.sidebarItems or {}
    
    local yPos = -10
    
    local homeButton = AT_CreateHomeButton(yPos)
    table.insert(AT.sidebarElements, homeButton)
    yPos = yPos - 25
    
    for i, category in ipairs(AT.categories) do
        local isExpanded = AT.db.categoryStates[category.name]
        local header = AT_CreateCategoryHeader(category.name, yPos)
        table.insert(AT.sidebarElements, header)
        yPos = yPos - 25
        
        if isExpanded then
            for _, attunementKey in ipairs(category.items) do
                local item = AT_CreateSidebarItem(attunementKey, yPos)
                if item then
                    table.insert(AT.sidebarElements, item)
                    AT.sidebarItems[attunementKey] = item
                    yPos = yPos - 20
                end
            end
        end
    end
end

function AT:CheckStepStatus(step)
    if not step.check then return false end
    if step.check.type == "level" then return (UnitLevel("player") >= step.check.value) end
    return false
end

function AT_CreateAttunementView(attunementKey)
    attunementKey = attunementKey or AT.selectedAttunement
    if not attunementKey or not AT.attunements[attunementKey] then return end
    if not AT.contentFrame or AT.contentFrame:GetWidth() <= 1 then return end

    if AT.scrollChild then
        local children = {AT.scrollChild:GetChildren()}
        for _, child in ipairs(children) do child:Hide(); child:SetParent(nil) end
        local regions = {AT.scrollChild:GetRegions()}
        for _, region in ipairs(regions) do
            if region:GetObjectType() == "FontString" or region:GetObjectType() == "Texture" then region:Hide(); region:SetParent(nil) end
        end
    end
    
    local attunementData = AT.attunements[attunementKey]
    if not attunementData then return end
    
    local availableWidth = AT.contentFrame:GetWidth() - 40
    if availableWidth <= 0 then return end
    AT.scrollChild:SetWidth(availableWidth)
    
    local titleIcon = AT.scrollChild:CreateTexture(nil, "ARTWORK")
    titleIcon:SetWidth(32); titleIcon:SetHeight(32)
    titleIcon:SetPoint("TOPLEFT", AT.scrollChild, "TOPLEFT", 15, -15)
    titleIcon:SetTexture(attunementData.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    
    local attunementTitle = AT.scrollChild:CreateFontString(nil, "OVERLAY")
    attunementTitle:SetFont("Fonts\\FRIZQT__.TTF", 18, "OUTLINE")
    attunementTitle:SetPoint("LEFT", titleIcon, "RIGHT", 10, 0)
    attunementTitle:SetText(attunementData.name)
    
    if not attunementData.steps[1] or not attunementData.steps[1].x then
        local currentY = -80
        for i, step in ipairs(attunementData.steps) do
            -- *** NEW 3-TIER LOGIC ***
            local iconTexture = AT.icons.scroll -- Default icon
            if step.icon then
                -- 1. Use the hardcoded icon string if it exists
                iconTexture = step.icon
            elseif step.itemID then
                -- 2. Try to get the icon from the item ID
                local _, _, _, _, _, _, _, _, texture = GetItemInfo(step.itemID)
                if texture then
                    iconTexture = texture
                end
            elseif step.type and AT.icons[step.type] then
                -- 3. Fallback to our hardcoded type icons
                iconTexture = AT.icons[step.type]
            end

            -- Create the icon for the step
            local icon = AT.scrollChild:CreateTexture(nil, "ARTWORK")
            icon:SetWidth(18); icon:SetHeight(18)
            icon:SetPoint("TOPLEFT", AT.scrollChild, "TOPLEFT", 20, currentY)
            icon:SetTexture(iconTexture)

            -- Create the text, anchored to the new icon
            local fallbackText = AT.scrollChild:CreateFontString(nil, "OVERLAY")
            fallbackText:SetFont("Fonts\\FRIZQT__.TTF", 12)
            fallbackText:SetPoint("LEFT", icon, "RIGHT", 8, 0)
            fallbackText:SetWidth(availableWidth - 40 - 25) -- Adjust width for icon
            fallbackText:SetJustifyH("LEFT")
            fallbackText:SetText((step.title or "Step " .. i) .. ": " .. (step.text or "No details available."))
            
            -- Adjust Y position for the next element
            local textHeight = fallbackText:GetHeight()
            local iconHeight = 18
            currentY = currentY - math.max(textHeight, iconHeight) - 10
        end
        AT.scrollChild:SetHeight(math.abs(currentY) + 50)
        if AT.UpdateScrollRange then AT.UpdateScrollRange() end
        if AT.scrollBar then AT.scrollBar:SetValue(0) end
        return
    end

    local stepFrames = {}
    local minY = 0

    for i, step in ipairs(attunementData.steps) do
        local stepBox = CreateFrame("Frame", "AttuneTurtleStep_" .. step.id, AT.scrollChild)
        stepBox:SetWidth(180); stepBox:SetHeight(45)
        stepBox:SetPoint("CENTER", AT.scrollChild, "TOPLEFT", step.x + (availableWidth/2), step.y - 80)
        stepBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })

        if AT:CheckStepStatus(step) then stepBox:SetBackdropColor(0.1, 0.6, 0.1, 0.8) else stepBox:SetBackdropColor(0.15, 0.15, 0.15, 0.8) end

        local typeIcon = stepBox:CreateTexture(nil, "ARTWORK")
        typeIcon:SetWidth(28); typeIcon:SetHeight(28)
        typeIcon:SetPoint("LEFT", stepBox, "LEFT", 8, 0)
        
        -- *** NEW 3-TIER LOGIC for flowchart view ***
        local iconTexture = AT.icons.scroll -- Default icon
        if step.icon then
            -- 1. Use the hardcoded icon string if it exists
            iconTexture = step.icon
        elseif step.itemID then
            -- 2. Try to get the icon from the item ID
            local _, _, _, _, _, _, _, _, texture = GetItemInfo(step.itemID)
            if texture then
                iconTexture = texture
            end
        elseif step.type and AT.icons[step.type] then
            -- 3. Fallback to our hardcoded type icons
            iconTexture = AT.icons[step.type]
        end
        typeIcon:SetTexture(iconTexture)

        local stepTitle = stepBox:CreateFontString(nil, "OVERLAY")
        stepTitle:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
        stepTitle:SetPoint("TOPLEFT", typeIcon, "RIGHT", 8, 5)
        stepTitle:SetWidth(130); stepTitle:SetJustifyH("LEFT")
        stepTitle:SetText(step.title or "Unknown Step")

        local stepSubtext = stepBox:CreateFontString(nil, "OVERLAY")
        stepSubtext:SetFont("Fonts\\FRIZQT__.TTF", 10)
        stepSubtext:SetPoint("TOPLEFT", stepTitle, "BOTTOMLEFT", 0, -2)
        stepSubtext:SetWidth(130); stepSubtext:SetJustifyH("LEFT")
        stepSubtext:SetTextColor(0.8, 0.8, 0.8)
        stepSubtext:SetText(step.subtext or "")

        stepFrames[step.id] = stepBox
        minY = math.min(minY, step.y - 45)
    end

    for i, step in ipairs(attunementData.steps) do
        if step.previousStep then
            local toFrame = stepFrames[step.id]
            
            local function drawVerticalLine(fromFrame, toFrame)
                if fromFrame and toFrame then
                    local line = AT.scrollChild:CreateTexture(nil, "BACKGROUND")
                    line:SetTexture("Interface\\Buttons\\WHITE8X8")
                    line:SetPoint("TOP", fromFrame, "BOTTOM")
                    line:SetPoint("BOTTOM", toFrame, "TOP")
                    line:SetWidth(3)
                    line:SetVertexColor(0.2, 0.6, 0.2, 0.7)
                end
            end

            if type(step.previousStep) == "table" then
                local fromFrames = {}
                for _, prevId in ipairs(step.previousStep) do
                    if stepFrames[prevId] then table.insert(fromFrames, stepFrames[prevId]) end
                end
                
                if table.getn(fromFrames) > 0 then
                    local hLine = AT.scrollChild:CreateTexture(nil, "BACKGROUND")
                    hLine:SetTexture("Interface\\Buttons\\WHITE8X8")
                    hLine:SetPoint("LEFT", fromFrames[1], "BOTTOM", 0, -10)
                    hLine:SetPoint("RIGHT", fromFrames[table.getn(fromFrames)], "BOTTOM", 0, -10)
                    hLine:SetHeight(3)
                    hLine:SetVertexColor(0.2, 0.6, 0.2, 0.7)

                    for _, fromFrame in ipairs(fromFrames) do
                        local vLine = AT.scrollChild:CreateTexture(nil, "BACKGROUND")
                        vLine:SetTexture("Interface\\Buttons\\WHITE8X8")
                        vLine:SetPoint("TOP", fromFrame, "BOTTOM")
                        vLine:SetPoint("BOTTOM", hLine, "TOP", fromFrame:GetCenter() - hLine:GetLeft(), 0)
                        vLine:SetWidth(3)
                        vLine:SetVertexColor(0.2, 0.6, 0.2, 0.7)
                    end
                    
                    local mainVLine = AT.scrollChild:CreateTexture(nil, "BACKGROUND")
                    mainVLine:SetTexture("Interface\\Buttons\\WHITE8X8")
                    mainVLine:SetPoint("TOP", hLine, "BOTTOM", toFrame:GetCenter() - hLine:GetLeft(), 0)
                    mainVLine:SetPoint("BOTTOM", toFrame, "TOP")
                    mainVLine:SetWidth(3)
                    mainVLine:SetVertexColor(0.2, 0.6, 0.2, 0.7)
                end
            else
                drawVerticalLine(stepFrames[step.previousStep], toFrame)
            end
        end
    end

    AT.scrollChild:SetHeight(math.abs(minY) + 100)
    if AT.UpdateScrollRange then AT.UpdateScrollRange() end
    if AT.scrollBar then AT.scrollBar:SetValue(0) end
end