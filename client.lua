lib.locale()

local function registerCommand(commandName, callback)
    RegisterCommand(commandName, function(_, args)
        if not lib.callback.await('ox_commands:hasPermission', 100, ('command.%s'):format(commandName)) then
            return lib.notify({ type = 'error', description = locale('no_permission') })
        end

        callback(args)
        lib.notify({ type = 'success', description = locale('success') })
    end)
end

local function freezePlayer(state, vehicle)
    local playerId, ped = cache.playerId, cache.ped
    local entity = vehicle and cache.vehicle or ped

    SetPlayerControl(playerId, not state, 1 << 8)
    SetPlayerInvincible(playerId, state)
    FreezeEntityPosition(entity, state)
    SetEntityCollision(entity, not state)

    if not state and vehicle then
        SetVehicleOnGroundProperly(entity)
    end
end

RegisterNetEvent('ox_commands:freeze', freezePlayer)

local function teleport(vehicle, x, y, z)
    if vehicle then
        return SetPedCoordsKeepVehicle(cache.ped, x, y, z)
    end

    SetEntityCoords(cache.ped, x, y, z, false, false, false, false)
end

local lastCoords

registerCommand('goback', function()
    if lastCoords then
        local currentCoords = GetEntityCoords(cache.ped)
        teleport(cache.vehicle, lastCoords.x, lastCoords.y, lastCoords.z)
        lastCoords = currentCoords
    end
end)

registerCommand('tpm', function()
	local marker = GetFirstBlipInfoId(8)

    if marker ~= 0 then
        DoScreenFadeOut(250)
        Wait(250)

        local coords = GetBlipInfoIdCoord(marker)
        local vehicle = cache.seat == -1 and cache.vehicle
        lastCoords = GetEntityCoords(cache.ped)

        freezePlayer(true, vehicle)

        local z = 30.0

        while z < 900.0 do
            Wait(0)
            local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, z, false)

            if found then
                teleport(vehicle, coords.x, coords.y, groundZ)
                break
            end

            teleport(vehicle, coords.x, coords.y, z)
            z += 30.0
        end

        freezePlayer(false, vehicle)
        DoScreenFadeIn(750)
    end
end)

local noClip = false

-- https://github.com/Deltanic/fivem-freecam/
-- https://github.com/tabarra/txAdmin/tree/master/scripts/menu/vendor/freecam
registerCommand('noclip', function()
    noClip = not noClip
    SetFreecamActive(noClip)
end)
