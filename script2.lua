task.spawn(function()
    -- =================================================
    -- CONFIGURACIÓN DE KEYAUTH (CREDENTCIALES)
    -- =================================================
    local KeyAuthApp = {
        name = "Shadow Protocol",
        ownerid = "6E3KP1k829", -- Tu Account Owner ID
        secret = "f38d03463f7ec6581704a2b14ad8896638014e2a7ed013ad9c313df04ec", -- Tu Application Secret
        version = "1.0"
    }

    -- Cargar el módulo oficial de KeyAuth para Roblox
    local KeyAuth = loadstring(game:HttpGet("https://raw.githubusercontent.com/KeyAuth/KeyAuth-Roblox-Module/main/KeyAuth.lua"))()
    
    -- Inicializar KeyAuth
    local initSuccess = pcall(function()
        KeyAuth:init(KeyAuthApp.name, KeyAuthApp.ownerid, KeyAuthApp.secret, KeyAuthApp.version)
    end)

    -- =================================================
    -- SERVICIOS DE ROBLOX
    -- =================================================
    local CoreGui = cloneref(game:GetService("CoreGui"))
    local Players = cloneref(game:GetService("Players"))
    local LocalPlayer = Players.LocalPlayer

    -- =================================================
    -- GUI DE KEY SYSTEM
    -- =================================================
    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "ShadowProtocolKeySystem"
    KeyGui.ResetOnSpawn = false
    KeyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    pcall(function()
        KeyGui.Parent = CoreGui
    end)
    if not KeyGui.Parent then
        KeyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

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
    StatusLabel.Size = UDim2.new(1, 0, 0, 30)
    StatusLabel.Position = UDim2.new(0, 0, 0.78, 0)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "HWID Lock Activado"
    StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = MainKeyFrame

    -- =================================================
    -- FUNCIÓN PARA CARGAR EL SCRIPT PRINCIPAL (FLUENT)
    -- =================================================
    local function LoadMainScript()
        print("[Shadow Protocol] Key validada exitosamente. Cargando Fluent Menu...")
        
        -- Carga de tu menú principal
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

        Tabs.Main:AddParagraph({
            Title = "Estado",
            Content = "¡Autenticación HWID correcta! Shadow Protocol activo."
        })

        Window:SelectTab(1)
    end

    -- =================================================
    -- EVENTO DE VALIDACIÓN DE KEY
    -- =================================================
    VerifyButton.MouseButton1Click:Connect(function()
        local inputKey = KeyInputText.Text
        
        if inputKey == "" then
            StatusLabel.Text = "Por favor ingresa una llave"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            return
        end

        StatusLabel.Text = "Verificando Key y HWID..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)

        -- Intentar autenticar la Key en KeyAuth
        local authSuccess, authResponse = pcall(function()
            return KeyAuth:license(inputKey)
        end)

        if authSuccess and KeyAuth.authenticated then
            StatusLabel.Text = "¡Acceso concedido!"
            StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
            task.wait(1)
            
            -- Destruir la ventana del Key System y desplegar el script principal
            KeyGui:Destroy()
            LoadMainScript()
        else
            StatusLabel.Text = "Key inválida o HWID no coincide"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)
end)