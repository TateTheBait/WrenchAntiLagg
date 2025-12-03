RegisterNetEvent('antilagg:toggle')
AddEventHandler('antilagg:toggle', function(vehicleNetId, state)
    local source = source
    
    -- Sync the state change to all other clients
    TriggerClientEvent('antilagg:syncState', -1, vehicleNetId, state)
end)