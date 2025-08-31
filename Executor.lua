-- bootstrap sekali aja, biar script tetep jalan meski teleport
local RAW = "https://raw.githubusercontent.com/xeterguyt/tower-zombie-cheat/main/core.lua"

local qot = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

pcall(function()
    if qot then
        qot('loadstring(game:HttpGet("'..RAW..'"))()')
        print("[BOOT] queued script for next teleport")
    else
        warn("[BOOT] queue_on_teleport not found! Script bisa mati saat teleport")
    end
end)

-- langsung load core
local ok, err = pcall(function() loadstring(game:HttpGet(RAW))() end)
if not ok then
    error("[BOOT] gagal load core: "..tostring(err))
end
