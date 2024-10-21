local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('ft_qb_pumpkin:givepumpkin')
AddEventHandler('ft_qb_pumpkin:givepumpkin', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        Player.Functions.AddItem(Config.Rewards.item, 1)
    end
end)

RegisterNetEvent('ft_qb_pumpkin:sellpumpkins')
AddEventHandler('ft_qb_pumpkin:sellpumpkins', function(input)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local amountToSell = tonumber(input[1])

    local playerPumpkins = Player.Functions.GetItemByName(Config.Rewards.item)

    if playerPumpkins and playerPumpkins.amount >= amountToSell then
        Player.Functions.RemoveItem(Config.Rewards.item, amountToSell)
        
        Player.Functions.AddMoney(Config.Rewards.money, amountToSell * Config.Rewards.amount)
    end
end)
