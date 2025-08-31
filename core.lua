-- core.lua (host this on GitHub raw)
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- GANTI INI jika path raw-mu beda. Jika file ini di repo yg sama, set ke raw link file ini.
local RAW = "https://raw.githubusercontent.com/xeterguyt/tower-zombie-cheat/main/core.lua"

-- helper: cari fungsi queue_on_teleport dari executor
local function get_qot()
    if queue_on_teleport then return queue_on_teleport end
    if syn and syn.queue_on_teleport then return syn.queue_on_teleport end
    if fluxus and fluxus.queue_on_teleport then return fluxus.queue_on_teleport end
    if secure_load and secure_load.queue_on_teleport then return secure_load.queue_on_teleport end
    return nil
end
local qot = get_qot()

-- re-queue sendiri untuk run setelah teleport (penting: lakukan SEBELUM teleport)
pcall(function()
    if qot then
        qot('loadstring(game:HttpGet("'..RAW..'"))()')
        print("[AutoFarm] queued self for next teleport")
    else
        warn("[AutoFarm] queue_on_teleport NOT found on this executor")
    end
end)

print("[AutoFarm] started. JobId:", game.JobId)

local function runCheckpoints()
    local ok, err = pcall(function()
        local folder = workspace:WaitForChild("CheckpointSpawns")
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        for i = 0, 11 do
            local part = folder:FindFirstChild(tostring(i))
            if part and part:IsA("BasePart") then
                hrp.CFrame = part.CFrame
                task.wait(0.3)
            end
        end
    end)
    if not ok then warn("[AutoFarm] runCheckpoints failed:", err) end
end

-- cepat-cepat cari server valid (cek sampai N halaman, return pertama yg valid)
local function findNewServer(maxPages)
    maxPages = maxPages or 3
    local placeId = game.PlaceId
    local cursor = ""
    for page = 1, maxPages do
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s")
            :format(placeId, (cursor ~= "" and "&cursor="..cursor) or "")
        local ok, resp = pcall(function() return game:HttpGet(url) end)
        if not ok or not resp then
            warn("[AutoFarm] HttpGet failed page", page)
            break
        end
        local ok2, data = pcall(function() return HttpService:JSONDecode(resp) end)
        if not ok2 or not data or not data.data then
            warn("[AutoFarm] JSON decode failed page", page)
            break
        end
        for _, s in ipairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                return s.id -- langsung return untuk kecepatan
            end
        end
        cursor = data.nextPageCursor or ""
        if cursor == "" then break end
    end
    return nil
end

local function joinDifferentServer()
    while true do
        local candidate = findNewServer(3) -- cek sampai 3 halaman (cepat)
        if candidate then
            print("[AutoFarm] found new server:", candidate)
            -- re-queue lagi (double-safe) sebelum teleport
            pcall(function()
                if qot then qot('loadstring(game:HttpGet("'..RAW..'"))()') end
            end)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, candidate, player)
            task.wait(10) -- safety; eksekusi akan berhenti karena teleport
            return
        else
            print("[AutoFarm] no server found, retry in 2s")
            task.wait(2)
        end
    end
end

-- loop utama (jalan terus sampai kamu tutup Roblox)
while true do
    runCheckpoints()
    joinDifferentServer()
    task.wait(3)
end
