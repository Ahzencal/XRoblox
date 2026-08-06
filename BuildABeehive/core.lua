-- BuildABeehive/core.lua
-- Shared services, state, helper functions, and cleanup for honey automation modules

return function(gui, config)
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local localPlayer = Players.LocalPlayer
    local ctx = {
        gui = gui,
        config = config,
        Players = Players,
        ReplicatedStorage = ReplicatedStorage,
        LocalPlayer = localPlayer,
        PlayerGui = localPlayer:WaitForChild("PlayerGui"),
        Destroyed = false,
        minimized = false,
        AutoCollect = false,
        AutoExtract = false,
        AutoSell = false,
        AutoDepositAurora = false,
        collectCount = 0,
        sellCount = 0,
        auroraCount = 0,
        connections = {},
    }

    ctx.ExtractRemote = ReplicatedStorage.Framework.Features.HoneySystem.HiveUtil.RemoteEvent
    ctx.SellRemote = ReplicatedStorage.Framework.Features.HoneySystem.HoneyUtil.RemoteEvent
    ctx.GameRemote = ReplicatedStorage.Framework.Features.GameEvent.GameEventUtil.RemoteEvent

    local function bind(signal, fn)
        local connection = signal:Connect(fn)
        table.insert(ctx.connections, connection)
        return connection
    end
    ctx.bind = bind

    local function setButtonState(button, enabled, label)
        if not button then
            return
        end

        button.Text = label .. ": " .. (enabled and "ON" or "OFF")
        button.BackgroundColor3 = enabled
            and (config.Theme and config.Theme.success or Color3.fromRGB(60, 180, 60))
            or (config.Theme and config.Theme.danger or Color3.fromRGB(180, 60, 60))
    end
    ctx.setButtonState = setButtonState

    local function setMinimized(minimized)
        ctx.minimized = minimized
        if gui.Main then
            gui.Main.Visible = not minimized
        end
        if gui.MinimizedPanel then
            gui.MinimizedPanel.Visible = minimized
        end
    end
    ctx.setMinimized = setMinimized

    local function addCount(kind, amount)
        amount = amount or 1
        if kind == "collect" then
            ctx.collectCount = ctx.collectCount + amount
        elseif kind == "sell" then
            ctx.sellCount = ctx.sellCount + amount
        elseif kind == "aurora" then
            ctx.auroraCount = ctx.auroraCount + amount
        end
    end
    ctx.addCount = addCount

    local function updateStats()
        local hives = ctx.getMyHives()
        local hiveCount = hives and #hives:GetChildren() or 0
        local active = ctx.AutoCollect or ctx.AutoSell or ctx.AutoDepositAurora
        local theme = config.Theme or {}

        if gui.StatusLbl then
            gui.StatusLbl.Text = "Status: " .. (active and "ON" or "OFF")
            gui.StatusLbl.TextColor3 = active
                and (theme.success or Color3.fromRGB(80, 220, 140))
                or (theme.danger or Color3.fromRGB(255, 80, 100))
        end

        if gui.Stats then
            gui.Stats.CollectVal.Text = tostring(ctx.collectCount)
            gui.Stats.SellVal.Text = tostring(ctx.sellCount)
            gui.Stats.AuroraVal.Text = tostring(ctx.auroraCount)
            gui.Stats.HivesVal.Text = tostring(hiveCount)
        end

        if gui.MiniStats then
            gui.MiniStats.CollectVal.Text = tostring(ctx.collectCount)
            gui.MiniStats.SellVal.Text = tostring(ctx.sellCount)
            gui.MiniStats.AuroraVal.Text = tostring(ctx.auroraCount)
            gui.MiniStats.HivesVal.Text = tostring(hiveCount)
        end

        if gui.CollectButton then
            setButtonState(gui.CollectButton, ctx.AutoCollect, "Collect")
        end
        if gui.SellButton then
            setButtonState(gui.SellButton, ctx.AutoSell, "Sell")
        end
        if gui.DepositAuroraButton then
            setButtonState(gui.DepositAuroraButton, ctx.AutoDepositAurora, "Aurora")
        end
        if gui.SoonLbl then
            gui.SoonLbl.Text = "Auto-buy coming soon"
            gui.SoonLbl.TextColor3 = theme.dim or Color3.fromRGB(130, 130, 145)
        end
    end
    ctx.updateStats = updateStats

    ctx.updateStatus = updateStats

    local function getMyPlot()
        local plots = workspace:FindFirstChild("Plots")
        if not plots then
            return nil
        end

        for _, plot in ipairs(plots:GetChildren()) do
            local owner = plot:FindFirstChild("Owner")
            if owner and owner.Value == localPlayer then
                return plot
            end
        end

        return nil
    end
    ctx.getMyPlot = getMyPlot

    local function getMyHives()
        local plot = getMyPlot()
        if plot then
            return plot:FindFirstChild("Hives")
        end
        return nil
    end
    ctx.getMyHives = getMyHives

    local function beginDrag(target, input)
        ctx.draggingUI = true
        ctx.dragTarget = target
        ctx.dragStart = input.Position
        ctx.startPos = target.Position
        ctx.dragInput = input
    end
    ctx.beginDrag = beginDrag

    local function endDrag(input)
        if ctx.dragInput == input then
            ctx.draggingUI = false
            ctx.dragTarget = nil
            ctx.dragInput = nil
        end
    end
    ctx.endDrag = endDrag

    bind(gui.DragHit.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag(gui.Frame, input)
        end
    end)

    bind(gui.MiniDragHit.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag(gui.MinimizedPanel, input)
        end
    end)

    bind(UserInputService.InputChanged, function(input)
        if not ctx.draggingUI or input ~= ctx.dragInput then
            return
        end

        local delta = input.Position - ctx.dragStart
        local position = ctx.startPos
        ctx.dragTarget.Position = UDim2.new(
            position.X.Scale,
            position.X.Offset + delta.X,
            position.Y.Scale,
            position.Y.Offset + delta.Y
        )
    end)

    bind(UserInputService.InputEnded, function(input)
        endDrag(input)
    end)

    bind(gui.MinBtn.MouseButton1Click, function()
        setMinimized(true)
    end)

    bind(gui.MiniExpand.MouseButton1Click, function()
        setMinimized(false)
    end)

    bind(gui.CloseBtn.MouseButton1Click, function()
        destroyAll()
    end)

    local function destroyAll()
        ctx.Destroyed = true
        for _, connection in ipairs(ctx.connections) do
            pcall(function()
                connection:Disconnect()
            end)
        end
        table.clear(ctx.connections)
        pcall(function()
            gui.ScreenGui:Destroy()
        end)
    end
    ctx.destroyAll = destroyAll
    _G.__BuildABeehive_Destroy = destroyAll

    setMinimized(false)
    updateStats()

    return ctx
end