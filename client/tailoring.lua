----Gets ESX-----
ESX = nil

local PlayerData = {}
local tailorSpawned = false
local tailorNpc
onjobTailoring = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

--Job start blips--
Citizen.CreateThread(function()
         --Tailoring Blip--
        tailoringblip = AddBlipForCoord(Config.mainTailoringBlip)
        SetBlipSprite(tailoringblip, 79)
        SetBlipDisplay(tailoringblip, 2)
        SetBlipScale(tailoringblip, 0.8)
         SetBlipColour(tailoringblip, 5)
        SetBlipAsShortRange(tailoringblip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Tailoring")
        EndTextCommandSetBlipName(tailoringblip)  
end)


--Tailoring Start-------------------------------------------------------------------------------------------------------

local tailorLoop1 = false
local tailorLoop2 = false
local tailorLoop3 = false
local inZoneT1 = false
local inZoneT2 = false
local inZoneT3 = false

--Spawn NPC--
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local pedCoords = GetEntityCoords(PlayerPedId()) 
        local tailorNpcCoords = Config.tailorNpcCoords
        local dst = #(tailorNpcCoords - pedCoords)
            
        if dst < 30 and tailorSpawned == false then
            TriggerEvent('koe_jobs:spawnTailorPed',tailorNpcCoords, Config.tailorHeading)
            tailorSpawned = true
        end
        if dst >= 31  then
            tailorSpawned = false
            DeleteEntity(tailorNpc)
        end
    end
end)


RegisterNetEvent('koe_jobs:spawnTailorPed')
AddEventHandler('koe_jobs:spawnTailorPed',function(coords,heading) 

    local hash = GetHashKey(Config.tailorModel)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do 
        Wait(10)
    end

    tailorNpc = CreatePed(5, hash, coords, heading, false, false)
    FreezeEntityPosition(tailorNpc, true)
    SetEntityInvincible(tailorNpc, true)
    SetBlockingOfNonTemporaryEvents(tailorNpc, true)
    SetModelAsNoLongerNeeded(hash)
    exports['qtarget']:AddEntityZone('tailorNpc', tailorNpc, {
            name="tailorNpc",
            debugPoly=false,
            useZ = true
                }, {
                options = {
                    {
                    event = "koe_jobs:startTailoringjob",
                    icon = "fas fa-id-badge",
                    label = "Start Tailoring",
                    },   
                    {
                        event = "koe_jobs:sellTailoring",
                        icon = "fas fa-id-badge",
                        label = "Sell Goods",
                        }, 
                    {
                    event = "koe_jobs:endTailoring",
                    icon = "fas fa-id-badge",
                    label = "Clock Out",
                    },                                   
                },
                    distance = 2.5
                })
end)

RegisterCommand('starttailor', function(source, args, rawCommand)
    TriggerEvent('koe_jobs:startTailoringjob')
end)

RegisterCommand('stoptailor', function(source, args, rawCommand)
    TriggerEvent('koe_jobs:endTailoring')
end)

RegisterNetEvent('koe_jobs:startTailoringjob')
AddEventHandler('koe_jobs:startTailoringjob',function()
        onjobTailoring = true
        -- exports['okokNotify']:Alert("Tailoring", "Ive added markers to your map for all locations, to get started go third eye the field marked in red", 15000, 'info') 
        lib.notify({
            title = 'Tailoring',
            description = 'Ive added markers to your map for all locations, to get started go third eye the field marked in red',
            type = 'inform',
            duration = 8000,
            position = 'top'
           })

        --Stage 1 Blip
        woolBlip = AddBlipForRadius(Config.woolBlip, 60.0)
        SetBlipSprite(woolBlip,9)
        SetBlipColour(woolBlip,1)
        SetBlipAlpha(woolBlip,95)

        --Stage 2 Blip
        fabricBlip = AddBlipForCoord(Config.fabricBlip)
        SetBlipSprite(fabricBlip, 79)
        SetBlipDisplay(fabricBlip, 2)
        SetBlipScale(fabricBlip, 0.8)
        SetBlipColour(fabricBlip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Fabric")
        EndTextCommandSetBlipName(fabricBlip)  

        --Stage 3 Blip
        clotheBlip = AddBlipForCoord(Config.clotheBlip)
        SetBlipSprite(clotheBlip, 79)
        SetBlipDisplay(clotheBlip, 2)
        SetBlipScale(clotheBlip, 0.8)
        SetBlipColour(clotheBlip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Cloth")
        EndTextCommandSetBlipName(clotheBlip)  

        --Stage 1
        exports.qtarget:AddBoxZone("wool", vector3(2056.76, 4926.19, 41.22), 50.4, 86.0, {
            name="wool",
            heading=315,
            debugPoly=false,
            minZ=39.42,
            maxZ=43.42
            }, {
                options = {
                    {
                        event = "koe_jobs:tailorWool",
                        icon = "fas fa-hand-paper",
                        label = "Collect Wool",
                        canInteract = function()
                            return onjobTailoring == true and tailorLoop1 == false and tailorLoop2 == false and tailorLoop3 == false 
                        end,
                    },
                },
                distance = 3.5
        })

        --Stage 2
        exports.qtarget:AddBoxZone("fabric", vector3(716.6, -961.81, 30.4), 4.6, 7.6, {
            name="fabric",
            heading=0,
            debugPoly=false,
            minZ=27.0,
            maxZ=31.0
            }, {
                options = {
                    {
                        event = "koe_jobs:woolCheck",
                        icon = "fas fa-hand-paper",
                        label = "Get Fabric",
                        canInteract = function()
                            return onjobTailoring == true and tailorLoop1 == false and tailorLoop2 == false and tailorLoop3 == false 
                        end,
                    },
                },
                distance = 3.5
        })

        --Stage 3
        exports.qtarget:AddBoxZone("clothe", vector3(712.75, -970.0, 30.4), 4.6, 7.6, {
            name="clothe",
            heading=270,
            debugPoly=false,
            minZ=27.0,
            maxZ=31.0
            }, {
                options = {
                    {
                        event = "koe_jobs:fabricCheck",
                        icon = "fas fa-hand-paper",
                        label = "Make Cloth",
                        canInteract = function()
                            return onjobTailoring == true and tailorLoop1 == false and tailorLoop2 == false and tailorLoop3 == false 
                        end,
                    },
                },
                distance = 3.5
        })

end)

RegisterNetEvent('koe_jobs:endTailorLoop')
AddEventHandler('koe_jobs:endTailorLoop',function()
    tailorLoop1 = false
    tailorLoop2 = false
    tailorLoop3 = false
end)

RegisterNetEvent('koe_jobs:tailorWool')
AddEventHandler('koe_jobs:tailorWool',function()
    local finished = exports["tgiann-skillbar"]:taskBar(30000)
    if finished then
        local finished2 = exports["tgiann-skillbar"]:taskBar(1100)
        if finished2 then
            local finished3 = exports["tgiann-skillbar"]:taskBar(800)
            if finished3 then
                
                local sphereT1 = lib.zones.sphere({
                    coords = vec3(2054.6, 4935.12, 41.08),
                    radius = 30,
                    debug = false,
                    inside = insideT1,
                    onEnter = onEnterT1,
                    onExit = onExitT1
                })

                tailorLoop1 = true 
                StartTailorLoop1()
                TriggerServerEvent('koe_jobs:giveRating')
            end
        end
    end
end)

function onEnterT1(self)
    inZoneT1 = true
end

function onExitT1(self)
    inZoneT1 = false
    tailorLoop1 = false 
end

function StartTailorLoop1()
    Citizen.CreateThread(function()
        while tailorLoop1 do
            TriggerServerEvent('koe_jobs:getWool')
            Citizen.Wait(Config.LoopTimer1) 
        end
    end)

    Citizen.Wait(Config.LoopRestartTimer)
    lib.notify({
        title = 'Tailoring',
        description = 'You must third eye again to collect more.',
        type = 'inform',
        duration = 8000,
        position = 'top'
    })
    tailorLoop1 = false 
end

RegisterNetEvent('koe_jobs:woolCheck')
AddEventHandler('koe_jobs:woolCheck',function()
    TriggerServerEvent('koe_jobs:woolCount')  
end)

RegisterNetEvent('koe_jobs:fabricCheck')
AddEventHandler('koe_jobs:fabricCheck',function()
    TriggerServerEvent('koe_jobs:fabricCheck')  
end)

RegisterNetEvent('koe_jobs:getFabric')
AddEventHandler('koe_jobs:getFabric',function()
    local finished = exports["tgiann-skillbar"]:taskBar(30000)
    if finished then
        local finished2 = exports["tgiann-skillbar"]:taskBar(1100)
        if finished2 then
        
            local sphereT2 = lib.zones.sphere({
                coords = vec3(716.4, -961.6, 30.4),
                radius = 12,
                debug = false,
                inside = insideT2,
                onEnter = onEnterT2,
                onExit = onExitT2
            })

            tailorLoop2 = true 
            StartTailorLoop2()
            TriggerServerEvent('koe_jobs:giveRating')
        end
    end

end)

function onEnterT2(self)
    inZoneT2 = true
end

function onExitT2(self)
    inZoneT2 = false
    tailorLoop2 = false 
end

function StartTailorLoop2()
    Citizen.CreateThread(function()
        while tailorLoop2 do
            TriggerServerEvent('koe_jobs:getFabric')  
            Citizen.Wait(Config.LoopTimer2) 
        end
    end)

    Citizen.Wait(Config.LoopRestartTimer)
    lib.notify({
        title = 'Tailoring',
        description = 'You must third eye again to collect more.',
        type = 'inform',
        duration = 8000,
        position = 'top'
    })
    tailorLoop2 = false 
end

RegisterNetEvent('koe_jobs:getClothe')
AddEventHandler('koe_jobs:getClothe',function()
    local finished = exports["tgiann-skillbar"]:taskBar(400)
    if finished then
     
        local sphereT3 = lib.zones.sphere({
            coords = vec3(716.4, -961.6, 30.4),
            radius = 12,
            debug = false,
            inside = insideT3,
            onEnter = onEnterT3,
            onExit = onExitT3
        })

        tailorLoop3 = true 
        StartTailorLoop3()
        TriggerServerEvent('koe_jobs:giveRating')
    end
end)

function onEnterT3(self)
    inZoneT3 = true
end

function onExitT3(self)
    inZoneT3 = false
    tailorLoop3 = false 
end

function StartTailorLoop3()
    Citizen.CreateThread(function()
        while tailorLoop3 do
            TriggerServerEvent('koe_jobs:getTailoringRewards')  
            Citizen.Wait(Config.LoopTimer3) 
        end
    end)

    Citizen.Wait(Config.LoopRestartTimer)
    lib.notify({
        title = 'Tailoring',
        description = 'You must third eye again to collect more.',
        type = 'inform',
        duration = 8000,
        position = 'top'
    })
    tailorLoop3 = false 
end

RegisterNetEvent('koe_jobs:sellTailoring')
AddEventHandler('koe_jobs:sellTailoring',function()
    TriggerServerEvent('koe_jobs:sellTailoringRewards')  
end)

RegisterNetEvent('koe_jobs:endTailoring')
AddEventHandler('koe_jobs:endTailoring',function()
    tailorLoop1 = false
    tailorLoop2 = false
    tailorLoop3 = false
    onjobTailoring = false
    RemoveBlip(woolBlip)
    RemoveBlip(fabricBlip)
    RemoveBlip(clotheBlip)
    -- exports['okokNotify']:Alert("Tailoring", "Clocked Out and markers removed", 8000, 'info')  
    lib.notify({
        title = 'Tailoring',
        description = 'Clocked Out and markers removed',
        type = 'inform',
        duration = 8000,
        position = 'top'
       })
end)
      

---Tailoring End------------------------------------------------------------------------------------------------