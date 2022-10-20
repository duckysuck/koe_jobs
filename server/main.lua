----Gets ESX---------------------------------------------------------
ESX = nil
local ox_inventory = exports.ox_inventory

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
---------------------------------------------------------------------

--MINING START ---------------------------------------------------------------------------------------------------------------------------------------

--Gives Stone for mining
RegisterServerEvent('koe_jobs:getStone')
AddEventHandler('koe_jobs:getStone', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local stoneAmount = math.random(Config.minStone , Config.maxStone)
    if ox_inventory:CanCarryItem(source, 'stone', stoneAmount) then
	    xPlayer.addInventoryItem('stone', stoneAmount)
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = "Not enough space", duration = 8000, position = 'top'})
        TriggerClientEvent('koe_jobs:endStoneLoop', source)
    end

end)

--Checks the count of stone before allowing to wash the stone
RegisterServerEvent('koe_jobs:stoneCount')
AddEventHandler('koe_jobs:stoneCount', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'stone', 'washed_stone'})
    if items and items.stone > 0 then
        TriggerClientEvent('koe_jobs:washStone', source)
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = "Not enough stone, go mine some more.", duration = 8000, position = 'top'})
        TriggerClientEvent('koe_jobs:endStoneLoop', source)
    end

end)

--Checks the count of washed stone before allowing to wash the stone
RegisterServerEvent('koe_jobs:washedstoneCount')
AddEventHandler('koe_jobs:washedstoneCount', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'stone', 'washed_stone'})
    if items and items.washed_stone > 0 then
        TriggerClientEvent('koe_jobs:smelt', source)
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = "Not enough washed stone, go wash some more.", duration = 8000, position = 'top'})
        TriggerClientEvent('koe_jobs:endStoneLoop', source)
    end

end)

--Washes the stone
RegisterServerEvent('koe_jobs:getWashed')
AddEventHandler('koe_jobs:getWashed', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'stone', 'washed_stone'})
    if items and items.stone > 0 then
        if ox_inventory:CanCarryItem(source, 'washed_stone', 1) then
            xPlayer.removeInventoryItem('stone', 1)
            xPlayer.addInventoryItem('washed_stone', 1)
        else
            TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = "Not enough space", duration = 8000, position = 'top'})
            TriggerClientEvent('koe_jobs:endStoneLoop', source)
        end
        
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = "Not enough stone, go mine some more.", duration = 8000, position = 'top'})
        TriggerClientEvent('koe_jobs:endStoneLoop', source)
    end

end)

--Smelts the stone
RegisterServerEvent('koe_jobs:getMiningRewards')
AddEventHandler('koe_jobs:getMiningRewards', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'stone', 'washed_stone'})
    if items and items.washed_stone > 0 then
        if ox_inventory:CanCarryItem(source, 'copper', 2) and ox_inventory:CanCarryItem(source, 'iron', 1) then
            xPlayer.removeInventoryItem('washed_stone', 1)
            xPlayer.addInventoryItem('copper', 2)
            xPlayer.addInventoryItem('iron', 1)
        else
            TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = "Not enough space", duration = 8000, position = 'top'})
            TriggerClientEvent('koe_jobs:endStoneLoop', source)
        end
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = "Not enough washed stone, go wash some more.", duration = 8000, position = 'top'})
        TriggerClientEvent('koe_jobs:endStoneLoop', source)
    end

end)

--Selling of the goods
RegisterServerEvent('koe_jobs:sellMiningRewards')
AddEventHandler('koe_jobs:sellMiningRewards', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'iron', 'copper'})
    if items and items.copper > 0 then
        xPlayer.removeInventoryItem('copper', items.copper)
        -- xPlayer.addMoney(items.copper * Config.CopperPrice )
        TriggerEvent('sd-paycheck:server:AddPaycheck', items.copper * Config.CopperPrice, xPlayer.source)
    end
    if items and items.iron > 0 then
        xPlayer.removeInventoryItem('iron', items.iron)
        -- xPlayer.addMoney(items.iron * Config.IronPrice )
        TriggerEvent('sd-paycheck:server:AddPaycheck', items.iron * Config.IronPrice, xPlayer.source)
    end
    local soldAmountMining1 = items.copper * Config.CopperPrice
    local soldAmountMining2 = items.iron * Config.IronPrice
    local finalAmountMining = soldAmountMining1 + soldAmountMining2
    TriggerClientEvent('ox_lib:notify', source, {type = 'success', description = "Sold all items. Head to the main bank to pick up your check", duration = 10000, position = 'top'})

end)

--MINING END ---------------------------------------------------------------------------------------------------------------------------------------


--BUTCHER START ---------------------------------------------------------------------------------------------------------------------------------------
--Gives Alive chickens
RegisterServerEvent('koe_jobs:getChickens')
AddEventHandler('koe_jobs:getChickens', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local chickenAmount = 1
	
    if ox_inventory:CanCarryItem(source, 'alive_chicken', chickenAmount) then
        xPlayer.addInventoryItem('alive_chicken', chickenAmount)
    else
        lib.notify({
            title = 'Butcher',
            description = 'Not enough space',
            type = 'error',
            duration = 8000,
            position = 'top'
        })
        TriggerClientEvent('koe_jobs:endButcherLoop', source)
    end

end)

--Checks the count alive chickens before killing
RegisterServerEvent('koe_jobs:chickenCount')
AddEventHandler('koe_jobs:chickenCount', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'alive_chicken', 'slaughtered_chicken', 'packaged_chicken'})
    if items and items.alive_chicken > 0 then
        TriggerClientEvent('koe_jobs:killEmAll', source)
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = "Not enough Chickens, go get some!", duration = 8000, position = 'top'})
        TriggerClientEvent('koe_jobs:endButcherLoop', source)
    end

end)

--Checks the count of dead chickens before packaging
RegisterServerEvent('koe_jobs:killedCount')
AddEventHandler('koe_jobs:killedCount', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'alive_chicken', 'slaughtered_chicken', 'packaged_chicken'})
    if items and items.slaughtered_chicken > 0 then
        TriggerClientEvent('koe_jobs:PackageEmUp', source)
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = "Not enough DEAD Chickens, go get some!", duration = 8000, position = 'top'})
        TriggerClientEvent('koe_jobs:endButcherLoop', source)
    end

end)

--Gives Dead Chickens
RegisterServerEvent('koe_jobs:getKilled')
AddEventHandler('koe_jobs:getKilled', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'alive_chicken', 'slaughtered_chicken', 'packaged_chicken'})
    if items and items.alive_chicken > 0 then
        if ox_inventory:CanCarryItem(source, 'slaughtered_chicken', 2) then
            xPlayer.removeInventoryItem('alive_chicken', 1)
            xPlayer.addInventoryItem('slaughtered_chicken', 1)
        else
            TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = "Not enough space.", duration = 8000, position = 'top'})
            TriggerClientEvent('koe_jobs:endButcherLoop', source)
        end
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = "Not enough DEAD Chickens, go get some!", duration = 8000, position = 'top'})
        TriggerClientEvent('koe_jobs:endButcherLoop', source)
    end

end)

--dead chicken to packaged chicken
RegisterServerEvent('koe_jobs:getButcherRewards')
AddEventHandler('koe_jobs:getButcherRewards', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'alive_chicken', 'slaughtered_chicken', 'packaged_chicken'})
    if items and items.slaughtered_chicken > 0 then
        if ox_inventory:CanCarryItem(source, 'packaged_chicken', 1) then
            xPlayer.removeInventoryItem('slaughtered_chicken', 1)
            xPlayer.addInventoryItem('packaged_chicken', 1)
        else
            TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = "Not enough space.", duration = 8000, position = 'top'})
            TriggerClientEvent('koe_jobs:endButcherLoop', source)
        end
        
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = "Not enough DEAD Chickens, go get some!", duration = 8000, position = 'top'})
        TriggerClientEvent('koe_jobs:endButcherLoop', source)
    end

end)

--Selling of the goods
RegisterServerEvent('koe_jobs:sellButcherRewards')
AddEventHandler('koe_jobs:sellButcherRewards', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'alive_chicken', 'slaughtered_chicken', 'packaged_chicken'})
    if items and items.packaged_chicken > 0 then
        xPlayer.removeInventoryItem('packaged_chicken', items.packaged_chicken)
        -- xPlayer.addMoney(items.packaged_chicken * Config.packagedPrice )
        TriggerEvent('sd-paycheck:server:AddPaycheck', items.packaged_chicken * Config.packagedPrice, xPlayer.source)
        local soldAmountButcher = items.packaged_chicken * Config.packagedPrice
        TriggerClientEvent('ox_lib:notify', source, {type = 'success', description = 'Sold all items. Head to the main bank to pick up your check', position = 'top', duration = 10000})
    end

end)

--BUTCHER END ---------------------------------------------------------------------------------------------------------------------------------------


--TAILOR START ---------------------------------------------------------------------------------------------------------------------------------------
--Gives Wool
RegisterServerEvent('koe_jobs:getWool')
AddEventHandler('koe_jobs:getWool', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local woolAmount = math.random(Config.minWool, Config.maxWool)
	
    if ox_inventory:CanCarryItem(source, 'wool', woolAmount) then
        xPlayer.addInventoryItem('wool', woolAmount)
    else
        lib.notify({
            title = 'Tailoring',
            description = 'Not enough space',
            type = 'error',
            duration = 8000,
            position = 'top'
        })
        TriggerClientEvent('koe_jobs:endTailorLoop', source)
    end

end)

--Checks the count of wool before turning into fabric
RegisterServerEvent('koe_jobs:woolCount')
AddEventHandler('koe_jobs:woolCount', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'wool', 'fabric', 'clothe'})
    if items and items.wool > 0 then
        TriggerClientEvent('koe_jobs:getFabric', source)
    else
        lib.notify({
            title = 'Tailoring',
            description = 'Not enough wool go get some!',
            type = 'error',
            duration = 8000,
            position = 'top'
        })
        TriggerClientEvent('koe_jobs:endTailorLoop', source)
    end

end)


--Gives Fabric
RegisterServerEvent('koe_jobs:getFabric')
AddEventHandler('koe_jobs:getFabric', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'wool', 'fabric', 'clothe'})
    if items and items.wool > 0 then
        if ox_inventory:CanCarryItem(source, 'fabric', 2) then
            xPlayer.removeInventoryItem('wool', 1)
            xPlayer.addInventoryItem('fabric', 1)
        else
            TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'Not enough space', duration = 8000, position = 'top'})
            TriggerClientEvent('koe_jobs:endTailorLoop', source)
        end
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'Not enough Wool, go get some!', duration = 8000, position = 'top'})
        TriggerClientEvent('koe_jobs:endTailorLoop', source)
    end

end)

--Checks the count of fabric before turning into clothe
RegisterServerEvent('koe_jobs:fabricCheck')
AddEventHandler('koe_jobs:fabricCheck', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'wool', 'fabric', 'clothe'})
    if items and items.fabric > 0 then
        TriggerClientEvent('koe_jobs:getClothe', source)
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'Not enough Fabric, go get some!', duration = 8000, position = 'top'})
        TriggerClientEvent('koe_jobs:endTailorLoop', source)
    end

end)

--fabric to clothe
RegisterServerEvent('koe_jobs:getTailoringRewards')
AddEventHandler('koe_jobs:getTailoringRewards', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'wool', 'fabric', 'clothe'})
    if items and items.fabric > 0 then
        if ox_inventory:CanCarryItem(source, 'clothe', 2) then
            xPlayer.removeInventoryItem('fabric', 1)
            xPlayer.addInventoryItem('clothe', 2)
            -- local identifier =  ESX.GetPlayerFromId(source).identifier
	        -- exports['koe_vendors']:giveCivLevel(identifier, 1)
        else
            TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'Not enough space', duration = 8000, position = 'top'})
            TriggerClientEvent('koe_jobs:endTailorLoop', source)
        end
        
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'Not enough Fabric, go get some!', duration = 8000, position = 'top'})
        TriggerClientEvent('koe_jobs:endTailorLoop', source)
    end

end)

--Selling of the goods
RegisterServerEvent('koe_jobs:sellTailoringRewards')
AddEventHandler('koe_jobs:sellTailoringRewards', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'wool', 'fabric', 'clothe'})
    if items and items.clothe > 0 then
        xPlayer.removeInventoryItem('clothe', items.clothe)
        -- xPlayer.addMoney(items.clothe * Config.clothePrice )
        TriggerEvent('sd-paycheck:server:AddPaycheck', items.clothe * Config.clothePrice, xPlayer.source)
        local soldAmountTailor = items.clothe * Config.clothePrice
        TriggerClientEvent('ox_lib:notify', source, {type = 'success', description = 'Sold all items for $' ..soldAmountTailor.. ' Head to the main bank to pick up your check', position = 'top', duration = '10000'})
    end

end)

--Tailoring END ---------------------------------------------------------------------------------------------------------------------------------------

--FUELER START ---------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent('koe_jobs:getOil')
AddEventHandler('koe_jobs:getOil', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local petrolAmount = math.random(Config.minPetrol, Config.minPetrol)
	
    if ox_inventory:CanCarryItem(source, 'petrol', petrolAmount) then
        xPlayer.addInventoryItem('petrol', petrolAmount)
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'Not enough space', duration = 8000, position = 'top'})
        TriggerClientEvent('koe_jobs:endFuelerLoop', source)
    end

end)

RegisterServerEvent('koe_jobs:oilCount')
AddEventHandler('koe_jobs:oilCount', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'petrol', 'petrol_raffin', 'essence'})
    if items and items.petrol > 0 then
        TriggerClientEvent('koe_jobs:grabRefined', source)
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'Not enough Oil, go get some!', duration = 8000, position = 'top'})
        TriggerClientEvent('koe_jobs:endFuelerLoop', source)
    end

end)

RegisterServerEvent('koe_jobs:refinedCount')
AddEventHandler('koe_jobs:refinedCount', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'petrol', 'petrol_raffin', 'essence'})
    if items and items.petrol_raffin > 0 then
        TriggerClientEvent('koe_jobs:grabGas', source)
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'Not enough Refined Oil!', duration = 8000, position = 'top'})
        TriggerClientEvent('koe_jobs:endFuelerLoop', source)
    end

end)

RegisterServerEvent('koe_jobs:getRefined')
AddEventHandler('koe_jobs:getRefined', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'petrol', 'petrol_raffin', 'essence'})
    if items and items.petrol > 0 then
        if ox_inventory:CanCarryItem(source, 'petrol_raffin', 2) then
            xPlayer.removeInventoryItem('petrol', 1)
            xPlayer.addInventoryItem('petrol_raffin', 1)
        else
            TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'Not enough space', duration = 8000, position = 'top'})
            TriggerClientEvent('koe_jobs:endFuelerLoop', source)
        end
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'Not enough Oil!', duration = 8000, position = 'top'})
        TriggerClientEvent('koe_jobs:endFuelerLoop', source)
    end

end)

RegisterServerEvent('koe_jobs:getFuelerRewards')
AddEventHandler('koe_jobs:getFuelerRewards', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'petrol', 'petrol_raffin', 'essence'})
    if items and items.petrol_raffin > 0 then
        if ox_inventory:CanCarryItem(source, 'essence', 2) then
            xPlayer.removeInventoryItem('petrol_raffin', 1)
            xPlayer.addInventoryItem('essence', 2)
            -- local identifier =  ESX.GetPlayerFromId(source).identifier
	        -- exports['koe_vendors']:giveCivLevel(identifier, 1)
        else
            TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'Not enough space', duration = 8000, position = 'top'})
            TriggerClientEvent('koe_jobs:endFuelerLoop', source)
        end
        
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = 'Not enough Refined Oil!', duration = 8000, position = 'top'})
        TriggerClientEvent('koe_jobs:endFuelerLoop', source)
    end

end)

--Selling of the goods
RegisterServerEvent('koe_jobs:sellFuelerRewards')
AddEventHandler('koe_jobs:sellFuelerRewards', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'petrol', 'petrol_raffin', 'essence'})
    if items and items.essence > 0 then
        xPlayer.removeInventoryItem('essence', items.essence)
        -- xPlayer.addMoney(items.essence * Config.essencePrice )
        TriggerEvent('sd-paycheck:server:AddPaycheck', items.essence * Config.essencePrice, xPlayer.source)
        local soldAmountFueler = items.essence * Config.essencePrice
        TriggerClientEvent('ox_lib:notify', source, {type = 'success', description = 'Sold all items for $' ..soldAmountFueler.. ' Head to the main bank to pick up your check', position = 'top', duration = '10000'})
    end

end)

--Fueler END ---------------------------------------------------------------------------------------------------------------------------------------

RegisterServerEvent('koe_jobs:giveRating')
AddEventHandler('koe_jobs:giveRating', function()
    local identifier =  ESX.GetPlayerFromId(source).identifier
    exports['koe_vendors']:giveCivLevel(identifier, Config.CivRatingToGive)
    exports['koe_vendors']:giveCrimLevel(identifier, -10)
end)