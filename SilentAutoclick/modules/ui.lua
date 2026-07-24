-- modules/ui.lua
-- Window drag, minimize/restore, close, and global hotkeys
return function(ctx)
    local gui = ctx.gui
    local UserInputService = ctx.UserInputService
    local bind = ctx.bind
    local beginDrag = ctx.beginDrag
    local mouse = ctx.mouse
    local updateClickerUI = ctx.updateClickerUI
    local toggleClicker = ctx.toggleClicker
    local destroyAll = ctx.destroyAll

    -- ═══════════════════════════════════════════
    -- DRAG (top bar + hit area)
    -- ═══════════════════════════════════════════
    bind(gui.DragHit.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag(input)
        end
    end)

    bind(UserInputService.InputChanged, function(input)
        if ctx.draggingUI and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - ctx.dragStart
            gui.Main.Position = UDim2.new(ctx.startPos.X.Scale, ctx.startPos.X.Offset + delta.X, ctx.startPos.Y.Scale, ctx.startPos.Y.Offset + delta.Y)
        end
    end)

    bind(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            ctx.draggingUI = false
        end
    end)

    -- ═══════════════════════════════════════════
    -- MINIMIZE / RESTORE / CLOSE
    -- ═══════════════════════════════════════════
    bind(gui.MinBtn.MouseButton1Click, function()
        ctx.minimized = true
        gui.Main.Visible = false
        gui.MinimizedOrb.Visible = true
    end)

    bind(gui.MinimizedOrb.MouseButton1Click, function()
        ctx.minimized = false
        gui.Main.Visible = true
        gui.MinimizedOrb.Visible = false
    end)

    bind(gui.CloseBtn.MouseButton1Click, destroyAll)

    -- ═══════════════════════════════════════════
    -- GLOBAL HOTKEYS
    -- ═══════════════════════════════════════════
    bind(UserInputService.InputBegan, function(input, gp)
        if gp or ctx.destroyed then return end
        if input.KeyCode == ctx.toggleKey then
            toggleClicker()
        elseif input.KeyCode == ctx.pickKey then
            ctx.fixedX = mouse.X
            ctx.fixedY = mouse.Y
            updateClickerUI()
        elseif input.KeyCode == ctx.hideKey then
            ctx.hideUI = not ctx.hideUI
            if ctx.hideUI then
                gui.Main.Visible = false
                gui.MinimizedOrb.Visible = false
            else
                if ctx.minimized then
                    gui.MinimizedOrb.Visible = true
                else
                    gui.Main.Visible = true
                end
            end
        end
    end)
end
