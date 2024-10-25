colors = {
    body = '',
    engine = ''
}

---@param vehicle any
function repairVehicle(vehicle)
    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleEngineHealth(vehicle, 1000.0)
    SetVehicleBodyHealth(vehicle, 1000.0)
    SetVehicleDoorsLockedForPlayer(vehicle, false)
    RollDownWindow(vehicle, 0)
    RollDownWindow(vehicle, 1)
    SetVehicleFixed(vehicle)
    for i = 0, 7 do
        SetVehicleTyreFixed(vehicle, i)
    end
    SetVehicleDirtLevel(vehicle, 0.0)
end

---@return any
function getNearestVehicle()
    local pedLoc = GetEntityCoords(cache.ped)
    local closestVehicle, _ = lib.getClosestVehicle(pedLoc, 3.0, false)
    return closestVehicle
end

function repairProgress()
    if Config.ProgressType == 'circle' then
        if lib.progressCircle({
            duration = 5000,
            label = L['PROGRESS_LABEL'],
            position = 'bottom',
            useWhileDead = false,
            canCancel = false,
            disable = {move = true, car = true},
        }) then repairVehicle(cache.vehicle)
        end
    elseif Config.ProgressType == 'bar' then
        if lib.progressBar({
            duration = 5000,
            position = 'bottom',
            label = L['PROGRESS_LABEL'],
            useWhileDead = false,
            canCancel = false,
            disable = {move = true, car = true},
        }) then repairVehicle(cache.vehicle)
        end
    end
end
        

-- Create blips for repair bays
CreateThread(function()
    if Config.RepairBayEnabled then
        for _, info in pairs(Config.RepairBays) do
            if info.blip then
                info.blip = AddBlipForCoord(info.location.x, info.location.y, info.location.z)
                SetBlipSprite(info.blip, info.sprite)
                SetBlipDisplay(info.blip, 4)
                SetBlipScale(info.blip, 1.0)
                SetBlipColour(info.blip, info.blipColour)
                SetBlipAsShortRange(info.blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(info.name)
                EndTextCommandSetBlipName(info.blip)
            elseif not info.blip then
                return
            end
        end
    else
        return
    end
end)

-- Payment method creation

---@param amount integer
function payment(amount, type)
    local bank, cash = lib.callback.await('hx_repair:server:getPayment', false)
    print(bank, cash)
    local paymentMenu = {}
    if amount > 0 then
        if bank >= amount then
            paymentMenu[#paymentMenu+1] = {
                title = L['BANK_TITLE'],
                description = L['BANK_DESC'],
                icon = 'building-columns',
                iconColor = '#48A860',
                metadata = {
                    {label = L['AMOUNT_METADATA'], value = amount}
                },
                onSelect = function()
                    TriggerServerEvent('hx_repair:server:payment', 'bank', amount)
                    repairProgress()
                end,
            }
        elseif bank < amount then
            paymentMenu[#paymentMenu+1] = {
                title = L['BANK_TITLE'],
                description = L['NOT_ENOUGH_FUNDS_DESC'],
                icon = 'building-columns',
                iconColor = '#48A860',
                disabled = true,
                metadata = {
                    {label = L['AMOUNT_METADATA'], value = amount}
                },
                onSelect = function()
                    TriggerServerEvent('hx_repair:server:payment', 'bank', amount)
                    repairProgress()
                end,
            }
        end
        if cash >= amount then
            paymentMenu[#paymentMenu+1] = {
                title = L['CASH_TITLE'],
                description = L['CASH_DESC'],
                icon = 'wallet',
                iconColor = '#48A860',
                metadata = {
                    {label = L['AMOUNT_METADATA'], value = amount}
                },
                onSelect = function()
                    TriggerServerEvent('hx_repair:server:payment', 'cash', amount)
                    repairProgress()
                end,
            }
        elseif cash < amount then
            paymentMenu[#paymentMenu+1] = {
                title = L['CASH_TITLE'],
                description = L['NOT_ENOUGH_FUNDS_DESC'],
                icon = 'wallet',
                iconColor = '#48A860',
                disabled = true,
                metadata = {
                    {label = L['AMOUNT_METADATA'], value = amount}
                },
                onSelect = function()
                    TriggerServerEvent('hx_repair:server:payment', 'cash', amount)
                    repairProgress()
                end,
            }
        end
        if Config.EnableVehicleHealthInPayment.engine then
            if math.floor(GetVehicleEngineHealth(cache.vehicle) / 10) > 50 then
                colors.engine = 'green'
            elseif math.floor(GetVehicleEngineHealth(cache.vehicle) / 10) <= 50 then
                colors.engine = 'orange'
            elseif math.floor(GetVehicleEngineHealth(cache.vehicle) / 10) < 20 then
                colors.engine = 'red'
            end
            paymentMenu[#paymentMenu+1] = {
                title = L['ENGINE_HEALTH'],
                description = L['ENGINE_HEALTH_DESC'],
                icon = 'car',
                iconColor = '#48A860',
                progress = math.floor(GetVehicleEngineHealth(cache.vehicle) / 10),
                colorScheme = colors.engine
            }
        end
        if Config.EnableVehicleHealthInPayment.body then
            if math.floor(GetVehicleBodyHealth(cache.vehicle) / 10) > 50 then
                colors.body = 'green'
            elseif math.floor(GetVehicleBodyHealth(cache.vehicle) / 10) <= 50 then
                colors.body = 'orange'
            elseif math.floor(GetVehicleEngineHealth(cache.vehicle) / 10) < 20 then
                colors.body = 'red'
            end
            paymentMenu[#paymentMenu+1] = {
                title = L['BODY_HEALTH'],
                description = L['BODY_HEALTH_DESC'],
                icon = 'car',
                iconColor = '#48A860',
                progress = math.floor(GetVehicleBodyHealth(cache.vehicle) / 10),
                colorScheme = colors.body
            }
        end
        if cash >= amount or bank >= amount then
            lib.registerContext({
                title = L['PAYMENT_TITLE'],
                id = 'hx_repair:menus:payment',
                options = paymentMenu,
            })
            lib.showContext('hx_repair:menus:payment')
        else
            lib.notify({
                title = L['NOTI_TITLE_BAY'],
                description = L['NOT_ENOUGH_FUNDS'],
                type = 'error',
                position = 'top-center'
            })
        end
    elseif amount == 0 then
        repairVehicle(cache.vehicle)
        lib.notify({
            title = L['NOTI_TITLE_BAY'],
            description = L['VEHICLE_REPAIRED'],
            type = 'success',
            position = 'top-center'
        })
    end
end

CreateThread(function()
    if Config.RepairBayEnabled then
        for _, bay in pairs(Config.RepairBays) do
            local point = lib.points.new({
                coords = bay.location,
                distance = bay.range,
                dunak = 'repair_bay'
            })
    
            function point:nearby()
                DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 200, 20, 20, 50, false, true, 2, false, nil, nil, false)
                lib.showTextUI(L['OPEN_REPAIR_BAY'], {
                    icon = 'toolbox'
                })
    
                if self.currentDistance < bay.range and IsControlJustReleased(0, 38) then
                    local vehicle = GetVehiclePedIsIn(cache.ped, false)
                    if vehicle ~= 0 then
                        payment(bay.price)
                    elseif vehicle == 0 then
                        lib.notify({
                            title = L['NOTI_TITLE_BAY'],
                            description = L['NOTI_DESC_NIL_VEH'],
                            type = 'error',
                            position = 'top-center'
                        })
                    end
                end
            end
    
            function point:onExit()
                local _, text = lib.isTextUIOpen()
                if text == L['OPEN_REPAIR_BAY'] then
                    lib.hideTextUI()
                else
                    return
                end
            end
        end
    else
        return
    end
end)

RegisterCommand('testvehiclehealth', function()
    local engineHealth = GetVehicleEngineHealth(cache.vehicle)
    local bodyHealth = GetVehicleBodyHealth(cache.vehicle)
    print(engineHealth)
    print(('Body Health %s'):format(math.floor(bodyHealth / 10)))
end)
