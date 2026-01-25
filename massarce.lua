loadstring(game:HttpGet("https://github.com/zee-7654/UI/blob/main/UI.lua"))()

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
