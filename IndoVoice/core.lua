-- FishZone/core.lua
-- Unified latest core logic, keeps rewards + sell + ESP + clicker + FishZone
return function(gui, config)
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TextChatService = game:FindService("TextChatService")

    local lp = Players.LocalPlayer
    local mouse = lp:GetMouse()
    local cam = workspace.CurrentCamera

    local AUTO_SELL_INTERVAL = config.AutoSell and config.AutoSell.Interval or 300
    local AUTO_SELL_RARITIES = config.AutoSell and config.AutoSell.Rarities or
        { "Legend", "Epic", "Rare", "Uncommon", "Common" }
    local autoSellEnabled = false
    local autoClaimDailyRewardEnabled = false
    local autoClaimSessionRewardEnabled = false
    local TOGGLE_KEY = config.Keys.ToggleClicker
    local HIDE_KEY = config.Keys.HideUI
    local PICK_KEY = config.Keys.PickPosition
    local DEFAULT_CPS = config.Clicker.DefaultCPS
    local POSITION_MODE = config.Clicker.PositionMode
    local FIXED_X, FIXED_Y = config.Clicker.FixedX, config.Clicker.FixedY
    local FISHING_ZONE_PATH = config.FishZone.Path
    local FLOAT_HEIGHT = config.FishZone.FloatHeight
    local BLACKLISTED_POSITIONS = config.FishZone.BlacklistedPositions
    local BLACKLIST_THRESHOLD = config.FishZone.BlacklistThreshold

    local clicking = false
    local destroyed = false
    local clickCPS = DEFAULT_CPS
    local clickDelay = 1 / DEFAULT_CPS
    local savedX, savedY = FIXED_X, FIXED_Y
    local autoTPEnabled = false
    local currentZone = nil
    local frozenAnchor = nil
    local frozenGyro = nil
    local hideUI = false
    local zoneESPOn = false
    local playerSearchText = ""
    local minimized = false
    local draggingUI = false
    local draggingSlider = false
    local dragStart, startPos
    local lastClick = 0
    local activeTab = "Players"

    local espObjects = {}
    local zoneObjects = {}
    local playerRows = {}
    local beamStates = {}
    local connections = {}
    local playerConnections = {}
    local zoneAttributeConnections = {}
    local rodStateConnections = {}
    local rodTool = nil
    local isFishing = false

    local THEME = gui.Theme

    local function bind(signal, fn)
        local c = signal:Connect(fn)
        table.insert(connections, c)
        return c
    end

    local function disconnectList(list)
        for _, c in ipairs(list) do
            pcall(function() c:Disconnect() end)
        end
        table.clear(list)
    end

    local function getHRP(char)
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function getHum(char)
        return char and char:FindFirstChildOfClass("Humanoid")
    end

    local function clearRodStateConnections()
        for _, c in ipairs(rodStateConnections) do
            pcall(function() c:Disconnect() end)
        end
        table.clear(rodStateConnections)
    end

    local function attachRodState(tool)
        rodTool = tool
        clearRodStateConnections()
        isFishing = false

        local function hookRemote(name, fn)
            local obj = tool:FindFirstChild(name)
            if obj and obj:IsA("RemoteEvent") then
                table.insert(rodStateConnections, obj.OnClientEvent:Connect(fn))
            end
        end

        hookRemote("BaitLanded", function(...)
            isFishing = true
        end)

        hookRemote("FishingCanceled", function(...)
            isFishing = false
        end)

        hookRemote("Catch", function(...)
            isFishing = false
        end)

        hookRemote("ToolReady", function(...)
            if not isFishing then
                isFishing = false
            end
        end)

        table.insert(rodStateConnections, tool.AncestryChanged:Connect(function(_, parent)
            local char = lp.Character
            if not parent or not char or not tool:IsDescendantOf(char) then
                rodTool = nil
                isFishing = false
                clearRodStateConnections()
            end
        end))
    end

    local function tryAttachCurrentRod()
        local char = lp.Character
        if not char then
            return
        end
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Tool") and obj:FindFirstChild("Cast") then
                attachRodState(obj)
                return
            end
        end
    end

    local function resolvePosition()
        if POSITION_MODE == "center" then
            local vp = cam.ViewportSize
            return vp.X / 2, vp.Y / 2
        elseif POSITION_MODE == "custom" then
            return FIXED_X or 960, FIXED_Y or 540
        else
            return savedX, savedY
        end
    end

    local function lower(s)
        return string.lower(tostring(s or ""))
    end

    local function isBlacklisted(part)
        for _, bpos in ipairs(BLACKLISTED_POSITIONS) do
            if (part.Position - bpos).Magnitude <= BLACKLIST_THRESHOLD then
                return true
            end
        end
        return false
    end

    local function isActiveZone(part)
        return part and part:IsA("BasePart") and part:GetAttribute("IsActive") == true and not isBlacklisted(part)
    end

    local function getZoneParts()
        local parts = {}
        for _, part in ipairs(FISHING_ZONE_PATH:GetChildren()) do
            if part:IsA("BasePart") then
                table.insert(parts, part)
            end
        end
        return parts
    end

    local function getActiveZoneParts()
        local parts = {}
        for _, part in ipairs(getZoneParts()) do
            if isActiveZone(part) then
                table.insert(parts, part)
            end
        end
        return parts
    end

    local function isInsidePart(hrp, part)
        if not hrp or not part then return false end
        local rel = part.CFrame:PointToObjectSpace(hrp.Position)
        local half = part.Size / 2
        return math.abs(rel.X) <= half.X
            and math.abs(rel.Y) <= half.Y + FLOAT_HEIGHT + 1.5
            and math.abs(rel.Z) <= half.Z
    end

    local function isInsideAnyActiveZone(hrp)
        if not hrp then return false, nil end
        for _, part in ipairs(getActiveZoneParts()) do
            if isInsidePart(hrp, part) then
                return true, part
            end
        end
        return false, nil
    end

    local function nearestActiveZonePart()
        local hrp = getHRP(lp.Character)
        if not hrp then return nil end
        local best, bestDist = nil, math.huge
        for _, part in ipairs(getActiveZoneParts()) do
            local d = (hrp.Position - part.Position).Magnitude
            if d < bestDist then
                bestDist = d
                best = part
            end
        end
        return best
    end

    local VIM = pcall(function()
        return cloneref(game:GetService("VirtualInputManager"))
    end) and cloneref(game:GetService("VirtualInputManager")) or game:GetService("VirtualInputManager")

    local useVIM = pcall(function()
        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
    end)

    local function silentClick(x, y)
        if useVIM then
            VIM:SendMouseButtonEvent(x, y, 0, true, game, 1)
            VIM:SendMouseButtonEvent(x, y, 0, false, game, 1)
        else
            local cx, cy = mouse.X, mouse.Y
            mousemoveabs(x, y)
            mouse1press()
            mouse1release()
            mousemoveabs(cx, cy)
        end
    end

    local function unfreezeCharacter()
        if frozenAnchor and frozenAnchor.Parent then frozenAnchor:Destroy() end
        frozenAnchor = nil
        if frozenGyro and frozenGyro.Parent then frozenGyro:Destroy() end
        frozenGyro = nil
        local hum = getHum(lp.Character)
        if hum then hum.PlatformStand = false end
    end

    local function freezeAt(pos)
        local char = lp.Character
        local hrp = getHRP(char)
        local hum = getHum(char)
        if not hrp then return end

        local rotCF = CFrame.new(pos) * CFrame.Angles(0, math.rad(89), 0)
        hrp.CFrame = rotCF
        if hum then hum.PlatformStand = true end

        if frozenAnchor and frozenAnchor.Parent then frozenAnchor:Destroy() end
        local bp = Instance.new("BodyPosition")
        bp.Name = "AhzencalZoneFreeze"
        bp.Position = pos
        bp.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        bp.P = 2e4
        bp.D = 1200
        bp.Parent = hrp
        frozenAnchor = bp

        if frozenGyro and frozenGyro.Parent then frozenGyro:Destroy() end
        local bg = Instance.new("BodyGyro")
        bg.Name = "AhzencalZoneGyro"
        bg.CFrame = CFrame.Angles(0, math.rad(89), 0)
        bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        bg.P = 1e5
        bg.D = 500
        bg.Parent = hrp
        frozenGyro = bg
    end

    local function tpToZone(part)
        if not isActiveZone(part) then return false end
        local pos = part.Position + Vector3.new(0, part.Size.Y / 2 + FLOAT_HEIGHT, 0)
        freezeAt(pos)
        currentZone = part
        return true
    end

    local function tpToPlayer(target)
        local hrp = getHRP(lp.Character)
        local targetHRP = getHRP(target.Character)
        if hrp and targetHRP then
            hrp.CFrame = targetHRP.CFrame
        end
    end

    local function sendAdonisRefresh(msg)
        pcall(function()
            local defaultEvent = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            local sayEvent = defaultEvent and defaultEvent:FindFirstChild("SayMessageRequest")
            if sayEvent then sayEvent:FireServer(msg, "All") end
        end)
        pcall(function()
            if TextChatService and TextChatService.TextChannels then
                local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                if channel then channel:SendAsync(msg) end
            end
        end)
        pcall(function()
            game:GetService("Players"):Chat(msg)
        end)
    end

    local function refreshCharacterAdonis()
        unfreezeCharacter()
        task.spawn(function()
            task.wait(0.15)
            sendAdonisRefresh("!refresh")
            task.wait(0.4)
            sendAdonisRefresh("/refresh")
        end)
    end

    local function removeESPForPlayer(player)
        local obj = espObjects[player]
        if not obj then return end
        if obj.billboard then obj.billboard:Destroy() end
        if obj.box then obj.box:Destroy() end
        espObjects[player] = nil
    end

    local function makeESPForPlayer(player)
        if espObjects[player] then return end
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESP_Box"
        box.Size = Vector3.new(2, 5, 1)
        box.Color3 = THEME.accent
        box.AlwaysOnTop = true
        box.Transparency = 0.45
        box.ZIndex = 5
        box.SizeRelativeOffset = Vector3.new(0, 0.5, 0)

        local bb = Instance.new("BillboardGui")
        bb.Name = "ESP_Tag"
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0, 120, 0, 28)
        bb.StudsOffset = Vector3.new(0, 3, 0)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = player.Name
        lbl.TextColor3 = THEME.accent
        lbl.TextStrokeTransparency = 0
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.Parent = bb

        local function attach(char)
            local hrp = getHRP(char)
            if hrp then
                box.Adornee = hrp
                box.Parent = hrp
                bb.Adornee = hrp
                bb.Parent = hrp
            end
        end

        if player.Character then attach(player.Character) end
        playerConnections[player] = playerConnections[player] or {}
        table.insert(playerConnections[player], player.CharacterAdded:Connect(attach))
        espObjects[player] = { box = box, billboard = bb }
    end

    local function stopBeam(player)
        local state = beamStates[player]
        if not state then return end
        state.enabled = false
        if state.beam then state.beam:Destroy() end
        if state.a0 then state.a0:Destroy() end
        if state.a1 then state.a1:Destroy() end
        beamStates[player] = nil
    end

    local function startBeam(player)
        stopBeam(player)
        local state = { enabled = true }
        beamStates[player] = state
        task.spawn(function()
            while state.enabled and not destroyed do
                local myHRP = getHRP(lp.Character)
                local targetHRP = getHRP(player.Character)
                if myHRP and targetHRP then
                    if state.a0 and state.a0.Parent ~= myHRP then
                        state.a0:Destroy(); state.a0 = nil
                    end
                    if state.a1 and state.a1.Parent ~= targetHRP then
                        state.a1:Destroy(); state.a1 = nil
                    end
                    if not state.a0 then state.a0 = Instance.new("Attachment", myHRP) end
                    if not state.a1 then state.a1 = Instance.new("Attachment", targetHRP) end
                    if not state.beam or not state.beam.Parent then
                        local beam = Instance.new("Beam")
                        beam.Attachment0 = state.a0
                        beam.Attachment1 = state.a1
                        beam.Color = ColorSequence.new(THEME.accent)
                        beam.Width0 = 0.12
                        beam.Width1 = 0.12
                        beam.FaceCamera = true
                        beam.Parent = workspace
                        state.beam = beam
                    end
                end
                task.wait(0.25)
            end
            stopBeam(player)
        end)
    end

    local function passesSearch(player)
        if player == lp then return false end
        if playerSearchText == "" then return true end
        return lower(player.Name):find(lower(playerSearchText), 1, true) ~= nil
            or lower(player.DisplayName):find(lower(playerSearchText), 1, true) ~= nil
    end

    local function refreshPlayerRows()
        for player, row in pairs(playerRows) do
            row.Visible = passesSearch(player)
        end
    end

    local function makePlayerRow(player)
        if player == lp or playerRows[player] then return end

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -8, 0, 38)
        row.BackgroundColor3 = THEME.panel2
        row.BorderSizePixel = 0
        row.Parent = gui.Players.PlayerList
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

        local name = Instance.new("TextLabel")
        name.Text = player.Name
        name.Size = UDim2.new(0, 104, 1, 0)
        name.Position = UDim2.new(0, 10, 0, 0)
        name.BackgroundTransparency = 1
        name.TextColor3 = THEME.text
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Font = Enum.Font.GothamBold
        name.TextSize = 12
        name.Parent = row

        local function miniBtn(txt, x, color)
            local b = Instance.new("TextButton")
            b.Text = txt
            b.Size = UDim2.new(0, 54, 0, 24)
            b.Position = UDim2.new(0, x, 0.5, -12)
            b.BackgroundColor3 = color
            b.TextColor3 = Color3.new(1, 1, 1)
            b.Font = Enum.Font.GothamBold
            b.TextSize = 11
            b.BorderSizePixel = 0
            b.Parent = row
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            return b
        end

        local espBtn = miniBtn("ESP", 118, THEME.accent)
        local tpBtn = miniBtn("TP", 176, THEME.tp)
        local beamBtn = miniBtn("Beam", 234, THEME.beam)
        local espOn = false
        local beamOn = false

        bind(espBtn.MouseButton1Click, function()
            espOn = not espOn
            if espOn then
                makeESPForPlayer(player)
                espBtn.Text = "ESP ✓"
                espBtn.BackgroundColor3 = THEME.success
            else
                removeESPForPlayer(player)
                espBtn.Text = "ESP"
                espBtn.BackgroundColor3 = THEME.accent
            end
        end)

        bind(tpBtn.MouseButton1Click, function()
            tpToPlayer(player)
        end)

        bind(beamBtn.MouseButton1Click, function()
            beamOn = not beamOn
            if beamOn then
                startBeam(player)
                beamBtn.Text = "Beam✓"
                beamBtn.BackgroundColor3 = THEME.warn
            else
                stopBeam(player)
                beamBtn.Text = "Beam"
                beamBtn.BackgroundColor3 = THEME.beam
            end
        end)

        playerRows[player] = row
        row.Visible = passesSearch(player)
    end

    local function removePlayerRow(player)
        if playerRows[player] then
            playerRows[player]:Destroy(); playerRows[player] = nil
        end
        removeESPForPlayer(player)
        stopBeam(player)
        if playerConnections[player] then
            disconnectList(playerConnections[player]); playerConnections[player] = nil
        end
    end

    local function removeZoneESP(part)
        local obj = zoneObjects[part]
        if not obj then return end
        if obj.highlight then obj.highlight:Destroy() end
        if obj.billboard then obj.billboard:Destroy() end
        zoneObjects[part] = nil
    end

    local function addZoneESP(part)
        if zoneObjects[part] or not isActiveZone(part) then return end

        local sb = Instance.new("SelectionBox")
        sb.Adornee = part
        sb.Color3 = THEME.accent
        sb.LineThickness = 0.06
        sb.SurfaceTransparency = 0.82
        sb.SurfaceColor3 = THEME.accent
        sb.Parent = workspace

        local bb = Instance.new("BillboardGui")
        bb.Adornee = part
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0, 140, 0, 28)
        bb.StudsOffset = Vector3.new(0, part.Size.Y / 2 + 4, 0)
        bb.Parent = workspace

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "Active Zone"
        lbl.TextColor3 = THEME.accent
        lbl.TextStrokeTransparency = 0
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.Parent = bb

        zoneObjects[part] = { highlight = sb, billboard = bb }
    end

    local function refreshZoneESP()
        for _, part in ipairs(getZoneParts()) do
            if zoneESPOn and isActiveZone(part) then
                addZoneESP(part)
            else
                removeZoneESP(part)
            end
        end
    end

    local function moveToNearestActiveZone()
        local nearest = nearestActiveZonePart()
        if nearest then
            tpToZone(nearest)
            return true, nearest
        end
        return false, nil
    end

    local function stopAutoTP()
        autoTPEnabled = false
        currentZone = nil
        unfreezeCharacter()
        gui.FishZone.AutoTPBtn.Text = "Auto TP Active FishZone: OFF"
        gui.FishZone.AutoTPBtn.BackgroundColor3 = THEME.tp
    end

    local function startAutoTP()
        autoTPEnabled = true
        gui.FishZone.AutoTPBtn.Text = "Auto TP Active FishZone: ON"
        gui.FishZone.AutoTPBtn.BackgroundColor3 = THEME.success
    end

    local SellRemote = nil
    local DailyRewardRemote = nil
    local SessionRewardRemote = nil

    task.spawn(function()
        local rf = ReplicatedStorage:WaitForChild("GameRemoteFunctions", 10)
        if rf then
            SellRemote = rf:WaitForChild("SellAllFishFunction", 10)
            DailyRewardRemote = rf:WaitForChild("CollectDailyRewardFunction", 10)
            SessionRewardRemote = rf:WaitForChild("CollectSessionRewardFunction", 10)
        end
    end)

    local function updateRewardButtons()
        if gui.Settings.AutoClaimDailyRewardBtn then
            gui.Settings.AutoClaimDailyRewardBtn.Text = autoClaimDailyRewardEnabled and "Auto Claim Daily Reward: ON" or
            "Auto Claim Daily Reward: OFF"
            gui.Settings.AutoClaimDailyRewardBtn.BackgroundColor3 = autoClaimDailyRewardEnabled and THEME.success or
            THEME.accent
        end
        if gui.Settings.AutoClaimSessionRewardBtn then
            gui.Settings.AutoClaimSessionRewardBtn.Text = autoClaimSessionRewardEnabled and
            "Auto Claim Session Reward: ON" or "Auto Claim Session Reward: OFF"
            gui.Settings.AutoClaimSessionRewardBtn.BackgroundColor3 = autoClaimSessionRewardEnabled and THEME.success or
            THEME.accent
        end
    end

    local function claimDailyReward()
        if not DailyRewardRemote then
            return false, "Daily reward remote not loaded"
        end
        local ok, a, b = pcall(function()
            return DailyRewardRemote:InvokeServer()
        end)
        if not ok then
            return false, tostring(a)
        end
        return a, b
    end

    local function claimSessionReward()
        if not SessionRewardRemote then
            return false, "Session reward remote not loaded"
        end
        local ok, result = pcall(function()
            if SessionRewardRemote:IsA("RemoteEvent") then
                SessionRewardRemote:FireServer()
                return true
            elseif SessionRewardRemote:IsA("RemoteFunction") then
                return SessionRewardRemote:InvokeServer()
            end
            return false
        end)
        if not ok then
            return false, tostring(result)
        end
        return result, "Session reward fired"
    end

    local function performSell()
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            return false, "No HumanoidRootPart found"
        end

        if isFishing then
            return false, "Cannot sell while bait is landed"
        end

        local shopPart = nil
        local world = workspace:FindFirstChild("World")
        if world then
            for _, mapName in ipairs({ "Map_01", "Map_02", "Map_03" }) do
                local currentMap = world:FindFirstChild(mapName)
                if currentMap then
                    local s = currentMap:FindFirstChild("Asset")
                    if s then s = s:FindFirstChild("ShopNPC") end
                    if s then s = s:FindFirstChild("FishShop") end
                    if s then
                        shopPart = s
                        break
                    end
                end
            end
        end

        if not shopPart then
            return false, "FishShop not found!"
        end

        local shopPivot = shopPart:GetPivot()
        local wasAutoTP = autoTPEnabled
        autoTPEnabled = false
        local oldCFrame = hrp.CFrame
        local oldAnchorPos = frozenAnchor and frozenAnchor.Position
        local targetPos = (shopPivot * CFrame.new(0, 3, 12)).Position

        hrp.CFrame = CFrame.new(targetPos)
        if frozenAnchor and frozenAnchor.Parent then
            frozenAnchor.Position = targetPos
        end

        task.wait(0.3)

        local result
        local success, err = pcall(function()
            if SellRemote:IsA("RemoteFunction") then
                result = SellRemote:InvokeServer(AUTO_SELL_RARITIES)
            elseif SellRemote:IsA("RemoteEvent") then
                SellRemote:FireServer(AUTO_SELL_RARITIES)
                result = "Fired RemoteEvent Payload"
            end
        end)

        hrp.CFrame = oldCFrame
        if frozenAnchor and frozenAnchor.Parent and oldAnchorPos then
            frozenAnchor.Position = oldAnchorPos
        end
        autoTPEnabled = wasAutoTP
        return success, result or err
    end

    bind(lp.CharacterAdded, function(char)
        clearRodStateConnections()
        rodTool = nil
        isFishing = false

        bind(char.ChildAdded, function(obj)
            if obj:IsA("Tool") and obj:FindFirstChild("Cast") then
                attachRodState(obj)
            end
        end)

        bind(char.ChildRemoved, function(obj)
            if obj == rodTool then
                rodTool = nil
                isFishing = false
                clearRodStateConnections()
            end
        end)

        task.defer(tryAttachCurrentRod)
    end)

    if lp.Character then
        bind(lp.Character.ChildAdded, function(obj)
            if obj:IsA("Tool") and obj:FindFirstChild("Cast") then
                attachRodState(obj)
            end
        end)

        bind(lp.Character.ChildRemoved, function(obj)
            if obj == rodTool then
                rodTool = nil
                isFishing = false
                clearRodStateConnections()
            end
        end)

        tryAttachCurrentRod()
    end

    bind(gui.FishZone.AutoSellBtn.MouseButton1Click, function()
        autoSellEnabled = not autoSellEnabled
        if autoSellEnabled then
            gui.FishZone.AutoSellBtn.Text = "Auto Sell Fish: ON"
            gui.FishZone.AutoSellBtn.BackgroundColor3 = THEME.success
            task.spawn(function()
                while autoSellEnabled and not destroyed do
                    if SellRemote then
                        performSell()
                    end
                    task.wait(AUTO_SELL_INTERVAL)
                end
            end)
        else
            gui.FishZone.AutoSellBtn.Text = "Auto Sell Fish: OFF"
            gui.FishZone.AutoSellBtn.BackgroundColor3 = THEME.warn
        end
    end)

    bind(gui.FishZone.SellNowBtn.MouseButton1Click, function()
        print("[IndoVoice] Attempting split-second TP & sell...")
        if not SellRemote then
            warn("[IndoVoice] Error: Sell remote not loaded yet!")
            return
        end
        local success, msg = performSell()
        if success then
            print("[IndoVoice] SUCCESS:", msg)
        else
            warn("[IndoVoice] FAILED to sell fish:", msg)
        end
    end)

    if gui.Settings.AutoClaimDailyRewardBtn then
        bind(gui.Settings.AutoClaimDailyRewardBtn.MouseButton1Click, function()
            autoClaimDailyRewardEnabled = not autoClaimDailyRewardEnabled
            updateRewardButtons()
            if autoClaimDailyRewardEnabled then
                task.spawn(function()
                    while autoClaimDailyRewardEnabled and not destroyed do
                        local success, message = claimDailyReward()
                        if success then
                            print("[IndoVoice] Daily reward claimed:", message)
                            autoClaimDailyRewardEnabled = false
                            updateRewardButtons()
                            break
                        end
                        task.wait(30)
                    end
                end)
            end
        end)
    end

    if gui.Settings.AutoClaimSessionRewardBtn then
        bind(gui.Settings.AutoClaimSessionRewardBtn.MouseButton1Click, function()
            autoClaimSessionRewardEnabled = not autoClaimSessionRewardEnabled
            updateRewardButtons()
            if autoClaimSessionRewardEnabled then
                task.spawn(function()
                    while autoClaimSessionRewardEnabled and not destroyed do
                        local success, message = claimSessionReward()
                        if success then
                            print("[IndoVoice] Session reward claimed:", message)
                        end
                        task.wait(60)
                    end
                end)
            end
        end)
    end

    bind(gui.Players.SearchBox:GetPropertyChangedSignal("Text"), function()
        playerSearchText = gui.Players.SearchBox.Text
        refreshPlayerRows()
    end)

    for _, p in ipairs(Players:GetPlayers()) do makePlayerRow(p) end
    bind(Players.PlayerAdded, makePlayerRow)
    bind(Players.PlayerRemoving, removePlayerRow)

    bind(gui.FishZone.ZoneESPBtn.MouseButton1Click, function()
        zoneESPOn = not zoneESPOn
        gui.FishZone.ZoneESPBtn.Text = zoneESPOn and "FishZone ESP: ON" or "FishZone ESP: OFF"
        gui.FishZone.ZoneESPBtn.BackgroundColor3 = zoneESPOn and THEME.success or THEME.accent
        refreshZoneESP()
    end)

    bind(gui.FishZone.AutoTPBtn.MouseButton1Click, function()
        if autoTPEnabled then
            stopAutoTP()
        else
            startAutoTP()
            moveToNearestActiveZone()
        end
    end)

    bind(gui.FishZone.RefreshCharBtn.MouseButton1Click, function()
        gui.FishZone.RefreshCharBtn.Text = "Refreshing..."
        refreshCharacterAdonis()
        task.delay(1.2, function()
            if gui.FishZone.RefreshCharBtn and gui.FishZone.RefreshCharBtn.Parent then
                gui.FishZone.RefreshCharBtn.Text = "Refresh Character"
            end
        end)
    end)

    for _, part in ipairs(getZoneParts()) do
        table.insert(zoneAttributeConnections, part:GetAttributeChangedSignal("IsActive"):Connect(function()
            refreshZoneESP()
            if autoTPEnabled then
                local hrp = getHRP(lp.Character)
                local currentStillActive = isActiveZone(currentZone)
                local insideActive, insidePart = isInsideAnyActiveZone(hrp)
                if not currentStillActive then
                    unfreezeCharacter()
                    currentZone = nil
                    moveToNearestActiveZone()
                elseif insideActive and insidePart ~= currentZone then
                    currentZone = insidePart
                    tpToZone(insidePart)
                elseif not insideActive then
                    moveToNearestActiveZone()
                end
            end
        end))
    end

    bind(gui.Clicker.ToggleBtn.MouseButton1Click, toggleClicker)

    bind(gui.Clicker.SliderKnob.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end
    end)

    bind(UserInputService.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
    end)

    bind(UserInputService.InputChanged, function(i)
        if draggingSlider and i.UserInputType == Enum.UserInputType.MouseMovement then
            local ratio = math.clamp(
                (i.Position.X - gui.Clicker.SliderTrack.AbsolutePosition.X) / gui.Clicker.SliderTrack.AbsoluteSize.X, 0,
                1)
            clickCPS = math.max(1, math.floor(ratio * 100))
            clickDelay = 1 / clickCPS
            gui.Clicker.SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
            gui.Clicker.SliderKnob.Position = UDim2.new(ratio, -8, 0.5, -8)
            gui.Clicker.CPSLbl.Text = "CPS: " .. clickCPS
        end
    end)

    local function destroyAll()
        clicking = false
        destroyed = true
        autoTPEnabled = false
        autoSellEnabled = false
        clearRodStateConnections()
        rodTool = nil
        isFishing = false
        unfreezeCharacter()
        disconnectList(connections)
        disconnectList(zoneAttributeConnections)
        for player in pairs(espObjects) do removeESPForPlayer(player) end
        for part in pairs(zoneObjects) do removeZoneESP(part) end
        for player in pairs(beamStates) do stopBeam(player) end
        for _, list in pairs(playerConnections) do disconnectList(list) end
        pcall(function() gui.MainGui:Destroy() end)
    end

    bind(gui.Settings.UnloadBtn.MouseButton1Click, destroyAll)
    bind(gui.CloseBtn.MouseButton1Click, destroyAll)

    updateRewardButtons()
    refreshPlayerRows()
    refreshZoneESP()
end
