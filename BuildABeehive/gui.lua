-- BuildABeehive/gui.lua
-- Builds the honey automation UI and returns references used by the core/module layers

return function(config)
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    local theme = config.Theme or {}

    if _G.__BuildABeehive_Destroy then
        pcall(_G.__BuildABeehive_Destroy)
    end
    _G.__BuildABeehive_Destroy = nil

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoHoneyGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
    if not screenGui.Parent then
        screenGui.Parent = lp:WaitForChild("PlayerGui")
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 180, 0, 145)
    frame.Position = UDim2.new(0.4, 0, 0.3, 0)
    frame.BackgroundColor3 = theme.bg2 or Color3.fromRGB(35, 35, 35)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = theme.accent or Color3.fromRGB(80, 180, 255)
    stroke.Transparency = 0.35
    stroke.Thickness = 1

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0.25, 0)
    title.BackgroundTransparency = 1
    title.Text = "Auto Honey"
    title.TextColor3 = theme.text or Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.Parent = frame

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -10, 0, 16)
    status.Position = UDim2.new(0, 5, 0, 24)
    status.BackgroundTransparency = 1
    status.Text = "Status: OFF"
    status.TextColor3 = theme.danger or Color3.fromRGB(255, 80, 80)
    status.Font = Enum.Font.GothamBold
    status.TextSize = 11
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = frame

    local collectButton = Instance.new("TextButton")
    collectButton.Size = UDim2.new(0.9, 0, 0.13, 0)
    collectButton.Position = UDim2.new(0.05, 0, 0.34, 0)
    collectButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    collectButton.Text = "Collect: OFF"
    collectButton.TextScaled = true
    collectButton.BorderSizePixel = 0
    collectButton.Parent = frame
    Instance.new("UICorner", collectButton).CornerRadius = UDim.new(0, 6)

    local extractButton = Instance.new("TextButton")
    extractButton.Size = UDim2.new(0.9, 0, 0.13, 0)
    extractButton.Position = UDim2.new(0.05, 0, 0.49, 0)
    extractButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    extractButton.Text = "Extract: OFF"
    extractButton.TextScaled = true
    extractButton.BorderSizePixel = 0
    extractButton.Parent = frame
    Instance.new("UICorner", extractButton).CornerRadius = UDim.new(0, 6)

    local sellButton = Instance.new("TextButton")
    sellButton.Size = UDim2.new(0.9, 0, 0.13, 0)
    sellButton.Position = UDim2.new(0.05, 0, 0.64, 0)
    sellButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    sellButton.Text = "Sell: OFF"
    sellButton.TextScaled = true
    sellButton.BorderSizePixel = 0
    sellButton.Parent = frame
    Instance.new("UICorner", sellButton).CornerRadius = UDim.new(0, 6)

    local depositAuroraButton = Instance.new("TextButton")
    depositAuroraButton.Size = UDim2.new(0.9, 0, 0.13, 0)
    depositAuroraButton.Position = UDim2.new(0.05, 0, 0.79, 0)
    depositAuroraButton.BackgroundColor3 = theme.danger or Color3.fromRGB(180, 60, 60)
    depositAuroraButton.Text = "Aurora: OFF"
    depositAuroraButton.TextScaled = true
    depositAuroraButton.BorderSizePixel = 0
    depositAuroraButton.Parent = frame
    Instance.new("UICorner", depositAuroraButton).CornerRadius = UDim.new(0, 6)

    return {
        ScreenGui = screenGui,
        Frame = frame,
        Title = title,
        StatusLbl = status,
        CollectButton = collectButton,
        ExtractButton = extractButton,
        SellButton = sellButton,
        DepositAuroraButton = depositAuroraButton,
    }
end