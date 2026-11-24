local environment = getgenv and getgenv() or _G

local baseUrl = environment.HubBaseUrl or ("https:" .. string.rep("/", 2) .. "raw.githubusercontent.com/geounsmero-cmd/Script-Blox-Fruitd/main/")

local function fetch(fileName)
    local source = game:HttpGet(baseUrl .. fileName)
    local chunk, problem = loadstring(source)
    if not chunk then
        error(problem)
    end
    return chunk()
end

local Library = fetch("UI.lua")
local Core = fetch("Core.lua")

local window = Library.new("Hub")
Core(window)
