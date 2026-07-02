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
    local antiIdleEnabled = false
    local antiIdleConnections = {}
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

    -- ═══════════════════════════════════════════
    -- LOGGING SYSTEM
    -- ═══════════════════════════════════════════
    local logEntries = 0
    local MAX_LOG_ENTRIES = 200

    local function log(msg, color)
        color = color or THEME.dim
        logEntries = logEntries + 1
        if logEntries > MAX_LOG_ENTRIES then
            -- Remove oldest entry
            local children = gui.Logs.LogScroll:GetChildren()
            for _, child in ipairs(children) do
                if child:IsA("TextLabel") then
                    child:Destroy()
                    break
                end
            end
            logEntries = logEntries - 1
        end

        local timestamp = os.date("%H:%M:%S")
        local entry = Instance.new("TextLabel")
        entry.Size = UDim2.new(1, -8, 0, 16)
        entry.BackgroundTransparency = 1
        entry.Text = "[" .. timestamp .. "] " .. tostring(msg)
        entry.TextColor3 = color
        entry.Font = Enum.Font.Code
        entry.TextSize = 11
        entry.TextXAlignment = Enum.TextXAlignment.Left
        entry.TextWrapped = true
        entry.AutomaticSize = Enum.AutomaticSize.Y
        entry.Parent = gui.Logs.LogScroll

        gui.Logs.LogCount.Text = logEntries .. " entries"

        -- Auto-scroll to bottom
        task.defer(function()
            gui.Logs.LogScroll.CanvasPosition = Vector2.new(0, gui.Logs.LogScroll.AbsoluteCanvasSize.Y)
        end)
    end

    -- Clear logs button
    bind(gui.Logs.ClearLogsBtn.MouseButton1Click, function()
        for _, child in ipairs(gui.Logs.LogScroll:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        logEntries = 0
        gui.Logs.LogCount.Text = "0 entries"
    end)

    local function getHRP(char)
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function getHum(char)
        return char and char:FindFirstChildOfClass("Humanoid")
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
        name.Size = UDim2.new(0, 140, 1, 0)
        name.Position = UDim2.new(0, 10, 0, 0)
        name.BackgroundTransparency = 1
        name.TextColor3 = THEME.text
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Font = Enum.Font.GothamBold
        name.TextSize = 12
        name.TextTruncate = Enum.TextTruncate.AtEnd
        name.Parent = row

        -- Buttons positioned from the RIGHT side
        local function miniBtn(txt, offsetFromRight, color)
            local b = Instance.new("TextButton")
            b.Text = txt
            b.Size = UDim2.new(0, 50, 0, 24)
            b.Position = UDim2.new(1, -offsetFromRight, 0.5, -12)
            b.BackgroundColor3 = color
            b.TextColor3 = Color3.new(1, 1, 1)
            b.Font = Enum.Font.GothamBold
            b.TextSize = 10
            b.BorderSizePixel = 0
            b.Parent = row
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            return b
        end

        local inspectBtn = miniBtn("View", 56, THEME.dim)
        local beamBtn = miniBtn("Beam", 112, THEME.beam)
        local tpBtn = miniBtn("TP", 168, THEME.tp)
        local espBtn = miniBtn("ESP", 224, THEME.accent)
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

        bind(inspectBtn.MouseButton1Click, function()
            -- Open avatar inspect menu for this player
            pcall(function()
                game:GetService("GuiService"):InspectPlayerFromUserId(player.UserId)
            end)
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

    local function updateClickerUI()
        if clicking then
            gui.Clicker.StatusLbl.Text = "Status: ON"
            gui.Clicker.StatusLbl.TextColor3 = THEME.success
            gui.Clicker.ToggleBtn.Text = "Stop [" .. tostring(TOGGLE_KEY):gsub("Enum.KeyCode.", "") .. "]"
            gui.Clicker.ToggleBtn.BackgroundColor3 = THEME.danger
        else
            gui.Clicker.StatusLbl.Text = "Status: OFF"
            gui.Clicker.StatusLbl.TextColor3 = THEME.danger
            gui.Clicker.ToggleBtn.Text = "Start [" .. tostring(TOGGLE_KEY):gsub("Enum.KeyCode.", "") .. "]"
            gui.Clicker.ToggleBtn.BackgroundColor3 = THEME.accent
        end

        gui.Clicker.MethodLbl.Text = useVIM and "Mode: Silent" or "Mode: Fallback"
        gui.Clicker.MethodLbl.TextColor3 = useVIM and THEME.success or THEME.warn

        local x, y = resolvePosition()
        if x and y then
            gui.Clicker.PosLbl.Text = string.format("Target: (%d, %d)", math.floor(x), math.floor(y))
            gui.Clicker.PosLbl.TextColor3 = THEME.success
        else
            gui.Clicker.PosLbl.Text = "Target: Not set (press " .. tostring(PICK_KEY):gsub("Enum.KeyCode.", "") .. ")"
            gui.Clicker.PosLbl.TextColor3 = THEME.dim
        end
    end

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
            THEME.tp
        end
    end

    local function toggleClicker()
        local x, y = resolvePosition()
        if not x or not y then
            gui.Clicker.PosLbl.Text = "Hover target and press " ..
            tostring(PICK_KEY):gsub("Enum.KeyCode.", "") .. " first"
            gui.Clicker.PosLbl.TextColor3 = THEME.warn
            log("Clicker: No target position set", THEME.warn)
            return
        end
        clicking = not clicking
        if clicking then
            log("Clicker: ON at (" .. math.floor(x) .. ", " .. math.floor(y) .. ") CPS=" .. clickCPS, THEME.success)
        else
            log("Clicker: OFF", THEME.danger)
        end
        updateClickerUI()
    end

    local function applyTheme()
        gui.Main.BackgroundColor3 = THEME.bg
        gui.Header.BackgroundColor3 = THEME.bg2
        gui.HeaderMask.BackgroundColor3 = THEME.bg2
        gui.TabsBar.BackgroundColor3 = THEME.panel
        gui.Content.BackgroundColor3 = THEME.panel
        gui.DragBar.BackgroundColor3 = THEME.accent
        gui.Title.TextColor3 = THEME.text
        gui.Subtitle.TextColor3 = THEME.dim
        gui.MainStroke.Color = THEME.accent:Lerp(Color3.new(1, 1, 1), 0.75)
        gui.ContentStroke.Color = THEME.accent:Lerp(Color3.new(0, 0, 0), 0.45)
        gui.Settings.AccentPreview.BackgroundColor3 = THEME.accent
        gui.Players.SearchBox.BackgroundColor3 = THEME.panel2
        gui.Players.SearchBox.TextColor3 = THEME.text
        gui.Clicker.SliderFill.BackgroundColor3 = THEME.accent

        for name, btn in pairs(gui.TabButtons) do
            if name == activeTab then
                btn.BackgroundColor3 = THEME.accent
                btn.TextColor3 = Color3.new(1, 1, 1)
            else
                btn.BackgroundColor3 = THEME.panel2
                btn.TextColor3 = THEME.dim
            end
        end

        for _, obj in pairs(espObjects) do
            if obj.box then obj.box.Color3 = THEME.accent end
            if obj.billboard and obj.billboard:FindFirstChildOfClass("TextLabel") then
                obj.billboard:FindFirstChildOfClass("TextLabel").TextColor3 = THEME.accent
            end
        end

        for _, obj in pairs(zoneObjects) do
            if obj.highlight then
                obj.highlight.Color3 = THEME.accent
                obj.highlight.SurfaceColor3 = THEME.accent
            end
            if obj.billboard and obj.billboard:FindFirstChildOfClass("TextLabel") then
                obj.billboard:FindFirstChildOfClass("TextLabel").TextColor3 = THEME.accent
            end
        end

        updateClickerUI()
        updateRewardButtons()
    end

    local function switchTab(name)
        activeTab = name
        for tabName, frame in pairs(gui.Tabs) do
            frame.Visible = (tabName == name)
        end
        applyTheme()
    end

    local function beginDrag(input)
        draggingUI = true
        dragStart = input.Position
        startPos = gui.Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                draggingUI = false
            end
        end)
    end

    local function playCloseAnimation()
        task.spawn(function()
            local CloseGui = Instance.new("ScreenGui")
            CloseGui.Name = "LyraHubClose"
            CloseGui.ResetOnSpawn = false
            CloseGui.DisplayOrder = 9999
            pcall(function() CloseGui.Parent = game:GetService("CoreGui") end)
            if not CloseGui.Parent then CloseGui.Parent = lp:WaitForChild("PlayerGui") end

            local CloseFrame = Instance.new("Frame")
            CloseFrame.Size = UDim2.new(0, 620, 0, 420)
            CloseFrame.AnchorPoint = Vector2.new(0.5, 0.5)
            CloseFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
            CloseFrame.BackgroundColor3 = Color3.fromRGB(12, 10, 20)
            CloseFrame.BackgroundTransparency = 1
            CloseFrame.BorderSizePixel = 0
            CloseFrame.ClipsDescendants = true
            CloseFrame.Parent = CloseGui
            Instance.new("UICorner", CloseFrame).CornerRadius = UDim.new(0, 12)
            local CloseStroke = Instance.new("UIStroke", CloseFrame)
            CloseStroke.Color = Color3.fromRGB(110, 60, 200)
            CloseStroke.Thickness = 1

            local CloseText = Instance.new("TextLabel")
            CloseText.Text = "Unloaded. Stay safe."
            CloseText.Size = UDim2.new(0, 400, 0, 40)
            CloseText.AnchorPoint = Vector2.new(0.5, 0.5)
            CloseText.Position = UDim2.new(0.5, 0, 0.5, 0)
            CloseText.BackgroundTransparency = 1
            CloseText.TextColor3 = Color3.fromRGB(180, 130, 255)
            CloseText.Font = Enum.Font.GothamBold
            CloseText.TextSize = 24
            CloseText.TextTransparency = 1
            CloseText.Parent = CloseFrame

            TweenService:Create(CloseFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart),
                { BackgroundTransparency = 0.08 }):Play()
            task.wait(0.15)
            TweenService:Create(CloseText, TweenInfo.new(0.35, Enum.EasingStyle.Quart), { TextTransparency = 0 }):Play()
            task.wait(0.8)
            TweenService:Create(CloseFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                { BackgroundTransparency = 1 }):Play()
            TweenService:Create(CloseText, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                { TextTransparency = 1 }):Play()
            task.wait(0.5)
            CloseGui:Destroy()
        end)
    end

    local function destroyAll()
        log("Script unloading...", THEME.danger)
        clicking = false
        destroyed = true
        autoTPEnabled = false
        autoSellEnabled = false
        autoFishEnabled = false
        autoGachaEnabled = false
        autoClaimDailyRewardEnabled = false
        autoClaimSessionRewardEnabled = false
        antiIdleEnabled = false
        _G.__AhzencalESP_Destroy = nil
        unfreezeCharacter()
        disconnectList(connections)
        disconnectList(zoneAttributeConnections)
        disconnectList(antiIdleConnections)
        for player in pairs(espObjects) do removeESPForPlayer(player) end
        for part in pairs(zoneObjects) do removeZoneESP(part) end
        for player in pairs(beamStates) do stopBeam(player) end
        for _, list in pairs(playerConnections) do disconnectList(list) end
        playCloseAnimation()
        task.wait(0.05)
        pcall(function() gui.MainGui:Destroy() end)
    end

    _G.__AhzencalESP_Destroy = destroyAll

    local SellRemote = nil
    local DailyRewardRemote = nil
    local SessionRewardRemote = nil

    task.spawn(function()
        local rf = ReplicatedStorage:WaitForChild("GameRemoteFunctions", 10)
        if rf then
            SellRemote = rf:WaitForChild("SellAllFishFunction", 10)
            DailyRewardRemote = rf:WaitForChild("CollectDailyRewardFunction", 10)
            SessionRewardRemote = rf:WaitForChild("CollectSessionRewardFunctionEvent", 10)
        end
    end)

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
        local rf = game:GetService("ReplicatedStorage"):FindFirstChild("GameRemoteFunctions")
        if not rf then
            return false, "GameRemoteFunctions folder not found"
        end

        local remote = rf:FindFirstChild("CollectSessionRewardFunctionEvent")
            or rf:FindFirstChild("CollectSessionRewardFunction")
            or rf:FindFirstChild("CollectSessionReward")

        if not remote then
            local names = {}
            for _, child in ipairs(rf:GetChildren()) do
                if string.find(string.lower(child.Name), "session") then
                    table.insert(names, child.Name .. " [" .. child.ClassName .. "]")
                end
            end
            local found = #names > 0 and table.concat(names, ", ") or "none with 'session'"
            return false, "Remote not found. Matches: " .. found
        end

        local claimed = 0
        local skipped = 0
        for slot = 1, 12 do
            local ok, result = pcall(function()
                if remote:IsA("RemoteFunction") then
                    return remote:InvokeServer(slot)
                elseif remote:IsA("RemoteEvent") then
                    remote:FireServer(slot)
                    return "fired"
                end
            end)
            if ok and result then
                claimed = claimed + 1
                log("Session slot " .. slot .. ": claimed", THEME.success)
            else
                skipped = skipped + 1
                log("Session slot " .. slot .. ": on cooldown", THEME.dim)
            end
            task.wait(1)
        end
        if claimed > 0 then
            return true, "Claimed " .. claimed .. "/12 (skipped " .. skipped .. ")"
        end
        return false, "All slots on cooldown (" .. skipped .. "/12)"
    end

    local function performSell()
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            return false, "No HumanoidRootPart found"
        end

        local char = lp.Character
        local isFishing = false
        local rodTool = nil

        if char then
            for _, obj in ipairs(char:GetChildren()) do
                if obj:IsA("Tool") and obj:FindFirstChild("Cast") then
                    rodTool = obj
                    break
                end
            end
        end

        if rodTool then
            local isCasting = rodTool:GetAttribute("IsCasting")
            local baitInWater = rodTool:GetAttribute("BaitLandedInWater")

            if isCasting == true or baitInWater == true then
                isFishing = true
            end
        end

        if isFishing then
            return false, "Cannot sell while casting or bait is in water"
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

        -- Webhook for sell
        if success then
            perfTotalSellValue = perfTotalSellValue + 1
            local soldRarities = table.concat(getActiveSellRarities(), ", ")
            webhookSellAll(tostring(result or "OK"), soldRarities)
            updatePerfMonitor()
        end

        return success, result or err
    end

    bind(gui.FishZone.AutoSellBtn.MouseButton1Click, function()
        autoSellEnabled = not autoSellEnabled
        if autoSellEnabled then
            gui.FishZone.AutoSellBtn.Text = "Auto Sell Fish: ON"
            gui.FishZone.AutoSellBtn.BackgroundColor3 = THEME.success
            log("Auto Sell: ON (interval " .. AUTO_SELL_INTERVAL .. "s)", THEME.success)
            task.spawn(function()
                while autoSellEnabled and not destroyed do
                    if SellRemote then
                        local ok, msg = performSell()
                        log("Auto Sell executed: " .. tostring(msg), ok and THEME.success or THEME.danger)
                    end
                    task.wait(AUTO_SELL_INTERVAL)
                end
            end)
        else
            gui.FishZone.AutoSellBtn.Text = "Auto Sell Fish: OFF"
            gui.FishZone.AutoSellBtn.BackgroundColor3 = THEME.warn
            log("Auto Sell: OFF", THEME.dim)
        end
    end)

    bind(gui.FishZone.SellNowBtn.MouseButton1Click, function()
        log("Sell Now: Attempting TP & sell...", THEME.warn)
        if not SellRemote then
            log("Sell Now: FAILED - remote not loaded", THEME.danger)
            return
        end
        local success, msg = performSell()
        if success then
            log("Sell Now: SUCCESS - " .. tostring(msg), THEME.success)
        else
            log("Sell Now: FAILED - " .. tostring(msg), THEME.danger)
        end
    end)

    if gui.Settings.AutoClaimDailyRewardBtn then
        bind(gui.Settings.AutoClaimDailyRewardBtn.MouseButton1Click, function()
            autoClaimDailyRewardEnabled = not autoClaimDailyRewardEnabled
            updateRewardButtons()
            if autoClaimDailyRewardEnabled then
                log("Daily Reward: Auto-claim ON (every 1h)", THEME.success)
                task.spawn(function()
                    while autoClaimDailyRewardEnabled and not destroyed do
                        local success, message = claimDailyReward()
                        if success then
                            log("Daily Reward: CLAIMED - " .. tostring(message), THEME.success)
                        else
                            log("Daily Reward: " .. tostring(message), THEME.dim)
                        end
                        task.wait(3600)
                    end
                end)
            else
                log("Daily Reward: Auto-claim OFF", THEME.dim)
            end
        end)
    end

    if gui.Settings.AutoClaimSessionRewardBtn then
        bind(gui.Settings.AutoClaimSessionRewardBtn.MouseButton1Click, function()
            autoClaimSessionRewardEnabled = not autoClaimSessionRewardEnabled
            updateRewardButtons()
            if autoClaimSessionRewardEnabled then
                log("Session Reward: Auto-claim ON (every 1h)", THEME.success)
                task.spawn(function()
                    while autoClaimSessionRewardEnabled and not destroyed do
                        local success, message = claimSessionReward()
                        if success then
                            log("Session Reward: " .. tostring(message), THEME.success)
                        else
                            log("Session Reward: " .. tostring(message), THEME.dim)
                        end
                        task.wait(3600)
                    end
                end)
            else
                log("Session Reward: Auto-claim OFF", THEME.dim)
            end
        end)
    end

    -- Anti Idle
    local function enableAntiIdle()
        antiIdleEnabled = true
        local VirtualUser = game:GetService("VirtualUser")
        -- Method 1: disconnect Idled connections (getconnections exploit)
        local success = pcall(function()
            if getconnections then
                for _, connection in pairs(getconnections(lp.Idled)) do
                    if connection["Disable"] then
                        connection["Disable"](connection)
                    elseif connection["Disconnect"] then
                        connection["Disconnect"](connection)
                    end
                end
            end
        end)
        -- Method 2: fallback - reconnect Idled to VirtualUser click
        if not success then
            local c = lp.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            table.insert(antiIdleConnections, c)
        end
        gui.Settings.AntiIdleBtn.Text = "Anti Idle: ON"
        gui.Settings.AntiIdleBtn.BackgroundColor3 = THEME.success
        log("Anti Idle: ON", THEME.success)
    end

    local function disableAntiIdle()
        antiIdleEnabled = false
        for _, c in ipairs(antiIdleConnections) do
            pcall(function() c:Disconnect() end)
        end
        table.clear(antiIdleConnections)
        gui.Settings.AntiIdleBtn.Text = "Anti Idle: OFF"
        gui.Settings.AntiIdleBtn.BackgroundColor3 = THEME.warn
        log("Anti Idle: OFF", THEME.dim)
    end

    if gui.Settings.AntiIdleBtn then
        bind(gui.Settings.AntiIdleBtn.MouseButton1Click, function()
            if antiIdleEnabled then
                disableAntiIdle()
            else
                enableAntiIdle()
            end
        end)
    end

    -- ═══════════════════════════════════════════
    -- WEBHOOK & PERFORMANCE MONITOR
    -- ═══════════════════════════════════════════
    local webhookEnabled = config.Webhook and config.Webhook.Enabled or false
    local webhookURL = config.Webhook and config.Webhook.URL or ""
    local webhookLogRarities = config.Webhook and config.Webhook.LogRarities or {"Ancient"}
    local webhookLogSells = config.Webhook and config.Webhook.LogSells or false

    local perfStartTime = tick()
    local perfRarityCounts = {}
    local perfTotalSellValue = 0
    local perfTotalEarnings = 0

    local function shouldLogRarity(rarity)
        for _, r in ipairs(webhookLogRarities) do
            if string.lower(r) == string.lower(tostring(rarity)) then
                return true
            end
        end
        return false
    end

    local function sendWebhookRaw(payload)
        if not webhookEnabled or webhookURL == "" then return end
        task.spawn(function()
            local ok, err = pcall(function()
                local HttpService = game:GetService("HttpService")
                local data = HttpService:JSONEncode(payload)
                local request = (syn and syn.request) or (http and http.request) or http_request or request
                if request then
                    request({
                        Url = webhookURL,
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = data,
                    })
                end
            end)
            if not ok then
                log("Webhook error: " .. tostring(err), THEME.danger)
            end
        end)
    end

    local function sendWebhook(title, description, color)
        sendWebhookRaw({
            embeds = {{
                title = title,
                description = description,
                color = color or 10181631,
                thumbnail = {url = "https://tr.rbxcdn.com/180DAY-0250e05e2ec3e54faf2791022401a956/150/150/Image/Webp/noFilter"},
                footer = {text = "LyraHub • " .. lp.Name .. " • " .. os.date("%m/%d/%Y %I:%M %p")},
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            }}
        })
    end

    local function webhookFishCaught(fishName, rarity, weight, price)
        if not shouldLogRarity(rarity) then return end
        local priceStr = price and ("Rp." .. tostring(math.floor(tonumber(price) or 0))) or "?"
        local weightStr = weight and (tostring(weight) .. " Kg") or "?"
        local colors = {ancient = 16711680, mythic = 16753920, legend = 16766720, epic = 10494192, secret = 10040115, rare = 3447003}
        local c = colors[string.lower(tostring(rarity))] or 10181631

        sendWebhookRaw({
            embeds = {{
                title = "LyraHub Fish caught!",
                description = "Congrats! **" .. lp.Name .. "** You obtained new **" .. tostring(rarity) .. "** here for full detail fish :",
                color = c,
                thumbnail = {url = "https://tr.rbxcdn.com/180DAY-0250e05e2ec3e54faf2791022401a956/150/150/Image/Webp/noFilter"},
                fields = {
                    {name = "Name Fish :", value = "```" .. tostring(fishName) .. "```", inline = false},
                    {name = "Rarity :", value = "```" .. tostring(rarity) .. "```", inline = false},
                    {name = "Weight :", value = "```" .. weightStr .. "```", inline = false},
                    {name = "Sell Price :", value = "```" .. priceStr .. "```", inline = false},
                },
                footer = {text = "LyraHub • " .. lp.Name .. " • " .. os.date("%m/%d/%Y %I:%M %p")},
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            }}
        })
    end

    local function webhookSellAll(serverResult, soldRarities)
        sendWebhookRaw({
            embeds = {{
                title = "💰 LyraHub Fish Sold!",
                description = "**" .. lp.Name .. "** sold their fish inventory.",
                color = 5763719,
                thumbnail = {url = "https://tr.rbxcdn.com/180DAY-0250e05e2ec3e54faf2791022401a956/150/150/Image/Webp/noFilter"},
                fields = {
                    {name = "Result :", value = "```" .. tostring(serverResult or "OK") .. "```", inline = false},
                    {name = "Rarities Sold :", value = "```" .. tostring(soldRarities or "All") .. "```", inline = false},
                    {name = "Session Earnings :", value = "```Rp." .. tostring(math.floor(perfTotalEarnings)), inline = true},
                    {name = "Total Sells :", value = "```" .. tostring(perfTotalSellValue) .. "```", inline = true},
                },
                footer = {text = "LyraHub • " .. lp.Name .. " • " .. os.date("%m/%d/%Y %I:%M %p")},
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            }}
        })
    end

    local function formatNumber(n)
        n = tonumber(n) or 0
        if n >= 1e12 then return string.format("%.1fT", n / 1e12)
        elseif n >= 1e9 then return string.format("%.1fB", n / 1e9)
        elseif n >= 1e6 then return string.format("%.1fM", n / 1e6)
        elseif n >= 1e3 then return string.format("%.1fK", n / 1e3)
        else return tostring(math.floor(n))
        end
    end

    local function updatePerfMonitor()
        local elapsed = tick() - perfStartTime
        local hours = elapsed / 3600
        local caught = autoFishCaught or 0
        local timeouts = autoFishTimeouts or 0
        local fishPerHour = hours > 0 and math.floor(caught / hours) or 0

        -- Update stat cards
        gui.AutoFish.PerfFishHrVal.Text = tostring(fishPerHour)
        gui.AutoFish.PerfCaughtVal.Text = tostring(caught)
        gui.AutoFish.PerfSellsVal.Text = tostring(perfTotalSellValue)
        gui.AutoFish.PerfEarnVal.Text = formatNumber(perfTotalEarnings)

        -- Rarity breakdown
        local rarityStr = ""
        for rarity, count in pairs(perfRarityCounts) do
            rarityStr = rarityStr .. rarity .. ":" .. count .. "  "
        end
        if rarityStr == "" then rarityStr = "-" end
        gui.AutoFish.PerfRarity.Text = rarityStr
    end

    -- ═══════════════════════════════════════════
    -- SETTINGS SAVE/LOAD (local file persistence)
    -- ═══════════════════════════════════════════
    local SETTINGS_FILE = "LyraHub_Settings.json"

    -- Sell rarity state (which rarities to sell)
    local sellRarities = {}
    for _, r in ipairs(AUTO_SELL_RARITIES) do
        sellRarities[r] = true
    end

    -- Webhook rarity state (which rarities to log)
    local webhookRarityState = {}
    for _, r in ipairs(webhookLogRarities) do
        webhookRarityState[r] = true
    end

    local function getActiveSellRarities()
        local list = {}
        for r, on in pairs(sellRarities) do
            if on then table.insert(list, r) end
        end
        return list
    end

    local function getActiveWebhookRarities()
        local list = {}
        for r, on in pairs(webhookRarityState) do
            if on then table.insert(list, r) end
        end
        return list
    end

    -- Override shouldLogRarity to use dynamic state
    shouldLogRarity = function(rarity)
        return webhookRarityState[tostring(rarity)] == true
    end

    local function updateSellRarityUI()
        for rarity, btn in pairs(gui.Settings.SellRarityButtons) do
            if sellRarities[rarity] then
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

    local function updateWebhookRarityUI()
        for rarity, btn in pairs(gui.Settings.WebhookRarityButtons) do
            if webhookRarityState[rarity] then
                btn.BackgroundColor3 = THEME.accent
                btn.BackgroundTransparency = 0.2
                btn.TextColor3 = Color3.new(1, 1, 1)
            else
                btn.BackgroundColor3 = THEME.panel2
                btn.BackgroundTransparency = 0.6
                btn.TextColor3 = THEME.dim
            end
        end
    end

    -- Bind sell rarity toggles
    for rarity, btn in pairs(gui.Settings.SellRarityButtons) do
        bind(btn.MouseButton1Click, function()
            sellRarities[rarity] = not sellRarities[rarity]
            updateSellRarityUI()
            AUTO_SELL_RARITIES = getActiveSellRarities()
        end)
    end

    -- Bind webhook rarity toggles
    for rarity, btn in pairs(gui.Settings.WebhookRarityButtons) do
        bind(btn.MouseButton1Click, function()
            webhookRarityState[rarity] = not webhookRarityState[rarity]
            updateWebhookRarityUI()
            webhookLogRarities = getActiveWebhookRarities()
        end)
    end

    local function saveSettings()
        local data = {
            webhookURL = webhookURL,
            webhookEnabled = webhookEnabled,
            webhookLogSells = webhookLogSells,
            webhookRarities = getActiveWebhookRarities(),
            sellRarities = getActiveSellRarities(),
        }
        local ok, err = pcall(function()
            local HttpService = game:GetService("HttpService")
            local json = HttpService:JSONEncode(data)
            writefile(SETTINGS_FILE, json)
        end)
        if ok then
            gui.Settings.SaveStatus.Text = "Settings saved!"
            gui.Settings.SaveStatus.TextColor3 = THEME.success
            log("Settings saved", THEME.success)
        else
            gui.Settings.SaveStatus.Text = "Save failed: " .. tostring(err)
            gui.Settings.SaveStatus.TextColor3 = THEME.danger
            log("Settings save failed: " .. tostring(err), THEME.danger)
        end
        task.delay(3, function()
            if gui.Settings.SaveStatus and gui.Settings.SaveStatus.Parent then
                gui.Settings.SaveStatus.Text = ""
            end
        end)
    end

    local function loadSettings()
        local ok, result = pcall(function()
            if isfile and isfile(SETTINGS_FILE) then
                local raw = readfile(SETTINGS_FILE)
                local HttpService = game:GetService("HttpService")
                return HttpService:JSONDecode(raw)
            end
            return nil
        end)
        if ok and result then
            if result.webhookURL then
                webhookURL = result.webhookURL
                gui.Settings.WebhookInput.Text = webhookURL
            end
            if result.webhookEnabled ~= nil then
                webhookEnabled = result.webhookEnabled
            end
            if result.webhookLogSells ~= nil then
                webhookLogSells = result.webhookLogSells
            end
            if result.webhookRarities then
                webhookRarityState = {}
                for _, r in ipairs(result.webhookRarities) do
                    webhookRarityState[r] = true
                end
                webhookLogRarities = result.webhookRarities
            end
            if result.sellRarities then
                sellRarities = {}
                for _, r in ipairs(result.sellRarities) do
                    sellRarities[r] = true
                end
                AUTO_SELL_RARITIES = result.sellRarities
            end
            -- Update UI
            gui.Settings.WebhookToggleBtn.Text = webhookEnabled and "Webhook: ON" or "Webhook: OFF"
            gui.Settings.WebhookToggleBtn.BackgroundColor3 = webhookEnabled and THEME.success or THEME.panel2
            updateSellRarityUI()
            updateWebhookRarityUI()
            log("Settings loaded", THEME.dim)
        end
    end

    -- Webhook toggle button
    bind(gui.Settings.WebhookToggleBtn.MouseButton1Click, function()
        webhookEnabled = not webhookEnabled
        gui.Settings.WebhookToggleBtn.Text = webhookEnabled and "Webhook: ON" or "Webhook: OFF"
        gui.Settings.WebhookToggleBtn.BackgroundColor3 = webhookEnabled and THEME.success or THEME.panel2
        log("Webhook: " .. (webhookEnabled and "ON" or "OFF"), webhookEnabled and THEME.success or THEME.dim)
    end)

    -- Test webhook button
    bind(gui.Settings.WebhookTestBtn.MouseButton1Click, function()
        webhookURL = gui.Settings.WebhookInput.Text
        if webhookURL == "" then
            log("Webhook test: No URL set!", THEME.danger)
            return
        end
        local oldEnabled = webhookEnabled
        webhookEnabled = true
        sendWebhookRaw({
            embeds = {{
                title = "🧪 LyraHub Webhook Test",
                description = "Congrats! **" .. lp.Name .. "** your webhook is working!",
                color = 10181631,
                thumbnail = {url = "https://tr.rbxcdn.com/180DAY-0250e05e2ec3e54faf2791022401a956/150/150/Image/Webp/noFilter"},
                fields = {
                    {name = "Status :", value = "```Connected```", inline = true},
                    {name = "Log Rarities :", value = "```" .. table.concat(getActiveWebhookRarities(), ", ") .. "```", inline = false},
                },
                footer = {text = "LyraHub • " .. lp.Name .. " • " .. os.date("%m/%d/%Y %I:%M %p")},
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            }}
        })
        webhookEnabled = oldEnabled
        log("Webhook test sent!", THEME.success)
    end)

    -- Webhook URL input
    bind(gui.Settings.WebhookInput.FocusLost, function()
        webhookURL = gui.Settings.WebhookInput.Text
    end)

    -- Save settings button
    bind(gui.Settings.SaveSettingsBtn.MouseButton1Click, function()
        webhookURL = gui.Settings.WebhookInput.Text
        saveSettings()
    end)

    -- Auto-load settings on start
    loadSettings()
    updateSellRarityUI()
    updateWebhookRarityUI()

    -- ═══════════════════════════════════════════
    -- AUTO FISH SYSTEM (animation-based, d8nte engine)
    -- ═══════════════════════════════════════════
    local autoFishEnabled = false
    local autoFishCasts = 0
    local autoFishCaught = 0
    local autoFishTimeouts = 0
    local autoFishStage = "Idle"
    local activeAnimConn = nil

    -- Timing config
    local AF_PRE_CAST_DELAY = 0.3
    local AF_CAST_HOLD_MIN = 0.4
    local AF_CAST_HOLD_MAX = 0.6
    local AF_VERIFY_CAST_TIMEOUT = 2.5
    local AF_PULL_TIMEOUT = 20
    local AF_POST_PULL_DELAY = 2.8
    local AF_POST_PULL_TIMEOUT = 5
    local AF_PRE_END_DELAY = 0
    local AF_POST_END_DELAY = 0.3

    -- Animation IDs (IndoVoice fishing game)
    local FISHING_ANIM_ID = "rbxassetid://107858786510758"
    local PULL_ANIM_ID = "rbxassetid://136444937709795"

    local VIM = game:GetService("VirtualInputManager")

    local function getRod()
        local char = lp.Character
        if not char then return nil end
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and (tool:FindFirstChild("Cast") or string.find(string.lower(tool.Name), "rod")) then
                return tool
            end
        end
        return nil
    end

    local function getRodFromBackpack()
        local backpack = lp:FindFirstChildOfClass("Backpack")
        if not backpack then return nil end
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool:FindFirstChild("Cast") or string.find(string.lower(tool.Name), "rod")) then
                return tool
            end
        end
        return nil
    end

    local function equipRod()
        local char = lp.Character
        if not char then return false end
        if getRod() then return true end
        local rod = getRodFromBackpack()
        if rod then
            rod.Parent = char
            log("AutoFish: Equipped " .. rod.Name, THEME.dim)
            task.wait(0.3)
            return true
        end
        return false
    end

    local function reequipRod()
        local char = lp.Character
        if not char then return end
        local current = getRod()
        if current then
            local backpack = lp:FindFirstChildOfClass("Backpack")
            if backpack then
                current.Parent = backpack
            end
        end
        task.wait(0.3)
        equipRod()
    end

    local function afSetStage(stage)
        autoFishStage = stage
        gui.AutoFish.Status.Text = "Status: " .. stage
    end

    local function afTimeout(reason)
        autoFishTimeouts = autoFishTimeouts + 1
        log("AutoFish: Timeout [" .. reason .. "] #" .. autoFishTimeouts, THEME.warn)

        if activeAnimConn then
            activeAnimConn:Disconnect()
            activeAnimConn = nil
        end

        -- Release mouse in case it's held
        pcall(function()
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)

        afSetStage("Re-equipping...")
        task.spawn(reequipRod)
        task.wait(0.5)
    end

    local function autoFishLoop()
        log("AutoFish: Engine started", THEME.success)
        gui.AutoFish.Status.TextColor3 = THEME.success

        while autoFishEnabled and not destroyed do
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if not char or not hum then
                afSetStage("No character")
                task.wait(1)
                continue
            end

            -- Check if moving
            if hum.MoveDirection.Magnitude > 0.1 then
                afSetStage("Moving... waiting")
                task.wait(0.2)
                continue
            end

            -- Ensure rod is equipped
            if not getRod() then
                afSetStage("Equipping rod...")
                if not equipRod() then
                    afSetStage("No rod found!")
                    gui.AutoFish.Status.TextColor3 = THEME.danger
                    log("AutoFish: No rod in character or backpack", THEME.danger)
                    task.wait(2)
                    continue
                end
            end

            -- ── PRE-CAST DELAY ──
            afSetStage("Pre-cast...")
            task.wait(AF_PRE_CAST_DELAY)
            if not autoFishEnabled or destroyed then break end
            if hum.MoveDirection.Magnitude > 0.1 then continue end

            -- ── CASTING (hold mouse) ──
            afSetStage("Casting...")
            pcall(function()
                VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            end)

            local holdDuration = AF_CAST_HOLD_MIN + math.random() * (AF_CAST_HOLD_MAX - AF_CAST_HOLD_MIN)
            local holdElapsed = 0
            while holdElapsed < holdDuration and autoFishEnabled do
                task.wait(0.05)
                holdElapsed = holdElapsed + 0.05
            end

            pcall(function()
                VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)

            if not autoFishEnabled or destroyed then break end

            -- ── VERIFY CAST (detect fishing animation) ──
            afSetStage("Verify Cast...")
            local castVerified = false

            activeAnimConn = hum.AnimationPlayed:Connect(function(track)
                if track.Animation and track.Animation.AnimationId == FISHING_ANIM_ID then
                    castVerified = true
                    if activeAnimConn then activeAnimConn:Disconnect(); activeAnimConn = nil end
                end
            end)

            local verifyStart = tick()
            while not castVerified and (tick() - verifyStart) < AF_VERIFY_CAST_TIMEOUT and autoFishEnabled do
                task.wait(0.05)
            end

            if activeAnimConn then activeAnimConn:Disconnect(); activeAnimConn = nil end

            if not autoFishEnabled or destroyed then break end

            if not castVerified then
                afTimeout("Verify Cast")
                continue
            end

            autoFishCasts = autoFishCasts + 1
            gui.AutoFish.Casts.Text = "Casts: " .. autoFishCasts .. " | Caught: " .. autoFishCaught

            -- ── WAITING FOR PULL (detect pull animation + capture fish data) ──
            afSetStage("Waiting for bite...")
            local pullDetected = false
            local caughtFishData = nil

            activeAnimConn = hum.AnimationPlayed:Connect(function(track)
                if track.Animation and track.Animation.AnimationId == PULL_ANIM_ID then
                    pullDetected = true
                    if activeAnimConn then activeAnimConn:Disconnect(); activeAnimConn = nil end
                end
            end)

            -- Also listen for StartMinigame to capture fish info
            local miniGameConn
            local rod2 = getRod()
            local startMinigame = rod2 and rod2:FindFirstChild("StartMinigame")
            if startMinigame and startMinigame:IsA("RemoteEvent") then
                miniGameConn = startMinigame.OnClientEvent:Connect(function(_, fishInfo)
                    if fishInfo and type(fishInfo) == "table" then
                        caughtFishData = fishInfo
                    end
                end)
            end

            local pullStart = tick()
            while not pullDetected and (tick() - pullStart) < AF_PULL_TIMEOUT and autoFishEnabled do
                task.wait(0.05)
            end

            if activeAnimConn then activeAnimConn:Disconnect(); activeAnimConn = nil end
            if miniGameConn then miniGameConn:Disconnect() end

            if not autoFishEnabled or destroyed then break end

            if not pullDetected then
                afTimeout("Waiting Pull")
                continue
            end

            -- ── POST-PULL DELAY ──
            afSetStage("Fish on! Waiting...")
            local postPullStart = tick()
            while (tick() - postPullStart) < AF_POST_PULL_DELAY and autoFishEnabled do
                if (tick() - postPullStart) > AF_POST_PULL_TIMEOUT then
                    afTimeout("Post Pull Wait")
                    break
                end
                task.wait(0.05)
            end

            if not autoFishEnabled or destroyed then break end
            if autoFishStage == "Re-equipping..." then continue end

            -- ── PRE-END DELAY ──
            if AF_PRE_END_DELAY > 0 then
                task.wait(AF_PRE_END_DELAY)
            end

            -- ── CATCH ──
            afSetStage("Catching!")
            local rod = getRod()
            local catchRemote = rod and rod:FindFirstChild("Catch")

            if catchRemote then
                pcall(function()
                    catchRemote:FireServer(true)
                end)
                autoFishCaught = autoFishCaught + 1
                gui.AutoFish.Casts.Text = "Casts: " .. autoFishCasts .. " | Caught: " .. autoFishCaught

                -- Extract fish info
                local fishName = caughtFishData and caughtFishData.FishName or "Unknown"
                local fishRarity = caughtFishData and caughtFishData.Rarity or "?"
                local fishWeight = caughtFishData and caughtFishData.Weight or nil
                local fishPrice = caughtFishData and caughtFishData.Price or nil

                gui.AutoFish.LastCatch.Text = "Last: " .. fishName .. " [" .. fishRarity .. "]"
                log("AutoFish: Caught " .. fishName .. " (" .. fishRarity .. ")", THEME.success)

                -- Track rarity counts and earnings
                perfRarityCounts[fishRarity] = (perfRarityCounts[fishRarity] or 0) + 1
                if fishPrice and tonumber(fishPrice) then
                    perfTotalEarnings = perfTotalEarnings + tonumber(fishPrice)
                end

                -- Send webhook if rarity qualifies
                webhookFishCaught(fishName, fishRarity, fishWeight, fishPrice)

                -- Update performance monitor
                updatePerfMonitor()
            else
                log("AutoFish: Catch remote not found", THEME.danger)
                afTimeout("Catch")
                continue
            end

            -- ── END: destroy fishing UI ──
            afSetStage("Cleaning up...")
            pcall(function()
                local playerGui = lp:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, g in pairs(playerGui:GetChildren()) do
                        if g:IsA("ScreenGui") and g:FindFirstChild("FishingHolder", true) then
                            g:Destroy()
                            break
                        end
                    end
                end
            end)

            -- ── POST-END DELAY ──
            afSetStage("Resetting...")
            task.wait(AF_POST_END_DELAY)
        end

        afSetStage("Idle")
        gui.AutoFish.Status.TextColor3 = THEME.dim
        log("AutoFish: Stopped", THEME.dim)

        -- Release mouse just in case
        pcall(function()
            VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
    end

    bind(gui.AutoFish.ToggleBtn.MouseButton1Click, function()
        autoFishEnabled = not autoFishEnabled
        if autoFishEnabled then
            gui.AutoFish.ToggleBtn.Text = "Auto Fish: ON"
            gui.AutoFish.ToggleBtn.BackgroundColor3 = THEME.success
            task.spawn(autoFishLoop)
        else
            gui.AutoFish.ToggleBtn.Text = "Auto Fish: OFF"
            gui.AutoFish.ToggleBtn.BackgroundColor3 = THEME.accent
            -- Release mouse
            pcall(function()
                VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end)
            if activeAnimConn then
                activeAnimConn:Disconnect()
                activeAnimConn = nil
            end
        end
    end)

    -- ═══════════════════════════════════════════
    -- AUTO GACHA SYSTEM
    -- ═══════════════════════════════════════════
    local autoGachaEnabled = false
    local autoGachaRolls = 0
    local gachaStopRarities = {}

    -- Stop rarity toggle buttons
    for rarity, btn in pairs(gui.Gacha.StopButtons) do
        bind(btn.MouseButton1Click, function()
            gachaStopRarities[rarity] = not gachaStopRarities[rarity]
            if gachaStopRarities[rarity] then
                btn.BackgroundColor3 = THEME.success
                btn.BackgroundTransparency = 0.2
                btn.TextColor3 = Color3.new(1, 1, 1)
            else
                btn.BackgroundColor3 = THEME.panel2
                btn.BackgroundTransparency = 0.6
                btn.TextColor3 = THEME.dim
            end
        end)
    end

    local function autoGachaLoop()
        log("AutoGacha: Started", THEME.success)
        gui.Gacha.Status.Text = "Status: Running | Rolls: 0"
        gui.Gacha.Status.TextColor3 = THEME.success

        local BlindBoxRoll = game:GetService("ReplicatedStorage"):FindFirstChild("GameRemoteFunctions")
        BlindBoxRoll = BlindBoxRoll and BlindBoxRoll:FindFirstChild("BlindBoxRollFunctionEvent")

        local BlindBoxComplete = game:GetService("ReplicatedStorage"):FindFirstChild("GameRemoteEvents")
        BlindBoxComplete = BlindBoxComplete and BlindBoxComplete:FindFirstChild("BlindBoxRollCompletedEventEvent")

        if not BlindBoxRoll then
            gui.Gacha.Status.Text = "Status: Roll remote not found!"
            gui.Gacha.Status.TextColor3 = THEME.danger
            log("AutoGacha: BlindBoxRollFunctionEvent not found", THEME.danger)
            autoGachaEnabled = false
            gui.Gacha.ToggleBtn.Text = "Auto Gacha: OFF"
            gui.Gacha.ToggleBtn.BackgroundColor3 = THEME.accent
            return
        end

        while autoGachaEnabled and not destroyed do
            local category = gui.Gacha.CategoryInput.Text
            local boxName = gui.Gacha.BoxInput.Text

            if category == "" or boxName == "" then
                gui.Gacha.Status.Text = "Status: Set Box & Type first!"
                gui.Gacha.Status.TextColor3 = THEME.warn
                task.wait(2)
                continue
            end

            -- Roll 10x
            gui.Gacha.Status.Text = "Status: Rolling 10x..."
            local rollOk, rollResult = pcall(function()
                return BlindBoxRoll:InvokeServer(category, boxName, 10)
            end)

            if not rollOk then
                gui.Gacha.Status.Text = "Status: Roll failed!"
                gui.Gacha.Status.TextColor3 = THEME.danger
                log("AutoGacha: Roll error - " .. tostring(rollResult), THEME.danger)
                task.wait(3)
                continue
            end

            autoGachaRolls = autoGachaRolls + 10
            gui.Gacha.Status.Text = "Status: Running | Rolls: " .. autoGachaRolls

            -- Fire completion event for each result
            -- The server may return rarity info — check if we got a stop rarity
            local gotStopRarity = false
            local lastRarity = "?"

            -- rollResult might be a table of results or a single value
            if type(rollResult) == "table" then
                for _, item in ipairs(rollResult) do
                    local r = type(item) == "table" and (item.Rarity or item.rarity) or tostring(item)
                    lastRarity = tostring(r)
                    if gachaStopRarities[lastRarity] then
                        gotStopRarity = true
                    end
                end
            elseif type(rollResult) == "string" then
                lastRarity = rollResult
                if gachaStopRarities[lastRarity] then
                    gotStopRarity = true
                end
            end

            -- Fire BlindBoxRollCompleted for each (if it exists)
            if BlindBoxComplete then
                pcall(function()
                    BlindBoxComplete:FireServer(lastRarity)
                end)
            end

            gui.Gacha.LastResult.Text = "Last: " .. lastRarity .. " (roll #" .. autoGachaRolls .. ")"
            log("AutoGacha: Roll #" .. autoGachaRolls .. " → " .. lastRarity, THEME.dim)

            -- Check stop condition
            if gotStopRarity then
                gui.Gacha.Status.Text = "Status: STOPPED! Got " .. lastRarity .. "!"
                gui.Gacha.Status.TextColor3 = THEME.success
                log("AutoGacha: STOPPED - obtained " .. lastRarity .. " after " .. autoGachaRolls .. " rolls!", THEME.success)
                autoGachaEnabled = false
                gui.Gacha.ToggleBtn.Text = "Auto Gacha: OFF"
                gui.Gacha.ToggleBtn.BackgroundColor3 = THEME.accent

                -- Send webhook
                sendWebhookRaw({
                    embeds = {{
                        title = "🎰 Gacha Target Obtained!",
                        description = "**" .. lp.Name .. "** hit the jackpot!",
                        color = 16766720,
                        thumbnail = {url = "https://tr.rbxcdn.com/180DAY-0250e05e2ec3e54faf2791022401a956/150/150/Image/Webp/noFilter"},
                        fields = {
                            {name = "Rarity :", value = "```" .. lastRarity .. "```", inline = true},
                            {name = "Total Rolls :", value = "```" .. tostring(autoGachaRolls) .. "```", inline = true},
                            {name = "Box :", value = "```" .. category .. " / " .. boxName .. "```", inline = false},
                        },
                        footer = {text = "LyraHub • " .. lp.Name .. " • " .. os.date("%m/%d/%Y %I:%M %p")},
                        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                    }}
                })
                break
            end

            -- Delay between rolls
            task.wait(1.5)
        end

        if autoGachaEnabled then
            gui.Gacha.Status.Text = "Status: Idle | Rolls: " .. autoGachaRolls
            gui.Gacha.Status.TextColor3 = THEME.dim
        end
    end

    bind(gui.Gacha.ToggleBtn.MouseButton1Click, function()
        autoGachaEnabled = not autoGachaEnabled
        if autoGachaEnabled then
            gui.Gacha.ToggleBtn.Text = "Auto Gacha: ON"
            gui.Gacha.ToggleBtn.BackgroundColor3 = THEME.success
            task.spawn(autoGachaLoop)
        else
            gui.Gacha.ToggleBtn.Text = "Auto Gacha: OFF"
            gui.Gacha.ToggleBtn.BackgroundColor3 = THEME.accent
            gui.Gacha.Status.Text = "Status: Stopped | Rolls: " .. autoGachaRolls
            gui.Gacha.Status.TextColor3 = THEME.dim
        end
    end)

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
        log("FishZone ESP: " .. (zoneESPOn and "ON" or "OFF"), zoneESPOn and THEME.success or THEME.dim)
    end)

    bind(gui.FishZone.AutoTPBtn.MouseButton1Click, function()
        if autoTPEnabled then
            stopAutoTP()
            log("Auto TP: OFF", THEME.danger)
        else
            startAutoTP()
            moveToNearestActiveZone()
            log("Auto TP: ON - searching for active zone", THEME.success)
        end
    end)

    bind(gui.FishZone.RefreshCharBtn.MouseButton1Click, function()
        gui.FishZone.RefreshCharBtn.Text = "Refreshing..."
        refreshCharacterAdonis()
        log("Refresh character sent (Adonis)", THEME.warn)
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
            (i.Position.X - gui.Clicker.SliderTrack.AbsolutePosition.X) / gui.Clicker.SliderTrack.AbsoluteSize.X, 0, 1)
            clickCPS = math.max(1, math.floor(ratio * 100))
            clickDelay = 1 / clickCPS
            gui.Clicker.SliderFill.Size = UDim2.new(ratio, 0, 1, 0)
            gui.Clicker.SliderKnob.Position = UDim2.new(ratio, -8, 0.5, -8)
            gui.Clicker.CPSLbl.Text = "CPS: " .. clickCPS
        end
    end)

    bind(gui.Settings.UnloadBtn.MouseButton1Click, destroyAll)
    bind(gui.CloseBtn.MouseButton1Click, destroyAll)

    bind(gui.MinBtn.MouseButton1Click, function()
        minimized = true
        gui.Main.Visible = false
        gui.MinimizedOrb.Visible = true
    end)

    bind(gui.MinimizedOrb.MouseButton1Click, function()
        minimized = false
        gui.Main.Visible = true
        gui.MinimizedOrb.Visible = false
    end)

    bind(gui.DragHit.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            beginDrag(input)
        end
    end)

    bind(UserInputService.InputChanged, function(input)
        if draggingUI and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            gui.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale,
                startPos.Y.Offset + delta.Y)
        end
    end)

    bind(UserInputService.InputBegan, function(input, gp)
        if gp or destroyed then return end
        if input.KeyCode == TOGGLE_KEY then toggleClicker() end
        if input.KeyCode == PICK_KEY then
            savedX = mouse.X
            savedY = mouse.Y
            updateClickerUI()
        end
        if input.KeyCode == HIDE_KEY then
            hideUI = not hideUI
            if hideUI then
                gui.Main.Visible = false
                gui.MinimizedOrb.Visible = false
            else
                if minimized then
                    gui.MinimizedOrb.Visible = true
                else
                    gui.Main.Visible = true
                end
            end
        end
    end)

    for i, btn in ipairs(gui.Settings.ColorButtons) do
        bind(btn.MouseButton1Click, function()
            THEME.accent = config.ThemePresets[i]
            applyTheme()
            refreshZoneESP()
            updateRewardButtons()
        end)
    end

    for name, btn in pairs(gui.TabButtons) do
        bind(btn.MouseButton1Click, function()
            switchTab(name)
        end)
    end

    -- Periodic performance monitor update
    local lastPerfUpdate = 0
    bind(RunService.Heartbeat, function()
        if destroyed then return end

        -- Update perf monitor every 10s
        local now = tick()
        if now - lastPerfUpdate > 10 then
            lastPerfUpdate = now
            if autoFishEnabled then
                updatePerfMonitor()
            end
        end

        if clicking then
            if now - lastClick >= clickDelay then
                lastClick = now
                local x, y = resolvePosition()
                if x and y then silentClick(x, y) end
            end
        end

        if autoTPEnabled then
            local hrp = getHRP(lp.Character)
            local insideActive, insidePart = isInsideAnyActiveZone(hrp)
            local currentStillActive = isActiveZone(currentZone)

            if not currentStillActive then
                moveToNearestActiveZone()
            elseif not insideActive then
                moveToNearestActiveZone()
            elseif currentZone ~= insidePart then
                tpToZone(insidePart)
            elseif frozenAnchor and frozenAnchor.Parent then
                frozenAnchor.Position = currentZone.Position + Vector3.new(0, currentZone.Size.Y / 2 + FLOAT_HEIGHT, 0)
            end

            if currentZone and isActiveZone(currentZone) then
                gui.FishZone.ZoneStatus.Text = "Locked: " .. currentZone.Name .. " [ACTIVE]"
                gui.FishZone.ZoneStatus.TextColor3 = THEME.success
            else
                local nearest = nearestActiveZonePart()
                gui.FishZone.ZoneStatus.Text = nearest and ("Searching → " .. nearest.Name) or "No active zone"
                gui.FishZone.ZoneStatus.TextColor3 = nearest and THEME.warn or THEME.danger
            end
        else
            local nearest = nearestActiveZonePart()
            if nearest then
                gui.FishZone.ZoneStatus.Text = "Nearest active zone: " .. nearest.Name
                gui.FishZone.ZoneStatus.TextColor3 = THEME.text
            else
                gui.FishZone.ZoneStatus.Text = "No active zone"
                gui.FishZone.ZoneStatus.TextColor3 = THEME.danger
            end
        end
    end)

    switchTab("Players")
    updateClickerUI()
    updateRewardButtons()
    refreshPlayerRows()
    refreshZoneESP()
    applyTheme()

    -- Startup logs
    log("LyraHub initialized", THEME.accentGlow)
    log("Player: " .. lp.Name, THEME.text)
    log("Clicker mode: " .. (useVIM and "Silent (VIM)" or "Fallback"), useVIM and THEME.success or THEME.warn)
    log("Active zones found: " .. #getActiveZoneParts(), THEME.dim)
    log("Press K to hide/show UI", THEME.dim)
end
