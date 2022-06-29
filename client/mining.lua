----Gets ESX-----
ESX = nil

local PlayerData = {}
local minerSpawned = false
local minerNpc
onjobMining = false

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

--MINE TARGET--
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
                label = "Mine"
            },
        },
        distance = 3.5
})

--WASH TARGET--
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
                label = "Wash Stone"
            },
        },
        distance = 3.5
})

--SMELT TARGET--
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
                label = "Smelt Stone"
            },
        },
        distance = 3.5
})


RegisterNetEvent('koe_jobs:spawnMinerPed')
AddEventHandler('koe_jobs:spawnMinerPed',function(coords,heading, xp, level) 
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

    TriggerServerEvent('koe_jobs:getCurrentXp', source)
end)

RegisterNetEvent('koe_jobs:miningTarget')
AddEventHandler('koe_jobs:miningTarget',function(xp, level) 
    if minerSpawned then
        exports['qtarget']:AddEntityZone('minerNpc', minerNpc, {
            name="minerNpc",
            debugPoly=false,
            useZ = true
                }, {
                options = {
                    {
                    event = "koe_jobs:playerinformation",
                    label = 'Player Information',
                    icon = "fas fa-id-badge",
                    xp = xp,
                    level = level
                    },
                    {
                    event = "koe_jobs:startMiningjob",
                    icon = "fas fa-id-badge",
                    label = "Start Mining",
                    xp = xp,
                    level = level
                    },   
                    {
                    event = "koe_jobs:sellMining",
                    icon = "fas fa-id-badge",
                    label = "Sell Goods",
                    xp = xp,
                    level = level
                    }, 
                    {
                    event = "koe_jobs:endMining",
                    icon = "fas fa-id-badge",
                    label = "Clock Out",
                    xp = xp,
                    level = level
                    },                                   
                },
                    distance = 2.5
                })
    end
end)

RegisterNetEvent('koe_jobs:playerinformation')
AddEventHandler('koe_jobs:playerinformation',function(data) 
        lib.registerContext({
            id = 'playerinfo',
            title = 'Experience and Level',
            onExit = function()
                TriggerServerEvent('koe_jobs:getCurrentXp', source)
            end,
            options = {
                {title = 'Player Information'},
                {
                    title = 'Current Level: '..data.level,
                },
                {
                    title = 'Current XP: '..data.xp,
                }
            },
        })
        lib.showContext('playerinfo')
end)

RegisterNetEvent('koe_jobs:startMiningjob')
AddEventHandler('koe_jobs:startMiningjob',function(data)
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

end)

RegisterNetEvent('koe_jobs:mineRock')
AddEventHandler('koe_jobs:mineRock',function()
    TriggerServerEvent('koe_jobs:getCurrentXp', source)
    local finished = exports["tgiann-skillbar"]:taskBar(30000)
    if finished then
        local finished2 = exports["tgiann-skillbar"]:taskBar(1100)
        if finished2 then
            local finished3 = exports["tgiann-skillbar"]:taskBar(800)
            if finished3 then
                TriggerEvent('koe_jobs:mineRock')
                TriggerServerEvent('koe_jobs:getStone')  
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
    TriggerServerEvent('koe_jobs:getCurrentXp', source)
    local finished = exports["tgiann-skillbar"]:taskBar(30000)
    if finished then
        local finished2 = exports["tgiann-skillbar"]:taskBar(1100)
        if finished2 then
            TriggerEvent('koe_jobs:washStone')
            TriggerServerEvent('koe_jobs:getWashed')  
        end
    end

end)

RegisterNetEvent('koe_jobs:smelt')
AddEventHandler('koe_jobs:smelt',function()
    TriggerServerEvent('koe_jobs:getCurrentXp', source)
    local finished = exports["tgiann-skillbar"]:taskBar(400)
    if finished then
        TriggerEvent('koe_jobs:smelt')
        TriggerServerEvent('koe_jobs:getMiningRewards')   
    end
end)

RegisterNetEvent('koe_jobs:sellMining')
AddEventHandler('koe_jobs:sellMining',function()
    TriggerServerEvent('koe_jobs:getCurrentXp', source)
    TriggerServerEvent('koe_jobs:sellMiningRewards')  
end)

RegisterNetEvent('koe_jobs:endMining')
AddEventHandler('koe_jobs:endMining',function()
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