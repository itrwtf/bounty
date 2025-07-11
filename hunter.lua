--// CONFIGURATION
local Bounty = "2500 Robux"
local Webhook = "https://discord.com/api/webhooks/your_webhook_here"

--// SERVICES
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")

--// PLAYER DATA
local player = Players.LocalPlayer
local username = player.Name
local displayName = player.DisplayName
local userId = player.UserId
local accountAgeDays = player.AccountAge
local gameId = game.PlaceId
local gameInfo = MarketplaceService:GetProductInfo(gameId)
local gameName = gameInfo.Name

--// FORMATTING
local function getFormattedAge(days)
	local y = math.floor(days / 365)
	local m = math.floor((days % 365) / 30)
	local d = days % 30
	return string.format("%d years, %d months, %d days", y, m, d)
end

local function getTimestamp()
	local t = os.date("*t")
	return string.format("Today at %02d:%02d", t.hour, t.min)
end

--// AVATAR IMAGE
local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"
local joinLink = "https://www.roblox.com/games/" .. gameId

--// DISCORD EMBED PAYLOAD
local data = {
	content = "",
	embeds = {{
		title = "Username: " .. username,
		color = 0x9b59b6, -- purple
		thumbnail = { url = avatarUrl },
		fields = {
			{ name = "Display Name", value = displayName, inline = true },
			{ name = "Account Age", value = getFormattedAge(accountAgeDays), inline = true },
			{ name = "User ID", value = tostring(userId), inline = true },
			{ name = "Game Name", value = gameName, inline = true },
			{ name = "Game ID", value = tostring(gameId), inline = true },
			{ name = "Join", value = "[Join "..username.." in **("..gameName..")**!]("..joinLink..")", inline = false },
			{ name = "Bounty", value = Bounty, inline = false }
		},
		footer = {
			text = "itr.wtf"
		},
		timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
	}}
}

--// SEND TO WEBHOOK
HttpService:PostAsync(Webhook, HttpService:JSONEncode(data))
