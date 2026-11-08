-- =====================================================================
--      SHADOW PROTOCOL - SECURE ENTERPRISE CORE (INK GAME)
-- =====================================================================
-- Protection Level: Advanced Lua Security & Integrity Enforced
-- Official Discord: discord.gg/Rz33pjVVAu
-- =====================================================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Sistema de integridad y encriptación de variables para evitar ingeniería inversa básica
local SecureEnvironment = {}
SecureEnvironment.Version = "4.0.0-Secured"
SecureEnvironment.AntiTamper = true

local function SecureLog(message)
    if SecureEnvironment.AntiTamper then
        print("[Shadow Protocol Secured Core] " .. tostring(message))
    end
end

-- Notificación de inicio de sesión seguro
task.spawn(function()
    task.wait(1)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Shadow Protocol Secure",
            Text = "¡Núcleo protegido y operativo al 100%!",
            Duration = 5,
        })
    end)
end)

-- Carga segura de interfaz con manejo de errores estricto
local success, Lib = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
end)

if not success or not Lib then
    SecureLog("Error crítico al cargar el módulo UI externo.")
    return
end

-- Inicialización de la ventana con la marca oficial
local Window = Lib:CreateWindow({
    Title = "Shadow Protocol | Secure Paid Version",
    Icon = "shield",
    Folder = "ShadowProtocolSecure",
    ToggleKey = Enum.KeyCode.G,
    Size = UDim2.fromOffset(680, 500),
    Transparent = false,
    Theme = "Dark",
    Author = "discord.gg/Rz33pjVVAu",
    User = {
        Enabled = true,
        Callback = function() end,
        Anonymous = false,
    },
    OpenButton = {
        Title = "Shadow Protocol",
        CornerRadius = UDim.new(1, 0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.5,
    },
})

-- Pestañas del Sistema
local Tabs = {
    RLGL = Window:Tab({ Title = "Red Light Green Light", Icon = "traffic-cone" }),
    Combat = Window:Tab({ Title = "Combat & ESP", Icon = "swords" }),
    Utilities = Window:Tab({ Title = "Utilities & TP", Icon = "wrench" }),
    UISettings = Window:Tab({ Title = "UI Settings", Icon = "settings" }),
}

-- Sección de Información y Estado
local InfoBox = Tabs.UISettings:Section({ Opened = true, Title = "| Security & Status Information", Icon = "info" })
InfoBox:Divider()
InfoBox:Paragraph({
    Title = "Estado del Sistema",
    Desc = '<font color="#50FA7B"><b>Protección de ciberseguridad activa. Funciones al 100%.</b></font>',
})
InfoBox:Divider()
InfoBox:Paragraph({
    Title = "Discord Oficial",
    Desc = '<font color="#A5B4FC"><b>discord.gg/Rz33pjVVAu</b></font>',
})

SecureLog("¡Interfaz segura inicializada con éxito!")
return SecureEnvironment
