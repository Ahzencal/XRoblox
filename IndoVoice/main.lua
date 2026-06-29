-- IndoVoice/main.lua
-- Safer single-loader with clearer line errors

local BASE_URL = "https://raw.githubusercontent.com/Ahzencal/XRoblox/main/IndoVoice/"

local function fetch(url, name)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or not result or result == "404: Not Found" or result == "Not Found" then
        error("Failed to fetch " .. tostring(name) .. " from " .. tostring(url))
    end
    return result
end

local function compile(source, name)
    local fn, err = loadstring(source)
    if not fn then
        error("Failed to compile " .. tostring(name) .. ": " .. tostring(err))
    end
    return fn
end

local configSource = fetch(BASE_URL .. "config.lua", "config.lua")
local guiSource = fetch(BASE_URL .. "gui.lua", "gui.lua")
local coreSource = fetch(BASE_URL .. "core.lua", "core.lua")

local configFactory = compile(configSource, "config.lua")
local guiFactory = compile(guiSource, "gui.lua")
local coreFactory = compile(coreSource, "core.lua")

local config = configFactory()
local gui = guiFactory(config)
coreFactory()(gui, config)