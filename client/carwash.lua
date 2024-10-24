function washVehicle()
    local pedCoords = GetEntityCoords(cache.ped)
    local vehicle, _ = lib.getClosestVehicle(pedCoords, 4.0, false)
    local success = lib.skillCheck({'easy', 'easy', {areaSize = 60, speedMultiplier = 2}, 'easy'}, {'e'})
    if success then
        if Config.ProgressType == 'circle' then
            lib.progressCircle({
                label        = L['WASH_PROG_LABEL'],
                duration     = 5000,
                position     = 'bottom',
                useWhileDead = false,
                canCancel    = false,
                disable      = {
                    move = true,
                    car  = true,
                },
                anim         = {
                    dict = Config.CarWashAnims.dict, -- amb@world_human_maid_clean@base -- missheistdocks2aleadinoutlsdh_2a_int
                    clip = Config.CarWashAnims.clip -- base -- cleaning_wade
                },
            })
        elseif Config.ProgressType == 'bar' then
            lib.progressBar({
                duration = 5000,
                label = L['WASH_PROG_LABEL'],
                useWhileDead = false,
                canCancel = false,
                disable = {
                    move = true,
                    car = true,
                },
                anim = {
                    dict = Config.CarWashAnims.dict,
                    clip = Config.CarWashAnims.clip
                }
            })
        end
        SetVehicleDirtLevel(vehicle, 0.0)
        lib.notify({
            title = L['WASH_TITLE'],
            description = L['WASH_DESCRIPTION_SUCCESS'],
            type = 'success',
            position = 'top-center'
        })
    end
end

CreateThread(function()
    if Config.CarWashEnabled then
        exports.ox_target:addGlobalVehicle({
            {
                label = L['WASH_CAR_TARGET'],
                bones = { 'bonnet', 'chassis', 'bodyshell', 'boot', 'door_dside_f', 'door_dside_r', 'door_pside_f', 'door_pside_r' },
                icon = 'fa-solid fa-soap',
                distance = 2,
                onSelect = function()
                    washVehicle()
                end,
            }
        })
    else
        return
    end
end)


RegisterCommand('maxdirt', function()
    SetVehicleDirtLevel(GetVehiclePedIsIn(PlayerPedId(), false), 15.0)
end)