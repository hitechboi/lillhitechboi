local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/hitechboi/lillhitechboi/main/ui.lua"))()

getgenv().NoRecoilEnabled = false
getgenv().RecoilStrength = 10
getgenv().RecoilKey = "F"

local window = UI:Window({
    Title = "Massacre",
    Size = Vector2.new(350, 260)
})

local tweaks = window:Tab("Tweaks")
local binds = window:Tab("Keybinds")

-- Checkbox
UI:Checkbox(tweaks, "No Recoil", false, function(state)
    getgenv().NoRecoilEnabled = state
end)

-- Slider
UI:Slider(tweaks, "Recoil Strength", 0, 100, 10, function(val)
    getgenv().RecoilStrength = val
end)

-- Keybind
UI:Keybind(binds, "Recoil Toggle", "F", function(key)
    getgenv().RecoilKey = key
end)
