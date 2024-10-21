
Locales = {}
local lang = Config.settings.Locale  -- do not touch

Locales["en"] = {
    interactions = {
        talk = "[E] Talk",
        farm_pumpkin = "[E] Farm Pumpkin",
    },
    target = {
        farm_pumpkin = "Farm Pumpkin",
        talk = "Talk",
    },
    menu = {
        pumpkin_farming = "Start Pumpkin Farming",
        sell_pumpkins = "Sell Pumpkins",
        pumpkin_menu = "Pumpkin Farm Menu",
        amount_sell = "Amount to Sell",
        enter_amount = "Enter the amount of pumpkins to sell",
    },
    bar = {
        talking = "Talking",
        cutting_pumpkin = "Cutting Pumpkin",
    },
    notify = {
        pumpkin = "Pumpkin",
        started_farming = "You have started pumpkins farming!",
        already_farming = "Already farming.",
        finished_farming = "You have finished pumpkins farming!",
    },
}















function L(key)
    local value = Locales[lang]
    for k in key:gmatch("[^.]+") do
        value = value[k]

        if not value then
            print("Missing locale for: " .. key)
            return ""
        end
    end
    return value
end