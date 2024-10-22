local atmModels = {
    'prop_fleeca_atm',
    'prop_atm_01',
    'prop_atm_02',
    'prop_atm_03'
}

local function isNearATM()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, atmModel in pairs(atmModels) do
        local atm = GetClosestObjectOfType(playerCoords, 1.5, GetHashKey(atmModel), false, false, false)
        if DoesEntityExist(atm) then
            return true
        end
    end
    return false
end

exports('startATMRobbery', function()
    if isNearATM() then

        local playerPed = PlayerPedId()

        SetPedComponentVariation(playerPed, 5, 45, 0, 2) -- Ändere hier 45 auf die ID der gewünschten Tasche


        local success = exports['howdy-hackminigame']:Begin(1, 15000) 
        if success then
            if lib.progressCircle({
                duration = 15000,
                position = 'bottom',
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                },
                anim = {
                    dict = 'mp_missheist_ornatebank',
                    clip = 'put_cash_into_bag_loop'
                }
            }) then
                local reward = math.random(5000, 20000)
                TriggerServerEvent('atm:rewardPlayer', reward)
                SetPedComponentVariation(playerPed, 5, 0, 0, 2)
                lib.notify({title = 'Robbery Success!', description = 'You received $' .. reward, type = 'success'})
            else
                SetPedComponentVariation(playerPed, 5, 0, 0, 2) 
                lib.notify({title = 'Robbery Cancelled', description = 'You cancelled the robbery.', type = 'error'})
            end
        else
            SetPedComponentVariation(playerPed, 5, 0, 0, 2) 
            lib.notify({title = 'Hack Failed', description = 'You failed the hack.', type = 'error'})
        end
    else
        lib.notify({title = 'No ATM Nearby', description = 'You are not near an ATM.', type = 'error'})
    end

    SetPedComponentVariation(playerPed, 5, 0, 0, 2) 


end)

local ox_inventory = exports.ox_inventory
local ESX = exports['es_extended']:getSharedObject() 

RegisterCommand('washmoney', function()
    local input = lib.inputDialog('Money Wash', {'Wie viel Black Money möchtest du waschen?'})
    
    if not input or not tonumber(input[1]) then
        return
    end

    local amount = tonumber(input[1])
    
    local playerMoney = ox_inventory:Search('count', 'black_money') -- Anzahl des Black Money
    if playerMoney < amount then
        lib.notify({title = 'Fehler', description = 'Du hast nicht genug Schwarzgeld!', type = 'error'})
        return
    end

    if lib.progressBar({
        duration = 5000,
        label = 'Wasche Geld...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
        },
    }) then
        TriggerServerEvent('wash_money:exchange', amount)
    else
        lib.notify({title = 'Abgebrochen', description = 'Der Geldwäsche-Vorgang wurde abgebrochen.', type = 'error'})
    end
end)