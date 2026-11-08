-- ============================================================
--       SHADOW PROTOCOL - PAID VERSION (INK GAME)
-- ============================================================

local flag, tbl, tbl2, tbl3, Workspace, Players, ReplicatedStorage, localPlayer, v, fn
local fn2, fn3, v2, tbl4, handlers, tbl5, tbl6

do
	local HttpService = game:GetService("HttpService")
	local n = 0

	pcall(function()
		if game.PlaceId ~= 99567941238278 then
			local data = nil
			local ok, result = pcall(function()
				return game:HttpGet("https://raw.githubusercontent.com/davidcespedes726-tech/Shadow-Protocol/refs/heads/main/InkVersion.json")
			end)
			if ok and result then
				pcall(function() data = HttpService:JSONDecode(result) end)
			end
			if data and data.LastCheckedVersion then
				n = tonumber(data.LastCheckedVersion) or 0
			end
		end
	end)

	flag = false
	if game.PlaceId ~= 99567941238278 then
		if n < game.PlaceVersion then flag = true end
	end

	if not game:IsLoaded() then game.Loaded:Wait() end

	tbl = {}
	tbl2 = {}
	tbl3 = {}

	Workspace = game:GetService("Workspace")
	Players = game:GetService("Players")
	ReplicatedStorage = game:GetService("ReplicatedStorage")
	localPlayer = Players.LocalPlayer
	local lib = nil

	pcall(function()
		lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Module.Lua"))()
	end)

	v = nil

	local function fn4()
		local response = nil
		pcall(function()
			response = game:HttpGet("https://raw.githubusercontent.com/platinww/CrustyMain/refs/heads/main/universal/ftgs.lua")
		end)
		if response and response ~= "" then
			response = response:gsub("local j=\"https://platinstudio.xyz/raw/WindIcons\"", "local j=\"https://raw.githubusercontent.com/eeeiqjjj/icon.github.io/refs/heads/main/lucide.lua\"")
			response = response:gsub("if u==false or not l then return nil end", "if u==false or not l then return setmetatable({Url=\"\",ImageRectOffset=Vector2.zero,ImageRectSize=Vector2.zero},{__index=function(t,k)if k==1 then return \"\" elseif k==2 then return{ImageRectPosition=Vector2.zero,ImageRectSize=Vector2.zero}end end}) end")
			response = response:gsub("if not%%(ok and data%%)then return nil end", "if not(ok and data)then return setmetatable({Url=\"\",ImageRectOffset=Vector2.zero,ImageRectSize=Vector2.zero},{__index=function(t,k)if k==1 then return \"\" elseif k==2 then return{ImageRectPosition=Vector2.zero,ImageRectSize=Vector2.zero}end end}) end")
			local chunk = loadstring(response)
			if chunk then v = chunk() end
		end
	end

	fn4()

	local function fn5(arg)
		if not isfile or not isfile(arg) then return nil end
		local getcustomasset_ = getcustomasset or getsynasset or getgenv and (getgenv().getcustomasset or getgenv().getsynasset)
		if getcustomasset_ then
			local tbl7 = {}
			local str = arg:gsub("^ShadowProtocol/", "")
			tbl7[1] = arg
			tbl7[2] = "/" .. arg
			tbl7[3] = str
			for _, v3 in ipairs(tbl7) do
				local ok, result = pcall(getcustomasset_, v3)
				if ok and result and typeof(result) == "string" and #result > 0 then return result end
			end
		end
		return nil
	end

	fn = function()
		local str = "https://raw.githubusercontent.com/platinww/UwU/main/UI/1351575.jpg"
		pcall(function()
			if isfolder and not isfolder("ShadowProtocol") then makefolder("ShadowProtocol") end
			if isfolder and not isfolder("ShadowProtocol/assets") then makefolder("ShadowProtocol/assets") end
			if isfile and not isfile("ShadowProtocol/assets/furina_v3.jpg") and writefile then
				local body = nil
				pcall(function() body = game:HttpGet("https://raw.githubusercontent.com/platinww/UwU/main/UI/1351575.jpg") end)
				if body and #body > 0 then writefile("ShadowProtocol/assets/furina_v3.jpg", body) end
			end
		end)
		local jpg = fn5("ShadowProtocol/assets/furina_v3.jpg")
		if jpg then return jpg end
		return nil
	end

	fn2 = function(arg)
		pcall(function()
			if not Window or not Window.UIElements or not Window.UIElements.Main then return end
			local main = Window.UIElements.Main
			local background = main:FindFirstChild("Background") or main
			pcall(function() main.ClipsDescendants = true end)
			if background and background:IsA("GuiObject") then pcall(function() background.ClipsDescendants = true end) end
			local furinaBgImage = background:FindFirstChild("FurinaBgImage")
			if arg then
				tbl.CurrentThemeName = "Furina Genshin"
				local v3 = fn()
				if not v3 then
					if Window and Window.SetBackgroundImage then
						pcall(function() Window:SetBackgroundImage("https://raw.githubusercontent.com/platinww/UwU/main/UI/1351575.jpg") end)
					end
					return
				end
				if not furinaBgImage then
					local imageLabel = Instance.new("ImageLabel")
					imageLabel.Name = "FurinaBgImage"
					imageLabel.Size = UDim2.new(1, 0, 1, 0)
					imageLabel.BackgroundTransparency = 1
					imageLabel.ScaleType = Enum.ScaleType.Crop
					imageLabel.ZIndex = 1
					imageLabel.ClipsDescendants = true
					imageLabel.Parent = background
					local uiCorner = Instance.new("UICorner")
					uiCorner.CornerRadius = UDim.new(0, 14)
					uiCorner.Parent = imageLabel
					furinaBgImage = imageLabel
				end
				furinaBgImage.Image = v3
				furinaBgImage.ImageTransparency = 0.5
				furinaBgImage.Visible = true
			else
				if furinaBgImage then
					furinaBgImage.Visible = false
					furinaBgImage.ImageTransparency = 1
				end
			end
		end)
	end

	local function fn6()
		local tbl7 = {}
		for match in string.gmatch("105945183689611,73508806663574,83283298046358,113495722420896,85233175572488,84182427140137,82748240649010,78860722288350,107102184635871,110898142671973,87214876397205,105203852440305,77883961484206,126623799590012,91474097079161,98718280245015,111062272133769,115821861998676,93835883876713,139649089665559,120828318960070,95338628841935,103472871155130,83657465787527,83248372739128,108358366652302,133868382220444,117812340355702,117241804955035,108163503726037,80566164738816,103177066435636,138962144446694,97387232349806,129535956026017,72327307619918,131254893672022,79431882611558,94376809664056,74712223703220,77428452195163,110731410878599,124548391472962,130015890944015,138326939239140,116483591755654,114461166826754,111178696015355,139416771716998,94742387386496,88691793193268,90662783635950,124115768167703,99726551474718,126558729644213,71614607188785,79827586059759,109284281035617,107966387870698,102579779688372,112156033802069,71932817449388,76075949487982,104604376173895,107781389641490,96366395614242,98579554681024,109105194031256,118274206899943,121262391909235,108978040611308,92301420719698,130675383145258,109936892767664,126023221721433", "%d+") do
			table.insert(tbl7, tonumber(match))
		end
		return tbl7
	end

	local v3 = fn6()
	local frame = nil
	local tbl7 = {}
	local connection = nil

	fn3 = function(arg)
		pcall(function()
			if not Window or not Window.UIElements or not Window.UIElements.Main then return end
			local main = Window.UIElements.Main
			local background = main:FindFirstChild("Background") or main
			if arg then
				tbl.CurrentThemeName = "Closing Eyes"
				local furinaBgImage = background:FindFirstChild("FurinaBgImage")
				if furinaBgImage then
					furinaBgImage.Visible = false
					furinaBgImage.ImageTransparency = 1
				end
				if not frame then
					frame = Instance.new("Frame")
					frame.Name = "AnimatedBackgroundContainer"
					frame.Size = UDim2.fromScale(1, 1)
					frame.BackgroundTransparency = 1
					frame.ClipsDescendants = true
					frame.ZIndex = 0
					frame.Parent = background
					local uiCorner = Instance.new("UICorner")
					uiCorner.CornerRadius = UDim.new(0, 14)
					uiCorner.Parent = frame
					for i, v4 in ipairs(v3) do
						local imageLabel = Instance.new("ImageLabel")
						imageLabel.Size = UDim2.fromScale(1, 1)
						imageLabel.BackgroundTransparency = 1
						imageLabel.ScaleType = Enum.ScaleType.Crop
						imageLabel.Image = "rbxassetid://" .. tostring(v4)
						imageLabel.Visible = false
						imageLabel.ZIndex = 0
						imageLabel.Parent = frame
						local uiCorner2 = Instance.new("UICorner")
						uiCorner2.CornerRadius = UDim.new(0, 14)
						uiCorner2.Parent = imageLabel
						tbl7[i] = imageLabel
					end
					task.spawn(function()
						local ContentProvider = game:GetService("ContentProvider")
						pcall(function() ContentProvider:PreloadAsync(tbl7) end)
					end)
				end
				frame.Visible = not Window.Closed
				if not connection and #tbl7 > 0 then
					local n2 = 1
					tbl7[n2].Visible = true
					local n3 = 0.04
					local n4 = 0
					connection = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
						n4 += deltaTime
						if n4 >= n3 then
							n4 %= n3
							if tbl7[n2] then tbl7[n2].Visible = false end
							n2 = n2 % #tbl7 + 1
							if tbl7[n2] then tbl7[n2].Visible = true end
						end
					end)
				end
			else
				if connection then
					pcall(function() connection:Disconnect() end)
					connection = nil
				end
				if frame then frame.Visible = false end
			end
		end)
	end

	pcall(function()
		if v and v.AddTheme then
			v:AddTheme({
				Name = "Cyberpunk",
				Accent = Color3.fromHex("#ff0055"),
				Dialog = Color3.fromHex("#0f1123"),
				Outline = Color3.fromHex("#00f0ff"),
				Text = Color3.fromHex("#ffffff"),
				Placeholder = Color3.fromHex("#00f0ff"),
				Background = Color3.fromHex("#080914"),
				Button = Color3.fromHex("#1a0033"),
				Icon = Color3.fromHex("#00f0ff"),
				Toggle = Color3.fromHex("#ff0055"),
				Checkbox = Color3.fromHex("#00f0ff"),
			})
		end
	end)

	local str = "Dark"
	pcall(function()
		if isfile and isfile("ShadowProtocol/default_theme.txt") and readfile then
			local txt = readfile("ShadowProtocol/default_theme.txt")
			if txt and txt ~= "" and v and v.Themes and v.Themes[txt] then str = txt end
		end
	end)

	if not v then return end
	local color = Color3.fromHex

	v2 = v:CreateWindow({
		Title = "Shadow Protocol | Paid Version",
		Icon = "bird",
		Folder = "ShadowProtocol",
		ToggleKey = Enum.KeyCode.G,
		Size = UDim2.fromOffset(650, 480),
		Transparent = false,
		Background = "",
		Theme = str,
		Author = "discord.gg/Rz33pjVVAu",
		User = { Enabled = true, Callback = function() end, Anonymous = false },
		OpenButton = {
			Title = "Shadow Protocol",
			CornerRadius = UDim.new(1, 0),
			StrokeThickness = 3,
			Enabled = true,
			Draggable = true,
			OnlyMobile = false,
			Scale = 0.5,
			Color = ColorSequence.new(Color3.fromHex("#A5B4FC"), color("#FFFFFF")),
		},
	})

	tbl4 = {}
	handlers = {}

	local function fn7(arg)
		if not arg or arg._wrapped then return arg end
		arg._wrapped = true
		local toggle = arg.Toggle
		if toggle then
			arg.Toggle = function(arg2, arg3)
				local title = arg3.Flag or arg3.Title
				local callback = arg3.Callback
				if title then
					arg3.Callback = function(arg4)
						tbl[title] = arg4
						if callback then pcall(callback, arg4) end
					end
				end
				local v4 = toggle(arg2, arg3)
				if title then
					tbl4[title] = v4
					if arg3.Callback then handlers[title] = arg3.Callback end
				end
				return v4
			end
		end
		return arg
	end

	local tab = v2.Tab
	v2.Tab = function(arg, arg2)
		local v4 = tab(arg, arg2)
		local section = v4.Section
		if section then
			v4.Section = function(arg3, arg4)
				local v5 = section(arg3, arg4)
				return fn7(v5)
			end
		end
		return v4
	end

	tbl5 = {
		RLGL = v2:Tab({ Title = "Red Light Green Light", Icon = "traffic-cone" }),
		Dalgona = v2:Tab({ Title = "Dalgona & Pentathlon", Icon = "cookie" }),
		LightsOut = v2:Tab({ Title = "Lights Out", Icon = "moon" }),
		HSTOW = v2:Tab({ Title = "Hide And Seek & Tug Of War", Icon = "eye" }),
		MingleGlass = v2:Tab({ Title = "Jump Rope & Glass Bridge", Icon = "swords" }),
		Mingle = v2:Tab({ Title = "Mingle", Icon = "users" }),
		Rebel = v2:Tab({ Title = "Rebel", Icon = "target" }),
		Sky = v2:Tab({ Title = "Sky & Squid Game", Icon = "cloud" }),
		Guard = v2:Tab({ Title = "Guard Mode", Icon = "shield" }),
		Combat = v2:Tab({ Title = "Combat", Icon = "swords" }),
		Tools = v2:Tab({ Title = "Tools", Icon = "wrench" }),
		Utilities = v2:Tab({ Title = "Utilities", Icon = "wrench" }),
		Visual = v2:Tab({ Title = "Visual", Icon = "eye" }),
		UISettings = v2:Tab({ Title = "UI Settings", Icon = "settings" }),
	}

	tbl6 = {
		InfoBox = tbl5.UISettings:Section({ Opened = true, Title = "| Shadow Protocol Information", Icon = "info" }),
	}

	local infoBox = tbl6.InfoBox
	infoBox:Divider()
	infoBox:Paragraph({
		Title = "Status",
		Desc = "<font color=\"#50FA7B\"><b>Todas las funciones están sirviendo y operativas al 100%</b></font>",
	})
	infoBox:Divider()
	infoBox:Paragraph({
		Title = "Discord Oficial",
		Desc = "<font color=\"#A5B4FC\"><b>discord.gg/Rz33pjVVAu</b></font>",
	})
	infoBox:Space()
	infoBox:Section({ Opened = true, Title = "<font color=\"#FBBF24\"><b>Estado del Sistema:</b></font>" })
	infoBox:Divider()
	infoBox:Paragraph({ Title = "Anuncio:", Desc = "<font color=\"#F3F4F6\">> Sistema cargado correctamente. Todas las herramientas y características están activas y operativas.</font>" })
end

local fn4
do
	local value = nil
	local n = 0
	local function fn5()
		if tick() - n < 0.5 then return value end
		n = tick()
		local values = Workspace:FindFirstChild("Values")
		values = values and values:FindFirstChild("CurrentGame")
		if values and values.Value ~= "" then value = values.Value else value = nil end
		return value
	end
	fn4 = function(arg) return fn5() == arg end
end

local fn5
local str = "rbxassetid://4590657391"
pcall(function()
	if not isfolder("ShadowProtocol") then makefolder("ShadowProtocol") end
	if not isfile("ShadowProtocol/notify.wav") then
		local response = game:HttpGet("https://github.com/platinww/UwU/raw/refs/heads/main/UI/notify.wav")
		writefile("ShadowProtocol/notify.wav", response)
	end
	if getcustomasset then str = getcustomasset("ShadowProtocol/notify.wav") end
end)

fn5 = function(arg, arg2)
	v:Notify({ Title = arg or "Shadow Protocol", Content = arg2, Duration = 4 })
	pcall(function()
		local sound = Instance.new("Sound")
		sound.SoundId = str or "rbxassetid://4590657391"
		sound.Volume = 2
		sound.Parent = game:GetService("SoundService")
		sound:Play()
		game:GetService("Debris"):AddItem(sound, 3)
	end)
end

-- ============================================================
--           NOTIFICACIÓN DE INICIO / ANUNCIO
-- ============================================================
task.spawn(function()
	task.wait(1.5)
	pcall(function()
		if v and v.Notify then
			v:Notify({
				Title = "Shadow Protocol Paid",
				Content = "¡Todas las funciones están sirviendo y operativas al 100%!",
				Duration = 8,
			})
		end
	end)
end)

local fn6
local tbl7 = {
	w = 87, a = 65, s = 83, d = 68, space = 32, e = 69, q = 81, f = 70, r = 82, t = 84, y = 89, x = 88, c = 67, v = 86, b = 66, g = 71, h = 72, z = 90,
	["1"] = 49, ["2"] = 50, ["3"] = 51, ["4"] = 52, ["5"] = 53, ["6"] = 54, ["7"] = 55, ["8"] = 56, ["9"] = 57, ["0"] = 48
}

fn6 = function(arg)
	if type(keypress) == "function" and type(keyrelease) == "function" then
		local v3 = tbl7[string.lower(tostring(arg))]
		if v3 then
			keypress(v3)
			task.wait(0.05)
			keyrelease(v3)
			return true
		end
	end
	return false
end

local fn7
local HBGQTE = nil
fn7 = function()
	if not HBGQTE then
		pcall(function()
			local modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules", 5)
			if modules then HBGQTE = require(modules:WaitForChild("HBGQTE", 5)) end
		end)
	end
	return HBGQTE
end

local guid = nil
task.spawn(function()
	pcall(function()
		local modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules", 5)
		if modules then
			local games = modules:WaitForChild("Games", 5)
			if games then
				local PentathlonClient = require(games:WaitForChild("PentathlonClient", 5))
				if PentathlonClient and type(PentathlonClient) == "table" then
					local runServerGame = PentathlonClient.RunServerGame
					if runServerGame then
						PentathlonClient.RunServerGame = function(arg, arg2, ...)
							if arg and arg.GUID then guid = arg.GUID end
							local v3 = table.pack(...)
							local v4 = runServerGame
							v3.n = 3 + v3.n - 1
							table.move(v3, 1, v3.n, 3, v3)
							v3[1] = arg
							v3[2] = arg2
							return v4(table.unpack(v3, 1, v3.n))
						end
					end
				end
			end
		end
	end)
end)

local fn9 = function(arg)
	local character = localPlayer.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	local humanoidRootPart = character.HumanoidRootPart
	humanoidRootPart.Velocity = Vector3.zero
	humanoidRootPart.RotVelocity = Vector3.zero
	humanoidRootPart.Anchored = true
	character:PivotTo(arg)
	task.wait()
	humanoidRootPart.Velocity = Vector3.zero
	humanoidRootPart.Anchored = false
end

tbl3.lastTPTime = 0
tbl6.RLGLBox = tbl5.RLGL:Section({ Opened = true, Title = "| Red Light Green Light", Icon = "hand" })

tbl6.RLGLBox:Button({
	Title = "TP To End",
	Callback = function()
		if tick() - tbl3.lastTPTime < 10 then
			fn5("Cooldown", "Please wait before teleporting again.")
			return
		end
		if fn4("RedLightGreenLight") then
			fn9(CFrame.new(-45, 1025, 137))
			tbl3.lastTPTime = tick()
		else
			fn5(nil, "Red Light Green Light is not currently running.")
		end
	end,
})

tbl6.RLGLBox:Button({
	Title = "TP To Start",
	Callback = function()
		if tick() - tbl3.lastTPTime < 10 then
			fn5("Cooldown", "Please wait before teleporting again.")
			return
		end
		if fn4("RedLightGreenLight") then
			fn9(CFrame.new(-49, 1023, -540))
			tbl3.lastTPTime = tick()
		else
			fn5(nil, "Red Light Green Light is not currently running.")
		end
	end,
})
