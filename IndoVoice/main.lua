-- FishZone/main.lua
-- Entry loader for raw GitHub split version with config.lua

local BASE_URL = "https://raw.githubusercontent.com/Ahzencal/XRoblox/main/IndoVoice/"

local function fetch(url)
    return game:HttpGet(url)
end

local configSource = fetch(BASE_URL .. "config.lua")
local guiSource = fetch(BASE_URL .. "gui.lua")
local coreSource = fetch(BASE_URL .. "core.lua")

local configFactory = loadstring(configSource)
local guiFactory = loadstring(guiSource)
local coreFactory = loadstring(coreSource)

assert(configFactory, "Failed to load config.lua")
assert(guiFactory, "Failed to load gui.lua")
assert(coreFactory, "Failed to load core.lua")

local config = configFactory()
local gui = guiFactory(config)
coreFactory()(gui, config)
