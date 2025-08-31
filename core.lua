local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

print("[CORE] aktif di server baru")

-- fungsi jalanin checkpoint 0-11
local function runCheckpoints()
    for i = 0, 11 do
        local checkpoint = workspace:FindFirstChild(tostring(i))
        if checkpoint and checkpoint:IsA("BasePart") then
            print("[CORE] sentuh checkpoint", i)
            LocalPlayer.Character:PivotTo(checkpoint.CFrame + Vector3.new(0,3,0))
            task.wait(1.5) -- waktu delay biar kesentuh
        else
            warn("[CORE] checkpoint", i, "ga ketemu")
        end
    end
end

-- fungsi rejoin kayak Infinite Yield
local function rejoin()
    print("[CORE] Rejoining match baru...")
    TeleportService:Teleport(game.PlaceId, LocalPlayer) 
    -- di multi-place game, ini bakal lempar balik ke lobby → sistem bikin match baru
end

-- MAIN LOOP
task.spawn(function()
    while task.wait(5) do
        runCheckpoints()
        task.wait(2)
        rejoin()
    end
end)
