local xp = 0
local level = 0

RegisterNetEvent('koe_jobs:mainXp')
AddEventHandler('koe_jobs:mainXp', function(xp)

        if xp == 0 and xp <= 9999 then
            level = 0
        elseif xp >= 1000 and xp <= 1999 then
            level = 1
        elseif xp >= 2000 and xp <= 2999 then
            level = 2
        elseif xp >= 3000 and xp <= 3999 then
            level = 3
        elseif xp >= 4000 and xp <= 4999 then
            level = 4
        elseif xp >= 5000 then
            level = 5
        end
    TriggerServerEvent('koe_jobs:xphandler', xp, level)
    TriggerEvent('koe_jobs:miningTarget', xp, level)
end)
