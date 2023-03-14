-- [[ QBCore Related Variables ]] --
local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local currentShop, currentData

-- [[ Ped Data ]] --
local pedSpawned = false
local PedCreated = {}

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        DeletePeds()
    end
end)

-- [[ Check Function ]] --
local function CheckForLicense()
    if PlayerData.metadata["licences"].weapon and QBCore.Functions.HasItem("weaponlicense") or QBCore.Functions.HasItem("license_a") or QBCore.Functions.HasItem("license_b") or QBCore.Functions.HasItem("license_c") or QBCore.Functions.HasItem("license_d") then
        return true
    end
    
    return false
end

-- [[ Store Functions ]] --
local function SetupItems(shop, checkLicense)
    local products = Config.Locations[shop].products
    local curJob
    local curGang
    local items = {}
    for i = 1, #products do
        curJob = products[i].requiredJob
        curGang = products[i].requiredGang

        if curJob then goto jobCheck end
        if curGang then goto gangCheck end
        if checkLicense then goto licenseCheck end

        items[#items + 1] = products[i]

        goto nextIteration

        :: jobCheck ::
        for i2 = 1, #curJob do
            if PlayerData.job.name == curJob[i2] then
                items[#items + 1] = products[i]
            end
        end

        goto nextIteration

        :: gangCheck ::
        for i2 = 1, #curGang do
            if PlayerData.gang.name == curGang[i2] then
                items[#items + 1] = products[i]
            end
        end

        goto nextIteration

        :: licenseCheck ::
        if not products[i].requiresLicense then
            items[#items + 1] = products[i]
        end

        :: nextIteration ::
    end
    return items
end

local function openShop(shop, data)
    local ShopItems = {}
    ShopItems.items = {}
    ShopItems.label = data["label"]

    if data.type == "weapon" and Config.FirearmsLicenseCheck then
        if CheckForLicense() then
            ShopItems.items = SetupItems(shop)
            QBCore.Functions.Notify('Your license was verified!', "success")
            Wait(500)
        else
            ShopItems.items = SetupItems(shop, true)
            QBCore.Functions.Notify('You should talk to a police officer for a license!', "error")
            Wait(500)
        end
    else
        ShopItems.items = SetupItems(shop)
    end

    for k in pairs(ShopItems.items) do
        ShopItems.items[k].slot = k
    end

    TriggerServerEvent("inventory:server:OpenInventory", "shop", "Itemshop_" .. shop, ShopItems)
end

-- [[ Intial Loading ]] --
CreateThread(function()
    for k, v in pairs(Config.Locations) do
        if pedSpawned then 
            return 
        end
    
        for k, v in pairs(Config.Locations) do
            if not PedCreated[k] then 
                PedCreated[k] = {} 
            end
    
            local current = v["ped"]
            current = type(current) == 'string' and joaat(current) or current
            RequestModel(current)
    
            while not HasModelLoaded(current) do
                Wait(0)
            end
    
            -- The coords + heading of the Ped
            PedCreated[k] = CreatePed(0, current, v["coords"].x, v["coords"].y, v["coords"].z-1, v["coords"].w, false, false)
            
            TaskStartScenarioInPlace(PedCreated[k], v["scenario"], 0, true)
            FreezeEntityPosition(PedCreated[k], true)
            SetEntityInvincible(PedCreated[k], true)
            SetBlockingOfNonTemporaryEvents(PedCreated[k], true)
            -- Target Stuff.. Read Config
            if v["target"] then
                exports['qb-target']:AddTargetEntity(PedCreated[k], {
                    options = {
                        {
                            label = v["text"],
                            icon = v["icon"],
                            item = v["item"],
                            action = function()
                                openShop(k, Config.Locations[k])
                            end,
                        },
                    },
                    distance = 2.0
                })
            end
        end
    
        pedSpawned = true
    end
end)

-- [[ Function To Delete Peds ]] --
function DeletePeds()
    if pedSpawned then
        for _, v in pairs(PedCreated) do
            DeletePed(v)
        end
    end
end

-- [[ Check if the Ped is dead and delete afther 1 Minute ]] --
CreateThread(function()
    while true do
        Wait(5000)
        if pedSpawned then
            for _, v in pairs(PedCreated) do
                if IsEntityDead(v) then 
                    DeletePed(v)
                end
            end
        end
    end
end)

-- [[ QBCore Events ]] --
RegisterNetEvent("qb-shops:client:UpdateShop", function(shop, itemData, amount)
    TriggerServerEvent("qb-shops:server:UpdateShopItems", shop, itemData, amount)
end)

RegisterNetEvent("qb-shops:client:SetShopItems", function(shop, shopProducts)
    Config.Locations[shop]["products"] = shopProducts
end)

RegisterNetEvent("qb-shops:client:RestockShopItems", function(shop, amount)
    if not Config.Locations[shop]["products"] then return end

    for k in pairs(Config.Locations[shop]["products"]) do
        Config.Locations[shop]["products"][k].amount = Config.Locations[shop]["products"][k].amount + amount
    end
end)

-- [[ Net Events ]] --
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)