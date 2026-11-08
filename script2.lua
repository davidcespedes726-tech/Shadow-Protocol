-- =================================================
    -- EVENTO DE VALIDACIÓN DE KEY (CORREGIDO)
    -- =================================================
    VerifyButton.MouseButton1Click:Connect(function()
        local inputKey = string.gsub(KeyInputText.Text, "%s+", "") -- Elimina espacios accidentales
        
        if inputKey == "" then
            StatusLabel.Text = "Por favor ingresa una llave"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            return
        end

        StatusLabel.Text = "Verificando Key y HWID..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)

        task.spawn(function()
            -- 1. Intentar validar la licencia en KeyAuth
            local success, result = pcall(function()
                return KeyAuth:license(inputKey)
            end)

            -- 2. Verificar el estado global de autenticación del módulo
            if KeyAuth.authenticated or (success and result == true) then
                StatusLabel.Text = "¡Acceso concedido!"
                StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
                task.wait(1)
                
                KeyGui:Destroy()
                LoadMainScript()
            else
                -- Si falla, mostrar la respuesta o mensaje de error de KeyAuth
                local errMsg = type(result) == "string" and result or "Key inválida o HWID no coincide"
                StatusLabel.Text = errMsg
                StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            end
        end)
    end)
