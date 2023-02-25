lib.addCommand('freeze', {
    help = 'Freeze the player',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id', 
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    local entity = GetPlayerPed(args.target)

    if entity ~= 0 then
        TriggerClientEvent('ox_commands:freeze', args.target, true, true)
        return TriggerClientEvent('ox_commands:notify', source, { type = 'success', description = 'success' })
    end

    lib.notify(source, { type = 'error', description = 'invalid_target' })
end)

lib.addCommand('thaw', {
    help = 'Unfreeze the player',
    params = {
        {
            name = 'target',
            type = 'playerId',
            help = 'Target player\'s server id', 
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    local entity = GetPlayerPed(args.target)

    if entity ~= 0 then
        TriggerClientEvent('ox_commands:freeze', args.target, false, true)
        return TriggerClientEvent('ox_commands:notify', source, { type = 'success', description = 'success' })
    end

    lib.notify(source, { type = 'error', description = 'invalid_target' })
end)
