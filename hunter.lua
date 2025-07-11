-- CONFIG
local webhookURL = "https://discord.com/api/webhooks/1384766141905244201/YI9Zf6Eyxmyo4gN0uxQNmzw4bkRhV2mWidD9GnLXcox9Vto6R4Y-EH_MZ9Vomt50Vg7X"
local bountyAmount = "2500 Robux"
local gameDuration = 300 -- seconds (5 minutes)

-- SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- DATA
local gameActive = false
local endTime = nil
local points = {}
local selectedAction = nil

-- FUNCTIONS
local function sendWebhook(title, description, color)
    local username = LocalPlayer.Name
    local displayName = LocalPlayer.DisplayName
    local userId = LocalPlayer.UserId
    local avatar = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. userId .. "&width=420&height=420&format=png"
    local gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
    local jobId = tostring(game.JobId)
    local joinLink = string.format("[Join Game](https://www.roblox.com/games/%d/%s)", game.PlaceId, jobId)

    local embed = {
        title = title,
        description = description,
        color = color or 0x9b59b6,
        thumbnail = { url = avatar },
        footer = { text = "itr.wtf" },
        fields = {
            { name = "User", value = username },
            { name = "Display Name", value = displayName },
            { name = "User ID", value = tostring(userId) },
            { name = "Game", value = gameName },
            { name = "Join", value = joinLink },
            { name = "Bounty", value = bountyAmount }
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }

    local payload = HttpService:JSONEncode({ content = "", embeds = {embed} })

    (syn and syn.request or http_request)({
        Url = webhookURL,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = payload
    })
end

local function autocomplete(input)
    input = input:lower()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():find(input) or p.DisplayName:lower():find(input) then
            return p
        end
    end
end

-- UI
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "BountyUI"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 50)
MainFrame.Position = UDim2.new(1, -210, 1, -60)
MainFrame.BackgroundTransparency = 0.5
MainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

local ToggleButton = Instance.new("TextButton", MainFrame)
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.Text = "↑"
ToggleButton.Font = Enum.Font.GothamSemibold
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 20
ToggleButton.BackgroundTransparency = 1

local ExpandedFrame = Instance.new("Frame", MainFrame)
ExpandedFrame.Size = UDim2.new(1, 0, 0, 150)
ExpandedFrame.Position = UDim2.new(0, 0, 1, 0)
ExpandedFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
ExpandedFrame.Visible = false
ExpandedFrame.BorderSizePixel = 0
ExpandedFrame.BackgroundTransparency = 0.3

local UICorner2 = Instance.new("UICorner", ExpandedFrame)
UICorner2.CornerRadius = UDim.new(0, 12)

local buttons = {
    {"Start Game", "Start"},
    {"Add Point", "Add"},
    {"Subtract Point", "Subtract"}
}

for i, data in ipairs(buttons) do
    local button = Instance.new("TextButton", ExpandedFrame)
    button.Name = data[2]
    button.Size = UDim2.new(1, -20, 0, 30)
    button.Position = UDim2.new(0, 10, 0, (i - 1) * 40 + 5)
    button.BackgroundColor3 = Color3.fromRGB(80, 60, 120)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = data[1]
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 14
    local corner = Instance.new("UICorner", button)
    corner.CornerRadius = UDim.new(0, 8)
end

local inputFrame = Instance.new("Frame", ScreenGui)
inputFrame.Size = UDim2.new(0, 240, 0, 80)
inputFrame.Position = UDim2.new(0.5, -120, 0.5, -40)
inputFrame.Visible = false
inputFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
local corner = Instance.new("UICorner", inputFrame)
corner.CornerRadius = UDim.new(0, 12)
inputFrame.BackgroundTransparency = 0.3

local inputBox = Instance.new("TextBox", inputFrame)
inputBox.Size = UDim2.new(1, -20, 0, 30)
inputBox.Position = UDim2.new(0, 10, 0, 10)
inputBox.PlaceholderText = "Enter username..."
inputBox.Text = ""
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 14
local corner2 = Instance.new("UICorner", inputBox)
corner2.CornerRadius = UDim.new(0, 8)

local submitBtn = Instance.new("TextButton", inputFrame)
submitBtn.Size = UDim2.new(1, -20, 0, 30)
submitBtn.Position = UDim2.new(0, 10, 0, 45)
submitBtn.Text = "Confirm"
submitBtn.BackgroundColor3 = Color3.fromRGB(90, 70, 150)
submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
submitBtn.Font = Enum.Font.GothamSemibold
submitBtn.TextSize = 14
local corner3 = Instance.new("UICorner", submitBtn)
corner3.CornerRadius = UDim.new(0, 8)

-- Toggle UI
ToggleButton.MouseButton1Click:Connect(function()
    ExpandedFrame.Visible = not ExpandedFrame.Visible
    ToggleButton.Text = ExpandedFrame.Visible and "↓" or "↑"
end)

-- Game Start/End
ExpandedFrame.Start.MouseButton1Click:Connect(function()
    if not gameActive then
        gameActive = true
        endTime = tick() + gameDuration
        ExpandedFrame.Start.Text = "End Game"
        sendWebhook("Game Started!", "The bounty hunt has begun!")
    else
        gameActive = false
        ExpandedFrame.Start.Text = "Start Game"
        sendWebhook("Game Ended!", "The game has been ended manually.")
    end
end)

-- Point Add/Subtract
ExpandedFrame.Add.MouseButton1Click:Connect(function()
    selectedAction = "add"
    inputFrame.Visible = true
end)

ExpandedFrame.Subtract.MouseButton1Click:Connect(function()
    selectedAction = "subtract"
    inputFrame.Visible = true
end)

submitBtn.MouseButton1Click:Connect(function()
    local input = inputBox.Text
    local player = autocomplete(input)
    if player then
        local current = points[player.Name] or 0
        if selectedAction == "add" then
            points[player.Name] = current + 1
        elseif selectedAction == "subtract" then
            points[player.Name] = math.max(0, current - 1)
        end
        sendWebhook("Point Update", player.Name .. " now has **" .. points[player.Name] .. "** points.")
    end
    inputBox.Text = ""
    inputFrame.Visible = false
end)

-- Auto End
game:GetService("RunService").RenderStepped:Connect(function()
    if gameActive and tick() >= endTime then
        gameActive = false
        ExpandedFrame.Start.Text = "Start Game"
        sendWebhook("Game Ended!", "Time's up! No winner declared.")
    end
end)
