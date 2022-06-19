lib.callback.register('ox_commands:hasPermission', function(source, command)
    return IsPlayerAceAllowed(source, command)
end)

lib.addCommand('group.admin', 'freeze', function(source, args)
    local entity = GetPlayerPed(args.target)

    if entity ~= 0 then
        TriggerClientEvent('ox_commands:freeze', args.target, true, true)
        return TriggerClientEvent('ox_commands:notify', source, { type = 'success', description = 'success' })
    end

    lib.notify(source, { type = 'error', description = 'invalid_target' })
end, {'target:number'})

lib.addCommand('group.admin', 'thaw', function(source, args)
    local entity = GetPlayerPed(args.target)

    if entity ~= 0 then
        TriggerClientEvent('ox_commands:freeze', args.target, false, true)
        return TriggerClientEvent('ox_commands:notify', source, { type = 'success', description = 'success' })
    end

    lib.notify(source, { type = 'error', description = 'invalid_target' })
end, {'target:number'})
