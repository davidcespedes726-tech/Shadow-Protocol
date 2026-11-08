task.spawn(function()
    local CoreGui = cloneref(game:GetService("CoreGui"))
    local Players = cloneref(game:GetService("Players"))
    local LocalPlayer = Players.LocalPlayer

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
    KeyInputText.PlaceholderText = "Ingresa tu Key aquí..."
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
    StatusLabel.Text = "Sistema Local Activo"
    StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    StatusLabel.TextSize = 12
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = MainKeyFrame

    local function LoadMainScript()
        local success, Fluent = pcall(function()
            return loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
        end)
        
        if success and Fluent then
            -- Acrylic desactivado para que el fondo sea sólido y legible
            local Window = Fluent:CreateWindow({
                Title = "Shadow Protocol",
                SubTitle = "by David Cespedes",
                TabWidth = 140,
                Size = UDim2.fromOffset(500, 380),
                Acrylic = false,
                Theme = "Dark"
            })

            local Tabs = {
                Main = Window:AddTab({ Title = "Main", Icon = "rbxassetid://4483345998" }),
                Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
            }

            Tabs.Main:AddParagraph({
                Title = "Estado del Sistema",
                Content = "¡Autenticación correcta! Shadow Protocol activo y operativo."
            })

            Window:SelectTab(1)
        end
    end

    VerifyButton.MouseButton1Click:Connect(function()
        local inputKey = string.gsub(KeyInputText.Text, "%s+", "")
        
        if inputKey == "" then
            StatusLabel.Text = "Por favor ingresa una llave"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
            return
        end

        StatusLabel.Text = "¡Acceso concedido!"
        StatusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
        
        task.delay(0.5, function()
            KeyGui:Destroy()
            LoadMainScript()
        end)
    end)
end)
