local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

-- CONFIG --
local Webhook = "https://discord.com/api/webhooks/your_webhook_here"
local Bounty = "2500 Robux"

-- Player and Game Info
local player = Players.LocalPlayer
local JobId = tostring(game.JobId)
local GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
local PlaceId = tostring(game.PlaceId)

-- Internal State
local cooldown = false
local afk = false
local afkStartTime = 0
local afkCooldown = false

-- For tracking player position to detect AFK
local lastPosition = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position or nil
local lastMoveTime = os.clock()

-- Helper: Format account age
local function formatAccountAge(days)
	local y = math.floor(days / 365)
	local m = math.floor((days % 365) / 30)
	local d = days % 30
	return string.format("%d years, %d months, %d days", y, m, d)
end

-- Helper: Send webhook embed
local function sendEmbed(embedData)
	if not (syn and syn.request or http_request) then return end
	(syn and syn.request or http_request)({
		Url = Webhook,
		Method = "POST",
		Headers = {["Content-Type"] = "application/json"},
		Body = HttpService:JSONEncode({content = "", embeds = {embedData}})
	})
end

-- Build embed for player info (normal purple embed)
local function buildPlayerEmbed()
	local Time = os.date('!*t', os.time())
	local Username = player.Name
	local DisplayName = player.DisplayName
	local UserId = player.UserId
	local AgeString = formatAccountAge(player.AccountAge)
	local Avatar = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. UserId .. "&width=420&height=420&format=png"

	local titleExtra = ""
	if Username == "3gtl" then
		titleExtra = " 👑 OWNER"
	elseif Username == "6r5lo" then
		titleExtra = " ✅ VERIFIED"
	end

	return {
		title = "Username: " .. Username .. titleExtra,
		color = 0x9b59b6, -- purple
		thumbnail = {url = Avatar},
		footer = {text = "itr.wtf"},
		fields = {
			{name = "Display Name", value = DisplayName},
			{name = "Account Age", value = AgeString},
			{name = "User ID", value = tostring(UserId)},
			{name = "Game Name", value = GameName},
			{name = "Job ID", value = JobId},
			{name = "Join", value = "[Join " .. Username .. " IN **(" .. GameName .. ")**!](https://www.roblox.com/games/" .. PlaceId .. "/" .. JobId .. ")"},
			{name = "Bounty", value = Bounty},
		},
		timestamp = string.format("%d-%02d-%02dT%02d:%02d:%02dZ", Time.year, Time.month, Time.day, Time.hour, Time.min, Time.sec)
	}
end

-- Build leave embed (simple)
local function buildLeaveEmbed()
	local Time = os.date('!*t', os.time())
	local Username = player.Name
	return {
		title = Username .. " has left the game",
		color = 0xff0000, -- red
		footer = {text = "itr.wtf"},
		timestamp = string.format("%d-%02d-%02dT%02d:%02d:%02dZ", Time.year, Time.month, Time.day, Time.hour, Time.min, Time.sec)
	}
end

-- Build AFK embed (yellow, moon emoji)
local function buildAfkEmbed()
	local Time = os.date('!*t', os.time())
	local Username = player.Name
	return {
		title = "🌙 " .. Username .. " is AFK! Bounty has been disabled.",
		color = 0xFFD700, -- gold/yellow
		footer = {text = "itr.wtf"},
		timestamp = string.format("%d-%02d-%02dT%02d:%02d:%02dZ", Time.year, Time.month, Time.day, Time.hour, Time.min, Time.sec)
	}
end

-- Build back embed (green dot)
local function buildBackEmbed(countdownSeconds)
	local Time = os.date('!*t', os.time())
	local Username = player.Name
	return {
		title = "🟢 " .. Username .. " is back! Bounty will turn on in: " .. countdownSeconds .. " seconds",
		color = 0x00FF00, -- green
		footer = {text = "itr.wtf"},
		timestamp = string.format("%d-%02d-%02dT%02d:%02d:%02dZ", Time.year, Time.month, Time.day, Time.hour, Time.min, Time.sec)
	}
end

-- Send main player embed with cooldown
local function sendPlayerInfo()
	if cooldown then return end
	cooldown = true
	sendEmbed(buildPlayerEmbed())
	task.spawn(function()
		wait(60)
		cooldown = false
	end)
end

sendPlayerInfo()

-- Listen for player leaving to send leave log
Players.PlayerRemoving:Connect(function(plr)
	if plr == player then
		sendEmbed(buildLeaveEmbed())
	end
end)

-- AFK detection loop
RunService.Heartbeat:Connect(function()
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local currentPos = hrp.Position

	if (lastPosition == nil) then
		lastPosition = currentPos
		lastMoveTime = os.clock()
		return
	end

	if (currentPos - lastPosition).magnitude > 0.1 then
		lastPosition = currentPos
		lastMoveTime = os.clock()

		if afk then
			-- Player just moved back from AFK
			afk = false
			if afkCooldown then return end
			afkCooldown = true
			local countdown = 30

			-- Start countdown coroutine
			task.spawn(function()
				while countdown > 0 do
					sendEmbed(buildBackEmbed(countdown))
					wait(1)
					countdown = countdown - 1
				end
				afkCooldown = false
				sendPlayerInfo()
			end)
		end
	else
		-- Check if 5 minutes passed without movement
		if not afk and (os.clock() - lastMoveTime) >= 300 then -- 300s = 5min
			afk = true
			sendEmbed(buildAfkEmbed())
		end
	end
end)
