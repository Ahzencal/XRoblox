-- BuildABeehive/core.lua
-- Shared services, state, helper functions, and cleanup for honey automation modules

return function(gui, config)
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local StatsService = game:GetService("Stats")
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
        collectInterval = 2,
        sellInterval = 5,
        fps = 0,
        ping = 0,
        playerCount = #Players:GetPlayers(),
        totalHive = 0,
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

    local function getPlayerCount()
        return #Players:GetPlayers()
    end
    ctx.getPlayerCount = getPlayerCount

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

    local function readInterval(input, fallback)
        if not input then
            return fallback
        end

        local value = tonumber(input.Text)
        if not value then
            input.Text = tostring(fallback)
            return fallback
        end

        value = math.clamp(value, 1, 3600)
        input.Text = tostring(value)
        return value
    end
    ctx.readInterval = readInterval

    local function syncIntervals()
        ctx.collectInterval = readInterval(gui.CollectIntervalInput, 2)
        ctx.sellInterval = readInterval(gui.SellIntervalInput, 5)
    end
    ctx.syncIntervals = syncIntervals

    ctx.addCount = function()
    end

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

    local function updateStats()
        local hives = ctx.getMyHives()
        local hiveCount = hives and #hives:GetChildren() or 0
        local active = ctx.AutoCollect or ctx.AutoSell or ctx.AutoDepositAurora
        local theme = config.Theme or {}

        ctx.playerCount = getPlayerCount()
        ctx.totalHive = hiveCount

        if gui.StatusLbl then
            gui.StatusLbl.Text = "Status: " .. (active and "ON" or "OFF")
            gui.StatusLbl.TextColor3 = active
                and (theme.success or Color3.fromRGB(80, 220, 140))
                or (theme.danger or Color3.fromRGB(255, 80, 100))
        end

        if gui.Stats then
            gui.Stats.FPSVal.Text = tostring(ctx.fps)
            gui.Stats.PingVal.Text = tostring(ctx.ping) .. " ms"
            gui.Stats.PlayerCountVal.Text = tostring(ctx.playerCount)
            gui.Stats.TotalHiveVal.Text = tostring(ctx.totalHive)
        end

        if gui.MiniStats then
            gui.MiniStats.FPSVal.Text = tostring(ctx.fps)
            gui.MiniStats.PingVal.Text = tostring(ctx.ping)
            gui.MiniStats.PlayerCountVal.Text = tostring(ctx.playerCount)
            gui.MiniStats.TotalHiveVal.Text = tostring(ctx.totalHive)
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

        if gui.CollectIntervalInput and not gui.CollectIntervalInput:IsFocused() then
                gui.CollectIntervalInput.Text = tostring(ctx.collectInterval)
        end
        if gui.SellIntervalInput and not gui.SellIntervalInput:IsFocused() then
                gui.SellIntervalInput.Text = tostring(ctx.sellInterval)
        end
    end
    ctx.updateStats = updateStats

    ctx.updateStatus = updateStats

    local frameCount = 0
    local fpsAccum = 0
    local lastUpdate = tick()

    bind(RunService.Heartbeat, function(dt)
        if ctx.Destroyed then
            return
        end

        frameCount = frameCount + 1
        fpsAccum = fpsAccum + dt

        local now = tick()
        if now - lastUpdate < 0.5 then
            return
        end

        lastUpdate = now

        if fpsAccum > 0 then
            ctx.fps = math.floor(frameCount / fpsAccum + 0.5)
        end
        frameCount = 0
        fpsAccum = 0

        local ok, pingMs = pcall(function()
            return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        if ok then
            ctx.ping = math.floor(pingMs + 0.5)
        end

        updateStats()
    end)

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

    bind(gui.TopBar.InputBegan, function(input)
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

    if gui.TabButtons then
        bind(gui.TabButtons.Overview.MouseButton1Click, function()
            if gui.SetTab then
                gui.SetTab("Overview")
            end
        end)

        bind(gui.TabButtons.Actions.MouseButton1Click, function()
            if gui.SetTab then
                gui.SetTab("Actions")
            end
        end)
    end

    if gui.CollectIntervalInput then
        bind(gui.CollectIntervalInput.FocusLost, function()
            ctx.syncIntervals()
        end)
    end

    if gui.SellIntervalInput then
        bind(gui.SellIntervalInput.FocusLost, function()
            ctx.syncIntervals()
        end)
    end

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

    bind(gui.CloseBtn.MouseButton1Click, function()
        ctx.destroyAll()
    end)

    setMinimized(false)
    updateStats()

    return ctx
end