--// UI + Recoil Toggle
getgenv().NoRecoilEnabled = false

-- Create UI
local gui = Instance.new("ScreenGui")
gui.Name = "MyScriptUI"
gui.ResetOnSpawn = false
gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 160)
frame.Position = UDim2.new(0.5, -130, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "My Script - Tweaks"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = frame

local checkbox = Instance.new("TextButton")
checkbox.Size = UDim2.new(0, 20, 0, 20)
checkbox.Position = UDim2.new(0, 15, 0, 50)
checkbox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
checkbox.Text = ""
checkbox.BorderSizePixel = 0
checkbox.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 200, 0, 20)
label.Position = UDim2.new(0, 45, 0, 50)
label.BackgroundTransparency = 1
label.Text = "No Recoil"
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.Gotham
label.TextSize = 14
label.Parent = frame

local check = Instance.new("TextLabel")
check.Size = UDim2.new(1, 0, 1, 0)
check.BackgroundTransparency = 1
check.Text = ""
check.TextColor3 = Color3.fromRGB(0, 255, 0)
check.Font = Enum.Font.GothamBold
check.TextSize = 18
check.Parent = checkbox

local toggled = false
checkbox.MouseButton1Click:Connect(function()
    toggled = not toggled
    check.Text = toggled and "✓" or ""
    getgenv().NoRecoilEnabled = toggled
end)

--// Recoil Module
local Recoil = {}

function Recoil.AddRecoil(_, recoilParams)
    if getgenv().NoRecoilEnabled then return end

    local xMin = recoilParams.xMin or 0
    local xMax = recoilParams.xMax or 0
    local yMin = recoilParams.yMin or 0
    local yMax = recoilParams.yMax or 0

    local recoilX = math.random(xMin * 100, xMax * 100) / 100
    local recoilY = math.random(yMin * 100, yMax * 100) / 100

    local cam = workspace.CurrentCamera
    if cam then
        cam.CFrame = cam.CFrame * CFrame.Angles(recoilX, recoilY, 0)
    end
end

-- Optional: expose globally
getgenv().Recoil = Recoil
