----Gets ESX-----
ESX = nil

local PlayerData = {}
local butcherSpawned = false
local butcherNpc
onjobButcher = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

--Job start blips--
Citizen.CreateThread(function()
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

RegisterCommand('startbutcher', function(source, args, rawCommand)
    TriggerEvent('koe_jobs:startButcherjob')
end)

RegisterCommand('stopbutcher', function(source, args, rawCommand)
    TriggerEvent('koe_jobs:endButcherb')
end)

RegisterNetEvent('koe_jobs:startButcherjob')
AddEventHandler('koe_jobs:startButcherjob',function()
        onjobButcher = true
        -- exports['okokNotify']:Alert("Butcher", "Ive added markers to your map for all locations. To get started head to 1023 and third eye the cages inside on the left", 15000, 'info') 
        lib.notify({
            title = 'Butcher',
            description = 'Ive added markers to your map for all locations. To get started head to 1023 and third eye the cages inside on the left',
            type = 'inform',
            duration = 15000,
            position = 'top',
           })
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
        packageBlip = AddBlipForCoord(Config.packageChickenBlip)
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

        --package--
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
                TriggerEvent('koe_jobs:grabChickens')
                TriggerServerEvent('koe_jobs:getChickens')
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
            TriggerEvent('koe_jobs:killEmAll')
            TriggerServerEvent('koe_jobs:getKilled')
        end
    end

end)

RegisterNetEvent('koe_jobs:PackageEmUp')
AddEventHandler('koe_jobs:PackageEmUp',function()
    local finished = exports["tgiann-skillbar"]:taskBar(400)
    if finished then
        TriggerEvent('koe_jobs:PackageEmUp')
        TriggerServerEvent('koe_jobs:getButcherRewards') 
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
    -- exports['okokNotify']:Alert("Butcher", "Clocked Out and markers removed", 8000, 'info')  
    lib.notify({
        title = 'Mining',
        description = 'Clocked Out and markers removed',
        type = 'inform',
        duration = 8000,
        position = 'top',
       })
end)
      

---Butcher End------------------------------------------------------------------------------------------------