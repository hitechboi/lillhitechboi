local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function GetMouse()
    local pos = UserInputService:GetMouseLocation()
    return pos.X, pos.Y
end

local UI = {}
UI.__index = UI

function UI:Window(opts)
    local self = setmetatable({}, UI)
    self.Title = opts.Title or "Window"
    self.Size = opts.Size or Vector2.new(350, 260)
    self.Position = Vector2.new(200, 200)
    self.Dragging = false
    self.DragOffset = Vector2.new()
    self.Elements = {}

    self.Base = Drawing.new("Square")
    self.Base.Filled = true
    self.Base.Color = Color3.fromRGB(25, 25, 25)
    self.Base.Size = self.Size
    self.Base.Position = self.Position
    self.Base.Visible = true

    self.TitleText = Drawing.new("Text")
    self.TitleText.Text = self.Title
    self.TitleText.Size = 18
    self.TitleText.Color = Color3.fromRGB(255, 255, 255)
    self.TitleText.Position = self.Position + Vector2.new(5, 5)
    self.TitleText.Visible = true

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mx, my = GetMouse()
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
            local mx, my = GetMouse()
            self.Position = Vector2.new(mx, my) - self.DragOffset
            self.Base.Position = self.Position
            self.TitleText.Position = self.Position + Vector2.new(5, 5)
            for _, e in ipairs(self.Elements) do
                if e.Update then e:Update(self.Position) end
            end
        end
    end)

    return self
end

function UI:Checkbox(label, default, callback)
    local i = #self.Elements
    local y = 40 + i * 25
    local e = {}

    e.Box = Drawing.new("Square")
    e.Box.Filled = true
    e.Box.Size = Vector2.new(15, 15)
    e.Box.Color = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 60)
    e.Box.Position = self.Position + Vector2.new(20, y)
    e.Box.Visible = true

    e.Text = Drawing.new("Text")
    e.Text.Text = label
    e.Text.Size = 16
    e.Text.Color = Color3.fromRGB(255, 255, 255)
    e.Text.Position = self.Position + Vector2.new(45, y - 2)
    e.Text.Visible = true

    function e:Update(base)
        local y = 40 + i * 25
        e.Box.Position = base + Vector2.new(20, y)
        e.Text.Position = base + Vector2.new(45, y - 2)
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mx, my = GetMouse()
            local pos = e.Box.Position
            if mx >= pos.X and mx <= pos.X + 15 and my >= pos.Y and my <= pos.Y + 15 then
                default = not default
                e.Box.Color = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 60)
                callback(default)
            end
        end
    end)

    table.insert(self.Elements, e)
end

function UI:Slider(label, min, max, default, callback)
    local i = #self.Elements
    local y = 40 + i * 40
    local e = {}
    local value = default
    local dragging = false

    e.Bar = Drawing.new("Square")
    e.Bar.Filled = true
    e.Bar.Size = Vector2.new(150, 6)
    e.Bar.Color = Color3.fromRGB(60, 60, 60)
    e.Bar.Position = self.Position + Vector2.new(20, y)
    e.Bar.Visible = true

    e.Fill = Drawing.new("Square")
    e.Fill.Filled = true
    e.Fill.Size = Vector2.new((value - min) / (max - min) * 150, 6)
    e.Fill.Color = Color3.fromRGB(0, 200, 255)
    e.Fill.Position = e.Bar.Position
    e.Fill.Visible = true

    e.Text = Drawing.new("Text")
    e.Text.Text = label .. ": " .. tostring(value)
    e.Text.Size = 16
    e.Text.Color = Color3.fromRGB(255, 255, 255)
    e.Text.Position = self.Position + Vector2.new(20, y - 20)
    e.Text.Visible = true

    function e:Update(base)
        local y = 40 + i * 40
        e.Bar.Position = base + Vector2.new(20, y)
        e.Fill.Position = e.Bar.Position
        e.Text.Position = base + Vector2.new(20, y - 20)
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mx, my = GetMouse()
            local pos = e.Bar.Position
            if mx >= pos.X and mx <= pos.X + 150 and my >= pos.Y and my <= pos.Y + 6 then
                dragging = true
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging then
            local mx = GetMouse()
            local pos = e.Bar.Position
            local pct = math.clamp((mx - pos.X) / 150, 0, 1)
            value = math.floor(min + pct * (max - min))
            e.Fill.Size = Vector2.new(pct * 150, 6)
            e.Text.Text = label .. ": " .. tostring(value)
            callback(value)
        end
    end)

    table.insert(self.Elements, e)
end

function UI:Keybind(label, defaultKey, callback)
    local i = #self.Elements
    local y = 40 + i * 30
    local e = {}
    local key = defaultKey
    local waiting = false

    e.Text = Drawing.new("Text")
    e.Text.Text = label .. ": [" .. key .. "]"
    e.Text.Size = 16
    e.Text.Color = Color3.fromRGB(255, 255, 255)
    e.Text.Position = self.Position + Vector2.new(20, y)
    e.Text.Visible = true

    function e:Update(base)
        local y = 40 + i * 30
        e.Text.Position = base + Vector2.new(20, y)
    end

    UserInputService.InputBegan:Connect(function(input)
        local mx, my = GetMouse()
        local pos = e.Text.Position
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if mx >= pos.X and mx <= pos.X + 200 and my >= pos.Y and my <= pos.Y + 20 then
                waiting = true
                e.Text.Text = label .. ": [...]"
            end
        elseif waiting and input.KeyCode ~= Enum.KeyCode.Unknown then
            key = input.KeyCode.Name
            e.Text.Text = label .. ": [" .. key .. "]"
            waiting = false
            callback(key)
        end
    end)

    table.insert(self.Elements, e)
end

return UI
