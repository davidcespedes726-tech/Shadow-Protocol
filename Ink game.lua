-- =====================================================================
--      SHADOW PROTOCOL - PAID VERSION (CORRECTED LOADER)
-- =====================================================================

local Success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
end)

if not Success or not Library then
    warn("[Shadow Protocol] Error crítico: No se pudo cargar la librería UI.")
    
    -- Notificación visual de respaldo en pantalla para que sepas qué falló
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Shadow Protocol Error",
            Text = "Fallo al conectar con el servidor de la UI. Revisa tu red o exploit.",
            Duration = 6,
        })
    end)
    return
end

-- Inicialización de la ventana si la librería cargó con éxito
local Window = Library:CreateWindow({
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

print("[Shadow Protocol] ¡Interfaz cargada correctamente!")
