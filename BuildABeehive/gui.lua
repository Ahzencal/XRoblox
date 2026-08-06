-- BuildABeehive/gui.lua
-- Builds the honey automation UI and returns references used by the core/module layers

return function(config)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local theme = config.Theme or {}

    if _G.__BuildABeehive_Destroy then
        pcall(_G.__BuildABeehive_Destroy)
    end
    screenGui.Name = "BuildABeehive_GUI"

    local screenGui = Instance.new("ScreenGui")
    screenGui.DisplayOrder = 999
    screenGui.Name = "AutoHoneyGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
    if not screenGui.Parent then
        screenGui.Parent = lp:WaitForChild("PlayerGui")
    frame.Size = UDim2.new(0, 360, 0, 308)
    frame.Position = UDim2.new(0.5, -180, 0.5, -154)
    frame.BackgroundColor3 = theme.bg or Color3.fromRGB(18, 18, 24)
    frame.Size = UDim2.new(0, 180, 0, 145)
    frame.ClipsDescendants = true
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    frame.Draggable = true
    frame.Parent = screenGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    stroke.Transparency = 0.25
    stroke.Thickness = 1

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 34)
    topBar.BackgroundColor3 = theme.topbar or Color3.fromRGB(20, 20, 28)
    topBar.BorderSizePixel = 0
    topBar.Parent = frame
    stroke.Color = theme.accent or Color3.fromRGB(80, 180, 255)
    stroke.Transparency = 0.35
    title.Size = UDim2.new(1, -110, 1, 0)
    title.Position = UDim2.new(0, 14, 0, 0)

    title.Text = "Build A Beehive"
    title.TextColor3 = theme.text or Color3.new(1, 1, 1)
    title.BackgroundTransparency = 1
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
    dragHit.Position = UDim2.new(0, 0, 0, 0)
    dragHit.BackgroundTransparency = 1
    dragHit.Text = ""
    dragHit.Parent = topBar
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    status.Size = UDim2.new(1, -20, 0, 18)
    status.Position = UDim2.new(0, 12, 0, 44)
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -10, 0, 16)
    status.Position = UDim2.new(0, 5, 0, 24)
    status.BackgroundTransparency = 1
    status.TextSize = 13
    status.TextColor3 = theme.danger or Color3.fromRGB(255, 80, 80)
    status.Font = Enum.Font.GothamBold

    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(1, -20, 0, 14)
    hint.Position = UDim2.new(0, 12, 0, 62)
    hint.BackgroundTransparency = 1
    hint.Text = "Auto-buy slot reserved for the next update"
    hint.TextColor3 = theme.warn or Color3.fromRGB(255, 200, 80)
    hint.Font = Enum.Font.Gotham
    hint.TextSize = 10
    hint.TextXAlignment = Enum.TextXAlignment.Left
    hint.Parent = frame

    local statsFrame = Instance.new("Frame")
    statsFrame.Size = UDim2.new(1, -24, 0, 88)
    statsFrame.Position = UDim2.new(0, 12, 0, 82)
    statsFrame.BackgroundColor3 = theme.panel or Color3.fromRGB(24, 24, 32)
    statsFrame.BorderSizePixel = 0
    statsFrame.Parent = frame
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

    local function makeStatCard(titleText, order)
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
        label.Text = titleText
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

    local collectValue = makeStatCard("AUTO COLLECT", 1)
    local sellValue = makeStatCard("AUTO SELL", 2)
    local auroraValue = makeStatCard("AURORA", 3)
    local hiveValue = makeStatCard("HIVES", 4)
    status.TextSize = 11
    status.TextXAlignment = Enum.TextXAlignment.Left
    collectButton.Size = UDim2.new(0.31, 0, 0, 30)
    collectButton.Position = UDim2.new(0.04, 0, 0, 182)
    collectButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    collectButton.Text = "Collect: OFF"
    collectButton.TextScaled = true
    collectButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    collectButton.Text = "Collect: OFF"
    collectButton.TextScaled = true
    collectButton.BorderSizePixel = 0
    collectButton.Parent = frame
    extractButton.Size = UDim2.new(0.31, 0, 0, 30)
    extractButton.Position = UDim2.new(0.345, 0, 0, 182)
    extractButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    extractButton.Text = "Sell: OFF"
    extractButton.TextScaled = true
    extractButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    extractButton.Text = "Extract: OFF"
    extractButton.TextScaled = true
    extractButton.BorderSizePixel = 0
    extractButton.Parent = frame
    sellButton.Size = UDim2.new(0.31, 0, 0, 30)
    sellButton.Position = UDim2.new(0.65, 0, 0, 182)
    sellButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    sellButton.Text = "Aurora: OFF"
    sellButton.TextScaled = true
    sellButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    sellButton.Text = "Sell: OFF"
    sellButton.TextScaled = true
    sellButton.BorderSizePixel = 0
    sellButton.Parent = frame
    depositAuroraButton.Size = UDim2.new(0.92, 0, 0, 26)
    depositAuroraButton.Position = UDim2.new(0.04, 0, 0, 220)
    depositAuroraButton.BackgroundColor3 = theme.panel2 or Color3.fromRGB(40, 40, 52)
    depositAuroraButton.Text = "Use the toggles above"
    depositAuroraButton.TextScaled = true
    depositAuroraButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    depositAuroraButton.Text = "Aurora: OFF"
    depositAuroraButton.TextScaled = true

    local minimizedPanel = Instance.new("Frame")
    minimizedPanel.Name = "MinimizedPanel"
    minimizedPanel.Size = UDim2.new(0, 280, 0, 84)
    minimizedPanel.Position = UDim2.new(0.5, -140, 0.5, -42)
    minimizedPanel.BackgroundColor3 = theme.bg or Color3.fromRGB(18, 18, 24)
    minimizedPanel.BorderSizePixel = 0
    minimizedPanel.Visible = false
    minimizedPanel.Parent = screenGui
    Instance.new("UICorner", minimizedPanel).CornerRadius = UDim.new(0, 12)

    local minimizedStroke = Instance.new("UIStroke", minimizedPanel)
    minimizedStroke.Color = stroke.Color
    minimizedStroke.Transparency = stroke.Transparency
    minimizedStroke.Thickness = 1

    local miniHeader = Instance.new("TextLabel")
    miniHeader.Size = UDim2.new(1, -28, 0, 16)
    miniHeader.Position = UDim2.new(0, 10, 0, 6)
    miniHeader.BackgroundTransparency = 1
    miniHeader.Text = "Build A Beehive"
    miniHeader.TextColor3 = theme.text or Color3.new(1, 1, 1)
    miniHeader.Font = Enum.Font.GothamBold
    miniHeader.TextSize = 10
    miniHeader.TextXAlignment = Enum.TextXAlignment.Left
    miniHeader.Parent = minimizedPanel

    local collectButton = Instance.new("TextButton")
    collectButton.Size = UDim2.new(0.31, 0, 0, 30)
    collectButton.Position = UDim2.new(0.04, 0, 0, 182)
    collectButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    collectButton.Text = "Collect: OFF"
    collectButton.TextScaled = true
    collectButton.BorderSizePixel = 0
    collectButton.Parent = frame
    Instance.new("UICorner", collectButton).CornerRadius = UDim.new(0, 6)

    local sellButton = Instance.new("TextButton")
    sellButton.Size = UDim2.new(0.31, 0, 0, 30)
    sellButton.Position = UDim2.new(0.345, 0, 0, 182)
    sellButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    sellButton.Text = "Sell: OFF"
    sellButton.TextScaled = true
    sellButton.BorderSizePixel = 0
    sellButton.Parent = frame
    Instance.new("UICorner", sellButton).CornerRadius = UDim.new(0, 6)

    local depositAuroraButton = Instance.new("TextButton")
    depositAuroraButton.Size = UDim2.new(0.31, 0, 0, 30)
    depositAuroraButton.Position = UDim2.new(0.65, 0, 0, 182)
    depositAuroraButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    depositAuroraButton.Text = "Aurora: OFF"
    depositAuroraButton.TextScaled = true
    depositAuroraButton.BorderSizePixel = 0
    depositAuroraButton.Parent = frame
    Instance.new("UICorner", depositAuroraButton).CornerRadius = UDim.new(0, 6)

    local soonLbl = Instance.new("TextLabel")
    soonLbl.Size = UDim2.new(1, -24, 0, 14)
    soonLbl.Position = UDim2.new(0, 12, 0, 224)
    soonLbl.BackgroundTransparency = 1
    soonLbl.Text = "Auto-buy coming soon"
    soonLbl.TextColor3 = theme.dim or Color3.fromRGB(130, 130, 145)
    soonLbl.Font = Enum.Font.Gotham
    soonLbl.TextSize = 10
    soonLbl.TextXAlignment = Enum.TextXAlignment.Left
    soonLbl.Parent = frame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -4, 0, 10)
        label.Position = UDim2.new(0, 2, 0, 3)
        label.BackgroundTransparency = 1
        label.Text = titleText
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

    local miniCollect = makeMiniCard("COL", 1)
    local miniSell = makeMiniCard("SELL", 2)
    local miniAurora = makeMiniCard("AUR", 3)
    local miniHives = makeMiniCard("HIVES", 4)
    depositAuroraButton.BorderSizePixel = 0
    depositAuroraButton.Parent = frame
    Instance.new("UICorner", depositAuroraButton).CornerRadius = UDim.new(0, 6)

    return {
        TopBar = topBar,
        MinBtn = minBtn,
        CloseBtn = closeBtn,
        DragHit = dragHit,
        ScreenGui = screenGui,
        HintLbl = hint,
        CollectButton = collectButton,
        ExtractButton = extractButton,
        SellButton = sellButton,
        DepositAuroraButton = depositAuroraButton,
        Stats = {
            CollectVal = collectValue,
            SellVal = sellValue,
            AuroraVal = auroraValue,
            HivesVal = hiveValue,
        },
        SoonLbl = soonLbl,
        MinimizedPanel = minimizedPanel,
        MiniHeader = miniHeader,
        MiniExpand = miniExpand,
        MiniDragHit = miniDragHit,
        MiniStats = {
            CollectVal = miniCollect,
            SellVal = miniSell,
            AuroraVal = miniAurora,
            HivesVal = miniHives,
        },
        ExtractButton = extractButton,
        SellButton = sellButton,
        DepositAuroraButton = depositAuroraButton,
    }
end