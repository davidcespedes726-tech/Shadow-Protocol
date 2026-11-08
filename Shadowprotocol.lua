task.spawn(function()
    local KeyAuthConfig = {
        name = "Shadow Protocol",
        ownerid = "6E3KP1k829",
        secret = "f38d03463f7ec6581704a2b14ad8896638014e2a7ed013ad9c313df04ec"
    }

    local HttpService = game:GetService("HttpService")
    local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
    local CoreGui = cloneref(game:GetService("CoreGui"))
    local Players = cloneref(game:GetService("Players"))
    local LocalPlayer = Players.LocalPlayer

    local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request

    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "ShadowProtocolKeySystem"
    KeyGui.ResetOnSpawn = false
    KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    pcall(function() KeyGui.Parent = CoreGui end)
    if not KeyGui.Parent then KeyGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local MainKeyFrame = Instance.new("Frame")
    MainKeyFrame.Name = "MainKeyFrame"
    MainKeyFrame.Size = UDim2.new(0, 400, 0, 220)
    MainKeyFrame.Position = UDim2.new(0.5, -200, 0.5, -110)
    MainKeyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    MainKeyFrame.BorderSizePixel = 0
    MainKeyFrame.Active = true
    MainKeyFrame.Draggable = true
    MainKeyFrame.Parent = KeyGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = MainKeyFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 40)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "SHADOW PROTOCOL - KEYAUTH SYSTEM"
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Parent = MainKeyFrame

    local KeyInputText = Instance.new("TextBox")
    KeyInputText.Name = "KeyInputText"
    KeyInputText.Size = UDim2.new(0.85, 0, 0, 40)
    KeyInputText.Position = UDim2.new(0.075, 0, 0.28, 0)
    KeyInputText.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    KeyInputText.Text = ""
    KeyInputText.PlaceholderText = "Ingresa tu Key de KeyAuth aquí..."
    KeyInputText.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInputText.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    KeyInputText.TextSize = 14
    KeyInputText.Font = Enum.Font.Gotham
    KeyInputText.Parent = MainKeyFrame

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = KeyInputText

    local VerifyButton = Instance.new("TextButton")
    VerifyButton.Name = "VerifyButton"
    VerifyButton.Size = UDim2.new(0.85, 0, 0, 40)
    VerifyButton.Position = UDim2.new(0.075, 0, 0.52, 0)
    VerifyButton.BackgroundColor3 = Color3.fromRGB(80, 50, 200)
    VerifyButton.Text = "VERIFICAR KEY"
    VerifyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    VerifyButton.TextSize = 14
    VerifyButton.Font = Enum.Font.GothamBold
    VerifyButton.Parent = MainKeyFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = VerifyButton

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(1, 0, 0, 30)
    StatusLabel.Position = UDim2.new(0, 0, 0.78, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "HWID Lock Activado"
    StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = MainKeyFrame

    local function LoadMainScript()
        print("[Shadow Protocol] Key validada. Cargando menú...")
        local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
        local Window = Fluent:CreateWindow({
            Title = "Shadow Protocol",
            SubTitle = "by David Cespedes",
            TabWidth = 160,
            Size = UDim2.fromOffset(580, 460),
            Acrylic = true,
            Theme = "Dark"
        })
        local Tabs = {
            Main = Window:AddTab({ Title = "Main", Icon = "rbxassetid://4483345998" }),
            Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
        }
        Tabs.Main:AddParagraph({ Title = "Estado", Content = "¡Autenticación HWID correcta!" })
        Window:SelectTab(1)
    end

    VerifyButton.MouseButton1Click:Connect(function()
        local inputKey = string.gsub(KeyInputText.Text, "%s+", "")
        if inputKey == "" then
            StatusLabel.Text = "Por favor ingresa una llave"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            return
        end

        StatusLabel.Text = "Verificando Key y HWID..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)

        task.spawn(function()
            local hwid = "unknown"
            pcall(function() hwid = RbxAnalyticsService:GetClientId() end)

            -- 1. Inicializar sesión de KeyAuth (Paso obligatorio)
            local initUrl = string.format(
                "https://keyauth.cc/api/1.2/?name=%s&ownerid=%s&secret=%s&type=init",
                HttpService:UrlEncode(KeyAuthConfig.name),
                HttpService:UrlEncode(KeyAuthConfig.ownerid),
                HttpService:UrlEncode(KeyAuthConfig.secret)
            )

            local initSuccess, initRes = pcall(function()
                if httpRequest then
                    local r = httpRequest({ Url = initUrl, Method = "GET", Headers = { ["User-Agent"] = "Mozilla/5.0" } })
                    return r and r.Body
                else
                    return game:HttpGet(initUrl)
                end
            end)

            if not initSuccess or not initRes then
                StatusLabel.Text = "Error de conexión al iniciar sesión"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                return
            end

            local initDecodeOk, initData = pcall(function()
                return HttpService:JSONDecode(initRes)
            end)

            if not initDecodeOk or not initData or not initData.success then
                StatusLabel.Text = initData and initData.message or "Error al procesar sesión"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                return
            end

            local sessionid = initData.sessionid

            -- 2. Validar la licencia usando el sessionid obtenido
            local licenseUrl = string.format(
                "https://keyauth.cc/api/1.2/?name=%s&ownerid=%s&secret=%s&type=license&key=%s&hwid=%s&sessionid=%s",
                HttpService:UrlEncode(KeyAuthConfig.name),
                HttpService:UrlEncode(KeyAuthConfig.ownerid),
                HttpService:UrlEncode(KeyAuthConfig.secret),
                HttpService:UrlEncode(inputKey),
                HttpService:UrlEncode(hwid),
                HttpService:UrlEncode(sessionid)
            )

            local success, responseBody = false, nil
            if httpRequest then
                local reqSuccess, reqRes = pcall(function()
                    return httpRequest({
                        Url = licenseUrl,
                        Method = "GET",
                        Headers = { ["User-Agent"] = "Mozilla/5.0" }
                    })
                end)
                if reqSuccess and reqRes and reqRes.Body then
                    success = true
                    responseBody = reqRes.Body
                end
            end

            if not success or not responseBody then
                local getSuccess, getRes = pcall(function()
                    return game:HttpGet(licenseUrl)
                end)
                if getSuccess then
                    success = true
                    responseBody = getRes
                end
            end

            if success and responseBody then
                local decodeSuccess, data = pcall(function()
                    return HttpService:JSONDecode(responseBody)
                end)

                if decodeSuccess and type(data) == "table" then
                    if data.success == true then
                        StatusLabel.Text = "¡Acceso concedido!"
                        StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
                        task.wait(1)
                        KeyGui:Destroy()
                        LoadMainScript()
                    else
                        StatusLabel.Text = data.message or "Key inválida o HWID no coincide"
                        StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                    end
                else
                    StatusLabel.Text = "Error al procesar respuesta"
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                end
            else
                StatusLabel.Text = "Error de conexión con KeyAuth"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            end
        end)
    end)
end)
