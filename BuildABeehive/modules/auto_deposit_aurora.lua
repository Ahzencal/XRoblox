-- modules/auto_deposit_aurora.lua
-- Auto Deposit Aurora feature: repeatedly deposits aurora honey

return function(ctx)
    ctx.setButtonState(ctx.gui.DepositAuroraButton, ctx.AutoDepositAurora, "Aurora")
    ctx.updateStatus()

    ctx.gui.DepositAuroraButton.MouseButton1Click:Connect(function()
        ctx.AutoDepositAurora = not ctx.AutoDepositAurora
        ctx.setButtonState(ctx.gui.DepositAuroraButton, ctx.AutoDepositAurora, "Aurora")
        ctx.updateStatus()

        if ctx.AutoDepositAurora then
            pcall(function()
                ctx.GameRemote:FireServer("DepositAuroraHoney")
            end)
        end
    end)

    task.spawn(function()
        while task.wait(5) do
            if ctx.Destroyed or not ctx.AutoDepositAurora then
                continue
            end

            pcall(function()
                ctx.GameRemote:FireServer("DepositAuroraHoney")
            end)
        end
    end)
end