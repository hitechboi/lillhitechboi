-- Decompiled game.ReplicatedStorage.Modules.Main.VSRG

local v_u_1 = game:GetService("UserInputService")
local v_u_2 = game:GetService("ReplicatedStorage")
local v_u_3 = game:GetService("RunService")
local v_u_4 = game:GetService("Players").LocalPlayer
local v_u_5 = v_u_4:FindFirstChildOfClass("PlayerGui")
local v_u_6 = require(v_u_2:WaitForChild("Modules"):WaitForChild("Main"):WaitForChild("VSRG"):WaitForChild("Game"))
require(v_u_2.Modules.Main.VSRG.Beatmap)
local v_u_7 = require(v_u_2.Modules.Main.VSRG.Game.KeyHandler)
local v_u_8 = require(v_u_2.Modules.Main.VSRG.Game.ObjectTypes.NoteAnimation)
local v_u_9 = require(v_u_2.Modules.FrameRate)
local v_u_10 = {}
v_u_10.__index = v_u_10
function v_u_10.new()
    -- upvalues: (copy) v_u_10, (copy) v_u_5, (copy) v_u_2, (copy) v_u_8
    local v11 = v_u_10
    local v12 = setmetatable({}, v11)
    local v13 = Instance.new("ScreenGui")
    v13.Name = "VSRG"
    v13.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    v13.Parent = v_u_5
    local v14 = Instance.new("UIScale")
    v14.Parent = v13
    v14.Scale = 1
    local v15 = Instance.new("UIPadding")
    v15.Parent = v13
    v15.PaddingTop = UDim.new(-0.2, 0)
    v15.PaddingBottom = UDim.new(0.1, 0)
    local v16 = Instance.new("UIListLayout")
    v16.Name = "Layout"
    v16.FillDirection = Enum.FillDirection.Horizontal
    v16.HorizontalAlignment = Enum.HorizontalAlignment.Center
    v16.SortOrder = Enum.SortOrder.LayoutOrder
    v16.Parent = v13
    v16.Padding = UDim.new(0, 6)
    v12._gui = v13
    local v17 = v_u_2.Track.TrackMode4:Clone()
    v17.Parent = workspace.ActiveTrack
    v17:ScaleTo(0.1)
    v12._track = v17
    local v18 = v_u_2.Display:Clone()
    v18.Parent = workspace
    v18:ScaleTo(2)
    v12._display = v18
    v12._replsound = v_u_2.Configuration.SelectedSound
    v_u_8.initialize(v12)
    return v12
end
function v_u_10.Play(p_u_19, p20)
    -- upvalues: (copy) v_u_6, (copy) v_u_4, (copy) v_u_2, (copy) v_u_3, (copy) v_u_9, (copy) v_u_7, (copy) v_u_1, (copy) v_u_5
    p_u_19._game = v_u_6.new(p_u_19._gui, p20)
    local v_u_21 = p_u_19._game:GetSound()
    local v_u_22 = p20.InitialBeatLength / 1000
    local v_u_23 = 2 + tick()
    local v_u_24 = -2
    v_u_4:SetAttribute("Playing", true)
    if v_u_2.Configuration.GuiMode.Value then
        p_u_19._track:Destroy()
    end
    p_u_19._renderHook = v_u_3.RenderStepped:ConnectParallel(function()
        -- upvalues: (copy) v_u_21, (ref) v_u_24, (copy) p_u_19, (copy) v_u_23, (copy) v_u_22
        if v_u_21.IsPlaying then
            v_u_24 = v_u_21.TimePosition
        elseif p_u_19._game then
            v_u_24 = tick() - v_u_23 - v_u_21:GetAttribute("PauseDuration")
            if v_u_24 >= v_u_21.TimeLength + 0.5 and not p_u_19._game._submitted then
                p_u_19._game._submitted = true
                p_u_19:Submit()
                return
            end
        end
        if p_u_19._game then
            p_u_19._game:Render(v_u_24, v_u_22)
        else
            p_u_19:Quit()
        end
    end)
    task.delay(2, function()
        -- upvalues: (ref) v_u_9, (copy) v_u_21
        v_u_9.GameAverage = {}
        v_u_21:Play()
    end)
    local v25 = p_u_19._display.TrackSong.SurfaceGui
    v25.DifficultyLabel.Text = p_u_19._replsound:GetAttribute("Difficulty")
    v25.TitleLabel.Text = p_u_19._replsound:GetAttribute("Title")
    v25.TimeLabel.Text = p_u_19._replsound:GetAttribute("Length")
    for _, v26 in p_u_19._track:GetDescendants() do
        if v26:IsA("TextLabel") and v26.Name == "KeyLabel" then
            local v27 = v26.Parent.Parent.Name
            local v28 = tonumber(v27:sub(-1))
            local v29 = v_u_7.KeyConfigurations[v_u_7.currentMode][v28]
            v26.Text = tostring(v29) or "Unknown"
            v26.TextSize = 100
            v26.TextTransparency = 0.3
        end
    end
    if v_u_1.TouchEnabled then
        v_u_5.KeyTouchGui.Enabled = true
    end
end
function v_u_10.Submit(p30)
    -- upvalues: (copy) v_u_5, (copy) v_u_2
    task.synchronize()
    task.wait()
    v_u_5.KeyTouchGui.Enabled = false
    require(v_u_2.Modules.RemoteService).FinalizeScoreResult(p30._game.scoreHandler)
    task.wait()
    p30:Quit()
end
function v_u_10.Quit(p31)
    -- upvalues: (copy) v_u_5, (copy) v_u_8, (copy) v_u_7, (copy) v_u_4
    task.synchronize()
    if p31._renderHook then
        p31._renderHook:Disconnect()
        p31._renderHook = nil
    end
    if p31._game then
        p31._game:GetSound():Destroy()
        p31._game = nil
    end
    p31._track:ScaleTo(0.1)
    p31._display:ScaleTo(2)
    p31._replsound.SoundId = ""
    v_u_5.KeyTouchGui.Enabled = false
    v_u_8.clearDisplay(p31._display)
    v_u_7.heldKey = {}
    v_u_4:SetAttribute("Playing", false)
end
return v_u_10
