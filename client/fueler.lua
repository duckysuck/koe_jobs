----Gets ESX-----
ESX = nil

local PlayerData = {}
local fuelerSpawned = false
local fuelerNpc
onjobfueler = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

--Job start blips--
Citizen.CreateThread(function()
        --fueler Blip--
        fuelerblip = AddBlipForCoord(Config.mainfuelerBlip)
        SetBlipSprite(fuelerblip, 88)
        SetBlipDisplay(fuelerblip, 2)
        SetBlipScale(fuelerblip, 0.8)
        SetBlipColour(fuelerblip, 5)
        SetBlipAsShortRange(fuelerblip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Fueler")
        EndTextCommandSetBlipName(fuelerblip)
end)

--fueler Start-------------------------------------------------------------------------------------------------------

local fuelerLoop1 = false
local fuelerLoop2 = false
local fuelerLoop3 = false
local inZoneF1 = false
local inZoneF2 = false
local inZoneF3 = false

--Spawn Start NPC--
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
            local pedCoords = GetEntityCoords(PlayerPedId()) 
            local fuelerCoords = Config.fuelerCoords
            local dst = #(fuelerCoords - pedCoords)
            
            if dst < 30 and fuelerSpawned == false then
                TriggerEvent('koe_jobs:spawnfuelerPed',fuelerCoords, Config.fuelerHeading)
                fuelerSpawned = true
            end
            if dst >= 31  then
                fuelerSpawned = false
                DeleteEntity(fuelerNpc)
            end
    end
end)


RegisterNetEvent('koe_jobs:spawnfuelerPed')
AddEventHandler('koe_jobs:spawnfuelerPed',function(coords,heading) 

    local hash = GetHashKey(Config.fuelerModel)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do 
        Wait(10)
    end

    fuelerNpc = CreatePed(5, hash, coords, heading, false, false)
    FreezeEntityPosition(fuelerNpc, true)
    SetEntityInvincible(fuelerNpc, true)
    SetBlockingOfNonTemporaryEvents(fuelerNpc, true)
    SetModelAsNoLongerNeeded(hash)
    exports['qtarget']:AddEntityZone('fuelerNpc', fuelerNpc, {
            name="fuelerNpc",
            debugPoly=false,
            useZ = true
                }, {
                options = {
                    {
                    event = "koe_jobs:startFuelerjob",
                    icon = "fas fa-id-badge",
                    label = "Start Fueler Job",
                    },   
                    {
                        event = "koe_jobs:sellFueler",
                        icon = "fas fa-id-badge",
                        label = "Sell Goods",
                        }, 
                    {
                    event = "koe_jobs:endFueler",
                    icon = "fas fa-id-badge",
                    label = "Clock Out",
                    },                                   
                },
                    distance = 2.5
                })
end)

RegisterCommand('startfueler', function(source, args, rawCommand)
    TriggerEvent('koe_jobs:startFuelerjob')
end)

RegisterCommand('stopfueler', function(source, args, rawCommand)
    TriggerEvent('koe_jobs:endFueler')
end)

RegisterNetEvent('koe_jobs:startFuelerjob')
AddEventHandler('koe_jobs:startFuelerjob',function()
        onjobfueler = true
        -- exports['okokNotify']:Alert("Fueler", "Ive added markers to your map for all locations. To get started head above 4020 to the blip marked on your GPS to grab oil", 15000, 'info') 
        lib.notify({
            title = 'Fueler',
            description = 'Ive added markers to your map for all locations. To get started head above 4020 to the blip marked on your GPS to grab oil',
            type = 'inform',
            duration = 8000,
            position = 'top'
           })
        --Oil Blip
        petrolBlip = AddBlipForCoord(Config.petrolBlip)
        SetBlipSprite(petrolBlip, 88)
        SetBlipDisplay(petrolBlip, 2)
        SetBlipScale(petrolBlip, 0.8)
        SetBlipColour(petrolBlip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Grab Oil")
        EndTextCommandSetBlipName(petrolBlip)  

        --Refine Blip
        raffinBlip = AddBlipForCoord(Config.raffinBlip)
        SetBlipSprite(raffinBlip, 88)
        SetBlipDisplay(raffinBlip, 2)
        SetBlipScale(raffinBlip, 0.8)
        SetBlipColour(raffinBlip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Refine Oil")
        EndTextCommandSetBlipName(raffinBlip)  

        --Gas Blip
        essenceBlip = AddBlipForCoord(Config.essenceBlip)
        SetBlipSprite(essenceBlip, 88)
        SetBlipDisplay(essenceBlip, 2)
        SetBlipScale(essenceBlip, 0.8)
        SetBlipColour(essenceBlip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Make Gas")
        EndTextCommandSetBlipName(essenceBlip)  

        --Oil--
        exports.qtarget:AddBoxZone("oil", vector3(610.54, 2856.45, 39.99), 12.4, 5.6, {
            name="oil",
            heading=250,
            debugPoly=false,
            minZ=38.99,
            maxZ=42.99
            }, {
                options = {
                    {
                        event = "koe_jobs:grabOil",
                        icon = "fas fa-hand-paper",
                        label = "Get Oil",
                        canInteract = function()
                            return onjobfueler == true and fuelerLoop1 == false and fuelerLoop2 == false and fuelerLoop3 == false
                        end,
                    },
                },
                distance = 3.5
        })

        --Refine--
        exports.qtarget:AddBoxZone("refine", vector3(2775.42, 1495.66, 24.49), 12.4, 11.4, {
            name="refine",
            heading=345,
            debugPoly=false,
            minZ=23.49,
            maxZ=27.49
            }, {
                options = {
                    {
                        event = "koe_jobs:oilCheck",
                        icon = "fas fa-hand-paper",
                        label = "Refine Oil",
                        canInteract = function()
                            return onjobfueler == true and fuelerLoop1 == false and fuelerLoop2 == false and fuelerLoop3 == false
                        end,
                    },
                },
                distance = 3.5
        })

        --Gas--
        exports.qtarget:AddBoxZone("gas", vector3(2772.83, 1531.36, 30.79), 21.6, 6.0, {
            name="gas",
            heading=345,
            debugPoly=false,
            minZ=29.79,
            maxZ=33.79
            }, {
                options = {
                    {
                        event = "koe_jobs:refineCheck",
                        icon = "fas fa-hand-paper",
                        label = "Make Gas",
                        canInteract = function()
                            return onjobfueler == true and fuelerLoop1 == false and fuelerLoop2 == false and fuelerLoop3 == false
                        end,
                    },
                },
                distance = 3.5
        })

end)

RegisterNetEvent('koe_jobs:endFuelerLoop')
AddEventHandler('koe_jobs:endFuelerLoop',function()
    fuelerLoop1 = false
    fuelerLoop2 = false
    fuelerLoop3 = false
end)

RegisterNetEvent('koe_jobs:grabOil')
AddEventHandler('koe_jobs:grabOil',function()
    local finished = exports["tgiann-skillbar"]:taskBar(30000)
    if finished then
        local finished2 = exports["tgiann-skillbar"]:taskBar(1100)
        if finished2 then
            local finished3 = exports["tgiann-skillbar"]:taskBar(800)
            if finished3 then
        
                local sphereF1 = lib.zones.sphere({
                    coords = vec3(604.32, 2858.64, 40.0),
                    radius = 20,
                    debug = false,
                    inside = insideF1,
                    onEnter = onEnterF1,
                    onExit = onExitF1
                })

                fuelerLoop1 = true 
                StartFuelerLoop1()
            end
        end
    end

end)

function onEnterF1(self)
    inZoneF1 = true
end

function onExitF1(self)
    inZoneF1 = false
    fuelerLoop1 = false 
end

function StartFuelerLoop1()
    Citizen.CreateThread(function()
        while fuelerLoop1 do
            TriggerServerEvent('koe_jobs:getOil')
            Citizen.Wait(Config.LoopTimer) 
        end
    end)

    Citizen.Wait(Config.LoopRestartTimer)
    lib.notify({
        title = 'Fueler',
        description = 'You must third eye again to collect more.',
        type = 'inform',
        duration = 8000,
        position = 'top'
    })
    fuelerLoop1 = false 
end

RegisterNetEvent('koe_jobs:oilCheck')
AddEventHandler('koe_jobs:oilCheck',function()
    TriggerServerEvent('koe_jobs:oilCount')  
end)

RegisterNetEvent('koe_jobs:refineCheck')
AddEventHandler('koe_jobs:refineCheck',function()
    TriggerServerEvent('koe_jobs:refinedCount')  
end)

RegisterNetEvent('koe_jobs:grabRefined')
AddEventHandler('koe_jobs:grabRefined',function()
    local finished = exports["tgiann-skillbar"]:taskBar(30000)
    if finished then
        local finished2 = exports["tgiann-skillbar"]:taskBar(1100)
        if finished2 then
            
            local sphereF2 = lib.zones.sphere({
                coords = vec3(2776.04, 1495.48, 24.52),
                radius = 15,
                debug = false,
                inside = insideF2,
                onEnter = onEnterF2,
                onExit = onExitF2
            })

            fuelerLoop2 = true 
            StartFuelerLoop2()
        end
    end

end)

function onEnterF2(self)
    inZoneF2 = true
end

function onExitF2(self)
    inZoneF2 = false
    fuelerLoop2 = false 
end

function StartFuelerLoop2()
    Citizen.CreateThread(function()
        while fuelerLoop2 do
            TriggerServerEvent('koe_jobs:getRefined')
            Citizen.Wait(Config.LoopTimer) 
        end
    end)

    Citizen.Wait(Config.LoopRestartTimer)
    lib.notify({
        title = 'Fueler',
        description = 'You must third eye again to collect more.',
        type = 'inform',
        duration = 8000,
        position = 'top'
    })
    fuelerLoop2 = false 
end

RegisterNetEvent('koe_jobs:grabGas')
AddEventHandler('koe_jobs:grabGas',function()
    local finished = exports["tgiann-skillbar"]:taskBar(400)
    if finished then
    
        local sphereF3 = lib.zones.sphere({
            coords = vec3(2769.96, 1520.96, 30.8),
            radius = 10,
            debug = false,
            inside = insideF3,
            onEnter = onEnterF3,
            onExit = onExitF3
        })

        fuelerLoop3 = true 
        StartFuelerLoop3()
    end

end)

function onEnterF3(self)
    inZoneF3 = true
end

function onExitF3(self)
    inZoneF3 = false
    fuelerLoop3 = false 
end

function StartFuelerLoop3()
    Citizen.CreateThread(function()
        while fuelerLoop3 do
            TriggerServerEvent('koe_jobs:getFuelerRewards') 
            Citizen.Wait(Config.LoopTimer) 
        end
    end)

    Citizen.Wait(Config.LoopRestartTimer)
    lib.notify({
        title = 'Fueler',
        description = 'You must third eye again to collect more.',
        type = 'inform',
        duration = 8000,
        position = 'top'
    })
    fuelerLoop3 = false 
end

RegisterNetEvent('koe_jobs:sellFueler')
AddEventHandler('koe_jobs:sellFueler',function()
    TriggerServerEvent('koe_jobs:sellFuelerRewards')  
end)

RegisterNetEvent('koe_jobs:endFueler')
AddEventHandler('koe_jobs:endFueler',function()
    fuelerLoop1 = false 
    fuelerLoop2 = false 
    fuelerLoop3 = false 
    onjobfueler = false
    RemoveBlip(petrolBlip)
    RemoveBlip(raffinBlip)
    RemoveBlip(essenceBlip)
    -- exports['okokNotify']:Alert("Fueler", "Clocked Out and markers removed", 8000, 'info')  
    lib.notify({
        title = 'Fueler',
        description = 'Clocked Out and markers removed',
        type = 'inform',
        duration = 8000,
        position = 'top'
       })
end)
      

---fueler End------------------------------------------------------------------------------------------------