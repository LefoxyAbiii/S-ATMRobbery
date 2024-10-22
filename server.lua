ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('atm:rewardPlayer')
AddEventHandler('atm:rewardPlayer', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addAccountMoney('black_money', amount)
        xPlayer.removeInventoryItem("drill", 1)
        TriggerClientEvent('ox_lib:notify', source, {title = 'ATM Robbery', description = 'You received $' .. amount, type = 'success'})
    end
end)

RegisterNetEvent('wash_money:exchange', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local blackMoney = xPlayer.getAccount('black_money').money

    if blackMoney >= amount then
        local washedAmount = math.floor(amount * 0.85)
        local companyCut = amount - washedAmount

        xPlayer.removeAccountMoney('black_money', amount)
        xPlayer.addMoney(washedAmount)

        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Erfolgreich',
            description = 'Du hast '..washedAmount..'$ gewaschen! Die Firma behielt '..companyCut..'$.',
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = 'Fehler',
            description = 'Nicht genug Schwarzgeld!',
            type = 'error'
        })
    end
end)


RegisterNetEvent('atm:notifyPolice')
AddEventHandler('atm:notifyPolice', function(atmCoords)
    local _source = source
    local xPlayers = ESX.GetPlayers()

    for _, playerId in ipairs(xPlayers) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer.job.name == 'police' then
            TriggerClientEvent('esx:showHelpNotification', playerId, 'Ein ATM wird überfallen! Drücke E für einen Wegpunkt.', false)
            -- Hier kannst du einen Wegpunkt setzen, wenn gewünscht
            TriggerClientEvent('esx:showMarker', playerId, atmCoords) -- Füge einen Marker oder Wegpunkt hinzu
        end
    end
end)
