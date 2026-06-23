-- Silent AutoClicker by Ahzul
-- Clicks fixed position without moving cursor
-- Execute separately in each Roblox instance

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ============================================================
--  CONFIG
-- ============================================================
local TOGGLE_KEY    = Enum.KeyCode.F
local DEFAULT_CPS   = 20
local POSITION_MODE = "pick"  -- "pick" | "center" | "custom"
local FIXED_X       = nil     -- only if POSITION_MODE = "custom"
local FIXED_Y       = nil
-- ============================================================

local clicking   = false
local destroyed  = false
local clickDelay = 1 / DEFAULT_CPS
local clickCPS   = DEFAULT_CPS
local savedX     = FIXED_X
local savedY     = FIXED_Y

local lp    = Players.LocalPlayer
local mouse = lp:GetMouse()
local cam   = workspace.CurrentCamera

-- ============================================================
--  RESOLVE POSITION
-- ============================================================
local function resolvePosition()
    if POSITION_MODE == "center" then
        local vp = cam.ViewportSize
        return vp.X / 2, vp.Y / 2
    elseif POSITION_MODE == "custom" then
        return FIXED_X or 960, FIXED_Y or 540
    else
        return savedX, savedY
    end
end

-- ============================================================
--  SILENT CLICK (no cursor movement)
-- ============================================================
local VIM = pcall(function()
    return cloneref(game:GetService("VirtualInputManager"))
end) and cloneref(game:GetService("VirtualInputManager"))
    or game:GetService("VirtualInputManager")

local useVIM = pcall(function()
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end)

local function silentClick(x, y)
    if useVIM then
        VIM:SendMouseButtonEvent(x, y, 0, true,  game, 1)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
    else
        local cx, cy = mouse.X, mouse.Y
        mousemoveabs(x, y)
        mouse1press()
        mouse1release()
        mousemoveabs(cx, cy)
    end
end

-- ============================================================
--  GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SilentAutoClicker"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999

local ok = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not ok then ScreenGui.Parent = lp:WaitForChild("PlayerGui") end

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 255, 0, 250)
Frame.Position = UDim2.new(0, 16, 0.5, -125)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 36)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 140, 100)
TopBar.BorderSizePixel = 0
TopBar.Parent = Frame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

-- Fix bottom corners of top bar
local TopMask = Instance.new("Frame")
TopMask.Size = UDim2.new(1, 0, 0, 10)
TopMask.Position = UDim2.new(0, 0, 1, -10)
TopMask.BackgroundColor3 = Color3.fromRGB(30, 140, 100)
TopMask.BorderSizePixel = 0
TopMask.Parent = TopBar

-- Title
local TitleLbl = Instance.new("TextLabel")
TitleLbl.Text = "🖱️ Silent AutoClicker"
TitleLbl.Size = UDim2.new(1, -46, 1, 0)
TitleLbl.Position = UDim2.new(0, 10, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 14
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.Parent = TopBar

-- Close Button (destroys everything)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "✕"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -32, 0, 4)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 80)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Status
local StatusLbl = Instance.new("TextLabel")
StatusLbl.Text = "Status: OFF"
StatusLbl.Size = UDim2.new(1, -20, 0, 26)
StatusLbl.Position = UDim2.new(0, 10, 0, 46)
StatusLbl.BackgroundTransparency = 1
StatusLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
StatusLbl.Font = Enum.Font.GothamBold
StatusLbl.TextSize = 14
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.Parent = Frame

-- Target Position
local PosLbl = Instance.new("TextLabel")
PosLbl.Text = "Target: Not set  (Press P to pick)"
PosLbl.Size = UDim2.new(1, -20, 0, 22)
PosLbl.Position = UDim2.new(0, 10, 0, 74)
PosLbl.BackgroundTransparency = 1
PosLbl.TextColor3 = Color3.fromRGB(100, 180, 255)
PosLbl.Font = Enum.Font.Gotham
PosLbl.TextSize = 12
PosLbl.TextXAlignment = Enum.TextXAlignment.Left
PosLbl.Parent = Frame

-- Click Mode
local MethodLbl = Instance.new("TextLabel")
MethodLbl.Text = useVIM and "Mode: ✓ Silent (cursor won't move)"
              or "Mode: ⚠ Fallback (quick restore)"
MethodLbl.Size = UDim2.new(1, -20, 0, 20)
MethodLbl.Position = UDim2.new(0, 10, 0, 97)
MethodLbl.BackgroundTransparency = 1
MethodLbl.TextColor3 = useVIM
    and Color3.fromRGB(80, 220, 100)
    or  Color3.fromRGB(255, 180, 50)
MethodLbl.Font = Enum.Font.Gotham
MethodLbl.TextSize = 12
MethodLbl.TextXAlignment = Enum.TextXAlignment.Left
MethodLbl.Parent = Frame

-- CPS Display
local CPSLbl = Instance.new("TextLabel")
CPSLbl.Text = "CPS: " .. clickCPS
CPSLbl.Size = UDim2.new(1, -20, 0, 20)
CPSLbl.Position = UDim2.new(0, 10, 0, 118)
CPSLbl.BackgroundTransparency = 1
CPSLbl.TextColor3 = Color3.fromRGB(180, 180, 200)
CPSLbl.Font = Enum.Font.Gotham
CPSLbl.TextSize = 13
CPSLbl.TextXAlignment = Enum.TextXAlignment.Left
CPSLbl.Parent = Frame

-- Slider Label
local SliderLbl = Instance.new("TextLabel")
SliderLbl.Text = "Speed (CPS: 1–100)"
SliderLbl.Size = UDim2.new(1, -20, 0, 18)
SliderLbl.Position = UDim2.new(0, 10, 0, 139)
SliderLbl.BackgroundTransparency = 1
SliderLbl.TextColor3 = Color3.fromRGB(120, 120, 145)
SliderLbl.Font = Enum.Font.Gotham
SliderLbl.TextSize = 12
SliderLbl.TextXAlignment = Enum.TextXAlignment.Left
SliderLbl.Parent = Frame

-- Slider Track
local Track = Instance.new("Frame")
Track.Size = UDim2.new(1, -20, 0, 8)
Track.Position = UDim2.new(0, 10, 0, 161)
Track.BackgroundColor3 = Color3.fromRGB(40, 40, 58)
Track.BorderSizePixel = 0
Track.Parent = Frame
Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

local Fill = Instance.new("Frame")
Fill.Size = UDim2.new(DEFAULT_CPS / 100, 0, 1, 0)
Fill.BackgroundColor3 = Color3.fromRGB(30, 140, 100)
Fill.BorderSizePixel = 0
Fill.Parent = Track
Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

local Knob = Instance.new("Frame")
Knob.Size = UDim2.new(0, 16, 0, 16)
Knob.Position = UDim2.new(DEFAULT_CPS / 100, -8, 0.5, -8)
Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Knob.BorderSizePixel = 0
Knob.ZIndex = 3
Knob.Parent = Track
Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Text = "▶  Start  [F]"
ToggleBtn.Size = UDim2.new(1, -20, 0, 36)
ToggleBtn.Position = UDim2.new(0, 10, 0, 185)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 90)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.BorderSizePixel = 0
ToggleBtn.Parent = Frame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

-- Footer
local FooterLbl = Instance.new("TextLabel")
FooterLbl.Text = "[F] Toggle  •  [P] Pick spot  •  Cursor won't move"
FooterLbl.Size = UDim2.new(1, -20, 0, 18)
FooterLbl.Position = UDim2.new(0, 10, 0, 228)
FooterLbl.BackgroundTransparency = 1
FooterLbl.TextColor3 = Color3.fromRGB(70, 70, 90)
FooterLbl.Font = Enum.Font.Gotham
FooterLbl.TextSize = 10
FooterLbl.TextXAlignment = Enum.TextXAlignment.Center
FooterLbl.Parent = Frame

-- ============================================================
--  UI UPDATE
-- ============================================================
local function updateUI()
    if clicking then
        StatusLbl.Text = "Status: ON ✓"
        StatusLbl.TextColor3 = Color3.fromRGB(80, 220, 100)
        ToggleBtn.Text = "⏹  Stop  [F]"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 80)
    else
        StatusLbl.Text = "Status: OFF"
        StatusLbl.TextColor3 = Color3.fromRGB(255, 80, 80)
        ToggleBtn.Text = "▶  Start  [F]"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 160, 90)
    end

    local x, y = resolvePosition()
    if x and y then
        PosLbl.Text = string.format("Target: (%d, %d)  ✓", math.floor(x), math.floor(y))
        PosLbl.TextColor3 = Color3.fromRGB(80, 220, 100)
    else
        PosLbl.Text = "Target: Not set  (Press P to pick)"
        PosLbl.TextColor3 = Color3.fromRGB(100, 180, 255)
    end
end

-- ============================================================
--  TOGGLE
-- ============================================================
local function toggleClicker()
    local x, y = resolvePosition()
    if not x or not y then
        PosLbl.Text = "⚠ Hover over target and press P first!"
        PosLbl.TextColor3 = Color3.fromRGB(255, 200, 50)
        return
    end
    clicking = not clicking
    updateUI()
end

-- ============================================================
--  SLIDER DRAG
-- ============================================================
local dragging = false

Knob.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local ratio = math.clamp(
            (i.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1
        )
        clickCPS   = math.max(1, math.floor(ratio * 100))
        clickDelay = 1 / clickCPS
        Fill.Size  = UDim2.new(ratio, 0, 1, 0)
        Knob.Position = UDim2.new(ratio, -8, 0.5, -8)
        CPSLbl.Text = "CPS: " .. clickCPS
    end
end)

-- ============================================================
--  BUTTON EVENTS
-- ============================================================
ToggleBtn.MouseButton1Click:Connect(toggleClicker)

-- Close: fully destroys script + GUI
CloseBtn.MouseButton1Click:Connect(function()
    clicking  = false
    destroyed = true
    ScreenGui:Destroy()
end)

-- ============================================================
--  HOTKEYS
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp or destroyed then return end

    -- F = toggle clicker
    if input.KeyCode == TOGGLE_KEY then
        toggleClicker()
    end

    -- P = save current mouse position as click target
    if input.KeyCode == Enum.KeyCode.P then
        savedX = mouse.X
        savedY = mouse.Y
        updateUI()
    end
end)

-- ============================================================
--  CLICK LOOP
-- ============================================================
local lastClick = 0

RunService.Heartbeat:Connect(function()
    if destroyed then return end
    if not clicking then return end

    local now = tick()
    if now - lastClick < clickDelay then return end
    lastClick = now

    local x, y = resolvePosition()
    if x and y then
        silentClick(x, y)
    end
end)

-- ============================================================
--  INIT
-- ============================================================
if POSITION_MODE == "center" then
    local vp = cam.ViewportSize
    savedX, savedY = vp.X / 2, vp.Y / 2
end

updateUI()
