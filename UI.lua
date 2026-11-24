local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local Theme = {
    Background = Color3.fromHex("0D0D12"),
    Card = Color3.fromHex("16161E"),
    Accent = Color3.fromHex("7C3AED"),
    AccentDark = Color3.fromHex("4C1D95"),
    Text = Color3.fromHex("FFFFFF")
}

local FontRegular = Enum.Font.GothamMedium
local FontBold = Enum.Font.GothamBold

local Library = {}
Library.__index = Library

local Tab = {}
Tab.__index = Tab

local function newInstance(className, properties)
    local instance = Instance.new(className)
    local parent = properties.Parent
    properties.Parent = nil
    for key, value in pairs(properties) do
        instance[key] = value
    end
    instance.Parent = parent
    return instance
end

local function addCorner(instance, radius)
    return newInstance("UICorner", {
        CornerRadius = UDim.new(0, radius),
        Parent = instance
    })
end

local function addStroke(instance, color, thickness)
    return newInstance("UIStroke", {
        Color = color,
        Thickness = thickness,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = instance
    })
end

local function createLabel(parent, text, size, position)
    return newInstance("TextLabel", {
        Parent = parent,
        BackgroundTransparency = 1,
        Size = size,
        Position = position,
        Text = text,
        Font = FontRegular,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    })
end

local function createRow(page, height)
    local frame = newInstance("Frame", {
        Parent = page,
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0
    })
    addCorner(frame, 8)
    addStroke(frame, Theme.AccentDark, 1)
    return frame
end

local function pulse(button)
    button.BackgroundColor3 = Theme.AccentDark
    TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
end

local function resolveParent()
    if typeof(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and typeof(result) == "Instance" then
            return result
        end
    end
    local probe = Instance.new("Folder")
    local parented = pcall(function()
        probe.Parent = CoreGui
    end)
    probe:Destroy()
    if parented then
        return CoreGui
    end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function makeDraggable(handle, target, connections, onTap)
    local dragging = false
    local moved = false
    local origin = Vector2.zero
    local startPosition = target.Position
    local activeInput = nil

    table.insert(connections, handle.InputBegan:Connect(function(input)
        local kind = input.UserInputType
        if kind == Enum.UserInputType.MouseButton1 or kind == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            activeInput = input
            origin = Vector2.new(input.Position.X, input.Position.Y)
            startPosition = target.Position
        end
    end))

    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        local kind = input.UserInputType
        if kind == Enum.UserInputType.MouseMovement or (kind == Enum.UserInputType.Touch and input == activeInput) then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - origin
            if delta.Magnitude > 6 then
                moved = true
            end
            if moved then
                target.Position = UDim2.new(
                    startPosition.X.Scale,
                    startPosition.X.Offset + delta.X,
                    startPosition.Y.Scale,
                    startPosition.Y.Offset + delta.Y
                )
            end
        end
    end))

    table.insert(connections, UserInputService.InputEnded:Connect(function(input)
        if dragging and (input == activeInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
            dragging = false
            if not moved and onTap then
                onTap()
            end
        end
    end))
end

function Library.new(title)
    local self = setmetatable({}, Library)
    self.Connections = {}
    self.Tabs = {}
    self.ActiveTab = nil

    local parent = resolveParent()
    local existing = parent:FindFirstChild("HubInterface")
    if existing then
        existing:Destroy()
    end

    local gui = newInstance("ScreenGui", {
        Name = "HubInterface",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999
    })
    pcall(function()
        if syn and syn.protect_gui then
            syn.protect_gui(gui)
        end
    end)
    gui.Parent = parent
    self.Gui = gui

    local camera = Workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(800, 600)
    local width = math.clamp(viewport.X - 40, 300, 500)
    local height = math.clamp(viewport.Y - 60, 220, 330)
    local sidebarWidth = width < 380 and 92 or 120

    local main = newInstance("Frame", {
        Name = "Main",
        Parent = gui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0
    })
    addCorner(main, 10)
    addStroke(main, Theme.Accent, 2)
    self.Main = main

    local topBar = newInstance("Frame", {
        Name = "TopBar",
        Parent = main,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0
    })
    addCorner(topBar, 10)
    newInstance("Frame", {
        Parent = topBar,
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 10),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0
    })

    newInstance("TextLabel", {
        Parent = topBar,
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -56, 1, 0),
        Text = title or "Hub",
        Font = FontBold,
        TextSize = 15,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    })

    local minimize = newInstance("TextButton", {
        Parent = topBar,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -6, 0.5, 0),
        Size = UDim2.fromOffset(28, 24),
        BackgroundColor3 = Theme.AccentDark,
        Text = "-",
        Font = FontBold,
        TextSize = 18,
        TextColor3 = Theme.Text,
        AutoButtonColor = false,
        BorderSizePixel = 0
    })
    addCorner(minimize, 6)
    table.insert(self.Connections, minimize.MouseButton1Click:Connect(function()
        self:Toggle()
    end))

    local body = newInstance("Frame", {
        Parent = main,
        Position = UDim2.fromOffset(0, 36),
        Size = UDim2.new(1, 0, 1, -36),
        BackgroundTransparency = 1
    })

    local sidebar = newInstance("Frame", {
        Parent = body,
        Size = UDim2.new(0, sidebarWidth, 1, -8),
        Position = UDim2.fromOffset(6, 4),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0
    })
    addCorner(sidebar, 8)
    addStroke(sidebar, Theme.AccentDark, 1)

    local tabList = newInstance("ScrollingFrame", {
        Parent = sidebar,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })
    newInstance("UIListLayout", {
        Parent = tabList,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    newInstance("UIPadding", {
        Parent = tabList,
        PaddingTop = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5)
    })
    self.TabList = tabList

    self.Content = newInstance("Frame", {
        Parent = body,
        Position = UDim2.fromOffset(sidebarWidth + 12, 4),
        Size = UDim2.new(1, -(sidebarWidth + 18), 1, -8),
        BackgroundColor3 = Theme.Card,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    addCorner(self.Content, 8)
    addStroke(self.Content, Theme.AccentDark, 1)

    local hub = newInstance("TextButton", {
        Name = "Hub",
        Parent = gui,
        Size = UDim2.fromOffset(52, 52),
        Position = UDim2.new(0, 14, 0.5, -26),
        BackgroundColor3 = Theme.Accent,
        Text = "HUB",
        Font = FontBold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        AutoButtonColor = false,
        BorderSizePixel = 0
    })
    addCorner(hub, 26)
    addStroke(hub, Theme.AccentDark, 2)
    self.HubButton = hub

    makeDraggable(topBar, main, self.Connections, nil)
    makeDraggable(hub, hub, self.Connections, function()
        self:Toggle()
    end)

    return self
end

function Library:Toggle()
    self.Main.Visible = not self.Main.Visible
end

function Library:SetVisible(value)
    self.Main.Visible = value
end

function Library:Destroy()
    for _, connection in ipairs(self.Connections) do
        connection:Disconnect()
    end
    self.Gui:Destroy()
end

function Library:SelectTab(tab)
    for _, other in ipairs(self.Tabs) do
        local active = other == tab
        other.Page.Visible = active
        other.Indicator.Visible = active
        TweenService:Create(other.Button, TweenInfo.new(0.15), {
            BackgroundTransparency = active and 0 or 1
        }):Play()
    end
    self.ActiveTab = tab
end

function Library:AddTab(name)
    local tab = setmetatable({}, Tab)
    tab.Library = self

    tab.Button = newInstance("TextButton", {
        Parent = self.TabList,
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundColor3 = Theme.AccentDark,
        BackgroundTransparency = 1,
        Text = name,
        Font = FontBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        LayoutOrder = #self.Tabs + 1
    })
    addCorner(tab.Button, 6)

    tab.Indicator = newInstance("Frame", {
        Parent = tab.Button,
        Position = UDim2.new(0, 2, 0.2, 0),
        Size = UDim2.new(0, 3, 0.6, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Visible = false
    })
    addCorner(tab.Indicator, 2)

    tab.Page = newInstance("ScrollingFrame", {
        Parent = self.Content,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    })
    newInstance("UIListLayout", {
        Parent = tab.Page,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    newInstance("UIPadding", {
        Parent = tab.Page,
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 8)
    })

    table.insert(self.Tabs, tab)
    table.insert(self.Connections, tab.Button.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end))

    if #self.Tabs == 1 then
        self:SelectTab(tab)
    end

    return tab
end

function Tab:AddSection(text)
    local label = newInstance("TextLabel", {
        Parent = self.Page,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        Font = FontBold,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    newInstance("Frame", {
        Parent = label,
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0
    })
    return label
end

function Tab:AddLabel(text)
    local frame = createRow(self.Page, 30)
    local label = createLabel(frame, text, UDim2.new(1, -20, 1, 0), UDim2.fromOffset(10, 0))
    local object = {Instance = label}
    function object:Set(value)
        label.Text = value
    end
    return object
end

function Tab:AddButton(text, callback)
    local button = newInstance("TextButton", {
        Parent = self.Page,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Accent,
        Text = text,
        Font = FontBold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        AutoButtonColor = false,
        BorderSizePixel = 0
    })
    addCorner(button, 8)
    addStroke(button, Theme.AccentDark, 1.5)
    button.MouseButton1Click:Connect(function()
        pulse(button)
        if callback then
            task.spawn(callback)
        end
    end)
    local object = {Instance = button}
    function object:SetText(value)
        button.Text = value
    end
    return object
end

function Tab:AddToggle(text, default, callback)
    local frame = createRow(self.Page, 38)
    createLabel(frame, text, UDim2.new(1, -70, 1, 0), UDim2.fromOffset(10, 0))

    local track = newInstance("TextButton", {
        Parent = frame,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(42, 22),
        BackgroundColor3 = Theme.AccentDark,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0
    })
    addCorner(track, 11)

    local knob = newInstance("Frame", {
        Parent = track,
        Position = UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0
    })
    addCorner(knob, 8)

    local object = {Value = default and true or false}

    local function render()
        TweenService:Create(track, TweenInfo.new(0.15), {
            BackgroundColor3 = object.Value and Theme.Accent or Theme.AccentDark
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.15), {
            Position = object.Value and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3)
        }):Play()
    end

    function object:Set(value, silent)
        self.Value = value and true or false
        render()
        if not silent and callback then
            task.spawn(callback, self.Value)
        end
    end

    function object:Get()
        return self.Value
    end

    track.MouseButton1Click:Connect(function()
        object:Set(not object.Value)
    end)

    render()
    return object
end

function Tab:AddTextbox(text, placeholder, default, callback)
    local frame = createRow(self.Page, 38)
    createLabel(frame, text, UDim2.new(0.5, -10, 1, 0), UDim2.fromOffset(10, 0))

    local box = newInstance("TextBox", {
        Parent = frame,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0.45, 0, 0, 26),
        BackgroundColor3 = Theme.Background,
        Text = default or "",
        PlaceholderText = placeholder or "",
        PlaceholderColor3 = Theme.Text:Lerp(Theme.Background, 0.55),
        Font = FontRegular,
        TextSize = 13,
        TextColor3 = Theme.Text,
        ClearTextOnFocus = false,
        BorderSizePixel = 0
    })
    addCorner(box, 6)
    addStroke(box, Theme.Accent, 1)

    box.FocusLost:Connect(function(enterPressed)
        if callback then
            task.spawn(callback, box.Text, enterPressed)
        end
    end)

    local object = {Instance = box}
    function object:Get()
        return box.Text
    end
    function object:Set(value)
        box.Text = value
    end
    return object
end

function Tab:AddCycle(text, options, default, callback)
    local frame = createRow(self.Page, 38)
    createLabel(frame, text, UDim2.new(0.5, -10, 1, 0), UDim2.fromOffset(10, 0))

    local button = newInstance("TextButton", {
        Parent = frame,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0.45, 0, 0, 26),
        BackgroundColor3 = Theme.Accent,
        Font = FontBold,
        TextSize = 12,
        TextColor3 = Theme.Text,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Text = ""
    })
    addCorner(button, 6)

    local index = table.find(options, default) or 1
    button.Text = options[index]

    local object = {}
    function object:Get()
        return options[index]
    end
    function object:Set(value)
        local found = table.find(options, value)
        if found then
            index = found
            button.Text = value
        end
    end

    button.MouseButton1Click:Connect(function()
        index = index % #options + 1
        button.Text = options[index]
        pulse(button)
        if callback then
            task.spawn(callback, options[index])
        end
    end)

    return object
end

return Library
