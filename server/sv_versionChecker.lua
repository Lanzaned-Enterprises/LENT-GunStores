--[[ Version Checker ]] --
local version = "101"

AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        checkResourceVersion()
    end
end)

function checkUpdateEmbed(color, name, message, footer)
    local content = {
        {
            ["color"] = color,
            ["title"] = " " .. name .. " ",
            ["description"] = message,
            ["footer"] = {
                ["text"] = " " .. footer .. " ",
            },
        }
    }
    PerformHttpRequest(Config.DISCORD_WEBHOOK, function(err, text, headers) end, 
    'POST', json.encode({
        username = Config.DISCORD_NAME, 
        embeds = content, 
        avatar_url = Config.DISCORD_IMAGE
    }), { ['Content-Type'] = 'application/json '})
end

function checkResourceVersion()
    PerformHttpRequest("https://github.com/Lanzaned-Enterprises/LENT-GunStores/blob/master/version.txt", function(err, text, headers)
        if (version > text) then -- Using Dev Branch
            print(" ")
            print("---------- LANZANED GUNSTORES ----------")
            print("LENT-GunStores is using a development branch! Please update to stable ASAP!")
            print("Your Version: " .. version .. " Current Stable Version: " .. text)
            print("https://github.com/Lanzaned-Enterprises/LENT-GunStores")
            print("----------------------------------------")
            print(" ")
            checkUpdateEmbed(5242880, "LENT-GunStores Update Checker", "LENT-GunStores is using a development branch! Please update to stable ASAP!\nYour Version: " .. version .. " Current Stable Version: " .. text .. "\nhttps://github.com/Lanzaned-Enterprises/LENT-GunStores", "Script created by: https://discord.lanzaned.com")
        elseif (text > version) then -- Not updated
            print(" ")
            print("---------- LANZANED GUNSTORES ----------")
            print("LENT-GunStores is not up to date! Please update!")
            print("Curent Version: " .. version .. " Latest Version: " .. text)
            print("https://github.com/Lanzaned-Enterprises/LENT-GunStores")
            print("----------------------------------------")
            print(" ")
            checkUpdateEmbed(5242880, "LENT-GunStores Update Checker", "LENT-GunStores is not up to date! Please update!\nCurent Version: " .. version .. " Latest Version: " .. text .. "\nhttps://github.com/Lanzaned-Enterprises/LENT-GunStores", "Script created by: https://discord.lanzaned.com")
        else -- resource is fine
            print(" ")
            print("---------- LANZANED GUNSTORES ----------")
            print("LENT-GunStores is up to date and ready to go!")
            print("Running on Version: " .. version)
            print("https://github.com/Lanzaned-Enterprises/LENT-GunStores")
            print("----------------------------------------")
            print(" ")
            checkUpdateEmbed(20480, "LENT-GunStores Update Checker", "LENT-GunStores is up to date and ready to go!\nRunning on Version: " .. version .. "\nhttps://github.com/Lanzaned-Enterprises/LENT-GunStores", "Script created by: https://discord.lanzaned.com")
        end 
    end, "GET", "", {})
end