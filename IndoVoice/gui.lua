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
    LoadBG.Size = UDim2.new(0, 620, 0, 420)
    LoadBG.AnchorPoint = Vector2.new(0.5, 0.5)
    LoadBG.Position = UDim2.new(0.5, 0, 0.5, 0)
    LoadBG.BackgroundColor3 = LYRA.bg
    LoadBG.BorderSizePixel = 0
    LoadBG.Parent = LoadGui
    Instance.new("UICorner", LoadBG).CornerRadius = UDim.new(0, 12)
    local LoadStroke = Instance.new("UIStroke", LoadBG)
    LoadStroke.Color = LYRA.accent
    LoadStroke.Thickness = 1.5

    local LoadTitle = Instance.new("TextLabel")
    LoadTitle.Text = "LYRA HUB"
    LoadTitle.Size = UDim2.new(1, 0, 0, 44)
    LoadTitle.Position = UDim2.new(0, 0, 0, 120)
    LoadTitle.BackgroundTransparency = 1
    LoadTitle.TextColor3 = LYRA.accentGlow
    LoadTitle.Font = Enum.Font.GothamBold
    LoadTitle.TextSize = 30
    LoadTitle.TextTransparency = 1
    LoadTitle.Parent = LoadBG

    local LoadQuote = Instance.new("TextLabel")
    LoadQuote.Text = "Precision tools for the bold"
    LoadQuote.Size = UDim2.new(1, 0, 0, 24)
    LoadQuote.Position = UDim2.new(0, 0, 0, 170)
    LoadQuote.BackgroundTransparency = 1
    LoadQuote.TextColor3 = LYRA.dim
    LoadQuote.Font = Enum.Font.Gotham
    LoadQuote.TextSize = 13
    LoadQuote.TextTransparency = 1
    LoadQuote.Parent = LoadBG

    local BarTrack = Instance.new("Frame")
    BarTrack.Size = UDim2.new(0, 360, 0, 4)
    BarTrack.AnchorPoint = Vector2.new(0.5, 0)
    BarTrack.Position = UDim2.new(0.5, 0, 0, 230)
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
    LoadStatus.Position = UDim2.new(0, 0, 0, 248)
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

    -- Minimized orb (circular "L" button, hidden by default)
    local MinimizedOrb = Instance.new("TextButton")
    MinimizedOrb.Size = UDim2.new(0, 44, 0, 44)
    MinimizedOrb.Position = UDim2.new(0, 20, 0, 20)
    MinimizedOrb.AnchorPoint = Vector2.new(0, 0)
    MinimizedOrb.BackgroundColor3 = LYRA.accent
    MinimizedOrb.Text = "L"
    MinimizedOrb.TextColor3 = Color3.new(1, 1, 1)
    MinimizedOrb.Font = Enum.Font.GothamBold
    MinimizedOrb.TextSize = 18
    MinimizedOrb.BorderSizePixel = 0
    MinimizedOrb.Visible = false
    MinimizedOrb.Parent = ScreenGui
    Instance.new("UICorner", MinimizedOrb).CornerRadius = UDim.new(1, 0)
    local OrbStroke = Instance.new("UIStroke", MinimizedOrb)
    OrbStroke.Color = LYRA.accentGlow
    OrbStroke.Thickness = 1.5

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
    TabsBar.Size = UDim2.new(1, 0, 1, -74)
    TabsBar.Position = UDim2.new(0, 0, 0, 74)
    TabsBar.BackgroundTransparency = 1
    TabsBar.BorderSizePixel = 0
    TabsBar.ClipsDescendants = true
    TabsBar.Parent = Sidebar

    -- Sidebar nav buttons (full text, vertical)
    local tabNames = {"About", "Players", "FishZone", "AutoFish", "Fun", "Settings", "Logs"}
    local tabIcons = {"About", "Players", "FishZone", "AutoFish", "Fun", "Settings", "Logs"}
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
    -- ABOUT TAB
    -- ═══════════════════════════════════════════
    local AboutTitle = Instance.new("TextLabel")
    AboutTitle.Size = UDim2.new(1, -20, 0, 30)
    AboutTitle.Position = UDim2.new(0, 10, 0, 20)
    AboutTitle.BackgroundTransparency = 1
    AboutTitle.Text = "LyraHub"
    AboutTitle.TextColor3 = LYRA.accentGlow
    AboutTitle.Font = Enum.Font.GothamBold
    AboutTitle.TextSize = 22
    AboutTitle.TextXAlignment = Enum.TextXAlignment.Left
    AboutTitle.Parent = Tabs.About

    local AboutSub = Instance.new("TextLabel")
    AboutSub.Size = UDim2.new(1, -20, 0, 18)
    AboutSub.Position = UDim2.new(0, 10, 0, 52)
    AboutSub.BackgroundTransparency = 1
    AboutSub.Text = "Automation tools for IndoVoice"
    AboutSub.TextColor3 = LYRA.dim
    AboutSub.Font = Enum.Font.Gotham
    AboutSub.TextSize = 12
    AboutSub.TextXAlignment = Enum.TextXAlignment.Left
    AboutSub.Parent = Tabs.About

    local AboutSep = Instance.new("Frame")
    AboutSep.Size = UDim2.new(1, -20, 0, 1)
    AboutSep.Position = UDim2.new(0, 10, 0, 80)
    AboutSep.BackgroundColor3 = LYRA.panel2
    AboutSep.BorderSizePixel = 0
    AboutSep.Parent = Tabs.About

    local AboutDiscord = Instance.new("TextLabel")
    AboutDiscord.Size = UDim2.new(1, -20, 0, 20)
    AboutDiscord.Position = UDim2.new(0, 10, 0, 94)
    AboutDiscord.BackgroundTransparency = 1
    AboutDiscord.Text = "Discord: Ahzencal"
    AboutDiscord.TextColor3 = LYRA.text
    AboutDiscord.Font = Enum.Font.GothamBold
    AboutDiscord.TextSize = 13
    AboutDiscord.TextXAlignment = Enum.TextXAlignment.Left
    AboutDiscord.Parent = Tabs.About

    local AboutSaweria = Instance.new("TextLabel")
    AboutSaweria.Size = UDim2.new(1, -20, 0, 20)
    AboutSaweria.Position = UDim2.new(0, 10, 0, 120)
    AboutSaweria.BackgroundTransparency = 1
    AboutSaweria.Text = "Saweria: saweria.co/ahzencal"
    AboutSaweria.TextColor3 = LYRA.text
    AboutSaweria.Font = Enum.Font.GothamBold
    AboutSaweria.TextSize = 13
    AboutSaweria.TextXAlignment = Enum.TextXAlignment.Left
    AboutSaweria.Parent = Tabs.About

    local CopySaweriaBtn = Instance.new("TextButton")
    CopySaweriaBtn.Size = UDim2.new(0, 80, 0, 24)
    CopySaweriaBtn.Position = UDim2.new(1, -90, 0, 118)
    CopySaweriaBtn.BackgroundColor3 = LYRA.accent
    CopySaweriaBtn.Text = "Copy"
    CopySaweriaBtn.TextColor3 = Color3.new(1, 1, 1)
    CopySaweriaBtn.Font = Enum.Font.GothamBold
    CopySaweriaBtn.TextSize = 11
    CopySaweriaBtn.BorderSizePixel = 0
    CopySaweriaBtn.Parent = Tabs.About
    Instance.new("UICorner", CopySaweriaBtn).CornerRadius = UDim.new(0, 6)

    local AboutSep2 = Instance.new("Frame")
    AboutSep2.Size = UDim2.new(1, -20, 0, 1)
    AboutSep2.Position = UDim2.new(0, 10, 0, 154)
    AboutSep2.BackgroundColor3 = LYRA.panel2
    AboutSep2.BorderSizePixel = 0
    AboutSep2.Parent = Tabs.About

    local AboutCreator = Instance.new("TextLabel")
    AboutCreator.Size = UDim2.new(1, -20, 0, 40)
    AboutCreator.Position = UDim2.new(0, 10, 0, 168)
    AboutCreator.BackgroundTransparency = 1
    AboutCreator.Text = "Created By: Ahzencal\nLyraHub est. 2026"
    AboutCreator.TextColor3 = LYRA.dim
    AboutCreator.Font = Enum.Font.Gotham
    AboutCreator.TextSize = 12
    AboutCreator.TextXAlignment = Enum.TextXAlignment.Left
    AboutCreator.TextYAlignment = Enum.TextYAlignment.Top
    AboutCreator.Parent = Tabs.About

    local AboutVersion = Instance.new("TextLabel")
    AboutVersion.Size = UDim2.new(1, -20, 0, 20)
    AboutVersion.Position = UDim2.new(0, 10, 1, -30)
    AboutVersion.BackgroundTransparency = 1
    AboutVersion.Text = "v2.0 | Lyra Engine"
    AboutVersion.TextColor3 = LYRA.dim
    AboutVersion.Font = Enum.Font.Code
    AboutVersion.TextSize = 10
    AboutVersion.TextXAlignment = Enum.TextXAlignment.Left
    AboutVersion.Parent = Tabs.About

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
    local SellNowBtn = makeActionButton(Tabs.FishZone, "Sell All Now", 162, LYRA.accent)

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
    -- AUTOFISH TAB
    -- ═══════════════════════════════════════════
    local AutoFishToggleBtn = makeActionButton(Tabs.AutoFish, "Auto Fish: OFF", 10, LYRA.accent)

    local AutoFishStatus = Instance.new("TextLabel")
    AutoFishStatus.Size = UDim2.new(1, -20, 0, 20)
    AutoFishStatus.Position = UDim2.new(0, 10, 0, 50)
    AutoFishStatus.BackgroundTransparency = 1
    AutoFishStatus.TextColor3 = LYRA.dim
    AutoFishStatus.Text = "Status: Idle"
    AutoFishStatus.Font = Enum.Font.GothamBold
    AutoFishStatus.TextSize = 12
    AutoFishStatus.TextXAlignment = Enum.TextXAlignment.Left
    AutoFishStatus.Parent = Tabs.AutoFish

    local AutoFishCasts = Instance.new("TextLabel")
    AutoFishCasts.Size = UDim2.new(1, -20, 0, 18)
    AutoFishCasts.Position = UDim2.new(0, 10, 0, 74)
    AutoFishCasts.BackgroundTransparency = 1
    AutoFishCasts.TextColor3 = LYRA.dim
    AutoFishCasts.Text = "Casts: 0 | Caught: 0"
    AutoFishCasts.Font = Enum.Font.Gotham
    AutoFishCasts.TextSize = 11
    AutoFishCasts.TextXAlignment = Enum.TextXAlignment.Left
    AutoFishCasts.Parent = Tabs.AutoFish

    local AutoFishLastCatch = Instance.new("TextLabel")
    AutoFishLastCatch.Size = UDim2.new(1, -20, 0, 18)
    AutoFishLastCatch.Position = UDim2.new(0, 10, 0, 94)
    AutoFishLastCatch.BackgroundTransparency = 1
    AutoFishLastCatch.TextColor3 = LYRA.dim
    AutoFishLastCatch.Text = "Last: -"
    AutoFishLastCatch.Font = Enum.Font.Gotham
    AutoFishLastCatch.TextSize = 11
    AutoFishLastCatch.TextXAlignment = Enum.TextXAlignment.Left
    AutoFishLastCatch.Parent = Tabs.AutoFish

    -- Separator
    local AFSep = Instance.new("Frame")
    AFSep.Size = UDim2.new(1, -20, 0, 1)
    AFSep.Position = UDim2.new(0, 10, 0, 120)
    AFSep.BackgroundColor3 = LYRA.panel2
    AFSep.BorderSizePixel = 0
    AFSep.Parent = Tabs.AutoFish

    -- Settings info
    local AFSettingsTitle = Instance.new("TextLabel")
    AFSettingsTitle.Size = UDim2.new(1, -20, 0, 18)
    AFSettingsTitle.Position = UDim2.new(0, 10, 0, 128)
    AFSettingsTitle.BackgroundTransparency = 1
    AFSettingsTitle.TextColor3 = LYRA.text
    AFSettingsTitle.Text = "Timing Settings"
    AFSettingsTitle.Font = Enum.Font.GothamBold
    AFSettingsTitle.TextSize = 11
    AFSettingsTitle.TextXAlignment = Enum.TextXAlignment.Left
    AFSettingsTitle.Parent = Tabs.AutoFish

    local AFTimings = Instance.new("TextLabel")
    AFTimings.Size = UDim2.new(1, -20, 0, 120)
    AFTimings.Position = UDim2.new(0, 10, 0, 148)
    AFTimings.BackgroundTransparency = 1
    AFTimings.TextColor3 = LYRA.dim
    AFTimings.Text = "Pre-cast delay: 0.3s\nCast hold: random 0.4-0.6s\nVerify cast timeout: 2.5s\nPull timeout: 20s\nPost-pull delay: 2.8s\nPost-pull timeout: 5s\nPost-end delay: 0.3s"
    AFTimings.Font = Enum.Font.Code
    AFTimings.TextSize = 10
    AFTimings.TextWrapped = true
    AFTimings.TextXAlignment = Enum.TextXAlignment.Left
    AFTimings.TextYAlignment = Enum.TextYAlignment.Top
    AFTimings.Parent = Tabs.AutoFish

    -- Performance Monitor section (card-style)
    local AFPerfSep = Instance.new("Frame")
    AFPerfSep.Size = UDim2.new(1, -20, 0, 1)
    AFPerfSep.Position = UDim2.new(0, 10, 0, 278)
    AFPerfSep.BackgroundColor3 = LYRA.panel2
    AFPerfSep.BorderSizePixel = 0
    AFPerfSep.Parent = Tabs.AutoFish

    local AFPerfTitle = Instance.new("TextLabel")
    AFPerfTitle.Size = UDim2.new(1, -20, 0, 18)
    AFPerfTitle.Position = UDim2.new(0, 10, 0, 284)
    AFPerfTitle.BackgroundTransparency = 1
    AFPerfTitle.TextColor3 = LYRA.accentGlow
    AFPerfTitle.Text = "📊 Performance"
    AFPerfTitle.Font = Enum.Font.GothamBold
    AFPerfTitle.TextSize = 12
    AFPerfTitle.TextXAlignment = Enum.TextXAlignment.Left
    AFPerfTitle.Parent = Tabs.AutoFish

    -- Stat cards row 1
    local function makeStatCard(parent, x, y, w)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(0, w, 0, 44)
        card.Position = UDim2.new(0, x, 0, y)
        card.BackgroundColor3 = LYRA.bg2
        card.BorderSizePixel = 0
        card.Parent = parent
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(1, -8, 0, 22)
        valLbl.Position = UDim2.new(0, 4, 0, 2)
        valLbl.BackgroundTransparency = 1
        valLbl.TextColor3 = LYRA.text
        valLbl.Font = Enum.Font.GothamBold
        valLbl.TextSize = 14
        valLbl.Text = "0"
        valLbl.TextXAlignment = Enum.TextXAlignment.Center
        valLbl.Parent = card

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -8, 0, 14)
        nameLbl.Position = UDim2.new(0, 4, 0, 26)
        nameLbl.BackgroundTransparency = 1
        nameLbl.TextColor3 = LYRA.dim
        nameLbl.Font = Enum.Font.Gotham
        nameLbl.TextSize = 9
        nameLbl.Text = "Label"
        nameLbl.TextXAlignment = Enum.TextXAlignment.Center
        nameLbl.Parent = card

        return valLbl, nameLbl
    end

    local perfFishHrVal, perfFishHrLbl = makeStatCard(Tabs.AutoFish, 10, 306, 85)
    perfFishHrLbl.Text = "Fish/hr"

    local perfCaughtVal, perfCaughtLbl = makeStatCard(Tabs.AutoFish, 101, 306, 75)
    perfCaughtLbl.Text = "Caught"

    local perfSellsVal, perfSellsLbl = makeStatCard(Tabs.AutoFish, 182, 306, 75)
    perfSellsLbl.Text = "Sells"

    local perfEarnVal, perfEarnLbl = makeStatCard(Tabs.AutoFish, 263, 306, 95)
    perfEarnLbl.Text = "Earned $"

    -- Rarity breakdown row
    local AFPerfRarity = Instance.new("TextLabel")
    AFPerfRarity.Size = UDim2.new(1, -20, 0, 30)
    AFPerfRarity.Position = UDim2.new(0, 10, 0, 356)
    AFPerfRarity.BackgroundTransparency = 1
    AFPerfRarity.TextColor3 = LYRA.dim
    AFPerfRarity.Text = "Rarities: -"
    AFPerfRarity.Font = Enum.Font.Code
    AFPerfRarity.TextSize = 9
    AFPerfRarity.TextWrapped = true
    AFPerfRarity.TextXAlignment = Enum.TextXAlignment.Left
    AFPerfRarity.TextYAlignment = Enum.TextYAlignment.Top
    AFPerfRarity.Parent = Tabs.AutoFish

    -- We keep AFPerfStats as a hidden container for the update function
    local AFPerfStats = Instance.new("Frame")
    AFPerfStats.Size = UDim2.new(0, 0, 0, 0)
    AFPerfStats.Visible = false
    AFPerfStats.Parent = Tabs.AutoFish

    -- ═══════════════════════════════════════════
    -- FUN THINGS TAB (Auto Clicker + Auto Gacha)
    -- ═══════════════════════════════════════════
    local FunScroll = Instance.new("ScrollingFrame")
    FunScroll.Size = UDim2.new(1, 0, 1, 0)
    FunScroll.Position = UDim2.new(0, 0, 0, 0)
    FunScroll.BackgroundTransparency = 1
    FunScroll.BorderSizePixel = 0
    FunScroll.ScrollBarThickness = 3
    FunScroll.CanvasSize = UDim2.new(0, 0, 0, 520)
    FunScroll.Parent = Tabs.Fun

    -- ── Auto Clicker Section ──
    local ClickerTitle = Instance.new("TextLabel")
    ClickerTitle.Size = UDim2.new(1, -20, 0, 18)
    ClickerTitle.Position = UDim2.new(0, 10, 0, 8)
    ClickerTitle.BackgroundTransparency = 1
    ClickerTitle.Text = "🖱 Auto Clicker"
    ClickerTitle.TextColor3 = LYRA.accentGlow
    ClickerTitle.Font = Enum.Font.GothamBold
    ClickerTitle.TextSize = 12
    ClickerTitle.TextXAlignment = Enum.TextXAlignment.Left
    ClickerTitle.Parent = FunScroll

    local StatusLbl = Instance.new("TextLabel")
    StatusLbl.Size = UDim2.new(1, -20, 0, 18)
    StatusLbl.Position = UDim2.new(0, 10, 0, 30)
    StatusLbl.BackgroundTransparency = 1
    StatusLbl.Text = "Status: OFF"
    StatusLbl.TextColor3 = LYRA.danger
    StatusLbl.Font = Enum.Font.GothamBold
    StatusLbl.TextSize = 12
    StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
    StatusLbl.Parent = FunScroll

    local PosLbl = Instance.new("TextLabel")
    PosLbl.Size = UDim2.new(1, -20, 0, 16)
    PosLbl.Position = UDim2.new(0, 10, 0, 50)
    PosLbl.BackgroundTransparency = 1
    PosLbl.Text = "Target: Not set (press P)"
    PosLbl.TextColor3 = LYRA.dim
    PosLbl.Font = Enum.Font.Gotham
    PosLbl.TextSize = 11
    PosLbl.TextXAlignment = Enum.TextXAlignment.Left
    PosLbl.Parent = FunScroll

    local MethodLbl = Instance.new("TextLabel")
    MethodLbl.Size = UDim2.new(1, -20, 0, 16)
    MethodLbl.Position = UDim2.new(0, 10, 0, 68)
    MethodLbl.BackgroundTransparency = 1
    MethodLbl.Text = "Mode: Loading..."
    MethodLbl.TextColor3 = LYRA.warn
    MethodLbl.Font = Enum.Font.Gotham
    MethodLbl.TextSize = 11
    MethodLbl.TextXAlignment = Enum.TextXAlignment.Left
    MethodLbl.Parent = FunScroll

    local CPSLbl = Instance.new("TextLabel")
    CPSLbl.Size = UDim2.new(1, -20, 0, 16)
    CPSLbl.Position = UDim2.new(0, 10, 0, 86)
    CPSLbl.BackgroundTransparency = 1
    CPSLbl.Text = "CPS: " .. tostring(config.Clicker.DefaultCPS)
    CPSLbl.TextColor3 = LYRA.text
    CPSLbl.Font = Enum.Font.GothamBold
    CPSLbl.TextSize = 11
    CPSLbl.TextXAlignment = Enum.TextXAlignment.Left
    CPSLbl.Parent = FunScroll

    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, -20, 0, 6)
    SliderTrack.Position = UDim2.new(0, 10, 0, 108)
    SliderTrack.BackgroundColor3 = LYRA.bg2
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Parent = FunScroll
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

    local ToggleBtn = makeActionButton(FunScroll, "Start [F]", 126, LYRA.accent)

    -- ── Auto Gacha Section ──
    local GachaSep = Instance.new("Frame")
    GachaSep.Size = UDim2.new(1, -20, 0, 1)
    GachaSep.Position = UDim2.new(0, 10, 0, 170)
    GachaSep.BackgroundColor3 = LYRA.panel2
    GachaSep.BorderSizePixel = 0
    GachaSep.Parent = FunScroll

    local GachaTitle = Instance.new("TextLabel")
    GachaTitle.Size = UDim2.new(1, -20, 0, 18)
    GachaTitle.Position = UDim2.new(0, 10, 0, 178)
    GachaTitle.BackgroundTransparency = 1
    GachaTitle.Text = "🎰 Auto Gacha (10x BlindBox)"
    GachaTitle.TextColor3 = LYRA.accentGlow
    GachaTitle.Font = Enum.Font.GothamBold
    GachaTitle.TextSize = 12
    GachaTitle.TextXAlignment = Enum.TextXAlignment.Left
    GachaTitle.Parent = FunScroll

    local GachaToggleBtn = makeActionButton(FunScroll, "Auto Gacha: OFF", 200, LYRA.accent)

    local GachaStatus = Instance.new("TextLabel")
    GachaStatus.Size = UDim2.new(1, -20, 0, 18)
    GachaStatus.Position = UDim2.new(0, 10, 0, 240)
    GachaStatus.BackgroundTransparency = 1
    GachaStatus.Text = "Status: Idle | Rolls: 0"
    GachaStatus.TextColor3 = LYRA.dim
    GachaStatus.Font = Enum.Font.Gotham
    GachaStatus.TextSize = 11
    GachaStatus.TextXAlignment = Enum.TextXAlignment.Left
    GachaStatus.Parent = FunScroll

    local GachaLastResult = Instance.new("TextLabel")
    GachaLastResult.Size = UDim2.new(1, -20, 0, 18)
    GachaLastResult.Position = UDim2.new(0, 10, 0, 260)
    GachaLastResult.BackgroundTransparency = 1
    GachaLastResult.Text = "Last: -"
    GachaLastResult.TextColor3 = LYRA.dim
    GachaLastResult.Font = Enum.Font.Gotham
    GachaLastResult.TextSize = 11
    GachaLastResult.TextXAlignment = Enum.TextXAlignment.Left
    GachaLastResult.Parent = FunScroll

    -- Box selection (auto-detected from ReplicatedStorage.Content.BlindBox)
    local GachaBoxTitle = Instance.new("TextLabel")
    GachaBoxTitle.Size = UDim2.new(1, -20, 0, 16)
    GachaBoxTitle.Position = UDim2.new(0, 10, 0, 284)
    GachaBoxTitle.BackgroundTransparency = 1
    GachaBoxTitle.Text = "Select Box:"
    GachaBoxTitle.TextColor3 = LYRA.text
    GachaBoxTitle.Font = Enum.Font.GothamBold
    GachaBoxTitle.TextSize = 10
    GachaBoxTitle.TextXAlignment = Enum.TextXAlignment.Left
    GachaBoxTitle.Parent = FunScroll

    -- Read available boxes
    local availableBoxes = {}
    pcall(function()
        local blindBoxFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Content")
        blindBoxFolder = blindBoxFolder and blindBoxFolder:FindFirstChild("BlindBox")
        if blindBoxFolder then
            for _, child in ipairs(blindBoxFolder:GetChildren()) do
                table.insert(availableBoxes, child.Name)
            end
        end
    end)

    local GachaBoxButtons = {}
    local GachaSelectedBox = Instance.new("StringValue")
    GachaSelectedBox.Value = availableBoxes[1] or ""

    for i, boxName in ipairs(availableBoxes) do
        local btn = Instance.new("TextButton")
        btn.Text = boxName
        btn.Size = UDim2.new(0, 90, 0, 22)
        btn.Position = UDim2.new(0, 10 + ((i - 1) % 3) * 96, 0, 304 + math.floor((i - 1) / 3) * 28)
        btn.BackgroundColor3 = (i == 1) and LYRA.accent or LYRA.panel2
        btn.BackgroundTransparency = (i == 1) and 0.2 or 0.6
        btn.TextColor3 = (i == 1) and Color3.new(1, 1, 1) or LYRA.dim
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9
        btn.BorderSizePixel = 0
        btn.Parent = FunScroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        GachaBoxButtons[boxName] = btn
    end

    -- Calculate Y offset based on number of box rows
    local boxRows = math.ceil(#availableBoxes / 3)
    local stopY = 304 + boxRows * 28 + 10

    -- Stop rarity selection
    local GachaStopTitle = Instance.new("TextLabel")
    GachaStopTitle.Size = UDim2.new(1, -20, 0, 16)
    GachaStopTitle.Position = UDim2.new(0, 10, 0, stopY)
    GachaStopTitle.BackgroundTransparency = 1
    GachaStopTitle.Text = "Stop when rarity obtained:"
    GachaStopTitle.TextColor3 = LYRA.text
    GachaStopTitle.Font = Enum.Font.GothamBold
    GachaStopTitle.TextSize = 10
    GachaStopTitle.TextXAlignment = Enum.TextXAlignment.Left
    GachaStopTitle.Parent = FunScroll

    local gachaRarities = {"Common", "Uncommon", "Rare", "Epic", "Legend", "Mythic"}
    local GachaStopButtons = {}
    for i, rarity in ipairs(gachaRarities) do
        local btn = Instance.new("TextButton")
        btn.Text = rarity
        btn.Size = UDim2.new(0, 62, 0, 22)
        btn.Position = UDim2.new(0, 10 + ((i - 1) % 4) * 68, 0, stopY + 20 + math.floor((i - 1) / 4) * 28)
        btn.BackgroundColor3 = LYRA.panel2
        btn.BackgroundTransparency = 0.6
        btn.TextColor3 = LYRA.dim
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9
        btn.BorderSizePixel = 0
        btn.Parent = FunScroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        GachaStopButtons[rarity] = btn
    end

    -- Update canvas size to fit everything
    FunScroll.CanvasSize = UDim2.new(0, 0, 0, stopY + 90)

    -- ═══════════════════════════════════════════
    -- SETTINGS TAB
    -- ═══════════════════════════════════════════
    local SettingsScroll = Instance.new("ScrollingFrame")
    SettingsScroll.Size = UDim2.new(1, 0, 1, 0)
    SettingsScroll.Position = UDim2.new(0, 0, 0, 0)
    SettingsScroll.BackgroundTransparency = 1
    SettingsScroll.BorderSizePixel = 0
    SettingsScroll.ScrollBarThickness = 3
    SettingsScroll.CanvasSize = UDim2.new(0, 0, 0, 820)
    SettingsScroll.Parent = Tabs.Settings

    local HideKeyLbl = Instance.new("TextLabel")
    HideKeyLbl.Size = UDim2.new(1, -20, 0, 22)
    HideKeyLbl.Position = UDim2.new(0, 10, 0, 10)
    HideKeyLbl.BackgroundTransparency = 1
    HideKeyLbl.Text = "Hide/Show UI: " .. tostring(config.Keys.HideUI):gsub("Enum.KeyCode.", "")
    HideKeyLbl.TextColor3 = LYRA.text
    HideKeyLbl.Font = Enum.Font.GothamBold
    HideKeyLbl.TextSize = 12
    HideKeyLbl.TextXAlignment = Enum.TextXAlignment.Left
    HideKeyLbl.Parent = SettingsScroll

    local UnloadBtn = makeActionButton(SettingsScroll, "Unload Script", 40, LYRA.danger)
    local AutoClaimDailyRewardBtn = makeActionButton(SettingsScroll, "Auto Claim Daily Reward: OFF", 80, LYRA.accent)
    local AutoClaimSessionRewardBtn = makeActionButton(SettingsScroll, "Auto Claim Session Reward: OFF", 120, LYRA.tp)
    local AntiIdleBtn = makeActionButton(SettingsScroll, "Anti Idle: OFF", 160, LYRA.warn)

    -- ── Auto Sell Rarity Selection ──
    local SellRarityTitle = Instance.new("TextLabel")
    SellRarityTitle.Size = UDim2.new(1, -20, 0, 18)
    SellRarityTitle.Position = UDim2.new(0, 10, 0, 202)
    SellRarityTitle.BackgroundTransparency = 1
    SellRarityTitle.Text = "Auto Sell Rarities (tap to toggle)"
    SellRarityTitle.TextColor3 = LYRA.text
    SellRarityTitle.Font = Enum.Font.GothamBold
    SellRarityTitle.TextSize = 11
    SellRarityTitle.TextXAlignment = Enum.TextXAlignment.Left
    SellRarityTitle.Parent = SettingsScroll

    local allRarities = {"Common", "Uncommon", "Rare", "Epic", "Legend", "Mythic", "Ancient"}
    local SellRarityButtons = {}
    for i, rarity in ipairs(allRarities) do
        local btn = Instance.new("TextButton")
        btn.Text = rarity
        btn.Size = UDim2.new(0, 62, 0, 22)
        btn.Position = UDim2.new(0, 10 + ((i - 1) % 4) * 68, 0, 224 + math.floor((i - 1) / 4) * 28)
        btn.BackgroundColor3 = LYRA.success
        btn.BackgroundTransparency = 0.2
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9
        btn.BorderSizePixel = 0
        btn.Parent = SettingsScroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        SellRarityButtons[rarity] = btn
    end

    -- ── Webhook Section ──
    local WebhookSep = Instance.new("Frame")
    WebhookSep.Size = UDim2.new(1, -20, 0, 1)
    WebhookSep.Position = UDim2.new(0, 10, 0, 290)
    WebhookSep.BackgroundColor3 = LYRA.panel2
    WebhookSep.BorderSizePixel = 0
    WebhookSep.Parent = SettingsScroll

    local WebhookTitle = Instance.new("TextLabel")
    WebhookTitle.Size = UDim2.new(1, -20, 0, 18)
    WebhookTitle.Position = UDim2.new(0, 10, 0, 298)
    WebhookTitle.BackgroundTransparency = 1
    WebhookTitle.Text = "Webhook Settings"
    WebhookTitle.TextColor3 = LYRA.text
    WebhookTitle.Font = Enum.Font.GothamBold
    WebhookTitle.TextSize = 11
    WebhookTitle.TextXAlignment = Enum.TextXAlignment.Left
    WebhookTitle.Parent = SettingsScroll

    local WebhookURLLabel = Instance.new("TextLabel")
    WebhookURLLabel.Size = UDim2.new(0, 80, 0, 22)
    WebhookURLLabel.Position = UDim2.new(0, 10, 0, 320)
    WebhookURLLabel.BackgroundTransparency = 1
    WebhookURLLabel.Text = "URL:"
    WebhookURLLabel.TextColor3 = LYRA.dim
    WebhookURLLabel.Font = Enum.Font.Gotham
    WebhookURLLabel.TextSize = 10
    WebhookURLLabel.TextXAlignment = Enum.TextXAlignment.Left
    WebhookURLLabel.Parent = SettingsScroll

    local WebhookInput = Instance.new("TextBox")
    WebhookInput.Size = UDim2.new(1, -60, 0, 22)
    WebhookInput.Position = UDim2.new(0, 46, 0, 320)
    WebhookInput.BackgroundColor3 = LYRA.bg2
    WebhookInput.TextColor3 = LYRA.text
    WebhookInput.PlaceholderText = "https://discord.com/api/webhooks/..."
    WebhookInput.PlaceholderColor3 = LYRA.dim
    WebhookInput.Text = config.Webhook and config.Webhook.URL or ""
    WebhookInput.Font = Enum.Font.Code
    WebhookInput.TextSize = 9
    WebhookInput.TextXAlignment = Enum.TextXAlignment.Left
    WebhookInput.ClearTextOnFocus = false
    WebhookInput.BorderSizePixel = 0
    WebhookInput.ClipsDescendants = true
    WebhookInput.Parent = SettingsScroll
    Instance.new("UICorner", WebhookInput).CornerRadius = UDim.new(0, 4)
    local WebhookInputPad = Instance.new("UIPadding", WebhookInput)
    WebhookInputPad.PaddingLeft = UDim.new(0, 6)

    -- Webhook rarity filter
    local WebhookRarityTitle = Instance.new("TextLabel")
    WebhookRarityTitle.Size = UDim2.new(1, -20, 0, 18)
    WebhookRarityTitle.Position = UDim2.new(0, 10, 0, 350)
    WebhookRarityTitle.BackgroundTransparency = 1
    WebhookRarityTitle.Text = "Log Rarities (tap to toggle)"
    WebhookRarityTitle.TextColor3 = LYRA.dim
    WebhookRarityTitle.Font = Enum.Font.Gotham
    WebhookRarityTitle.TextSize = 10
    WebhookRarityTitle.TextXAlignment = Enum.TextXAlignment.Left
    WebhookRarityTitle.Parent = SettingsScroll

    local WebhookRarityButtons = {}
    for i, rarity in ipairs(allRarities) do
        local btn = Instance.new("TextButton")
        btn.Text = rarity
        btn.Size = UDim2.new(0, 62, 0, 22)
        btn.Position = UDim2.new(0, 10 + ((i - 1) % 4) * 68, 0, 370 + math.floor((i - 1) / 4) * 28)
        btn.BackgroundColor3 = LYRA.panel2
        btn.BackgroundTransparency = 0.4
        btn.TextColor3 = LYRA.dim
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9
        btn.BorderSizePixel = 0
        btn.Parent = SettingsScroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        WebhookRarityButtons[rarity] = btn
    end

    -- Buttons row: Toggle + Test + Save
    local WebhookToggleBtn = makeActionButton(SettingsScroll, "Webhook: OFF", 430, LYRA.panel2)
    WebhookToggleBtn.Size = UDim2.new(0.48, -10, 0, 28)
    WebhookToggleBtn.Position = UDim2.new(0, 10, 0, 430)

    local WebhookTestBtn = makeActionButton(SettingsScroll, "Test Webhook", 430, LYRA.warn)
    WebhookTestBtn.Size = UDim2.new(0.48, -10, 0, 28)
    WebhookTestBtn.Position = UDim2.new(0.5, 5, 0, 430)

    local SaveSettingsBtn = makeActionButton(SettingsScroll, "Save All Settings", 468, LYRA.success)

    local SaveStatus = Instance.new("TextLabel")
    SaveStatus.Size = UDim2.new(1, -20, 0, 18)
    SaveStatus.Position = UDim2.new(0, 10, 0, 506)
    SaveStatus.BackgroundTransparency = 1
    SaveStatus.Text = ""
    SaveStatus.TextColor3 = LYRA.success
    SaveStatus.Font = Enum.Font.Gotham
    SaveStatus.TextSize = 10
    SaveStatus.TextXAlignment = Enum.TextXAlignment.Left
    SaveStatus.Parent = SettingsScroll

    -- ── Accent Color section ──
    local ColorSep = Instance.new("Frame")
    ColorSep.Size = UDim2.new(1, -20, 0, 1)
    ColorSep.Position = UDim2.new(0, 10, 0, 530)
    ColorSep.BackgroundColor3 = LYRA.panel2
    ColorSep.BorderSizePixel = 0
    ColorSep.Parent = SettingsScroll

    local ColorTitle = Instance.new("TextLabel")
    ColorTitle.Size = UDim2.new(1, -20, 0, 20)
    ColorTitle.Position = UDim2.new(0, 10, 0, 538)
    ColorTitle.BackgroundTransparency = 1
    ColorTitle.Text = "Accent Color"
    ColorTitle.TextColor3 = LYRA.text
    ColorTitle.Font = Enum.Font.GothamBold
    ColorTitle.TextSize = 12
    ColorTitle.TextXAlignment = Enum.TextXAlignment.Left
    ColorTitle.Parent = SettingsScroll

    local AccentPreview = Instance.new("Frame")
    AccentPreview.Size = UDim2.new(0, 22, 0, 22)
    AccentPreview.Position = UDim2.new(1, -36, 0, 536)
    AccentPreview.BackgroundColor3 = LYRA.accent
    AccentPreview.BorderSizePixel = 0
    AccentPreview.Parent = SettingsScroll
    Instance.new("UICorner", AccentPreview).CornerRadius = UDim.new(0, 6)

    local ColorButtons = {}
    for i, color in ipairs(config.ThemePresets) do
        local sw = Instance.new("TextButton")
        sw.Text = ""
        sw.Size = UDim2.new(0, 28, 0, 28)
        sw.Position = UDim2.new(0, 10 + ((i - 1) % 5) * 36, 0, 566 + math.floor((i - 1) / 5) * 36)
        sw.BackgroundColor3 = color
        sw.BorderSizePixel = 0
        sw.Parent = SettingsScroll
        Instance.new("UICorner", sw).CornerRadius = UDim.new(0, 6)
        table.insert(ColorButtons, sw)
    end

    local SettingsInfo = Instance.new("TextLabel")
    SettingsInfo.Size = UDim2.new(1, -20, 0, 44)
    SettingsInfo.Position = UDim2.new(0, 10, 0, 640)
    SettingsInfo.BackgroundTransparency = 1
    SettingsInfo.Text = "Settings are saved locally and auto-loaded on next run."
    SettingsInfo.TextColor3 = LYRA.dim
    SettingsInfo.Font = Enum.Font.Gotham
    SettingsInfo.TextSize = 11
    SettingsInfo.TextWrapped = true
    SettingsInfo.TextXAlignment = Enum.TextXAlignment.Left
    SettingsInfo.TextYAlignment = Enum.TextYAlignment.Top
    SettingsInfo.Parent = SettingsScroll

    -- ═══════════════════════════════════════════
    -- LOGS TAB
    -- ═══════════════════════════════════════════
    local LogScroll = Instance.new("ScrollingFrame")
    LogScroll.Size = UDim2.new(1, -20, 1, -50)
    LogScroll.Position = UDim2.new(0, 10, 0, 10)
    LogScroll.BackgroundColor3 = LYRA.bg2
    LogScroll.BorderSizePixel = 0
    LogScroll.ScrollBarThickness = 3
    LogScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    LogScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    LogScroll.Parent = Tabs.Logs
    Instance.new("UICorner", LogScroll).CornerRadius = UDim.new(0, 8)
    Instance.new("UIListLayout", LogScroll).Padding = UDim.new(0, 2)

    local ClearLogsBtn = Instance.new("TextButton")
    ClearLogsBtn.Text = "Clear Logs"
    ClearLogsBtn.Size = UDim2.new(0, 100, 0, 26)
    ClearLogsBtn.Position = UDim2.new(1, -110, 1, -36)
    ClearLogsBtn.BackgroundColor3 = LYRA.danger
    ClearLogsBtn.TextColor3 = Color3.new(1, 1, 1)
    ClearLogsBtn.Font = Enum.Font.GothamBold
    ClearLogsBtn.TextSize = 11
    ClearLogsBtn.BorderSizePixel = 0
    ClearLogsBtn.Parent = Tabs.Logs
    Instance.new("UICorner", ClearLogsBtn).CornerRadius = UDim.new(0, 6)

    local LogCount = Instance.new("TextLabel")
    LogCount.Size = UDim2.new(0, 200, 0, 26)
    LogCount.Position = UDim2.new(0, 10, 1, -36)
    LogCount.BackgroundTransparency = 1
    LogCount.Text = "0 entries"
    LogCount.TextColor3 = LYRA.dim
    LogCount.Font = Enum.Font.Gotham
    LogCount.TextSize = 10
    LogCount.TextXAlignment = Enum.TextXAlignment.Left
    LogCount.Parent = Tabs.Logs

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
        MinimizedOrb = MinimizedOrb,
        Title = Title,
        Subtitle = Subtitle,
        MinBtn = MinBtn,
        CloseBtn = CloseBtn,
        TabButtons = TabButtons,
        Tabs = Tabs,
        About = {
            CopySaweriaBtn = CopySaweriaBtn,
        },
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
        AutoFish = {
            ToggleBtn = AutoFishToggleBtn,
            Status = AutoFishStatus,
            Casts = AutoFishCasts,
            LastCatch = AutoFishLastCatch,
            Timings = AFTimings,
            PerfStats = AFPerfStats,
            PerfFishHrVal = perfFishHrVal,
            PerfCaughtVal = perfCaughtVal,
            PerfSellsVal = perfSellsVal,
            PerfEarnVal = perfEarnVal,
            PerfRarity = AFPerfRarity,
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
        Gacha = {
            ToggleBtn = GachaToggleBtn,
            Status = GachaStatus,
            LastResult = GachaLastResult,
            StopButtons = GachaStopButtons,
            BoxButtons = GachaBoxButtons,
            SelectedBox = GachaSelectedBox,
        },
        Settings = {
            HideKeyLbl = HideKeyLbl,
            UnloadBtn = UnloadBtn,
            AutoClaimDailyRewardBtn = AutoClaimDailyRewardBtn,
            AutoClaimSessionRewardBtn = AutoClaimSessionRewardBtn,
            AntiIdleBtn = AntiIdleBtn,
            SellRarityButtons = SellRarityButtons,
            WebhookInput = WebhookInput,
            WebhookToggleBtn = WebhookToggleBtn,
            WebhookTestBtn = WebhookTestBtn,
            WebhookRarityButtons = WebhookRarityButtons,
            SaveSettingsBtn = SaveSettingsBtn,
            SaveStatus = SaveStatus,
            ColorTitle = ColorTitle,
            AccentPreview = AccentPreview,
            ColorButtons = ColorButtons,
            SettingsInfo = SettingsInfo,
        },
        Logs = {
            LogScroll = LogScroll,
            ClearLogsBtn = ClearLogsBtn,
            LogCount = LogCount,
        },
    }
end
