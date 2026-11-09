-- ============================================================
-- SHADOW PROTOCOL - MASTER LOADER WITH KEYAUTH & NOTIFICATIONS
-- ============================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- ---------------- [[ CONFIGURATION ]] ----------------
local CONFIG = {
    DiscordInvite = "https://discord.gg/2p59z7pHYk",
    DiscordWebhook = "", 
    
    -- Configuración oficial de KeyAuth
    KeyAuth = {
        Name = "Shadow Protocol",
        OwnerId = "8EJKP3XB29",
        Secret = "f3b03463f7ec6181704a2b14",
        Version = "1.0"
    },
    
    StatusUrl = "https://raw.githubusercontent.com/bodxz/xz-hub/refs/heads/main/games_status",
    AnnouncementUrl = "https://raw.githubusercontent.com/bodxz/xz-hub/refs/heads/main/announcement", 
    FallbackAnnouncement = "NOTICE: Shadow Protocol Online | Join Discord for updates!",
    
    SoundEnabled = true,
    ParticlesEnabled = true,
    AutoInjectEnabled = false,
    ToggleKey = Enum.KeyCode.RightControl,
    
    Sounds = {
        Click = "rbxassetid://6895079853",
        Success = "rbxassetid://6895079527",
        Error = "rbxassetid://9069609268"
    }
}

-- Limpieza de efectos de ambiente
for _, effect in ipairs(Lighting:GetChildren()) do
    if (effect:IsA("BlurEffect") or effect:IsA("DepthOfFieldEffect")) and not effect.Name:lower():find("aim") then
        effect.Enabled = false
    end
end

local function getSafeGui()
    local getHuiFunc = rawget(getfenv(), "gethui") or (typeof(getgenv) == "function" and getgenv().gethui)
    if typeof(getHuiFunc) == "function" then return getHuiFunc() end
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if success and coreGui then return coreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local GuiParent = getSafeGui()
local existing = GuiParent:FindFirstChild("ShadowProtocol_Master")
if existing then existing:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ShadowProtocol_Master"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = GuiParent

local function playSound(soundId)
    if not CONFIG.SoundEnabled or soundId == "" then return end
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 0.6
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end

-- ---------------- [[ KEYAUTH VALIDATION FUNCTION ]] ----------------
local function validateKeyAuth(userKey)
    local url = string.format(
        "https://keyauth.cc/api/1.2/?name=%s&ownerid=%s&type=license&key=%s&ver=%s",
        CONFIG.KeyAuth.Name,
        CONFIG.KeyAuth.OwnerId,
        userKey,
        CONFIG.KeyAuth.Version
    )
    
    local success, res = pcall(function()
        local req = (syn and syn.request) or (http and http.request) or request
        if req then
            local r = req({Url = url, Method = "GET"})
            return r.Body
        else
            return game:HttpGet(url)
        end
    end)
    
    if success and res then
        local decodeOk, data = pcall(function() return HttpService:JSONDecode(res) end)
        if decodeOk and data and data.success then
            return true
        end
    end
    return false
end

-- ---------------- [[ INTERFAZ DEL KEY SYSTEM ]] ----------------
local KeyModal = Instance.new("Frame")
KeyModal.Size = UDim2.new(0, 360, 0, 220)
KeyModal.Position = UDim2.new(0.5, 0, 0.5, 0)
KeyModal.AnchorPoint = Vector2.new(0.5, 0.5)
KeyModal.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
KeyModal.BorderSizePixel = 0
KeyModal.ZIndex = 100
KeyModal.Parent = ScreenGui

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 10)
KeyCorner.Parent = KeyModal

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Color = Color3.fromRGB(255, 45, 55)
KeyStroke.Thickness = 1.2
KeyStroke.Parent = KeyModal

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 50)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = '<font color="#FF2D37"><b>SHADOW PROTOCOL</b></font> | KEY SYSTEM'
KeyTitle.RichText = true
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.TextSize = 15
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.ZIndex = 101
KeyTitle.Parent = KeyModal

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.85, 0, 0, 42)
KeyInput.Position = UDim2.new(0.075, 0, 0.35, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
KeyInput.PlaceholderText = "Introduce tu llave de KeyAuth..."
KeyInput.PlaceholderColor3 = Color3.fromRGB(135, 135, 142)
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(250, 250, 250)
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextSize = 13
KeyInput.ClearTextOnFocus = false
KeyInput.ZIndex = 101
KeyInput.Parent = KeyModal

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = KeyInput

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0.85, 0, 0, 40)
VerifyBtn.Position = UDim2.new(0.075, 0, 0.68, 0)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(175, 20, 28)
VerifyBtn.Text = "VERIFICAR LICENCIA"
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.TextSize = 12
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.AutoButtonColor = false
VerifyBtn.ZIndex = 101
VerifyBtn.Parent = KeyModal

local VerifyCorner = Instance.new("UICorner")
VerifyCorner.CornerRadius = UDim.new(0, 6)
VerifyCorner.Parent = VerifyBtn

local function initMainHub()
    -- Notificación oficial de inyección exitosa con el nombre Shadow Protocol
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Shadow Protocol",
            Text = "¡Inyectado exitosamente con éxito!",
            Duration = 5,
        })
    end)
end

VerifyBtn.MouseButton1Click:Connect(function()
    local enteredKey = KeyInput.Text
    if enteredKey == "" then
        VerifyBtn.Text = "¡Escribe una llave válida!"
        playSound(CONFIG.Sounds.Error)
        task.wait(1.5)
        VerifyBtn.Text = "VERIFICAR LICENCIA"
        return
    end
    
    VerifyBtn.Text = "Comprobando..."
    local isValid = validateKeyAuth(enteredKey)
    
    if isValid then
        VerifyBtn.Text = "¡Acceso Concedido!"
        playSound(CONFIG.Sounds.Success)
        task.wait(1)
        KeyModal:Destroy()
        initMainHub()
    else
        VerifyBtn.Text = "Llave incorrecta o expirada"
        playSound(CONFIG.Sounds.Error)
        task.wait(2)
        VerifyBtn.Text = "VERIFICAR LICENCIA"
    end
end)
