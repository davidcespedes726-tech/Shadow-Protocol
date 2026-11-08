-- ============================================================
--       SHADOW PROTOCOL - PAID VERSION (LOADER OFICIAL)
-- ============================================================

task.spawn(function()
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Shadow Protocol Paid",
            Text = "¡Cargando sistema y verificando funciones al 100%!",
            Duration = 5,
        })
    end)
end)

-- Descarga directa del archivo original alojado en tu GitHub
local success, result = pcall(function()
    return game:HttpGet("https://raw.githubusercontent.com/davidcespedes726-tech/Shadow-Protocol/refs/heads/main/Ink%20game.lua")
end)

if success and result and #result > 100 then
    local executeSuccess, err = pcall(function()
        loadstring(result)()
    end)
    
    if not executeSuccess then
        warn("[Shadow Protocol] Error de ejecución: " .. tostring(err))
    else
        print("[Shadow Protocol Paid] ¡Ejecutado correctamente!")
    end
else
    warn("[Shadow Protocol] Error: No se pudo descargar el archivo desde el repositorio o está vacío.")
end
```[cite: 10]

### Pasos para asegurarte de que funcione al 100%:
1. Ve a tu repositorio en GitHub y asegúrate de que el archivo se llame exactamente `Ink game.lua` (con el espacio o codificado como `%20`) y que contenga el código completo[cite: 10].
2. Si prefieres evitar problemas con los espacios en la URL de GitHub, te sugiero renombrar el archivo en tu repositorio a **`inkgame.lua`** (sin espacios) y actualizar la URL del `game:HttpGet` en el script de arriba para que coincida.
