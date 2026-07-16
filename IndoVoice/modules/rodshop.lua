-- modules/rodshop.lua
-- Rod Shop (Buy Rod)
return function(ctx)
    local gui = ctx.gui
    local THEME = ctx.THEME
    local bind = ctx.bind
    local log = ctx.log

    for rodName, btn in pairs(gui.RodShop.BuyButtons) do
        bind(btn.MouseButton1Click, function()
            btn.Text = "..."
            btn.BackgroundColor3 = THEME.warn
            local ok, success, errMsg = pcall(function()
                return game:GetService("ReplicatedStorage").GameRemoteFunctions.RodShopPurchaseFunction:InvokeServer(rodName)
            end)
            if ok and success == true then
                btn.Text = "OK!"
                btn.BackgroundColor3 = THEME.success
                gui.RodShop.Status.Text = "Bought: " .. rodName:gsub("Tool_", ""):gsub("Rod$", "")
                gui.RodShop.Status.TextColor3 = THEME.success
                log("RodShop: Purchased " .. rodName, THEME.success)
            else
                local reason = ""
                if not ok then
                    reason = tostring(success)
                elseif success == false then
                    reason = tostring(errMsg or "Not enough Ropiah")
                else
                    reason = "Unknown error"
                end
                btn.Text = "Fail"
                btn.BackgroundColor3 = THEME.danger
                gui.RodShop.Status.Text = reason
                gui.RodShop.Status.TextColor3 = THEME.danger
                log("RodShop: " .. rodName:gsub("Tool_", "") .. " → " .. reason, THEME.danger)
            end
            task.delay(3, function()
                if btn and btn.Parent then
                    btn.Text = "Buy"
                    btn.BackgroundColor3 = THEME.accent
                end
            end)
        end)
    end

    -- Rod search filter
    bind(gui.RodShop.SearchBox:GetPropertyChangedSignal("Text"), function()
        local query = string.lower(gui.RodShop.SearchBox.Text)
        for rodName, row in pairs(gui.RodShop.RodRows) do
            if query == "" then
                row.Visible = true
            else
                local display = string.lower(rodName:gsub("Tool_", ""):gsub("Rod$", ""))
                row.Visible = string.find(display, query, 1, true) ~= nil
            end
        end
    end)
end
