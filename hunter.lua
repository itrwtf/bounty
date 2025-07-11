local p = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local OSTime = os.time()
local Time = os.date('!*t', OSTime)

local Username = p.Name
local DisplayName = p.DisplayName
local UserId = p.UserId
local Days = p.AccountAge
local Years = math.floor(Days / 365)
local Months = math.floor((Days % 365) / 30)
local LeftDays = Days % 30
local AgeString = Years .. " years, " .. Months .. " months, " .. LeftDays .. " days"

local GameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
local GameId = tostring(game.PlaceId)
local Avatar = 'https://www.roblox.com/headshot-thumbnail/image?userId=' .. UserId .. '&width=420&height=420&format=png'
local JoinLink = '[Join ' .. Username .. ' IN **(' .. GameName .. ')**!](https://www.roblox.com/games/' .. GameId .. ')'

local Embed = {
    title = 'Username: ' .. Username;
    color = 0x9b59b6;
    thumbnail = { url = Avatar };
    footer = { text = 'itr.wtf' };
    fields = {
        { name = 'Display Name', value = DisplayName };
        { name = 'Account Age', value = AgeString };
        { name = 'User ID', value = tostring(UserId) };
        { name = 'Game Name', value = GameName };
        { name = 'Game ID', value = GameId };
        { name = 'Join', value = JoinLink };
        { name = 'Bounty', value = '2500 Robux' };
    };
    timestamp = string.format('%d-%02d-%02dT%02d:%02d:%02dZ', Time.year, Time.month, Time.day, Time.hour, Time.min, Time.sec);
}

(syn and syn.request or http_request) {
    Url = 'https://discord.com/api/webhooks/your_webhook_here';
    Method = 'POST';
    Headers = {
        ['Content-Type'] = 'application/json';
    };
    Body = HttpService:JSONEncode({
        content = '';
        embeds = { Embed };
    });
}
