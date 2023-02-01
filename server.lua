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

lib.addCommand('group.admin', 'setappearance', function(source, args)
    local entity = GetPlayerPed(args.target)

    if entity ~= 0 then
        TriggerClientEvent('ox_commands:setappearance', args.target, false, true)
        return TriggerClientEvent('ox_commands:notify', source, { type = 'success', description = 'success' })
    end

    lib.notify(source, { type = 'error', description = 'invalid_target' })
end, {'target:number'})
