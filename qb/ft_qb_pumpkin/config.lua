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
    Prop = 'prop_veg_crop_03_pump',                                    -- prop name
    Ped = 'u_m_y_zombie_01',                                           -- ped spawn code 
    Start = vector4(3311.0464, 5176.2817, 19.6146, 239.4020),          -- start and sell pumpkin location
    Zones = {                                                          -- Zones to farm pumpkins (after starting one of them all selected automatically)
        [1] = {
            vector3(2302.3735, 5136.7554, 51.6315),
            vector3(2280.4358, 5125.5483, 51.2915),
            vector3(2265.8828, 5135.0396, 53.7162),
            vector3(2280.9731, 5147.8979, 54.7415),
            vector3(2295.4111, 5167.3252, 58.0826),
            vector3(2301.4080, 5153.6025, 54.3130),
            vector3(2326.2988, 5123.5303, 48.5670),
            vector3(2323.0535, 5110.1396, 47.6894),
            vector3(2309.6506, 5108.7808, 47.9968),
            vector3(2309.5715, 5096.5171, 47.4717),
        },
        [2] = {
            vector3(1865.4810, 4909.2026, 45.3941),
            vector3(1862.2811, 4920.5117, 46.3701),
            vector3(1864.2994, 4933.9531, 48.2237),
            vector3(1875.7372, 4941.0591, 50.1243),
            vector3(1885.9773, 4928.7920, 48.7323),
            vector3(1888.5181, 4913.3555, 47.6533),
            vector3(1874.3320, 4884.0430, 45.2015),
            vector3(1862.8824, 4870.3662, 44.1549),
            vector3(1848.3451, 4849.2305, 44.1467),
            vector3(1813.9321, 4897.2837, 42.3332),
        },
        [3] = {
            vector3(732.9182, 6457.9482, 31.6209),
            vector3(726.6858, 6472.8691, 29.3638),
            vector3(711.9891, 6471.1875, 29.7007),
            vector3(702.3328, 6458.9746, 30.7789),
            vector3(684.6400, 6469.5283, 30.4121),
            vector3(671.0437, 6484.8228, 29.6526),
            vector3(652.6766, 6485.5835, 30.1856),
            vector3(637.4549, 6470.8657, 30.3669),
            vector3(619.9382, 6463.1880, 29.9293),
            vector3(614.4620, 6487.6895, 29.7970),
        },
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
