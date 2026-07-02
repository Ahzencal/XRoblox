-- LyraHub/gui.lua
-- Wide sleek GUI with Lyra violet theme, draggable from top bar + bottom line
return function(config)
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local lp = Players.LocalPlayer

    -- Lyra Theme (violet/purple palette)
    local LYRA = {
        accent = Color3.fromRGB(155, 89, 255),
        accentDark = Color3.fromRGB(110, 60, 200),
        accentGlow = Color3.fromRGB(180, 130, 255),
        bg = Color3.fromRGB(12, 10, 20),
        bg2 = Color3.fromRGB(18, 15, 30),
        panel = Color3.fromRGB(22, 20, 38),
        panel2 = Color3.fromRGB(30, 27, 50),
        sidebar = Color3.fromRGB(16, 13, 28),
        topbar = Color3.fromRGB(20, 17, 34),
        text = Color3.fromRGB(240, 235, 255),
        dim = Color3.fromRGB(130, 120, 170),
        success = Color3.fromRGB(80, 220, 140),
        danger = Color3.fromRGB(255, 80, 100),
        warn = Color3.fromRGB(255, 200, 80),
        tp = Color3.fromRGB(100, 180, 255),
        beam = Color3.fromRGB(255, 130, 90),
    }

    if _G.__LyraHub_Destroy then
        pcall(_G.__LyraHub_Destroy)
    end
    _G.__LyraHub_Destroy = nil

    local function tweenProp(obj, props, t, style, dir)
        style = style or Enum.EasingStyle.Quart
        dir = dir or Enum.EasingDirection.Out
        TweenService:Create(obj, TweenInfo.new(t, style, dir), props):Play()
    end

    -- ═══════════════════════════════════════════
    -- LOADING SCREEN
    -- ═══════════════════════════════════════════
    local LoadGui = Instance.new("ScreenGui")
    LoadGui.Name = "LyraLoader"
    LoadGui.ResetOnSpawn = false
    LoadGui.DisplayOrder = 9999
    pcall(function() LoadGui.Parent = game:GetService("CoreGui") end)
    if not LoadGui.Parent then LoadGui.Parent = lp:WaitForChild("PlayerGui") end

    local LoadBG = Instance.new("Frame")
    LoadBG.Size = UDim2.new(0, 420, 0, 260)
    LoadBG.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadBG.Position = UDim2.new(0.5, 0, 0.5, 0)
    LoadBG.BackgroundColor3 = LYRA.bg
    LoadBG.BorderSizePixel = 0
    LoadBG.Parent = LoadGui
    Instance.new("UICorner", LoadBG).CornerRadius = UDim.new(0, 14)
    local LoadStroke = Instance.new("UIStroke", LoadBG)
    LoadStroke.Color = LYRA.accent
    LoadStroke.Thickness = 1.5

    local LoadTitle = Instance.new("TextLabel")
    LoadTitle.Text = "LYRA HUB"
    LoadTitle.Size = UDim2.new(1, 0, 0, 44)
    LoadTitle.Position = UDim2.new(0, 0, 0, 40)
    LoadTitle.BackgroundTransparency = 1
    LoadTitle.TextColor3 = LYRA.accentGlow
    LoadTitle.Font = Enum.Font.GothamBold
    LoadTitle.TextSize = 30
    LoadTitle.TextTransparency = 1
    LoadTitle.Parent = LoadBG

    local LoadQuote = Instance.new("TextLabel")
    LoadQuote.Text = "Precision tools for the bold"
    LoadQuote.Size = UDim2.new(1, 0, 0, 24)
    LoadQuote.Position = UDim2.new(0, 0, 0, 88)
    LoadQuote.BackgroundTransparency = 1
    LoadQuote.TextColor3 = LYRA.dim
    LoadQuote.Font = Enum.Font.Gotham
    LoadQuote.TextSize = 13
    LoadQuote.TextTransparency = 1
    LoadQuote.Parent = LoadBG

    local BarTrack = Instance.new("Frame")
    BarTrack.Size = UDim2.new(0, 300, 0, 4)
    BarTrack.AnchorPoint = Vector2.new(0.5, 0)
    BarTrack.Position = UDim2.new(0.5, 0, 0, 140)
    BarTrack.BackgroundColor3 = LYRA.panel2
    BarTrack.BorderSizePixel = 0
    BarTrack.Parent = LoadBG
    Instance.new("UICorner", BarTrack).CornerRadius = UDim.new(1, 0)

    local BarFill = Instance.new("Frame")
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = LYRA.accent
    BarFill.BorderSizePixel = 0
    BarFill.Parent = BarTrack
    Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

    local LoadStatus = Instance.new("TextLabel")
    LoadStatus.Text = "Initializing..."
    LoadStatus.Size = UDim2.new(1, 0, 0, 20)
    LoadStatus.Position = UDim2.new(0, 0, 0, 155)
    LoadStatus.BackgroundTransparency = 1
    LoadStatus.TextColor3 = LYRA.dim
    LoadStatus.Font = Enum.Font.Gotham
    LoadStatus.TextSize = 11
    LoadStatus.Parent = LoadBG

    task.spawn(function()
        local stages = {
            {text = "Loading modules...", pct = 0.20},
            {text = "Setting up ESP...", pct = 0.45},
            {text = "Connecting FishZone...", pct = 0.65},
            {text = "Building GUI...", pct = 0.85},
            {text = "Welcome.", pct = 1.00},
        }
        task.wait(0.1)
        tweenProp(LoadTitle, {TextTransparency = 0}, 0.6)
        task.wait(0.4)
        tweenProp(LoadQuote, {TextTransparency = 0}, 0.5)
        task.wait(0.2)
        for _, stage in ipairs(stages) do
            LoadStatus.Text = stage.text
            tweenProp(BarFill, {Size = UDim2.new(stage.pct, 0, 1, 0)}, 0.4, Enum.EasingStyle.Quint)
            task.wait(0.35)
        end
        task.wait(0.3)
        tweenProp(LoadBG, {BackgroundTransparency = 1}, 0.5)
        tweenProp(LoadStroke, {Transparency = 1}, 0.5)
        tweenProp(LoadTitle, {TextTransparency = 1}, 0.4)
        tweenProp(LoadQuote, {TextTransparency = 1}, 0.4)
        tweenProp(LoadStatus, {TextTransparency = 1}, 0.4)
        tweenProp(BarTrack, {BackgroundTransparency = 1}, 0.4)
        tweenProp(BarFill, {BackgroundTransparency = 1}, 0.4)
        task.wait(0.55)
        pcall(function() LoadGui:Destroy() end)
    end)

    -- ═══════════════════════════════════════════
    -- MAIN GUI
    -- ═══════════════════════════════════════════
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LyraHub_Main"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999
    pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ScreenGui.Parent then ScreenGui.Parent = lp:WaitForChild("PlayerGui") end

    -- Main frame: wider (620x420)
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 620, 0, 420)
    Main.Position = UDim2.new(0.5, -310, 0.5, -210)
    Main.BackgroundColor3 = LYRA.bg
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = LYRA.accentDark
    MainStroke.Thickness = 1

    -- ═══════════════════════════════════════════
    -- TOP BAR (draggable)
    -- ═══════════════════════════════════════════
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 36)
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.BackgroundColor3 = LYRA.topbar
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Main

    local TopBarTitle = Instance.new("TextLabel")
    TopBarTitle.Text = "LYRA HUB"
    TopBarTitle.Size = UDim2.new(0, 200, 1, 0)
    TopBarTitle.Position = UDim2.new(0, 14, 0, 0)
    TopBarTitle.BackgroundTransparency = 1
    TopBarTitle.TextColor3 = LYRA.accentGlow
    TopBarTitle.Font = Enum.Font.GothamBold
    TopBarTitle.TextSize = 13
    TopBarTitle.TextXAlignment = Enum.TextXAlignment.Left
    TopBarTitle.Parent = TopBar

    -- Minimize button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Text = "—"
    MinBtn.Size = UDim2.new(0, 30, 0, 24)
    MinBtn.Position = UDim2.new(1, -68, 0, 6)
    MinBtn.BackgroundColor3 = LYRA.panel2
    MinBtn.TextColor3 = LYRA.dim
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 14
    MinBtn.BorderSizePixel = 0
    MinBtn.Parent = TopBar
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "x"
    CloseBtn.Size = UDim2.new(0, 30, 0, 24)
    CloseBtn.Position = UDim2.new(1, -34, 0, 6)
    CloseBtn.BackgroundColor3 = LYRA.danger
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 13
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    -- ═══════════════════════════════════════════
    -- DRAG LOGIC (top bar + bottom line)
    -- ═══════════════════════════════════════════
    local dragging, dragStart, startPos

    local function beginDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end

    local function updateDrag(input)
        if dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end

    TopBar.InputBegan:Connect(beginDrag)
    UserInputService.InputChanged:Connect(updateDrag)

    -- Bottom drag line
    local DragBar = Instance.new("Frame")
    DragBar.Size = UDim2.new(0, 80, 0, 4)
    DragBar.AnchorPoint = Vector2.new(0.5, 0)
    DragBar.Position = UDim2.new(0.5, 0, 1, -10)
    DragBar.BackgroundColor3 = LYRA.accentDark
    DragBar.BorderSizePixel = 0
    DragBar.Parent = Main
    Instance.new("UICorner", DragBar).CornerRadius = UDim.new(1, 0)

    local DragHit = Instance.new("TextButton")
    DragHit.Size = UDim2.new(0, 140, 0, 16)
    DragHit.AnchorPoint = Vector2.new(0.5, 0)
    DragHit.Position = UDim2.new(0.5, 0, 1, -14)
    DragHit.Text = ""
    DragHit.BackgroundTransparency = 1
    DragHit.Parent = Main
    DragHit.InputBegan:Connect(beginDrag)

    -- ═══════════════════════════════════════════
    -- SIDEBAR (wider: 130px)
    -- ═══════════════════════════════════════════
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 130, 1, -36)
    Sidebar.Position = UDim2.new(0, 0, 0, 36)
    Sidebar.BackgroundColor3 = LYRA.sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main

    -- Hub name in sidebar
    local Title = Instance.new("TextLabel")
    Title.Text = "LyraHub"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 10)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = LYRA.accentGlow
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15
    Title.Parent = Sidebar

    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "v2.0"
    Subtitle.Size = UDim2.new(1, 0, 0, 14)
    Subtitle.Position = UDim2.new(0, 0, 0, 46)
    Subtitle.BackgroundTransparency = 1
    Subtitle.TextColor3 = LYRA.dim
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 10
    Subtitle.Parent = Sidebar

    -- Sidebar separator
    local SepLine = Instance.new("Frame")
    SepLine.Size = UDim2.new(0.7, 0, 0, 1)
    SepLine.AnchorPoint = Vector2.new(0.5, 0)
    SepLine.Position = UDim2.new(0.5, 0, 0, 64)
    SepLine.BackgroundColor3 = LYRA.panel2
    SepLine.BorderSizePixel = 0
    SepLine.Parent = Sidebar

    -- Header / HeaderMask (API contract)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 64)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundTransparency = 1
    Header.BorderSizePixel = 0
    Header.Parent = Sidebar

    local HeaderMask = Instance.new("Frame")
    HeaderMask.Size = UDim2.new(1, 0, 0, 1)
    HeaderMask.Position = UDim2.new(0, 0, 0, 64)
    HeaderMask.BackgroundTransparency = 1
    HeaderMask.BorderSizePixel = 0
    HeaderMask.Parent = Sidebar

    -- TabsBar (nav area)
    local TabsBar = Instance.new("Frame")
    TabsBar.Size = UDim2.new(1, 0, 0, 240)
    TabsBar.Position = UDim2.new(0, 0, 0, 74)
    TabsBar.BackgroundTransparency = 1
    TabsBar.BorderSizePixel = 0
    TabsBar.Parent = Sidebar

    -- Sidebar nav buttons (full text, vertical)
    local tabNames = {"Players", "FishZone", "Clicker", "Settings"}
    local tabIcons = {"Players", "FishZone", "Clicker", "Settings"}
    local TabButtons = {}

    for i, name in ipairs(tabNames) do
        local btn = Instance.new("TextButton")
        btn.Text = tabIcons[i]
        btn.Size = UDim2.new(1, -16, 0, 34)
        btn.Position = UDim2.new(0, 8, 0, (i - 1) * 42)
        btn.BackgroundColor3 = (i == 1) and LYRA.accent or LYRA.panel2
        btn.BackgroundTransparency = (i == 1) and 0.15 or 0.6
        btn.TextColor3 = (i == 1) and LYRA.text or LYRA.dim
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.BorderSizePixel = 0
        btn.Parent = TabsBar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        TabButtons[name] = btn
    end

    -- ═══════════════════════════════════════════
    -- CONTENT AREA
    -- ═══════════════════════════════════════════
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -142, 1, -48)
    Content.Position = UDim2.new(0, 136, 0, 42)
    Content.BackgroundColor3 = LYRA.panel
    Content.BorderSizePixel = 0
    Content.ClipsDescendants = true
    Content.Parent = Main
    Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 10)
    local ContentStroke = Instance.new("UIStroke", Content)
    ContentStroke.Color = LYRA.panel2
    ContentStroke.Thickness = 1

    -- Tab content frames
    local Tabs = {}
    for i, name in ipairs(tabNames) do
        local f = Instance.new("Frame")
        f.Name = name .. "Tab"
        f.Size = UDim2.new(1, 0, 1, 0)
        f.BackgroundTransparency = 1
        f.Visible = (i == 1)
        f.Parent = Content
        Tabs[name] = f
    end

    -- ═══════════════════════════════════════════
    -- PLAYERS TAB
    -- ═══════════════════════════════════════════
    local SearchBox = Instance.new("TextBox")
    SearchBox.PlaceholderText = "Search player..."
    SearchBox.Text = ""
    SearchBox.ClearTextOnFocus = false
    SearchBox.Size = UDim2.new(1, -20, 0, 32)
    SearchBox.Position = UDim2.new(0, 10, 0, 10)
    SearchBox.BackgroundColor3 = LYRA.bg2
    SearchBox.TextColor3 = LYRA.text
    SearchBox.PlaceholderColor3 = LYRA.dim
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 13
    SearchBox.BorderSizePixel = 0
    SearchBox.Parent = Tabs.Players
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 8)

    local PlayerList = Instance.new("ScrollingFrame")
    PlayerList.Size = UDim2.new(1, -20, 1, -70)
    PlayerList.Position = UDim2.new(0, 10, 0, 48)
    PlayerList.BackgroundColor3 = LYRA.bg2
    PlayerList.BorderSizePixel = 0
    PlayerList.ScrollBarThickness = 3
    PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    PlayerList.Parent = Tabs.Players
    Instance.new("UICorner", PlayerList).CornerRadius = UDim.new(0, 8)
    Instance.new("UIListLayout", PlayerList).Padding = UDim.new(0, 4)

    local PlayerHint = Instance.new("TextLabel")
    PlayerHint.Text = "Scroll for more players"
    PlayerHint.Size = UDim2.new(1, -20, 0, 16)
    PlayerHint.Position = UDim2.new(0, 10, 1, -20)
    PlayerHint.BackgroundTransparency = 1
    PlayerHint.TextColor3 = LYRA.dim
    PlayerHint.Font = Enum.Font.Gotham
    PlayerHint.TextSize = 10
    PlayerHint.TextXAlignment = Enum.TextXAlignment.Left
    PlayerHint.Parent = Tabs.Players

    -- ═══════════════════════════════════════════
    -- FISHZONE TAB
    -- ═══════════════════════════════════════════
    local function makeActionButton(parent, text, y, color)
        local b = Instance.new("TextButton")
        b.Text = text
        b.Size = UDim2.new(1, -20, 0, 32)
        b.Position = UDim2.new(0, 10, 0, y)
        b.BackgroundColor3 = color
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 12
        b.BorderSizePixel = 0
        b.Parent = parent
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        return b
    end

    local ZoneESPBtn = makeActionButton(Tabs.FishZone, "FishZone ESP: OFF", 10, LYRA.accent)
    local AutoTPBtn = makeActionButton(Tabs.FishZone, "Auto TP Active FishZone: OFF", 48, LYRA.tp)
    local RefreshCharBtn = makeActionButton(Tabs.FishZone, "Refresh Character", 86, LYRA.danger)
    local AutoSellBtn = makeActionButton(Tabs.FishZone, "Auto Sell Fish: OFF", 124, LYRA.warn)
    local SellNowBtn = makeActionButton(Tabs.FishZone, "Sell All Now (Test)", 162, LYRA.accent)

    local ZoneStatus = Instance.new("TextLabel")
    ZoneStatus.Size = UDim2.new(1, -20, 0, 20)
    ZoneStatus.Position = UDim2.new(0, 10, 0, 204)
    ZoneStatus.BackgroundTransparency = 1
    ZoneStatus.TextColor3 = LYRA.text
    ZoneStatus.Text = "Status: Idle"
    ZoneStatus.Font = Enum.Font.GothamBold
    ZoneStatus.TextSize = 12
    ZoneStatus.TextXAlignment = Enum.TextXAlignment.Left
    ZoneStatus.Parent = Tabs.FishZone

    local ZoneInfo = Instance.new("TextLabel")
    ZoneInfo.Size = UDim2.new(1, -20, 0, 70)
    ZoneInfo.Position = UDim2.new(0, 10, 0, 228)
    ZoneInfo.BackgroundTransparency = 1
    ZoneInfo.TextColor3 = LYRA.dim
    ZoneInfo.Text = "Active zones only\nAuto TP keeps rotation/body lock\nRefresh uses Adonis commands\nCore logic in core.lua"
    ZoneInfo.Font = Enum.Font.Gotham
    ZoneInfo.TextSize = 11
    ZoneInfo.TextWrapped = true
    ZoneInfo.TextXAlignment = Enum.TextXAlignment.Left
    ZoneInfo.TextYAlignment = Enum.TextYAlignment.Top
    ZoneInfo.Parent = Tabs.FishZone

    -- ═══════════════════════════════════════════
    -- CLICKER TAB
    -- ═══════════════════════════════════════════
    local StatusLbl = Instance.new("TextLabel")
    StatusLbl.Size = UDim2.new(1, -20, 0, 22)
    StatusLbl.Position = UDim2.new(0, 10, 0, 10)
    StatusLbl.BackgroundTransparency = 1
    StatusLbl.Text = "Status: OFF"
    StatusLbl.TextColor3 = LYRA.danger
    StatusLbl.Font = Enum.Font.GothamBold
    StatusLbl.TextSize = 14
    StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
    StatusLbl.Parent = Tabs.Clicker

    local PosLbl = Instance.new("TextLabel")
    PosLbl.Size = UDim2.new(1, -20, 0, 20)
    PosLbl.Position = UDim2.new(0, 10, 0, 36)
    PosLbl.BackgroundTransparency = 1
    PosLbl.Text = "Target: Not set (press P)"
    PosLbl.TextColor3 = LYRA.dim
    PosLbl.Font = Enum.Font.Gotham
    PosLbl.TextSize = 12
    PosLbl.TextXAlignment = Enum.TextXAlignment.Left
    PosLbl.Parent = Tabs.Clicker

    local MethodLbl = Instance.new("TextLabel")
    MethodLbl.Size = UDim2.new(1, -20, 0, 20)
    MethodLbl.Position = UDim2.new(0, 10, 0, 58)
    MethodLbl.BackgroundTransparency = 1
    MethodLbl.Text = "Mode: Loading..."
    MethodLbl.TextColor3 = LYRA.warn
    MethodLbl.Font = Enum.Font.Gotham
    MethodLbl.TextSize = 12
    MethodLbl.TextXAlignment = Enum.TextXAlignment.Left
    MethodLbl.Parent = Tabs.Clicker

    local CPSLbl = Instance.new("TextLabel")
    CPSLbl.Size = UDim2.new(1, -20, 0, 20)
    CPSLbl.Position = UDim2.new(0, 10, 0, 82)
    CPSLbl.BackgroundTransparency = 1
    CPSLbl.Text = "CPS: " .. tostring(config.Clicker.DefaultCPS)
    CPSLbl.TextColor3 = LYRA.text
    CPSLbl.Font = Enum.Font.GothamBold
    CPSLbl.TextSize = 12
    CPSLbl.TextXAlignment = Enum.TextXAlignment.Left
    CPSLbl.Parent = Tabs.Clicker

    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, -20, 0, 6)
    SliderTrack.Position = UDim2.new(0, 10, 0, 112)
    SliderTrack.BackgroundColor3 = LYRA.bg2
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Parent = Tabs.Clicker
    Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(1, 0)

    local ratio = math.clamp(config.Clicker.DefaultCPS / 100, 0, 1)
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
    SliderFill.BackgroundColor3 = LYRA.accent
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

    local SliderKnob = Instance.new("Frame")
    SliderKnob.Size = UDim2.new(0, 14, 0, 14)
    SliderKnob.Position = UDim2.new(ratio, -7, 0.5, -7)
    SliderKnob.BackgroundColor3 = LYRA.accentGlow
    SliderKnob.BorderSizePixel = 0
    SliderKnob.Parent = SliderTrack
    Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)

    local ToggleBtn = makeActionButton(Tabs.Clicker, "Start [F]", 134, LYRA.accent)

    -- ═══════════════════════════════════════════
    -- SETTINGS TAB
    -- ═══════════════════════════════════════════
    local HideKeyLbl = Instance.new("TextLabel")
    HideKeyLbl.Size = UDim2.new(1, -20, 0, 22)
    HideKeyLbl.Position = UDim2.new(0, 10, 0, 10)
    HideKeyLbl.BackgroundTransparency = 1
    HideKeyLbl.Text = "Hide/Show UI: " .. tostring(config.Keys.HideUI):gsub("Enum.KeyCode.", "")
    HideKeyLbl.TextColor3 = LYRA.text
    HideKeyLbl.Font = Enum.Font.GothamBold
    HideKeyLbl.TextSize = 12
    HideKeyLbl.TextXAlignment = Enum.TextXAlignment.Left
    HideKeyLbl.Parent = Tabs.Settings

    local UnloadBtn = makeActionButton(Tabs.Settings, "Unload Script", 40, LYRA.danger)
    local AutoClaimDailyRewardBtn = makeActionButton(Tabs.Settings, "Auto Claim Daily Reward: OFF", 80, LYRA.accent)
    local AutoClaimSessionRewardBtn = makeActionButton(Tabs.Settings, "Auto Claim Session Reward: OFF", 120, LYRA.tp)

    local ColorTitle = Instance.new("TextLabel")
    ColorTitle.Size = UDim2.new(1, -20, 0, 20)
    ColorTitle.Position = UDim2.new(0, 10, 0, 166)
    ColorTitle.BackgroundTransparency = 1
    ColorTitle.Text = "Accent Color"
    ColorTitle.TextColor3 = LYRA.text
    ColorTitle.Font = Enum.Font.GothamBold
    ColorTitle.TextSize = 12
    ColorTitle.TextXAlignment = Enum.TextXAlignment.Left
    ColorTitle.Parent = Tabs.Settings

    local AccentPreview = Instance.new("Frame")
    AccentPreview.Size = UDim2.new(0, 22, 0, 22)
    AccentPreview.Position = UDim2.new(1, -36, 0, 164)
    AccentPreview.BackgroundColor3 = LYRA.accent
    AccentPreview.BorderSizePixel = 0
    AccentPreview.Parent = Tabs.Settings
    Instance.new("UICorner", AccentPreview).CornerRadius = UDim.new(0, 6)

    local ColorButtons = {}
    for i, color in ipairs(config.ThemePresets) do
        local sw = Instance.new("TextButton")
        sw.Text = ""
        sw.Size = UDim2.new(0, 28, 0, 28)
        sw.Position = UDim2.new(0, 10 + ((i - 1) % 5) * 36, 0, 194 + math.floor((i - 1) / 5) * 36)
        sw.BackgroundColor3 = color
        sw.BorderSizePixel = 0
        sw.Parent = Tabs.Settings
        Instance.new("UICorner", sw).CornerRadius = UDim.new(0, 6)
        table.insert(ColorButtons, sw)
    end

    local SettingsInfo = Instance.new("TextLabel")
    SettingsInfo.Size = UDim2.new(1, -20, 0, 44)
    SettingsInfo.Position = UDim2.new(0, 10, 1, -52)
    SettingsInfo.BackgroundTransparency = 1
    SettingsInfo.Text = "Use config.lua for keys, blacklist positions, float height, colors, presets, and reward toggles."
    SettingsInfo.TextColor3 = LYRA.dim
    SettingsInfo.Font = Enum.Font.Gotham
    SettingsInfo.TextSize = 11
    SettingsInfo.TextWrapped = true
    SettingsInfo.TextXAlignment = Enum.TextXAlignment.Left
    SettingsInfo.TextYAlignment = Enum.TextYAlignment.Top
    SettingsInfo.Parent = Tabs.Settings

    -- ═══════════════════════════════════════════
    -- RETURN TABLE (API contract preserved)
    -- ═══════════════════════════════════════════
    return {
        Theme = LYRA,
        MainGui = ScreenGui,
        Main = Main,
        Header = Header,
        HeaderMask = HeaderMask,
        MainStroke = MainStroke,
        Content = Content,
        ContentStroke = ContentStroke,
        TabsBar = TabsBar,
        DragBar = DragBar,
        DragHit = DragHit,
        Title = Title,
        Subtitle = Subtitle,
        MinBtn = MinBtn,
        CloseBtn = CloseBtn,
        TabButtons = TabButtons,
        Tabs = Tabs,
        Players = {
            SearchBox = SearchBox,
            PlayerList = PlayerList,
            PlayerHint = PlayerHint,
        },
        FishZone = {
            ZoneESPBtn = ZoneESPBtn,
            AutoTPBtn = AutoTPBtn,
            RefreshCharBtn = RefreshCharBtn,
            AutoSellBtn = AutoSellBtn,
            SellNowBtn = SellNowBtn,
            ZoneStatus = ZoneStatus,
            ZoneInfo = ZoneInfo,
        },
        Clicker = {
            StatusLbl = StatusLbl,
            PosLbl = PosLbl,
            MethodLbl = MethodLbl,
            CPSLbl = CPSLbl,
            SliderTrack = SliderTrack,
            SliderFill = SliderFill,
            SliderKnob = SliderKnob,
            ToggleBtn = ToggleBtn,
        },
        Settings = {
            HideKeyLbl = HideKeyLbl,
            UnloadBtn = UnloadBtn,
            AutoClaimDailyRewardBtn = AutoClaimDailyRewardBtn,
            AutoClaimSessionRewardBtn = AutoClaimSessionRewardBtn,
            ColorTitle = ColorTitle,
            AccentPreview = AccentPreview,
            ColorButtons = ColorButtons,
            SettingsInfo = SettingsInfo,
        },
    }
end
