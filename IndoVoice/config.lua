-- IndoVoice/config.lua
-- Config table only (NOT a function wrapper)

return {
    Keys = {
        ToggleClicker = Enum.KeyCode.F,
        HideUI = Enum.KeyCode.K,
        PickPosition = Enum.KeyCode.P,
    },

    Clicker = {
        DefaultCPS = 20,
        PositionMode = "pick",
        FixedX = nil,
        FixedY = nil,
    },

    FishZone = {
        Path = workspace:WaitForChild("Main"):WaitForChild("FishingZone"),
        FloatHeight = 15,
        BlacklistThreshold = 2,
        BlacklistedPositions = {
            Vector3.new(-198, 16.5000153, -5079),
            Vector3.new(-629.866821, 19.5, 4640.11377),
        },
    },

    Theme = {
        accent = Color3.fromRGB(0, 170, 255),
        bg = Color3.fromRGB(14, 17, 25),
        bg2 = Color3.fromRGB(20, 24, 34),
        panel = Color3.fromRGB(25, 30, 43),
        panel2 = Color3.fromRGB(31, 37, 52),
        text = Color3.fromRGB(235, 240, 255),
        dim = Color3.fromRGB(140, 152, 175),
        success = Color3.fromRGB(67, 214, 125),
        danger = Color3.fromRGB(255, 92, 117),
        warn = Color3.fromRGB(255, 191, 71),
        tp = Color3.fromRGB(132, 97, 255),
        beam = Color3.fromRGB(255, 120, 84),
    },

    ThemePresets = {
        Color3.fromRGB(0,170,255),
        Color3.fromRGB(132,97,255),
        Color3.fromRGB(255,96,140),
        Color3.fromRGB(67,214,125),
        Color3.fromRGB(255,170,0),
        Color3.fromRGB(255,120,84),
    },

    AutoSell = {
        Interval = 60, -- Seconds between sell attempts (prevents server kick for spamming)
    },
}
