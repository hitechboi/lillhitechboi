loadstring(game:HttpGet("https://raw.githubusercontent.com/hitechboi/lillhitechboi/main/Ui.txt"))()

getgenv().NoRecoilEnabled = false

local window = UI:Window({
    Title = "Massacre",
    Size = Vector2.new(600, 450),
    Open = true
})

local tweaks = window:Tab({ Title = "Tweaks" })

local recoilSection = tweaks:Section({ Title = "Recoil Control" })

recoilSection:Checkbox({ Title = "No Recoil", Default = false }, function(state)
    getgenv().NoRecoilEnabled = state
end)
