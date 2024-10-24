function repairKit()
    local repairKit = exports.ox_inventory:GetItemCount('repairkit')
    local pedCoords = GetEntityCoords(cache.ped)
    local vehicle, _ = lib.getClosestVehicle(pedCoords, 4.0, false)
    if repairKit >= 1 then
        local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}, 'easy'}, {'e'})
        if success then
            SetVehicleDoorOpen(vehicle, 4, true, true)
            if Config.ProgressType == 'circle' then
                lib.progressCircle({
                    label        = L['PROGRESS_LABEL'],
                    duration     = 5000,
                    position     = 'bottom',
                    useWhileDead = false,
                    canCancel    = false,
                    disable      = {
                        move = true,
                        car  = true,
                    },
                    anim         = {
                        dict = Config.RepairKitAnims.dict,
                        clip = Config.RepairKitAnims.clip
                    },
                })
            elseif Config.ProgressType == 'bar' then
                lib.progressBar({
                    duration = 5000,
                    label = L['PROGRESS_LABEL'],
                    useWhileDead = false,
                    canCancel = false,
                    disable = {
                        move = true,
                        car = true,
                    },
                    anim = {
                        dict = 'mini@repair',
                        clip = 'fixing_a_ped'
                    }
                })
            end
            repairVehicle(vehicle)
            lib.notify({
                title = L['NOTI_TITLE_KIT'],
                description = L['SUCCESS_REPAIR'],
                type = 'success',
                position = 'top-center'
            })
        end
        TriggerServerEvent('hx_repair:server:removeKit')
    else
        lib.notify({
            title = L['NOTI_TITLE_KIT'],
            description = L['MISSING_ITEM'],
            type = 'error',
            position = 'top-center'
        })
    end
end

CreateThread(function()
    if Config.RepairKitEnabled then
        exports.ox_target:addGlobalVehicle({
            {
                label = L['REPAIR_VEHICLE_TARGET'],
                bones = { 'bonnet' },
                icon = 'fa-solid fa-toolbox',
                distance = 2,
                onSelect = function()
                    repairKit()
                end,
            }
        })
    else
        return
    end
end)
