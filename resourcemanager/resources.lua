--------------------------------------------------------------------------------------------------------------
--- RESOURCE MANAGER
--------------------------------------------------------------------------------------------------------------
-- CONFIG
local debug = false -- SHOW IN REAL TIME THE SCRIPT START TIME AT THE SERVER START -- (true/false)
local savelog = true -- ENABLES SAVING A RESOURCE INITIALIZATION LOG. (EX.: @resourcemanager/logs/[here]) -- (true/false)


-- SYSTEM VARIABLES (DON'T CHANGE!)
local resource_timers = {}
local resource_db = {}
local total_ms = 0
local total_rscs = 0
local starting = true
local lock = false

-- SCRIPT
function Save()
    local archive = io.open(GetResourcePath(GetCurrentResourceName()).."/logs/settingup_"..os.date("%d.%m.%Y-%H.%M.%S")..".log","a")
    if archive then
        archive:write("-----------------------------------------------------\n[HOUR]: "..os.date("%d/%m/%Y-%H:%M:%S").." \n[TIME ELAPSED]: "..total_ms.." ms ("..(string.format("%.1f",total_ms/1000)).." seconds) \n[TOTAL OF RESOURCES]: "..total_rscs.."\n-----------------------------------------------------\n")
        for name, timer in pairs(resource_db) do
			archive:write("-----------------------------------------------------\n [RESOURCE NAME]: "..name.."\n [START TIMER]: "..timer.." MS\n")
        end
        archive:close()
    else
        print("\n^5[RSC-MNGR] ^7File Path: ^1"..GetResourcePath(GetCurrentResourceName()).."/logs/ ^7 not found!\n^5[RSC-MNGR] ^7Please Create a ^2logs ^7folder in resource ^1"..GetCurrentResourceName().."^7!\n")
    end
end

function Check()
    SetTimeout(2000, function() 
        if not starting and not lock then
            print("\n^5[RSC-MNGR] ^7Server Started. Charging Time: ^2"..total_ms.."^7 ms (^2"..(string.format("%.1f",total_ms/1000)).."^7 seconds)!")
            lock = true
            if savelog then
                Save()
            end
        end
    end)
end

AddEventHandler('onResourceStarting', function(resourceName)
    if (resourceName ~= nil) then
        resource_timers[resourceName] = GetGameTimer()
        if debug then print("^5[RSC-MNGR] ^7Starting..^3["..resourceName.."]^7") end
        starting = true
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (resource_timers[resourceName] ~= nil) then
        local actualy = GetGameTimer()
        local elapsed = (actualy - resource_timers[resourceName])
        if debug then print("^2^5[RSC-MNGR] ^7Started: ^3["..resourceName.."]^7 at "..elapsed.." ms!^7") end 
        total_ms = total_ms + elapsed
        total_rscs = total_rscs + 1
        resource_db[resourceName] = elapsed
        starting = false
        Check()
    end
end)