ESX		= nil


TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('brinn_paycheck:AddMoney')
AddEventHandler('brinn_paycheck:AddMoney',function(value)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer ~= nil then
		MySQL.Async.fetchAll('SELECT `paycheck` FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		}, function(result)
			local paycheckbd = {}
			if result[1].paycheck ~= nil then
				paycheckbd = json.decode(result[1].paycheck)
			end
		MySQL.Async.fetchAll("UPDATE users SET paycheck = @paycheck WHERE identifier = @identifier",{
			['@identifier'] = xPlayer.identifier,
			['@paycheck'] = paycheckbd + (value)
		})
		end)
	else 
		print(('Someone is trying to do something shady. [BRINN_PAYCHECK]'):format(xPlayer.identifier))
	end
end)


RegisterNetEvent('brinn_paycheck:withdrawMoney')
AddEventHandler('brinn_paycheck:withdrawMoney', function(value)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer ~= nil then
		MySQL.Async.fetchAll('SELECT `paycheck` FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		}, function(result)
			if result[1] then
				local paycheckbd = {}
				if result[1].paycheck ~= nil then
					paycheckbd = json.decode(result[1].paycheck)
				end
				print(value)
				if paycheckbd >= value then
					MySQL.Async.execute("UPDATE users SET paycheck = @paycheck WHERE identifier = @identifier",{
						['@identifier'] = xPlayer.identifier,
						['@paycheck'] = paycheckbd - value
					})
					if Config.ReceiveInCash == true then
						xPlayer.addMoney(value)
					else
						xPlayer.addAccountMoney('bank', value)
					end
					local msg1 = 'You recollect '..value..'$'
					local type = 'success'
					TriggerClientEvent('brinn_paycheck:notification',_source,msg1,type)
				else
					local msg2 = 'You dont have enough money to collect that.'
					local type2 = 'error'
					TriggerClientEvent('brinn_paycheck:notification',_source,msg2,type2)
				end
			end
		end)
	else
		print(('Someone is trying to do something shady. [BRINN_PAYCHECK]'):format(xPlayer.identifier))
	end
end)


 RegisterNetEvent("brinn_paycheck:Payout")
 AddEventHandler("brinn_paycheck:Payout", function()
	local _source = source
    local xPlayer  = ESX.GetPlayerFromId(_source)
	if xPlayer ~= nil then
		MySQL.Async.fetchAll('SELECT `paycheck` FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		}, function(result)
				local paycheckbd = {}
				if result[1].paycheck ~= nil then
					paycheckbd = json.decode(result[1].paycheck)
				end
				if paycheckbd > 0 then
					MySQL.Async.execute("UPDATE users SET paycheck = @paycheck WHERE identifier = @identifier",{
						['@identifier'] = xPlayer.identifier,
						['@paycheck'] = 0
					})
					if Config.ReceiveInCash == true then
						xPlayer.addMoney(paycheckbd)
					else
						xPlayer.addAccountMoney('bank', paycheckbd)
					end
					local msg3 = 'All your paycheck its '..paycheckbd..'$'
					local type3 = 'success'
					TriggerClientEvent('brinn_paycheck:notification',_source,msg3,type3)
				else
					local msg4 = 'You dont have anything to collect.'
					local type4 = 'error'
					TriggerClientEvent('brinn_paycheck:notification',_source,msg4,type4)
				end
		end)
	else
		print(('Someone is trying to do something shady. [BRINN_PAYCHECK]'):format(xPlayer.identifier))
	end
end)