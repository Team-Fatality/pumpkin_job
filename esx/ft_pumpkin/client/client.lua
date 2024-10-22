local ESX = exports['es_extended']:getSharedObject()

local spawnedPed = nil
local isNearPed = false
local spawnedpumpkins = {}
local pumpkinFarm = false

local function Draw3DText(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local function CreateBlip(coords, blipConfig)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, blipConfig.Sprite)
    SetBlipColour(blip, blipConfig.Color)
    SetBlipScale(blip, blipConfig.Scale)
    SetBlipDisplay(blip, 4)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipConfig.Name)
    EndTextCommandSetBlipName(blip)
    
    return blip
end

local function CutPumpkin(prop, zoneName)

    local playerPed = PlayerPedId()

    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_GARDENER_PLANT", 0, true)
    lib.progressBar({
        duration = 5000,
        label = L('bar.cutting_pumpkin'),

    })

    ClearPedTasksImmediately(playerPed)

    if DoesEntityExist(prop) then
        DeleteEntity(prop)

        for i, data in ipairs(spawnedpumpkins) do
            if data.prop == prop then
                if data.blip then
                    RemoveBlip(data.blip)
                end

                table.remove(spawnedpumpkins, i)
                break
            end
        end

        if Config.settings.UseTarget then
            exports.ox_target:removeZone(zoneName)
        end
    end

    TriggerServerEvent('ft_pumpkin:givepumpkin')
    pumpkinFarm = false
end

local function SpawnPumpkins(propModel, location)
    local model = GetHashKey(propModel)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(500)
    end

    local prop = CreateObject(model, location.x, location.y, location.z - 1.0, true, true, true)

    -- PlaceObjectOnGroundProperly(prop)
    FreezeEntityPosition(prop, true)

    SetEntityAsMissionEntity(prop, true, true)

    local blip = CreateBlip(location, Config.Blips.Zones)

    local propCoords = GetEntityCoords(prop)
    local zoneName = 'interaction_prop_' .. #spawnedpumpkins + 1
    local targetZone = {
        coords = propCoords,
        zoneName = zoneName,
        size = vector3(1.5, 1.5, 1.5)
    }
    table.insert(spawnedpumpkins, { prop = prop, coords = propCoords, blip = blip, targetZone = targetZone })

    if Config.settings.UseTarget then
        exports['ox_target']:addBoxZone({
            coords = targetZone.coords,
            size = targetZone.size,
            debug = Config.settings.Debug,
            name = targetZone.zoneName,
            options = {
                {
                    icon = 'fas fa-hand',
                    label = L('target.farm_pumpkin'),
                    onSelect = function(data)
                        CutPumpkin(prop, targetZone.zoneName)
                    end
                }
            }
        })
    end
end


local function StarPumpkinFarming()
    if not pumpkinFarm then
        lib.notify({ title = L('notify.pumpkin'), description = L('notify.started_farming'), type = 'success' })

        local randomIndex = math.random(1, #Config.Locations.Zones)
        local selectedZone = Config.Locations.Zones[randomIndex]

        for _, location in ipairs(selectedZone) do
            SpawnPumpkins(Config.Locations.Prop, location)
        end
        
        pumpkinFarm = true
    else
        lib.notify({ title = L('notify.pumpkin'), description = L('notify.already_farming'), type = 'success' })
    end
end


local function OpenSellMenu()
    local input = lib.inputDialog(L('menu.sell_pumpkins'), {
        {type = 'number', label = L('menu.amount_sell'), description = L('menu.enter_amount'), required = true, min = 1},
    })

    if input then
        TriggerServerEvent('ft_pumpkin:sellpumpkins', input)
    end
end

local function OpenPedMenu()

    lib.progressBar({
        duration = 3000,
        label = L('bar.talking'),
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true,
        },
        anim = {
            dict = 'misscarsteal4@actor',
            clip = 'actor_berating_loop'
        }

    })
    local menu = {
        {
            title = L('menu.pumpkin_farming'),
            icon = 'fa-play',
            onSelect = function()
                StarPumpkinFarming()
            end
        },
        {
            title = L('menu.sell_pumpkins'),
            icon = 'fa-dollar-sign',
            onSelect = function()
                OpenSellMenu()
            end
        }
    }

    lib.registerContext({
        id = 'pumpkin_farm_menu',
        title = L('menu.pumpkin_menu'),
        options = menu
    })

    lib.showContext('pumpkin_farm_menu')
end

CreateThread(function()
    local model = GetHashKey(Config.Locations.Ped)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(500)
    end

    local coords = Config.Locations.Start
    spawnedPed = CreatePed(4, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)

    SetEntityAsMissionEntity(spawnedPed, true, true)
    SetPedFleeAttributes(spawnedPed, 0, 0)
    SetPedCombatAttributes(spawnedPed, 46, 1)
    SetPedDiesWhenInjured(spawnedPed, false)
    TaskStartScenarioInPlace(spawnedPed, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
    SetEntityInvincible(spawnedPed, true)
    FreezeEntityPosition(spawnedPed, true)
    CreateBlip(Config.Locations.Start, Config.Blips.Start)

    if Config.settings.UseTarget then
        exports['ox_target']:addBoxZone({
            coords = coords,
            size = vector3(1.5, 1.5, 1.5),
            debug = Config.settings.Debug,
            options = {
                {
                    name = 'interaction_ped',
                    icon = 'fas fa-hand',
                    label = L('target.talk'),
                    onSelect = function(data)
                        OpenPedMenu()
                    end
                }
            }
        })
    end

    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        if DoesEntityExist(spawnedPed) then
            local pedCoords = GetEntityCoords(spawnedPed)
            local distanceToPed = #(playerCoords - pedCoords)
            isNearPed = distanceToPed < 3.0

            if isNearPed and not Config.settings.UseTarget then
                Draw3DText(pedCoords.x, pedCoords.y, pedCoords.z + 1.0, L('interactions.talk'))

                if IsControlJustPressed(1, 38) then
                    OpenPedMenu()
                end
            end
        end

        for _, data in ipairs(spawnedpumpkins) do
            local prop = data.prop
            if DoesEntityExist(prop) then
                local propCoords = data.coords
                local distanceToProp = #(playerCoords - propCoords)

                if distanceToProp < 2.0 and not Config.settings.UseTarget then
                    Draw3DText(propCoords.x, propCoords.y, propCoords.z + 1.0, L('interactions.farm_pumpkin'))

                    if IsControlJustPressed(1, 38) then
                        CutPumpkin(prop, data.targetZone.zoneName)
                    end
                end
            end
        end
    end
end)
