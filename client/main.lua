lib.locale()

local _registerCommand = RegisterCommand

---@param commandName string
---@param callback fun(source, args, raw)
---@param restricted boolean?
function RegisterCommand(commandName, callback, restricted)
	_registerCommand(commandName, function(_, args, raw)
		if not restricted or lib.callback.await('ox_lib:checkPlayerAce', 100, ('command.%s'):format(commandName)) then
            lib.notify({ type = 'success', description = locale('success') })
			return callback(args, raw)
		end

        lib.notify({ type = 'error', description = locale('no_permission') })
	end)
end

local function freezePlayer(state, vehicle)
    local playerId, ped = cache.playerId, cache.ped
    vehicle = vehicle and cache.vehicle

    SetPlayerInvincible(playerId, state)
    FreezeEntityPosition(ped, state)
    SetEntityCollision(ped, not state)

    if vehicle then
        if not state then
            SetVehicleOnGroundProperly(vehicle)
        end

        FreezeEntityPosition(vehicle, state)
        SetEntityCollision(vehicle, not state)
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

RegisterCommand('goback', function()
    if lastCoords then
        local currentCoords = GetEntityCoords(cache.ped)
        teleport(cache.vehicle, lastCoords.x, lastCoords.y, lastCoords.z)
        lastCoords = currentCoords
    end
end, true)

RegisterCommand('tpm', function()
	local marker = GetFirstBlipInfoId(8)

    if marker ~= 0 then
        local coords = GetBlipInfoIdCoord(marker)

        DoScreenFadeOut(100)
        Wait(100)

        local vehicle = cache.seat == -1 and cache.vehicle
        lastCoords = GetEntityCoords(cache.ped)

        freezePlayer(true, vehicle)

        local z, inc, int = 0.0, 20.0, 0

        while z < 800.0 do
            Wait(0)
            local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, z, false)

            if int == 0 then
                int = GetInteriorAtCoords(coords.x, coords.y, z)

                if int ~= 0 then
                    inc = 2.0
                end
            end

            if found then
                teleport(vehicle, coords.x, coords.y, groundZ)
                break
            end

            teleport(vehicle, coords.x, coords.y, z)
            z += inc
        end

        freezePlayer(false, vehicle)
        SetGameplayCamRelativeHeading(0)
        DoScreenFadeIn(750)
    end
end, true)

RegisterCommand('setcoords', function(_, raw)
    raw = raw:sub(raw:find('%(') + 1 or 11, -1):gsub('%)', ''):gsub(',', '')
    local x, y, z, w = string.strsplit(' ', raw)

    if x and y and z then
        DoScreenFadeOut(100)
        Wait(100)

        local vehicle = cache.seat == -1 and cache.vehicle
        lastCoords = GetEntityCoords(cache.ped)

        teleport(vehicle, tonumber(x), tonumber(y), tonumber(z))

        if w then
            SetEntityHeading(cache.ped, tonumber(w) or 90)
        end

        SetGameplayCamRelativeHeading(0)
        DoScreenFadeIn(750)
    end
end, true)
end)

local noClip = false

-- https://github.com/Deltanic/fivem-freecam/
-- https://github.com/tabarra/txAdmin/tree/master/scripts/menu/vendor/freecam
RegisterCommand('noclip', function()
    noClip = not noClip
    SetFreecamActive(noClip)
end, true)
