-- LazyHub - Roll a Brainrot Script

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- ========================================
-- Default Parameters
-- ========================================
local candiesFolder = workspace:WaitForChild("Candies")
local collectDelay = 0.1
local cycleDelay = 0
local offset = Vector3.new(0, 3, 0)
local autoCollectEnabled = true

local OWNER_USERID = player.UserId
local KICK_DELAY = 180
local autoKickEnabled = true
local running = true
local kickTaskRunning = false
local remainingKickTime = KICK_DELAY
local PLACE_ID = game.PlaceId

-- ========================================
-- AutoCollect Functions
-- ========================================
local function getRootPart(character)
	if not character then return nil end
	return character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart or character:FindFirstChildWhichIsA("BasePart")
end

local function bringCandyToPlayer(candyPart, rootPart)
	if not candyPart or not rootPart then return end
	if candyPart.Anchored then candyPart.Anchored = false end
	candyPart.CFrame = rootPart.CFrame + offset
end

local function collectOnce(character)
	local root = getRootPart(character)
	if not root then return end
	for _, candy in ipairs(candiesFolder:GetChildren()) do
		if not running or not autoCollectEnabled then break end
		local targetPart = nil
		if candy:IsA("BasePart") then
			targetPart = candy
		elseif candy:IsA("Model") then
			targetPart = candy.PrimaryPart or candy:FindFirstChildWhichIsA("BasePart")
		end
		if targetPart and targetPart.Parent then
			bringCandyToPlayer(targetPart, root)
			task.wait(collectDelay)
		end
	end
end

-- ========================================
-- Kick/Rejoin
-- ========================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local function kickAndRejoin(p)
	if kickTaskRunning then return end
	kickTaskRunning = true
	task.spawn(function()
		while remainingKickTime > 0 do
			if not autoKickEnabled then
				kickTaskRunning = false
				return
			end
			task.wait(1)
			remainingKickTime = remainingKickTime - 1
		end
		if p and p.Parent then
			Rayfield:Notify({
				Title = "🎃 Roll a Brainrot",
				Content = "Rejoining in 1 second...",
				Duration = 2,
				Image = "candy"
			})
			task.wait(1)
			p:Kick("Rejoining...")
			if p.UserId == OWNER_USERID then
				wait(1)
				TeleportService:Teleport(PLACE_ID, p)
			end
		end
		remainingKickTime = KICK_DELAY
		kickTaskRunning = false
	end)
end

-- ========================================
-- Rayfield Window
-- ========================================
local Window = Rayfield:CreateWindow({
	Name = "🎃 Roll a Brainrot",
	Icon = "candy",
	LoadingTitle = "Roll a Brainrot",
	LoadingSubtitle = "by LazyHub",
	ShowText = "🎃",
	Theme = "Dark",
	DisableRayfieldPrompts = false,
	DisableBuildWarnings = false,
	ConfigurationSaving = { Enabled = false },
	Discord = { Enabled = false },
	KeySystem = false,
})

local Tab = Window:CreateTab("🍬 Candy Farm", "candy")

Tab:CreateSection("Auto Collect")

Tab:CreateToggle({
	Name = "🍬 AutoCollect",
	CurrentValue = true,
	Flag = "AutoCollect",
	Callback = function(value)
		autoCollectEnabled = value
		Rayfield:Notify({
			Title = "AutoCollect",
			Content = "AutoCollect: " .. (value and "ON" or "OFF"),
			Duration = 2,
			Image = "candy"
		})
	end
})

Tab:CreateSection("Auto Kick / Rejoin")

Tab:CreateToggle({
	Name = "💀 AutoKick",
	CurrentValue = true,
	Flag = "AutoKick",
	Callback = function(value)
		autoKickEnabled = value
		if not value then remainingKickTime = KICK_DELAY end
		Rayfield:Notify({
			Title = "AutoKick",
			Content = "AutoKick: " .. (value and "ON" or "OFF"),
			Duration = 2,
			Image = "skull"
		})
	end
})

Tab:CreateButton({
	Name = "⚡ Skip Timer",
	Callback = function()
		if autoKickEnabled then
			remainingKickTime = 0
			Rayfield:Notify({
				Title = "🎃 Roll a Brainrot",
				Content = "Timer skipped! Rejoining...",
				Duration = 3,
				Image = "zap"
			})
		else
			Rayfield:Notify({
				Title = "🎃 Roll a Brainrot",
				Content = "Enable AutoKick first!",
				Duration = 3,
				Image = "alert-circle"
			})
		end
	end
})

Tab:CreateSection("Info")

Tab:CreateButton({
	Name = "📊 Current Status",
	Callback = function()
		Rayfield:Notify({
			Title = "Status",
			Content = "AutoCollect: " .. (autoCollectEnabled and "ON" or "OFF") .. " | AutoKick: " .. (autoKickEnabled and "ON" or "OFF") .. " | Kick in: " .. math.ceil(remainingKickTime) .. "s",
			Duration = 5,
			Image = "info"
		})
	end
})

-- ========================================
-- Loops
-- ========================================
task.spawn(function()
	if not player.Character then player.CharacterAdded:Wait() end
	local character = player.Character
	player.CharacterAdded:Connect(function(char) character = char end)
	task.wait(0.5)
	while running do
		if not character or not character.Parent then
			player.CharacterAdded:Wait()
			character = player.Character
			task.wait(0.2)
		end
		if autoCollectEnabled then collectOnce(character) end
		task.wait(cycleDelay)
	end
end)

task.spawn(function()
	while true do
		if autoKickEnabled and not kickTaskRunning then
			kickAndRejoin(player)
		end
		task.wait(1)
	end
end)

task.spawn(function()
	while true do
		task.wait(30)
		if autoKickEnabled and kickTaskRunning then
			Rayfield:Notify({
				Title = "⏱️ Kick Timer",
				Content = "Kick in: " .. math.ceil(remainingKickTime) .. "s",
				Duration = 4,
				Image = "timer"
			})
		end
	end
end)
