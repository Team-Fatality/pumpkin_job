Config = {}

Config.settings = {
    Locale = 'en',
    Target = 'qb',                                                     -- ox or qb
    UseTarget = true,                                                  -- false if wanna use 3d text
    Debug = false,
}

Config.Rewards = {
    item = 'ft_pumpkin',                                               -- pumpkin item name 
    money = 'cash',                                                   -- account type  (cash or bank)
    amount = 180                                                        -- how much $ you ll get for selling pumpkins
}

Config.Locations = {
    Radius = 40,                                                       -- in how much radius pumpkins ll spawn
    Prop = 'prop_veg_crop_03_pump',                                    -- prop name
    Count = 10,                                                         -- how much pumpkins ll spawn in zone
    Ped = 'u_m_y_zombie_01',                                           -- ped spawn code 
    Start = vector4(3311.0464, 5176.2817, 19.6146, 239.4020),          -- start and sell pumpkin location
    Zones = {                                                          -- Zones to farm pumpkins (after starting one of them all selected automatically)
        vector3(2302.3735, 5136.7554, 51.63),
        vector3(248.2724, 6457.7837, 31.311),
        vector3(1492.5748, -2333.8813, 74.0),
    }
}

Config.Blips = {
    Start = {
        Name = "Pumpkin Job",
        Sprite = 84,
        Color = 5,
        Scale = 0.9,
    },
    Zones = {
        Name = "Pumpkin",
        Sprite = 171,
        Color = 5,
        Scale = 0.5,
    }
}
