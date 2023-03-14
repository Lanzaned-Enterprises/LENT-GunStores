local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-shops:server:UpdateShopItems', function(shop, itemData, amount)
    if not shop or not itemData or not amount then return end

    Config.Locations[shop]["products"][itemData.slot].amount -= amount
    if Config.Locations[shop]["products"][itemData.slot].amount < 0 then
        Config.Locations[shop]["products"][itemData.slot].amount = 0
    end

    TriggerClientEvent('qb-shops:client:SetShopItems', -1, shop, Config.Locations[shop]["products"])
end)

RegisterNetEvent('qb-shops:server:RestockShopItems', function(shop)
    if not shop or not Config.Locations[shop]?["products"] then return end

    local randAmount = math.random(10, 50)
    for k in pairs(Config.Locations[shop]["products"]) do
        Config.Locations[shop]["products"][k].amount += randAmount
    end

    TriggerClientEvent('qb-shops:client:RestockShopItems', -1, shop, randAmount)
end)