ESX = exports["es_extended"]:getSharedObject()

---@param source integer
lib.callback.register('hx_repair:server:getPayment', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local cash = exports.ox_inventory:GetItemCount(source, Config.MoneyItem)
    local bank = xPlayer.getAccount('bank')
    return bank.money, cash
end)

---@param paymentMethod string
---@param amount integer
---@return boolean
RegisterNetEvent('hx_repair:server:payment', function(paymentMethod, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local bank = xPlayer.getAccount('bank')
    if paymentMethod == 'cash' then
        if exports.ox_inventory:GetItemCount(source, Config.MoneyItem) < amount then
            DropPlayer(source, 'Attempted to repair vehicle with exploits')
            return false
        elseif exports.ox_inventory:GetItemCount(source, Config.MoneyItem) >= amount then
            exports.ox_inventory:RemoveItem(source, Config.MoneyItem, amount)
            return true
        end
    elseif paymentMethod == 'bank' then
        if bank.money < amount then
            DropPlayer(source, 'Attempted to repair vehicle with exploits')
            return false
        elseif bank.money >= amount then
            xPlayer.removeAccountMoney('bank', amount)
            return true
        end
    end
end)