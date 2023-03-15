-- [[ QBCore Related Variables ]] --
local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local currentShop, currentData

-- [[ Ped Data ]] --
local pedSpawned = false
local PedCreated = {}

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        PlayerData = QBCore.Functions.GetPlayerData()
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        DeletePeds()
    end
end)

-- [[ QBCore Events ]] --
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = nil
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

-- [[ Check Function ]] --
local function CheckForLicense()
    if PlayerData.metadata["licences"].weapon then
        return true
    end

    return false
end

-- [[ Store Functions ]] --
local function SetupItems(shop)
    local products = Config.Locations[shop].products
    local curJob
    local curGang
    local items = {}
    for i = 1, #products do
        curJob = products[i].requiredJob
        curGang = products[i].requiredGang
        curClass = products[i].weaponClass

        if curJob then goto jobCheck end
        if curGang then goto gangCheck end
        if curClass then goto classCheck end

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

        :: classCheck ::
        for i2 = 1, #curClass do
            if QBCore.Functions.HasItem('license_a') and curClass == "A" then
                items[#items + 1] = products[i]
            elseif QBCore.Functions.HasItem('license_b') and curClass == "B" or curClass == "A" then
                items[#items + 1] = products[i]
            elseif QBCore.Functions.HasItem('license_c') and curClass == "C" or curClass == "A" or curClass == "B" then
                items[#items + 1] = products[i]
            elseif QBCore.Functions.HasItem('license_d') and curClass == "D" or curClass == "A" or curClass == "B" or curClass == "C" then
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