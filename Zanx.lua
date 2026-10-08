-- Zanx - Enhanced Mobile UI with Airflow
local function waitForLoadingScreen()
	local players = game:GetService("Players")
	local coreGui = game:GetService("CoreGui")

	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	local player = players.LocalPlayer
	while not player do
		players:GetPropertyChangedSignal("LocalPlayer"):Wait()
		player = players.LocalPlayer
	end

	local playerGui = player:WaitForChild("PlayerGui")
	local function isActiveLoadingGui(object)
		local normalizedName = object.Name:lower():gsub("[%s_%-]", "")
		if normalizedName ~= "loadingscreen" and not normalizedName:find("loadingscreen", 1, true) then
			return false
		end

		local current = object
		while current and current ~= playerGui and current ~= coreGui do
			if current:IsA("LayerCollector") and not current.Enabled then
				return false
			end
			if current:IsA("GuiObject") and not current.Visible then
				return false
			end
			current = current.Parent
		end
		return object:IsDescendantOf(playerGui) or object:IsDescendantOf(coreGui)
	end

	local clearSince
	repeat
		local loading = false
		for _, root in ipairs({playerGui, coreGui}) do
			for _, object in ipairs(root:GetDescendants()) do
				if isActiveLoadingGui(object) then
					loading = true
					break
				end
			end
			if loading then break end
		end

		clearSince = loading and nil or (clearSince or os.clock())
		task.wait(0.1)
	until clearSince and os.clock() - clearSince >= 0.5
end

waitForLoadingScreen()

do
    local function safeNewcclosure(fn)
        return newcclosure and newcclosure(fn) or fn
    end

    if not getgenv().__LionStartupHooks then
        getgenv().__LionStartupHooks = true
        if setthreadidentity then
            pcall(setthreadidentity, 8)
        end

        local okEnv, renv = pcall(getrenv)
        local setmetatableTarget = okEnv and renv and renv.setmetatable
        if hookfunction and setmetatableTarget then
            local oldSetmetatable = setmetatableTarget
            local okHook, hooked = pcall(hookfunction, setmetatableTarget, safeNewcclosure(function(Table, Metatable)
                if Metatable and type(Metatable) == "table" and rawget(Metatable, "__mode") then
                    local mode = rawget(Metatable, "__mode")
                    if mode == "kv" or mode == "v" or mode == "k" then
                        local okTrace, trace = pcall(debug.traceback)
                        trace = okTrace and trace or ""
                        if trace:find("MiscellaneousController", 1, true)
                            or trace:find("CameraSecurity", 1, true)
                            or trace:find("AnalyticsPipelineController", 1, true) then
                            return oldSetmetatable({1, 2, 3}, {})
                        end
                    end
                end
                return oldSetmetatable(Table, Metatable)
            end))
            if okHook and hooked then
                oldSetmetatable = hooked
            end
        end

        local okPlayer, localPlayer = pcall(function()
            return cloneref(game:GetService("Players")).LocalPlayer
        end)
        if okPlayer and localPlayer and hookfunction then
            pcall(function()
                local oldKick
                oldKick = hookfunction(localPlayer.Kick, safeNewcclosure(function(self, ...)
                    if self == localPlayer then return nil end
                    return oldKick(self, ...)
                end))
            end)

            pcall(function()
                local oldGetMouse
                oldGetMouse = hookfunction(localPlayer.GetMouse, safeNewcclosure(function(self, ...)
                    if self == localPlayer then
                        local okTrace, trace = pcall(debug.traceback)
                        if okTrace and trace:find("MiscellaneousController", 1, true) then
                            local realMouse = oldGetMouse(self, ...)
                            local fakeMouse = {}
                            setmetatable(fakeMouse, {
                                __index = function(_, key)
                                    if key == "X" or key == "Y" then
                                        local loc = game:GetService("UserInputService"):GetMouseLocation()
                                        return key == "X" and loc.X or loc.Y
                                    end
                                    local val = realMouse[key]
                                    if type(val) == "function" then
                                        return function(_, ...) return val(realMouse, ...) end
                                    end
                                    return val
                                end,
                                __newindex = function(_, key, value)
                                    realMouse[key] = value
                                end
                            })
                            return fakeMouse
                        end
                    end
                    return oldGetMouse(self, ...)
                end))
            end)
        end
    end
end

print'[Zanx] Initializing Airflow UI...'

-- Load Airflow UI Library
local Airflow = loadstring(game:HttpGet("https://raw.githubusercontent.com/PookiePepelsss/Airflow-UI/refs/heads/main/Source.luau"))()

Airflow:LoadFont({ Name = "ValleySans" })

local Window = Airflow:CreateWindow({
	Name = "Zanx",
	LoadingSubtitle = "Advanced Mobile Enhancement",
	Theme = "Default",
	ToggleUIKeybind = "RightControl",
	ConfigurationSaving = { Enabled = true, FolderName = "Zanx", FileName = "default" },
	Home = {
		Name = "Home",
		Stats = { "FPS", "Ping", "Executor", "Game", "Region", "Time" },
		Pages = {
			{
				Name = "Changelog",
				Icon = "scroll-text",
				Entries = {
					{ Title = "v1.0", Tag = "Latest", Changes = { "Airflow UI Integration", "Mobile Optimized", "Enhanced Security" } },
				},
			},
			{
				Name = "Info",
				Icon = "info",
				Content = "Zanx - Advanced Mobile Enhancement Script with Airflow UI. Stay safe and have fun!",
			},
		},
	},
})

-- Main Features Tab
local Features = Window:CreateTab({ Name = "Features", Desc = "Core functionality", Icon = "zap" })

Features:CreateSection("Combat")

Features:CreateToggle({
	Name = "Hit Notifier",
	Desc = "Get notified when you hit enemies",
	CurrentValue = false,
	Flag = "HitNotifier",
	Callback = function(Value)
		print("Hit Notifier:", Value)
	end,
})

Features:CreateSlider({
	Name = "Hit Notify Duration",
	Desc = "How long to show hit notifications",
	Range = { 1, 10 },
	Increment = 1,
	Suffix = "s",
	CurrentValue = 1,
	Flag = "NotifyDuration",
	Callback = function(Value)
		print("Notify Duration:", Value)
	end,
})

Features:CreateDropdown({
	Name = "Hit Notify Format",
	Options = {
		"Hit {NAME} for {DMG} in the {PART}",
		"Hit {NAME} for {DMG} with {WEAPON}",
		"{NAME} took {DMG} damage in the {PART}",
		"{WEAPON} hit {NAME} for {DMG}",
	},
	CurrentOption = "Hit {NAME} for {DMG} in the {PART}",
	Flag = "NotifyFormat",
	Callback = function(Option)
		print("Notify Format:", Option)
	end,
})

Features:CreateSection("Visuals")

Features:CreateToggle({
	Name = "FPS Counter",
	Desc = "Display FPS in corner",
	CurrentValue = false,
	Flag = "FPSCounter",
	Callback = function(Value)
		print("FPS Counter:", Value)
	end,
})

Features:CreateToggle({
	Name = "Player ESP",
	Desc = "See all players through walls",
	CurrentValue = false,
	Flag = "PlayerESP",
	Callback = function(Value)
		print("Player ESP:", Value)
	end,
})

Features:CreateSlider({
	Name = "ESP Distance",
	Desc = "Maximum distance for ESP",
	Range = { 50, 500 },
	Increment = 10,
	Suffix = "m",
	CurrentValue = 200,
	Flag = "ESPDistance",
	Callback = function(Value)
		print("ESP Distance:", Value)
	end,
})

-- Advanced Tab
local Advanced = Window:CreateTab({ Name = "Advanced", Desc = "Advanced settings", Icon = "sliders" })

Advanced:CreateSection("Performance")

Advanced:CreateToggle({
	Name = "Optimize Graphics",
	Desc = "Reduce lag with optimized rendering",
	CurrentValue = false,
	Flag = "OptimizeGraphics",
	Callback = function(Value)
		print("Graphics Optimization:", Value)
	end,
})

Advanced:CreateSlider({
	Name = "Render Distance",
	Range = { 100, 1000 },
	Increment = 50,
	Suffix = "m",
	CurrentValue = 500,
	Flag = "RenderDistance",
	Callback = function(Value)
		print("Render Distance:", Value)
	end,
})

Advanced:CreateSection("Safety")

Advanced:CreateToggle({
	Name = "Anti-Ban Protection",
	Desc = "Enable enhanced anti-detection",
	CurrentValue = true,
	Flag = "AntiBan",
	Callback = function(Value)
		print("Anti-Ban Protection:", Value)
	end,
})

Advanced:CreateToggle({
	Name = "Spoof Executor",
	Desc = "Hide executor information",
	CurrentValue = true,
	Flag = "SpoofExecutor",
	Callback = function(Value)
		print("Spoof Executor:", Value)
	end,
})

-- Customization Tab
local Customization = Window:CreateTab({ Name = "Customization", Desc = "Personalize your experience", Icon = "palette" })

Customization:CreateSection("Appearance")

Customization:CreateColorPicker({
	Name = "Primary Color",
	Color = Color3.fromRGB(235, 199, 246),
	Flag = "PrimaryColor",
	Callback = function(Color)
		print("Primary Color Changed:", Color)
	end,
})

local ThemeToggle = Customization:CreateToggle({
	Name = "Dark Mode",
	Desc = "Enable dark theme",
	CurrentValue = false,
	Flag = "DarkMode",
	Callback = function(Value)
		print("Dark Mode:", Value)
	end,
})

Customization:CreateSection("UI Settings")

Customization:CreateThemePicker({ Flag = "Theme" })

Customization:CreateKeybind({
	Name = "Toggle UI",
	CurrentKeybind = "RightControl",
	OnChanged = function(Key)
		Window:SetKeybind(Key)
	end,
})

Customization:CreateConfigManager({ Name = "Configs" })

-- Notifications/Popups Tab
local Notifications = Window:CreateTab({ Name = "Notifications", Desc = "Test notifications", Icon = "bell" })

Notifications:CreateSection("Notification Types")

for _, Type in ipairs({ "Info", "Success", "Warning", "Error" }) do
	Notifications:CreateButton({
		Name = Type .. " Notification",
		Callback = function()
			Airflow:Notify({
				Title = Type,
				Content = "Example " .. string.lower(Type) .. " notification from Zanx",
				Icon = "bell",
				Type = Type,
				Duration = 3,
			})
		end,
	})
end

Notifications:CreateButton({
	Name = "Test Confirm Dialog",
	Callback = function()
		Airflow:Confirm({
			Title = "Confirm Action",
			Content = "Are you sure?",
			ConfirmText = "Yes",
			CancelText = "No",
			Callback = function()
				print("Action confirmed")
				Airflow:Notify({
					Title = "Success",
					Content = "Action confirmed!",
					Type = "Success",
					Duration = 2,
				})
			end,
		})
	end,
})

-- Settings Tab
local Settings = Window:CreateTab({ Name = "Settings", Icon = "settings" })

Settings:CreateSection("Interface")

Settings:CreateThemePicker({ Flag = "Theme" })

Settings:CreateKeybind({
	Name = "Toggle UI",
	CurrentKeybind = "RightControl",
	OnChanged = function(Key)
		Window:SetKeybind(Key)
	end,
})

Settings:CreateConfigManager({ Name = "Configs" })

Settings:CreateButton({
	Name = "Unload",
	Icon = "power",
	Style = "Danger",
	Callback = function()
		Airflow:Confirm({
			Title = "Unload Zanx?",
			Content = "Are you sure you want to unload?",
			ConfirmText = "Unload",
			CancelText = "Cancel",
			Callback = function()
				print("[Zanx] Unloading...")
				Airflow:Notify({
					Title = "Goodbye",
					Content = "Zanx has been unloaded",
					Type = "Info",
					Duration = 2,
				})
				task.wait(1)
				Window:Destroy()
			end,
		})
	end,
})

Settings:CreateLabel("Zanx v1.0 - Powered by Airflow UI")

Window:LoadConfig()

print'[Zanx] Successfully loaded with Airflow UI!'
