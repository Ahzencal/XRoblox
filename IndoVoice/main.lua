-- IndoVoice/main.lua
-- Shared loader, same file for both staging and main

return function(BASE_URL)
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

    local configChunk = compile(fetch(BASE_URL .. "config.lua", "config.lua"), "config.lua")
    local guiChunk = compile(fetch(BASE_URL .. "gui.lua", "gui.lua"), "gui.lua")
    local coreChunk = compile(fetch(BASE_URL .. "core.lua", "core.lua"), "core.lua")

    local config = configChunk()
    local guiFactory = guiChunk()
    local coreFactory = coreChunk()

    assert(type(config) == "table", "config.lua must return a table")
    assert(type(guiFactory) == "function", "gui.lua must return a function")
    assert(type(coreFactory) == "function", "core.lua must return a function")

    local gui = guiFactory(config)
    coreFactory(gui, config)
end
