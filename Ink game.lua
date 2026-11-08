-- ============================================================
--       SHADOW PROTOCOL - PAID VERSION (LOADER)
-- ============================================================

task.spawn(function()
    pcall(function()
        -- Notificación de inicio del sistema pagado
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Shadow Protocol Paid",
            Text = "¡Cargando sistema y verificando funciones al 100%!",
            Duration = 5,
        })
    end)
end)

-- Carga el script principal del repositorio asegurando compatibilidad
local success, result = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/davidcespedes726-tech/Shadow-Protocol/refs/heads/main/Ink%20game.lua")
end)

if success and result and #result > 0 then
    -- Ejecución exitosa del script original empaquetado
    local executeSuccess, err = pcall(function()
        loadstring(result)()
    end)
    
    if not executeSuccess then
        warn("Shadow Protocol Error al ejecutar: " .. tostring(err))
    end
else
    warn("Shadow Protocol: No se pudo conectar con el repositorio remoto.")
end
