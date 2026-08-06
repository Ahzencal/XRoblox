-- modules/auto_deposit_aurora.lua
-- Auto Deposit Aurora feature: repeatedly deposits aurora honey

return function(ctx)
    ctx.setButtonState(ctx.gui.DepositAuroraButton, ctx.AutoDepositAurora, "Aurora")
    ctx.updateStatus()

    ctx.syncIntervals()

    ctx.gui.DepositAuroraButton.MouseButton1Click:Connect(function()
        ctx.AutoDepositAurora = not ctx.AutoDepositAurora
        ctx.setButtonState(ctx.gui.DepositAuroraButton, ctx.AutoDepositAurora, "Aurora")
        ctx.updateStatus()

        if ctx.AutoDepositAurora then
            pcall(function()
                ctx.GameRemote:FireServer("DepositAuroraHoney")
        local lastRun = 0

        while task.wait(0.1) do
            end)
            ctx.updateStats()
        end

            ctx.syncIntervals()
            if os.clock() - lastRun < ctx.auroraInterval then
                continue
            end

            lastRun = os.clock()
    end)

    task.spawn(function()
        while task.wait(5) do
            if ctx.Destroyed or not ctx.AutoDepositAurora then
                continue
            end

            pcall(function()
                ctx.GameRemote:FireServer("DepositAuroraHoney")
                ctx.addCount("aurora", 1)
            end)
            ctx.updateStats()
        end
    end)
end