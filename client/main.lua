lib.locale()

local _registerCommand = RegisterCommand

---@param commandName string
---@param callback fun(source, args, raw)
---@param restricted boolean?
function RegisterCommand(commandName, callback, restricted)
	_registerCommand(commandName, function(_, args, raw)
        CreateThread(function()
            if not restricted or lib.callback.await('ox_lib:checkPlayerAce', 100, ('command.%s'):format(commandName)) then
                lib.notify({ type = 'success', description = locale('success') })
                return callback(args, raw)
            end

            lib.notify({ type = 'error', description = locale('no_permission') })
        end)
	end)
end

local function freezePlayer(state, vehicle)
    local playerId, ped = cache.playerId, cache.ped
    vehicle = vehicle and cache.vehicle

    SetPlayerInvincible(playerId, state)
    FreezeEntityPosition(ped, state)
    SetEntityCollision(ped, not state, true)

    if vehicle then
        if not state then
            SetVehicleOnGroundProperly(vehicle)
        end

        FreezeEntityPosition(vehicle, state)
        SetEntityCollision(vehicle, not state, true)
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

        local z, inc, int = 0.0, Config.TeleportIncrement + 0.0, 0

        while z < 800.0 do
            Wait(0)
            local found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, z, true)

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

local function stringToCoords(input)
    local arr, num = {}, 0

    for n in string.gmatch(input:gsub('vec.-%d?%(', ''), '(-?[%d.%d]+)') do
        num += 1
        arr[num] = tonumber(n)
    end

    return table.unpack(arr)
end

RegisterCommand('setcoords', function(_, raw)
    local x, y, z, w = stringToCoords(raw)

    if x then
        DoScreenFadeOut(100)
        Wait(100)

        local vehicle = cache.seat == -1 and cache.vehicle
        lastCoords = GetEntityCoords(cache.ped)

        teleport(vehicle, x, y, z)

        if w then
            SetEntityHeading(cache.ped, w)
        end

        SetGameplayCamRelativeHeading(0)
        DoScreenFadeIn(750)
    end
end, true)

RegisterCommand('coords', function(args)
    local coords = GetEntityCoords(cache.ped)
    local str = args[1] and 'vec4(%.3f, %.3f, %.3f, %.3f)' or 'vec3(%.3f, %.3f, %.3f)'
    str = str:format(coords.x, coords.y, coords.z, args[1] and GetEntityHeading(cache.ped) or nil)

    print(str)
    lib.setClipboard(str)
end, false)

SetTimeout(1000, function()
    TriggerEvent('chat:addSuggestion', '/coords', 'Saves current coordinates to the clipboard.', {
        { name = 'heading', help = 'Save your current heading.' },
    })
end)

local noClip = false

-- https://github.com/Deltanic/fivem-freecam/
-- https://github.com/tabarra/txAdmin/tree/master/scripts/menu/vendor/freecam
RegisterCommand('noclip', function()
    noClip = not noClip
    SetFreecamActive(noClip)
end, true)
