-- FishZone/gui.lua
-- Modern minimalist sidebar GUI layout
return function(config)
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local lp = Players.LocalPlayer
    local THEME = config.Theme

    if _G.__AhzencalESP_Destroy then
        pcall(_G.__AhzencalESP_Destroy)
    end
    _G.__AhzencalESP_Destroy = nil

    local function tweenProp(obj, props, t, style, dir)
        style = style or Enum.EasingStyle.Quart
        dir = dir or Enum.EasingDirection.Out
        TweenService:Create(obj, TweenInfo.new(t, style, dir), props):Play()
    end

    -- Loading screen animation (kept exactly as-is)
    local LoadGui = Instance.new("ScreenGui")
    LoadGui.Name = "AhzencalLoader"
    LoadGui.ResetOnSpawn = false
    LoadGui.DisplayOrder = 9999
    pcall(function()
        LoadGui.Parent = game:GetService("CoreGui")
    end)
    if not LoadGui.Parent then
        LoadGui.Parent = lp:WaitForChild("PlayerGui")
    end

    local LoadBG = Instance.new("Frame")
    LoadBG.Size = UDim2.new(0, 390, 0, 470)
    LoadBG.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadBG.Position = UDim2.new(0.5, 0, 0.5, 0)
    LoadBG.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
    LoadBG.BorderSizePixel = 0
    LoadBG.Parent = LoadGui
    Instance.new("UICorner", LoadBG).CornerRadius = UDim.new(0, 16)
    local LoadStroke = Instance.new("UIStroke", LoadBG)
    LoadStroke.Color = Color3.fromRGB(0, 170, 255)
    LoadStroke.Thickness = 1.2

    local Scan = Instance.new("Frame")
    Scan.Size = UDim2.new(1, 0, 1, 0)
    Scan.BackgroundTransparency = 0.94
    Scan.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    Scan.BorderSizePixel = 0
    Scan.Parent = LoadBG
    Instance.new("UICorner", Scan).CornerRadius = UDim.new(0, 16)

    local Orb = Instance.new("Frame")
    Orb.Size = UDim2.new(0, 220, 0, 220)
    Orb.AnchorPoint = Vector2.new(0.5, 0.5)
    Orb.Position = UDim2.new(0.5, 0, 0.45, 0)
    Orb.BackgroundColor3 = Color3.fromRGB(0, 130, 255)
    Orb.BackgroundTransparency = 0.72
    Orb.BorderSizePixel = 0
    Orb.Parent = LoadBG
    Instance.new("UICorner", Orb).CornerRadius = UDim.new(1, 0)

    local OrbInner = Instance.new("Frame")
    OrbInner.Size = UDim2.new(0, 110, 0, 110)
    OrbInner.AnchorPoint = Vector2.new(0.5, 0.5)
    OrbInner.Position = UDim2.new(0.5, 0, 0.5, 0)
    OrbInner.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    OrbInner.BackgroundTransparency = 0.5
    OrbInner.BorderSizePixel = 0
    OrbInner.Parent = Orb
    Instance.new("UICorner", OrbInner).CornerRadius = UDim.new(1, 0)

    local LoadTitle = Instance.new("TextLabel")
    LoadTitle.Text = "AHZENCAL HUB"
    LoadTitle.Size = UDim2.new(0, 400, 0, 44)
    LoadTitle.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadTitle.Position = UDim2.new(0.5, 0, 0.38, 0)
    LoadTitle.BackgroundTransparency = 1
    LoadTitle.TextColor3 = Color3.fromRGB(0, 210, 255)
    LoadTitle.Font = Enum.Font.GothamBold
    LoadTitle.TextSize = 32
    LoadTitle.TextTransparency = 1
    LoadTitle.Parent = LoadBG

    local LoadQuote = Instance.new("TextLabel")
    LoadQuote.Text = "Beware of the staff, and welcome to the dark side"
    LoadQuote.Size = UDim2.new(0, 540, 0, 30)
    LoadQuote.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadQuote.Position = UDim2.new(0.5, 0, 0.56, 0)
    LoadQuote.BackgroundTransparency = 1
    LoadQuote.TextColor3 = Color3.fromRGB(180, 210, 255)
    LoadQuote.Font = Enum.Font.GothamBold
    LoadQuote.TextSize = 15
    LoadQuote.TextTransparency = 1
    LoadQuote.TextWrapped = true
    LoadQuote.Parent = LoadBG

    local BarTrack = Instance.new("Frame")
    BarTrack.Size = UDim2.new(0, 320, 0, 6)
    BarTrack.AnchorPoint = Vector2.new(0.5, 0.5)
    BarTrack.Position = UDim2.new(0.5, 0, 0.66, 0)
    BarTrack.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    BarTrack.BorderSizePixel = 0
    BarTrack.BackgroundTransparency = 0.5
    BarTrack.Parent = LoadBG
    Instance.new("UICorner", BarTrack).CornerRadius = UDim.new(1, 0)

    local BarFill = Instance.new("Frame")
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    BarFill.BorderSizePixel = 0
    BarFill.Parent = BarTrack
    Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

    local LoadStatus = Instance.new("TextLabel")
    LoadStatus.Text = "Initializing..."
    LoadStatus.Size = UDim2.new(0, 320, 0, 20)
    LoadStatus.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadStatus.Position = UDim2.new(0.5, 0, 0.71, 0)
    LoadStatus.BackgroundTransparency = 1
    LoadStatus.TextColor3 = Color3.fromRGB(100, 160, 220)
    LoadStatus.Font = Enum.Font.Gotham
    LoadStatus.TextSize = 12
    LoadStatus.Parent = LoadBG

    task.spawn(function()
        local stages = {{
            text = "Loading modules...",
            pct = 0.20
        }, {
            text = "Setting up ESP...",
            pct = 0.45
        }, {
            text = "Connecting FishZone...",
            pct = 0.65
        }, {
            text = "Building GUI...",
            pct = 0.85
        }, {
            text = "Welcome.",
            pct = 1.00
        }}
        task.wait(0.1)
        tweenProp(LoadTitle, {
            TextTransparency = 0
        }, 0.7)
        tweenProp(Orb, {
            BackgroundTransparency = 0.55
        }, 0.9)
        task.wait(0.5)
        tweenProp(LoadQuote, {
            TextTransparency = 0
        }, 0.8)
        task.wait(0.3)
        for _, stage in ipairs(stages) do
            LoadStatus.Text = stage.text
            tweenProp(BarFill, {
                Size = UDim2.new(stage.pct, 0, 1, 0)
            }, 0.45, Enum.EasingStyle.Quint)
            task.wait(0.38)
        end
        task.wait(0.3)
        tweenProp(LoadBG, {
            BackgroundTransparency = 1
        }, 0.55)
        task.wait(0.6)
        pcall(function()
            LoadGui:Destroy()
        end)
    end)
    -- End loading screen animation

    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AhzencalESPv3_Split"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999
    pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = lp:WaitForChild("PlayerGui")
    end

    -- Main frame (sidebar + content area)
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 470, 0, 380)
    Main.Position = UDim2.new(0.5, -235, 0.5, -190)
    Main.BackgroundColor3 = THEME.bg
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Color3.fromRGB(60, 70, 95)
    MainStroke.Thickness = 1.2

    -- Sidebar (left, 80px wide)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 80, 1, 0)
    Sidebar.Position = UDim2.new(0, 0, 0, 0)
    Sidebar.BackgroundColor3 = THEME.bg2
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 14)

    -- Mask right side of sidebar corner radius
    local SidebarMask = Instance.new("Frame")
    SidebarMask.Size = UDim2.new(0, 14, 1, 0)
    SidebarMask.Position = UDim2.new(1, -14, 0, 0)
    SidebarMask.BackgroundColor3 = THEME.bg2
    SidebarMask.BorderSizePixel = 0
    SidebarMask.Parent = Sidebar

    -- Title at top of sidebar
    local Title = Instance.new("TextLabel")
    Title.Text = "AH"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Position = UDim2.new(0, 0, 0, 8)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = THEME.text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = Sidebar

    -- Subtitle (hidden but exists for API contract)
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Text = "ESP"
    Subtitle.Size = UDim2.new(1, 0, 0, 12)
    Subtitle.Position = UDim2.new(0, 0, 0, 42)
    Subtitle.BackgroundTransparency = 1
    Subtitle.TextColor3 = THEME.dim
    Subtitle.Font = Enum.Font.Gotham
    Subtitle.TextSize = 8
    Subtitle.Parent = Sidebar

    -- Header (minimal, exists for API contract)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(0, 80, 0, 54)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundColor3 = THEME.bg2
    Header.BackgroundTransparency = 1
    Header.BorderSizePixel = 0
    Header.Parent = Sidebar

    local HeaderMask = Instance.new("Frame")
    HeaderMask.Size = UDim2.new(0, 80, 0, 16)
    HeaderMask.Position = UDim2.new(0, 0, 0, 38)
    HeaderMask.BackgroundColor3 = THEME.bg2
    HeaderMask.BackgroundTransparency = 1
    HeaderMask.BorderSizePixel = 0
    HeaderMask.Parent = Sidebar

    -- TabsBar (sidebar nav area, exists for API contract)
    local TabsBar = Instance.new("Frame")
    TabsBar.Size = UDim2.new(1, 0, 0, 220)
    TabsBar.Position = UDim2.new(0, 0, 0, 60)
    TabsBar.BackgroundColor3 = THEME.panel
    TabsBar.BackgroundTransparency = 1
    TabsBar.BorderSizePixel = 0
    TabsBar.Parent = Sidebar

    -- Sidebar nav buttons (vertical)
    local tabNames = {"Players", "FishZone", "Clicker", "Settings"}
    local tabIcons = {"P", "F", "C", "S"}
    local TabButtons = {}

    for i, name in ipairs(tabNames) do
        local btn = Instance.new("TextButton")
        btn.Text = tabIcons[i]
        btn.Size = UDim2.new(0, 56, 0, 42)
        btn.Position = UDim2.new(0.5, -28, 0, (i - 1) * 50)
        btn.BackgroundColor3 = THEME.panel2
        btn.TextColor3 = THEME.dim
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.BorderSizePixel = 0
        btn.Parent = TabsBar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
        TabButtons[name] = btn
    end

    -- Minimize and close buttons at bottom of sidebar
    local MinBtn = Instance.new("TextButton")
    MinBtn.Text = "-"
    MinBtn.Size = UDim2.new(0, 28, 0, 28)
    MinBtn.Position = UDim2.new(0.5, -30, 1, -40)
    MinBtn.BackgroundColor3 = Color3.fromRGB(64, 74, 102)
    MinBtn.TextColor3 = Color3.new(1, 1, 1)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 14
    MinBtn.BorderSizePixel = 0
    MinBtn.Parent = Sidebar
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Text = "x"
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(0.5, 2, 1, -40)
    CloseBtn.BackgroundColor3 = THEME.danger
    CloseBtn.TextColor3 = Color3.new(1, 1, 1)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = Sidebar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

    -- Content area (right side)
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -90, 1, -14)
    Content.Position = UDim2.new(0, 84, 0, 7)
    Content.BackgroundColor3 = THEME.panel
    Content.BorderSizePixel = 0
    Content.ClipsDescendants = true
    Content.Parent = Main
    Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 12)
    local ContentStroke = Instance.new("UIStroke", Content)
    ContentStroke.Color = Color3.fromRGB(48, 58, 82)

    -- Drag bar and hit area
    local DragBar = Instance.new("Frame")
    DragBar.Size = UDim2.new(0, 100, 0, 6)
    DragBar.AnchorPoint = Vector2.new(0.5, 0)
    DragBar.Position = UDim2.new(0.5, 40, 1, 6)
    DragBar.BackgroundColor3 = Color3.fromRGB(95, 108, 142)
    DragBar.BorderSizePixel = 0
    DragBar.Parent = Main
    Instance.new("UICorner", DragBar).CornerRadius = UDim.new(1, 0)

    local DragHit = Instance.new("TextButton")
    DragHit.Size = UDim2.new(0, 140, 0, 18)
    DragHit.AnchorPoint = Vector2.new(0.5, 0)
    DragHit.Position = UDim2.new(0.5, 40, 1, 2)
    DragHit.Text = ""
    DragHit.BackgroundTransparency = 1
    DragHit.Parent = Main

    -- Tab content frames
    local Tabs = {}
    for i, name in ipairs(tabNames) do
        local f = Instance.new("Frame")
        f.Name = name .. "Tab"
        f.Size = UDim2.new(1, 0, 1, 0)
        f.BackgroundTransparency = 1
        f.Visible = i == 1
        f.Parent = Content
        Tabs[name] = f
    end

    -- Players tab content
    local SearchBox = Instance.new("TextBox")
    SearchBox.PlaceholderText = "Search player..."
    SearchBox.Text = ""
    SearchBox.ClearTextOnFocus = false
    SearchBox.Size = UDim2.new(1, -16, 0, 32)
    SearchBox.Position = UDim2.new(0, 8, 0, 8)
    SearchBox.BackgroundColor3 = THEME.panel2
    SearchBox.TextColor3 = THEME.text
    SearchBox.PlaceholderColor3 = THEME.dim
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 13
    SearchBox.BorderSizePixel = 0
    SearchBox.Parent = Tabs.Players
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 10)

    local PlayerList = Instance.new("ScrollingFrame")
    PlayerList.Size = UDim2.new(1, -16, 1, -70)
    PlayerList.Position = UDim2.new(0, 8, 0, 46)
    PlayerList.BackgroundColor3 = THEME.bg2
    PlayerList.BorderSizePixel = 0
    PlayerList.ScrollBarThickness = 4
    PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    PlayerList.Parent = Tabs.Players
    Instance.new("UICorner", PlayerList).CornerRadius = UDim.new(0, 10)
    local PlayerListLayout = Instance.new("UIListLayout", PlayerList)
    PlayerListLayout.Padding = UDim.new(0, 5)

    local PlayerHint = Instance.new("TextLabel")
    PlayerHint.Text = "Scroll for more players"
    PlayerHint.Size = UDim2.new(1, -16, 0, 16)
    PlayerHint.Position = UDim2.new(0, 8, 1, -20)
    PlayerHint.BackgroundTransparency = 1
    PlayerHint.TextColor3 = THEME.dim
    PlayerHint.Font = Enum.Font.Gotham
    PlayerHint.TextSize = 10
    PlayerHint.TextXAlignment = Enum.TextXAlignment.Left
    PlayerHint.Parent = Tabs.Players

    -- FishZone tab content
    local function makeActionButton(parent, text, y, color)
        local b = Instance.new("TextButton")
        b.Text = text
        b.Size = UDim2.new(1, -16, 0, 34)
        b.Position = UDim2.new(0, 8, 0, y)
        b.BackgroundColor3 = color
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 12
        b.BorderSizePixel = 0
        b.Parent = parent
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
        return b
    end

    local ZoneESPBtn = makeActionButton(Tabs.FishZone, "FishZone ESP: OFF", 8, THEME.accent)
    local AutoTPBtn = makeActionButton(Tabs.FishZone, "Auto TP Active FishZone: OFF", 48, THEME.tp)
    local RefreshCharBtn = makeActionButton(Tabs.FishZone, "Refresh Character", 88, THEME.danger)
    local AutoSellBtn = makeActionButton(Tabs.FishZone, "Auto Sell Fish: OFF", 128, THEME.warn)
    local SellNowBtn = makeActionButton(Tabs.FishZone, "Sell All Now (Test)", 168, THEME.accent)

    local ZoneStatus = Instance.new("TextLabel")
    ZoneStatus.Size = UDim2.new(1, -16, 0, 20)
    ZoneStatus.Position = UDim2.new(0, 8, 0, 212)
    ZoneStatus.BackgroundTransparency = 1
    ZoneStatus.TextColor3 = THEME.text
    ZoneStatus.Text = "Status: Idle"
    ZoneStatus.Font = Enum.Font.GothamBold
    ZoneStatus.TextSize = 12
    ZoneStatus.TextXAlignment = Enum.TextXAlignment.Left
    ZoneStatus.Parent = Tabs.FishZone

    local ZoneInfo = Instance.new("TextLabel")
    ZoneInfo.Size = UDim2.new(1, -16, 0, 80)
    ZoneInfo.Position = UDim2.new(0, 8, 0, 238)
    ZoneInfo.BackgroundTransparency = 1
    ZoneInfo.TextColor3 = THEME.dim
    ZoneInfo.Text = "Active zones only\nAuto TP keeps rotation/body lock\nRefresh uses Adonis commands\nCore logic in core.lua"
    ZoneInfo.Font = Enum.Font.Gotham
    ZoneInfo.TextSize = 11
    ZoneInfo.TextWrapped = true
    ZoneInfo.TextXAlignment = Enum.TextXAlignment.Left
    ZoneInfo.TextYAlignment = Enum.TextYAlignment.Top
    ZoneInfo.Parent = Tabs.FishZone

    -- Clicker tab content
    local StatusLbl = Instance.new("TextLabel")
    StatusLbl.Size = UDim2.new(1, -16, 0, 22)
    StatusLbl.Position = UDim2.new(0, 8, 0, 8)
    StatusLbl.BackgroundTransparency = 1
    StatusLbl.Text = "Status: OFF"
    StatusLbl.TextColor3 = THEME.danger
    StatusLbl.Font = Enum.Font.GothamBold
    StatusLbl.TextSize = 14
    StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
    StatusLbl.Parent = Tabs.Clicker

    local PosLbl = Instance.new("TextLabel")
    PosLbl.Size = UDim2.new(1, -16, 0, 20)
    PosLbl.Position = UDim2.new(0, 8, 0, 32)
    PosLbl.BackgroundTransparency = 1
    PosLbl.Text = "Target: Not set (press P)"
    PosLbl.TextColor3 = THEME.dim
    PosLbl.Font = Enum.Font.Gotham
    PosLbl.TextSize = 12
    PosLbl.TextXAlignment = Enum.TextXAlignment.Left
    PosLbl.Parent = Tabs.Clicker

    local MethodLbl = Instance.new("TextLabel")
    MethodLbl.Size = UDim2.new(1, -16, 0, 20)
    MethodLbl.Position = UDim2.new(0, 8, 0, 54)
    MethodLbl.BackgroundTransparency = 1
    MethodLbl.Text = "Mode: Loading..."
    MethodLbl.TextColor3 = THEME.warn
    MethodLbl.Font = Enum.Font.Gotham
    MethodLbl.TextSize = 12
    MethodLbl.TextXAlignment = Enum.TextXAlignment.Left
    MethodLbl.Parent = Tabs.Clicker

    local CPSLbl = Instance.new("TextLabel")
    CPSLbl.Size = UDim2.new(1, -16, 0, 20)
    CPSLbl.Position = UDim2.new(0, 8, 0, 78)
    CPSLbl.BackgroundTransparency = 1
    CPSLbl.Text = "CPS: " .. tostring(config.Clicker.DefaultCPS)
    CPSLbl.TextColor3 = THEME.text
    CPSLbl.Font = Enum.Font.GothamBold
    CPSLbl.TextSize = 12
    CPSLbl.TextXAlignment = Enum.TextXAlignment.Left
    CPSLbl.Parent = Tabs.Clicker

    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, -16, 0, 8)
    SliderTrack.Position = UDim2.new(0, 8, 0, 106)
    SliderTrack.BackgroundColor3 = THEME.bg2
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Parent = Tabs.Clicker
    Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(1, 0)

    local ratio = math.clamp(config.Clicker.DefaultCPS / 100, 0, 1)
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
    SliderFill.BackgroundColor3 = THEME.accent
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack
    Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)

    local SliderKnob = Instance.new("Frame")
    SliderKnob.Size = UDim2.new(0, 16, 0, 16)
    SliderKnob.Position = UDim2.new(ratio, -8, 0.5, -8)
    SliderKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    SliderKnob.BorderSizePixel = 0
    SliderKnob.Parent = SliderTrack
    Instance.new("UICorner", SliderKnob).CornerRadius = UDim.new(1, 0)

    local ToggleBtn = makeActionButton(Tabs.Clicker, "Start [F]", 130, THEME.accent)

    -- Settings tab content
    local HideKeyLbl = Instance.new("TextLabel")
    HideKeyLbl.Size = UDim2.new(1, -16, 0, 22)
    HideKeyLbl.Position = UDim2.new(0, 8, 0, 8)
    HideKeyLbl.BackgroundTransparency = 1
    HideKeyLbl.Text = "Hide/Show UI: " .. tostring(config.Keys.HideUI):gsub("Enum.KeyCode.", "")
    HideKeyLbl.TextColor3 = THEME.text
    HideKeyLbl.Font = Enum.Font.GothamBold
    HideKeyLbl.TextSize = 12
    HideKeyLbl.TextXAlignment = Enum.TextXAlignment.Left
    HideKeyLbl.Parent = Tabs.Settings

    local UnloadBtn = makeActionButton(Tabs.Settings, "Unload Script", 36, THEME.danger)
    local AutoClaimDailyRewardBtn = makeActionButton(Tabs.Settings, "Auto Claim Daily Reward: OFF", 76, THEME.accent)
    local AutoClaimSessionRewardBtn = makeActionButton(Tabs.Settings, "Auto Claim Session Reward: OFF", 116, THEME.tp)

    local ColorTitle = Instance.new("TextLabel")
    ColorTitle.Size = UDim2.new(1, -16, 0, 20)
    ColorTitle.Position = UDim2.new(0, 8, 0, 162)
    ColorTitle.BackgroundTransparency = 1
    ColorTitle.Text = "Accent Color"
    ColorTitle.TextColor3 = THEME.text
    ColorTitle.Font = Enum.Font.GothamBold
    ColorTitle.TextSize = 12
    ColorTitle.TextXAlignment = Enum.TextXAlignment.Left
    ColorTitle.Parent = Tabs.Settings

    local AccentPreview = Instance.new("Frame")
    AccentPreview.Size = UDim2.new(0, 24, 0, 24)
    AccentPreview.Position = UDim2.new(1, -32, 0, 160)
    AccentPreview.BackgroundColor3 = THEME.accent
    AccentPreview.BorderSizePixel = 0
    AccentPreview.Parent = Tabs.Settings
    Instance.new("UICorner", AccentPreview).CornerRadius = UDim.new(0, 8)

    local ColorButtons = {}
    for i, color in ipairs(config.ThemePresets) do
        local sw = Instance.new("TextButton")
        sw.Text = ""
        sw.Size = UDim2.new(0, 30, 0, 30)
        sw.Position = UDim2.new(0, 8 + ((i - 1) % 4) * 38, 0, 190 + math.floor((i - 1) / 4) * 38)
        sw.BackgroundColor3 = color
        sw.BorderSizePixel = 0
        sw.Parent = Tabs.Settings
        Instance.new("UICorner", sw).CornerRadius = UDim.new(0, 8)
        table.insert(ColorButtons, sw)
    end

    local SettingsInfo = Instance.new("TextLabel")
    SettingsInfo.Size = UDim2.new(1, -16, 0, 50)
    SettingsInfo.Position = UDim2.new(0, 8, 1, -58)
    SettingsInfo.BackgroundTransparency = 1
    SettingsInfo.Text = "Use config.lua for keys, blacklist positions, float height, colors, presets, and reward toggles."
    SettingsInfo.TextColor3 = THEME.dim
    SettingsInfo.Font = Enum.Font.Gotham
    SettingsInfo.TextSize = 11
    SettingsInfo.TextWrapped = true
    SettingsInfo.TextXAlignment = Enum.TextXAlignment.Left
    SettingsInfo.TextYAlignment = Enum.TextYAlignment.Top
    SettingsInfo.Parent = Tabs.Settings

    -- Return table (API contract must match exactly)
    return {
        Theme = THEME,
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
            PlayerHint = PlayerHint
        },
        FishZone = {
            ZoneESPBtn = ZoneESPBtn,
            AutoTPBtn = AutoTPBtn,
            RefreshCharBtn = RefreshCharBtn,
            AutoSellBtn = AutoSellBtn,
            SellNowBtn = SellNowBtn,
            ZoneStatus = ZoneStatus,
            ZoneInfo = ZoneInfo
        },
        Clicker = {
            StatusLbl = StatusLbl,
            PosLbl = PosLbl,
            MethodLbl = MethodLbl,
            CPSLbl = CPSLbl,
            SliderTrack = SliderTrack,
            SliderFill = SliderFill,
            SliderKnob = SliderKnob,
            ToggleBtn = ToggleBtn
        },
        Settings = {
            HideKeyLbl = HideKeyLbl,
            UnloadBtn = UnloadBtn,
            AutoClaimDailyRewardBtn = AutoClaimDailyRewardBtn,
            AutoClaimSessionRewardBtn = AutoClaimSessionRewardBtn,
            ColorTitle = ColorTitle,
            AccentPreview = AccentPreview,
            ColorButtons = ColorButtons,
            SettingsInfo = SettingsInfo
        }
    }
end
