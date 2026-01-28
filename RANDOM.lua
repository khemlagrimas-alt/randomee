--[[ 
    VOID.Δ (v8.2) - DELTA PREMIUM (LAUNCHER CLICK FIX)
    Instructions: 
    1. Open Roblox Studio.
    2. Go to StarterGui.
    3. Insert a 'LocalScript'.
    4. Delete the default code and paste this entire script.
]]

-- // 1. SERVICES //
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")
local Stats = game:GetService("Stats")

-- // 2. LOCALS //
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = Workspace.CurrentCamera

-- // 3. CONFIGURATION //
local Colors = {
    Background = Color3.fromRGB(15, 15, 20),
    Sidebar = Color3.fromRGB(20, 20, 28),
    CardInfo = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(140, 80, 255),
    AccentLight = Color3.fromRGB(180, 130, 255),
    Text = Color3.fromRGB(255, 255, 255),
    SecondaryText = Color3.fromRGB(160, 160, 175),
    Button = Color3.fromRGB(28, 28, 38),
    ButtonHover = Color3.fromRGB(40, 40, 55),
    Border = Color3.fromRGB(45, 45, 55),
    Success = Color3.fromRGB(0, 255, 150),
    Danger = Color3.fromRGB(255, 70, 70),
    ConsoleLog = Color3.fromRGB(200, 200, 210)
}

local States = {
    Flying = false, FlySpeed = 60,
    Freecam = false, FreecamSpeed = 1,
    Noclip = false, InfJump = false,
    Spin = false, SpinSpeed = 20,
    TpWalk = false, TpWalkSpeed = 5,
    HatSpin = false,
    LoopGoto = nil, LoopBring = nil, LoopKill = nil,
    Orbit = nil, Stare = nil,
    ClickTP = false, AntiAfk = false,
    Spamming = false, SpamText = "",
    Xray = false, Esp = false,
    Float = false, Swim = false,
    GodMode = false, FullBright = false
}

local OriginalSettings = {
    WalkSpeed = 16,
    JumpPower = 50,
    HipHeight = 0,
    Gravity = 196.2,
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows
}

-- // 4. UI CONSTRUCTION //
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VoidDeltaGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainScale = Instance.new("UIScale", ScreenGui)

-- [Utility] Smooth Tween
local function animate(obj, props, duration)
    local info = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

-- [Utility] Create Notification
local function createNotification(text, isSuccess)
    local NotifyFrame = Instance.new("Frame")
    NotifyFrame.Name = "Notification"
    NotifyFrame.Size = UDim2.new(0, 240, 0, 45)
    NotifyFrame.Position = UDim2.new(1, 20, 1, -70) 
    NotifyFrame.BackgroundColor3 = Colors.Sidebar
    NotifyFrame.ZIndex = 200
    NotifyFrame.Parent = ScreenGui

    Instance.new("UICorner", NotifyFrame).CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new("UIStroke", NotifyFrame)
    Stroke.Color = isSuccess and Colors.Success or Colors.Danger
    Stroke.Thickness = 2
    local Label = Instance.new("TextLabel", NotifyFrame)
    Label.Size = UDim2.new(1, -20, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Colors.Text
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left

    animate(NotifyFrame, {Position = UDim2.new(1, -260, 1, -70)}, 0.5)
    
    task.delay(3.5, function()
        if NotifyFrame.Parent then
            animate(NotifyFrame, {Position = UDim2.new(1, 20, 1, -70)}, 0.5).Completed:Connect(function()
                NotifyFrame:Destroy()
            end)
        end
    end)
end

-- [Utility] Create Dummy Window
local function createDummyWindow(title, contentText)
    local Win = Instance.new("Frame", ScreenGui)
    Win.Name = "DummyWindow"
    Win.Size = UDim2.new(0, 400, 0, 300)
    Win.Position = UDim2.new(0.5, -200, 0.5, -150)
    Win.BackgroundColor3 = Colors.Background
    Win.Active = true 
    Win.Draggable = true
    Win.ZIndex = 50
    
    Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 8)
    local WS = Instance.new("UIStroke", Win)
    WS.Color = Colors.Accent
    WS.Thickness = 1
    
    local Top = Instance.new("Frame", Win)
    Top.Size = UDim2.new(1, 0, 0, 30)
    Top.BackgroundColor3 = Colors.Sidebar
    Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 8)
    
    local T = Instance.new("TextLabel", Top)
    T.Size = UDim2.new(1, -40, 1, 0)
    T.Position = UDim2.new(0, 10, 0, 0)
    T.BackgroundTransparency = 1
    T.Text = title
    T.TextColor3 = Colors.Text
    T.Font = Enum.Font.GothamBold
    T.TextXAlignment = Enum.TextXAlignment.Left
    
    local X = Instance.new("TextButton", Top)
    X.Size = UDim2.new(0, 30, 1, 0)
    X.Position = UDim2.new(1, -30, 0, 0)
    X.BackgroundTransparency = 1
    X.Text = "X"
    X.TextColor3 = Colors.Danger
    X.MouseButton1Click:Connect(function() Win:Destroy() end)
    
    local C = Instance.new("TextLabel", Win)
    C.Size = UDim2.new(1, -20, 1, -40)
    C.Position = UDim2.new(0, 10, 0, 35)
    C.BackgroundTransparency = 1
    C.Text = contentText
    C.TextColor3 = Colors.SecondaryText
    C.TextYAlignment = Enum.TextYAlignment.Top
    C.TextXAlignment = Enum.TextXAlignment.Left
    C.TextWrapped = true
end

-- // MAIN UI STRUCTURE //

-- 1. Launcher (SIMPLIFIED FOR RELIABILITY)
local Launcher = Instance.new("TextButton", ScreenGui)
Launcher.Name = "Launcher"
Launcher.Size = UDim2.new(0, 0, 0, 0) -- Start small for anim
Launcher.Position = UDim2.new(0.5, -30, 0.5, -30)
Launcher.BackgroundColor3 = Colors.Sidebar
Launcher.Text = "Δ"
Launcher.TextColor3 = Colors.Accent
Launcher.TextSize = 38
Launcher.Font = Enum.Font.GothamBold
Launcher.Active = true
Launcher.Draggable = true -- Built-in Draggable to avoid script conflict
Launcher.ZIndex = 10000 -- Max ZIndex
Instance.new("UICorner", Launcher).CornerRadius = UDim.new(1, 0)
local LStroke = Instance.new("UIStroke", Launcher)
LStroke.Thickness = 3
LStroke.Color = Colors.Accent

-- Pop-in Animation
animate(Launcher, {Size = UDim2.new(0, 60, 0, 60)}, 0.5)

-- 2. Main Window
local MainWidth, MainHeight = 600, 380
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, MainWidth, 0, MainHeight)
MainFrame.Position = UDim2.new(0.5, -MainWidth/2, 1, 50) -- Hidden
MainFrame.BackgroundColor3 = Colors.Background
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MStroke = Instance.new("UIStroke", MainFrame)
MStroke.Color = Colors.Border

-- Sidebar
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 60, 1, 0)
Sidebar.BackgroundColor3 = Colors.Sidebar
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local NavContainer = Instance.new("Frame", Sidebar)
NavContainer.Size = UDim2.new(1, 0, 1, 0)
NavContainer.BackgroundTransparency = 1

local function createNavIcon(name, text, yPos)
    local btn = Instance.new("TextButton", NavContainer)
    btn.Name = name
    btn.Size = UDim2.new(0, 40, 0, 40)
    btn.Position = UDim2.new(0.5, -20, 0, yPos)
    btn.BackgroundColor3 = Colors.Button
    btn.Text = text
    btn.TextColor3 = Colors.SecondaryText
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    return btn
end

local HomeTabBtn = createNavIcon("HomeTab", "H", 15)
local ScriptsTabBtn = createNavIcon("ScriptsTab", "S", 65)
local MapsTabBtn = createNavIcon("MapsTab", "M", 115)
local ConsoleTabBtn = createNavIcon("ConsoleTab", "C", 165)

-- Content Area
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -80, 1, -60)
ContentFrame.Position = UDim2.new(0, 75, 0, 50)
ContentFrame.BackgroundTransparency = 1

-- >> HOME TAB
local HomeContent = Instance.new("Frame", ContentFrame)
HomeContent.Size = UDim2.new(1, 0, 1, 0)
HomeContent.BackgroundTransparency = 1

local UserProfile = Instance.new("Frame", HomeContent)
UserProfile.Size = UDim2.new(1, 0, 0, 80)
UserProfile.BackgroundColor3 = Colors.CardInfo
Instance.new("UICorner", UserProfile).CornerRadius = UDim.new(0, 8)

task.spawn(function()
    local AvatarImage = Instance.new("ImageLabel", UserProfile)
    AvatarImage.Size = UDim2.new(0, 60, 0, 60)
    AvatarImage.Position = UDim2.new(0, 10, 0, 10)
    AvatarImage.BackgroundColor3 = Colors.Background
    pcall(function()
        AvatarImage.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
    end)
    Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(1, 0)
end)

local WelcomeTitle = Instance.new("TextLabel", UserProfile)
WelcomeTitle.Size = UDim2.new(1, -80, 0, 30)
WelcomeTitle.Position = UDim2.new(0, 80, 0, 10)
WelcomeTitle.BackgroundTransparency = 1
WelcomeTitle.Text = "Welcome, " .. Player.Name
WelcomeTitle.TextColor3 = Colors.Text
WelcomeTitle.Font = Enum.Font.GothamBold
WelcomeTitle.TextSize = 20
WelcomeTitle.TextXAlignment = "Left"
local RankLabel = Instance.new("TextLabel", UserProfile)
RankLabel.Size = UDim2.new(1, -80, 0, 20)
RankLabel.Position = UDim2.new(0, 80, 0, 40)
RankLabel.BackgroundTransparency = 1
RankLabel.Text = "Delta Premium User"
RankLabel.TextColor3 = Colors.Accent
RankLabel.Font = Enum.Font.GothamMedium
RankLabel.TextSize = 14
RankLabel.TextXAlignment = "Left"

local StatsContainer = Instance.new("Frame", HomeContent)
StatsContainer.Size = UDim2.new(1, 0, 1, -90)
StatsContainer.Position = UDim2.new(0, 0, 0, 90)
StatsContainer.BackgroundTransparency = 1
local Grid = Instance.new("UIGridLayout", StatsContainer)
Grid.CellSize = UDim2.new(0.48, 0, 0, 80)
Grid.CellPadding = UDim2.new(0.04, 0, 0, 10)

local function createStatCard(title)
    local Card = Instance.new("Frame", StatsContainer)
    Card.BackgroundColor3 = Colors.CardInfo
    Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 8)
    local CTitle = Instance.new("TextLabel", Card)
    CTitle.Size = UDim2.new(1, -20, 0, 30)
    CTitle.Position = UDim2.new(0, 10, 0, 5)
    CTitle.BackgroundTransparency = 1
    CTitle.Text = title
    CTitle.TextColor3 = Colors.SecondaryText
    CTitle.Font = Enum.Font.GothamMedium
    CTitle.TextSize = 14
    CTitle.TextXAlignment = "Left"
    local CValue = Instance.new("TextLabel", Card)
    CValue.Name = "ValueLabel"
    CValue.Size = UDim2.new(1, -20, 0, 40)
    CValue.Position = UDim2.new(0, 10, 0, 35)
    CValue.BackgroundTransparency = 1
    CValue.Text = "..."
    CValue.TextColor3 = Colors.Text
    CValue.Font = Enum.Font.GothamBold
    CValue.TextSize = 22
    CValue.TextXAlignment = "Left"
    return CValue
end
local FPSValue = createStatCard("Frames Per Second")
local PingValue = createStatCard("Network Ping")
local PlayersValue = createStatCard("Server Players")
local TimeValue = createStatCard("Server Time")

-- >> SCRIPTS TAB
local ScriptsContent = Instance.new("ScrollingFrame", ContentFrame)
ScriptsContent.Size = UDim2.new(1, 0, 1, 0)
ScriptsContent.BackgroundTransparency = 1
ScriptsContent.Visible = false
ScriptsContent.ScrollBarThickness = 3
ScriptsContent.CanvasSize = UDim2.new(0, 0, 50, 0)

-- >> MAPS TAB
local MapsContent = Instance.new("ScrollingFrame", ContentFrame)
MapsContent.Size = UDim2.new(1, 0, 1, 0)
MapsContent.BackgroundTransparency = 1
MapsContent.Visible = false
MapsContent.ScrollBarThickness = 3
local MapsGrid = Instance.new("UIGridLayout", MapsContent)
MapsGrid.CellSize = UDim2.new(0.3, 0, 0, 100)
MapsGrid.CellPadding = UDim2.new(0.025, 0, 0, 10)

-- >> CONSOLE TAB
local ConsoleContent = Instance.new("ScrollingFrame", ContentFrame)
ConsoleContent.Size = UDim2.new(1, 0, 1, 0)
ConsoleContent.BackgroundTransparency = 1
ConsoleContent.Visible = false
ConsoleContent.ScrollBarThickness = 3
local ConsoleLayout = Instance.new("UIListLayout", ConsoleContent)
ConsoleLayout.Padding = UDim.new(0, 3)

local function logToConsole(message, color)
    color = color or Colors.ConsoleLog
    if color == Colors.Danger then warn("[Void.Δ]: " .. message) else print("[Void.Δ]: " .. message) end
    local log = Instance.new("TextLabel", ConsoleContent)
    log.Size = UDim2.new(1, 0, 0, 20)
    log.BackgroundTransparency = 1
    log.Text = " <font color='#8C50FF'>[" .. os.date("%X") .. "]</font> " .. message
    log.RichText = true
    log.TextColor3 = color
    log.Font = Enum.Font.Code
    log.TextSize = 13
    log.TextXAlignment = "Left"
    ConsoleContent.CanvasSize = UDim2.new(0, 0, 0, ConsoleLayout.AbsoluteContentSize.Y)
    ConsoleContent.CanvasPosition = Vector2.new(0, 9999)
end

-- Command Bar
local CommandBarFrame = Instance.new("Frame", ScreenGui)
CommandBarFrame.Size = UDim2.new(0, 420, 0, 45)
CommandBarFrame.Position = UDim2.new(0.5, -210, 1, 50) 
CommandBarFrame.BackgroundColor3 = Colors.Sidebar
Instance.new("UICorner", CommandBarFrame).CornerRadius = UDim.new(0, 10)
local CBStroke = Instance.new("UIStroke", CommandBarFrame)
CBStroke.Color = Colors.Accent
CBStroke.Thickness = 2
local InfiniteField = Instance.new("TextBox", CommandBarFrame)
InfiniteField.Size = UDim2.new(1, -30, 1, 0)
InfiniteField.Position = UDim2.new(0, 15, 0, 0)
InfiniteField.BackgroundTransparency = 1
InfiniteField.TextColor3 = Colors.Text
InfiniteField.Font = "Code"
InfiniteField.TextSize = 15
InfiniteField.PlaceholderText = "Execute command..."
InfiniteField.Text = ""

-- Top Bar
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, -60, 0, 40)
TopBar.Position = UDim2.new(0, 60, 0, 0)
TopBar.BackgroundTransparency = 1
local TitleLabel = Instance.new("TextLabel", TopBar)
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Text = "VOID.Δ <font color='#8C50FF'>ULTIMATE</font>"
TitleLabel.RichText = true
TitleLabel.TextColor3 = Colors.Text
TitleLabel.Font = "GothamBold"
TitleLabel.TextXAlignment = "Left"
TitleLabel.BackgroundTransparency = 1
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 40, 0, 40)
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Colors.SecondaryText
CloseBtn.Font = "GothamBold"
CloseBtn.TextSize = 16

-- Toggle Logic (RELIABLE METHOD)
local mainVisible = false
local function toggleMain()
    mainVisible = not mainVisible
    local mainTarget = mainVisible and UDim2.new(0.5, -MainWidth/2, 0.5, -MainHeight/2) or UDim2.new(0.5, -MainWidth/2, 1, 50)
    local barTarget = mainVisible and UDim2.new(0.5, -210, 1, -110) or UDim2.new(0.5, -210, 1, 50)
    
    animate(MainFrame, {Position = mainTarget}, 0.4)
    animate(CommandBarFrame, {Position = barTarget}, 0.4)
end

-- Connect Events (Use MouseButton1Click for best reliability)
Launcher.MouseButton1Click:Connect(toggleMain)
CloseBtn.MouseButton1Click:Connect(toggleMain)

-- Tab Switcher
local function switchTab(name)
    HomeContent.Visible = (name == "HomeTab")
    ScriptsContent.Visible = (name == "ScriptsTab")
    MapsContent.Visible = (name == "MapsTab")
    ConsoleContent.Visible = (name == "ConsoleTab")
    
    HomeTabBtn.BackgroundColor3 = (name == "HomeTab") and Colors.Accent or Colors.Button
    ScriptsTabBtn.BackgroundColor3 = (name == "ScriptsTab") and Colors.Accent or Colors.Button
    MapsTabBtn.BackgroundColor3 = (name == "MapsTab") and Colors.Accent or Colors.Button
    ConsoleTabBtn.BackgroundColor3 = (name == "ConsoleTab") and Colors.Accent or Colors.Button
end
HomeTabBtn.MouseButton1Click:Connect(function() switchTab("HomeTab") end)
ScriptsTabBtn.MouseButton1Click:Connect(function() switchTab("ScriptsTab") end)
MapsTabBtn.MouseButton1Click:Connect(function() switchTab("MapsTab") end)
ConsoleTabBtn.MouseButton1Click:Connect(function() switchTab("ConsoleTab") end)
switchTab("HomeTab")

-- TP Tool
local function giveTPTool()
    local tool = Instance.new("Tool") tool.Name = "Void TP" tool.RequiresHandle = false
    tool.Activated:Connect(function() 
        local char = Player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0,3,0)) end 
    end)
    tool.Parent = Player.Backpack
end

-- Physics Updates
local function updateFly()
    local char = Player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if States.Flying and root and hum then
        local bv = root:FindFirstChild("FlyVelocity") or Instance.new("BodyVelocity", root)
        bv.Name = "FlyVelocity" bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge) bv.Velocity = Vector3.new(0,0,0)
        local bg = root:FindFirstChild("FlyGyro") or Instance.new("BodyGyro", root)
        bg.Name = "FlyGyro" bg.P = 9e4 bg.MaxTorque = Vector3.new(math.huge,math.huge,math.huge) bg.CFrame = root.CFrame
        hum.PlatformStand = true
    else
        if root and root:FindFirstChild("FlyVelocity") then root.FlyVelocity:Destroy() end
        if root and root:FindFirstChild("FlyGyro") then root.FlyGyro:Destroy() end
        if hum then hum.PlatformStand = false end
    end
end

-- MAIN COMMAND HANDLER
local function executeCommand(input)
    if input == "" then return end
    lastCommand = input
    local args = string.split(input, " ")
    local cmd = string.lower(args[1])
    local fullText = string.sub(input, #cmd + 2)
    local found = true
    local char = Player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if cmd == "guiscale" and args[2] then local s = tonumber(args[2]) if s then MainScale.Scale = math.clamp(s, 0.4, 2) end
    elseif cmd == "console" then StarterGui:SetCore("DevConsoleVisible", true) createNotification("Console Opened", true)
    elseif cmd == "dex" or cmd == "explorer" then createDummyWindow("Dex Explorer", "Workspace\nPlayers\nLighting\nReplicatedStorage\nServerScriptService\nServerStorage")
    elseif cmd == "remotespy" or cmd == "rspy" then createDummyWindow("Remote Spy", "Listening...\n> FireServer\n> InvokeServer")
    elseif cmd == "executor" then createDummyWindow("Executor", "print('Hello Void')")
    elseif cmd == "serverinfo" or cmd == "info" then
        createDummyWindow("Server Info", "Place: "..game.PlaceId.."\nJob: "..(game.JobId~="" and game.JobId or "Studio").."\nPlayers: "..#Players:GetPlayers())
    elseif cmd == "jobid" then InfiniteField.Text = game.JobId InfiniteField:CaptureFocus() createNotification("Copied JobID", true)
    elseif cmd == "rejoin" then TeleportService:Teleport(game.PlaceId, Player)
    elseif cmd == "serverhop" then createNotification("Hopping...", true) TeleportService:Teleport(game.PlaceId, Player)
    elseif cmd == "antiidle" then States.AntiAfk = true createNotification("Anti-AFK Enabled", true)
    elseif cmd == "notify" then createNotification(fullText, true)
    elseif cmd == "lastcommand" then executeCommand(lastCommand) return
    elseif cmd == "fly" then
        if args[2] then States.FlySpeed = tonumber(args[2]) or States.FlySpeed States.Flying = true else States.Flying = not States.Flying end
        updateFly()
    elseif cmd == "unfly" then States.Flying = false updateFly()
    elseif cmd == "flyspeed" and args[2] then States.FlySpeed = tonumber(args[2]) or States.FlySpeed
    elseif cmd == "noclip" then States.Noclip = true
    elseif cmd == "clip" then States.Noclip = false
    elseif cmd == "speed" then OriginalSettings.WalkSpeed = tonumber(args[2]) or 16 if hum then hum.WalkSpeed = OriginalSettings.WalkSpeed end
    elseif cmd == "unspeed" then OriginalSettings.WalkSpeed = 16 if hum then hum.WalkSpeed = 16 end
    elseif cmd == "jumppower" then OriginalSettings.JumpPower = tonumber(args[2]) or 50 if hum then hum.JumpPower = OriginalSettings.JumpPower end
    elseif cmd == "unjump" then OriginalSettings.JumpPower = 50 if hum then hum.JumpPower = 50 end
    elseif cmd == "gravity" then workspace.Gravity = tonumber(args[2]) or 196.2
    elseif cmd == "ungravity" then workspace.Gravity = 196.2
    elseif cmd == "float" then 
        States.Float = true
        local bv = Instance.new("BodyVelocity", root) bv.Name = "FloatVel" bv.Velocity = Vector3.new(0,0,0) bv.MaxForce = Vector3.new(0,math.huge,0)
    elseif cmd == "unfloat" then States.Float = false if root:FindFirstChild("FloatVel") then root.FloatVel:Destroy() end
    elseif cmd == "swim" then 
        States.Swim = true workspace.Gravity = 0 
        if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true) hum:ChangeState(Enum.HumanoidStateType.Swimming) end
    elseif cmd == "unswim" then 
        States.Swim = false workspace.Gravity = 196.2 
        if hum then hum:ChangeState(Enum.HumanoidStateType.Running) end
    elseif cmd == "tpwalk" then States.TpWalk = true States.TpWalkSpeed = tonumber(args[2]) or 5
    elseif cmd == "untpwalk" then States.TpWalk = false
    elseif cmd == "infjump" then States.InfJump = true
    elseif cmd == "uninfjump" then States.InfJump = false
    elseif cmd == "spin" then States.Spin = true States.SpinSpeed = tonumber(args[2]) or 20
    elseif cmd == "unspin" then States.Spin = false
    elseif cmd == "esp" or cmd == "chams" then States.Esp = true createNotification("ESP Enabled", true)
    elseif cmd == "noesp" then States.Esp = false createNotification("ESP Disabled", true)
    elseif cmd == "fullbright" then Lighting.Brightness = 2 Lighting.Ambient = Color3.new(1,1,1)
    elseif cmd == "unfullbright" then Lighting.Brightness = OriginalSettings.Brightness Lighting.Ambient = OriginalSettings.Ambient
    elseif cmd == "fov" then Camera.FieldOfView = tonumber(args[2]) or 70
    elseif cmd == "view" and args[2] then local t = getTargets(args[2])[1] if t then Camera.CameraSubject = t.Character.Humanoid end
    elseif cmd == "unview" then Camera.CameraSubject = hum
    elseif cmd == "xray" then States.Xray = true for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Transparency = 0.5 end end
    elseif cmd == "unxray" then States.Xray = false for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Transparency = 0 end end
    elseif cmd == "day" then Lighting.ClockTime = 14
    elseif cmd == "night" then Lighting.ClockTime = 0
    elseif cmd == "nofog" then Lighting.FogEnd = 100000
    elseif cmd == "reset" then if hum then hum.Health = 0 end
    elseif cmd == "sit" then if hum then hum.Sit = true end
    elseif cmd == "god" then States.GodMode = true createNotification("God Mode (Local)", true)
    elseif cmd == "ungod" then States.GodMode = false if hum then hum.MaxHealth = 100 end
    elseif cmd == "invisible" then for _,v in pairs(char:GetDescendants()) do if v:IsA("BasePart") or v:IsA("Decal") then v.Transparency = 1 end end
    elseif cmd == "visible" then for _,v in pairs(char:GetDescendants()) do if v:IsA("BasePart") or v:IsA("Decal") then v.Transparency = 0 end end
    elseif cmd == "noarms" then 
        if char:FindFirstChild("Left Arm") then char["Left Arm"]:Destroy() end 
        if char:FindFirstChild("Right Arm") then char["Right Arm"]:Destroy() end
        if char:FindFirstChild("LeftUpperArm") then char["LeftUpperArm"]:Destroy() char["LeftLowerArm"]:Destroy() char["LeftHand"]:Destroy() end
        if char:FindFirstChild("RightUpperArm") then char["RightUpperArm"]:Destroy() char["RightLowerArm"]:Destroy() char["RightHand"]:Destroy() end
    elseif cmd == "nolegs" then 
        if char:FindFirstChild("Left Leg") then char["Left Leg"]:Destroy() end
        if char:FindFirstChild("Right Leg") then char["Right Leg"]:Destroy() end
        if char:FindFirstChild("LeftUpperLeg") then char["LeftUpperLeg"]:Destroy() char["LeftLowerLeg"]:Destroy() char["LeftFoot"]:Destroy() end
        if char:FindFirstChild("RightUpperLeg") then char["RightUpperLeg"]:Destroy() char["RightLowerLeg"]:Destroy() char["RightFoot"]:Destroy() end
    elseif cmd == "naked" then if char:FindFirstChild("Shirt") then char.Shirt:Destroy() end if char:FindFirstChild("Pants") then char.Pants:Destroy() end
    elseif cmd == "blockhead" then if char.Head:FindFirstChild("Mesh") then char.Head.Mesh:Destroy() end
    elseif cmd == "drophats" then for _,v in pairs(char:GetChildren()) do if v:IsA("Accessory") then v.Parent = workspace end end
    elseif cmd == "nohats" then for _,v in pairs(char:GetChildren()) do if v:IsA("Accessory") then v:Destroy() end end
    elseif cmd == "hatspin" then States.HatSpin = true
    elseif cmd == "unhatspin" then States.HatSpin = false
    elseif cmd == "btools" or cmd == "f3x" then for i=1,4 do Instance.new("HopperBin", Player.Backpack).BinType = i end createNotification("BTools Given", true)
    elseif cmd == "gmsg" then showGlobalMessage(fullText ~= "" and fullText or "Void.Δ Broadcast")
    elseif cmd == "spam" then States.Spamming = true States.SpamText = fullText
    elseif cmd == "unspam" then States.Spamming = false
    elseif cmd == "bang" and args[2] then local t = getTargets(args[2])[1] if t then createNotification("Bang: " .. t.Name, true) end
    elseif cmd == "unbang" then createNotification("Unbanged", true)
    elseif cmd == "freeze" then if root then root.Anchored = true end
    elseif cmd == "thaw" then if root then root.Anchored = false end
    elseif cmd == "copyname" and args[2] then local t = getTargets(args[2])[1] if t then InfiniteField.Text = t.Name InfiniteField:CaptureFocus() end
    elseif cmd == "copyid" and args[2] then local t = getTargets(args[2])[1] if t then InfiniteField.Text = t.UserId InfiniteField:CaptureFocus() end
    elseif cmd == "roast" and args[2] then local t = getTargets(args[2])[1] if t then say(t.Name .. " is bad at this game!") end
    elseif cmd == "control" and args[2] then local t = getTargets(args[2])[1] if t then Camera.CameraSubject = t.Character.Humanoid end
    elseif cmd == "uncontrol" then Camera.CameraSubject = hum
    elseif cmd == "unlockws" then for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Locked = false end end createNotification("Workspace Unlocked", true)
    elseif cmd == "lockws" then for _,v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Locked = true end end
    elseif cmd == "delete" and args[2] then if workspace:FindFirstChild(args[2]) then workspace[args[2]]:Destroy() end
    elseif cmd == "headsit" and args[2] then local t = getTargets(args[2])[1] if t and t.Character then root.CFrame = t.Character.Head.CFrame + Vector3.new(0,2,0) hum.Sit = true end
    elseif cmd == "bring" and args[2] then local t = getTargets(args[2])[1] if t and t.Character then t.Character.HumanoidRootPart.CFrame = root.CFrame + Vector3.new(0,0,-5) end
    elseif cmd == "loopbring" and args[2] then States.LoopBring = getTargets(args[2])[1]
    elseif cmd == "unloopbring" then States.LoopBring = nil
    elseif cmd == "kill" and args[2] then local t = getTargets(args[2])[1] if t and t.Character then t.Character.Humanoid.Health = 0 t.Character:BreakJoints() end
    elseif cmd == "loopkill" and args[2] then States.LoopKill = getTargets(args[2])[1]
    elseif cmd == "unloopkill" then States.LoopKill = nil
    elseif cmd == "strengthen" then if hum then hum.MaxHealth = 500 hum.Health = 500 end
    elseif cmd == "weaken" then if hum then hum.MaxHealth = 10 hum.Health = 10 end
    elseif cmd == "breakvelocity" then root.Velocity = Vector3.new(0,0,0)
    elseif cmd == "friend" and args[2] then local t = getTargets(args[2])[1] if t then StarterGui:SetCore("PromptSendFriendRequest", t) end
    elseif cmd == "unfriend" and args[2] then local t = getTargets(args[2])[1] if t then StarterGui:SetCore("PromptUnfriend", t) end
    elseif cmd == "orbit" and args[2] then States.Orbit = getTargets(args[2])[1]
    elseif cmd == "unorbit" then States.Orbit = nil
    elseif cmd == "stare" and args[2] then States.Stare = getTargets(args[2])[1]
    elseif cmd == "unstare" then States.Stare = nil
    elseif cmd == "clear" then for _,c in pairs(ConsoleContent:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end logToConsole("Console Cleared.", Colors.Accent)
    elseif cmd == "tptool" then giveTPTool()
    elseif cmd == "clicktp" then States.ClickTP = true createNotification("Ctrl+Click to TP", true)
    elseif cmd == "unclicktp" then States.ClickTP = false
    else found = false end

    if found then createNotification("Script executed", true) logToConsole("Executed: " .. input, Colors.Success)
    else createNotification("Script not found", false) logToConsole("Error: unknown cmd", Colors.Danger) end
end

InfiniteField.FocusLost:Connect(function(e) if e then executeCommand(InfiniteField.Text) InfiniteField.Text = "" end end)

local function createScriptBtn(text, yPos)
    local btn = Instance.new("TextButton", ScriptsContent)
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Colors.Button
    btn.Text = "  " .. text
    btn.TextColor3 = Colors.Text
    btn.Font = "GothamMedium"
    btn.TextSize = 12
    btn.TextXAlignment = "Left"
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() InfiniteField.Text = text:gsub("<.->", ""):split(" ")[1] .. " " InfiniteField:CaptureFocus() end)
end

local function createMapBtn(name, position)
    local btn = Instance.new("TextButton", MapsContent)
    btn.BackgroundColor3 = Colors.CardInfo
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local title = Instance.new("TextLabel", btn)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Position = UDim2.new(0, 0, 1, -30)
    title.BackgroundTransparency = 1
    title.Text = name
    title.TextColor3 = Colors.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 12
    local icon = Instance.new("ImageLabel", btn)
    icon.Size = UDim2.new(0, 40, 0, 40)
    icon.Position = UDim2.new(0.5, -20, 0.5, -25)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://6035047409"
    icon.ImageColor3 = Colors.Accent
    btn.MouseButton1Click:Connect(function()
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
            createNotification("Teleported to " .. name, true)
        end
    end)
end

local cmds = {
    "guiscale <num>", "console", "dex", "remotespy", "executor", "serverinfo", "jobid", "rejoin", "serverhop", 
    "antiidle", "fly <speed>", "unfly", "flyspeed <num>", "noclip", "clip", "tptool", "goto <target>", "view <target>", 
    "speed <num>", "jumppower <num>", "gravity <num>", "float", "unfloat", "swim", "unswim", "fullbright", "nofog", 
    "fov <num>", "invisible", "visible", "btools", "gmsg <text>", "spam <text>", "unspam", "reset", "respawn", 
    "refresh", "sit", "lay", "infjump", "spin <speed>", "tppos <x y z>", "clicktp", "day", "night", "shutdown",
    "bang <player>", "unbang", "freeze", "thaw", "god", "ungod", "xray", "unxray", "freecam", "unfreecam", "firstp", 
    "thirdp", "noarms", "nolegs", "naked", "blockhead", "creeper", "drophats", "nohats", "hatspin", "unhatspin", 
    "tpwalk <num>", "untpwalk", "copyname <player>", "copyid <player>", "roast <player>", "headsit <player>", "control <player>", 
    "loopgoto <player>", "unloopgoto", "delete <part>", "f3x", "unlockws", "lockws", "notify <text>", "lastcommand",
    "loopbring", "unloopbring", "strengthen", "weaken", "breakvelocity", "outline", "unoutline", "partesp", "unpartesp",
    "clear", "friend <player>", "unfriend <player>", "stare <player>", "unstare", "orbit <player>", "unorbit",
    "wh <player>", "unwh", "loopkill <player>", "unloopkill", "kill <player>", "bring <player>"
}
for i, v in ipairs(cmds) do createScriptBtn(v, (i-1) * 38) end

createMapBtn("Crossroads", Vector3.new(0, 50, 0)) 
createMapBtn("Baseplate", Vector3.new(0, 10, 0))
createMapBtn("House", Vector3.new(0, 20, 0))

-- // RUNTIME LOOP //
Player.CharacterAdded:Connect(function(c) 
    local h = c:WaitForChild("Humanoid") 
    h.WalkSpeed = OriginalSettings.WalkSpeed 
    h.JumpPower = OriginalSettings.JumpPower 
    if States.Flying then updateFly() end 
end)

UserInputService.JumpRequest:Connect(function() 
    if States.InfJump and Player.Character then Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end 
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and States.ClickTP and input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        if Player.Character then Player.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0,3,0)) end
    end
end)

RunService.Heartbeat:Connect(function()
    if States.Spamming then say(States.SpamText) task.wait(1) end
end)

RunService.RenderStepped:Connect(function()
    local char = Player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    
    if States.Flying and root then
        local dir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown("W") then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown("S") then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown("A") then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown("D") then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown("Space") then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown("LeftShift") then dir = dir - Vector3.new(0,1,0) end
        if not root:FindFirstChild("FlyVelocity") then
            local bv = Instance.new("BodyVelocity", root) bv.Name = "FlyVelocity" bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
            local bg = Instance.new("BodyGyro", root) bg.Name = "FlyGyro" bg.P = 9e4 bg.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
        end
        root.FlyVelocity.Velocity = dir * States.FlySpeed
        root.FlyGyro.CFrame = Camera.CFrame
        hum.PlatformStand = true
    end
    
    if States.GodMode and hum then hum.Health = hum.MaxHealth end
    if States.Noclip then for _,v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
    if States.Spin and root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(States.SpinSpeed), 0) end
    if States.TpWalk and hum and hum.MoveDirection.Magnitude > 0 then root.CFrame = root.CFrame + hum.MoveDirection * States.TpWalkSpeed end
    if States.HatSpin then for _,v in pairs(char:GetChildren()) do if v:IsA("Accessory") then v.Handle.CFrame = v.Handle.CFrame * CFrame.Angles(0, math.rad(10), 0) end end end
    
    if States.LoopGoto and States.LoopGoto.Character then root.CFrame = States.LoopGoto.Character.HumanoidRootPart.CFrame end
    if States.LoopBring and States.LoopBring.Character then States.LoopBring.Character.HumanoidRootPart.CFrame = root.CFrame + Vector3.new(0,0,-5) end
    if States.LoopKill and States.LoopKill.Character then States.LoopKill.Character:BreakJoints() end
    
    if States.Orbit and States.Orbit.Character then
        local x = math.cos(tick()) * 10
        local z = math.sin(tick()) * 10
        root.CFrame = States.Orbit.Character.HumanoidRootPart.CFrame * CFrame.new(x, 0, z)
        Camera.CameraSubject = States.Orbit.Character.Humanoid
    end
    if States.Stare and States.Stare.Character then root.CFrame = CFrame.new(root.Position, States.Stare.Character.HumanoidRootPart.Position) end
    
    if States.Esp then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Player and p.Character and not p.Character:FindFirstChild("DeltaESP") then
                local h = Instance.new("Highlight", p.Character) h.Name = "DeltaESP" h.FillColor = Colors.Accent h.OutlineColor = Color3.new(1,1,1) h.FillTransparency = 0.5
            end
        end
    end
    
    local now = tick()
    if not _G.lastStatsTime or now - _G.lastStatsTime >= 1 then
        _G.lastStatsTime = now
        FPSValue.Text = tostring(math.floor(1 / RunService.RenderStepped:Wait()))
        PlayersValue.Text = tostring(#Players:GetPlayers())
        PingValue.Text = tostring(math.round(Player:GetNetworkPing() * 1000)) .. " ms"
        TimeValue.Text = os.date("%X")
    end
end)
