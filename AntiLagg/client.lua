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


local timesrun = 0
local nitrorun = 0
RegisterCommand("antilagg", function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    --SetVehicleMod(vehicle, )
    if vehicle ~= nil then
        local thread = Citizen.CreateThread(function()
            while true do
                local RPM = GetVehicleCurrentRpm(vehicle)
                local gear = GetVehicleCurrentGear(vehicle)
                if RPM > 0.4 and gear > 1 and not IsControlPressed(1, 71) and not IsControlPressed(1, 72) then
                    --CreateVehicleExhaustBackfire(vehicle, 0.75)
                    lib.requestNamedPtfxAsset("veh_xs_vehicle_mods")
                    SetVehicleNitroEnabled(vehicle, true)
                    timesrun = 0
                    nitrorun += 1
                    if usesound == true then
                      pop()
                    end
                else
                    SetVehicleNitroEnabled(vehicle, false)
                    timesrun += 1
                    if timesrun == 5 then
                      if nitrorun >= 20 then
                        nitrorun = 0
                        TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 20, "blowoff", 0.2)
                      end
                    end
                end
                if GetVehiclePedIsIn(PlayerPedId(), false) ~= vehicle then
                    Citizen.TerminateThisThread()
                end
                Wait(100)
            end
        end)
    end
end)
