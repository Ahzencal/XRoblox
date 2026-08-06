-- BuildABeehive/core.lua
-- Shared services, state, helper functions, and cleanup for honey automation modules

return function(gui, config)
    local Players = game:GetService("Players")
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
        AutoCollect = false,
        AutoExtract = false,
        AutoSell = false,
        AutoDepositAurora = false,
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

    local function updateStatus()
        local active = ctx.AutoCollect or ctx.AutoExtract or ctx.AutoSell or ctx.AutoDepositAurora
        gui.StatusLbl.Text = "Status: " .. (active and "ON" or "OFF")
        gui.StatusLbl.TextColor3 = active
            and (config.Theme and config.Theme.success or Color3.fromRGB(80, 220, 140))
            or (config.Theme and config.Theme.danger or Color3.fromRGB(255, 80, 100))
    end
    ctx.updateStatus = updateStatus

    local function setButtonState(button, enabled, label)
        button.Text = label .. ": " .. (enabled and "ON" or "OFF")
        button.BackgroundColor3 = enabled
            and (config.Theme and config.Theme.success or Color3.fromRGB(60, 180, 60))
            or (config.Theme and config.Theme.danger or Color3.fromRGB(180, 60, 60))
    end
    ctx.setButtonState = setButtonState

    local function setActiveFromState(stateName, button, label)
        ctx[stateName] = not ctx[stateName]
        setButtonState(button, ctx[stateName], label)
        updateStatus()
    end
    ctx.setActiveFromState = setActiveFromState

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

    return ctx
end