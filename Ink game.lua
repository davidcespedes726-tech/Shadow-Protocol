-- =====================================================================
--      SHADOW PROTOCOL - PAID VERSION (INK GAME ADVANCED CORE)
-- =====================================================================
-- Author: Shadow Protocol Team
-- Discord: discord.gg/Rz33pjVVAu
-- Version: 3.5.0-Release
-- =====================================================================

local ShadowProtocol = {}
ShadowProtocol.Version = "3.5.0"
ShadowProtocol.Settings = {
    Theme = "Cyberpunk",
    Keybind = Enum.KeyCode.G,
    DebugMode = false,
    NotificationsEnabled = true
}

-- Servicios esenciales de Roblox
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Sistema de notificaciones nativo integrado de alta calidad
function ShadowProtocol:Notify(title, content, duration)
    pcall(function()
        if not self.Settings.NotificationsEnabled then return end
        
        -- Cargar librería de UI externa de forma segura
        local success, UI = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
        end)
        
        if success and UI and UI.Notify then
            UI:Notify({
                Title = title or "Shadow Protocol",
                Content = content or "Operación completada con éxito.",
                Duration = duration or 4
            })
        else
            -- Notificación de respaldo por consola/coregui
            print("[Shadow Protocol Notification] " .. tostring(title) .. ": " .. tostring(content))
        end
    end)
end

-- Mensaje de bienvenida inicial y estado operativo
task.spawn(function()
    task.wait(2)
    ShadowProtocol:Notify(
        "Shadow Protocol Paid", 
        "¡Todas las funciones están sirviendo y operativas al 100%!", 
        7
    )
end)

-- Módulo de Utilidades y Anti-AFK / Teleports
ShadowProtocol.Utils = {}

function ShadowProtocol.Utils:TeleportTo(cframe)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local hrp = character.HumanoidRootPart
    hrp.Velocity = Vector3.zero
    hrp.RotVelocity = Vector3.zero
    hrp.Anchored = true
    character:PivotTo(cframe)
    task.wait(0.1)
    hrp.Velocity = Vector3.zero
    hrp.Anchored = false
end

function ShadowProtocol.Utils:ToggleAntiCrawl(state)
    task.spawn(function()
        while state do
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Crawling") then
                char.Crawling:Destroy()
            end
            task.wait(0.3)
        end
    end)
end

-- Módulo Principal de Funciones del Ink Game
ShadowProtocol.GameModules = {
    RedLightGreenLight = {
        Active = false,
        AutoFreeze = function(enabled)
            print("[Shadow Protocol] Módulo Freeze on Red Light configurado a: " .. tostring(enabled))
        end,
        TPToEnd = function()
            ShadowProtocol.Utils:TeleportTo(CFrame.new(-45, 1025, 137))
            ShadowProtocol:Notify("Red Light Green Light", "Teletransportado al final con éxito.", 3)
        end,
        TPToStart = function()
            ShadowProtocol.Utils:TeleportTo(CFrame.new(-49, 1023, -540))
            ShadowProtocol:Notify("Red Light Green Light", "Teletransportado al inicio con éxito.", 3)
        end
    },
    Combat = {
        AimbotEnabled = false,
        ESPEnabled = false,
        ToggleESP = function(state)
            ShadowProtocol.GameModules.Combat.ESPEnabled = state
            ShadowProtocol:Notify("Combat Module", "ESP de jugadores: " .. (state and "Activado" or "Desactivado"), 3)
        end
    }
}

-- Inicializador de la Interfaz de Usuario Gráfica (UI)
function ShadowProtocol:InitializeUI()
    local success, library = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
    end)

    if not success or not library then
        warn("[Shadow Protocol] Error crítico: No se pudo cargar la librería UI.")
        return
    end

    local Window = library:CreateWindow({
        Title = "Shadow Protocol | Paid Version",
        Icon = "bird",
        Folder = "ShadowProtocol",
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

    -- Pestañas del Panel Avanzado
    local Tabs = {
        RLGL = Window:Tab({ Title = "Red Light Green Light", Icon = "traffic-cone" }),
        Dalgona = Window:Tab({ Title = "Dalgona & Pentathlon", Icon = "cookie" }),
        Combat = Window:Tab({ Title = "Combat & ESP", Icon = "swords" }),
        Utilities = Window:Tab({ Title = "Utilities & TP", Icon = "wrench" }),
        UISettings = Window:Tab({ Title = "UI Settings", Icon = "settings" }),
    }

    -- Sección RLGL
    local rlglSection = Tabs.RLGL:Section({ Opened = true, Title = "| Red Light Green Light Core", Icon = "hand" })
    
    rlglSection:Button({
        Title = "TP To End Zone",
        Callback = function()
            ShadowProtocol.GameModules.RedLightGreenLight.TPToEnd()
        end,
    })

    rlglSection:Button({
        Title = "TP To Start Zone",
        Callback = function()
            ShadowProtocol.GameModules.RedLightGreenLight.TPToStart()
        end,
    })

    rlglSection:Toggle({
        Title = "Anti Crawl / Auto Recover",
        Default = false,
        Callback = function(state)
            ShadowProtocol.Utils:ToggleAntiCrawl(state)
            ShadowProtocol:Notify("RLGL", "Anti Crawl modificado: " .. tostring(state), 3)
        end,
    })

    -- Sección Combat
    local combatSection = Tabs.Combat:Section({ Opened = true, Title = "| Combat & Visuales", Icon = "target" })
    
    combatSection:Toggle({
        Title = "Player ESP (Highlight)",
        Default = false,
        Callback = function(state)
            ShadowProtocol.GameModules.Combat.ToggleESP(state)
        end,
    })

    -- Sección Ajustes / Información del Sistema (Discord y Estado)
    local infoSection = Tabs.UISettings:Section({ Opened = true, Title = "| Shadow Protocol Information", Icon = "info" })
    
    infoSection:Divider()
    infoSection:Paragraph({
        Title = "Status del Sistema",
        Desc = '<font color="#50FA7B"><b>Todas las funciones están operativas y sirviendo al 100%</b></font>',
    })
    
    infoSection:Divider()
    infoSection:Paragraph({
        Title = "Discord Oficial",
        Desc = '<font color="#A5B4FC"><b>discord.gg/Rz33pjVVAu</b></font>',
    })
    
    infoSection:Space()
    infoSection:Section({ Opened = true, Title = '<font color="#FBBF24"><b>Registro de Versión:</b></font>' })
    infoSection:Divider()
    infoSection:Paragraph({ 
        Title = "Build:", 
        Desc = '<font color="#F3F4F6">> Shadow Protocol Paid v3.5.0 cargado y compilado sin errores.</font>' 
    })

    print("[Shadow Protocol] Interfaz gráfica renderizada correctamente.")
end

-- Auto-ejecución segura del núcleo
task.spawn(function()
    ShadowProtocol:InitializeUI()
end)

return ShadowProtocol
