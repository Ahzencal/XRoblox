-- modules/auto_sell.lua
-- Auto Sell feature: sells honey on a timer

return function(ctx)
    ctx.setButtonState(ctx.gui.SellButton, ctx.AutoSell, "Sell")
    ctx.updateStatus()

    ctx.gui.SellButton.MouseButton1Click:Connect(function()
        ctx.AutoSell = not ctx.AutoSell
        ctx.setButtonState(ctx.gui.SellButton, ctx.AutoSell, "Sell")
        ctx.updateStatus()
    end)

    task.spawn(function()
        while task.wait(5) do
            if ctx.Destroyed or not ctx.AutoSell then
                continue
            end

            pcall(function()
                ctx.SellRemote:FireServer("SellHoney", "Honey")
                ctx.addCount("sell", 1)
            end)
            ctx.updateStats()
        end
    end)
end