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
        local washedAmount = math.floor(amount * 0.85) -- 15% abziehen
        local companyCut = amount - washedAmount -- Die Firma behält 15%

        -- Schwarzgeld entfernen und reguläres Geld hinzufügen
        xPlayer.removeAccountMoney('black_money', amount)
        xPlayer.addMoney(washedAmount) -- Spieler erhält 85% des gewaschenen Betrags

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
