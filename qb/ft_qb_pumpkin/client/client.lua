local QBCore = exports['qb-core']:GetCoreObject()

local spawnedPed = nil
local isNearPed = false
local spawnedpumpkins = {}
local pumpkinCount = 0
local totalpumpkin = 0
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

local function GetGroundZUsingRaycast(x, y)
    local startZ = 1000.0
    local endZ = -1000.0
    local rayHandle = StartShapeTestRay(x, y, startZ, x, y, endZ, -1, PlayerPedId(), 0)
    local _, hit, hitCoord = GetShapeTestResult(rayHandle)

    if hit then
        return hitCoord.z
    else
        return 5.0
    end
end

local function getRandomLocationInZone(zone, radius)
    local offsetX = math.random(-radius, radius)
    local offsetY = math.random(-radius, radius)
    local newLocation = vector3(zone.x + offsetX, zone.y + offsetY, zone.z)

    local groundZ = GetGroundZUsingRaycast(newLocation.x, newLocation.y)

    return vector3(newLocation.x, newLocation.y, groundZ)
end

local function CutPumpkin(prop, zoneName)

    pumpkinCount = pumpkinCount + 1

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
            if Config.settings.Target == 'ox' then
                exports.ox_target:removeZone(zoneName)
            elseif Config.settings.Target == 'qb' then
                exports['qb-target']:RemoveZone(zoneName)
            end
        end
    end

    TriggerServerEvent('ft_qb_pumpkin:givepumpkin')
    pumpkinFarm = false

    if pumpkinCount >= totalpumpkin then
        lib.notify({ title = L('notify.pumpkin'), description = L('notify.finished_farming'), type = 'success' })
    end
end

local function SpawnPumpkins(propModel, location)
    local model = GetHashKey(propModel)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(500)
    end

    local adjustedLocation = vector3(location.x, location.y, GetGroundZUsingRaycast(location.x, location.y))
    local prop = CreateObject(model, adjustedLocation.x, adjustedLocation.y, adjustedLocation.z, true, true, true)

    SetEntityAsMissionEntity(prop, true, true)

    PlaceObjectOnGroundProperly(prop)

    FreezeEntityPosition(prop, true)

    local blip = CreateBlip(adjustedLocation, Config.Blips.Zones)

    local propCoords = GetEntityCoords(prop)
    local zoneName = 'interaction_prop_' .. #spawnedpumpkins + 1
    local targetZone = {
        coords = propCoords,
        zoneName = zoneName,
        size = vector3(1.5, 1.5, 1.5)
    }
    table.insert(spawnedpumpkins, { prop = prop, coords = propCoords, blip = blip, targetZone = targetZone })

    if Config.settings.UseTarget then
        if Config.settings.Target == 'ox' then
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
        elseif Config.settings.Target == 'qb' then
            exports['qb-target']:AddBoxZone(targetZone.zoneName, targetZone.coords, 2, 2, {
                name = targetZone.zoneName,
                heading = 0,
                debugPoly = Config.settings.Debug,
                minZ = targetZone.coords.z - 1,
                maxZ = targetZone.coords.z + 1,
            }, {
                options = {
                    {
                        icon = 'fas fa-hand',
                        label = L('target.farm_pumpkin'),
                        action = function()
                            CutPumpkin(prop, targetZone.zoneName)
                        end,
                    }
                },
                distance = 2.0
            })
        end
    end

    totalpumpkin = totalpumpkin + 1
end

local function StarPumpkinFarming()
    if not pumpkinFarm then
        lib.notify({ title = L('notify.pumpkin'), description = L('notify.started_farming'), type = 'success' })

        local randomIndex = math.random(1, #Config.Locations.Zones)
        local selectedZone = Config.Locations.Zones[randomIndex]

        for i = 1, Config.Locations.Count do
            local randomLocation = getRandomLocationInZone(selectedZone, Config.Locations.Radius)
            SpawnPumpkins(Config.Locations.Prop, randomLocation)
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
        TriggerServerEvent('ft_qb_pumpkin:sellpumpkins', input)
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
        if Config.settings.Target == 'ox' then
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
        elseif Config.settings.Target == 'qb' then
            exports['qb-target']:AddBoxZone('interaction_ped', coords, 2, 2, {
                name = 'interaction_ped',
                heading = 0,
                debugPoly = Config.settings.Debug,
                minZ = coords.z - 1,
                maxZ = coords.z + 1,
            }, {
                options = {
                    {
                        icon = 'fas fa-hand',
                        label = L('target.talk'),
                        action = function()
                            OpenPedMenu()
                        end,
                    }
                },
                distance = 2.0
            })
        end
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
