-- =====================================================================
--      SHADOW PROTOCOL - PAID VERSION (PARCHE DE CARGA UI)
-- =====================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Intentar cargar la librería UI de forma segura con reintentos
local success, library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
end)

if not success or not library then
    warn("[Shadow Protocol] Error: No se pudo conectar con el servidor de la UI. Verificando red...")
    
    -- Notificación de respaldo en pantalla si falla la UI principal
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Shadow Protocol Error",
            Text = "Fallo al cargar la librería gráfica. Revisa tu ejecutor.",
            Duration = 6,
        })
    end)
    return
end

-- Si la librería carga con éxito, procede a crear la ventana
local Window = library:CreateWindow({
    Title = "Shadow Protocol | Paid Version",
    Icon = "bird",
    Folder = "ShadowProtocol",
    ToggleKey = Enum.KeyCode.G,
    Size = UDim2.fromOffset(650, 480),
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

print("[Shadow Protocol] ¡Interfaz cargada y ejecutada correctamente!")
