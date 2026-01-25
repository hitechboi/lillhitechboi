local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/hitechboi/lillhitechboi/main/Ui.lua"))()

getgenv().NoRecoilEnabled = false

local window = UI:Window({
    Title = "Massacre",
    Size = Vector2.new(300, 200)
})

window:Checkbox("No Recoil", false, function(state)
    getgenv().NoRecoilEnabled = state
end)
