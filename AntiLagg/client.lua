local usesound = false

function CreateVehicleExhaustBackfire(vehicle, scale)
    local exhaustNames = {
      "exhaust",    "exhaust_2",  "exhaust_3",  "exhaust_4",
      "exhaust_5",  "exhaust_6",  "exhaust_7",  "exhaust_8",
      "exhaust_9",  "exhaust_10", "exhaust_11", "exhaust_12",
      "exhaust_13", "exhaust_14", "exhaust_15", "exhaust_16"
    }
  
    for _, exhaustName in ipairs(exhaustNames) do
      local boneIndex = GetEntityBoneIndexByName(vehicle, exhaustName)
  
      if boneIndex ~= -1 then
        local pos = GetWorldPositionOfEntityBone(vehicle, boneIndex)
        local off = GetOffsetFromEntityGivenWorldCoords(vehicle, pos.x, pos.y, pos.z)
  
        UseParticleFxAssetNextCall('core')
        StartParticleFxNonLoopedOnEntity('veh_backfire', vehicle, off.x, off.y, off.z, 0.0, 0.0, 0.0, scale, false, false, false)
      end
    end
  end

  local function vehicleActivate(veh, setType, value)
    if not veh or not DoesEntityExist(veh) then return end
    local state = Entity(veh).state
    state:set(("nd_nitro_activated_%s"):format(setType), value, true)
end

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