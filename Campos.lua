-- ============================================================
-- SHADOW PROTOCOL - MASTER LOADER (COMPLETE UI & INTEGRATION)
-- ============================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local StatsService = game:GetService("Stats")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Cerrar efectos de ambiente generales sin afectar sistemas de puntería
for _, effect in ipairs(Lighting:GetChildren()) do
    if (effect:IsA("BlurEffect") or effect:IsA("DepthOfFieldEffect")) and not effect.Name:lower():find("aim") then
        effect.Enabled = false
    end
end

-- ---------------- [[ CONFIGURATION ]] ----------------
local CONFIG = {
    DiscordInvite = "https://discord.gg/2p59z7pHYk", -- Enlace actualizado de Discord
    DiscordWebhook = "", 
    
    StatusUrl = "https://raw.githubusercontent.com/bodxz/xz-hub/refs/heads/main/games_status",
    AnnouncementUrl = "https://raw.githubusercontent.com/bodxz/xz-hub/refs/heads/main/announcement", 
    FallbackAnnouncement = "NOTICE: Shadow Protocol Online | Join Discord for changelogs & script updates!",
    
    SoundEnabled = true,
    ParticlesEnabled = true,
    AutoInjectEnabled = true,
    ToggleKey = Enum.KeyCode.RightControl,
    
    Sounds = {
        Click = "rbxassetid://6895079853",
        Success = "rbxassetid://6895079527",
        Error = "rbxassetid://9069609268"
    }
}

-- ---------------- [[ STATE & PERSISTENCE ]] ----------------
local isDestroyed = false
local isProcessing = false
local isKeyListening = false
local keybindConnection = nil
local fpsConnection = nil

local function getEnvValue(name)
    local env = (typeof(getgenv) == "function" and getgenv()) or getfenv()
    return env[name]
end

local SettingsPath = "ShadowProtocol_Settings.json"

local function saveSettings()
    local writeFunc = getEnvValue("writefile")
    if not writeFunc then return end
    local payload = {
        SoundEnabled = CONFIG.SoundEnabled,
        ParticlesEnabled = CONFIG.ParticlesEnabled,
        AutoInjectEnabled = CONFIG.AutoInjectEnabled,
        ToggleKey = CONFIG.ToggleKey.Name
    }
    pcall(function()
        writeFunc(SettingsPath, HttpService:JSONEncode(payload))
    end)
end

local function loadSettings()
    local isfileFunc = getEnvValue("isfile")
    local readFunc = getEnvValue("readfile")
    if not (isfileFunc and readFunc) then return end
    local ok, fileExists = pcall(isfileFunc, SettingsPath)
    if not (ok and fileExists) then return end
    local readOk, content = pcall(readFunc, SettingsPath)
    if not (readOk and content) then return end
    local decodeOk, data = pcall(function()
        return HttpService:JSONDecode(content)
    end)
    if decodeOk and typeof(data) == "table" then
        if typeof(data.SoundEnabled) == "boolean" then CONFIG.SoundEnabled = data.SoundEnabled end
        if typeof(data.ParticlesEnabled) == "boolean" then CONFIG.ParticlesEnabled = data.ParticlesEnabled end
        if typeof(data.AutoInjectEnabled) == "boolean" then CONFIG.AutoInjectEnabled = data.AutoInjectEnabled end
        if typeof(data.ToggleKey) == "string" then
            local kc = Enum.KeyCode[data.ToggleKey]
            if kc then CONFIG.ToggleKey = kc end
        end
    end
end

loadSettings()

local function cleanupHub()
    isDestroyed = true
    if keybindConnection then keybindConnection:Disconnect() end
    if fpsConnection then fpsConnection:Disconnect() end
end

task.spawn(function()
    pcall(function()
        local virtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            virtualUser:CaptureController()
            virtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end)
end)

local function getSafeGui()
    local getHuiFunc = rawget(getfenv(), "gethui") or (typeof(getgenv) == "function" and getgenv().gethui)
    if typeof(getHuiFunc) == "function" then 
        return getHuiFunc()
    end
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if success and coreGui then return coreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local GuiParent = getSafeGui()
local existing = GuiParent:FindFirstChild("ShadowProtocol_Master")
if existing then existing:Destroy() end

-- ---------------- [[ GAME DATABASE ]] ----------------
local SupportedGames = {
    {
        Id = 13794093709,
        MatchByGameId = 4785126950,
        SubPlaces = { 13794093709 },
        Name = "Scorched Earth",
        ScriptUrl = "https://raw.githubusercontent.com/bodxz/xz-hub/refs/heads/main/Scorched%20Earth%20by%20xz%20hub"
    },
    {
        Id = 137233438285284,
        Name = "Chicken Farm",
        ScriptUrl = "https://raw.githubusercontent.com/bodxz/xz-hub/refs/heads/main/Chicken%20Farm%20by%20xz%20hub"
    },
    {
        Id = 91994812344752,
        MatchByGameId = 9617037991,
        SubPlaces = { 91994812344752, 9617037991 },
        Name = "Virtual Football",
        ScriptUrl = "https://raw.githubusercontent.com/bodxz/xz-hub/refs/heads/main/Virtual%20Football%20by%20xz%20hub"
    },
    {
        Id = 117433621747604,
        MatchByGameId = 10224849445,
        SubPlaces = { 117433621747604, 10224849445 },
        Name = "Be the King",
        ScriptUrl = "https://raw.githubusercontent.com/bodxz/xz-hub/refs/heads/main/Be%20the%20King%20by%20xz%20hub"
    },
    {
        Id = 132640332499066,
        Name = "Global Anarchy",
        ScriptUrl = "https://raw.githubusercontent.com/bodxz/xz-hub/refs/heads/main/Global%20Anarchy%20by%20xz%20hub"
    },
    {
        Id = 15278322858,
        Name = "Lexington & Concord",
        ScriptUrl = "https://raw.githubusercontent.com/bodxz/xz-hub/refs/heads/main/Lexington%20%26%20Concord%20by%20xz%20hub"
    },
    {
        Id = 3678761576,
        Name = "ENTRENCHED WW1",
        ScriptUrl = "https://raw.githubusercontent.com/bodxz/xz-hub/refs/heads/main/ENTRENCHED%20WW1%20by%20xz%20hub"
    },
    {
        Id = 94217045453265,
        MatchByGameId = 9051406594,
        SubPlaces = { 94217045453265 },
        Name = "Dueling Grounds",
        ScriptUrl = "https://raw.githubusercontent.com/bodxz/xz-hub/refs/heads/main/Dueling%20Grounds%20by%20xz%20hub"
    },
    {
        Id = 129216769649527,
        MatchByGameId = 10501944811,
        SubPlaces = { 129216769649527 },
        Name = "Beat the Anime Boss",
        ScriptUrl = "https://raw.githubusercontent.com/bodxz/xz-hub/refs/heads/main/Beat%20the%20Anime%20Boss%20by%20xz%20hub"
    },
    {
        Id = 18177090186,
        MatchByGameId = 6162715284,
        SubPlaces = { 18177090186 },
        Name = "LB Futbol",
        ScriptUrl = "https://raw.githubusercontent.com/bodxz/xz-hub/refs/heads/main/Lb%20Futbol%20by%20xz%20hub"
    },
    {
        Id = 100971017807798,
        MatchByGameId = 10666192800,
        SubPlaces = { 100971017807798 },
        Name = "Bug Fixes",
        ScriptUrl = "https://raw.githubusercontent.com/bodxz/xz-hub/refs/heads/main/Bug%20Fixes%20by%20xz%20hub"
    }
}

local function isGameMatched(gameData)
    local currentPlaceStr = tostring(game.PlaceId)
    local currentGameStr = tostring(game.GameId)
    if currentPlaceStr == tostring(gameData.Id) then return true end
    if gameData.SubPlaces and typeof(gameData.SubPlaces) == "table" then
        for _, subId in ipairs(gameData.SubPlaces) do
            if currentPlaceStr == tostring(subId) then return true end
        end
    end
    if gameData.MatchByGameId and currentGameStr == tostring(gameData.MatchByGameId) then return true end
    return false
end

local StatusColors = {
    ["Working"] = Color3.fromRGB(80, 220, 110),
    ["Updating"] = Color3.fromRGB(240, 195, 60),
    ["Discontinued"] = Color3.fromRGB(225, 50, 50)
}

local function fetchGameStatuses()
    local statuses = {}
    if CONFIG.StatusUrl ~= "" then
        local success, res = pcall(function() return game:HttpGet(CONFIG.StatusUrl) end)
        if success and res then
            local decodeSuccess, data = pcall(function() return HttpService:JSONDecode(res) end)
            if decodeSuccess and typeof(data) == "table" then statuses = data end
        end
    end
    return statuses
end

local RemoteStatuses = fetchGameStatuses()
local function getGameStatus(gameData)
    local mainIdStr = tostring(gameData.Id)
    local currentPlaceStr = tostring(game.PlaceId)
    if RemoteStatuses[currentPlaceStr] then return RemoteStatuses[currentPlaceStr] end
    if RemoteStatuses[mainIdStr] then return RemoteStatuses[mainIdStr] end
    return "Working"
end

local function playSound(soundId)
    if not CONFIG.SoundEnabled or soundId == "" then return end
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 0.6
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end

local function copyClipboard(text)
    local clipFunc = rawget(getfenv(), "setclipboard") or rawget(getfenv(), "toclipboard") or (typeof(getgenv) == "function" and (getgenv().setclipboard or getgenv().toclipboard))
    if typeof(clipFunc) == "function" then clipFunc(text) end
end

local function formatTimeAgo(unixTime)
    local diff = os.time() - unixTime
    if diff < 60 then return "Just now"
    elseif diff < 3600 then return math.floor(diff / 60) .. "m ago"
    elseif diff < 86400 then return math.floor(diff / 3600) .. "h ago"
    else return math.floor(diff / 86400) .. "d ago" end
end

local function fetchAnnouncement()
    if CONFIG.AnnouncementUrl ~= "" then
        local success, res = pcall(function() return game:HttpGet(CONFIG.AnnouncementUrl) end)
        if success and res and #res > 0 then
            local decodeSuccess, jsonData = pcall(function() return HttpService:JSONDecode(res) end)
            if decodeSuccess and typeof(jsonData) == "table" and jsonData.text then
                local timeTag = jsonData.timestamp and (" [" .. formatTimeAgo(tonumber(jsonData.timestamp) or os.time()) .. "] ") or ""
                return timeTag .. tostring(jsonData.text):gsub("[\r\n]", " ")
            else
                return res:gsub("[\r\n]", " ")
            end
        end
    end
    return CONFIG.FallbackAnnouncement
end

local function getHttpRequest()
    local env = (typeof(getgenv) == "function" and getgenv()) or getfenv()
    return env.request or env.http_request or (env.syn and env.syn.request) or (env.http and env.http.request) or (env.fluxus and env.fluxus.request)
end

local function sendDiscordLog(gameName)
    if CONFIG.DiscordWebhook == "" then return end
    task.spawn(function()
        local req = getHttpRequest()
        if req then
            local payload = {
                ["embeds"] = {{
                    ["title"] = "Shadow Protocol Script Executed",
                    ["color"] = 15077923,
                    ["fields"] = {
                        {["name"] = "Player", ["value"] = LocalPlayer.DisplayName .. " (@" .. LocalPlayer.Name .. ")", ["inline"] = true},
                        {["name"] = "User ID", ["value"] = tostring(LocalPlayer.UserId), ["inline"] = true},
                        {["name"] = "Selected Game", ["value"] = gameName, ["inline"] = false},
                        {["name"] = "Place ID", ["value"] = tostring(game.PlaceId), ["inline"] = true}
                    },
                    ["footer"] = {["text"] = "Shadow Protocol Execution Logger"}
                }}
            }
            pcall(function()
                req({
                    Url = CONFIG.DiscordWebhook,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode(payload)
                })
            end)
        end
    end)
end

-- ============================================================
-- UI SYSTEM & ASSET HELPERS
-- ============================================================
local function getAssetUri(id)
	if type(id) == "string" and id:find("rbxassetid://") then
		local numId = id:match("%d+")
		return "rbxthumb://type=Asset&id=" .. numId .. "&w=150&h=150"
	elseif type(id) == "number" or (type(id) == "string" and tonumber(id)) then
		return "rbxthumb://type=Asset&id=" .. tostring(id) .. "&w=150&h=150"
	end
	return id
end

local function round(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = parent
	return c
end

local C_DEEP_BLACK = Color3.fromRGB(10, 10, 12)
local C_CARD = Color3.fromRGB(24, 24, 29)
local C_SUB_ROW = Color3.fromRGB(18, 18, 22)
local C_RED_ACCENT = Color3.fromRGB(255, 45, 55)
local C_RED_BASE = Color3.fromRGB(175, 20, 28)
local C_RED_DARK_FADE = Color3.fromRGB(25, 8, 10)
local C_TEXT_WHITE = Color3.fromRGB(250, 250, 250)
local C_TEXT_MUTED = Color3.fromRGB(135, 135, 142)
local C_LINE_OFF = Color3.fromRGB(45, 45, 54)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowProtocol_Master"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = GuiParent

local BackDim = Instance.new("Frame")
BackDim.Size = UDim2.new(1, 0, 1, 0)
BackDim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BackDim.BackgroundTransparency = 1
BackDim.BorderSizePixel = 0
BackDim.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 460, 0, 220)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = C_DEEP_BLACK
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
round(MainFrame, 12)

local targetUIScale = 1.0
local UIScale = Instance.new("UIScale")
UIScale.Scale = 0.7
UIScale.Parent = MainFrame

-- Alert Banner
local AlertBanner = Instance.new("TextLabel")
AlertBanner.Size = UDim2.new(1, -220, 0, 32)
AlertBanner.Position = UDim2.new(0, 195, 0, 64)
AlertBanner.BackgroundColor3 = Color3.fromRGB(200, 30, 40)
AlertBanner.BackgroundTransparency = 1
AlertBanner.Font = Enum.Font.GothamBold
AlertBanner.TextSize = 11.5
AlertBanner.TextColor3 = Color3.fromRGB(255, 255, 255)
AlertBanner.TextTransparency = 1
AlertBanner.ZIndex = 60
AlertBanner.Parent = MainFrame
round(AlertBanner, 6)

local function showAlert(text)
    playSound(CONFIG.Sounds.Error)
    AlertBanner.Text = text
    TweenService:Create(AlertBanner, TweenInfo.new(0.25), {BackgroundTransparency = 0.1, TextTransparency = 0}):Play()
    
    local origin = MainFrame.Position
    for _ = 1, 3 do
        TweenService:Create(MainFrame, TweenInfo.new(0.05), {Position = origin + UDim2.new(0, 6, 0, 0)}):Play()
        task.wait(0.05)
        TweenService:Create(MainFrame, TweenInfo.new(0.05), {Position = origin - UDim2.new(0, 6, 0, 0)}):Play()
        task.wait(0.05)
    end
    TweenService:Create(MainFrame, TweenInfo.new(0.05), {Position = origin}):Play()
    
    task.delay(3, function()
        TweenService:Create(AlertBanner, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
    end)
end

-- Mobile Toggle
local MobileToggle = Instance.new("ImageButton")
MobileToggle.Size = UDim2.new(0, 44, 0, 44)
MobileToggle.Position = UDim2.new(0.04, 0, 0.22, 0)
MobileToggle.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
MobileToggle.BorderSizePixel = 0
MobileToggle.AutoButtonColor = false
MobileToggle.Active = true
MobileToggle.ZIndex = 50
MobileToggle.Parent = ScreenGui
round(MobileToggle, 22)

local MobileStroke = Instance.new("UIStroke")
MobileStroke.Thickness = 1.2
MobileStroke.Color = Color3.fromRGB(65, 20, 24)
MobileStroke.Transparency = 0.2
MobileStroke.Parent = MobileToggle

local MobileLogo = Instance.new("ImageLabel")
MobileLogo.Size = UDim2.new(0, 24, 0, 24)
MobileLogo.Position = UDim2.new(0.5, 0, 0.5, 0)
MobileLogo.AnchorPoint = Vector2.new(0.5, 0.5)
MobileLogo.BackgroundTransparency = 1
MobileLogo.Image = getAssetUri("140277993260075")
MobileLogo.ZIndex = 51
MobileLogo.Parent = MobileToggle

local MobileScale = Instance.new("UIScale")
MobileScale.Scale = 1
MobileScale.Parent = MobileToggle

local mobDragging, mobDragInput, mobDragStart, mobStartPos
local mobMoved = false
MobileToggle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		mobDragging = true; mobMoved = false; mobDragStart = input.Position; mobStartPos = MobileToggle.Position
		TweenService:Create(MobileScale, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.88}):Play()
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				mobDragging = false
				TweenService:Create(MobileScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
			end
		end)
	end
end)
MobileToggle.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then mobDragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == mobDragInput and mobDragging then
		local delta = input.Position - mobDragStart
		if delta.Magnitude > 6 then mobMoved = true end
		MobileToggle.Position = UDim2.new(mobStartPos.X.Scale, mobStartPos.X.Offset + delta.X, mobStartPos.Y.Scale, mobStartPos.Y.Offset + delta.Y)
	end
end)

local isUIOpen = true
local isAnimatingUI = false

local function toggleUI(state)
	if isAnimatingUI or not ScreenGui.Parent then return end
	if state == nil then state = not isUIOpen end
	if state == isUIOpen then return end
	isAnimatingUI = true

	if state then
		MainFrame.Visible = true
		isUIOpen = true
		UIScale.Scale = targetUIScale * 0.92
		local openTween = TweenService:Create(UIScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = targetUIScale})
		openTween:Play()
		openTween.Completed:Connect(function() isAnimatingUI = false end)
	else
		isUIOpen = false
		local closeTween = TweenService:Create(UIScale, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Scale = targetUIScale * 0.92})
		closeTween:Play()
		closeTween.Completed:Connect(function()
			MainFrame.Visible = false
			isAnimatingUI = false
		end)
	end
end

MobileToggle.MouseButton1Click:Connect(function()
	if not mobMoved then toggleUI() end
end)

keybindConnection = UserInputService.InputBegan:Connect(function(input, gpe)
	if isKeyListening or gpe then return end
	if input.KeyCode == CONFIG.ToggleKey then toggleUI() end
end)

local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true; dragStart = input.Position; startPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- ============================================================
-- STAGE 1: COMPACT DISCORD GATEWAY VIEW (MODAL)
-- ============================================================
local DiscordGatewayView = Instance.new("Frame")
DiscordGatewayView.Name = "DiscordGatewayView"
DiscordGatewayView.Size = UDim2.new(1, 0, 1, 0)
DiscordGatewayView.BackgroundColor3 = C_DEEP_BLACK
DiscordGatewayView.ZIndex = 40
DiscordGatewayView.Parent = MainFrame
round(DiscordGatewayView, 12)

local GatewayAccent = Instance.new("Frame")
GatewayAccent.Size = UDim2.new(1, 0, 0, 3)
GatewayAccent.BorderSizePixel = 0
GatewayAccent.BackgroundColor3 = C_RED_ACCENT
GatewayAccent.ZIndex = 41
GatewayAccent.Parent = DiscordGatewayView

local GatewayLogo = Instance.new("ImageLabel")
GatewayLogo.Size = UDim2.new(0, 32, 0, 32)
GatewayLogo.Position = UDim2.new(0, 24, 0, 24)
GatewayLogo.BackgroundTransparency = 1
GatewayLogo.Image = getAssetUri("140277993260075")
GatewayLogo.ZIndex = 42
GatewayLogo.Parent = DiscordGatewayView

local GatewayTitle = Instance.new("TextLabel")
GatewayTitle.Text = '<font color="#FF2D37"><b>SHADOW PROTOCOL</b></font>  |  COMMUNITY'
GatewayTitle.RichText = true
GatewayTitle.Font = Enum.Font.GothamBold
GatewayTitle.TextSize = 14
GatewayTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
GatewayTitle.Position = UDim2.new(0, 68, 0, 28)
GatewayTitle.Size = UDim2.new(1, -90, 0, 22)
GatewayTitle.TextXAlignment = Enum.TextXAlignment.Left
GatewayTitle.BackgroundTransparency = 1
GatewayTitle.ZIndex = 42
GatewayTitle.Parent = DiscordGatewayView

local GatewayDesc = Instance.new("TextLabel")
GatewayDesc.Text = "Join our official Discord server to receive the latest script updates, keyless execution perks, and 24/7 technical support."
GatewayDesc.Font = Enum.Font.Gotham
GatewayDesc.TextSize = 11.5
GatewayDesc.TextColor3 = Color3.fromRGB(160, 160, 170)
GatewayDesc.Position = UDim2.new(0, 24, 0, 68)
GatewayDesc.Size = UDim2.new(1, -48, 0, 48)
GatewayDesc.TextWrapped = true
GatewayDesc.TextXAlignment = Enum.TextXAlignment.Left
GatewayDesc.BackgroundTransparency = 1
GatewayDesc.ZIndex = 42
GatewayDesc.Parent = DiscordGatewayView

local GatewayJoinBtn = Instance.new("TextButton")
GatewayJoinBtn.Size = UDim2.new(0.5, -28, 0, 36)
GatewayJoinBtn.Position = UDim2.new(0, 24, 1, -54)
GatewayJoinBtn.BackgroundColor3 = C_RED_BASE
GatewayJoinBtn.Text = "JOIN SERVER"
GatewayJoinBtn.Font = Enum.Font.GothamBold
GatewayJoinBtn.TextSize = 11.5
GatewayJoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GatewayJoinBtn.AutoButtonColor = false
GatewayJoinBtn.ZIndex = 42
GatewayJoinBtn.Parent = DiscordGatewayView
round(GatewayJoinBtn, 7)

local GatewayDeclineBtn = Instance.new("TextButton")
GatewayDeclineBtn.Size = UDim2.new(0.5, -28, 0, 36)
GatewayDeclineBtn.Position = UDim2.new(0.5, 4, 1, -54)
GatewayDeclineBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
GatewayDeclineBtn.Text = "CONTINUE"
GatewayDeclineBtn.Font = Enum.Font.GothamBold
GatewayDeclineBtn.TextSize = 11.5
GatewayDeclineBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
GatewayDeclineBtn.AutoButtonColor = false
GatewayDeclineBtn.ZIndex = 42
GatewayDeclineBtn.Parent = DiscordGatewayView
round(GatewayDeclineBtn, 7)

-- ============================================================
-- STAGE 3: AVATAR LOADER & INJECTION PROGRESS VIEW
-- ============================================================
local LoaderView = Instance.new("Frame")
LoaderView.Name = "LoaderView"
LoaderView.Size = UDim2.new(1, 0, 1, 0)
LoaderView.BackgroundColor3 = C_DEEP_BLACK
LoaderView.Visible = false
LoaderView.ZIndex = 50
LoaderView.Parent = MainFrame
round(LoaderView, 12)

local LoaderAccent = Instance.new("Frame")
LoaderAccent.Size = UDim2.new(1, 0, 0, 3)
LoaderAccent.BorderSizePixel = 0
LoaderAccent.BackgroundColor3 = C_RED_ACCENT
LoaderAccent.ZIndex = 51
LoaderAccent.Parent = LoaderView

local LoaderAvatar = Instance.new("ImageLabel")
LoaderAvatar.Size = UDim2.new(0, 56, 0, 56)
LoaderAvatar.Position = UDim2.new(0, 24, 0, 24)
LoaderAvatar.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
task.spawn(function()
    local content, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    if isReady then LoaderAvatar.Image = content end
end)
LoaderAvatar.ZIndex = 52
LoaderAvatar.Parent = LoaderView
round(LoaderAvatar, 28)

local LoaderAvatarStroke = Instance.new("UIStroke")
LoaderAvatarStroke.Color = C_RED_ACCENT
LoaderAvatarStroke.Thickness = 1.5
LoaderAvatarStroke.Parent = LoaderAvatar

local LoaderTitle = Instance.new("TextLabel")
LoaderTitle.Text = '<font color="#FF2D37"><b>SHADOW PROTOCOL</b></font> LOADER'
LoaderTitle.RichText = true
LoaderTitle.Font = Enum.Font.GothamBold
LoaderTitle.TextSize = 14
LoaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
LoaderTitle.Position = UDim2.new(0, 92, 0, 26)
LoaderTitle.Size = UDim2.new(1, -112, 0, 20)
LoaderTitle.TextXAlignment = Enum.TextXAlignment.Left
LoaderTitle.BackgroundTransparency = 1
LoaderTitle.ZIndex = 52
LoaderTitle.Parent = LoaderView

local UserSubText = Instance.new("TextLabel")
UserSubText.Text = "Welcome, " .. LocalPlayer.DisplayName
UserSubText.Font = Enum.Font.Gotham
UserSubText.TextSize = 11.5
UserSubText.TextColor3 = Color3.fromRGB(150, 150, 160)
UserSubText.Position = UDim2.new(0, 92, 0, 50)
UserSubText.Size = UDim2.new(1, -112, 0, 16)
UserSubText.TextXAlignment = Enum.TextXAlignment.Left
UserSubText.BackgroundTransparency = 1
UserSubText.ZIndex = 52
UserSubText.Parent = LoaderView

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "Verifying Environment..."
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextSize = 12
StatusLabel.TextColor3 = Color3.fromRGB(210, 210, 220)
StatusLabel.Position = UDim2.new(0, 24, 0, 96)
StatusLabel.Size = UDim2.new(1, -48, 0, 18)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.BackgroundTransparency = 1
StatusLabel.ZIndex = 52
StatusLabel.Parent = LoaderView

local ProgressBG = Instance.new("Frame")
ProgressBG.Size = UDim2.new(1, -48, 0, 7)
ProgressBG.Position = UDim2.new(0, 24, 0, 122)
ProgressBG.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ProgressBG.BorderSizePixel = 0
ProgressBG.ZIndex = 52
ProgressBG.Parent = LoaderView
round(ProgressBG, 4)

local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = C_RED_ACCENT
ProgressFill.BorderSizePixel = 0
ProgressFill.ZIndex = 53
ProgressFill.Parent = ProgressBG
round(ProgressFill, 4)

-- ============================================================
-- MAIN SELECTOR & CAROUSEL LAYOUT
-- ============================================================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, 0)
Sidebar.BackgroundColor3 = C_DEEP_BLACK
Sidebar.BorderSizePixel = 0
Sidebar.Visible = false
Sidebar.Parent = MainFrame
round(Sidebar, 12)

local BrandHeader = Instance.new("Frame")
BrandHeader.Size = UDim2.new(1, 0, 0, 60)
BrandHeader.BackgroundTransparency = 1
BrandHeader.Parent = Sidebar

local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 32, 0, 32)
Logo.Position = UDim2.new(0, 14, 0.5, -16)
Logo.BackgroundTransparency = 1
Logo.Image = getAssetUri("140277993260075")
Logo.Parent = BrandHeader

local BrandTitle = Instance.new("TextLabel")
BrandTitle.Size = UDim2.new(1, -56, 1, 0)
BrandTitle.Position = UDim2.new(0, 54, 0, 0)
BrandTitle.BackgroundTransparency = 1
BrandTitle.Text = "<font color='#FF2D37'>SHADOW</font> <font color='#FFFFFF'>PROTOCOL</font>"
BrandTitle.RichText = true
BrandTitle.Font = Enum.Font.GothamBold
BrandTitle.TextSize = 11.5
BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
BrandTitle.Parent = BrandHeader

local SideList = Instance.new("ScrollingFrame")
SideList.Size = UDim2.new(1, 0, 1, -108)
SideList.Position = UDim2.new(0, 0, 0, 60)
SideList.BackgroundTransparency = 1
SideList.BorderSizePixel = 0
SideList.ScrollBarThickness = 0
SideList.CanvasSize = UDim2.new(0, 0, 0, 0)
SideList.AutomaticCanvasSize = Enum.AutomaticSize.Y
SideList.Parent = Sidebar

local SideLayout = Instance.new("UIListLayout")
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Padding = UDim.new(0, 5)
SideLayout.Parent = SideList

local SidePadding = Instance.new("UIPadding")
SidePadding.PaddingTop = UDim.new(0, 4)
SidePadding.PaddingLeft = UDim.new(0, 12)
SidePadding.PaddingRight = UDim.new(0, 12)
SidePadding.Parent = SideList

local ProfileContainer = Instance.new("Frame")
ProfileContainer.Size = UDim2.new(1, -24, 0, 36)
ProfileContainer.Position = UDim2.new(0, 12, 1, -44)
ProfileContainer.BackgroundTransparency = 1
ProfileContainer.BorderSizePixel = 0
ProfileContainer.Parent = Sidebar

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Size = UDim2.new(0, 26, 0, 26)
AvatarImage.Position = UDim2.new(0, 2, 0.5, -13)
AvatarImage.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
AvatarImage.BorderSizePixel = 0
AvatarImage.Parent = ProfileContainer
round(AvatarImage, 13)

task.spawn(function()
	local content, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	if isReady then AvatarImage.Image = content end
end)

local NicknameLabel = Instance.new("TextLabel")
NicknameLabel.Size = UDim2.new(1, -38, 0, 15)
NicknameLabel.Position = UDim2.new(0, 36, 0, 2)
NicknameLabel.BackgroundTransparency = 1
NicknameLabel.Text = LocalPlayer.DisplayName
NicknameLabel.TextColor3 = C_TEXT_WHITE
NicknameLabel.Font = Enum.Font.GothamBold
NicknameLabel.TextSize = 11
NicknameLabel.TextTruncate = Enum.TextTruncate.AtEnd
NicknameLabel.TextXAlignment = Enum.TextXAlignment.Left
NicknameLabel.Parent = ProfileContainer

local UsernameLabel = Instance.new("TextLabel")
UsernameLabel.Size = UDim2.new(1, -38, 0, 13)
UsernameLabel.Position = UDim2.new(0, 36, 0, 17)
UsernameLabel.BackgroundTransparency = 1
UsernameLabel.Text = "@" .. LocalPlayer.Name
UsernameLabel.TextColor3 = C_TEXT_MUTED
UsernameLabel.Font = Enum.Font.Gotham
UsernameLabel.TextSize = 9.5
UsernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
UsernameLabel.Parent = ProfileContainer

local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, -180, 0, 60)
Topbar.Position = UDim2.new(0, 180, 0, 0)
Topbar.BackgroundTransparency = 1
Topbar.Visible = false
Topbar.Parent = MainFrame

local TopTitle = Instance.new("TextLabel")
TopTitle.Size = UDim2.new(1, -110, 1, 0)
TopTitle.Position = UDim2.new(0, 20, 0, 0)
TopTitle.BackgroundTransparency = 1
TopTitle.RichText = true
TopTitle.Text = "<font color='#FFFFFF'><b>Shadow Protocol</b></font>  <font color='#55555F'>|</font>  <font color='#FF2D37'>Games</font>"
TopTitle.Font = Enum.Font.Gotham
TopTitle.TextSize = 13.5
TopTitle.TextXAlignment = Enum.TextXAlignment.Left
TopTitle.Parent = Topbar

local function createTopIconButton(xOffset, iconAsset)
	local btn = Instance.new("ImageButton")
	btn.Size = UDim2.new(0, 18, 0, 18)
	btn.Position = UDim2.new(1, xOffset, 0.5, -9)
	btn.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
	btn.Image = getAssetUri(iconAsset)
	btn.ImageColor3 = C_TEXT_MUTED
	btn.BorderSizePixel = 0
	btn.ZIndex = 11
	btn.Parent = Topbar
	round(btn, 5)
	btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(34, 34, 40), ImageColor3 = C_TEXT_WHITE}):Play() end)
	btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(24, 24, 28), ImageColor3 = C_TEXT_MUTED}):Play() end)
	return btn
end

local MinBtn = createTopIconButton(-48, "10734896206")
MinBtn.MouseButton1Click:Connect(function() toggleUI(false) end)

local CloseBtn = createTopIconButton(-24, "10747384394")
CloseBtn.MouseEnter:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.18), {BackgroundColor3 = C_RED_BASE, ImageColor3 = Color3.new(1, 1, 1)}):Play() end)
CloseBtn.MouseLeave:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(24, 24, 28), ImageColor3 = C_TEXT_MUTED}):Play() end)
CloseBtn.MouseButton1Click:Connect(function()
    cleanupHub()
    ScreenGui:Destroy()
end)

local PagesViewport = Instance.new("Frame")
PagesViewport.Size = UDim2.new(1, -195, 1, -72)
PagesViewport.Position = UDim2.new(0, 185, 0, 60)
PagesViewport.BackgroundTransparency = 1
PagesViewport.BorderSizePixel = 0
PagesViewport.ClipsDescendants = true
PagesViewport.Visible = false
PagesViewport.Parent = MainFrame

local PagesTrack = Instance.new("Frame")
PagesTrack.Size = UDim2.new(1, 0, 1, 0)
PagesTrack.Position = UDim2.new(0, 0, 0, 0)
PagesTrack.BackgroundTransparency = 1
PagesTrack.BorderSizePixel = 0
PagesTrack.Parent = PagesViewport

local tabButtons = {}
local pageIndices = {}
local currentTabIndex = 1
local currentSelectedBtn = nil

local function switchTab(tabName, btnData)
	local targetIndex = pageIndices[tabName]
	if not targetIndex or targetIndex == currentTabIndex then return end

	local oldBtn = currentSelectedBtn
	currentTabIndex = targetIndex

	local fadeOutText = TweenService:Create(TopTitle, TweenInfo.new(0.1), {TextTransparency = 1})
	fadeOutText:Play()
	fadeOutText.Completed:Connect(function()
		TopTitle.Text = "<font color='#FFFFFF'><b>Shadow Protocol</b></font>  <font color='#55555F'>|</font>  <font color='#FF2D37'>" .. tabName .. "</font>"
		TweenService:Create(TopTitle, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
	end)

	if oldBtn and oldBtn ~= btnData then
		TweenService:Create(oldBtn.Indicator, TweenInfo.new(0.2), {Size = UDim2.new(0, 3.5, 0, 0)}):Play()
		TweenService:Create(oldBtn.Text, TweenInfo.new(0.2), {TextColor3 = C_TEXT_MUTED}):Play()
		TweenService:Create(oldBtn.Icon, TweenInfo.new(0.2), {ImageColor3 = C_RED_ACCENT}):Play()
		local slideOut = TweenService:Create(oldBtn.Gradient, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Offset = Vector2.new(-1, 0)})
		slideOut:Play()
		slideOut.Completed:Connect(function()
			if currentSelectedBtn ~= oldBtn then oldBtn.BgFrame.BackgroundTransparency = 1 end
		end)
	end

	currentSelectedBtn = btnData
	btnData.BgFrame.BackgroundTransparency = 0
	btnData.Gradient.Offset = Vector2.new(-1, 0)

	TweenService:Create(btnData.Gradient, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Offset = Vector2.new(0, 0)}):Play()
	TweenService:Create(btnData.Indicator, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 3.5, 0.65, 0)}):Play()
	TweenService:Create(btnData.Text, TweenInfo.new(0.2), {TextColor3 = Color3.new(1, 1, 1)}):Play()
	TweenService:Create(btnData.Icon, TweenInfo.new(0.2), {ImageColor3 = Color3.new(1, 1, 1)}):Play()

	local targetPos = UDim2.new(-(targetIndex - 1), 0, 0, 0)
	TweenService:Create(PagesTrack, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Position = targetPos
	}):Play()
end

local function createCategoryLabel(text)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 22)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = C_TEXT_MUTED
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = SideList
end

local function createTabButton(name, iconId, index)
	pageIndices[name] = index

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 35)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	btn.Parent = SideList

	local btnScale = Instance.new("UIScale")
	btnScale.Scale = 1
	btnScale.Parent = btn

	local bgFrame = Instance.new("Frame")
	bgFrame.Size = UDim2.new(1, 0, 1, 0)
	bgFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bgFrame.BackgroundTransparency = 1
	bgFrame.ClipsDescendants = true
	bgFrame.BorderSizePixel = 0
	bgFrame.Parent = btn
	round(bgFrame, 6)

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0.0, C_RED_BASE),
		ColorSequenceKeypoint.new(0.45, Color3.fromRGB(115, 16, 20)),
		ColorSequenceKeypoint.new(1.0, C_RED_DARK_FADE)
	})
	gradient.Offset = Vector2.new(-1, 0)
	gradient.Parent = bgFrame

	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 3.5, 0, 0)
	indicator.Position = UDim2.new(0, 3, 0.5, 0)
	indicator.AnchorPoint = Vector2.new(0, 0.5)
	indicator.BackgroundColor3 = C_RED_ACCENT
	indicator.BorderSizePixel = 0
	indicator.ZIndex = 5
	indicator.Parent = btn
	round(indicator, 2)

	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.new(0, 18, 0, 18)
	icon.Position = UDim2.new(0, 14, 0.5, -9)
	icon.BackgroundTransparency = 1
	icon.Image = getAssetUri(iconId)
	icon.ImageColor3 = C_RED_ACCENT
	icon.BorderSizePixel = 0
	icon.ZIndex = 4
	icon.Parent = btn

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -42, 1, 0)
	textLabel.Position = UDim2.new(0, 40, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = name
	textLabel.TextColor3 = C_TEXT_MUTED
	textLabel.Font = Enum.Font.GothamMedium
	textLabel.TextSize = 12
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.ZIndex = 4
	textLabel.Parent = btn

	local btnData = {
		Btn = btn,
		Scale = btnScale,
		BgFrame = bgFrame,
		Gradient = gradient,
		Icon = icon,
		Text = textLabel,
		Indicator = indicator
	}
	tabButtons[name] = btnData

	btn.MouseEnter:Connect(function()
		if currentSelectedBtn ~= btnData then
			TweenService:Create(textLabel, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(220, 220, 225)}):Play()
			TweenService:Create(icon, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(255, 120, 125)}):Play()
		end
	end)
	btn.MouseLeave:Connect(function()
		if currentSelectedBtn ~= btnData then
			TweenService:Create(textLabel, TweenInfo.new(0.15), {TextColor3 = C_TEXT_MUTED}):Play()
			TweenService:Create(icon, TweenInfo.new(0.15), {ImageColor3 = C_RED_ACCENT}):Play()
		end
	end)
	btn.MouseButton1Click:Connect(function()
		btnScale.Scale = 0.94
		TweenService:Create(btnScale, TweenInfo.new(0.28, Enum.EasingStyle.Back), {Scale = 1}):Play()
		switchTab(name, btnData)
	end)

	return btnData
end

local function createPageScroll(index)
	local pageScroll = Instance.new("ScrollingFrame")
	pageScroll.Size = UDim2.new(1, 0, 1, 0)
	pageScroll.Position = UDim2.new(index - 1, 0, 0, 0)
	pageScroll.BackgroundTransparency = 1
	pageScroll.BorderSizePixel = 0
	pageScroll.ScrollBarThickness = 3
	pageScroll.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 55)
	pageScroll.ScrollBarImageTransparency = 0.4
	pageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	pageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	pageScroll.ClipsDescendants = true
	pageScroll.Parent = PagesTrack

	local pagePadding = Instance.new("UIPadding")
	pagePadding.PaddingRight = UDim.new(0, 6)
	pagePadding.PaddingBottom = UDim.new(0, 20)
	pagePadding.Parent = pageScroll

	return pageScroll
end

local function createSection(parentCol, secTitle, iconAsset, subText)
	local Section = {CurrentHeight = 52}

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 46)
	card.BackgroundTransparency = 1
	card.ClipsDescendants = true
	card.Parent = parentCol

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 46)
	header.BackgroundColor3 = C_CARD
	header.BorderSizePixel = 0
	header.ZIndex = 4
	header.Parent = card
	round(header, 8)

	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.new(0, 20, 0, 20)
	icon.Position = UDim2.new(0, 12, 0, 13)
	icon.BackgroundTransparency = 1
	icon.Image = getAssetUri(iconAsset or "10723374641")
	icon.ImageColor3 = C_RED_ACCENT
	icon.ZIndex = 5
	icon.Parent = header

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0.6, 0, 0, 18)
	title.Position = UDim2.new(0, 38, 0, 8)
	title.BackgroundTransparency = 1
	title.Text = secTitle
	title.TextColor3 = C_TEXT_WHITE
	title.Font = Enum.Font.GothamBold
	title.TextSize = 12
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 5
	title.Parent = header

	local sub = Instance.new("TextLabel")
	sub.Size = UDim2.new(0.6, 0, 0, 14)
	sub.Position = UDim2.new(0, 38, 0, 24)
	sub.BackgroundTransparency = 1
	sub.Text = subText or ""
	sub.TextColor3 = C_TEXT_MUTED
	sub.Font = Enum.Font.Gotham
	sub.TextSize = 9.5
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.ZIndex = 5
	title.Parent = header

	local toggleBg = Instance.new("TextButton")
	toggleBg.Size = UDim2.new(0, 32, 0, 16)
	toggleBg.Position = UDim2.new(1, -44, 0, 15)
	toggleBg.BackgroundColor3 = C_RED_ACCENT
	toggleBg.Text = ""
	toggleBg.AutoButtonColor = false
	toggleBg.ZIndex = 5
	toggleBg.Parent = header
	round(toggleBg, 8)

	local circle = Instance.new("Frame")
	circle.Size = UDim2.new(0, 12, 0, 12)
	circle.Position = UDim2.new(1, -14, 0.5, -6)
	circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	circle.ZIndex = 6
	circle.Parent = toggleBg
	round(circle, 6)

	local contentMask = Instance.new("Frame")
	contentMask.Size = UDim2.new(1, 0, 0, 0)
	contentMask.Position = UDim2.new(0, 0, 0, 46)
	contentMask.BackgroundTransparency = 1
	contentMask.ClipsDescendants = true
	contentMask.Visible = true
	contentMask.Parent = card

	local body = Instance.new("Frame")
	body.Size = UDim2.new(1, 0, 1, 0)
	body.BackgroundTransparency = 1
	body.Parent = contentMask

	local isOpen = true
	local function refreshHeight()
		if isOpen then
			card.Size = UDim2.new(1, 0, 0, Section.CurrentHeight)
			contentMask.Size = UDim2.new(1, 0, 0, Section.CurrentHeight - 46)
		end
	end

	toggleBg.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		TweenService:Create(circle, TweenInfo.new(0.24, Enum.EasingStyle.Back), {Position = isOpen and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
		TweenService:Create(toggleBg, TweenInfo.new(0.24), {BackgroundColor3 = isOpen and C_RED_ACCENT or Color3.fromRGB(36, 36, 42)}):Play()
		if isOpen then
			contentMask.Visible = true
			TweenService:Create(card, TweenInfo.new(0.32, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, Section.CurrentHeight)}):Play()
			TweenService:Create(contentMask, TweenInfo.new(0.32, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, Section.CurrentHeight - 46)}):Play()
		else
			local t = TweenService:Create(card, TweenInfo.new(0.26, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 46)})
			TweenService:Create(contentMask, TweenInfo.new(0.26, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 0, 0)}):Play()
			t:Play()
			t.Completed:Connect(function() if not isOpen then contentMask.Visible = false end end)
		end
	end)

	function Section:AddToggle(toggleName, defaultVal, callback)
		local yPos = Section.CurrentHeight - 46
		Section.CurrentHeight = Section.CurrentHeight + 35
		refreshHeight()

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -12, 0, 30)
		row.Position = UDim2.new(0, 6, 0, yPos)
		row.BackgroundTransparency = 1
		row.ClipsDescendants = true
		row.Parent = body
		round(row, 6)

		local bgSlide = Instance.new("Frame")
		bgSlide.Size = defaultVal and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0)
		bgSlide.BackgroundColor3 = C_SUB_ROW
		bgSlide.BorderSizePixel = 0
		bgSlide.ZIndex = 1
		bgSlide.Parent = row
		round(bgSlide, 6)

		local line = Instance.new("Frame")
		line.Size = UDim2.new(0, 2, 0, 16)
		line.Position = UDim2.new(0, 7, 0.5, -8)
		line.BackgroundColor3 = defaultVal and C_RED_ACCENT or C_LINE_OFF
		line.BorderSizePixel = 0
		line.ZIndex = 2
		line.Parent = row
		round(line, 2)

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0.75, 0, 1, 0)
		label.Position = UDim2.new(0, 16, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = toggleName
		label.TextColor3 = defaultVal and C_TEXT_WHITE or C_TEXT_MUTED
		label.Font = Enum.Font.Gotham
		label.TextSize = 11.5
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 2
		label.Parent = row

		local box = Instance.new("TextButton")
		box.Size = UDim2.new(0, 17, 0, 17)
		box.Position = UDim2.new(1, -25, 0.5, -8.5)
		box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		box.BackgroundTransparency = defaultVal and 0 or 0.88
		box.Text = ""
		box.AutoButtonColor = false
		box.ZIndex = 3
		box.Parent = row
		round(box, 4)

		local gradient = Instance.new("UIGradient")
		gradient.Rotation = 45
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 60, 75)),
			ColorSequenceKeypoint.new(0.55, Color3.fromRGB(215, 25, 38)),
			ColorSequenceKeypoint.new(1.0, Color3.fromRGB(150, 12, 22))
		})
		gradient.Parent = box

		local checkIcon = Instance.new("ImageLabel")
		checkIcon.Size = defaultVal and UDim2.new(0, 11, 0, 11) or UDim2.new(0, 4, 0, 4)
		checkIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
		checkIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		checkIcon.BackgroundTransparency = 1
		checkIcon.Image = getAssetUri("10709790644")
		checkIcon.ImageTransparency = defaultVal and 0 or 1
		checkIcon.ZIndex = 4
		checkIcon.Parent = box

		local state = defaultVal
		box.MouseButton1Click:Connect(function()
			state = not state
			playSound(CONFIG.Sounds.Click)
			box.Size = UDim2.new(0, 14, 0, 14)
			box.Position = UDim2.new(1, -23.5, 0.5, -7)
			TweenService:Create(box, TweenInfo.new(0.24, Enum.EasingStyle.Back), {Size = UDim2.new(0, 17, 0, 17), Position = UDim2.new(1, -25, 0.5, -8.5)}):Play()
			if state then
				TweenService:Create(bgSlide, TweenInfo.new(0.28, Enum.EasingStyle.Quart), {Size = UDim2.new(1, 0, 1, 0)}):Play()
				TweenService:Create(box, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
				TweenService:Create(checkIcon, TweenInfo.new(0.25, Enum.EasingStyle.Back), {Size = UDim2.new(0, 11, 0, 11), ImageTransparency = 0}):Play()
				TweenService:Create(line, TweenInfo.new(0.2), {BackgroundColor3 = C_RED_ACCENT}):Play()
				TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = C_TEXT_WHITE}):Play()
			else
				TweenService:Create(bgSlide, TweenInfo.new(0.24, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 0, 1, 0)}):Play()
				TweenService:Create(box, TweenInfo.new(0.18), {BackgroundTransparency = 0.88}):Play()
				TweenService:Create(checkIcon, TweenInfo.new(0.15), {Size = UDim2.new(0, 4, 0, 4), ImageTransparency = 1}):Play()
				TweenService:Create(line, TweenInfo.new(0.2), {BackgroundColor3 = C_LINE_OFF}):Play()
				TweenService:Create(label, TweenInfo.new(0.2), {TextColor3 = C_TEXT_MUTED}):Play()
			end
			if callback then callback(state) end
		end)
	end

	function Section:AddKeybind(titleTxt, defaultKey, callback)
		local yPos = Section.CurrentHeight - 46
		Section.CurrentHeight = Section.CurrentHeight + 38
		refreshHeight()

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -12, 0, 32)
		row.Position = UDim2.new(0, 6, 0, yPos)
		row.BackgroundColor3 = C_SUB_ROW
		row.BorderSizePixel = 0
		row.Parent = body
		round(row, 6)

		local titleLabel = Instance.new("TextLabel")
		titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
		titleLabel.Position = UDim2.new(0, 10, 0, 0)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = titleTxt
		titleLabel.TextColor3 = C_TEXT_WHITE
		titleLabel.Font = Enum.Font.Gotham
		titleLabel.TextSize = 11.5
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.Parent = row

		local keyBtn = Instance.new("TextButton")
		keyBtn.Size = UDim2.new(0, 110, 0, 24)
		keyBtn.Position = UDim2.new(1, -118, 0.5, -12)
		keyBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
		keyBtn.Text = "[" .. defaultKey.Name .. "]"
		keyBtn.TextColor3 = C_RED_ACCENT
		keyBtn.Font = Enum.Font.GothamBold
		keyBtn.TextSize = 10.5
		keyBtn.AutoButtonColor = false
		keyBtn.Parent = row
		round(keyBtn, 5)

		local isBinding = false
		keyBtn.MouseButton1Click:Connect(function()
			if isBinding then return end
			isBinding = true
			isKeyListening = true
			playSound(CONFIG.Sounds.Click)
			keyBtn.Text = "... Press Key ..."
			keyBtn.TextColor3 = Color3.fromRGB(255, 200, 50)

			local conn
			conn = UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
					keyBtn.Text = "[" .. input.KeyCode.Name .. "]"
					keyBtn.TextColor3 = C_RED_ACCENT
					isBinding = false
					isKeyListening = false
					conn:Disconnect()
					playSound(CONFIG.Sounds.Success)
					if callback then callback(input.KeyCode) end
				end
			end)
		end)
	end

	function Section:AddSlider(sliderName, min, max, defaultVal, step, callback)
		local yPos = Section.CurrentHeight - 46
		Section.CurrentHeight = Section.CurrentHeight + 40
		refreshHeight()

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -12, 0, 34)
		row.Position = UDim2.new(0, 6, 0, yPos)
		row.BackgroundColor3 = C_SUB_ROW
		row.BorderSizePixel = 0
		row.Parent = body
		round(row, 6)

		local titleLbl = Instance.new("TextLabel")
		titleLbl.Size = UDim2.new(0.45, 0, 1, 0)
		titleLbl.Position = UDim2.new(0, 10, 0, 0)
		titleLbl.BackgroundTransparency = 1
		titleLbl.Text = sliderName
		titleLbl.TextColor3 = C_TEXT_WHITE
		titleLbl.Font = Enum.Font.Gotham
		titleLbl.TextSize = 11.5
		titleLbl.TextXAlignment = Enum.TextXAlignment.Left
		titleLbl.Parent = row

		local valLbl = Instance.new("TextLabel")
		valLbl.Size = UDim2.new(0, 42, 1, 0)
		valLbl.Position = UDim2.new(1, -50, 0, 0)
		valLbl.BackgroundTransparency = 1
		valLbl.Text = tostring(defaultVal)
		valLbl.TextColor3 = C_RED_ACCENT
		valLbl.Font = Enum.Font.GothamBold
		valLbl.TextSize = 10.5
		valLbl.TextXAlignment = Enum.TextXAlignment.Right
		valLbl.Parent = row

		local sliderTrack = Instance.new("TextButton")
		sliderTrack.Size = UDim2.new(0, 115, 0, 5)
		sliderTrack.Position = UDim2.new(1, -172, 0.5, -2.5)
		sliderTrack.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
		sliderTrack.BorderSizePixel = 0
		sliderTrack.Text = ""
		sliderTrack.AutoButtonColor = false
		sliderTrack.Parent = row
		round(sliderTrack, 3)

		local initialPct = math.clamp((defaultVal - min) / (max - min), 0, 1)

		local sliderFill = Instance.new("Frame")
		sliderFill.Size = UDim2.new(initialPct, 0, 1, 0)
		sliderFill.BackgroundColor3 = C_RED_ACCENT
		sliderFill.BorderSizePixel = 0
		sliderFill.Parent = sliderTrack
		round(sliderFill, 3)

		local sliderThumb = Instance.new("Frame")
		sliderThumb.Size = UDim2.new(0, 12, 0, 12)
		sliderThumb.AnchorPoint = Vector2.new(0.5, 0.5)
		sliderThumb.Position = UDim2.new(initialPct, 0, 0.5, 0)
		sliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		sliderThumb.BorderSizePixel = 0
		sliderThumb.ZIndex = 5
		sliderThumb.Parent = sliderTrack
		round(sliderThumb, 6)

		local isSliding = false
		local dragStartX = 0
		local currentPct = initialPct
		local startPercent = initialPct

		local function applyVal(pct)
			pct = math.clamp(pct, 0, 1)
			currentPct = pct
			local rawVal = min + (max - min) * pct
			if step and step > 0 then
				rawVal = math.round(rawVal / step) * step
			end
			local cleanPct = (rawVal - min) / (max - min)
			sliderFill.Size = UDim2.new(cleanPct, 0, 1, 0)
			sliderThumb.Position = UDim2.new(cleanPct, 0, 0.5, 0)
			valLbl.Text = tostring(rawVal)
			if callback then callback(rawVal) end
		end

		sliderTrack.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isSliding = true
				dragStartX = input.Position.X
				startPercent = currentPct
				local effectiveScale = (UIScale.Scale > 0) and UIScale.Scale or 1
				local effectiveWidth = 115 * effectiveScale
				local localOffset = input.Position.X - sliderTrack.AbsolutePosition.X
				if effectiveWidth > 0 then
					applyVal(localOffset / effectiveWidth)
					startPercent = currentPct
				end
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isSliding = false
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local deltaX = input.Position.X - dragStartX
				local effectiveScale = (UIScale.Scale > 0) and UIScale.Scale or 1
				local effectiveWidth = 115 * effectiveScale
				if effectiveWidth > 0 then
					applyVal(startPercent + (deltaX / effectiveWidth))
				end
			end
		end)
	end

	return Section
end

-- ---------------- [[ MODAL: SCRIPT UPDATING ]] ----------------
local UpdatingModal = Instance.new("Frame")
UpdatingModal.Size = UDim2.new(1, 0, 1, 0)
UpdatingModal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
UpdatingModal.BackgroundTransparency = 0.4
UpdatingModal.Visible = false
UpdatingModal.ZIndex = 70
UpdatingModal.Parent = MainFrame

local UpdatingCard = Instance.new("Frame")
UpdatingCard.Size = UDim2.new(0, 340, 0, 180)
UpdatingCard.Position = UDim2.new(0.5, 0, 0.5, 0)
UpdatingCard.AnchorPoint = Vector2.new(0.5, 0.5)
UpdatingCard.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
UpdatingCard.BorderSizePixel = 0
UpdatingCard.ZIndex = 71
UpdatingCard.Parent = UpdatingModal
round(UpdatingCard, 8)

local UpdatingStroke = Instance.new("UIStroke")
UpdatingStroke.Color = Color3.fromRGB(240, 195, 60)
UpdatingStroke.Thickness = 1.2
UpdatingStroke.Parent = UpdatingCard

local UpdatingTitle = Instance.new("TextLabel")
UpdatingTitle.Text = "SCRIPT UNDER MAINTENANCE"
UpdatingTitle.Font = Enum.Font.GothamBold
UpdatingTitle.TextSize = 12.5
UpdatingTitle.TextColor3 = Color3.fromRGB(240, 195, 60)
UpdatingTitle.Position = UDim2.new(0, 16, 0, 16)
UpdatingTitle.Size = UDim2.new(1, -32, 0, 18)
UpdatingTitle.BackgroundTransparency = 1
UpdatingTitle.ZIndex = 72
UpdatingTitle.Parent = UpdatingCard

local UpdatingDesc = Instance.new("TextLabel")
UpdatingDesc.Text = "This script is currently being updated. Some functions or bypasses may not work properly. Do you still want to proceed?"
UpdatingDesc.Font = Enum.Font.Gotham
UpdatingDesc.TextSize = 11
UpdatingDesc.TextColor3 = Color3.fromRGB(180, 180, 190)
UpdatingDesc.Position = UDim2.new(0, 16, 0, 42)
UpdatingDesc.Size = UDim2.new(1, -32, 0, 52)
UpdatingDesc.TextWrapped = true
UpdatingDesc.BackgroundTransparency = 1
UpdatingDesc.ZIndex = 72
UpdatingDesc.Parent = UpdatingCard

local ProceedBtn = Instance.new("TextButton")
ProceedBtn.Size = UDim2.new(0.5, -20, 0, 32)
ProceedBtn.Position = UDim2.new(0, 16, 1, -44)
ProceedBtn.BackgroundColor3 = Color3.fromRGB(220, 35, 45)
ProceedBtn.Text = "PROCEED"
ProceedBtn.Font = Enum.Font.GothamBold
ProceedBtn.TextSize = 11.5
ProceedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ProceedBtn.AutoButtonColor = false
ProceedBtn.ZIndex = 72
ProceedBtn.Parent = UpdatingCard
round(ProceedBtn, 6)

local CancelBtn = Instance.new("TextButton")
CancelBtn.Size = UDim2.new(0.5, -20, 0, 32)
CancelBtn.Position = UDim2.new(0.5, 4, 1, -44)
CancelBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
CancelBtn.Text = "CANCEL"
CancelBtn.Font = Enum.Font.GothamBold
CancelBtn.TextSize = 11.5
CancelBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
CancelBtn.AutoButtonColor = false
CancelBtn.ZIndex = 72
CancelBtn.Parent = UpdatingCard
round(CancelBtn, 6)

-- ---------------- [[ INJECTION PIPELINE ]] ----------------
local pendingUpdatingGame = nil

local function startLoaderSequence(gameData)
    isProcessing = true
    playSound(CONFIG.Sounds.Click)
    sendDiscordLog(gameData.Name)
    
    DiscordGatewayView.Visible = false
    UpdatingModal.Visible = false
    Sidebar.Visible = false
    Topbar.Visible = false
    PagesViewport.Visible = false
    
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 420, 0, 170)
    }):Play()
    
    task.wait(0.2)
    LoaderView.Visible = true
    
    StatusLabel.Text = "Matching Place ID..."
    TweenService:Create(ProgressFill, TweenInfo.new(0.4), {Size = UDim2.new(0.3, 0, 1, 0)}):Play()
    task.wait(0.4)
    
    StatusLabel.Text = "Game Identified: " .. gameData.Name
    StatusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
    TweenService:Create(ProgressFill, TweenInfo.new(0.5), {Size = UDim2.new(0.65, 0, 1, 0)}):Play()
    task.wait(0.4)
    
    StatusLabel.Text = "Injecting Payload..."
    StatusLabel.TextColor3 = Color3.fromRGB(210, 210, 220)
    TweenService:Create(ProgressFill, TweenInfo.new(0.6), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(0.6)
    
    playSound(CONFIG.Sounds.Success)
    StatusLabel.Text = "Successfully Injected"
    StatusLabel.TextColor3 = Color3.fromRGB(255, 70, 80)
    task.wait(0.3)

    cleanupHub()
    ScreenGui:Destroy()
    task.wait(0.15)

    -- Notificación oficial de inyección exitosa con el nombre Shadow Protocol
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Shadow Protocol",
            Text = "¡Inyectado exitosamente con éxito!",
            Duration = 5,
        })
    end)

    task.spawn(function()
        local success, rawScript = pcall(function()
            return game:HttpGet(gameData.ScriptUrl)
        end)
        
        if success and rawScript and #rawScript > 0 then
            local execSuccess, execErr = pcall(function()
                loadstring(rawScript)()
            end)
            if not execSuccess then
                warn("[SHADOW PROTOCOL EXECUTION ERROR] " .. tostring(execErr))
            end
        else
            warn("[SHADOW PROTOCOL DOWNLOAD ERROR] Failed to fetch script from URL")
        end
    end)
end

ProceedBtn.MouseButton1Click:Connect(function()
    if pendingUpdatingGame then
        UpdatingModal.Visible = false
        startLoaderSequence(pendingUpdatingGame)
    end
end)

CancelBtn.MouseButton1Click:Connect(function()
    playSound(CONFIG.Sounds.Click)
    UpdatingModal.Visible = false
    pendingUpdatingGame = nil
end)

-- ---------------- [[ TRANSITION TO MAIN LOADER ]] ----------------
local function dismissGateway()
    playSound(CONFIG.Sounds.Click)
    
    local fadeGateway = TweenService:Create(DiscordGatewayView, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    })
    fadeGateway:Play()
    fadeGateway.Completed:Connect(function()
        DiscordGatewayView.Visible = false
    end)

    local morphFrame = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 820, 0, 600)
    })
    morphFrame:Play()
    morphFrame.Completed:Connect(function()
        Sidebar.Visible = true
        Topbar.Visible = true
        PagesViewport.Visible = true
    end)
end

GatewayJoinBtn.MouseButton1Click:Connect(function()
    playSound(CONFIG.Sounds.Success)
    copyClipboard(CONFIG.DiscordInvite)
    dismissGateway()
    showAlert("Discord Invite Copied to Clipboard!")
end)

GatewayDeclineBtn.MouseButton1Click:Connect(function()
    dismissGateway()
end)

-- ---------------- [[ TABS BUILD ]] ----------------
createCategoryLabel("General")
local GamesBtn = createTabButton("Games", "10734975692", 1)

createCategoryLabel("Utilities")
local SettingsBtn = createTabButton("Settings", "10734950309", 2)
local DiscordBtn = createTabButton("Discord", "10709790597", 3)

-- ---------------- [[ TAB 1: GAMES VIEW ]] ----------------
local gamesPage = createPageScroll(1)

local NoticeFrame = Instance.new("Frame")
NoticeFrame.Size = UDim2.new(1, -12, 0, 28)
NoticeFrame.Position = UDim2.new(0, 6, 0, 4)
NoticeFrame.BackgroundColor3 = C_SUB_ROW
NoticeFrame.BorderSizePixel = 0
NoticeFrame.ClipsDescendants = true
NoticeFrame.Parent = gamesPage
round(NoticeFrame, 6)

local NoticeLabel = Instance.new("TextLabel")
NoticeLabel.Text = "LOADING..."
NoticeLabel.Font = Enum.Font.GothamMedium
NoticeLabel.TextSize = 10.5
NoticeLabel.TextColor3 = Color3.fromRGB(230, 200, 205)
NoticeLabel.Position = UDim2.new(1, 10, 0, 0)
NoticeLabel.Size = UDim2.new(0, 1000, 1, 0)
NoticeLabel.TextXAlignment = Enum.TextXAlignment.Left
NoticeLabel.BackgroundTransparency = 1
NoticeLabel.Parent = NoticeFrame

task.spawn(function()
    local text = fetchAnnouncement()
    NoticeLabel.Text = text
    local textSize = TextService:GetTextSize(text, 10.5, Enum.Font.GothamMedium, Vector2.new(10000, 28))
    local textWidth = math.max(textSize.X + 60, 250)
    NoticeLabel.Size = UDim2.new(0, textWidth, 1, 0)
    
    while NoticeFrame.Parent do
        local containerWidth = NoticeFrame.AbsoluteSize.X
        if containerWidth == 0 then containerWidth = 560 end
        NoticeLabel.Position = UDim2.new(0, containerWidth + 20, 0, 0)
        local totalDistance = containerWidth + textWidth + 40
        local scrollTween = TweenService:Create(
            NoticeLabel,
            TweenInfo.new(totalDistance / 55, Enum.EasingStyle.Linear),
            {Position = UDim2.new(0, -textWidth - 20, 0, 0)}
        )
        scrollTween:Play()
        scrollTween.Completed:Wait()
    end
end)

local ControlsFrame = Instance.new("Frame")
ControlsFrame.Size = UDim2.new(1, -12, 0, 32)
ControlsFrame.Position = UDim2.new(0, 6, 0, 38)
ControlsFrame.BackgroundTransparency = 1
ControlsFrame.Parent = gamesPage

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -135, 1, 0)
SearchBox.BackgroundColor3 = C_SUB_ROW
SearchBox.PlaceholderText = "Search games..."
SearchBox.PlaceholderColor3 = C_TEXT_MUTED
SearchBox.Text = ""
SearchBox.TextColor3 = C_TEXT_WHITE
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 11.5
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.Parent = ControlsFrame
round(SearchBox, 6)

local SearchPad = Instance.new("UIPadding")
SearchPad.PaddingLeft = UDim.new(0, 12)
SearchPad.Parent = SearchBox

local AutoInjectBtn = Instance.new("TextButton")
AutoInjectBtn.Size = UDim2.new(0, 125, 1, 0)
AutoInjectBtn.Position = UDim2.new(1, -125, 0, 0)
AutoInjectBtn.BackgroundColor3 = C_RED_BASE
AutoInjectBtn.Text = "AUTO INJECT"
AutoInjectBtn.Font = Enum.Font.GothamBold
AutoInjectBtn.TextSize = 11
AutoInjectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoInjectBtn.AutoButtonColor = false
AutoInjectBtn.Parent = ControlsFrame
round(AutoInjectBtn, 6)

local GamesGridHolder = Instance.new("Frame")
GamesGridHolder.Size = UDim2.new(1, -12, 0, 0)
GamesGridHolder.Position = UDim2.new(0, 6, 0, 78)
GamesGridHolder.AutomaticSize = Enum.AutomaticSize.Y
GamesGridHolder.BackgroundTransparency = 1
GamesGridHolder.Parent = gamesPage

local UIGrid = Instance.new("UIGridLayout")
UIGrid.CellSize = UDim2.new(0, 188, 0, 156)
UIGrid.CellPadding = UDim2.new(0, 12, 0, 12)
UIGrid.SortOrder = Enum.SortOrder.LayoutOrder
UIGrid.Parent = GamesGridHolder

local cardElements = {}

for _, gameData in ipairs(SupportedGames) do
    local isCurrentGame = isGameMatched(gameData)
    local statusName = getGameStatus(gameData)
    local statusColor = StatusColors[statusName] or StatusColors["Working"]
    local isUsable = (statusName == "Working" or statusName == "Updating")

    local Card = Instance.new("TextButton")
    Card.Name = gameData.Name
    Card.BackgroundColor3 = isUsable and C_CARD or Color3.fromRGB(16, 16, 20)
    Card.BorderSizePixel = 0
    Card.Text = ""
    Card.AutoButtonColor = false
    Card.ClipsDescendants = true
    Card.LayoutOrder = isCurrentGame and 0 or 10
    Card.Parent = GamesGridHolder
    round(Card, 8)

    local CardStroke = Instance.new("UIStroke")
    CardStroke.Color = isCurrentGame and C_RED_ACCENT or Color3.fromRGB(38, 38, 44)
    CardStroke.Thickness = isCurrentGame and 1.8 or 1.0
    CardStroke.Parent = Card

    local ThumbWrap = Instance.new("Frame")
    ThumbWrap.Size = UDim2.new(1, 0, 0, 96)
    ThumbWrap.BackgroundTransparency = 1
    ThumbWrap.ClipsDescendants = true
    ThumbWrap.Parent = Card

    local Thumb = Instance.new("ImageLabel")
    Thumb.Size = UDim2.new(1, 0, 1, 0)
    Thumb.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
    Thumb.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. tostring(gameData.Id) .. "&width=768&height=432&format=png"
    Thumb.BorderSizePixel = 0
    Thumb.ScaleType = Enum.ScaleType.Crop
    Thumb.ImageTransparency = isUsable and 0 or 0.45
    Thumb.Parent = ThumbWrap

    if isCurrentGame then
        local Badge = Instance.new("TextLabel")
        Badge.Size = UDim2.new(0, 92, 0, 20)
        Badge.Position = UDim2.new(0, 6, 0, 6)
        Badge.BackgroundColor3 = C_RED_ACCENT
        Badge.Text = "CURRENT GAME"
        Badge.Font = Enum.Font.GothamBold
        Badge.TextSize = 8.5
        Badge.TextColor3 = Color3.fromRGB(255, 255, 255)
        Badge.ZIndex = 8
        Badge.Parent = ThumbWrap
        round(Badge, 4)
    end

    local GameTitle = Instance.new("TextLabel")
    GameTitle.Text = gameData.Name
    GameTitle.Font = Enum.Font.GothamBold
    GameTitle.TextSize = 11.5
    GameTitle.TextColor3 = isUsable and C_TEXT_WHITE or C_TEXT_MUTED
    GameTitle.Position = UDim2.new(0, 8, 0, 102)
    GameTitle.Size = UDim2.new(1, -16, 0, 22)
    GameTitle.TextTruncate = Enum.TextTruncate.AtEnd
    GameTitle.TextXAlignment = Enum.TextXAlignment.Center
    GameTitle.BackgroundTransparency = 1
    GameTitle.Parent = Card

    local StatusText = Instance.new("TextLabel")
    StatusText.Text = "● " .. statusName
    StatusText.Font = Enum.Font.GothamMedium
    StatusText.TextSize = 10
    StatusText.TextColor3 = statusColor
    StatusText.Position = UDim2.new(0, 8, 0, 128)
    StatusText.Size = UDim2.new(1, -16, 0, 18)
    StatusText.BackgroundTransparency = 1
    StatusText.Parent = Card

    Card.MouseEnter:Connect(function()
        if isUsable then
            TweenService:Create(CardStroke, TweenInfo.new(0.2), {Color = C_RED_ACCENT, Thickness = 1.6}):Play()
            TweenService:Create(Card, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 28, 34)}):Play()
        end
    end)
    Card.MouseLeave:Connect(function()
        if not isCurrentGame then
            TweenService:Create(CardStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(38, 38, 44), Thickness = 1.0}):Play()
        end
        TweenService:Create(Card, TweenInfo.new(0.2), {BackgroundColor3 = isUsable and C_CARD or Color3.fromRGB(16, 16, 20)}):Play()
    end)

    Card.MouseButton1Click:Connect(function()
        if isProcessing then return end
        if not isGameMatched(gameData) then
            showAlert("Error: You are not playing " .. gameData.Name)
            return
        end
        if statusName == "Discontinued" then
            showAlert("Script is Discontinued and no longer supported.")
            return
        end
        if statusName == "Updating" then
            pendingUpdatingGame = gameData
            UpdatingModal.Visible = true
        else
            startLoaderSequence(gameData)
        end
    end)

    table.insert(cardElements, {Frame = Card, Name = string.lower(gameData.Name)})
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = string.lower(SearchBox.Text)
    for _, item in ipairs(cardElements) do
        item.Frame.Visible = (query == "" or string.find(item.Name, query) ~= nil)
    end
end)

AutoInjectBtn.MouseButton1Click:Connect(function()
    if isProcessing then return end
    local matchedGame = nil
    for _, g in ipairs(SupportedGames) do
        if isGameMatched(g) then
            matchedGame = g
            break
        end
    end
    if matchedGame then
        local status = getGameStatus(matchedGame)
        if status == "Working" then
            startLoaderSequence(matchedGame)
        elseif status == "Updating" then
            pendingUpdatingGame = matchedGame
            UpdatingModal.Visible = true
        else
            showAlert("Cannot inject: Script is " .. status .. "!")
        end
    else
        showAlert("Error: Current game is not supported!")
    end
end)

-- ---------------- [[ TAB 2: SETTINGS VIEW ]] ----------------
local settingsPage = createPageScroll(2)

local sColLeft = Instance.new("Frame")
sColLeft.Size = UDim2.new(0.485, 0, 0, 0)
sColLeft.AutomaticSize = Enum.AutomaticSize.Y
sColLeft.BackgroundTransparency = 1
sColLeft.Parent = settingsPage

local sColRight = Instance.new("Frame")
sColRight.Size = UDim2.new(0.485, 0, 0, 0)
sColRight.Position = UDim2.new(0.515, 0, 0, 0)
sColRight.AutomaticSize = Enum.AutomaticSize.Y
sColRight.BackgroundTransparency = 1
sColRight.Parent = settingsPage

local PreferencesSec = createSection(sColLeft, "Preferences", "10734950309", "Loader Behavior")
PreferencesSec:AddToggle("Sound Effects (SFX)", CONFIG.SoundEnabled, function(v)
    CONFIG.SoundEnabled = v
    saveSettings()
end)
PreferencesSec:AddToggle("Background Particles", CONFIG.ParticlesEnabled, function(v)
    CONFIG.ParticlesEnabled = v
    saveSettings()
end)
PreferencesSec:AddToggle("Auto-Inject on Start", CONFIG.AutoInjectEnabled, function(v)
    CONFIG.AutoInjectEnabled = v
    saveSettings()
end)

local ControlsSec = createSection(sColRight, "Controls & Scale", "10734950020", "Hotkeys & Window Size")
ControlsSec:AddKeybind("Toggle UI Keybind", CONFIG.ToggleKey, function(newKey)
    CONFIG.ToggleKey = newKey
    saveSettings()
end)
ControlsSec:AddSlider("UI Scale (%)", 75, 130, 100, 1, function(scalePercent)
    targetUIScale = scalePercent / 100
    if isUIOpen then UIScale.Scale = targetUIScale end
end)

-- ---------------- [[ TAB 3: DISCORD GATEWAY ]] ----------------
local discordPage = createPageScroll(3)

local dCol = Instance.new("Frame")
dCol.Size = UDim2.new(1, 0, 0, 0)
dCol.AutomaticSize = Enum.AutomaticSize.Y
dCol.BackgroundTransparency = 1
dCol.Parent = discordPage

local CommunitySec = createSection(dCol, "Official Community", "10709790597", "Get updates & support")

local dBox = Instance.new("Frame")
dBox.Size = UDim2.new(1, -12, 0, 76)
dBox.Position = UDim2.new(0, 6, 0, 6)
dBox.BackgroundColor3 = C_SUB_ROW
dBox.BorderSizePixel = 0
dBox.Parent = CommunitySec.Card or dCol
round(dBox, 6)

local dLabel = Instance.new("TextLabel")
dLabel.Size = UDim2.new(1, -20, 0, 38)
dLabel.Position = UDim2.new(0, 10, 0, 6)
dLabel.BackgroundTransparency = 1
dLabel.Text = "Join our official Discord server to receive the latest script updates, keyless execution perks, and technical support."
dLabel.TextColor3 = C_TEXT_MUTED
dLabel.Font = Enum.Font.Gotham
dLabel.TextSize = 11
dLabel.TextWrapped = true
dLabel.TextXAlignment = Enum.TextXAlignment.Left
dLabel.Parent = dBox

local CopyDiscordBtn = Instance.new("TextButton")
CopyDiscordBtn.Size = UDim2.new(0, 150, 0, 24)
CopyDiscordBtn.Position = UDim2.new(0, 10, 0, 46)
CopyDiscordBtn.BackgroundColor3 = C_RED_BASE
CopyDiscordBtn.Text = "COPY INVITE LINK"
CopyDiscordBtn.Font = Enum.Font.GothamBold
CopyDiscordBtn.TextSize = 10
CopyDiscordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyDiscordBtn.AutoButtonColor = false
CopyDiscordBtn.Parent = dBox
round(CopyDiscordBtn, 5)

CopyDiscordBtn.MouseButton1Click:Connect(function()
    playSound(CONFIG.Sounds.Success)
    copyClipboard(CONFIG.DiscordInvite)
    CopyDiscordBtn.Text = "COPIED TO CLIPBOARD!"
    task.delay(2, function()
        if CopyDiscordBtn.Parent then CopyDiscordBtn.Text = "COPY INVITE LINK" end
    end)
end)

-- Default Tab Active
currentSelectedBtn = GamesBtn
GamesBtn.BgFrame.BackgroundTransparency = 0
GamesBtn.Gradient.Offset = Vector2.new(0, 0)
GamesBtn.Indicator.Size = UDim2.new(0, 3.5, 0.65, 0)
GamesBtn.Text.TextColor3 = Color3.new(1, 1, 1)
GamesBtn.Icon.ImageColor3 = Color3.new(1, 1, 1)

-- ---------------- [[ EXECUTE ENTRANCE ANIMATION ]] ----------------
TweenService:Create(BackDim, TweenInfo.new(0.4), {BackgroundTransparency = 0.45}):Play()
local introTween = TweenService:Create(UIScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Scale = targetUIScale
})
introTween:Play()

-- ---------------- [[ AUTO-INJECT PIPELINE ]] ----------------
task.delay(1.5, function()
    if isDestroyed or not CONFIG.AutoInjectEnabled then return end
    
    local matchedGame = nil
    for _, g in ipairs(SupportedGames) do
        if isGameMatched(g) then
            matchedGame = g
            break
        end
    end
    
    if matchedGame then
        local status = getGameStatus(matchedGame)
        if status == "Working" then
            startLoaderSequence(matchedGame)
        elseif status == "Updating" then
            pendingUpdatingGame = matchedGame
            dismissGateway()
            UpdatingModal.Visible = true
        end
    end
end)
