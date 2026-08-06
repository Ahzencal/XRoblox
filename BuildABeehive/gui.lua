-- BuildABeehive/gui.lua
-- Clean, spacious honey automation UI with a simple top bar, stats, and action row.

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
    main.Size = UDim2.new(0, 390, 0, 296)
    main.Position = UDim2.new(0.5, -195, 0.5, -148)
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
    topBar.Size = UDim2.new(1, 0, 0, 34)
    topBar.BackgroundColor3 = theme.topbar or Color3.fromRGB(20, 20, 28)
    topBar.BorderSizePixel = 0
    topBar.Parent = main

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -110, 1, 0)
    title.Position = UDim2.new(0, 14, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Build A Beehive"
    title.TextColor3 = theme.text or Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topBar

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -110, 1, 0)
    subtitle.Position = UDim2.new(0, 14, 0, 12)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Collect, sell, and deposit aurora from one place"
    subtitle.TextColor3 = theme.dim or Color3.fromRGB(130, 130, 145)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 9
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = topBar

    local minBtn = Instance.new("TextButton")
    minBtn.Text = "—"
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

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -24, 0, 16)
    status.Position = UDim2.new(0, 12, 0, 44)
    status.BackgroundTransparency = 1
    status.Text = "Status: OFF"
    status.TextColor3 = theme.danger or Color3.fromRGB(255, 80, 80)
    status.Font = Enum.Font.GothamBold
    status.TextSize = 13
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = main

    local statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(1, -24, 0, 96)
    statsFrame.Position = UDim2.new(0, 12, 0, 64)
    statsFrame.BackgroundColor3 = theme.panel or Color3.fromRGB(24, 24, 32)
    statsFrame.BorderSizePixel = 0
    statsFrame.Parent = main
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

    local collectButton = Instance.new("TextButton")
    collectButton.Size = UDim2.new(0.31, 0, 0, 30)
    collectButton.Position = UDim2.new(0.04, 0, 0, 172)
    collectButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    collectButton.Text = "Collect: OFF"
    collectButton.TextScaled = true
    collectButton.BorderSizePixel = 0
    collectButton.Parent = main
    Instance.new("UICorner", collectButton).CornerRadius = UDim.new(0, 6)

    local sellButton = Instance.new("TextButton")
    sellButton.Size = UDim2.new(0.31, 0, 0, 30)
    sellButton.Position = UDim2.new(0.345, 0, 0, 172)
    sellButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    sellButton.Text = "Sell: OFF"
    sellButton.TextScaled = true
    sellButton.BorderSizePixel = 0
    sellButton.Parent = main
    Instance.new("UICorner", sellButton).CornerRadius = UDim.new(0, 6)

    local depositAuroraButton = Instance.new("TextButton")
    depositAuroraButton.Size = UDim2.new(0.31, 0, 0, 30)
    depositAuroraButton.Position = UDim2.new(0.65, 0, 0, 172)
    depositAuroraButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    depositAuroraButton.Text = "Aurora: OFF"
    depositAuroraButton.TextScaled = true
    depositAuroraButton.BorderSizePixel = 0
    depositAuroraButton.Parent = main
    Instance.new("UICorner", depositAuroraButton).CornerRadius = UDim.new(0, 6)

    local soonLbl = Instance.new("TextLabel")
    soonLbl.Size = UDim2.new(1, -24, 0, 14)
    soonLbl.Position = UDim2.new(0, 12, 0, 210)
    soonLbl.BackgroundTransparency = 1
    soonLbl.Text = "Auto-buy coming soon"
    soonLbl.TextColor3 = theme.dim or Color3.fromRGB(130, 130, 145)
    soonLbl.Font = Enum.Font.Gotham
    soonLbl.TextSize = 10
    soonLbl.TextXAlignment = Enum.TextXAlignment.Left
    soonLbl.Parent = main

    local mini = Instance.new("Frame")
    mini.Name = "MinimizedPanel"
    mini.Size = UDim2.new(0, 300, 0, 92)
    mini.Position = UDim2.new(0.5, -150, 0.5, -46)
    mini.BackgroundColor3 = theme.bg or Color3.fromRGB(18, 18, 24)
    mini.BorderSizePixel = 0
    mini.Visible = false
    mini.Parent = screenGui
    Instance.new("UICorner", mini).CornerRadius = UDim.new(0, 12)

    local miniStroke = Instance.new("UIStroke", mini)
    miniStroke.Color = mainStroke.Color
    miniStroke.Transparency = mainStroke.Transparency
    miniStroke.Thickness = 1

    local miniHeader = Instance.new("TextLabel")
    miniHeader.Size = UDim2.new(1, -28, 0, 16)
    miniHeader.Position = UDim2.new(0, 10, 0, 6)
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
    miniExpand.Position = UDim2.new(1, -24, 0, 4)
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
    miniCards.Size = UDim2.new(1, -16, 0, 48)
    miniCards.Position = UDim2.new(0, 8, 0, 32)
    miniCards.BackgroundTransparency = 1
    miniCards.Parent = mini

    local miniLayout = Instance.new("UIListLayout")
    miniLayout.FillDirection = Enum.FillDirection.Horizontal
    miniLayout.Padding = UDim.new(0, 4)
    miniLayout.SortOrder = Enum.SortOrder.LayoutOrder
    miniLayout.Parent = miniCards

    local function makeMiniCard(labelText, order)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0, 68, 1, 0)
        card.BackgroundColor3 = theme.panel2 or Color3.fromRGB(34, 34, 44)
        card.BorderSizePixel = 0
        card.LayoutOrder = order
        card.Parent = miniCards
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -4, 0, 10)
        label.Position = UDim2.new(0, 2, 0, 3)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = theme.dim or Color3.fromRGB(130, 130, 145)
        label.Font = Enum.Font.Gotham
        label.TextSize = 8
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.Parent = card

        local value = Instance.new("TextLabel")
        value.Size = UDim2.new(1, -4, 0, 16)
        value.Position = UDim2.new(0, 2, 0, 16)
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

    return {
        Theme = theme,
        ScreenGui = screenGui,
        Main = main,
        Frame = main,
        MainStroke = mainStroke,
        TopBar = topBar,
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
