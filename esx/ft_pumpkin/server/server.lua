local ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('ft_pumpkin:givepumpkin')
AddEventHandler('ft_pumpkin:givepumpkin', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addInventoryItem(Config.Rewards.item, 1)
    end
end)

RegisterServerEvent('ft_pumpkin:sellpumpkins')
AddEventHandler('ft_pumpkin:sellpumpkins', function(input)
    local xPlayer = ESX.GetPlayerFromId(source)
    local amountToSell = tonumber(input[1])

    local playerPumpkins = xPlayer.getInventoryItem(Config.Rewards.item).count

    if playerPumpkins >= amountToSell then
        xPlayer.removeInventoryItem(Config.Rewards.item, amountToSell)
        
        xPlayer.addAccountMoney(Config.Rewards.money, amountToSell * Config.Rewards.amount)
    end
end)
