--// MATCHA-SAFE DRAWING UI FRAMEWORK (Tabs, Sliders, Keybinds)

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local function GetMouse()
    local pos = UserInputService:GetMouseLocation()
    return pos.X, pos.Y
end

local UI = {}
UI.__index = UI

-- WINDOW ---------------------------------------------------------
function UI:Window(opts)
    local self = setmetatable({}, UI)

    self.Title = opts.Title or "Window"
    self.Size = opts.Size or Vector2.new(350, 260)
    self.Position = Vector2.new(200, 200)
    self.Dragging = false
    self.DragOffset = Vector2.new()
    self.Tabs = {}
    self.ActiveTab = nil

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

    -- Dragging
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mx, my = GetMouse()
            if mx >= self.Position.X and mx <= self.Position.X + self.Size.X
            and my >= self.Position.Y and my <= self.Position.Y + 25 then
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

            for _, tab in pairs(self.Tabs) do
                tab:UpdatePositions(self.Position)
            end
        end
    end)

    return self
end

-- TAB ------------------------------------------------------------
function UI:Tab(name)
    local tab = {}
    tab.Name = name
    tab.Parent = self
    tab.Elements = {}
    tab.Index = #self.Tabs
    tab.Active = false

    -- Tab button
    tab.Button = Drawing.new("Text")
    tab.Button.Text = name
    tab.Button.Size = 16
    tab.Button.Color = Color3.fromRGB(200, 200, 200)
    tab.Button.Position = self.Position + Vector2.new(10 + (tab.Index * 80), 30)
    tab.Button.Visible = true

    function tab:SetActive(state)
        tab.Active = state
        tab.Button.Color = state and Color3.fromRGB(0, 200, 255) or Color3.fromRGB(200, 200, 200)

        for _, element in ipairs(tab.Elements) do
            element:SetVisible(state)
        end
    end

    function tab:UpdatePositions(basePos)
        tab.Button.Position = basePos + Vector2.new(10 + (tab.Index * 80), 30)

        for _, element in ipairs(tab.Elements) do
            if element.UpdatePosition then
                element:UpdatePosition(basePos)
            end
        end
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mx, my = GetMouse()
            local pos = tab.Button.Position

            if mx >= pos.X and mx <= pos.X + 70 and my >= pos.Y and my <= pos.Y + 20 then
                for _, t in pairs(self.Tabs) do
                    t:SetActive(false)
                end
                tab:SetActive(true)
                self.ActiveTab = tab
            end
        end
    end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        tab:SetActive(true)
        self.ActiveTab = tab
    end

    return tab
end

-- CHECKBOX -------------------------------------------------------
function UI:Checkbox(tab, label, default, callback)
    local element = {}
    element.Type = "Checkbox"
    element.State = default or false
    element.Parent = tab

    local index = #tab.Elements
    local yOffset = 60 + (index * 25)

    element.Box = Drawing.new("Square")
    element.Box.Filled = true
    element.Box.Size = Vector2.new(15, 15)
    element.Box.Color = element.State and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 60)
    element.Box.Position = tab.Parent.Position + Vector2.new(20, yOffset)
    element.Box.Visible = tab.Active

    element.Text = Drawing.new("Text")
    element.Text.Text = label
    element.Text.Size = 16
    element.Text.Color = Color3.fromRGB(255, 255, 255)
    element.Text.Position = tab.Parent.Position + Vector2.new(45, yOffset - 2)
    element.Text.Visible = tab.Active

    function element:SetVisible(v)
        element.Box.Visible = v
        element.Text.Visible = v
    end

    function element:UpdatePosition(basePos)
        local y = 60 + (index * 25)
        element.Box.Position = basePos + Vector2.new(20, y)
        element.Text.Position = basePos + Vector2.new(45, y - 2)
    end

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and tab.Active then
            local mx, my = GetMouse()
            local pos = element.Box.Position

            if mx >= pos.X and mx <= pos.X + 15 and my >= pos.Y and my <= pos.Y + 15 then
                element.State = not element.State
                element.Box.Color = element.State and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 60)
                callback(element.State)
            end
        end
    end)

    table.insert(tab.Elements, element)
end

-- SLIDER ---------------------------------------------------------
function UI:Slider(tab, label, min, max, default, callback)
    local element = {}
    element.Type = "Slider"
    element.Value = default or min
    element.Parent = tab

    local index = #tab.Elements
    local yOffset = 60 + (index * 40)

    element.Bar = Drawing.new("Square")
    element.Bar.Filled = true
    element.Bar.Color = Color3.fromRGB(60, 60, 60)
    element.Bar.Size = Vector2.new(150, 6)
    element.Bar.Position = tab.Parent.Position + Vector2.new(20, yOffset)
    element.Bar.Visible = tab.Active

    element.Fill = Drawing.new("Square")
    element.Fill.Filled = true
    element.Fill.Color = Color3.fromRGB(0, 200, 255)
    element.Fill.Size = Vector2.new((element.Value - min) / (max - min) * 150, 6)
    element.Fill.Position = element.Bar.Position
    element.Fill.Visible = tab.Active

    element.Text = Drawing.new("Text")
    element.Text.Text = label .. ": " .. tostring(element.Value)
    element.Text.Size = 16
    element.Text.Color = Color3.fromRGB(255, 255, 255)
    element.Text.Position = tab.Parent.Position + Vector2.new(20, yOffset - 20)
    element.Text.Visible = tab.Active

    function element:SetVisible(v)
        element.Bar.Visible = v
        element.Fill.Visible = v
        element.Text.Visible = v
    end

    function element:UpdatePosition(basePos)
        local y = 60 + (index * 40)
        element.Bar.Position = basePos + Vector2.new(20, y)
        element.Fill.Position = element.Bar.Position
        element.Text.Position = basePos + Vector2.new(20, y - 20)
    end

    local dragging = false

    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and tab.Active then
            local mx, my = GetMouse()
            local pos = element.Bar.Position

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
        if dragging and tab.Active then
            local mx = GetMouse()
            local pos = element.Bar.Position

            local pct = math.clamp((mx - pos.X) / 150, 0, 1)
            element.Value = math.floor(min + pct * (max - min))

            element.Fill.Size = Vector2.new(pct * 150, 6)
            element.Text.Text = label .. ": " .. tostring(element.Value)

            callback(element.Value)
        end
    end)

    table.insert(tab.Elements, element)
end

-- KEYBIND --------------------------------------------------------
function UI:Keybind(tab, label, defaultKey, callback)
    local element = {}
    element.Type = "Keybind"
    element.Key = defaultKey
    element.Parent = tab
    element.Waiting = false

    local index = #tab.Elements
    local yOffset = 60 + (index * 30)

    element.Text = Drawing.new("Text")
    element.Text.Text = label .. ": [" .. defaultKey .. "]"
    element.Text.Size = 16
    element.Text.Color = Color3.fromRGB(255, 255, 255)
    element.Text.Position = tab.Parent.Position + Vector2.new(20, yOffset)
    element.Text.Visible = tab.Active

    function element:SetVisible(v)
        element.Text.Visible = v
    end

    function element:UpdatePosition(basePos)
        local y = 60 + (index * 30)
        element.Text.Position = basePos + Vector2.new(20, y)
    end

    UserInputService.InputBegan:Connect(function(input)
        if not tab.Active then return end

        local mx, my = GetMouse()
        local pos = element.Text.Position

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if mx >= pos.X and mx <= pos.X + 200 and my >= pos.Y and my <= pos.Y + 20 then
                element.Waiting = true
                element.Text.Text = label .. ": [...]"
            end
        end

        if element.Waiting and input.KeyCode ~= Enum.KeyCode.Unknown then
            element.Key = input.KeyCode.Name
            element.Text.Text = label .. ": [" .. element.Key .. "]"
            element.Waiting = false
            callback(element.Key)
        end
    end)

    table.insert(tab.Elements, element)
end

return UI
