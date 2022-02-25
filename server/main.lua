----Gets ESX-----
ESX = nil
local ox_inventory = exports.ox_inventory

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)



--MINING START ---------------------------------------------------------------------------------------------------------------------------------------
--Gives Stone for mining
RegisterServerEvent('koe_jobs:getStone')
AddEventHandler('koe_jobs:getStone', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.addInventoryItem('stone', Config.stoneAmount )

end)

--Checks the count of stone before allowing to wash the stone
RegisterServerEvent('koe_jobs:stoneCount')
AddEventHandler('koe_jobs:stoneCount', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'stone', 'washed_stone'})
    if items and items.stone > 1 then
        TriggerClientEvent('koe_jobs:washStone', source)
    else
        TriggerClientEvent('okokNotify:Alert', source, "Mining", "Not enough stone, go mine some more.", 8000, 'error')
    end

end)

--Checks the count of washed stone before allowing to wash the stone
RegisterServerEvent('koe_jobs:washedstoneCount')
AddEventHandler('koe_jobs:washedstoneCount', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'stone', 'washed_stone'})
    if items and items.washed_stone > 1 then
        TriggerClientEvent('koe_jobs:smelt', source)
    else
        TriggerClientEvent('okokNotify:Alert', source, "Mining", "Not enough washed stone, go wash some more.", 8000, 'error')
    end

end)

--Washes the stone
RegisterServerEvent('koe_jobs:getWashed')
AddEventHandler('koe_jobs:getWashed', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'stone', 'washed_stone'})
    if items and items.stone > 1 then
        xPlayer.removeInventoryItem('stone', 1)
        xPlayer.addInventoryItem('washed_stone', 2)
    else
        TriggerClientEvent('okokNotify:Alert', source, "Mining", "Not enough stone, go mine some more.", 8000, 'error')
    end

end)

--Smelts the stone
RegisterServerEvent('koe_jobs:getMiningRewards')
AddEventHandler('koe_jobs:getMiningRewards', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'stone', 'washed_stone'})
    if items and items.washed_stone > 1 then
        xPlayer.removeInventoryItem('washed_stone', 1)
        xPlayer.addInventoryItem('copper', 8)
        xPlayer.addInventoryItem('iron', 6)
        xPlayer.addInventoryItem('gold', 5)
    else
        TriggerClientEvent('okokNotify:Alert', source, "Mining", "Not enough washed stone, go wash some more.", 8000, 'error')
    end

end)

--Selling of the goods
RegisterServerEvent('koe_jobs:sellMiningRewards')
AddEventHandler('koe_jobs:sellMiningRewards', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'iron', 'copper', 'gold'})
    if items and items.copper > 1 then
        xPlayer.removeInventoryItem('copper', items.copper)
        xPlayer.addMoney(items.copper * Config.CopperPrice )
    end
    if items and items.iron > 1 then
        xPlayer.removeInventoryItem('iron', items.iron)
        xPlayer.addMoney(items.iron * Config.IronPrice )
    end
    if items and items.gold > 1 then
        xPlayer.removeInventoryItem('gold', items.gold)
        xPlayer.addMoney(items.gold * Config.GoldPrice )
    end

end)

--MINING END ---------------------------------------------------------------------------------------------------------------------------------------


--BUTCHER START ---------------------------------------------------------------------------------------------------------------------------------------
--Gives Alive chickens
RegisterServerEvent('koe_jobs:getChickens')
AddEventHandler('koe_jobs:getChickens', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.addInventoryItem('alive_chicken', Config.chickenAmount )

end)

--Checks the count alive chickens before killing
RegisterServerEvent('koe_jobs:chickenCount')
AddEventHandler('koe_jobs:chickenCount', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'alive_chicken', 'slaughtered_chicken', 'packaged_chicken'})
    if items and items.alive_chicken > 1 then
        TriggerClientEvent('koe_jobs:killEmAll', source)
    else
        TriggerClientEvent('okokNotify:Alert', source, "Butcher", "Not enough Chickens, go get some!", 8000, 'error')
    end

end)

--Checks the count of dead chickens before packaging
RegisterServerEvent('koe_jobs:killedCount')
AddEventHandler('koe_jobs:killedCount', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'alive_chicken', 'slaughtered_chicken', 'packaged_chicken'})
    if items and items.slaughtered_chicken > 1 then
        TriggerClientEvent('koe_jobs:PackageEmUp', source)
    else
        TriggerClientEvent('okokNotify:Alert', source, "Butcher", "Not enough DEAD Chickens, go get some!", 8000, 'error')
    end

end)

--Gives Dead Chickens
RegisterServerEvent('koe_jobs:getKilled')
AddEventHandler('koe_jobs:getKilled', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'alive_chicken', 'slaughtered_chicken', 'packaged_chicken'})
    if items and items.alive_chicken > 1 then
        xPlayer.removeInventoryItem('alive_chicken', 1)
        xPlayer.addInventoryItem('slaughtered_chicken', 2)
    else
        TriggerClientEvent('okokNotify:Alert', source, "Butcher", "Not enough DEAD Chickens, go get some!", 8000, 'error')
    end

end)

--Smelts the stone
RegisterServerEvent('koe_jobs:getButcherRewards')
AddEventHandler('koe_jobs:getButcherRewards', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'alive_chicken', 'slaughtered_chicken', 'packaged_chicken'})
    if items and items.slaughtered_chicken > 1 then
        xPlayer.removeInventoryItem('slaughtered_chicken', 1)
        xPlayer.addInventoryItem('packaged_chicken', 8)
    else
        TriggerClientEvent('okokNotify:Alert', source, "Butcher", "Not enough DEAD Chickens, go get some!", 8000, 'error')
    end

end)

--Selling of the goods
RegisterServerEvent('koe_jobs:sellButcherRewards')
AddEventHandler('koe_jobs:sellButcherRewards', function()
	local xPlayer = ESX.GetPlayerFromId(source)
    local items = ox_inventory:Search(source, 'count', {'alive_chicken', 'slaughtered_chicken', 'packaged_chicken'})
    if items and items.packaged_chicken > 1 then
        xPlayer.removeInventoryItem('packaged_chicken', items.packaged_chicken)
        xPlayer.addMoney(items.packaged_chicken * Config.packagedPrice )
    end

end)

--BUTCHER END ---------------------------------------------------------------------------------------------------------------------------------------