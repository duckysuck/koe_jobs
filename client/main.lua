----Gets ESX-----
ESX = nil

local PlayerData = {}
local minerSpawned = false
local butcherSpawned = false
local minerNpc
local butcherNpc
onjobMining = false
onjobButcher = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

--Job start blips--
Citizen.CreateThread(function()
         --Mining Blip--
        miningblip = AddBlipForCoord(Config.mainMiningBlip)
        SetBlipSprite(miningblip, 618)
        SetBlipDisplay(miningblip, 2)
        SetBlipScale(miningblip, 0.8)
         SetBlipColour(miningblip, 5)
        SetBlipAsShortRange(miningblip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Mining")
        EndTextCommandSetBlipName(miningblip)  

        --Butcher Blip--
        butcherblip = AddBlipForCoord(Config.mainButcherBlip)
        SetBlipSprite(butcherblip, 536)
        SetBlipDisplay(butcherblip, 2)
        SetBlipScale(butcherblip, 0.8)
        SetBlipColour(butcherblip, 5)
        SetBlipAsShortRange(butcherblip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Butcher")
        EndTextCommandSetBlipName(butcherblip)
end)


--Mining Start-------------------------------------------------------------------------------------------------------

--Spawn NPC--
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local pedCoords = GetEntityCoords(PlayerPedId()) 
        local minerCoords = Config.minerCoords
        local dst = #(minerCoords - pedCoords)
            
        if dst < 30 and minerSpawned == false then
            TriggerEvent('koe_jobs:spawnMinerPed',minerCoords, Config.minerHeading)
            minerSpawned = true
        end
        if dst >= 31  then
            minerSpawned = false
            DeleteEntity(minerNpc)
        end
    end
end)


RegisterNetEvent('koe_jobs:spawnMinerPed')
AddEventHandler('koe_jobs:spawnMinerPed',function(coords,heading) 

    local hash = GetHashKey(Config.minerModel)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do 
        Wait(10)
    end

    minerNpc = CreatePed(5, hash, coords, heading, false, false)
    FreezeEntityPosition(minerNpc, true)
    SetEntityInvincible(minerNpc, true)
    SetBlockingOfNonTemporaryEvents(minerNpc, true)
    SetModelAsNoLongerNeeded(hash)
    exports['qtarget']:AddEntityZone('minerNpc', minerNpc, {
            name="minerNpc",
            debugPoly=false,
            useZ = true
                }, {
                options = {
                    {
                    event = "koe_jobs:startMiningjob",
                    icon = "fas fa-id-badge",
                    label = "Start Mining",
                    },   
                    {
                        event = "koe_jobs:sellMining",
                        icon = "fas fa-id-badge",
                        label = "Sell Goods",
                        }, 
                    {
                    event = "koe_jobs:endMining",
                    icon = "fas fa-id-badge",
                    label = "Clock Out",
                    },                                   
                },
                    distance = 2.5
                })
end)

RegisterNetEvent('koe_jobs:startMiningjob')
AddEventHandler('koe_jobs:startMiningjob',function()
        onjobMining = true
        exports['okokNotify']:Alert("Mining", "Ive added markers to your map for all locations, to get started go third eye some rocks down in the quarry", 15000, 'info') 
        --Stone Blip
        miningZone = AddBlipForRadius(Config.minerZoneCoords, 60.0)
        SetBlipSprite(miningZone,9)
        SetBlipColour(miningZone,1)
        SetBlipAlpha(miningZone,95)

        --Wash Blip
        washBlip = AddBlipForCoord(Config.washBlipCoords)
        SetBlipSprite(washBlip, 618)
        SetBlipDisplay(washBlip, 2)
        SetBlipScale(washBlip, 0.8)
        SetBlipColour(washBlip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Wash Stone")
        EndTextCommandSetBlipName(washBlip)  

        --Smelt Blip
        smeltBlip = AddBlipForCoord(Config.smeltBlipCoords)
        SetBlipSprite(smeltBlip, 618)
        SetBlipDisplay(smeltBlip, 2)
        SetBlipScale(smeltBlip, 0.8)
        SetBlipColour(smeltBlip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Smelter Stone")
        EndTextCommandSetBlipName(smeltBlip)  

        --MINE--
        exports.qtarget:AddBoxZone("rock1", vector3(2945.03, 2794.8, 49.21), 59.0, 64.8, {
            name="rock1",
            heading=305,
            debugPoly=false,
            minZ=35.61,
            maxZ=50.61
            }, {
                options = {
                    {
                        event = "koe_jobs:mineRock",
                        icon = "fas fa-hand-paper",
                        label = "Mine",
                        canInteract = function()
                            return onjobMining == true
                        end,
                    },
                },
                distance = 3.5
        })

        --WASH--
        exports.qtarget:AddBoxZone("wash", vector3(2755.38, 2801.91, 33.97), 2.0, 3.4, {
            name="wash",
            heading=300,
            debugPoly=false,
            minZ=31.17,
            maxZ=35.17
            }, {
                options = {
                    {
                        event = "koe_jobs:stoneCheck",
                        icon = "fas fa-hand-paper",
                        label = "Wash Stone",
                        canInteract = function()
                            return onjobMining == true
                        end,
                    },
                },
                distance = 3.5
        })

        --SMELT--
        exports.qtarget:AddBoxZone("smelt", vector3(1111.84, -2009.66, 30.94), 4.4, 4.4, {
            name="smelt",
            heading=235,
            debugPoly=false,
            minZ=28.14,
            maxZ=33.34
            }, {
                options = {
                    {
                        event = "koe_jobs:washCheck",
                        icon = "fas fa-hand-paper",
                        label = "Smelt Stone",
                        canInteract = function()
                            return onjobMining == true
                        end,
                    },
                },
                distance = 3.5
        })

end)

RegisterNetEvent('koe_jobs:mineRock')
AddEventHandler('koe_jobs:mineRock',function()
    local finished = exports["tgiann-skillbar"]:taskBar(30000)
    if finished then
        local finished2 = exports["tgiann-skillbar"]:taskBar(1100)
        if finished2 then
            local finished3 = exports["tgiann-skillbar"]:taskBar(800)
            if finished3 then
                local finished4 = exports["tgiann-skillbar"]:taskBar(600)
                if finished4 then
                    local finished5 = exports["tgiann-skillbar"]:taskBar(400)
                    if finished5 then  
                        TriggerServerEvent('koe_jobs:getStone')                       
                    end
                end
            end
        end
    end

end)

RegisterNetEvent('koe_jobs:stoneCheck')
AddEventHandler('koe_jobs:stoneCheck',function()
    TriggerServerEvent('koe_jobs:stoneCount')  
end)

RegisterNetEvent('koe_jobs:washCheck')
AddEventHandler('koe_jobs:washCheck',function()
    TriggerServerEvent('koe_jobs:washedstoneCount')  
end)

RegisterNetEvent('koe_jobs:washStone')
AddEventHandler('koe_jobs:washStone',function()
    local finished = exports["tgiann-skillbar"]:taskBar(30000)
    if finished then
        local finished2 = exports["tgiann-skillbar"]:taskBar(1100)
        if finished2 then
            local finished3 = exports["tgiann-skillbar"]:taskBar(800)
            if finished3 then
                local finished4 = exports["tgiann-skillbar"]:taskBar(600)
                if finished4 then
                    local finished5 = exports["tgiann-skillbar"]:taskBar(400)
                    if finished5 then     
                        TriggerServerEvent('koe_jobs:getWashed')                       
                    end
                end
            end
        end
    end

end)

RegisterNetEvent('koe_jobs:smelt')
AddEventHandler('koe_jobs:smelt',function()
    local finished = exports["tgiann-skillbar"]:taskBar(30000)
    if finished then
        local finished2 = exports["tgiann-skillbar"]:taskBar(1100)
        if finished2 then
            local finished3 = exports["tgiann-skillbar"]:taskBar(800)
            if finished3 then
                local finished4 = exports["tgiann-skillbar"]:taskBar(600)
                if finished4 then
                    local finished5 = exports["tgiann-skillbar"]:taskBar(400)
                    if finished5 then     
                        TriggerServerEvent('koe_jobs:getMiningRewards')                       
                    end
                end
            end
        end
    end

end)

RegisterNetEvent('koe_jobs:sellMining')
AddEventHandler('koe_jobs:sellMining',function()
    TriggerServerEvent('koe_jobs:sellMiningRewards')  
end)

RegisterNetEvent('koe_jobs:endMining')
AddEventHandler('koe_jobs:endMining',function()
    onjobMining = false
    RemoveBlip(miningZone)
    RemoveBlip(washBlip)
    RemoveBlip(smeltBlip)
    exports['okokNotify']:Alert("Mining", "Clocked Out and markers removed", 8000, 'info')  
end)
      

---Mining End------------------------------------------------------------------------------------------------

--BUTCHER Start-------------------------------------------------------------------------------------------------------

--Spawn Start NPC--
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
            local pedCoords = GetEntityCoords(PlayerPedId()) 
            local butcherCoords = Config.butcherCoords
            local dst = #(butcherCoords - pedCoords)
            
            if dst < 30 and butcherSpawned == false then
                TriggerEvent('koe_jobs:spawnbutcherPed',butcherCoords, Config.butcherHeading)
                butcherSpawned = true
            end
            if dst >= 31  then
                butcherSpawned = false
                DeleteEntity(butcherNpc)
            end
    end
end)


RegisterNetEvent('koe_jobs:spawnbutcherPed')
AddEventHandler('koe_jobs:spawnbutcherPed',function(coords,heading) 

    local hash = GetHashKey(Config.butcherModel)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do 
        Wait(10)
    end

    butcherNpc = CreatePed(5, hash, coords, heading, false, false)
    FreezeEntityPosition(butcherNpc, true)
    SetEntityInvincible(butcherNpc, true)
    SetBlockingOfNonTemporaryEvents(butcherNpc, true)
    SetModelAsNoLongerNeeded(hash)
    exports['qtarget']:AddEntityZone('butcherNpc', butcherNpc, {
            name="butcherNpc",
            debugPoly=false,
            useZ = true
                }, {
                options = {
                    {
                    event = "koe_jobs:startButcherjob",
                    icon = "fas fa-id-badge",
                    label = "Start Butcher Job",
                    },   
                    {
                        event = "koe_jobs:sellButcher",
                        icon = "fas fa-id-badge",
                        label = "Sell Goods",
                        }, 
                    {
                    event = "koe_jobs:endButcher",
                    icon = "fas fa-id-badge",
                    label = "Clock Out",
                    },                                   
                },
                    distance = 2.5
                })
end)

RegisterNetEvent('koe_jobs:startButcherjob')
AddEventHandler('koe_jobs:startButcherjob',function()
        onjobButcher = true
        exports['okokNotify']:Alert("Butcher", "Ive added markers to your map for all locations. To get started go third eye the chicken cage down the hall on the left", 15000, 'info') 
        --Chicken Blip
        chickenBlip = AddBlipForCoord(Config.aliveChickenBlip)
        SetBlipSprite(chickenBlip, 536)
        SetBlipDisplay(chickenBlip, 2)
        SetBlipScale(chickenBlip, 0.8)
        SetBlipColour(chickenBlip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Grab Chickens")
        EndTextCommandSetBlipName(chickenBlip)  

        --Kill Blip
        killBlip = AddBlipForCoord(Config.killChickenBlip)
        SetBlipSprite(killBlip, 536)
        SetBlipDisplay(killBlip, 2)
        SetBlipScale(killBlip, 0.8)
        SetBlipColour(killBlip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Kill Chickens")
        EndTextCommandSetBlipName(killBlip)  

        --Package Blip
        packageBlip = AddBlipForCoord(Config.packageChickenBli)
        SetBlipSprite(packageBlip, 536)
        SetBlipDisplay(packageBlip, 2)
        SetBlipScale(packageBlip, 0.8)
        SetBlipColour(packageBlip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Package Chickens")
        EndTextCommandSetBlipName(packageBlip)  

        --Chickens--
        exports.qtarget:AddBoxZone("chickens", vector3(-62.52, 6244.12, 31.08), 2.8, 12.6, {
            name="chickens",
            heading=302,
            debugPoly=false,
            }, {
                options = {
                    {
                        event = "koe_jobs:grabChickens",
                        icon = "fas fa-hand-paper",
                        label = "Grab Chickens",
                        canInteract = function()
                            return onjobButcher == true
                        end,
                    },
                },
                distance = 3.5
        })

        --kill--
        exports.qtarget:AddBoxZone("kill", vector3(-79.62, 6228.66, 31.09), 3, 4, {
            name="kill",
            heading=300,
            debugPoly=false,
            minZ=30.09,
            maxZ=34.09
            }, {
                options = {
                    {
                        event = "koe_jobs:chickenCheck",
                        icon = "fas fa-hand-paper",
                        label = "Kill Chickens",
                        canInteract = function()
                            return onjobButcher == true
                        end,
                    },
                },
                distance = 3.5
        })

        --SMELT--
        exports.qtarget:AddBoxZone("package", vector3(-102.09, 6210.07, 31.03), 3.6, 18.6, {
            name="package",
            heading=226,
            debugPoly=false,
            minZ=30.03,
            maxZ=34.03
            }, {
                options = {
                    {
                        event = "koe_jobs:deadCheck",
                        icon = "fas fa-hand-paper",
                        label = "Package Chickens",
                        canInteract = function()
                            return onjobButcher == true
                        end,
                    },
                },
                distance = 3.5
        })

end)

RegisterNetEvent('koe_jobs:grabChickens')
AddEventHandler('koe_jobs:grabChickens',function()
    local finished = exports["tgiann-skillbar"]:taskBar(30000)
    if finished then
        local finished2 = exports["tgiann-skillbar"]:taskBar(1100)
        if finished2 then
            local finished3 = exports["tgiann-skillbar"]:taskBar(800)
            if finished3 then
                local finished4 = exports["tgiann-skillbar"]:taskBar(600)
                if finished4 then
                    local finished5 = exports["tgiann-skillbar"]:taskBar(400)
                    if finished5 then  
                        TriggerServerEvent('koe_jobs:getChickens')                       
                    end
                end
            end
        end
    end

end)

RegisterNetEvent('koe_jobs:chickenCheck')
AddEventHandler('koe_jobs:chickenCheck',function()
    TriggerServerEvent('koe_jobs:chickenCount')  
end)

RegisterNetEvent('koe_jobs:deadCheck')
AddEventHandler('koe_jobs:deadCheck',function()
    TriggerServerEvent('koe_jobs:killedCount')  
end)

RegisterNetEvent('koe_jobs:killEmAll')
AddEventHandler('koe_jobs:killEmAll',function()
    local finished = exports["tgiann-skillbar"]:taskBar(30000)
    if finished then
        local finished2 = exports["tgiann-skillbar"]:taskBar(1100)
        if finished2 then
            local finished3 = exports["tgiann-skillbar"]:taskBar(800)
            if finished3 then
                local finished4 = exports["tgiann-skillbar"]:taskBar(600)
                if finished4 then
                    local finished5 = exports["tgiann-skillbar"]:taskBar(400)
                    if finished5 then     
                        TriggerServerEvent('koe_jobs:getKilled')                       
                    end
                end
            end
        end
    end

end)

RegisterNetEvent('koe_jobs:PackageEmUp')
AddEventHandler('koe_jobs:PackageEmUp',function()
    local finished = exports["tgiann-skillbar"]:taskBar(30000)
    if finished then
        local finished2 = exports["tgiann-skillbar"]:taskBar(1100)
        if finished2 then
            local finished3 = exports["tgiann-skillbar"]:taskBar(800)
            if finished3 then
                local finished4 = exports["tgiann-skillbar"]:taskBar(600)
                if finished4 then
                    local finished5 = exports["tgiann-skillbar"]:taskBar(400)
                    if finished5 then     
                        TriggerServerEvent('koe_jobs:getButcherRewards')                       
                    end
                end
            end
        end
    end

end)

RegisterNetEvent('koe_jobs:sellButcher')
AddEventHandler('koe_jobs:sellButcher',function()
    TriggerServerEvent('koe_jobs:sellButcherRewards')  
end)

RegisterNetEvent('koe_jobs:endButcher')
AddEventHandler('koe_jobs:endButcher',function()
    onjobButcher = false
    RemoveBlip(chickenBlip)
    RemoveBlip(killBlip)
    RemoveBlip(packageBlip)
    exports['okokNotify']:Alert("Butcher", "Clocked Out and markers removed", 8000, 'info')  
end)
      

---Butcher End------------------------------------------------------------------------------------------------