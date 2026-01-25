-- Minimal Matcha-Safe Drawing UI Framework

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Mouse = game.Players.LocalPlayer:GetMouse()

local UI = {}
UI.__index = UI

-- Create a window
function UI:Window(opts)
    local self = setmetatable({}, UI)

    self.Title = opts.Title or "Window"
    self.Size = opts.Size or Vector2.new(300, 200)
    self.Position = Vector2.new(200, 200)
    self.Dragging = false
    self.DragOffset = Vector2.new()
    self.Elements = {}

    -- Background
    self.Base = Drawing.new("Square")
    self.Base.Filled = true
    self.Base.Color = Color3.fromRGB(25, 25, 25)
    self.Base.Size = self.Size
    self.Base.Position = self.Position
    self.Base.Visible = true

    -- Title
    self.TitleText = Drawing.new("Text")
    self.TitleText.Text = self.Title
    self.TitleText.Size = 18
    self.TitleText.Color = Color3.fromRGB(255, 255, 255)
    self.TitleText.Position = self.Position + Vector2.new(5, 5)
    self.TitleText.Visible = true

    -- Dragging logic
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mx, my = Mouse.X, Mouse.Y
            if mx >= self.Position.X and mx <= self.Position.X + self.Size.X and my >= self.Position.Y and my <= self.Position.Y + 25 then
                self.Dragging = true
                self.DragOffset = Vector2.new(mx, my) - self.Position
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if self.Dragging then
            self.Position = Vector2.new(Mouse.X, Mouse.Y) - self.DragOffset
            self.Base.Position = self.Position
            self.TitleText.Position = self.Position + Vector2.new(5, 5)

            -- Update all child elements
            for _, element in ipairs(self.Elements) do
                element:UpdatePosition(self.Position)
            end
        end
    end)

    return self
end

-- Checkbox widget
function UI:Checkbox(label, default, callback)
    local index = #self.Elements
    local yOffset = 35 + (index * 25)

    local checkbox = {}
    checkbox.State = default or false
    checkbox.Parent = self

    checkbox.Box = Drawing.new("Square")
    checkbox.Box.Filled = true
    checkbox.Box.Size = Vector2.new(15, 15)
    checkbox.Box.Color = checkbox.State and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 60)
    checkbox.Box.Position = self.Position + Vector2.new(10, yOffset)
    checkbox.Box.Visible = true

    checkbox.Text = Drawing.new("Text")
    checkbox.Text.Text = label
    checkbox.Text.Size = 16
    checkbox.Text.Color = Color3.fromRGB(255, 255, 255)
    checkbox.Text.Position = self.Position + Vector2.new(30, yOffset - 2)
    checkbox.Text.Visible = true

    function checkbox:UpdatePosition(basePos)
        local y = 35 + (index * 25)
        self.Box.Position = basePos + Vector2.new(10, y)
        self.Text.Position = basePos + Vector2.new(30, y - 2)
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mx, my = Mouse.X, Mouse.Y
            local pos = checkbox.Box.Position

            if mx >= pos.X and mx <= pos.X + 15 and my >= pos.Y and my <= pos.Y + 15 then
                checkbox.State = not checkbox.State
                checkbox.Box.Color = checkbox.State and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 60)
                callback(checkbox.State)
            end
        end
    end)

    table.insert(self.Elements, checkbox)
end

return UI
