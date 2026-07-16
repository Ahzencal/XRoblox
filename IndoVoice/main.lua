-- IndoVoice/main.lua
-- Shared loader, same file for both staging and main

local BASE_URL = ...

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

local function deepClone(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = deepClone(v)
    end
    return copy
end

local function loadModule(name)
    return compile(fetch(BASE_URL .. "modules/" .. name .. ".lua", name), name)
end

local configChunk = compile(fetch(BASE_URL .. "config.lua", "config.lua"), "config.lua")
local config = deepClone(configChunk())
assert(type(config) == "table", "config.lua must return a table")

-- Password gate (blocks until authenticated)
local gateChunk = compile(fetch(BASE_URL .. "gate.lua", "gate.lua"), "gate.lua")
local gateFactory = gateChunk()
assert(type(gateFactory) == "function", "gate.lua must return a function")
gateFactory(config)

-- Load main UI after authentication
local guiChunk = compile(fetch(BASE_URL .. "gui.lua", "gui.lua"), "gui.lua")
local coreChunk = compile(fetch(BASE_URL .. "core.lua", "core.lua"), "core.lua")
local guiFactory = guiChunk()
local coreFactory = coreChunk()

if type(guiFactory) ~= "function" then
    warn("[IndoVoice] gui.lua returned: " .. type(guiFactory) .. " (expected function)")
    return
end
if type(coreFactory) ~= "function" then
    warn("[IndoVoice] core.lua returned: " .. type(coreFactory) .. " (expected function)")
    return
end

local guiOk, gui = pcall(guiFactory, config)
if not guiOk then
    warn("[IndoVoice] gui.lua failed: " .. tostring(gui))
    return
end

local coreOk, ctx = pcall(coreFactory, gui, config)
if not coreOk then
    warn("[IndoVoice] core.lua failed: " .. tostring(ctx))
    return
end

-- Load modules
local modules = {"fishing", "mining", "gacha", "shopgacha", "rodshop", "ui"}
for _, name in ipairs(modules) do
    local ok, err = pcall(function()
        local modChunk = loadModule(name)
        local modFactory = modChunk()
        if type(modFactory) == "function" then
            modFactory(ctx)
        else
            warn("[IndoVoice] Module '" .. name .. "' did not return a function, got: " .. type(modFactory))
        end
    end)
    if not ok then
        warn("[IndoVoice] Failed to load module '" .. name .. "': " .. tostring(err))
    end
end
