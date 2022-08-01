----Gets ESX-----
ESX = nil

local PlayerData = {}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)
---------------------------------------------------------------------------------------------------------------------
--Mining Start-------------------------------------------------------------------------------------------------------

local minerSpawned = false
local minerNpc
onjobMining = false
local miningLoop1 = false
local miningLoop2 = false
local miningLoop3 = false
local inZone1 = false
local inZone2 = false
local inZone3 = false

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
end)


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
                    label = "Start Mining"
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


RegisterCommand('startmining', function(source, args, rawCommand)
    TriggerEvent('koe_jobs:startMiningjob')
end)

RegisterCommand('stopmining', function(source, args, rawCommand)
    TriggerEvent('koe_jobs:endMining')
end)

RegisterNetEvent('koe_jobs:startMiningjob')
AddEventHandler('koe_jobs:startMiningjob',function()
        onjobMining = true
        lib.notify({
            title = 'Mining',
            description = 'Ive added markers to your map for all locations, to get started go third eye some rocks down in the quarry',
            type = 'inform',
            duration = 15000,
            position = 'top',
           })
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
                            return onjobMining == true and miningLoop1 == false and miningLoop2 == false and miningLoop3 == false
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
                            return onjobMining == true and miningLoop1 == false and miningLoop2 == false and miningLoop3 == false
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
                            return onjobMining == true and miningLoop1 == false and miningLoop2 == false and miningLoop3 == false
                        end,
                    },
                },
                distance = 3.5
        })

end)

RegisterNetEvent('koe_jobs:endStoneLoop')
AddEventHandler('koe_jobs:endStoneLoop',function()
    miningLoop1 = false
    miningLoop2 = false
    miningLoop3 = false
end)

RegisterNetEvent('koe_jobs:mineRock')
AddEventHandler('koe_jobs:mineRock',function()
    local finished = exports["tgiann-skillbar"]:taskBar(30000)
    if finished then
        local finished2 = exports["tgiann-skillbar"]:taskBar(1100)
        if finished2 then
            local finished3 = exports["tgiann-skillbar"]:taskBar(800)
            if finished3 then

                local sphere = lib.zones.sphere({
                    coords = vec3(2946.04, 2794.96, 40.64),
                    radius = 30,
                    debug = false,
                    inside = inside1,
                    onEnter = onEnter1,
                    onExit = onExit1
                })

                miningLoop1 = true 
                StartMiningLoop1()
            end
        end
    end
end)

function onEnter1(self)
    inZone1 = true
end

function onExit1(self)
    inZone1 = false
    miningLoop1 = false 
end

function StartMiningLoop1()
    Citizen.CreateThread(function()
        while miningLoop1 do
            TriggerServerEvent('koe_jobs:getStone') 
            Citizen.Wait(Config.LoopTimer1) 
        end
    end)

    Citizen.Wait(Config.LoopRestartTimer)
    lib.notify({
        title = 'Mining',
        description = 'You must third eye again to collect more.',
        type = 'inform',
        duration = 8000,
        position = 'top'
    })
    miningLoop1 = false 
end

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

            local sphere2 = lib.zones.sphere({
                coords = vec3(2754.4, 2801.48, 33.96),
                radius = 10,
                debug = false,
                inside = inside2,
                onEnter = onEnter2,
                onExit = onExit2
            })

            miningLoop2 = true 
            StartMiningLoop2()
        end
    end
end)

function onEnter2(self)
    inZone2 = true
end

function onExit2(self)
    inZone2 = false
    miningLoop2 = false 
end

function StartMiningLoop2()
    Citizen.CreateThread(function()
        while miningLoop2 do
            TriggerServerEvent('koe_jobs:getWashed')  
            Citizen.Wait(Config.LoopTimer2) 
        end
    end)

    Citizen.Wait(Config.LoopRestartTimer)
    lib.notify({
        title = 'Mining',
        description = 'You must third eye again to collect more.',
        type = 'inform',
        duration = 8000,
        position = 'top'
    })
    miningLoop2 = false 
end

RegisterNetEvent('koe_jobs:smelt')
AddEventHandler('koe_jobs:smelt',function()
    local finished = exports["tgiann-skillbar"]:taskBar(400)
    if finished then
        local sphere3 = lib.zones.sphere({
            coords = vec3(1109.48, -2007.92, 31.04),
            radius = 15,
            debug = false,
            inside = inside3,
            onEnter = onEnter3,
            onExit = onExit3
        })

        miningLoop3 = true 
        StartMiningLoop3()
    end
end)

function onEnter3(self)
    inZone3 = true
end

function onExit3(self)
    inZone3 = false
    miningLoop3 = false 
end

function StartMiningLoop3()
    Citizen.CreateThread(function()
        while miningLoop3 do
            TriggerServerEvent('koe_jobs:getMiningRewards') 
            Citizen.Wait(Config.LoopTimer3) 
        end
    end)

    Citizen.Wait(Config.LoopRestartTimer)
    lib.notify({
        title = 'Mining',
        description = 'You must third eye again to collect more.',
        type = 'inform',
        duration = 8000,
        position = 'top'
    })
    miningLoop3 = false 
end

RegisterNetEvent('koe_jobs:sellMining')
AddEventHandler('koe_jobs:sellMining',function()
    TriggerServerEvent('koe_jobs:sellMiningRewards')  
end)

RegisterNetEvent('koe_jobs:endMining')
AddEventHandler('koe_jobs:endMining',function()
    miningLoop1 = false 
    miningLoop2 = false 
    miningLoop3 = false 
    onjobMining = false
    RemoveBlip(miningZone)
    RemoveBlip(washBlip)
    RemoveBlip(smeltBlip)
 
    lib.notify({
        title = 'Mining',
        description = 'Clocked Out and markers removed',
        type = 'inform',
        duration = 8000,
        position = 'top',
       })
end)
      

---Mining End------------------------------------------------------------------------------------------------