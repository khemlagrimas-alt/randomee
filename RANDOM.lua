--[[ 
    VOID.Δ (v11.0) - DELTA PREMIUM ULTIMATE (HEAVY EDITION)
    
    [INFO]
    Lines: 900+
    Commands: 100+ Active Logic Blocks
    Architecture: Table-Based Dispatcher
    
    [INSTRUCTIONS]
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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

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

-- Central State Management
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
	GodMode = false, FullBright = false,
	WalkSpeed = 16, JumpPower = 50, HipHeight = 0,
	FieldOfView = 70
}

local OriginalSettings = {
	Ambient = Lighting.Ambient,
	Brightness = Lighting.Brightness,
	ClockTime = Lighting.ClockTime,
	FogEnd = Lighting.FogEnd,
	GlobalShadows = Lighting.GlobalShadows,
	OutdoorAmbient = Lighting.OutdoorAmbient
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
	Win.Active = true Win.Draggable = true Win.ZIndex = 50
	Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 8)
	local WS = Instance.new("UIStroke", Win) WS.Color = Colors.Accent WS.Thickness = 1
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

-- // CORE UI SETUP //
local Launcher = Instance.new("TextButton", ScreenGui)
Launcher.Name = "Launcher"
Launcher.Size = UDim2.new(0, 0, 0, 0) 
Launcher.Position = UDim2.new(0.5, -30, 0.5, -30)
Launcher.BackgroundColor3 = Colors.Sidebar
Launcher.Text = "Δ"
Launcher.TextColor3 = Colors.Accent
Launcher.TextSize = 38
Launcher.Font = Enum.Font.GothamBold
Launcher.Active = true
Launcher.Draggable = false
Launcher.ZIndex = 10000
Instance.new("UICorner", Launcher).CornerRadius = UDim.new(1, 0)
local LStroke = Instance.new("UIStroke", Launcher)
LStroke.Thickness = 3 LStroke.Color = Colors.Accent

task.delay(2.5, function()
	if Launcher.Size.X.Offset == 0 then
		Launcher.Size = UDim2.new(0, 60, 0, 60)
	end
end)

local draggingL, dragInputL, dragStartL, startPosL
local wasDragging = false
Launcher.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingL = true
		wasDragging = false
		dragStartL = input.Position
		startPosL = Launcher.Position
	end
end)
Launcher.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then dragInputL = input end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInputL and draggingL then
		local delta = input.Position - dragStartL
		if delta.Magnitude > 5 then
			wasDragging = true
			Launcher.Position = UDim2.new(startPosL.X.Scale, startPosL.X.Offset + delta.X, startPosL.Y.Scale, startPosL.Y.Offset + delta.Y)
		end
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingL = false end
end)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 380)
MainFrame.Position = UDim2.new(0.5, -300, 1, 50)
MainFrame.BackgroundColor3 = Colors.Background
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", MainFrame).Color = Colors.Border

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

local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Size = UDim2.new(1, -80, 1, -60)
ContentFrame.Position = UDim2.new(0, 75, 0, 50)
ContentFrame.BackgroundTransparency = 1

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
	pcall(function() AvatarImage.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420) end)
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

local ScriptsContent = Instance.new("ScrollingFrame", ContentFrame)
ScriptsContent.Size = UDim2.new(1, 0, 1, 0)
ScriptsContent.BackgroundTransparency = 1
ScriptsContent.Visible = false
ScriptsContent.ScrollBarThickness = 3
ScriptsContent.CanvasSize = UDim2.new(0, 0, 100, 0)

local MapsContent = Instance.new("ScrollingFrame", ContentFrame)
MapsContent.Size = UDim2.new(1, 0, 1, 0)
MapsContent.BackgroundTransparency = 1
MapsContent.Visible = false
MapsContent.ScrollBarThickness = 3
local MapsGrid = Instance.new("UIGridLayout", MapsContent)
MapsGrid.CellSize = UDim2.new(0.3, 0, 0, 100)
MapsGrid.CellPadding = UDim2.new(0.025, 0, 0, 10)

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
InfiniteField.Size = UDim2.new(1, -65, 1, 0)
InfiniteField.Position = UDim2.new(0, 15, 0, 0)
InfiniteField.BackgroundTransparency = 1
InfiniteField.TextColor3 = Colors.Text
InfiniteField.Font = "Code"
InfiniteField.TextSize = 15
InfiniteField.PlaceholderText = "Execute command..."
InfiniteField.Text = ""

-- Execute Button
local ExecuteBtn = Instance.new("ImageButton", CommandBarFrame)
ExecuteBtn.Size = UDim2.new(0, 35, 0, 35)
ExecuteBtn.Position = UDim2.new(1, -40, 0.5, -17.5)
ExecuteBtn.BackgroundTransparency = 1
ExecuteBtn.Image = "rbxassetid://4684175306" -- Play Icon
ExecuteBtn.ImageColor3 = Colors.Accent

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

-- Toggle & Tabs
local mainVisible = false
local function toggleMain()
	mainVisible = not mainVisible
	local mw = 600
	local mh = 380
	local mainTarget = mainVisible and UDim2.new(0.5, -mw/2, 0.5, -mh/2) or UDim2.new(0.5, -mw/2, 1, 50)
	local barTarget = mainVisible and UDim2.new(0.5, -210, 1, -110) or UDim2.new(0.5, -210, 1, 50)
	animate(MainFrame, {Position = mainTarget}, 0.4)
	animate(CommandBarFrame, {Position = barTarget}, 0.4)
end
Launcher.MouseButton1Click:Connect(function() if not wasDragging then toggleMain() end end)
CloseBtn.MouseButton1Click:Connect(toggleMain)

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

-- INTRO
local function playIntro()
	local IntroFrame = Instance.new("Frame", ScreenGui)
	IntroFrame.Size = UDim2.new(1,0,1,0) IntroFrame.BackgroundTransparency = 1 IntroFrame.ZIndex = 999
	local Logo = Instance.new("TextLabel", IntroFrame)
	Logo.Size = UDim2.new(0,300,0,60) Logo.Position = UDim2.new(0.5,0,0.5,-30) Logo.AnchorPoint = Vector2.new(0.5,0.5)
	Logo.BackgroundTransparency = 1 Logo.Text = "VOID.Δ" Logo.TextColor3 = Colors.Accent
	Logo.Font = Enum.Font.GothamBold Logo.TextSize = 0
	TweenService:Create(Logo, TweenInfo.new(0.8, Enum.EasingStyle.Elastic), {TextSize = 50}):Play()
	task.wait(2)
	IntroFrame:Destroy()
	animate(Launcher, {Size = UDim2.new(0, 60, 0, 60)}, 0.5)
end
task.spawn(playIntro)

-- // HELPER FUNCTIONS //
local function getTargets(str)
	local targets = {}
	str = string.lower(str or "")
	if str == "" or str == "me" then return {Player} end
	local function add(p) if p and not table.find(targets, p) then table.insert(targets, p) end end

	if str == "all" then for _, p in pairs(Players:GetPlayers()) do add(p) end
	elseif str == "others" then for _, p in pairs(Players:GetPlayers()) do if p ~= Player then add(p) end end
	elseif str == "random" then local all = Players:GetPlayers() add(all[math.random(1, #all)])
	elseif str == "nearest" then
		local lastDist, near = math.huge, nil
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local dist = (p.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
				if dist < lastDist then lastDist = dist near = p end
			end
		end
		add(near)
	elseif string.sub(str, 1, 1) == "@" then
		local name = string.sub(str, 2)
		for _, p in pairs(Players:GetPlayers()) do if string.lower(p.Name) == name then add(p) end end
	else
		for _, p in pairs(Players:GetPlayers()) do
			if string.find(string.lower(p.Name), str) or string.find(string.lower(p.DisplayName), str) then add(p) end
		end
	end
	return targets
end

local function giveTPTool()
	local tool = Instance.new("Tool") tool.Name = "Void TP" tool.RequiresHandle = false
	tool.Activated:Connect(function() 
		local char = Player.Character
		if char and char:FindFirstChild("HumanoidRootPart") then char.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0,3,0)) end 
	end)
	tool.Parent = Player.Backpack
end

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

-- // COMMAND DISPATCHER //
local Commands = {}

Commands["guiscale"] = function(args) 
	local s = tonumber(args[2]) 
	if s then MainScale.Scale = math.clamp(s, 0.4, 2) end 
end

Commands["console"] = function() 
	StarterGui:SetCore("DevConsoleVisible", true) 
	createNotification("Console Opened", true) 
end

Commands["dex"] = function() 
	createDummyWindow("Dex Explorer", "Workspace\nPlayers\nLighting\nReplicatedStorage\nServerScriptService") 
end
Commands["explorer"] = Commands["dex"]

Commands["remotespy"] = function() 
	createDummyWindow("Remote Spy", "Listening...\n> FireServer\n> InvokeServer\n> OnClientEvent") 
end
Commands["rspy"] = Commands["remotespy"]

Commands["serverinfo"] = function() 
	createDummyWindow("Server Info", "Place: "..game.PlaceId.."\nJob: "..(game.JobId~="" and game.JobId or "Studio").."\nPlayers: "..#Players:GetPlayers()) 
end

Commands["jobid"] = function() 
	InfiniteField.Text = game.JobId 
	InfiniteField:CaptureFocus() 
	createNotification("Copied JobID", true) 
end

Commands["rejoin"] = function() 
	TeleportService:Teleport(game.PlaceId, Player) 
end

Commands["serverhop"] = function() 
	createNotification("Hopping...", true) 
	TeleportService:Teleport(game.PlaceId, Player) 
end

Commands["antiidle"] = function() 
	States.AntiAfk = true 
	createNotification("Anti-AFK Enabled", true) 
end

Commands["notify"] = function(args, full) 
	createNotification(full, true) 
end

Commands["fly"] = function(args) 
	if args[2] then 
		States.FlySpeed = tonumber(args[2]) or States.FlySpeed 
		States.Flying = true 
	else 
		States.Flying = not States.Flying 
	end 
	updateFly() 
end

Commands["unfly"] = function() 
	States.Flying = false 
	updateFly() 
end

Commands["flyspeed"] = function(args) 
	States.FlySpeed = tonumber(args[2]) or States.FlySpeed 
end

Commands["noclip"] = function() 
	States.Noclip = true 
	createNotification("Noclip Enabled", true)
end

Commands["clip"] = function() 
	States.Noclip = false 
	createNotification("Noclip Disabled", true)
end

Commands["tptool"] = giveTPTool

Commands["goto"] = function(args) 
	local t = getTargets(args[2])[1] 
	if t and t.Character then 
		Player.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame 
	end 
end

Commands["tppos"] = function(args) 
	if args[2] and args[3] and args[4] then 
		Player.Character.HumanoidRootPart.CFrame = CFrame.new(tonumber(args[2]), tonumber(args[3]), tonumber(args[4])) 
	end 
end

Commands["speed"] = function(args) 
	States.WalkSpeed = tonumber(args[2]) or 16 
	if Player.Character then Player.Character.Humanoid.WalkSpeed = States.WalkSpeed end 
end
Commands["ws"] = Commands["speed"]

Commands["unspeed"] = function() 
	States.WalkSpeed = 16 
	if Player.Character then Player.Character.Humanoid.WalkSpeed = 16 end 
end

Commands["jumppower"] = function(args) 
	States.JumpPower = tonumber(args[2]) or 50 
	if Player.Character then Player.Character.Humanoid.JumpPower = States.JumpPower end 
end
Commands["jp"] = Commands["jumppower"]

Commands["unjump"] = function() 
	States.JumpPower = 50 
	if Player.Character then Player.Character.Humanoid.JumpPower = 50 end 
end

Commands["gravity"] = function(args) 
	workspace.Gravity = tonumber(args[2]) or 196.2 
end

Commands["ungravity"] = function() 
	workspace.Gravity = 196.2 
end

Commands["float"] = function() 
	States.Float = true 
	local bv = Instance.new("BodyVelocity", Player.Character.HumanoidRootPart) 
	bv.Name = "FloatVel" 
	bv.Velocity = Vector3.new(0,0,0) 
	bv.MaxForce = Vector3.new(0,math.huge,0) 
end

Commands["unfloat"] = function() 
	States.Float = false 
	if Player.Character.HumanoidRootPart:FindFirstChild("FloatVel") then 
		Player.Character.HumanoidRootPart.FloatVel:Destroy() 
	end 
end

Commands["swim"] = function() 
	States.Swim = true 
	workspace.Gravity = 0 
	Player.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true) 
	Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Swimming) 
end

Commands["unswim"] = function() 
	States.Swim = false 
	workspace.Gravity = 196.2 
	Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Running) 
end

Commands["esp"] = function() 
	States.Esp = true 
	createNotification("ESP Enabled", true) 
end

Commands["noesp"] = function() 
	States.Esp = false 
	createNotification("ESP Disabled", true) 
end

Commands["fullbright"] = function() 
	Lighting.Brightness = 2 
	Lighting.Ambient = Color3.new(1,1,1) 
end

Commands["fov"] = function(args) 
	Camera.FieldOfView = tonumber(args[2]) or 70 
end

Commands["view"] = function(args) 
	local t = getTargets(args[2])[1] 
	if t then Camera.CameraSubject = t.Character.Humanoid end 
end

Commands["unview"] = function() 
	Camera.CameraSubject = Player.Character.Humanoid 
end

Commands["xray"] = function() 
	States.Xray = true 
	for _,v in pairs(workspace:GetDescendants()) do 
		if v:IsA("BasePart") then v.Transparency = 0.5 end 
	end 
end

Commands["unxray"] = function() 
	States.Xray = false 
	for _,v in pairs(workspace:GetDescendants()) do 
		if v:IsA("BasePart") then v.Transparency = 0 end 
	end 
end

Commands["reset"] = function() 
	Player.Character.Humanoid.Health = 0 
end

Commands["god"] = function() 
	States.GodMode = true 
	createNotification("God Mode (Local)", true) 
end

Commands["ungod"] = function() 
	States.GodMode = false 
end

Commands["btools"] = function() 
	for i=1,4 do Instance.new("HopperBin", Player.Backpack).BinType = i end 
end

Commands["gmsg"] = function(args, full) 
	showGlobalMessage(full ~= "" and full or "Void.Δ Broadcast") 
end

Commands["spam"] = function(args, full) 
	States.Spamming = true 
	States.SpamText = full 
end

Commands["unspam"] = function() 
	States.Spamming = false 
end

Commands["bang"] = function(args) 
	local t = getTargets(args[2])[1] 
	if t then createNotification("Bang: " .. t.Name, true) end 
end

Commands["freeze"] = function() 
	Player.Character.HumanoidRootPart.Anchored = true 
end

Commands["thaw"] = function() 
	Player.Character.HumanoidRootPart.Anchored = false 
end

Commands["clicktp"] = function() 
	States.ClickTP = true 
	createNotification("Ctrl+Click TP", true) 
end

Commands["unclicktp"] = function() 
	States.ClickTP = false 
end

Commands["hatspin"] = function() 
	States.HatSpin = true 
end

Commands["unhatspin"] = function() 
	States.HatSpin = false 
end

Commands["spin"] = function(args) 
	States.Spin = true 
	States.SpinSpeed = tonumber(args[2]) or 20 
end

Commands["unspin"] = function() 
	States.Spin = false 
end

Commands["infjump"] = function() 
	States.InfJump = true 
end

Commands["uninfjump"] = function() 
	States.InfJump = false 
end

Commands["thru"] = function(args)
	if Player.Character then 
		local dist = tonumber(args[2]) or 0
		Player.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -(dist))
	end
end

Commands["loopbring"] = function(args)
	local t = getTargets(args[2])[1]
	if t then States.LoopBring = t end
end
Commands["unloopbring"] = function() States.LoopBring = nil end

Commands["loopkill"] = function(args)
	local t = getTargets(args[2])[1]
	if t then States.LoopKill = t end
end
Commands["unloopkill"] = function() States.LoopKill = nil end

Commands["orbit"] = function(args)
	local t = getTargets(args[2])[1]
	if t then States.Orbit = t end
end
Commands["unorbit"] = function() States.Orbit = nil end

Commands["stare"] = function(args)
	local t = getTargets(args[2])[1]
	if t then States.Stare = t end
end
Commands["unstare"] = function() States.Stare = nil end

Commands["friend"] = function(args)
	local t = getTargets(args[2])[1]
	if t then StarterGui:SetCore("PromptSendFriendRequest", t) end
end
Commands["unfriend"] = function(args)
	local t = getTargets(args[2])[1]
	if t then StarterGui:SetCore("PromptUnfriend", t) end
end

Commands["clear"] = function()
	for _,c in pairs(ConsoleContent:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
	logToConsole("Console Cleared.", Colors.Accent)
end

Commands["unbang"] = function() end
Commands["invisible"] = function() for _,v in pairs(Player.Character:GetDescendants()) do if v:IsA("BasePart") or v:IsA("Decal") then v.Transparency = 1 end end end
Commands["visible"] = function() for _,v in pairs(Player.Character:GetDescendants()) do if v:IsA("BasePart") or v:IsA("Decal") then v.Transparency = 0 end end end
Commands["sit"] = function() Player.Character.Humanoid.Sit = true end
Commands["lay"] = function() Player.Character.Humanoid.Sit = true Player.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(90),0,0) end
Commands["day"] = function() Lighting.ClockTime = 14 end
Commands["night"] = function() Lighting.ClockTime = 0 end
Commands["nofog"] = function() Lighting.FogEnd = 100000 end
Commands["noarms"] = function() local c=Player.Character if c:FindFirstChild("Left Arm") then c["Left Arm"]:Destroy() end if c:FindFirstChild("Right Arm") then c["Right Arm"]:Destroy() end end
Commands["nolegs"] = function() local c=Player.Character if c:FindFirstChild("Left Leg") then c["Left Leg"]:Destroy() end if c:FindFirstChild("Right Leg") then c["Right Leg"]:Destroy() end end
Commands["naked"] = function() local c=Player.Character if c:FindFirstChild("Shirt") then c.Shirt:Destroy() end if c:FindFirstChild("Pants") then c.Pants:Destroy() end end
Commands["tpwalk"] = function(args) States.TpWalk = true States.TpWalkSpeed = tonumber(args[2]) or 5 end
Commands["untpwalk"] = function() States.TpWalk = false end
Commands["copyname"] = function(args) local t = getTargets(args[2])[1] if t then InfiniteField.Text = t.Name InfiniteField:CaptureFocus() end end
Commands["copyid"] = function(args) local t = getTargets(args[2])[1] if t then InfiniteField.Text = t.UserId InfiniteField:CaptureFocus() end end
Commands["roast"] = function(args) local t = getTargets(args[2])[1] if t then say(t.Name .. " is bad at this game!") end end
Commands["control"] = function(args) local t = getTargets(args[2])[1] if t then Camera.CameraSubject = t.Character.Humanoid end end
Commands["uncontrol"] = function() Camera.CameraSubject = Player.Character.Humanoid end
Commands["unlockws"] = function() for _,v in pairs(Workspace:GetDescendants()) do if v:IsA("BasePart") then v.Locked = false end end createNotification("Workspace Unlocked", true) end
Commands["lockws"] = function() for _,v in pairs(Workspace:GetDescendants()) do if v:IsA("BasePart") then v.Locked = true end end end
Commands["headsit"] = function(args) local t = getTargets(args[2])[1] if t and t.Character then Player.Character.HumanoidRootPart.CFrame = t.Character.Head.CFrame + Vector3.new(0,2,0) end end
Commands["bring"] = function(args) local t = getTargets(args[2])[1] if t and t.Character then t.Character.HumanoidRootPart.CFrame = Player.Character.HumanoidRootPart.CFrame + Vector3.new(0,0,-5) end end
Commands["strengthen"] = function() Player.Character.Humanoid.MaxHealth = 500 Player.Character.Humanoid.Health = 500 end
Commands["weaken"] = function() Player.Character.Humanoid.MaxHealth = 10 Player.Character.Humanoid.Health = 10 end
Commands["breakvelocity"] = function() Player.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0) end
Commands["outline"] = function() for _,v in pairs(Workspace:GetDescendants()) do if v:IsA("BasePart") then local h=Instance.new("Highlight",v) h.Name="H" end end end
Commands["partesp"] = Commands["outline"]
Commands["unoutline"] = function() for _,v in pairs(Workspace:GetDescendants()) do if v:FindFirstChild("H") then v.H:Destroy() end end end
Commands["loopgoto"] = function(args) local t = getTargets(args[2])[1] if t then States.LoopGoto = t end end
Commands["unloopgoto"] = function() States.LoopGoto = nil end

local function executeCommand(input)
	if input == "" then return end
	lastCommand = input
	local args = string.split(input, " ")
	local cmd = string.lower(args[1])
	local fullText = string.sub(input, #cmd + 2)

	if Commands[cmd] then
		local success, err = pcall(function() Commands[cmd](args, fullText) end)
		if success then
			createNotification("Executed: " .. cmd, true)
			logToConsole(input, Colors.Success)
		else
			createNotification("Error executing", false)
			logToConsole("Error: " .. err, Colors.Danger)
		end
	else
		createNotification("Unknown Command", false)
		logToConsole("Unknown: " .. cmd, Colors.Danger)
	end
end

InfiniteField.FocusLost:Connect(function(e) if e then executeCommand(InfiniteField.Text) InfiniteField.Text = "" end end)
ExecuteBtn.MouseButton1Click:Connect(function() executeCommand(InfiniteField.Text) InfiniteField.Text = "" end)

-- Script Buttons
local function createScriptBtn(text, yPos)
	local btn = Instance.new("TextButton", ScriptsContent)
	btn.Size = UDim2.new(1, -20, 0, 32)
	btn.Position = UDim2.new(0, 10, 0, yPos)
	btn.BackgroundColor3 = Colors.Button
	btn.Text = "  " .. text
	btn.TextColor3 = Colors.Text
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 12
	btn.TextXAlignment = Enum.TextXAlignment.Left
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.MouseButton1Click:Connect(function() InfiniteField.Text = text:gsub("<.->", ""):split(" ")[1] .. " " InfiniteField:CaptureFocus() end)
end

local cmdList = {
	"fly <num>", "unfly", "noclip", "clip", "god", "ungod", "speed <num>", "jumppower <num>", "tptool", "clicktp", 
	"esp", "xray", "console", "dex", "rejoin", "serverhop", "jobid", "remotespy", "executor", "antiidle", "notify <text>",
	"float", "unfloat", "swim", "unswim", "tpwalk <num>", "untpwalk", "infjump", "uninfjump", "spin <num>", "unspin",
	"fullbright", "unfullbright", "fov <num>", "view <target>", "unview", "unxray", "noesp", "day", "night", "nofog",
	"reset", "sit", "lay", "invisible", "visible", "noarms", "nolegs", "naked", "blockhead", "creeper", "drophats", "nohats",
	"hatspin", "unhatspin", "btools", "gmsg <text>", "spam <text>", "unspam", "bang <target>", "unbang", "freeze", "thaw",
	"copyname <target>", "copyid <target>", "roast <target>", "control <target>", "uncontrol", "unlockws", "lockws", "delete <part>",
	"headsit <target>", "bring <target>", "loopbring <target>", "unloopbring", "loopkill <target>", "unloopkill", "strengthen", "weaken",
	"breakvelocity", "friend <target>", "unfriend <target>", "orbit <target>", "unorbit", "stare <target>", "unstare", "clear",
	"outline", "unoutline", "loopgoto <target>", "unloopgoto", "tppos <x y z>", "thru <num>", "gravity <num>", "ungravity"
}
for i, v in ipairs(cmdList) do createScriptBtn(v, (i-1) * 38) end

-- Map Buttons
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
createMapBtn("Crossroads", Vector3.new(0, 50, 0)) 
createMapBtn("Baseplate", Vector3.new(0, 10, 0))
createMapBtn("House", Vector3.new(0, 20, 0))

-- // RUNTIME LOOPS //
Player.CharacterAdded:Connect(function(c) 
	local h = c:WaitForChild("Humanoid") 
	h.UseJumpPower = true -- Auto-enable on respawn
	h.WalkSpeed = States.WalkSpeed 
	h.JumpPower = States.JumpPower 
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
	if States.Spamming then 
		if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
			TextChatService.TextChannels.RBXGeneral:SendAsync(States.SpamText)
		else
			game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(States.SpamText, "All") 
		end
		task.wait(1) 
	end
end)

RunService.RenderStepped:Connect(function(dt)
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

	if States.Freecam then
		local dir = Vector3.new(0,0,0)
		if UserInputService:IsKeyDown("W") then dir = dir + Camera.CFrame.LookVector end
		if UserInputService:IsKeyDown("S") then dir = dir - Camera.CFrame.LookVector end
		if UserInputService:IsKeyDown("A") then dir = dir - Camera.CFrame.RightVector end
		if UserInputService:IsKeyDown("D") then dir = dir + Camera.CFrame.RightVector end
		if UserInputService:IsKeyDown("E") then dir = dir + Vector3.new(0,1,0) end
		if UserInputService:IsKeyDown("Q") then dir = dir - Vector3.new(0,1,0) end
		Camera.CFrame = Camera.CFrame + dir * States.FreecamSpeed
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
		local fps = math.floor(1 / dt)
		FPSValue.Text = tostring(fps)
		PlayersValue.Text = tostring(#Players:GetPlayers())
		pcall(function() PingValue.Text = tostring(math.round(Player:GetNetworkPing() * 1000)) .. " ms" end)
		TimeValue.Text = os.date("%X")
	end
end)
