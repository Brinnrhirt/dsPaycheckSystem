if Config.Framework == 'QBCore' then
    local QBCore = exports['qb-core']:GetCoreObject()
    if Config.UseFrameworkTrigger then
        RegisterNetEvent('dsPaycheckSystem:AddMoneyFramework')
        AddEventHandler('dsPaycheckSystem:AddMoneyFramework',function(xPlayer, value)
            if Player ~= nil then
                local citizenid = Player.PlayerData.citizenid
                MySQL.Async.fetchAll('SELECT `paycheck` FROM players WHERE citizenid = @citizenid', {
                    ['@citizenid'] = citizenid
                }, function(result)
                    local paycheckbd = {}
                    if result[1].paycheck ~= nil then
                        paycheckbd = json.decode(result[1].paycheck)
                    end
                MySQL.Async.fetchAll("UPDATE players SET paycheck = @paycheck WHERE citizenid = @citizenid",{
                    ['@citizenid'] = citizenid,
                    ['@paycheck'] = paycheckbd + (value)
                })
                end)
            else 
                print(('Someone is trying to do something shady. [dsPaycheckSystem]'):format(citizenid))
            end
        end)
    end


    RegisterNetEvent('dsPaycheckSystem:AddMoney')
    AddEventHandler('dsPaycheckSystem:AddMoney',function(source, value)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if Player ~= nil then
            local citizenid = Player.PlayerData.citizenid
            MySQL.Async.fetchAll('SELECT `paycheck` FROM players WHERE citizenid = @citizenid', {
                ['@citizenid'] = citizenid
            }, function(result)
                local paycheckbd = {}
                if result[1].paycheck ~= nil then
                    paycheckbd = json.decode(result[1].paycheck)
                end
            MySQL.Async.fetchAll("UPDATE players SET paycheck = @paycheck WHERE citizenid = @citizenid",{
                ['@citizenid'] = citizenid,
                ['@paycheck'] = paycheckbd + (value)
            })
            end)
        else 
            print(('Someone is trying to do something shady. [dsPaycheckSystem]'):format(citizenid))
        end
    end)


    RegisterNetEvent('dsPaycheckSystem:withdrawMoney')
    AddEventHandler('dsPaycheckSystem:withdrawMoney', function(value)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if Player ~= nil then
            local citizenid = Player.PlayerData.citizenid
            MySQL.Async.fetchAll('SELECT `paycheck` FROM players WHERE citizenid = @citizenid', {
                ['@citizenid'] = citizenid
            }, function(result)
                if result[1] then
                    local paycheckbd = {}
                    if result[1].paycheck ~= nil then
                        paycheckbd = json.decode(result[1].paycheck)
                    end
                    if paycheckbd >= value then
                        MySQL.Async.execute("UPDATE players SET paycheck = @paycheck WHERE citizenid = @citizenid",{
                            ['@citizenid'] = citizenid,
                            ['@paycheck'] = paycheckbd - value
                        })
                        if Config.ReceiveInCash == true then
                            Player.Functions.AddMoney('cash', value)
                        else
                            Player.Functions.AddMoney('bank', value)
                        end
                        TriggerClientEvent('dsPaycheckSystem:notification',src,_U("success.payout_quantity", value),'success')
                    else
                        TriggerClientEvent('dsPaycheckSystem:notification',src,_U('error.payout_quantity'),'error')
                    end
                end
            end)
        else
            print(('Someone is trying to do something shady. [dsPaycheckSystem]'):format(citizenid))
        end
    end)

    QBCore.Functions.CreateCallback('dsPaycheckSystem:server:GetDataMoney', function(source,cb)
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if Player ~= nil then
            local citizenid = Player.PlayerData.citizenid
            MySQL.Async.fetchAll("SELECT `paycheck` FROM players WHERE citizenid = @citizenid", {
                ['@citizenid'] = citizenid
            }, function(result)
                if result[1] ~= nil then
                    local paycheckdata = {}
                    if result[1].paycheck ~= nil then
                        paycheckdata = json.decode(result[1].paycheck)
                    end
                    cb(paycheckdata)
                end	
            end)
        end
    end)

    RegisterNetEvent("dsPaycheckSystem:Payout")
    AddEventHandler("dsPaycheckSystem:Payout", function()
        local src = source
        local Player  = QBCore.Functions.GetPlayer(src)
        if Player ~= nil then
            local citizenid = Player.PlayerData.citizenid
            MySQL.Async.fetchAll('SELECT `paycheck` FROM players WHERE citizenid = @citizenid', {
                ['@citizenid'] = citizenid
            }, function(result)
                    local paycheckdb = {}
                    if result[1].paycheck ~= nil then
                        paycheckdb = json.decode(result[1].paycheck)
                    end
                    if paycheckdb > 0 then
                        MySQL.Async.execute("UPDATE players SET paycheck = @paycheck WHERE citizenid = @citizenid",{
                            ['@citizenid'] = citizenid,
                            ['@paycheck'] = 0
                        })
                        if Config.ReceiveInCash == true then
                            Player.Functions.AddMoney('cash', paycheckdb)
                        else
                            Player.Functions.AddMoney('bank', paycheckdb)
                        end
                        TriggerClientEvent('dsPaycheckSystem:notification',src,_U('success.payout_all', paycheckdb),'success')
                    else
                        TriggerClientEvent('dsPaycheckSystem:notification',src,_U('error.payout_all'),'error')
                    end
            end)
        else
            print(('Someone is trying to do something shady. [dsPaycheckSystem]'):format(citizenid))
        end
    end)
end