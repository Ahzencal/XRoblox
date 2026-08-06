-- modules/auto_deposit_aurora.lua
-- Auto Deposit Aurora feature: repeatedly deposits aurora honey

return function(ctx)
    ctx.setButtonState(ctx.gui.DepositAuroraButton, ctx.AutoDepositAurora, "Aurora")
    ctx.updateStatus()

    local lastRun = os.clock()

    ctx.gui.DepositAuroraButton.MouseButton1Click:Connect(function()
        ctx.AutoDepositAurora = not ctx.AutoDepositAurora
        ctx.setButtonState(ctx.gui.DepositAuroraButton, ctx.AutoDepositAurora, "Aurora")
        ctx.updateStatus()
    end)

    local elapsed = 0

    ctx.bind(ctx.RunService.Heartbeat, function(dt)
        if ctx.Destroyed then
            return
        end

        if not ctx.AutoDepositAurora then
            elapsed = 0
            lastRun = os.clock()
            return
        end

        ctx.syncIntervals()

        elapsed = elapsed + dt
        if elapsed < (ctx.auroraInterval or 5) then
            return
        end

        elapsed = 0
        lastRun = os.clock()

        pcall(function()
            ctx.GameRemote:FireServer("DepositAuroraHoney")
            ctx.addCount("aurora", 1)
        end)
        ctx.updateStats()
    end)
end