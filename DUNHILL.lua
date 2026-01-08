--[[
    ╔══════════════════════════════════════╗
    ║      DUNHILL UI LIBRARY v2.0         ║
    ║   Modern UI for Roblox Executors     ║
    ║       MOBILE FIXED VERSION           ║
    ╚══════════════════════════════════════╝
]]

local Dunhill = {}
Dunhill.Version = "2.0.3"
Dunhill.Flags = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- ✅ FIX: Tunggu LocalPlayer dengan cara yang lebih reliable
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    LocalPlayer = Players:WaitForChild("LocalPlayer", 3)
end

-- Jika masih nil, tunggu dengan repeat
if not LocalPlayer then
    repeat
        LocalPlayer = Players.LocalPlayer
        task.wait(0.1)
    until LocalPlayer
end

local DunhillFolder = "DunhillUI"
local ConfigurationExtension = ".dhl"

-- ✅ CHLOE X COLOR SCHEME
local Theme = {
    -- Backgrounds (Lebih gelap seperti Chloe X)
    Background = Color3.fromRGB(12, 14, 16),
    BackgroundSecondary = Color3.fromRGB(18, 20, 23),
    TopBar = Color3.fromRGB(15, 17, 20),
    
    -- Sidebar
    Sidebar = Color3.fromRGB(20, 22, 25),
    SidebarHover = Color3.fromRGB(28, 31, 35),
    SidebarSelected = Color3.fromRGB(180, 190, 200),
    
    -- Primary Colors (Cyan seperti Chloe X)
    Primary = Color3.fromRGB(210, 220, 230),
    Secondary = Color3.fromRGB(150, 160, 170),
    Accent = Color3.fromRGB(200, 210, 220),
    
    -- Element Backgrounds
    ElementBg = Color3.fromRGB(22, 25, 28),
    ElementBgHover = Color3.fromRGB(28, 32, 36),
    ElementBorder = Color3.fromRGB(40, 45, 50),

    -- Element Content (Untuk section items - Abu-abu seperti sebelumnya)
    ElementContentBg = Color3.fromRGB(65, 70, 80),
    ElementContentHover = Color3.fromRGB(75, 80, 90),
    
    -- Tab Colors
    TabActive = Color3.fromRGB(35, 40, 45),
    TabInactive = Color3.fromRGB(20, 22, 25),

    -- Text Colors (Lebih kontras)
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(160, 170, 180),
    TextDark = Color3.fromRGB(15, 15, 15),
    
    -- Status Colors
    Success = Color3.fromRGB(80, 200, 120),
    Warning = Color3.fromRGB(255, 180, 0),
    Error = Color3.fromRGB(240, 80, 80),
    Info = Color3.fromRGB(100, 180, 255),
    
    -- Toggle Colors (Cyan untuk ON seperti Chloe X)
    ToggleOn = Color3.fromRGB(100, 200, 255),  -- Cyan terang
    ToggleOff = Color3.fromRGB(50, 55, 60),
    
    -- Slider Colors
    SliderFill = Color3.fromRGB(100, 200, 255),  -- Cyan
    SliderBg = Color3.fromRGB(30, 35, 40),
    
    -- Border Cyan (Signature Chloe X)
    BorderBlue = Color3.fromRGB(100, 200, 255),  -- Cyan terang
}

local function Tween(obj, props, duration, style, direction)
    duration = duration or 0.25
    style = style or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(duration, style, direction), props):Play()
end

-- ✅ FIXED: Dragging sekarang support touch input
local function MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateInput(input)
        end
    end)
end

function Dunhill:CreateWindow(config)
    config = config or {}
    local WindowName = config.Name or "Dunhill"
    local LoadConfigurationOnStart = config.LoadConfigurationOnStart
    if LoadConfigurationOnStart == nil then LoadConfigurationOnStart = true end
    local ConfigurationSaving = {
        Enabled = config.ConfigurationSaving and config.ConfigurationSaving.Enabled or false,
        FolderName = config.ConfigurationSaving and config.ConfigurationSaving.FolderName or WindowName,
        FileName = config.ConfigurationSaving and config.ConfigurationSaving.FileName or "config"
    }
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DunhillUI_" .. math.random(1000, 9999)
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
-- ✅ FIX: Parent detection yang lebih aman
local success, parent = pcall(function()
    if gethui then
        return gethui()
    elseif syn and syn.protect_gui then
        local gui = Instance.new("ScreenGui")
        syn.protect_gui(gui)
        return gui.Parent or CoreGui
    else
        return CoreGui
    end
end)

if success and parent then
    ScreenGui.Parent = parent
else
    if LocalPlayer then
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            ScreenGui.Parent = playerGui
        else
            ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5) or CoreGui
        end
    else
        ScreenGui.Parent = CoreGui
    end
end
    
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 500, 0, 290)
    Main.Position = UDim2.new(0.5, -250, 0.5, -175)
    Main.BackgroundColor3 = Theme.Background
    Main.BackgroundTransparency = 0.15  -- ✅ Sedikit transparan
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui


    -- ✅ Border biru dihapus sesuai permintaan user
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    
    local Shadow = Instance.new("ImageLabel", Main)
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.Position = UDim2.new(0, -20, 0, -20)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.4
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.ZIndex = -1
    
    local TopBar = Instance.new("Frame", Main)
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Theme.Background
    TopBar.BackgroundTransparency = 0.7
    TopBar.BorderSizePixel = 0
    
    local TopBarCorner = Instance.new("UICorner", TopBar)
    TopBarCorner.CornerRadius = UDim.new(0, 10)
    
    local TopBarExtend = Instance.new("Frame", TopBar)
    TopBarExtend.Size = UDim2.new(1, 0, 0, 10)
    TopBarExtend.Position = UDim2.new(0, 0, 1, -10)
    TopBarExtend.BackgroundColor3 = Theme.Background  
    TopBarExtend.BackgroundTransparency = 0.7
    TopBarExtend.BorderSizePixel = 0
    
    local Title = Instance.new("ImageLabel", TopBar)
    Title.Size = UDim2.new(0, 30, 0, 30)  -- Ukuran logo
    Title.Position = UDim2.new(0, 15, 0.5, -15)  -- Posisi kiri atas
    Title.BackgroundTransparency = 1
    Title.Image = "rbxassetid://90636797161481"  -- Logo Mach kamu (sama kayak minimize icon)
    Title.ScaleType = Enum.ScaleType.Fit
    Title.ImageTransparency = 0

    local TitleText = Instance.new("TextLabel", TopBar)
    TitleText.Size = UDim2.new(0, 150, 1, 0)
    TitleText.Position = UDim2.new(0, 60, 0, 0)  -- Di sebelah kanan logo
    TitleText.BackgroundTransparency = 1
    TitleText.Text = WindowName
    TitleText.TextColor3 = Theme.BorderBlue
    TitleText.TextSize = 17
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseBtn = Instance.new("ImageButton", TopBar)
    CloseBtn.Size = UDim2.new(0, 35, 0, 35)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -17.5)
    CloseBtn.BackgroundTransparency = 1  -- ✅ Transparan, tanpa background
    CloseBtn.Image = "rbxassetid://97946818577230"
    CloseBtn.ScaleType = Enum.ScaleType.Fit
    CloseBtn.AutoButtonColor = false
    CloseBtn.BorderSizePixel = 0
    
    local MinBtn = Instance.new("TextButton", TopBar)
    MinBtn.Size = UDim2.new(0, 35, 0, 35)
    MinBtn.Position = UDim2.new(1, -80, 0.5, -17.5)
    MinBtn.BackgroundTransparency = 1  -- ✅ Transparan, tanpa background
    MinBtn.Text = "−"
    MinBtn.TextColor3 = Theme.Text
    MinBtn.TextSize = 18
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.AutoButtonColor = false
    MinBtn.BorderSizePixel = 0
        
    local MinimizedIcon = Instance.new("ImageButton", ScreenGui)
    MinimizedIcon.Name = "MinIcon"
    MinimizedIcon.Size = UDim2.new(0, 50, 0, 50)  
    MinimizedIcon.Position = UDim2.new(0, 20, 0, 20)
    MinimizedIcon.BackgroundTransparency = 1 
    MinimizedIcon.Image = "rbxassetid://101311528770915"  -- Logo Mach kamu
    MinimizedIcon.ScaleType = Enum.ScaleType.Fit
    MinimizedIcon.ImageTransparency = 0
    MinimizedIcon.AutoButtonColor = false
    MinimizedIcon.BorderSizePixel = 0
    MinimizedIcon.Visible = false
    Instance.new("UICorner", MinimizedIcon).CornerRadius = UDim.new(0, 8)
    MakeDraggable(MinimizedIcon, MinimizedIcon)
    
    local Content = Instance.new("Frame", Main)
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 1, -45)
    Content.Position = UDim2.new(0, 0, 0, 45)
    Content.BackgroundTransparency = 1
    
    local Sidebar = Instance.new("ScrollingFrame", Content)
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 135, 1, -15)
    Sidebar.Position = UDim2.new(0, 10, 0, 10)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BackgroundTransparency = 0.8  -- ✅ Lebih transparan (pas)
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 3
    Sidebar.ScrollBarImageColor3 = Theme.Primary
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)
    
    local SidebarLayout = Instance.new("UIListLayout", Sidebar)
    SidebarLayout.Padding = UDim.new(0, 5)
    SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local SidebarPadding = Instance.new("UIPadding", Sidebar)
    SidebarPadding.PaddingTop = UDim.new(0, 10)
    SidebarPadding.PaddingBottom = UDim.new(0, 10)
    
    MakeDraggable(Main, TopBar)
    
    -- ✅ Hover effects dihapus karena button tidak punya background
    -- CloseBtn.MouseEnter:Connect(function() 
    --     Tween(CloseBtn, {BackgroundColor3 = Theme.Error})
    -- end)

    -- CloseBtn.MouseLeave:Connect(function() 
    --     Tween(CloseBtn, {BackgroundColor3 = Theme.ElementBg})
    -- end)
    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        wait(0.35)
        ScreenGui:Destroy()
    end)
            -- ✅ RESIZE HANDLE (setelah MakeDraggable)
        local ResizeHandle = Instance.new("TextButton", Main)
        ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
        ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
        ResizeHandle.BackgroundColor3 = Theme.BorderBlue
        ResizeHandle.BackgroundTransparency = 0.3
        ResizeHandle.Text = ""
        ResizeHandle.AutoButtonColor = false
        ResizeHandle.BorderSizePixel = 0
        ResizeHandle.ZIndex = 10
        Instance.new("UICorner", ResizeHandle).CornerRadius = UDim.new(0, 4)

        -- Icon garis resize (opsional, bisa dihapus jika mau polos)
        local ResizeIcon = Instance.new("TextLabel", ResizeHandle)
        ResizeIcon.Size = UDim2.new(1, 0, 1, 0)
        ResizeIcon.BackgroundTransparency = 1
        ResizeIcon.Text = "⋰"
        ResizeIcon.TextColor3 = Theme.Text
        ResizeIcon.TextSize = 16
        ResizeIcon.Font = Enum.Font.GothamBold
        ResizeIcon.Rotation = 90

        -- ✅ RESIZE LOGIC
        local resizing = false
        local resizeStart = nil
        local startSize = nil
        local minSize = Vector2.new(400, 250)  -- Minimum: 400x250
        local maxSize = Vector2.new(1000, 700)   -- Ukuran maksimum

        ResizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = true
                resizeStart = input.Position
                startSize = Main.AbsoluteSize
            end
        end)

        ResizeHandle.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                resizing = false
                -- Update OriginalSize agar minimize/maximize tetap pakai size baru
                OriginalSize = Main.Size
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - resizeStart
                local newWidth = math.clamp(startSize.X + delta.X, minSize.X, maxSize.X)
                local newHeight = math.clamp(startSize.Y + delta.Y, minSize.Y, maxSize.Y)
                
                Main.Size = UDim2.new(0, newWidth, 0, newHeight)
            end
        end)

        -- Hover effect untuk resize handle
        ResizeHandle.MouseEnter:Connect(function()
            Tween(ResizeHandle, {BackgroundTransparency = 0})
        end)

        ResizeHandle.MouseLeave:Connect(function()
            if not resizing then
                Tween(ResizeHandle, {BackgroundTransparency = 0.3})
            end
        end)

    -- ✅ Hover effects dihapus karena button tidak punya background
    -- MinBtn.MouseEnter:Connect(function() Tween(MinBtn, {BackgroundColor3 = Theme.ElementBgHover}) end)
    -- MinBtn.MouseLeave:Connect(function() Tween(MinBtn, {BackgroundColor3 = Theme.ElementBg}) end)
-- ✅ FIX: Simpan ukuran dan posisi asli
local OriginalSize = Main.Size
local OriginalPosition = Main.Position

MinBtn.MouseButton1Click:Connect(function()
    Tween(Main, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    wait(0.3)
    Main.Visible = false
    MinimizedIcon.Visible = true
    MinimizedIcon.Size = UDim2.new(0, 0, 0, 0)
    Tween(MinimizedIcon, {Size = UDim2.new(0, 50, 0, 50)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end)

        local isDraggingIcon = false

        MinimizedIcon.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isDraggingIcon = false
            end
        end)

        MinimizedIcon.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                isDraggingIcon = true
            end
        end)

        MinimizedIcon.InputEnded:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not isDraggingIcon then
                Tween(MinimizedIcon, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
                wait(0.3)
                MinimizedIcon.Visible = false
                Main.Visible = true
                Main.Size = UDim2.new(0, 0, 0, 0)
                Main.Position = UDim2.new(0.5, 0, 0.5, 0)
                Tween(Main, {Size = OriginalSize, Position = OriginalPosition}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            end
            isDraggingIcon = false
        end)
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    local function SaveConfig()
        if not ConfigurationSaving.Enabled then return end
        
        -- ✅ FIX: Debounce saving
        task.spawn(function()
            local cfg = {}
            
            pcall(function()
                for flag, data in pairs(Dunhill.Flags) do
                    if type(data) == "table" and data.CurrentValue ~= nil then
                        cfg[flag] = data.CurrentValue
                    end
                end
            end)
            
            local success, encoded = pcall(function() 
                return HttpService:JSONEncode(cfg) 
            end)
            
            if success and writefile then
                pcall(function()
                    if makefolder then
                        if not isfolder(DunhillFolder) then 
                            makefolder(DunhillFolder) 
                        end
                        if not isfolder(DunhillFolder .. "/" .. ConfigurationSaving.FolderName) then
                            makefolder(DunhillFolder .. "/" .. ConfigurationSaving.FolderName)
                        end
                    end
                    
                    writefile(
                        DunhillFolder .. "/" .. ConfigurationSaving.FolderName .. "/" .. ConfigurationSaving.FileName .. ConfigurationExtension, 
                        encoded
                    )
                end)
            end
        end)
    end
            
        local function LoadConfig()
            if not ConfigurationSaving.Enabled then return end
            
            -- ✅ FIX: Multiple layer protection
            task.spawn(function()
                task.wait(1.5) -- Tunggu lebih lama untuk semua element ready
                
                local success = pcall(function()
                    if not isfile or not readfile then 
                        warn("[Dunhill] File functions not available")
                        return 
                    end
                    
                    local path = DunhillFolder .. "/" .. ConfigurationSaving.FolderName .. "/" .. ConfigurationSaving.FileName .. ConfigurationExtension
                    
                    if not isfile(path) then 
                        warn("[Dunhill] Config file not found")
                        return 
                    end
                    
                    local content = readfile(path)
                    if not content or content == "" then 
                        warn("[Dunhill] Config file empty")
                        return 
                    end
                    
                    local decoded
                    local decodeSuccess = pcall(function()
                        decoded = HttpService:JSONDecode(content)
                    end)
                    
                    if not decodeSuccess or type(decoded) ~= "table" then 
                        warn("[Dunhill] Invalid config format")
                        return 
                    end
                    
                    -- ✅ FIX: Load dengan delay dan validasi
                    for flag, value in pairs(decoded) do
                        task.spawn(function()
                            task.wait(0.1) -- Delay per flag
                            
                            if Dunhill.Flags[flag] then
                                pcall(function()
                                    if Dunhill.Flags[flag].SetValue then
                                        Dunhill.Flags[flag]:SetValue(value)
                                    elseif type(Dunhill.Flags[flag]) == "table" then
                                        Dunhill.Flags[flag].CurrentValue = value
                                    end
                                end)
                            end
                        end)
                    end
                    
                    print("[Dunhill] Config loaded successfully")
                end)
                
                if not success then
                    warn("[Dunhill] Failed to load config")
                end
            end)
        end
    
    Window.SaveConfiguration = SaveConfig
    Window.LoadConfiguration = LoadConfig
    
    function Window:CreateTab(config)
        config = config or {}
        local TabName = config.Name or "Tab"
        local TabIcon = config.Icon or ""
        
        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Name = TabName
        TabBtn.Size = UDim2.new(1, -12, 0, 38)
        TabBtn.BackgroundTransparency = 1  -- ✅ Transparan, tanpa background
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.BorderSizePixel = 0
        -- ✅ UICorner dihapus karena tidak ada background

        local ActiveIndicator = Instance.new("Frame", TabBtn)
        ActiveIndicator.Name = "ActiveIndicator"
        ActiveIndicator.Size = UDim2.new(0, 3, 0.7, 0)
        ActiveIndicator.Position = UDim2.new(0, 0, 0.15, 0)
        ActiveIndicator.BackgroundColor3 = Theme.BorderBlue
        ActiveIndicator.BorderSizePixel = 0
        ActiveIndicator.Visible = false
        Instance.new("UICorner", ActiveIndicator).CornerRadius = UDim.new(0, 2)
        
        
        local Icon = Instance.new("ImageLabel", TabBtn)
        Icon.Name = "Icon"
        Icon.Size = UDim2.new(0, 20, 0, 20)
        Icon.Position = UDim2.new(0, 10, 0.5, -10)
        Icon.BackgroundTransparency = 1
        Icon.Image = TabIcon ~= "" and "rbxassetid://" .. TabIcon or ""
        Icon.ImageColor3 = Theme.TextDim
        Icon.ScaleType = Enum.ScaleType.Fit
        Icon.Visible = TabIcon ~= ""
        
        
        local Label = Instance.new("TextLabel", TabBtn)
        Label.Name = "Label"
        Label.Size = UDim2.new(1, -45, 1, 0)  
        Label.Position = UDim2.new(0, TabIcon ~= "" and 35 or 10, 0, 0) 
        Label.BackgroundTransparency = 1
        Label.Text = TabName
        Label.TextColor3 = Theme.TextDim
        Label.TextSize = 13
        Label.Font = Enum.Font.GothamBold
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local TabTitleBar = Instance.new("TextLabel", Content)
        TabTitleBar.Name = TabName .. "TitleBar"
        TabTitleBar.Size = UDim2.new(1, -175, 0, 35)
        TabTitleBar.Position = UDim2.new(0, 155, 0, 4)
        TabTitleBar.BackgroundTransparency = 1  -- Tanpa background
        TabTitleBar.Text = TabName
        TabTitleBar.TextColor3 = Theme.Accent
        TabTitleBar.TextSize = 18
        TabTitleBar.Font = Enum.Font.GothamBold
        TabTitleBar.TextXAlignment = Enum.TextXAlignment.Left
        TabTitleBar.Visible = false
        TabTitleBar.ZIndex = 2
        
        local TabContent = Instance.new("ScrollingFrame", Content)
        TabContent.Name = TabName .. "Content"
        TabContent.Size = UDim2.new(1, -160, 1, -43)  
        TabContent.Position = UDim2.new(0, 150, 0, 38)  
        TabContent.BackgroundColor3 = Theme.Background
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 3
        TabContent.ScrollBarImageColor3 = Theme.Primary
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabContent.Visible = false
        TabContent.ClipsDescendants = true
        
        local Layout = Instance.new("UIListLayout", TabContent)
        Layout.Padding = UDim.new(0, 6)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local Padding = Instance.new("UIPadding", TabContent)
        Padding.PaddingTop = UDim.new(0, 5)
        Padding.PaddingLeft = UDim.new(0, 5)
        Padding.PaddingRight = UDim.new(0, 5)
        Padding.PaddingBottom = UDim.new(0, 5)
        
        -- ✅ Hover effect dihapus karena tab tidak punya background
        -- TabBtn.MouseEnter:Connect(function()
        --     if Window.CurrentTab ~= TabContent then
        --         Tween(TabBtn, {BackgroundColor3 = Theme.SidebarHover})
        --     end
        -- end)
        
        -- TabBtn.MouseLeave:Connect(function()
        --     if Window.CurrentTab ~= TabContent then
        --         Tween(TabBtn, {BackgroundColor3 = Theme.ElementBg})
        --     end
        -- end)
        
            local function ActivateTab()
                for _, tab in pairs(Window.Tabs) do
                    tab.Content.Visible = false
                    tab.TitleBar.Visible = false
                    -- ✅ Background color animation dihapus karena tab transparan
                    -- Tween(tab.Button, {BackgroundColor3 = Theme.TabInactive})
                    Tween(tab.Label, {TextColor3 = Theme.TextDim})
                    
                    if tab.Icon and tab.Icon.Visible then
                        Tween(tab.Icon, {ImageColor3 = Theme.TextDim})
                    end
                    
                    if tab.Button:FindFirstChild("ActiveIndicator") then
                        tab.Button.ActiveIndicator.Visible = false
                    end
                end
                
                Window.CurrentTab = TabContent
                TabContent.Visible = true
                TabTitleBar.Visible = true
                -- ✅ Background color animation dihapus karena tab transparan
                -- Tween(TabBtn, {BackgroundColor3 = Theme.TabActive})
                Tween(Label, {TextColor3 = Theme.Text})
                
                if Icon and Icon.Visible then
                    Tween(Icon, {ImageColor3 = Theme.Text})
                end
                
                if TabBtn:FindFirstChild("ActiveIndicator") then
                    TabBtn.ActiveIndicator.Visible = true
                end
            end
        
        TabBtn.MouseButton1Click:Connect(ActivateTab)
        
        -- ✅ FIX: Aktifkan tab pertama dengan delay lebih panjang
-- ✅ FIX: Aktifkan tab pertama dengan delay lebih panjang dan validasi
        if #Window.Tabs == 0 then
            task.spawn(function()
                task.wait(0.8) -- Delay lebih lama
                
                pcall(function()
                    if TabContent and TabContent.Parent then
                        ActivateTab()
                        print("[Dunhill] First tab activated")
                    end
                end)
            end)
        end
        
            local Tab = {
                Button = TabBtn, 
                Content = TabContent,
                TitleBar = TabTitleBar,  -- ✅ TAMBAHKAN
                Icon = Icon,
                Label = Label
            }
        table.insert(Window.Tabs, Tab)
        
        function Tab:CreateSection(config)
            config = config or {}
            local SectionName = config.Name or "Section"
            local DefaultExpanded = config.DefaultExpanded == true
            
            -- ✅ HEADER SECTION (KECIL TAPI ADA BINGKAI)
            local SectionHeader = Instance.new("Frame", TabContent)
            SectionHeader.Name = SectionName .. "_Header"
            SectionHeader.Size = UDim2.new(1, 0, 0, 35)  -- ✅ Kecil tapi ada background
            SectionHeader.BackgroundColor3 = Color3.fromRGB(65, 70, 80)  -- ✅ Abu-abu seperti sebelumnya
            SectionHeader.BackgroundTransparency = 0.7
            SectionHeader.BorderSizePixel = 0
            Instance.new("UICorner", SectionHeader).CornerRadius = UDim.new(0, 8)
            
            local SectionStroke = Instance.new("UIStroke", SectionHeader)
            SectionStroke.Color = Theme.ElementBorder
            SectionStroke.Thickness = 1
            SectionStroke.Transparency = 0.4
            SectionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            
            -- ✅ BUTTON (CLICKABLE AREA)
            local HeaderBtn = Instance.new("TextButton", SectionHeader)
            HeaderBtn.Size = UDim2.new(1, 0, 1, 0)
            HeaderBtn.BackgroundTransparency = 1
            HeaderBtn.Text = ""
            HeaderBtn.AutoButtonColor = false
            
            local SectionTitle = Instance.new("TextLabel", SectionHeader)
            SectionTitle.Name = "Title"
            SectionTitle.Size = UDim2.new(1, -80, 1, 0)
            SectionTitle.Position = UDim2.new(0, 12, 0, 0)  -- ✅ Padding kiri
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.Text = SectionName
            SectionTitle.TextColor3 = DefaultExpanded and Theme.BorderBlue or Theme.Accent
            SectionTitle.TextSize = 13
            SectionTitle.Font = Enum.Font.GothamBold
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            
            -- ✅ ARROW ICON
            local Arrow = Instance.new("TextLabel", SectionHeader)
            Arrow.Size = UDim2.new(0, 16, 0, 16)
            Arrow.Position = UDim2.new(1, -20, 0.5, -8)  -- ✅ Centered vertically
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "▼"
            Arrow.TextColor3 = Theme.TextDim
            Arrow.TextSize = 8  -- ✅ Lebih kecil
            Arrow.Font = Enum.Font.Gotham
            Arrow.Rotation = DefaultExpanded and 180 or 0
            
            -- ✅ DOT INDICATOR dihapus sesuai permintaan user
            
            -- ✅ GARIS BIRU ANIMASI (EXPAND DARI TENGAH, UJUNG RUNCING)
            local UnderlineContainer = Instance.new("Frame", SectionHeader)
            UnderlineContainer.Name = "UnderlineContainer"
            UnderlineContainer.Size = UDim2.new(1, 0, 0, 3)
            UnderlineContainer.Position = UDim2.new(0, 0, 1, 0)  -- Di bawah header
            UnderlineContainer.BackgroundTransparency = 1
            UnderlineContainer.ClipsDescendants = true
            
            -- Garis biru dengan gradient untuk ujung runcing
            local BlueLine = Instance.new("Frame", UnderlineContainer)
            BlueLine.Name = "BlueLine"
            BlueLine.Size = DefaultExpanded and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0)  -- Mulai dari 0 jika collapsed
            BlueLine.Position = UDim2.new(0.5, 0, 0, 0)  -- Anchor di tengah
            BlueLine.AnchorPoint = Vector2.new(0.5, 0)  -- Expand dari tengah
            BlueLine.BackgroundColor3 = Theme.BorderBlue
            BlueLine.BorderSizePixel = 0
            
            -- Gradient untuk ujung runcing (fade out di kedua sisi)
            local LineGradient = Instance.new("UIGradient", BlueLine)
            LineGradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),      -- Transparan di kiri (runcing)
                NumberSequenceKeypoint.new(0.05, 0),   -- Solid
                NumberSequenceKeypoint.new(0.95, 0),   -- Solid
                NumberSequenceKeypoint.new(1, 1)       -- Transparan di kanan (runcing)
            })
            
            -- ✅ CONTAINER (LANGSUNG DI TabContent, BUKAN DI DALAM FRAME!)
            local Container = Instance.new("Frame", TabContent)
            Container.Name = SectionName .. "_Content"
            Container.Size = UDim2.new(1, 0, 0, 0)
            Container.AutomaticSize = Enum.AutomaticSize.Y
            Container.BackgroundTransparency = 1
            Container.Visible = DefaultExpanded
            
            local ContainerLayout = Instance.new("UIListLayout", Container)
            ContainerLayout.Padding = UDim.new(0, 4)
            ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local Expanded = DefaultExpanded
            
            -- ✅ TOGGLE DENGAN ANIMASI SLIDE DOWN (SEPERTI ACCORDION)
            local function ToggleContent()
                Expanded = not Expanded
                
                -- ✅ ANIMASI WARNA TITLE DAN GARIS BIRU
                if Expanded then
                    Tween(SectionTitle, {TextColor3 = Theme.BorderBlue}, 0.3)
                    -- ✅ ANIMASI GARIS BIRU: Expand dari tengah ke samping
                    Tween(BlueLine, {Size = UDim2.new(1, 0, 1, 0)}, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                else
                    Tween(SectionTitle, {TextColor3 = Theme.Accent}, 0.3)
                    -- ✅ ANIMASI GARIS BIRU: Collapse ke tengah
                    Tween(BlueLine, {Size = UDim2.new(0, 0, 1, 0)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                end
                
                if Expanded then
                    -- Buka: Container jadi visible dulu
                    Container.Visible = true
                    Container.ClipsDescendants = true
                    
                    -- Animasi tinggi dari 0 ke full
                    Container.Size = UDim2.new(1, 0, 0, 0)
                    task.wait(0.05)
                    local targetHeight = ContainerLayout.AbsoluteContentSize.Y
                    
                    Tween(Container, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    
                    task.delay(0.3, function()
                        Container.Size = UDim2.new(1, 0, 0, 0)
                        Container.AutomaticSize = Enum.AutomaticSize.Y
                        Container.ClipsDescendants = false
                    end)
                else
                    -- Tutup: Animasi tinggi ke 0
                    Container.ClipsDescendants = true
                    Container.AutomaticSize = Enum.AutomaticSize.None
                    local currentHeight = Container.AbsoluteSize.Y
                    Container.Size = UDim2.new(1, 0, 0, currentHeight)
                    
                    Tween(Container, {Size = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    
                    task.delay(0.3, function()
                        Container.Visible = false
                    end)
                end
                
                Tween(Arrow, {Rotation = Expanded and 180 or 0}, 0.3)
            end
            
        -- ✅ CLICK EVENT (SUPPORT MOUSE & TOUCH)
        local touchStart = nil
        local isTouching = false

        HeaderBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                touchStart = input.Position
                isTouching = true
            end
        end)

        HeaderBtn.InputEnded:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isTouching then
                local touchEnd = input.Position
                local distance = (touchEnd - touchStart).Magnitude
                
                -- Kalau gerak kurang dari 10 pixel = tap, bukan scroll
                if distance < 10 then
                    ToggleContent()
                end
                
                isTouching = false
                touchStart = nil
            end
        end)

        -- ✅ HOVER EFFECT
        HeaderBtn.MouseEnter:Connect(function()
            Tween(SectionHeader, {BackgroundColor3 = Color3.fromRGB(75, 80, 90)}, 0.15)  -- ✅ Abu-abu lebih terang
        end)

        HeaderBtn.MouseLeave:Connect(function()
            Tween(SectionHeader, {BackgroundColor3 = Color3.fromRGB(65, 70, 80)}, 0.15)  -- ✅ Kembali ke abu-abu normal
        end)
            
            local SectionObj = {Container = Container, Frame = SectionHeader}
            
            function SectionObj:CreateLabel(config)
                config = config or {}
                local Text = config.Text or "Label"
                
                local Label = Instance.new("TextLabel", Container)
                Label.Size = UDim2.new(1, 0, 0, 0)
                Label.AutomaticSize = Enum.AutomaticSize.Y
                Label.BackgroundTransparency = 1
                Label.Text = Text
                Label.TextColor3 = Theme.TextDim
                Label.TextSize = 13
                Label.Font = Enum.Font.Gotham
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.TextWrapped = true
                
                return {
                    SetText = function(_, text) Label.Text = text end
                }
            end
            
            function SectionObj:CreateButton(config)
                config = config or {}
                local Name = config.Name or "Button"
                local Callback = config.Callback or function() end
                
                local Btn = Instance.new("TextButton", Container)
                Btn.Size = UDim2.new(1, 0, 0, 38)
                Btn.BackgroundColor3 = Theme.ElementContentBg
                Btn.BackgroundTransparency = 0.7
                Btn.Text = Name
                Btn.TextColor3 = Theme.Text
                Btn.TextSize = 14
                Btn.Font = Enum.Font.GothamMedium
                Btn.AutoButtonColor = false
                Btn.BorderSizePixel = 0
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 7)
                
                local Stroke = Instance.new("UIStroke", Btn)
                Stroke.Color = Theme.ElementBorder
                Stroke.Thickness = 1
                Stroke.Transparency = 0.4
                Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                
                Btn.MouseEnter:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Theme.ElementContentHover}, 0.15)
                    -- ✅ CHLOE X: Cyan border on hover
                    Tween(Stroke, {Color = Theme.BorderBlue, Transparency = 0.2}, 0.15)
                end)
                
                Btn.MouseLeave:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Theme.ElementContentBg}, 0.15)
                    Tween(Stroke, {Color = Theme.ElementBorder, Transparency = 0.4}, 0.15)
                end)
                
                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, {BackgroundColor3 = Theme.Primary}, 0.1)
                    Tween(Btn, {TextColor3 = Theme.TextDark}, 0.1)
                    wait(0.1)
                    Tween(Btn, {BackgroundColor3 = Theme.ElementBgHover}, 0.1)
                    Tween(Btn, {TextColor3 = Theme.Text}, 0.1)
                    pcall(Callback)
                end)
                
                return {
                    SetText = function(_, text) Btn.Text = text end
                }
            end
            
            function SectionObj:CreateToggle(config)
                config = config or {}
                local Name = config.Name or "Toggle"
                local CurrentValue = config.CurrentValue or false
                local Flag = config.Flag
                local Callback = config.Callback or function() end
                
                local Frame = Instance.new("Frame", Container)
                Frame.Size = UDim2.new(1, 0, 0, 50)  -- ✅ Lebih besar dari 38 ke 50
                Frame.BackgroundColor3 = Theme.ElementContentBg
                Frame.BackgroundTransparency = 0.7
                Frame.BorderSizePixel = 0
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 7)
                
                local Stroke = Instance.new("UIStroke", Frame)
                Stroke.Color = Theme.ElementBorder
                Stroke.Thickness = 1
                Stroke.Transparency = 0.4
                Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                
                -- ✅ TEXT DI ATAS
                local NameLabel = Instance.new("TextLabel", Frame)
                NameLabel.Size = UDim2.new(1, -60, 0, 20)
                NameLabel.Position = UDim2.new(0, 12, 0, 8)  -- ✅ Di atas dengan padding
                NameLabel.BackgroundTransparency = 1
                NameLabel.Text = Name
                NameLabel.TextColor3 = CurrentValue and Theme.BorderBlue or Theme.Text  -- ✅ Biru jika aktif
                NameLabel.TextSize = 13
                NameLabel.Font = Enum.Font.GothamBold
                NameLabel.TextXAlignment = Enum.TextXAlignment.Left
                NameLabel.TextYAlignment = Enum.TextYAlignment.Top
                
                -- ✅ TOGGLE DI KANAN BAWAH
                local ToggleBg = Instance.new("Frame", Frame)
                ToggleBg.Size = UDim2.new(0, 44, 0, 22)
                ToggleBg.Position = UDim2.new(1, -56, 1, -33)  -- ✅ Lebih ke atas, lebih centered
                ToggleBg.BackgroundColor3 = CurrentValue and Theme.ToggleOn or Theme.ToggleOff
                ToggleBg.BorderSizePixel = 0
                Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(1, 0)
                
                local ToggleCircle = Instance.new("Frame", ToggleBg)
                ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
                ToggleCircle.Position = CurrentValue and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ToggleCircle.BorderSizePixel = 0
                Instance.new("UICorner", ToggleCircle).CornerRadius = UDim.new(1, 0)
                
                local Interact = Instance.new("TextButton", Frame)
                Interact.Size = UDim2.new(1, 0, 1, 0)
                Interact.BackgroundTransparency = 1
                Interact.Text = ""
                
                Interact.MouseEnter:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Theme.ElementContentHover}, 0.15)
                end)
                
                Interact.MouseLeave:Connect(function()
                    Tween(Frame, {BackgroundColor3 = Theme.ElementContentBg}, 0.15)
                end)
                
                local function SetValue(value)
                    CurrentValue = value
                    -- ✅ CHLOE X: Animasi lebih cepat (0.2s)
                    Tween(ToggleBg, {BackgroundColor3 = value and Theme.ToggleOn or Theme.ToggleOff}, 0.2)
                    Tween(ToggleCircle, {Position = value and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2)
                    -- ✅ ANIMASI WARNA TEXT: Biru jika aktif, putih jika nonaktif
                    Tween(NameLabel, {TextColor3 = value and Theme.BorderBlue or Theme.Text}, 0.2)
                    if Flag then
                        Dunhill.Flags[Flag] = {CurrentValue = value, SetValue = SetValue}
                    end
                    pcall(Callback, value)
                    SaveConfig()
                end
                
                Interact.MouseButton1Click:Connect(function()
                    SetValue(not CurrentValue)
                end)
                
                if Flag then
                    Dunhill.Flags[Flag] = {CurrentValue = CurrentValue, SetValue = SetValue}
                end
                
                return {
                    CurrentValue = CurrentValue,
                    Set = SetValue,
                    SetValue = SetValue
                }
            end
            
            -- ✅ FIXED: Slider dengan bulatan dan support touch drag
            function SectionObj:CreateSlider(config)
                config = config or {}
                local Name = config.Name or "Slider"
                local Min = config.Min or 0
                local Max = config.Max or 100
                local Default = config.Default or Min
                local Increment = config.Increment or 1
                local Flag = config.Flag
                local Callback = config.Callback or function() end
                
                local CurrentValue = Default
                
                local Frame = Instance.new("Frame", Container)
                Frame.Size = UDim2.new(1, 0, 0, 54)
                Frame.BackgroundColor3 = Theme.ElementContentBg
                Frame.BackgroundTransparency = 0.7
                Frame.BorderSizePixel = 0
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 7)
                
                local Stroke = Instance.new("UIStroke", Frame)
                Stroke.Color = Theme.ElementBorder
                Stroke.Thickness = 1
                Stroke.Transparency = 0.4
                Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                
                local NameLabel = Instance.new("TextLabel", Frame)
                NameLabel.Size = UDim2.new(1, -60, 0, 22)
                NameLabel.Position = UDim2.new(0, 15, 0, 8)
                NameLabel.BackgroundTransparency = 1
                NameLabel.Text = Name
                NameLabel.TextColor3 = Theme.Text
                NameLabel.TextSize = 13
                NameLabel.Font = Enum.Font.GothamBold
                NameLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local ValueLabel = Instance.new("TextLabel", Frame)
                ValueLabel.Size = UDim2.new(0, 50, 0, 22)
                ValueLabel.Position = UDim2.new(1, -60, 0, 8)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = tostring(CurrentValue)
                ValueLabel.TextColor3 = Theme.Primary
                ValueLabel.TextSize = 13
                ValueLabel.Font = Enum.Font.GothamBold
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                
                local SliderBg = Instance.new("Frame", Frame)
                SliderBg.Size = UDim2.new(1, -30, 0, 6)
                SliderBg.Position = UDim2.new(0, 15, 1, -18)
                SliderBg.BackgroundColor3 = Theme.SliderBg
                SliderBg.BorderSizePixel = 0
                Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)
                
                local SliderFill = Instance.new("Frame", SliderBg)
                SliderFill.Size = UDim2.new((CurrentValue - Min) / (Max - Min), 0, 1, 0)
                SliderFill.BackgroundColor3 = Theme.SliderFill
                SliderFill.BorderSizePixel = 0
                Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
                
                -- ✅ BULATAN KECIL SLIDER
                local SliderThumb = Instance.new("Frame", SliderBg)
                SliderThumb.Size = UDim2.new(0, 16, 0, 16)
                SliderThumb.Position = UDim2.new((CurrentValue - Min) / (Max - Min), -8, 0.5, -8)
                SliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SliderThumb.BorderSizePixel = 0
                SliderThumb.ZIndex = 2
                Instance.new("UICorner", SliderThumb).CornerRadius = UDim.new(1, 0)
                
                -- ✅ CHLOE X: Cyan glow untuk slider thumb
                local ThumbShadow = Instance.new("UIStroke", SliderThumb)
                ThumbShadow.Color = Theme.BorderBlue  -- Cyan glow
                ThumbShadow.Thickness = 2
                ThumbShadow.Transparency = 0.3
                
                local SliderBtn = Instance.new("TextButton", SliderBg)
                SliderBtn.Size = UDim2.new(1, 0, 1, 20)
                SliderBtn.Position = UDim2.new(0, 0, 0, -10)
                SliderBtn.BackgroundTransparency = 1
                SliderBtn.Text = ""
                SliderBtn.ZIndex = 3
                
                local Dragging = false
                
                local function SetValue(value)
                    value = math.clamp(value, Min, Max)
                    value = math.floor((value - Min) / Increment + 0.5) * Increment + Min
                    value = math.clamp(value, Min, Max)
                    CurrentValue = value
                    ValueLabel.Text = tostring(value)
                    
                    local percent = (value - Min) / (Max - Min)
                    Tween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.08)
                    Tween(SliderThumb, {Position = UDim2.new(percent, -8, 0.5, -8)}, 0.08)
                    
                    if Flag then
                        Dunhill.Flags[Flag] = {CurrentValue = value, SetValue = SetValue}
                    end
                    pcall(Callback, value)
                    SaveConfig()
                end
                
                local function Update(input)
                    local pos = input.Position
                    local relativeX = pos.X - SliderBg.AbsolutePosition.X
                    local percent = math.clamp(relativeX / SliderBg.AbsoluteSize.X, 0, 1)
                    SetValue(Min + (Max - Min) * percent)
                end
                
                -- ✅ Support Mouse & Touch
                SliderBtn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = true
                        Update(input)
                        Tween(SliderThumb, {Size = UDim2.new(0, 20, 0, 20)}, 0.1)
                    end
                end)
                
                SliderBtn.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        Dragging = false
                        Tween(SliderThumb, {Size = UDim2.new(0, 16, 0, 16)}, 0.1)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        Update(input)
                    end
                end)
                
                if Flag then
                    Dunhill.Flags[Flag] = {CurrentValue = CurrentValue, SetValue = SetValue}
                end
                
                return {
                    CurrentValue = CurrentValue,
                    Set = SetValue,
                    SetValue = SetValue
                }
            end
            
            function SectionObj:CreateInput(config)
                config = config or {}
                local Name = config.Name or "Input"
                local PlaceholderText = config.PlaceholderText or "Enter text..."
                local RemoveTextAfterFocusLost = config.RemoveTextAfterFocusLost or false
                local Flag = config.Flag
                local Callback = config.Callback or function() end
                
                local CurrentValue = "" -- Track current value
                
                -- ✅ FIX: Tambah pcall untuk semua operasi
                local success, Frame = pcall(function()
                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(1, 0, 0, 60)  -- ✅ Lebih tinggi untuk layout vertikal
                    frame.BackgroundColor3 = Theme.ElementContentBg
                    frame.BackgroundTransparency = 0.7
                    frame.BorderSizePixel = 0
                    frame.Parent = Container
                    return frame
                end)
                
                if not success then
                    warn("[Dunhill] Failed to create Input frame")
                    return {SetValue = function() end}
                end
                
                pcall(function()
                    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 7)
                end)
                
                local Stroke = Instance.new("UIStroke", Frame)
                Stroke.Color = Theme.ElementBorder
                Stroke.Thickness = 1
                Stroke.Transparency = 0.4
                Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                
                -- ✅ LABEL DI ATAS
                local NameLabel = Instance.new("TextLabel", Frame)
                NameLabel.Size = UDim2.new(1, -24, 0, 20)
                NameLabel.Position = UDim2.new(0, 12, 0, 8)
                NameLabel.BackgroundTransparency = 1
                NameLabel.Text = Name
                NameLabel.TextColor3 = Theme.Text
                NameLabel.TextSize = 13
                NameLabel.Font = Enum.Font.GothamBold
                NameLabel.TextXAlignment = Enum.TextXAlignment.Left
                NameLabel.TextYAlignment = Enum.TextYAlignment.Top
                
                -- ✅ INPUT BOX DI BAWAH, LEBAR PENUH, WARNA ABU-ABU
                local InputBox = Instance.new("TextBox", Frame)
                InputBox.Size = UDim2.new(1, -24, 0, 28)
                InputBox.Position = UDim2.new(0, 12, 1, -34)  -- Di bawah
                InputBox.BackgroundColor3 = Color3.fromRGB(50, 55, 60)  -- ✅ Abu-abu gelap
                InputBox.Text = ""
                InputBox.PlaceholderText = PlaceholderText
                InputBox.PlaceholderColor3 = Theme.TextDim
                InputBox.TextColor3 = Theme.Text
                InputBox.TextSize = 13
                InputBox.Font = Enum.Font.Gotham
                InputBox.ClearTextOnFocus = false
                InputBox.BorderSizePixel = 0
                InputBox.TextXAlignment = Enum.TextXAlignment.Left  -- ✅ Align kiri

                pcall(function()
                    Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 5)
                end)

                local InputPadding = Instance.new("UIPadding", InputBox)
                InputPadding.PaddingLeft = UDim.new(0, 10)
                InputPadding.PaddingRight = UDim.new(0, 10)
                
                -- ✅ FIX: Wrap semua event dengan pcall
                pcall(function()
                    InputBox.Focused:Connect(function()
                        pcall(function()
                            -- ✅ CHLOE X: Cyan border on focus
                            Tween(Stroke, {Color = Theme.BorderBlue, Transparency = 0.2})
                        end)
                    end)
                end)
                
                pcall(function()
                    InputBox.FocusLost:Connect(function(enterPressed)
                        pcall(function()
                            Tween(Stroke, {Color = Theme.ElementBorder, Transparency = 0.4})
                        end)
                        
                        local text = InputBox.Text or ""
                        CurrentValue = text
                        
                        if Flag then
                            Dunhill.Flags[Flag] = {
                                CurrentValue = text,
                                SetValue = function(newText)
                                    pcall(function()
                                        InputBox.Text = newText or ""
                                        CurrentValue = newText or ""
                                    end)
                                end
                            }
                        end
                        
                        -- ✅ FIX: Callback dengan pcall
                        task.spawn(function()
                            pcall(Callback, text)
                        end)
                        
                        if RemoveTextAfterFocusLost then
                            pcall(function()
                                InputBox.Text = ""
                                CurrentValue = ""
                            end)
                        end
                        
                        -- ✅ FIX: SaveConfig dengan pcall
                        task.spawn(function()
                            pcall(SaveConfig)
                        end)
                    end)
                end)
                
                -- ✅ FIX: Initialize flag
                if Flag then
                    Dunhill.Flags[Flag] = {
                        CurrentValue = CurrentValue,
                        SetValue = function(newText)
                            pcall(function()
                                InputBox.Text = newText or ""
                                CurrentValue = newText or ""
                                if Flag then
                                    Dunhill.Flags[Flag].CurrentValue = newText or ""
                                end
                            end)
                        end
                    }
                end
                
                return {
                    SetValue = function(_, text)
                        pcall(function()
                            InputBox.Text = text or ""
                            CurrentValue = text or ""
                            if Flag then
                                Dunhill.Flags[Flag].CurrentValue = text or ""
                            end
                        end)
                    end,
                    GetValue = function()
                        return CurrentValue
                    end
                }
            end
            
            function SectionObj:CreateDropdown(config)
                config = config or {}
                local Name = config.Name or "Dropdown"
                local Options = config.Options or {"Option 1", "Option 2"}
                local CurrentOption = config.CurrentOption or Options[1]
                local Flag = config.Flag
                local Callback = config.Callback or function() end
                
                -- ✅ Frame lebih tinggi dengan layout 2 kolom
                local Frame = Instance.new("Frame", Container)
                Frame.Size = UDim2.new(1, 0, 0, 50)  -- Lebih tinggi
                Frame.BackgroundColor3 = Theme.ElementContentBg
                Frame.BackgroundTransparency = 0.7
                Frame.BorderSizePixel = 0
                Frame.ClipsDescendants = false
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 7)
                
                local Stroke = Instance.new("UIStroke", Frame)
                Stroke.Color = Theme.ElementBorder
                Stroke.Thickness = 1
                Stroke.Transparency = 0.4
                Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                
                -- ✅ Label di sebelah kiri
                local NameLabel = Instance.new("TextLabel", Frame)
                NameLabel.Size = UDim2.new(0.4, -10, 1, 0)  -- 40% lebar, di kiri
                NameLabel.Position = UDim2.new(0, 15, 0, 5)  -- Sedikit ke atas
                NameLabel.BackgroundTransparency = 1
                NameLabel.Text = Name
                NameLabel.TextColor3 = Theme.Text
                NameLabel.TextSize = 13
                NameLabel.Font = Enum.Font.GothamBold
                NameLabel.TextXAlignment = Enum.TextXAlignment.Left
                NameLabel.TextYAlignment = Enum.TextYAlignment.Top  -- Align ke atas
                
                -- ✅ Box dropdown di sebelah kanan
                local DropdownBox = Instance.new("Frame", Frame)
                DropdownBox.Size = UDim2.new(0.55, 0, 0, 35)  -- 55% lebar, di kanan
                DropdownBox.Position = UDim2.new(0.43, 0, 0.5, -17.5)  -- Centered vertically
                DropdownBox.BackgroundColor3 = Color3.fromRGB(25, 28, 32)
                DropdownBox.BackgroundTransparency = 0.3
                DropdownBox.BorderSizePixel = 0
                Instance.new("UICorner", DropdownBox).CornerRadius = UDim.new(0, 6)
                
                local DropboxStroke = Instance.new("UIStroke", DropdownBox)
                DropboxStroke.Color = Theme.ElementBorder
                DropboxStroke.Thickness = 1
                DropboxStroke.Transparency = 0.5
                DropboxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                
                local Btn = Instance.new("TextButton", DropdownBox)
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.BackgroundTransparency = 1
                Btn.Text = ""
                
                local ValueLabel = Instance.new("TextLabel", DropdownBox)
                ValueLabel.Size = UDim2.new(1, -35, 1, 0)
                ValueLabel.Position = UDim2.new(0, 10, 0, 0)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = CurrentOption
                ValueLabel.TextColor3 = Theme.BorderBlue  -- Cyan
                ValueLabel.TextSize = 12
                ValueLabel.Font = Enum.Font.Gotham
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
                ValueLabel.TextYAlignment = Enum.TextYAlignment.Center
                
                local Arrow = Instance.new("TextLabel", DropdownBox)
                Arrow.Size = UDim2.new(0, 20, 0, 20)
                Arrow.Position = UDim2.new(1, -25, 0.5, -10)
                Arrow.BackgroundTransparency = 1
                Arrow.Text = "▼"
                Arrow.TextColor3 = Theme.TextDim
                Arrow.TextSize = 10
                Arrow.Font = Enum.Font.Gotham
                
                local DropdownPopup = Instance.new("Frame")
                DropdownPopup.Name = "DropdownPopup_" .. Name
                DropdownPopup.Size = UDim2.new(0, 200, 0, 0)
                DropdownPopup.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
                DropdownPopup.BorderSizePixel = 0
                DropdownPopup.Visible = false
                DropdownPopup.ZIndex = 100
                DropdownPopup.Parent = Main
                Instance.new("UICorner", DropdownPopup).CornerRadius = UDim.new(0, 6)
                
                local PopupShadow = Instance.new("ImageLabel", DropdownPopup)
                PopupShadow.Size = UDim2.new(1, 20, 1, 20)
                PopupShadow.Position = UDim2.new(0, -10, 0, -10)
                PopupShadow.BackgroundTransparency = 1
                PopupShadow.Image = "rbxassetid://5554236805"
                PopupShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
                PopupShadow.ImageTransparency = 0.5
                PopupShadow.ScaleType = Enum.ScaleType.Slice
                PopupShadow.SliceCenter = Rect.new(23, 23, 277, 277)
                PopupShadow.ZIndex = -1
                
                local OptionsScroll = Instance.new("ScrollingFrame", DropdownPopup)
                OptionsScroll.Size = UDim2.new(1, -6, 1, -6)
                OptionsScroll.Position = UDim2.new(0, 3, 0, 3)
                OptionsScroll.BackgroundTransparency = 1
                OptionsScroll.ScrollBarThickness = 4
                OptionsScroll.ScrollBarImageColor3 = Theme.Primary
                OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
                OptionsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
                OptionsScroll.BorderSizePixel = 0
                OptionsScroll.ScrollingDirection = Enum.ScrollingDirection.Y
                
                local OptionsLayout = Instance.new("UIListLayout", OptionsScroll)
                OptionsLayout.Padding = UDim.new(0, 4)
                OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                
                local OptionsPadding = Instance.new("UIPadding", OptionsScroll)
                OptionsPadding.PaddingTop = UDim.new(0, 5)
                OptionsPadding.PaddingBottom = UDim.new(0, 5)
                OptionsPadding.PaddingLeft = UDim.new(0, 5)
                OptionsPadding.PaddingRight = UDim.new(0, 5)
                
                local Opened = false
                
                local function UpdateSize()
                    if Opened then
                        local itemHeight = 30
                        local spacing = 4
                        local padding = 10
                        local calculatedHeight = (#Options * itemHeight) + ((#Options - 1) * spacing) + padding
                        local maxHeight = Main.AbsoluteSize.Y * 0.6
                        local finalHeight = math.min(calculatedHeight, maxHeight)
                        local relativeX = Main.AbsoluteSize.X - 210
                        local relativeY = 50
                        
                        DropdownPopup.Position = UDim2.new(0, relativeX, 0, relativeY)
                        DropdownPopup.Size = UDim2.new(0, 200, 0, finalHeight)
                        DropdownPopup.Visible = true
                        Tween(Arrow, {Rotation = 180}, 0.2)
                    else
                        DropdownPopup.Visible = false
                        Tween(Arrow, {Rotation = 0}, 0.2)
                    end
                end
                
                local updateConnection
                updateConnection = RunService.RenderStepped:Connect(function()
                    if DropdownPopup.Visible then
                        local relativeX = Main.AbsoluteSize.X - 210
                        local relativeY = 50
                        DropdownPopup.Position = UDim2.new(0, relativeX, 0, relativeY)
                    end
                end)
                
                local function CreateOptions()
                    for _, child in ipairs(OptionsScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    for _, option in ipairs(Options) do
                        local OptBtn = Instance.new("TextButton", OptionsScroll)
                        OptBtn.Size = UDim2.new(1, -10, 0, 30)
                        OptBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                        OptBtn.Text = option
                        OptBtn.TextColor3 = Theme.Text
                        OptBtn.TextSize = 13
                        OptBtn.Font = Enum.Font.Gotham
                        OptBtn.AutoButtonColor = false
                        OptBtn.BorderSizePixel = 0
                        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                        Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 5)
                        
                        local TextPadding = Instance.new("UIPadding", OptBtn)
                        TextPadding.PaddingLeft = UDim.new(0, 10)
                        
                        OptBtn.MouseEnter:Connect(function()
                            Tween(OptBtn, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}, 0.15)
                        end)
                        
                        OptBtn.MouseLeave:Connect(function()
                            Tween(OptBtn, {BackgroundColor3 = Color3.fromRGB(18, 18, 18)}, 0.15)
                        end)
                        
                    -- ✅ FIXED: Bedain scroll dan tap
                    local touchStart = nil
                    local isTouching = false

                    OptBtn.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            touchStart = input.Position
                            isTouching = true
                        end
                    end)

                    OptBtn.InputEnded:Connect(function(input)
                        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isTouching then
                            local touchEnd = input.Position
                            local distance = (touchEnd - touchStart).Magnitude
                            
                            if distance < 10 then
                                CurrentOption = option
                                ValueLabel.Text = option
                                Opened = false
                                UpdateSize()
                                
                                if Flag then 
                                    Dunhill.Flags[Flag] = {CurrentValue = option} 
                                end
                                pcall(Callback, option)
                                SaveConfig()
                            end
                            
                            isTouching = false
                            touchStart = nil
                        end
                    end)
                end
            end
                
                CreateOptions()
                
            -- ✅ BUTTON CLICK dengan deteksi scroll yang lebih ketat
            local btnTouchStart = nil
            local btnTouchStartTime = nil

            Btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    btnTouchStart = input.Position
                    btnTouchStartTime = tick()
                end
            end)

            Btn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if btnTouchStart then
                        local touchEnd = input.Position
                        local distance = (touchEnd - btnTouchStart).Magnitude
                        local touchDuration = tick() - btnTouchStartTime
                        
                        -- Hanya buka dropdown jika:
                        -- 1. Gerak kurang dari 10 pixel (bukan scroll)
                        -- 2. Touch duration kurang dari 0.3 detik (tap cepat)
                        if distance < 10 and touchDuration < 0.3 then
                            Opened = not Opened
                            UpdateSize()
                        end
                        
                        btnTouchStart = nil
                        btnTouchStartTime = nil
                    end
                end
            end)
                
                -- ✅ CLOSE DETECTION dengan delay
                local closeConnection
                closeConnection = UserInputService.InputBegan:Connect(function(input)
                    if Opened and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                        task.wait(0.15)
                        
                        local mousePos = input.Position
                        local popupPos = DropdownPopup.AbsolutePosition
                        local popupSize = DropdownPopup.AbsoluteSize
                        local inPopup = mousePos.X >= popupPos.X and mousePos.X <= popupPos.X + popupSize.X and
                                    mousePos.Y >= popupPos.Y and mousePos.Y <= popupPos.Y + popupSize.Y
                        
                        local btnPos = Frame.AbsolutePosition
                        local btnSize = Frame.AbsoluteSize
                        local inButton = mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and
                                        mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y
                        
                        if not inPopup and not inButton then
                            Opened = false
                            UpdateSize()
                        end
                    end
                end)
                
                Frame.AncestryChanged:Connect(function()
                    if not Frame.Parent then
                        if updateConnection then updateConnection:Disconnect() end
                        if closeConnection then closeConnection:Disconnect() end
                        DropdownPopup:Destroy()
                    end
                end)
                
                if Flag then
                    Dunhill.Flags[Flag] = {CurrentValue = CurrentOption}
                end
                
                return {
                    SetValue = function(_, option)
                        if table.find(Options, option) then
                            CurrentOption = option
                            ValueLabel.Text = option
                            if Flag then
                                Dunhill.Flags[Flag] = {CurrentValue = option}
                            end
                        end
                    end,
                    
                    Refresh = function(_, newOptions)
                        Options = newOptions
                        CurrentOption = newOptions[1] or "None"
                        ValueLabel.Text = CurrentOption  -- ✅ Update value box, bukan name label
                        CreateOptions()
                        if Flag then
                            Dunhill.Flags[Flag] = {CurrentValue = CurrentOption}
                        end
                    end,
                    
                    GetValue = function()
                        return CurrentOption
                    end
                }
            end
            
            -- ================================
-- ✅ COLLAPSIBLE SECTION (ACCORDION)
-- ================================
function SectionObj:CreateCollapsible(config)
    config = config or {}
    local Name = config.Name or "Collapsible Section"
    local DefaultExpanded = config.DefaultExpanded or false
    
    local CollapsibleFrame = Instance.new("Frame", Container)
    CollapsibleFrame.Size = UDim2.new(1, 0, 0, 35)
    CollapsibleFrame.BackgroundColor3 = Theme.ElementContentBg
    CollapsibleFrame.BackgroundTransparency = 0.7
    CollapsibleFrame.BorderSizePixel = 0
    CollapsibleFrame.ClipsDescendants = true
    Instance.new("UICorner", CollapsibleFrame).CornerRadius = UDim.new(0, 7)
    
    local Stroke = Instance.new("UIStroke", CollapsibleFrame)
    Stroke.Color = Theme.ElementBorder
    Stroke.Thickness = 1
    Stroke.Transparency = 0.4
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    -- Header Button
    local HeaderBtn = Instance.new("TextButton", CollapsibleFrame)
    HeaderBtn.Size = UDim2.new(1, 0, 0, 38)
    HeaderBtn.BackgroundTransparency = 1
    HeaderBtn.Text = ""
    
    local NameLabel = Instance.new("TextLabel", CollapsibleFrame)
    NameLabel.Size = UDim2.new(1, -35, 1, 0)
    NameLabel.Position = UDim2.new(0, 15, 0, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = Name
    NameLabel.TextColor3 = Theme.Accent
    NameLabel.TextSize = 14
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local Arrow = Instance.new("TextLabel", CollapsibleFrame)
    Arrow.Size = UDim2.new(0, 20, 0, 20)
    Arrow.Position = UDim2.new(1, -30, 0, 9)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.TextColor3 = Theme.TextDim
    Arrow.TextSize = 10
    Arrow.Font = Enum.Font.Gotham
    Arrow.Rotation = DefaultExpanded and 180 or 0
    
    -- Content Container
    local ContentContainer = Instance.new("Frame", CollapsibleFrame)
    ContentContainer.Size = UDim2.new(1, -10, 0, 0)
    ContentContainer.Position = UDim2.new(0, 5, 0, 43)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.AutomaticSize = Enum.AutomaticSize.Y
    
    local ContentLayout = Instance.new("UIListLayout", ContentContainer)
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local Expanded = DefaultExpanded
    
    -- Update height function
    local function UpdateHeight()
        task.wait(0.05)
        
        local contentHeight = ContentLayout.AbsoluteContentSize.Y
        local targetHeight = Expanded and (43 + contentHeight + 15) or 38
        
        Tween(CollapsibleFrame, {Size = UDim2.new(1, 0, 0, targetHeight)}, 0.3)
        Tween(Arrow, {Rotation = Expanded and 180 or 0}, 0.3)
    end
    
    HeaderBtn.MouseButton1Click:Connect(function()
        Expanded = not Expanded
        UpdateHeight()
    end)
    
    HeaderBtn.MouseEnter:Connect(function()
        Tween(CollapsibleFrame, {BackgroundColor3 = Theme.ElementContentHover})
    end)
    
    HeaderBtn.MouseLeave:Connect(function()
        Tween(CollapsibleFrame, {BackgroundColor3 = Theme.ElementContentBg})
    end)
    
    -- Initialize
    if DefaultExpanded then
        UpdateHeight()
    end
    
    -- Return object dengan element creation methods
    local CollapsibleObj = {Container = ContentContainer, Frame = CollapsibleFrame}
    
    -- ✅ CREATE METHODS (bisa bikin UI elements di dalamnya)
    function CollapsibleObj:CreateLabel(cfg)
        cfg = cfg or {}
        local Text = cfg.Text or "Label"
        
        local Label = Instance.new("TextLabel", ContentContainer)
        Label.Size = UDim2.new(1, 0, 0, 0)
        Label.AutomaticSize = Enum.AutomaticSize.Y
        Label.BackgroundTransparency = 1
        Label.Text = Text
        Label.TextColor3 = Theme.TextDim
        Label.TextSize = 13
        Label.Font = Enum.Font.Gotham
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextWrapped = true
        
        task.defer(UpdateHeight)
        
        return {SetText = function(_, text) Label.Text = text end}
    end
    
    function CollapsibleObj:CreateToggle(cfg)
        cfg = cfg or {}
        local Name = cfg.Name or "Toggle"
        local CurrentValue = cfg.CurrentValue or false
        local Flag = cfg.Flag
        local Callback = cfg.Callback or function() end
        
        local Frame = Instance.new("Frame", ContentContainer)
        Frame.Size = UDim2.new(1, 0, 0, 38)
        Frame.BackgroundColor3 = Theme.ElementContentBg  
        Frame.BackgroundTransparency = 0.4
        Frame.BorderSizePixel = 0
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 7)
        
        local Stroke = Instance.new("UIStroke", Frame)
        Stroke.Color = Theme.ElementBorder
        Stroke.Thickness = 1
        Stroke.Transparency = 0.4
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        
        local NameLabel = Instance.new("TextLabel", Frame)
        NameLabel.Size = UDim2.new(1, -60, 1, 0)
        NameLabel.Position = UDim2.new(0, 15, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = Name
        NameLabel.TextColor3 = Theme.Text
        NameLabel.TextSize = 13
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local ToggleBg = Instance.new("Frame", Frame)
        ToggleBg.Size = UDim2.new(0, 44, 0, 22)
        ToggleBg.Position = UDim2.new(1, -52, 0.5, -11)
        ToggleBg.BackgroundColor3 = CurrentValue and Theme.ToggleOn or Theme.ToggleOff
        ToggleBg.BorderSizePixel = 0
        Instance.new("UICorner", ToggleBg).CornerRadius = UDim.new(1, 0)
        
        local ToggleCircle = Instance.new("Frame", ToggleBg)
        ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
        ToggleCircle.Position = CurrentValue and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleCircle.BorderSizePixel = 0
        Instance.new("UICorner", ToggleCircle).CornerRadius = UDim.new(1, 0)
        
        local Interact = Instance.new("TextButton", Frame)
        Interact.Size = UDim2.new(1, 0, 1, 0)
        Interact.BackgroundTransparency = 1
        Interact.Text = ""
        
        Interact.MouseEnter:Connect(function()
            Tween(Frame, {BackgroundColor3 = Theme.ElementContentHover})
        end)
        
        Interact.MouseLeave:Connect(function()
            Tween(Frame, {BackgroundColor3 = Theme.ElementContentBg})
        end)
        
        local function SetValue(value)
            CurrentValue = value
            Tween(ToggleBg, {BackgroundColor3 = value and Theme.ToggleOn or Theme.ToggleOff})
            Tween(ToggleCircle, {Position = value and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
            if Flag then
                Dunhill.Flags[Flag] = {CurrentValue = value, SetValue = SetValue}
            end
            pcall(Callback, value)
            SaveConfig()
        end
        
        Interact.MouseButton1Click:Connect(function()
            SetValue(not CurrentValue)
        end)
        
        if Flag then
            Dunhill.Flags[Flag] = {CurrentValue = CurrentValue, SetValue = SetValue}
        end
        
        task.defer(UpdateHeight)
        
        return {CurrentValue = CurrentValue, Set = SetValue, SetValue = SetValue}
    end
    
    function CollapsibleObj:CreateInput(cfg)
        cfg = cfg or {}
        local Name = cfg.Name or "Input"
        local PlaceholderText = cfg.PlaceholderText or "Enter text..."
        local RemoveTextAfterFocusLost = cfg.RemoveTextAfterFocusLost or false
        local Flag = cfg.Flag
        local Callback = cfg.Callback or function() end
        
        local CurrentValue = ""
        
        local Frame = Instance.new("Frame", ContentContainer)
        Frame.Size = UDim2.new(1, 0, 0, 65)
        Frame.BackgroundColor3 = Theme.ElementContentBg
        Frame.BackgroundTransparency = 0.7
        Frame.BorderSizePixel = 0
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 7)
        
        local Stroke = Instance.new("UIStroke", Frame)
        Stroke.Color = Theme.ElementBorder
        Stroke.Thickness = 1
        Stroke.Transparency = 0.4
        Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        
        local NameLabel = Instance.new("TextLabel", Frame)
        NameLabel.Size = UDim2.new(1, -160, 1, 0)
        NameLabel.Position = UDim2.new(0, 15, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = Name
        NameLabel.TextColor3 = Theme.Text
        NameLabel.TextSize = 13
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local InputBox = Instance.new("TextBox", Frame)
        InputBox.Size = UDim2.new(0, 140, 0, 28)
        InputBox.Position = UDim2.new(1, -155, 0.5, -14)
        InputBox.BackgroundColor3 = Theme.SliderBg
        InputBox.Text = ""
        InputBox.PlaceholderText = PlaceholderText
        InputBox.PlaceholderColor3 = Theme.TextDim
        InputBox.TextColor3 = Theme.Text
        InputBox.TextSize = 13
        InputBox.Font = Enum.Font.Gotham
        InputBox.ClearTextOnFocus = false
        InputBox.BorderSizePixel = 0
        InputBox.TextXAlignment = Enum.TextXAlignment.Center  -- ✅ Ubah ke Center

        Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 5)

        local InputPadding = Instance.new("UIPadding", InputBox)
        InputPadding.PaddingLeft = UDim.new(0, 5)   -- ✅ Kurangi jadi 5
        InputPadding.PaddingRight = UDim.new(0, 5)  -- ✅ Kurangi jadi 5
        
        InputBox.Focused:Connect(function()
            Tween(Stroke, {Color = Theme.Primary})
        end)
        
        InputBox.FocusLost:Connect(function()
            Tween(Stroke, {Color = Theme.ElementBorder})
            
            local text = InputBox.Text or ""
            CurrentValue = text
            
            if Flag then
                Dunhill.Flags[Flag] = {CurrentValue = text, SetValue = function(newText)
                    InputBox.Text = newText or ""
                    CurrentValue = newText or ""
                end}
            end
            
            pcall(Callback, text)
            
            if RemoveTextAfterFocusLost then
                InputBox.Text = ""
                CurrentValue = ""
            end
            
            SaveConfig()
        end)
        
        if Flag then
            Dunhill.Flags[Flag] = {CurrentValue = CurrentValue, SetValue = function(newText)
                InputBox.Text = newText or ""
                CurrentValue = newText or ""
            end}
        end
        
        task.defer(UpdateHeight)
        
        return {
            SetValue = function(_, text)
                InputBox.Text = text or ""
                CurrentValue = text or ""
            end,
            GetValue = function() return CurrentValue end
        }
    end
    
    return CollapsibleObj
end


            function SectionObj:CreateKeybind(config)
                config = config or {}
                local Name = config.Name or "Keybind"
                local CurrentKeybind = config.CurrentKeybind or "NONE"
                local Flag = config.Flag
                local Callback = config.Callback or function() end
                
                local Frame = Instance.new("Frame", Container)
                Frame.Size = UDim2.new(1, 0, 0, 38)
                Frame.BackgroundColor3 = Theme.ElementBg
                Frame.BackgroundTransparency = 0.7
                Frame.BorderSizePixel = 0
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 7)
                
                local Stroke = Instance.new("UIStroke", Frame)
                Stroke.Color = Theme.ElementBorder
                Stroke.Thickness = 1
                Stroke.Transparency = 0.4 
                Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                
                local NameLabel = Instance.new("TextLabel", Frame)
                NameLabel.Size = UDim2.new(1, -75, 1, 0)
                NameLabel.Position = UDim2.new(0, 15, 0, 0)
                NameLabel.BackgroundTransparency = 1
                NameLabel.Text = Name
                NameLabel.TextColor3 = Theme.Text
                NameLabel.TextSize = 13
                NameLabel.Font = Enum.Font.GothamBold
                NameLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local KeyBtn = Instance.new("TextButton", Frame)
                KeyBtn.Size = UDim2.new(0, 60, 0, 26)
                KeyBtn.Position = UDim2.new(1, -68, 0.5, -13)
                KeyBtn.BackgroundColor3 = Theme.SliderBg
                KeyBtn.Text = CurrentKeybind
                KeyBtn.TextColor3 = Theme.Primary
                KeyBtn.TextSize = 12
                KeyBtn.Font = Enum.Font.GothamBold
                KeyBtn.AutoButtonColor = false
                KeyBtn.BorderSizePixel = 0
                Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 5)
                
                local Binding = false
                
                KeyBtn.MouseButton1Click:Connect(function()
                    Binding = true
                    KeyBtn.Text = "..."
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(input)
                        if Binding then
                            local key = input.KeyCode.Name
                            if key ~= "Unknown" then
                                CurrentKeybind = key
                                KeyBtn.Text = key
                                Binding = false
                                if Flag then
                                    Dunhill.Flags[Flag] = {CurrentValue = key}
                                end
                                SaveConfig()
                                conn:Disconnect()
                            end
                        end
                    end)
                end)
                
                UserInputService.InputBegan:Connect(function(input, gpe)
                    if not gpe and input.KeyCode.Name == CurrentKeybind then
                        pcall(Callback)
                    end
                end)
                
                if Flag then
                    Dunhill.Flags[Flag] = {CurrentValue = CurrentKeybind}
                end
                
                return {
                    SetValue = function(_, key)
                        CurrentKeybind = key
                        KeyBtn.Text = key
                        if Flag then
                            Dunhill.Flags[Flag] = {CurrentValue = key}
                        end
                    end
                }
            end
            
            function SectionObj:CreateColorPicker(config)
                config = config or {}
                local Name = config.Name or "Color Picker"
                local Color = config.Color or Color3.fromRGB(255, 255, 255)
                local Flag = config.Flag
                local Callback = config.Callback or function() end
                
                local Frame = Instance.new("Frame", Container)
                Frame.Size = UDim2.new(1, 0, 0, 38)
                Frame.BackgroundColor3 = Theme.ElementBg
                Frame.BackgroundTransparency = 0.7
                Frame.BorderSizePixel = 0
                Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 7)
                
                local Stroke = Instance.new("UIStroke", Frame)
                Stroke.Color = Theme.ElementBorder
                Stroke.Thickness = 1
                SectionStroke.Transparency = 0.4
                Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                
                local NameLabel = Instance.new("TextLabel", Frame)
                NameLabel.Size = UDim2.new(1, -55, 1, 0)
                NameLabel.Position = UDim2.new(0, 15, 0, 0)
                NameLabel.BackgroundTransparency = 1
                NameLabel.Text = Name
                NameLabel.TextColor3 = Theme.Text
                NameLabel.TextSize = 13
                NameLabel.Font = Enum.Font.GothamBold
                NameLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                local ColorDisplay = Instance.new("TextButton", Frame)
                ColorDisplay.Size = UDim2.new(0, 35, 0, 22)
                ColorDisplay.Position = UDim2.new(1, -43, 0.5, -11)
                ColorDisplay.BackgroundColor3 = Color
                ColorDisplay.Text = ""
                ColorDisplay.AutoButtonColor = false
                ColorDisplay.BorderSizePixel = 0
                Instance.new("UICorner", ColorDisplay).CornerRadius = UDim.new(0, 5)
                
                local ColorStroke = Instance.new("UIStroke", ColorDisplay)
                ColorStroke.Color = Theme.Primary
                ColorStroke.Thickness = 1
                ColorStroke.Transparency = 0.4
                ColorDisplay.MouseButton1Click:Connect(function()
                    pcall(Callback, Color)
                end)
                
                if Flag then
                    Dunhill.Flags[Flag] = {CurrentValue = Color}
                end
                
                return {
                    SetValue = function(_, color)
                        Color = color
                        ColorDisplay.BackgroundColor3 = color
                        if Flag then
                            Dunhill.Flags[Flag] = {CurrentValue = color}
                        end
                        pcall(Callback, color)
                        SaveConfig()
                    end
                }
            end
            
            return SectionObj
        end
        
        return Tab
    end
    
    function Window:CreateNotification(config)
        config = config or {}
        local Title = config.Title or "Notification"
        local Content = config.Content or "Content"
        local Duration = config.Duration or 3
        local Type = config.Type or "Info"
        
        local Color = Theme.Info
        if Type == "Success" then Color = Theme.Success
        elseif Type == "Warning" then Color = Theme.Warning
        elseif Type == "Error" then Color = Theme.Error
        end
        
        local Notif = Instance.new("Frame", ScreenGui)
        Notif.Size = UDim2.new(0, 320, 0, 85)
        Notif.Position = UDim2.new(1, -340, 1, 100)
        Notif.BackgroundColor3 = Theme.BackgroundSecondary
        Notif.BorderSizePixel = 0
        Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 10)
        
        local NotifStroke = Instance.new("UIStroke", Notif)
        NotifStroke.Color = Color
        NotifStroke.Thickness = 2
        NotifStroke.Transparency = 0.4
        local NotifTitle = Instance.new("TextLabel", Notif)
        NotifTitle.Size = UDim2.new(1, -20, 0, 26)
        NotifTitle.Position = UDim2.new(0, 12, 0, 10)
        NotifTitle.BackgroundTransparency = 1
        NotifTitle.Text = Title
        NotifTitle.TextColor3 = Theme.Accent
        NotifTitle.TextSize = 15
        NotifTitle.Font = Enum.Font.GothamBold
        NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
        
        local NotifContent = Instance.new("TextLabel", Notif)
        NotifContent.Size = UDim2.new(1, -20, 1, -40)
        NotifContent.Position = UDim2.new(0, 12, 0, 36)
        NotifContent.BackgroundTransparency = 1
        NotifContent.Text = Content
        NotifContent.TextColor3 = Theme.TextDim
        NotifContent.TextSize = 13
        NotifContent.Font = Enum.Font.Gotham
        NotifContent.TextXAlignment = Enum.TextXAlignment.Left
        NotifContent.TextYAlignment = Enum.TextYAlignment.Top
        NotifContent.TextWrapped = true
        
        Tween(Notif, {Position = UDim2.new(1, -340, 1, -105)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        
        task.delay(Duration, function()
            Tween(Notif, {Position = UDim2.new(1, -340, 1, 100)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            task.wait(0.5)
            Notif:Destroy()
        end)
    end
    
    task.wait(0.1)

if LoadConfigurationOnStart then
    task.spawn(function()
        task.wait(1) -- Kasih waktu semua UI fully loaded
        LoadConfig()
    end)
end
    
    return Window
end

return Dunhill
