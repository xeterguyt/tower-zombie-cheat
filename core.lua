local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer

-- Put your GitHub RAW link here so script reloads after teleport
queue_on_teleport([[
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xeterguyt/tower-zombie-cheat/refs/heads/main/core"))()
]])

local oldJobId = game.JobId -- current server JobId

-- Function to get a different server
local function findNewServer()
    local placeId = game.PlaceId
    local cursor = ""
    local servers = {}

    repeat
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100&cursor=%s"):format(placeId, cursor)
        local response = HttpService:JSONDecode(game:HttpGet(url))
        for _, s in ipairs(response.data) do
            if s.playing < s.maxPlayers and s.id ~= oldJobId then
                table.insert(servers, s.id)
            end
        end
        cursor = response.nextPageCursor or ""
    until cursor == "" or #servers > 0

    return servers
end

-- Function to teleport to a guaranteed different server
local function joinDifferentServer()
    local placeId = game.PlaceId
    local servers

    repeat
        servers = findNewServer()
        if #servers == 0 then
            task.wait(2) -- retry if no servers found
        end
    until #servers > 0

    local chosen = servers[math.random(1, #servers)]
    TeleportService:TeleportToPlaceInstance(placeId, chosen, player)
end

-- Function to run through checkpoints
local function runCheckpoints()
    local folder = workspace:WaitForChild("CheckpointSpawns")
    for i = 0, 11 do
        local part = folder:FindFirstChild(tostring(i))
        if part then
            player.Character:MoveTo(part.Position)
            task.wait(0.3)
        end
    end
end

-- Main infinite loop
while true do
    task.wait(3) -- short wait before starting
    runCheckpoints()
    joinDifferentServer() -- teleport away
end
