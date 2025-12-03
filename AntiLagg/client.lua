local usesound = false
local isondelay = false
local function pop()
  Citizen.CreateThread(function ()
    if isondelay == false then
      isondelay = true
      TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 20, 'antilagg', 1.0)
      Citizen.Wait(math.random(400, 800))
      isondelay = false
    end
  end)
end

-- Table to store the Vehicle Net IDs that currently have the antilag effect active
local active_antilag_vehicles = {}
local current_antilag_vehicle = nil -- Local vehicle for the current player's thread

local timesrun = 0
local nitrorun = 0

-- Function to handle the visual effect (nitro/flames)
local function setAntilagEffect(vehicle, state)
    if state then
        -- Request particle asset just in case (though `SetVehicleNitroEnabled` might handle it)
        lib.requestNamedPtfxAsset("veh_xs_vehicle_mods")
        SetVehicleNitroEnabled(vehicle, true)
    else
        SetVehicleNitroEnabled(vehicle, false)
    end
end

-- Event to receive the state change from the server (for syncing to other clients)
RegisterNetEvent('antilagg:syncState', function(vehicleNetId, state)
    local vehicle = NetToVeh(vehicleNetId)
    if DoesVehicleExist(vehicle) then
        if state then
            active_antilag_vehicles[vehicleNetId] = vehicle
        else
            active_antilag_vehicles[vehicleNetId] = nil
        end
        setAntilagEffect(vehicle, state)
    end
end)

RegisterCommand("antilagg", function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    
    if vehicle ~= nil then
        -- Terminate existing thread if the command is run again in the same vehicle
        if current_antilag_vehicle == vehicle then
            return
        end
        
        -- Use vehicle Net ID for server sync
        local vehicleNetId = VehToNet(vehicle)
        if not vehicleNetId then
            print("Failed to get Net ID for vehicle, cannot sync.")
            return
        end

        current_antilag_vehicle = vehicle
        
        -- Start the main antilag loop
        local thread = Citizen.CreateThread(function()
            local isAntilagActive = false
            
            while true do
                -- Check if the player is still in the original vehicle
                if GetVehiclePedIsIn(PlayerPedId(), false) ~= vehicle then
                    -- If effect was active, turn it off and notify server
                    if isAntilagActive then
                        isAntilagActive = false
                        -- Turn off local effect and notify server
                        setAntilagEffect(vehicle, false)
                        TriggerServerEvent('antilagg:toggle', vehicleNetId, false)
                    end
                    current_antilag_vehicle = nil
                    Citizen.TerminateThisThread()
                    return
                end

                local RPM = GetVehicleCurrentRpm(vehicle)
                local gear = GetVehicleCurrentGear(vehicle)
                
                -- Antilag activation condition
                if RPM > 0.4 and gear > 1 and not IsControlPressed(1, 71) and not IsControlPressed(1, 72) then
                    
                    -- Only trigger server event if the state is changing
                    if not isAntilagActive then
                        isAntilagActive = true
                        TriggerServerEvent('antilagg:toggle', vehicleNetId, true)
                        -- Also set the effect locally immediately
                        setAntilagEffect(vehicle, true)
                    end
                    
                    timesrun = 0
                    nitrorun = nitrorun + 1
                    
                    if usesound == true then
                      pop()
                    end
                else -- Antilag deactivation condition
                    
                    -- Only trigger server event if the state is changing
                    if isAntilagActive then
                        isAntilagActive = false
                        TriggerServerEvent('antilagg:toggle', vehicleNetId, false)
                        -- Also unset the effect locally immediately
                        setAntilagEffect(vehicle, false)
                    end
                    
                    timesrun = timesrun + 1
                    if timesrun == 5 then
                      if nitrorun >= 20 then
                        nitrorun = 0
                        TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 20, "blowoff", 0.2)
                      end
                    end
                end

                Wait(100)
            end
        end)
    end
end)