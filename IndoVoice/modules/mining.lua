-- modules/mining.lua
-- Auto Mining System + Auto Sell Ore
return function(ctx)
    local gui = ctx.gui
    local THEME = ctx.THEME
    local lp = ctx.lp
    local bind = ctx.bind
    local log = ctx.log
    local getHRP = ctx.getHRP
    local getHum = ctx.getHum
    local VIM = ctx.VIM
    local ReplicatedStorage = ctx.ReplicatedStorage

    -- Exposed on ctx (with defaults) so Settings save/load can persist these toggles
    ctx.autoMineHotspotOnly = ctx.autoMineHotspotOnly or false
    ctx.autoMineTPEnabled = ctx.autoMineTPEnabled or false
    local autoMineCounts = {}
    local autoMineStage = "Idle"
    local mineSessionStart = 0
    local MINE_BREAK_INTERVAL = 3600 -- 60 min
    local MINE_BREAK_DURATION = 300 -- 5 min pause

    local MINING_STONES_PATH = workspace:FindFirstChild("Main") and workspace.Main:FindFirstChild("ActiveMiningStones")
    local AM_MINIGAME_TIMEOUT = 30
    local AM_POST_MINE_DELAY = 1.5

    local function amSetStage(stage)
        autoMineStage = stage
        gui.Mining.Status.Text = "Status: " .. stage
    end

    local function getPickaxe()
        local char = lp.Character
        if not char then return nil end
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and (tool:FindFirstChild("Mine") or tool:FindFirstChild("MineResultEvent") or string.find(string.lower(tool.Name), "pickaxe") or string.find(string.lower(tool.Name), "pick")) then
                return tool
            end
        end
        return nil
    end

    local function getPickaxeFromBackpack()
        local backpack = lp:FindFirstChildOfClass("Backpack")
        if not backpack then return nil end
        local bestPick = nil
        local bestLevel = -1
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool:FindFirstChild("Mine") or tool:FindFirstChild("MineResultEvent") or string.find(string.lower(tool.Name), "pickaxe") or string.find(string.lower(tool.Name), "pick")) then
                local level = tool:GetAttribute("Level") or tool:GetAttribute("Tier") or 0
                if level > bestLevel then
                    bestLevel = level
                    bestPick = tool
                elseif bestPick == nil then
                    bestPick = tool
                end
            end
        end
        return bestPick
    end

    local function equipPickaxe()
        local char = lp.Character
        if not char then return false end
        if getPickaxe() then return true end
        local pick = getPickaxeFromBackpack()
        if pick then
            pick.Parent = char
            log("AutoMine: Equipped " .. pick.Name, THEME.dim)
            task.wait(0.3)
            return true
        end
        return false
    end

    local function getMiningStones()
        if not MINING_STONES_PATH then
            MINING_STONES_PATH = workspace:FindFirstChild("Main") and workspace.Main:FindFirstChild("ActiveMiningStones")
        end
        if not MINING_STONES_PATH then return {} end
        local stones = {}
        for _, stone in ipairs(MINING_STONES_PATH:GetChildren()) do
            if stone:IsA("Model") then
                table.insert(stones, stone)
            end
        end
        return stones
    end

    local function isStoneAvailable(stone)
        local available = stone:GetAttribute("AvailableSlot")
        if available and available <= 0 then return false end
        local consumed = stone:GetAttribute("ConsumedSlot")
        local maxSlot = stone:GetAttribute("MaxSlot")
        if consumed and maxSlot and consumed >= maxSlot then return false end
        return true
    end

    -- Counts other players within `radius` studs of a stone's position.
    -- Used to avoid contested stones where slots < nearby players, which
    -- causes repeated failed-click retries (a likely trigger for the
    -- server's "Mining is temporarily disabled" rate limit).
    local NEARBY_PLAYER_RADIUS = 20
    local function countNearbyPlayers(stonePos)
        local count = 0
        for _, player in ipairs(ctx.Players:GetPlayers()) do
            if player ~= lp then
                local hrp = getHRP(player.Character)
                if hrp and (hrp.Position - stonePos).Magnitude <= NEARBY_PLAYER_RADIUS then
                    count = count + 1
                end
            end
        end
        return count
    end

    -- Recently-failed stones are temporarily skipped so the loop doesn't
    -- hammer the same contested stone repeatedly.
    local avoidedStones = {}
    local AVOID_DURATION = 45

    local function markStoneAvoided(stone)
        avoidedStones[stone] = tick() + AVOID_DURATION
    end

    local function isStoneAvoided(stone)
        local until_ = avoidedStones[stone]
        if not until_ then return false end
        if tick() >= until_ then
            avoidedStones[stone] = nil
            return false
        end
        return true
    end

    local function getNearestStone()
        local hrp = getHRP(lp.Character)
        if not hrp then return nil, math.huge end
        local best, bestDist = nil, math.huge
        for _, stone in ipairs(getMiningStones()) do
            if ctx.autoMineHotspotOnly and not stone:GetAttribute("IsHotspot") then
                continue
            end
            if not isStoneAvailable(stone) then
                continue
            end
            if isStoneAvoided(stone) then
                continue
            end

            -- Skip contested stones: fewer available slots than players nearby
            local pos = stone:GetPivot().Position
            local available = stone:GetAttribute("AvailableSlot")
            if available then
                local nearbyPlayers = countNearbyPlayers(pos)
                if nearbyPlayers > available then
                    continue
                end
            end

            local d = (hrp.Position - pos).Magnitude
            if d < bestDist then
                bestDist = d
                best = stone
            end
        end
        return best, bestDist
    end

    local function tpToStone(stone)
        local hrp = getHRP(lp.Character)
        if not hrp or not stone then return end
        local pos = stone:GetPivot().Position
        local offset = 3 + math.random() * 2
        local angle = math.random() * math.pi * 2
        local beside = pos + Vector3.new(math.cos(angle) * offset, 3, math.sin(angle) * offset)
        hrp.CFrame = CFrame.new(beside, pos)
    end

    -- Standalone Auto TP loop: runs independently of Auto Mine so the player
    -- can be auto-positioned near stones while manually choosing which one to
    -- click. When this toggle is OFF, the player walks/selects stones freely.
    local stoneTPLoopRunning = false
    local function startStoneTPLoop()
        if stoneTPLoopRunning then return end
        stoneTPLoopRunning = true
        task.spawn(function()
            while ctx.autoMineTPEnabled and not ctx.destroyed do
                local stone, dist = getNearestStone()
                if stone and dist > 8 then
                    tpToStone(stone)
                end
                task.wait(1)
            end
            stoneTPLoopRunning = false
        end)
    end

    local function clickStone(stone)
        -- Fixed-position click at (0,0): reliable proximity-based mining
        -- interaction. A randomized offset was tried here but intermittently
        -- landed on the hub GUI panel itself (silently eating the click),
        -- which caused "No minigame in 5s, retrying" every couple of mines.
        pcall(function()
            VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.05)
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
        return true
    end

    -- ── HOTSPOT ESP ──
    local function removeMineESP(stone)
        local obj = ctx.mineESPObjects[stone]
        if not obj then return end
        if obj.highlight then obj.highlight:Destroy() end
        if obj.billboard then obj.billboard:Destroy() end
        ctx.mineESPObjects[stone] = nil
    end
    ctx.removeMineESP = removeMineESP

    local function addMineESP(stone)
        if ctx.mineESPObjects[stone] then return end
        if not stone:GetAttribute("IsHotspot") then return end

        local highlight = Instance.new("Highlight")
        highlight.Adornee = stone
        highlight.FillColor = THEME.warn
        highlight.FillTransparency = 0.7
        highlight.OutlineColor = THEME.warn
        highlight.OutlineTransparency = 0.3
        highlight.Parent = stone

        local bb = Instance.new("BillboardGui")
        bb.Adornee = stone
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0, 140, 0, 28)
        bb.StudsOffset = Vector3.new(0, 6, 0)
        bb.Parent = stone

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "⛏️ Hotspot"
        lbl.TextColor3 = THEME.warn
        lbl.TextStrokeTransparency = 0
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.Parent = bb

        ctx.mineESPObjects[stone] = { highlight = highlight, billboard = bb }
    end

    local function refreshMineESP()
        for stone in pairs(ctx.mineESPObjects) do
            removeMineESP(stone)
        end
        if not ctx.mineESPOn then return end
        for _, stone in ipairs(getMiningStones()) do
            if stone:GetAttribute("IsHotspot") and isStoneAvailable(stone) then
                addMineESP(stone)
            end
        end
    end

    local function updateMineStats()
        local total = 0
        for _, count in pairs(autoMineCounts) do
            total = total + count
        end
        local statsText = "Total Mined: " .. total
        local parts = {}
        for rarity, count in pairs(autoMineCounts) do
            table.insert(parts, rarity .. ": " .. count)
        end
        if #parts > 0 then
            statsText = statsText .. "\n" .. table.concat(parts, " | ")
        end
        pcall(function()
            gui.Mining.OreStats.Text = statsText
        end)
    end

    local function autoMineLoop()
        log("AutoMine: Engine started", THEME.success)
        gui.Mining.Status.TextColor3 = THEME.success
        mineSessionStart = tick()

        while ctx.autoMineEnabled and not ctx.destroyed do
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if not char or not hum then
                amSetStage("No character")
                task.wait(1)
                continue
            end

            if not getPickaxe() then
                amSetStage("Equipping pickaxe...")
                if not equipPickaxe() then
                    amSetStage("No pickaxe found!")
                    gui.Mining.Status.TextColor3 = THEME.danger
                    log("AutoMine: No pickaxe in character or backpack", THEME.danger)
                    task.wait(2)
                    continue
                end
            end

            local stone, dist = getNearestStone()
            if not stone then
                amSetStage("No stones available")
                log("AutoMine: All stones full or filtered out", THEME.warn)
                task.wait(3)
                continue
            end

            if ctx.autoMineTPEnabled then
                -- The standalone TP loop (startStoneTPLoop) keeps the player
                -- positioned near stones; just wait briefly for it to settle.
                amSetStage("TP to stone...")
                task.wait(0.3)
            elseif dist > 15 then
                amSetStage("Too far from stone, enable Auto TP")
                task.wait(2)
                continue
            end

            -- CLICK THE STONE
            amSetStage("Clicking stone...")
            local clicked = clickStone(stone)
            if not clicked then
                log("AutoMine: Failed to click stone", THEME.warn)
                task.wait(1)
                continue
            end

            if not ctx.autoMineEnabled or ctx.destroyed then break end

            -- WAIT FOR STARTMINIGAME (ore info) — timeout 5s, reset if pickaxe unequipped
            amSetStage("Waiting for minigame...")
            local minigameStarted = false
            local mineData = nil
            local minigameConn = nil

            local pick = getPickaxe()
            if not pick then
                amSetStage("Pickaxe unequipped, resetting...")
                log("AutoMine: Pickaxe lost, re-equipping", THEME.warn)
                task.wait(0.5)
                continue
            end

            local startMinigame = pick:FindFirstChild("StartMinigame")
            if startMinigame and startMinigame:IsA("RemoteEvent") then
                minigameConn = startMinigame.OnClientEvent:Connect(function(rarity, info)
                    minigameStarted = true
                    if info and type(info) == "table" then
                        mineData = info
                        mineData.Rarity = rarity
                    end
                end)
            end

            local mgWaitStart = tick()
            while not minigameStarted and (tick() - mgWaitStart) < 5 and ctx.autoMineEnabled do
                -- Reset if pickaxe got unequipped during wait
                if not getPickaxe() then
                    break
                end
                task.wait(0.1)
            end

            if minigameConn then minigameConn:Disconnect() end

            if not ctx.autoMineEnabled or ctx.destroyed then break end

            -- Reset if pickaxe was lost
            if not getPickaxe() then
                amSetStage("Pickaxe unequipped, resetting...")
                log("AutoMine: Pickaxe lost during wait, re-equipping", THEME.warn)
                task.wait(0.5)
                continue
            end

            if not minigameStarted then
                amSetStage("No minigame response, avoiding stone...")
                log("AutoMine: No minigame in 5s, marking stone contested and switching", THEME.warn)
                markStoneAvoided(stone)
                task.wait(1)
                continue
            end

            -- SKIP MINIGAME (random 8-15s delay then fire MineResult)
            -- Widened from 5-10s to reduce mining rate and avoid server-side
            -- "Mining is temporarily disabled" rate-limit kicks.
            amSetStage("Minigame active, waiting to mine...")
            local skipDelay = 8 + math.random() * 7
            task.wait(skipDelay)

            if not ctx.autoMineEnabled or ctx.destroyed then break end

            -- LISTEN FOR MINERESULT DATA + FIRE MineResult (catch)
            amSetStage("Mining!")
            local oreResultData = nil
            local resultConn = nil
            local mineResultRemote = pick and (pick:FindFirstChild("MineResult"))

            if mineResultRemote and mineResultRemote:IsA("RemoteEvent") then
                resultConn = mineResultRemote.OnClientEvent:Connect(function(info)
                    if info and type(info) == "table" then
                        oreResultData = info
                    end
                end)
                pcall(function()
                    mineResultRemote:FireServer(true)
                end)
            else
                log("AutoMine: MineResult remote not found", THEME.danger)
                task.wait(1)
                continue
            end

            local dataWait = tick()
            while not oreResultData and (tick() - dataWait) < 3 do
                task.wait(0.1)
            end
            if resultConn then resultConn:Disconnect() end

            -- FIRE MinigameOpenedEvent (close minigame)
            local minigameOpened = pick and pick:FindFirstChild("MinigameOpenedEvent")
            if minigameOpened then
                pcall(function()
                    minigameOpened:FireServer(tick())
                end)
            end

            -- DESTROY MINIGAME GUI
            pcall(function()
                local playerGui = lp:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, g in pairs(playerGui:GetChildren()) do
                        if g:IsA("ScreenGui") and (g:FindFirstChild("MiningHolder", true) or g:FindFirstChild("FishingHolder", true)) then
                            g:Destroy()
                            break
                        end
                    end
                end
            end)

            -- LOG RESULT
            local oreName = (oreResultData and oreResultData.OreName) or (mineData and mineData.OreName) or "Unknown"
            local oreRarity = (oreResultData and oreResultData.Rarity) or (mineData and mineData.Rarity) or "?"
            local orePrice = (oreResultData and oreResultData.Price) or (mineData and mineData.Price) or nil
            local oreDensity = (oreResultData and oreResultData.Density) or nil

            gui.Mining.LastOre.Text = "Last: " .. oreName .. " [" .. oreRarity .. "]"
            log("AutoMine: Mined " .. oreName .. " (" .. oreRarity .. ")", THEME.success)

            autoMineCounts[oreRarity] = (autoMineCounts[oreRarity] or 0) + 1
            if orePrice and tonumber(orePrice) then
                ctx.perfTotalEarnings = ctx.perfTotalEarnings + tonumber(orePrice)
            end

            if ctx.webhookEnabled and ctx.shouldLogRarity(oreRarity) then
                local priceStr = orePrice and ("Rp." .. tostring(math.floor(tonumber(orePrice) or 0))) or "?"
                ctx.sendWebhook("⛏️ Rare Ore Mined!", "**" .. oreName .. "** [" .. oreRarity .. "]\nPrice: " .. priceStr, 16753920)
            end

            updateMineStats()

            -- Refresh ESP (remove depleted stones, highlight new hotspots)
            if ctx.mineESPOn then
                refreshMineESP()
            end

            -- POST DELAY
            amSetStage("Resetting...")
            task.wait(AM_POST_MINE_DELAY)

            -- Break system: every 60 min, pause 5 min
            if (tick() - mineSessionStart) >= MINE_BREAK_INTERVAL then
                amSetStage("Taking break (5 min)...")
                log("AutoMine: 60 min reached, pausing 5 min", THEME.warn)
                task.wait(MINE_BREAK_DURATION)
                mineSessionStart = tick()
                log("AutoMine: Break over, resuming", THEME.success)
            end
        end

        amSetStage("Idle")
        gui.Mining.Status.TextColor3 = THEME.dim
        log("AutoMine: Stopped", THEME.dim)
    end

    -- Mining toggle button
    bind(gui.Mining.ToggleBtn.MouseButton1Click, function()
        ctx.autoMineEnabled = not ctx.autoMineEnabled
        if ctx.autoMineEnabled then
            gui.Mining.ToggleBtn.Text = "Auto Mine: ON"
            gui.Mining.ToggleBtn.BackgroundColor3 = THEME.success
            task.spawn(autoMineLoop)
        else
            gui.Mining.ToggleBtn.Text = "Auto Mine: OFF"
            gui.Mining.ToggleBtn.BackgroundColor3 = THEME.accent
        end
    end)

    -- Hotspot only toggle
    local function updateHotspotBtnUI()
        if ctx.autoMineHotspotOnly then
            gui.Mining.HotspotBtn.Text = "Hotspot Only: ON"
            gui.Mining.HotspotBtn.BackgroundColor3 = THEME.success
        else
            gui.Mining.HotspotBtn.Text = "Hotspot Only: OFF"
            gui.Mining.HotspotBtn.BackgroundColor3 = THEME.tp
        end
    end
    ctx.updateHotspotBtnUI = updateHotspotBtnUI

    bind(gui.Mining.HotspotBtn.MouseButton1Click, function()
        ctx.autoMineHotspotOnly = not ctx.autoMineHotspotOnly
        updateHotspotBtnUI()
        log("AutoMine: Hotspot Only " .. (ctx.autoMineHotspotOnly and "ON" or "OFF"),
            ctx.autoMineHotspotOnly and THEME.success or THEME.dim)
    end)

    -- Auto TP toggle
    local function updateMineTPBtnUI()
        if ctx.autoMineTPEnabled then
            gui.Mining.TPBtn.Text = "Auto TP to Stones: ON"
            gui.Mining.TPBtn.BackgroundColor3 = THEME.success
        else
            gui.Mining.TPBtn.Text = "Auto TP to Stones: OFF"
            gui.Mining.TPBtn.BackgroundColor3 = THEME.tp
        end
    end
    ctx.updateMineTPBtnUI = updateMineTPBtnUI

    bind(gui.Mining.TPBtn.MouseButton1Click, function()
        ctx.autoMineTPEnabled = not ctx.autoMineTPEnabled
        updateMineTPBtnUI()
        log("AutoMine: Auto TP " .. (ctx.autoMineTPEnabled and "ON" or "OFF"),
            ctx.autoMineTPEnabled and THEME.success or THEME.dim)
        if ctx.autoMineTPEnabled then
            startStoneTPLoop()
        end
    end)

    -- Hotspot ESP toggle
    bind(gui.Mining.ESPBtn.MouseButton1Click, function()
        ctx.mineESPOn = not ctx.mineESPOn
        if ctx.mineESPOn then
            gui.Mining.ESPBtn.Text = "Hotspot ESP: ON"
            gui.Mining.ESPBtn.BackgroundColor3 = THEME.success
            log("AutoMine: Hotspot ESP ON", THEME.success)
        else
            gui.Mining.ESPBtn.Text = "Hotspot ESP: OFF"
            gui.Mining.ESPBtn.BackgroundColor3 = THEME.warn
            log("AutoMine: Hotspot ESP OFF", THEME.dim)
        end
        refreshMineESP()
    end)

    -- ═══════════════════════════════════════════
    -- AUTO SELL ORE SYSTEM
    -- ═══════════════════════════════════════════
    -- ctx.ORE_SELL_INTERVAL / ctx.oreSellRarities are exposed (with defaults)
    -- so Settings save/load persistence works across sessions.
    ctx.ORE_SELL_INTERVAL = ctx.ORE_SELL_INTERVAL or 3600
    ctx.oreSellRarities = ctx.oreSellRarities or {
        Common = true, Uncommon = true, Rare = true,
        Epic = true, Legend = true, Mythic = false, Ancient = false,
    }

    local SellOreRemote = nil
    task.spawn(function()
        local rf = ReplicatedStorage:WaitForChild("GameRemoteFunctions", 10)
        if rf then
            SellOreRemote = rf:WaitForChild("SellAllOreFunction", 10)
        end
    end)

    local function getActiveOreSellRarities()
        local list = {}
        for r, on in pairs(ctx.oreSellRarities) do
            if on then table.insert(list, r) end
        end
        return list
    end

    local function updateOreSellRarityUI()
        for rarity, btn in pairs(gui.Mining.SellRarityButtons) do
            if ctx.oreSellRarities[rarity] then
                btn.BackgroundColor3 = THEME.success
                btn.BackgroundTransparency = 0.2
                btn.TextColor3 = Color3.new(1, 1, 1)
            else
                btn.BackgroundColor3 = THEME.panel2
                btn.BackgroundTransparency = 0.6
                btn.TextColor3 = THEME.dim
            end
        end
    end
    ctx.updateOreSellRarityUI = updateOreSellRarityUI

    local function performOreSell()
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return false, "No HumanoidRootPart" end

        local oreShop = nil
        local world = workspace:FindFirstChild("World")
        if world then
            for _, mapName in ipairs({"Map_01", "Map_02", "Map_03"}) do
                local currentMap = world:FindFirstChild(mapName)
                if currentMap then
                    local s = currentMap:FindFirstChild("Asset")
                    if s then s = s:FindFirstChild("ShopNPC") end
                    if s then s = s:FindFirstChild("OreShop") end
                    if s then
                        oreShop = s
                        break
                    end
                end
            end
        end

        if not oreShop then return false, "OreShop not found!" end

        local wasAutoMine = ctx.autoMineEnabled
        local wasAutoTP = ctx.autoTPEnabled
        ctx.autoTPEnabled = false
        local oldCFrame = hrp.CFrame
        local oldAnchorPos = ctx.frozenAnchor and ctx.frozenAnchor.Position

        local shopPivot = oreShop:GetPivot()
        local targetPos = (shopPivot * CFrame.new(0, 3, 12)).Position
        hrp.CFrame = CFrame.new(targetPos)
        if ctx.frozenAnchor and ctx.frozenAnchor.Parent then
            ctx.frozenAnchor.Position = targetPos
        end

        task.wait(0.3)

        -- Spawn auto-confirm handler for the sell confirmation UI
        local confirmDone = false
        task.spawn(function()
            local playerGui = lp:FindFirstChild("PlayerGui")
            if not playerGui then return end
            -- Wait for SellConfirmation GUI to appear (up to 5s)
            local waitStart = tick()
            local confirmGui = nil
            while not confirmGui and (tick() - waitStart) < 5 do
                confirmGui = playerGui:FindFirstChild("SellConfirmation")
                if not confirmGui then task.wait(0.1) end
            end
            if confirmGui then
                -- Find the ConfirmFunctionEvent and invoke its callback
                local controller = confirmGui:FindFirstChild("SellConfirmationUIController")
                if controller then
                    local confirmEvent = controller:FindFirstChild("ConfirmFunctionEvent")
                    if confirmEvent then
                        pcall(function()
                            confirmEvent:Invoke()
                        end)
                    end
                end
                -- Destroy the confirmation UI
                task.wait(0.2)
                pcall(function() confirmGui:Destroy() end)
            end
            confirmDone = true
        end)

        local raritiesList = getActiveOreSellRarities()
        local result
        local success, err = pcall(function()
            if SellOreRemote then
                result = SellOreRemote:InvokeServer(raritiesList)
            end
        end)

        -- Wait for confirmation to complete if not already
        local cWait = tick()
        while not confirmDone and (tick() - cWait) < 3 do
            task.wait(0.1)
        end

        -- Clean up any leftover confirmation GUI
        pcall(function()
            local playerGui = lp:FindFirstChild("PlayerGui")
            if playerGui then
                local confirmGui = playerGui:FindFirstChild("SellConfirmation")
                if confirmGui then confirmGui:Destroy() end
            end
        end)

        hrp.CFrame = oldCFrame
        if ctx.frozenAnchor and ctx.frozenAnchor.Parent and oldAnchorPos then
            ctx.frozenAnchor.Position = oldAnchorPos
        end
        ctx.autoTPEnabled = wasAutoTP

        return success, result or err
    end

    -- Sell rarity toggles
    for rarity, btn in pairs(gui.Mining.SellRarityButtons) do
        bind(btn.MouseButton1Click, function()
            ctx.oreSellRarities[rarity] = not ctx.oreSellRarities[rarity]
            updateOreSellRarityUI()
        end)
    end

    -- Sell interval input
    bind(gui.Mining.SellIntervalInput.FocusLost, function()
        local val = tonumber(gui.Mining.SellIntervalInput.Text)
        if val and val >= 10 then
            ctx.ORE_SELL_INTERVAL = val
            log("Ore Sell interval: " .. val .. "s", THEME.dim)
        else
            gui.Mining.SellIntervalInput.Text = tostring(ctx.ORE_SELL_INTERVAL)
        end
    end)

    -- Auto sell ore toggle
    bind(gui.Mining.AutoSellBtn.MouseButton1Click, function()
        ctx.autoSellOreEnabled = not ctx.autoSellOreEnabled
        if ctx.autoSellOreEnabled then
            gui.Mining.AutoSellBtn.Text = "Auto Sell Ore: ON"
            gui.Mining.AutoSellBtn.BackgroundColor3 = THEME.success
            log("Auto Sell Ore: ON (interval " .. ctx.ORE_SELL_INTERVAL .. "s)", THEME.success)
            task.spawn(function()
                while ctx.autoSellOreEnabled and not ctx.destroyed do
                    if SellOreRemote then
                        local ok, msg = performOreSell()
                        log("Auto Sell Ore: " .. tostring(msg), ok and THEME.success or THEME.danger)
                    end
                    task.wait(ctx.ORE_SELL_INTERVAL)
                end
            end)
        else
            gui.Mining.AutoSellBtn.Text = "Auto Sell Ore: OFF"
            gui.Mining.AutoSellBtn.BackgroundColor3 = THEME.warn
            log("Auto Sell Ore: OFF", THEME.dim)
        end
    end)

    -- Sell ore now button
    bind(gui.Mining.SellNowBtn.MouseButton1Click, function()
        log("Sell Ore Now: Attempting TP & sell...", THEME.warn)
        if not SellOreRemote then
            log("Sell Ore Now: FAILED - remote not loaded", THEME.danger)
            return
        end
        local success, msg = performOreSell()
        if success then
            log("Sell Ore Now: SUCCESS - " .. tostring(msg), THEME.success)
        else
            log("Sell Ore Now: FAILED - " .. tostring(msg), THEME.danger)
        end
    end)

    updateOreSellRarityUI()
    updateHotspotBtnUI()
    updateMineTPBtnUI()
    gui.Mining.SellIntervalInput.Text = tostring(ctx.ORE_SELL_INTERVAL)

    -- If Auto TP was restored as ON from saved settings, start the standalone loop
    if ctx.autoMineTPEnabled then
        startStoneTPLoop()
    end
end
