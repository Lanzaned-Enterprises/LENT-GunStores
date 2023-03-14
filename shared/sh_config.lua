Config = {}

Config.FirearmsLicenseCheck = true

-- requiredJob = { "mechanic", "police" } || requiresLicense = true

Config.Products = {
    ["weapons"] = {
        [1] = { -- Knife
            name = "weapon_knife",
            price = 250,
            amount = math.random(50, 100),
            info = {},
            type = "item",
            slot = 1,
        },

        [2] = { -- M9 / Class 1
            name = "weapon_m9",
            price = 2500,
            amount = math.random(10, 50),
            info = {},
            type = "item",
            slot = 2,
            requiresLicense = true
        },
        [3] = { -- Desert Eagle / Class 1
            name = "weapon_de",
            price = 2500,
            amount = math.random(10, 50),
            info = {},
            type = "item",
            slot = 3,
            requiresLicense = true
        },
        [4] = { -- FNX445 / Class 1
            name = "weapon_fnx45",
            price = 2500,
            amount = math.random(10, 50),
            info = {},
            type = "item",
            slot = 4,
            requiresLicense = true
        },
        [5] = { -- Glock 17 / Class 1
            name = "weapon_glock17",
            price = 2500,
            amount = math.random(10, 50),
            info = {},
            type = "item",
            slot = 5,
            requiresLicense = true
        },
        [6] = { -- M1911 / Class 1
            name = "weapon_m1911",
            price = 2500,
            amount = math.random(10, 50),
            info = {},
            type = "item",
            slot = 6,
            requiresLicense = true
        },
        [7] = { -- Glock 22 / Class 1
            name = "weapon_glock22",
            price = 2500,
            amount = math.random(10, 50),
            info = {},
            type = "item",
            slot = 7,
            requiresLicense = true
        },
    },
}

Config.Locations = {
    ["SandyShoresGunStore"] = {
        ["label"] = "Ammunation",
        ["type"] = "weapon",
        ["products"] = Config.Products["weapons"],

        ["target"] = true,
        ["icon"] = "fa-solid fa-gun", ["text"] = "Open Store", 

        ["coords"] = vector4(1692.15, 3760.78, 34.71, 230.08),
        ["ped"] = "s_m_m_ammucountry",
        ["scenario"] = "WORLD_HUMAN_COP_IDLES",
    },
}