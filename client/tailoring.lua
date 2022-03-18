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

RegisterNetEvent('koe_jobs:startTailoringjob')
AddEventHandler('koe_jobs:startTailoringjob',function()
        onjobTailoring = true
        exports['okokNotify']:Alert("Tailoring", "Ive added markers to your map for all locations, to get started go third eye the field marked in red", 15000, 'info') 

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
                            return onjobTailoring == true
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
                            return onjobTailoring == true
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
                            return onjobTailoring == true
                        end,
                    },
                },
                distance = 3.5
        })

end)

RegisterNetEvent('koe_jobs:tailorWool')
AddEventHandler('koe_jobs:tailorWool',function()
    local finished = exports["tgiann-skillbar"]:taskBar(30000)
    if finished then
        local finished2 = exports["tgiann-skillbar"]:taskBar(1100)
        if finished2 then
            local finished3 = exports["tgiann-skillbar"]:taskBar(800)
            if finished3 then
                TriggerServerEvent('koe_jobs:getWool')  
            end
        end
    end
end)

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
            TriggerServerEvent('koe_jobs:getFabric')  
        end
    end

end)

RegisterNetEvent('koe_jobs:getClothe')
AddEventHandler('koe_jobs:getClothe',function()
    local finished = exports["tgiann-skillbar"]:taskBar(400)
    if finished then
        TriggerServerEvent('koe_jobs:getTailoringRewards')   
    end
end)

RegisterNetEvent('koe_jobs:sellTailoring')
AddEventHandler('koe_jobs:sellTailoring',function()
    TriggerServerEvent('koe_jobs:sellTailoringRewards')  
end)

RegisterNetEvent('koe_jobs:endTailoring')
AddEventHandler('koe_jobs:endTailoring',function()
    onjobTailoring = false
    RemoveBlip(woolBlip)
    RemoveBlip(fabricBlip)
    RemoveBlip(clotheBlip)
    exports['okokNotify']:Alert("Tailoring", "Clocked Out and markers removed", 8000, 'info')  
end)
      

---Tailoring End------------------------------------------------------------------------------------------------