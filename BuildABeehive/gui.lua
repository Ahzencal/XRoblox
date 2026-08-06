-- BuildABeehive/gui.lua
-- IndoVoice-style split layout with real tabs, a clean overview, and a simple actions pane.

return function(config)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local theme = config.Theme or {}

    if _G.__BuildABeehive_Destroy then
        pcall(_G.__BuildABeehive_Destroy)
    end
    _G.__BuildABeehive_Destroy = nil

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BuildABeehive_GUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 999
    pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
    if not screenGui.Parent then
        screenGui.Parent = lp:WaitForChild("PlayerGui")
    end

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 620, 0, 420)
    main.Position = UDim2.new(0.5, -310, 0.5, -210)
    main.BackgroundColor3 = theme.bg or Color3.fromRGB(18, 18, 24)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = screenGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Color = theme.accent or Color3.fromRGB(80, 180, 255)
    mainStroke.Transparency = 0.25
    mainStroke.Thickness = 1

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 36)
    topBar.BackgroundColor3 = theme.topbar or Color3.fromRGB(20, 20, 28)
    topBar.BorderSizePixel = 0
    topBar.Active = true
    topBar.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 200, 1, 0)
    title.Position = UDim2.new(0, 14, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Build A Beehive"
    title.TextColor3 = theme.text or Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topBar

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0, 300, 1, 0)
    subtitle.Position = UDim2.new(0, 14, 0, 14)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Clean honey tools with the same wide layout as IndoVoice"
    subtitle.TextColor3 = theme.dim or Color3.fromRGB(130, 130, 145)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 9
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = topBar

    local minBtn = Instance.new("TextButton")
    minBtn.Text = "-"
    minBtn.Size = UDim2.new(0, 28, 0, 22)
    minBtn.Position = UDim2.new(1, -64, 0, 6)
    minBtn.BackgroundColor3 = theme.panel2 or Color3.fromRGB(40, 40, 52)
    minBtn.TextColor3 = theme.dim or Color3.fromRGB(130, 130, 145)
    minBtn.Font = Enum.Font.GothamBold
    minBtn.TextSize = 14
    minBtn.BorderSizePixel = 0
    minBtn.Parent = topBar
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "x"
    closeBtn.Size = UDim2.new(0, 28, 0, 22)
    closeBtn.Position = UDim2.new(1, -32, 0, 6)
    closeBtn.BackgroundColor3 = theme.danger or Color3.fromRGB(255, 80, 100)
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 13
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = topBar
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

    local dragHit = Instance.new("TextButton")
    dragHit.Size = UDim2.new(1, -96, 1, 0)
    dragHit.BackgroundTransparency = 1
    dragHit.Text = ""
    dragHit.Parent = topBar

    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.new(0, 130, 1, -36)
    sidebar.Position = UDim2.new(0, 0, 0, 36)
    sidebar.BackgroundColor3 = theme.sidebar or theme.bg2 or Color3.fromRGB(22, 22, 30)
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main

    local sideTitle = Instance.new("TextLabel")
    sideTitle.Size = UDim2.new(1, 0, 0, 32)
    sideTitle.Position = UDim2.new(0, 0, 0, 10)
    sideTitle.BackgroundTransparency = 1
    sideTitle.Text = "Beehive"
    sideTitle.TextColor3 = theme.text or Color3.new(1, 1, 1)
    sideTitle.Font = Enum.Font.GothamBold
    sideTitle.TextSize = 15
    sideTitle.Parent = sidebar

    local sideSub = Instance.new("TextLabel")
    sideSub.Size = UDim2.new(1, 0, 0, 14)
    sideSub.Position = UDim2.new(0, 0, 0, 42)
    sideSub.BackgroundTransparency = 1
    sideSub.Text = "Auto tools"
    sideSub.TextColor3 = theme.dim or Color3.fromRGB(130, 130, 145)
    sideSub.Font = Enum.Font.Gotham
    sideSub.TextSize = 10
    sideSub.Parent = sidebar

    local sidebarLine = Instance.new("Frame")
    sidebarLine.Size = UDim2.new(0.72, 0, 0, 1)
    sidebarLine.AnchorPoint = Vector2.new(0.5, 0)
    sidebarLine.Position = UDim2.new(0.5, 0, 0, 64)
    sidebarLine.BackgroundColor3 = theme.panel2 or Color3.fromRGB(40, 40, 52)
    sidebarLine.BorderSizePixel = 0
    sidebarLine.Parent = sidebar

    local tabOverviewBtn = Instance.new("TextButton")
    tabOverviewBtn.Size = UDim2.new(1, -16, 0, 34)
    tabOverviewBtn.Position = UDim2.new(0, 8, 0, 76)
    tabOverviewBtn.BackgroundColor3 = theme.accent or Color3.fromRGB(80, 180, 255)
    tabOverviewBtn.BackgroundTransparency = 0.1
    tabOverviewBtn.Text = "Overview"
    tabOverviewBtn.TextColor3 = theme.text or Color3.new(1, 1, 1)
    tabOverviewBtn.Font = Enum.Font.GothamBold
    tabOverviewBtn.TextSize = 12
    tabOverviewBtn.BorderSizePixel = 0
    tabOverviewBtn.Parent = sidebar
    Instance.new("UICorner", tabOverviewBtn).CornerRadius = UDim.new(0, 8)

    local tabActionsBtn = Instance.new("TextButton")
    tabActionsBtn.Size = UDim2.new(1, -16, 0, 34)
    tabActionsBtn.Position = UDim2.new(0, 8, 0, 118)
    tabActionsBtn.BackgroundColor3 = theme.panel2 or Color3.fromRGB(40, 40, 52)
    tabActionsBtn.Text = "Actions"
    tabActionsBtn.TextColor3 = theme.dim or Color3.fromRGB(130, 130, 145)
    tabActionsBtn.Font = Enum.Font.GothamBold
    tabActionsBtn.TextSize = 12
    tabActionsBtn.BorderSizePixel = 0
    tabActionsBtn.Parent = sidebar
    Instance.new("UICorner", tabActionsBtn).CornerRadius = UDim.new(0, 8)

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -142, 1, -48)
    content.Position = UDim2.new(0, 136, 0, 42)
    content.BackgroundColor3 = theme.panel or Color3.fromRGB(24, 24, 32)
    content.BorderSizePixel = 0
    content.ClipsDescendants = true
    content.Parent = main
    Instance.new("UICorner", content).CornerRadius = UDim.new(0, 10)

    local contentStroke = Instance.new("UIStroke", content)
    contentStroke.Color = theme.panel2 or Color3.fromRGB(40, 40, 52)
    contentStroke.Thickness = 1

    local overviewTab = Instance.new("Frame")
    overviewTab.Name = "OverviewTab"
    overviewTab.Size = UDim2.new(1, 0, 1, 0)
    overviewTab.BackgroundTransparency = 1
    overviewTab.Parent = content

    local actionsTab = Instance.new("Frame")
    actionsTab.Name = "ActionsTab"
    actionsTab.Size = UDim2.new(1, 0, 1, 0)
    actionsTab.BackgroundTransparency = 1
    actionsTab.Visible = false
    actionsTab.Parent = content

    local function applyTab(activeTab)
        local showOverview = activeTab == "Overview"
        overviewTab.Visible = showOverview
        actionsTab.Visible = not showOverview

        tabOverviewBtn.BackgroundColor3 = showOverview and (theme.accent or Color3.fromRGB(80, 180, 255)) or (theme.panel2 or Color3.fromRGB(40, 40, 52))
        tabOverviewBtn.BackgroundTransparency = showOverview and 0.1 or 0
        tabOverviewBtn.TextColor3 = showOverview and (theme.text or Color3.new(1, 1, 1)) or (theme.dim or Color3.fromRGB(130, 130, 145))

        tabActionsBtn.BackgroundColor3 = (not showOverview) and (theme.accent or Color3.fromRGB(80, 180, 255)) or (theme.panel2 or Color3.fromRGB(40, 40, 52))
        tabActionsBtn.BackgroundTransparency = (not showOverview) and 0.1 or 0
        tabActionsBtn.TextColor3 = (not showOverview) and (theme.text or Color3.new(1, 1, 1)) or (theme.dim or Color3.fromRGB(130, 130, 145))
    end

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -24, 0, 18)
    status.Position = UDim2.new(0, 12, 0, 10)
    status.BackgroundTransparency = 1
    status.Text = "Status: OFF"
    status.TextColor3 = theme.danger or Color3.fromRGB(255, 80, 80)
    status.Font = Enum.Font.GothamBold
    status.TextSize = 13
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = overviewTab

    local hero = Instance.new("TextLabel")
    hero.Size = UDim2.new(1, -24, 0, 26)
    hero.Position = UDim2.new(0, 12, 0, 34)
    hero.BackgroundTransparency = 1
    hero.Text = "Automation dashboard"
    hero.TextColor3 = theme.text or Color3.new(1, 1, 1)
    hero.Font = Enum.Font.GothamBold
    hero.TextSize = 18
    hero.TextXAlignment = Enum.TextXAlignment.Left
    hero.Parent = overviewTab

    local helper = Instance.new("TextLabel")
    helper.Size = UDim2.new(1, -24, 0, 16)
    helper.Position = UDim2.new(0, 12, 0, 58)
    helper.BackgroundTransparency = 1
    helper.Text = "Stats at a glance. Actions on the next tab."
    helper.TextColor3 = theme.dim or Color3.fromRGB(130, 130, 145)
    helper.Font = Enum.Font.Gotham
    helper.TextSize = 10
    helper.TextXAlignment = Enum.TextXAlignment.Left
    helper.Parent = overviewTab

    local statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(0, 300, 0, 118)
    statsFrame.Position = UDim2.new(0, 12, 0, 82)
    statsFrame.BackgroundColor3 = theme.panel or Color3.fromRGB(24, 24, 32)
    statsFrame.BorderSizePixel = 0
    statsFrame.Parent = overviewTab
    Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 10)

    local statsGrid = Instance.new("UIGridLayout")
    statsGrid.CellPadding = UDim2.new(0, 8, 0, 8)
    statsGrid.CellSize = UDim2.new(0.5, -4, 0.5, -4)
    statsGrid.SortOrder = Enum.SortOrder.LayoutOrder
    statsGrid.Parent = statsFrame

    local statsPadding = Instance.new("UIPadding")
    statsPadding.PaddingTop = UDim.new(0, 8)
    statsPadding.PaddingBottom = UDim.new(0, 8)
    statsPadding.PaddingLeft = UDim.new(0, 8)
    statsPadding.PaddingRight = UDim.new(0, 8)
    statsPadding.Parent = statsFrame

    local function makeStatCard(labelText, order)
        local card = Instance.new("Frame")
        card.BackgroundColor3 = theme.panel2 or Color3.fromRGB(34, 34, 44)
        card.BorderSizePixel = 0
        card.LayoutOrder = order
        card.Parent = statsFrame
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -8, 0, 12)
        label.Position = UDim2.new(0, 4, 0, 4)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = theme.dim or Color3.fromRGB(130, 130, 145)
        label.Font = Enum.Font.Gotham
        label.TextSize = 9
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = card

        local value = Instance.new("TextLabel")
        value.Size = UDim2.new(1, -8, 0, 18)
        value.Position = UDim2.new(0, 4, 0, 18)
        value.BackgroundTransparency = 1
        value.Text = "0"
        value.TextColor3 = theme.text or Color3.new(1, 1, 1)
        value.Font = Enum.Font.GothamBold
        value.TextSize = 14
        value.TextXAlignment = Enum.TextXAlignment.Left
        value.Parent = card

        return value
    end

    local fpsValue = makeStatCard("FPS", 1)
    local pingValue = makeStatCard("PING", 2)
    local playerCountValue = makeStatCard("PLAYER COUNT", 3)
    local totalHiveValue = makeStatCard("TOTAL HIVE", 4)

    local note = Instance.new("TextLabel")
    note.Size = UDim2.new(1, -24, 0, 14)
    note.Position = UDim2.new(0, 12, 0, 208)
    note.BackgroundTransparency = 1
    note.Text = "Auto-buy coming soon"
    note.TextColor3 = theme.dim or Color3.fromRGB(130, 130, 145)
    note.Font = Enum.Font.Gotham
    note.TextSize = 10
    note.TextXAlignment = Enum.TextXAlignment.Left
    note.Parent = overviewTab

    local actionHeader = Instance.new("TextLabel")
    actionHeader.Size = UDim2.new(1, -24, 0, 24)
    actionHeader.Position = UDim2.new(0, 12, 0, 16)
    actionHeader.BackgroundTransparency = 1
    actionHeader.Text = "Actions"
    actionHeader.TextColor3 = theme.text or Color3.new(1, 1, 1)
    actionHeader.Font = Enum.Font.GothamBold
    actionHeader.TextSize = 18
    actionHeader.TextXAlignment = Enum.TextXAlignment.Left
    actionHeader.Parent = actionsTab

    local actionSub = Instance.new("TextLabel")
    actionSub.Size = UDim2.new(1, -24, 0, 16)
    actionSub.Position = UDim2.new(0, 12, 0, 40)
    actionSub.BackgroundTransparency = 1
    actionSub.Text = "Keep each automation toggle separate."
    actionSub.TextColor3 = theme.dim or Color3.fromRGB(130, 130, 145)
    actionSub.Font = Enum.Font.Gotham
    actionSub.TextSize = 10
    actionSub.TextXAlignment = Enum.TextXAlignment.Left
    actionSub.Parent = actionsTab

    local function makeIntervalSetting(labelText, placeholder, y)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 140, 0, 18)
        label.Position = UDim2.new(0, 12, 0, y)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = theme.dim or Color3.fromRGB(130, 130, 145)
        label.Font = Enum.Font.Gotham
        label.TextSize = 10
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = actionsTab

        local input = Instance.new("TextBox")
        input.Size = UDim2.new(0, 72, 0, 22)
        input.Position = UDim2.new(0, 150, 0, y - 2)
        input.BackgroundColor3 = theme.bg2 or Color3.fromRGB(22, 22, 30)
        input.TextColor3 = theme.text or Color3.new(1, 1, 1)
        input.PlaceholderText = placeholder
        input.PlaceholderColor3 = theme.dim or Color3.fromRGB(130, 130, 145)
        input.ClearTextOnFocus = false
        input.Font = Enum.Font.Code
        input.TextSize = 10
        input.BorderSizePixel = 0
        input.Parent = actionsTab
        Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

        return label, input
    end

    local collectIntervalLbl, collectIntervalInput = makeIntervalSetting("Collect interval (s)", "2", 56)
    local sellIntervalLbl, sellIntervalInput = makeIntervalSetting("Sell interval (s)", "5", 84)

    local collectButton = Instance.new("TextButton")
    collectButton.Size = UDim2.new(0, 240, 0, 34)
    collectButton.Position = UDim2.new(0, 12, 0, 122)
    collectButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    collectButton.Text = "Collect: OFF"
    collectButton.TextScaled = true
    collectButton.BorderSizePixel = 0
    collectButton.Parent = actionsTab
    Instance.new("UICorner", collectButton).CornerRadius = UDim.new(0, 8)

    local sellButton = Instance.new("TextButton")
    sellButton.Size = UDim2.new(0, 240, 0, 34)
    sellButton.Position = UDim2.new(0, 12, 0, 164)
    sellButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    sellButton.Text = "Sell: OFF"
    sellButton.TextScaled = true
    sellButton.BorderSizePixel = 0
    sellButton.Parent = actionsTab
    Instance.new("UICorner", sellButton).CornerRadius = UDim.new(0, 8)

    local depositAuroraButton = Instance.new("TextButton")
    depositAuroraButton.Size = UDim2.new(0, 240, 0, 34)
    depositAuroraButton.Position = UDim2.new(0, 12, 0, 206)
    depositAuroraButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    depositAuroraButton.Text = "Aurora: OFF"
    depositAuroraButton.TextScaled = true
    depositAuroraButton.BorderSizePixel = 0
    depositAuroraButton.Parent = actionsTab
    Instance.new("UICorner", depositAuroraButton).CornerRadius = UDim.new(0, 8)

    local soonLbl = Instance.new("TextLabel")
    soonLbl.Size = UDim2.new(1, -24, 0, 14)
    soonLbl.Position = UDim2.new(0, 12, 0, 252)
    soonLbl.BackgroundTransparency = 1
    soonLbl.Text = "Auto-buy coming soon"
    soonLbl.TextColor3 = theme.dim or Color3.fromRGB(130, 130, 145)
    soonLbl.Font = Enum.Font.Gotham
    soonLbl.TextSize = 10
    soonLbl.TextXAlignment = Enum.TextXAlignment.Left
    soonLbl.Parent = actionsTab

    local mini = Instance.new("Frame")
    mini.Name = "MinimizedPanel"
    mini.Size = UDim2.new(0, 240, 0, 62)
    mini.Position = UDim2.new(0, 20, 0, 20)
    mini.BackgroundColor3 = theme.bg or Color3.fromRGB(18, 18, 24)
    mini.BorderSizePixel = 0
    mini.Visible = false
    mini.Active = true
    mini.Parent = screenGui
    Instance.new("UICorner", mini).CornerRadius = UDim.new(0, 12)

    local miniStroke = Instance.new("UIStroke", mini)
    miniStroke.Color = mainStroke.Color
    miniStroke.Transparency = mainStroke.Transparency
    miniStroke.Thickness = 1

    local miniHeader = Instance.new("TextLabel")
    miniHeader.Size = UDim2.new(1, -28, 0, 16)
    miniHeader.Position = UDim2.new(0, 8, 0, 4)
    miniHeader.BackgroundTransparency = 1
    miniHeader.Text = "Build A Beehive"
    miniHeader.TextColor3 = theme.text or Color3.new(1, 1, 1)
    miniHeader.Font = Enum.Font.GothamBold
    miniHeader.TextSize = 10
    miniHeader.TextXAlignment = Enum.TextXAlignment.Left
    miniHeader.Parent = mini

    local miniExpand = Instance.new("TextButton")
    miniExpand.Text = "▢"
    miniExpand.Size = UDim2.new(0, 18, 0, 18)
    miniExpand.Position = UDim2.new(1, -24, 0, 3)
    miniExpand.BackgroundColor3 = theme.panel2 or Color3.fromRGB(40, 40, 52)
    miniExpand.TextColor3 = theme.dim or Color3.fromRGB(130, 130, 145)
    miniExpand.Font = Enum.Font.GothamBold
    miniExpand.TextSize = 11
    miniExpand.BorderSizePixel = 0
    miniExpand.Parent = mini
    Instance.new("UICorner", miniExpand).CornerRadius = UDim.new(0, 5)

    local miniDragHit = Instance.new("TextButton")
    miniDragHit.Size = UDim2.new(1, -24, 0, 26)
    miniDragHit.BackgroundTransparency = 1
    miniDragHit.Text = ""
    miniDragHit.Parent = mini

    local miniCards = Instance.new("Frame")
    miniCards.Size = UDim2.new(1, -16, 0, 34)
    miniCards.Position = UDim2.new(0, 8, 0, 24)
    miniCards.BackgroundTransparency = 1
    miniCards.Parent = mini

    local miniLayout = Instance.new("UIListLayout")
    miniLayout.FillDirection = Enum.FillDirection.Horizontal
    miniLayout.Padding = UDim.new(0, 4)
    miniLayout.SortOrder = Enum.SortOrder.LayoutOrder
    miniLayout.Parent = miniCards

    local function makeMiniCard(labelText, order)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0, 53, 1, 0)
        card.BackgroundColor3 = theme.panel2 or Color3.fromRGB(34, 34, 44)
        card.BorderSizePixel = 0
        card.LayoutOrder = order
        card.Parent = miniCards
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -4, 0, 10)
        label.Position = UDim2.new(0, 2, 0, 2)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = theme.dim or Color3.fromRGB(130, 130, 145)
        label.Font = Enum.Font.Gotham
        label.TextSize = 8
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.Parent = card

        local value = Instance.new("TextLabel")
        value.Size = UDim2.new(1, -4, 0, 16)
        value.Position = UDim2.new(0, 2, 0, 14)
        value.BackgroundTransparency = 1
        value.Text = "0"
        value.TextColor3 = theme.text or Color3.new(1, 1, 1)
        value.Font = Enum.Font.GothamBold
        value.TextSize = 12
        value.TextXAlignment = Enum.TextXAlignment.Center
        value.Parent = card

        return value
    end

    local miniFps = makeMiniCard("FPS", 1)
    local miniPing = makeMiniCard("PING", 2)
    local miniPlayers = makeMiniCard("PLAYERS", 3)
    local miniHive = makeMiniCard("HIVE", 4)

    local function setTab(tabName)
        applyTab(tabName)
    end

    tabOverviewBtn.MouseButton1Click:Connect(function()
        setTab("Overview")
    end)

    tabActionsBtn.MouseButton1Click:Connect(function()
        setTab("Actions")
    end)

    setTab("Overview")

    return {
        Theme = theme,
        ScreenGui = screenGui,
        Main = main,
        Frame = main,
        MainStroke = mainStroke,
        TopBar = topBar,
        Sidebar = sidebar,
        Content = content,
        OverviewTab = overviewTab,
        ActionsTab = actionsTab,
        SetTab = setTab,
        TabButtons = {
            Overview = tabOverviewBtn,
            Actions = tabActionsBtn,
        },
        Title = title,
        Subtitle = subtitle,
        MinBtn = minBtn,
        CloseBtn = closeBtn,
        DragHit = dragHit,
        StatusLbl = status,
        Stats = {
            FPSVal = fpsValue,
            PingVal = pingValue,
            PlayerCountVal = playerCountValue,
            TotalHiveVal = totalHiveValue,
        },
        CollectButton = collectButton,
        SellButton = sellButton,
        DepositAuroraButton = depositAuroraButton,
        CollectIntervalInput = collectIntervalInput,
        SellIntervalInput = sellIntervalInput,
        SoonLbl = soonLbl,
        MinimizedPanel = mini,
        MiniHeader = miniHeader,
        MiniExpand = miniExpand,
        MiniDragHit = miniDragHit,
        MiniStats = {
            FPSVal = miniFps,
            PingVal = miniPing,
            PlayerCountVal = miniPlayers,
            TotalHiveVal = miniHive,
        },
    }
end
