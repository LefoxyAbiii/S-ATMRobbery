local atmModels = Config.atmModels

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
        local playerCoords = GetEntityCoords(playerPed)

        SetPedComponentVariation(playerPed, 5, 45, 0, 2) 

        local success = exports['howdy-hackminigame']:Begin(1, 15000) 
        if success then
            -- Dispatch an PD
            TriggerServerEvent('atm:notifyPolice', playerCoords) -- Benachrichtigung an die Polizei

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
                local reward = math.random(Config.minReward, Config.maxReward)
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


Citizen.CreateThread(function()
    if Config.UseWashSystem then
        local washMarker = Config.WashMarkerPos
        while true do
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - washMarker)

            if distance < Config.WashMarkerRadius then
                lib.showTextUI('[E] Geld waschen')
                if IsControlJustReleased(0, 38) then  -- 38 = Taste "E"
                    local input = lib.inputDialog('Money Wash', {'Wie viel Black Money möchtest du waschen?'})
                    
                    if not input or not tonumber(input[1]) then
                        return
                    end

                    local amount = tonumber(input[1])
                    local playerMoney = ox_inventory:Search('count', 'black_money')
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
                end
            end
            Citizen.Wait(0)
        end
    end
end)
