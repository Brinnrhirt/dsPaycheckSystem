if Config.Framework == 'ESX' then
	if Config.ESXOldVersion then
		ESX	= nil
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	end

	if Config.UseFrameworkTrigger then
		RegisterNetEvent('dsPaycheckSystem:AddMoneyFramework')
		AddEventHandler('dsPaycheckSystem:AddMoneyFramework',function(xPlayer, value)
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
				print(('Someone is trying to do something shady. [dsPaycheckSystem]'):format(xPlayer.identifier))
			end
		end)
	end


	RegisterNetEvent('dsPaycheckSystem:AddMoney')
	AddEventHandler('dsPaycheckSystem:AddMoney',function(source, value)
		local src = source
		local xPlayer = ESX.GetPlayerFromId(src)
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
			print(('Someone is trying to do something shady. [dsPaycheckSystem]'):format(xPlayer.identifier))
		end
	end)


	RegisterNetEvent('dsPaycheckSystem:withdrawMoney')
	AddEventHandler('dsPaycheckSystem:withdrawMoney', function(value)
		local src = source
		local xPlayer = ESX.GetPlayerFromId(src)
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
						TriggerClientEvent('dsPaycheckSystem:notification',src,_U("success.payout_quantity", value),'success')
					else
						TriggerClientEvent('dsPaycheckSystem:notification',src,_U('error.payout_quantity'),'error')
					end
				end
			end)
		else
			print(('Someone is trying to do something shady. [dsPaycheckSystem]'):format(xPlayer.identifier))
		end
	end)

	ESX.RegisterServerCallback('dsPaycheckSystem:server:GetDataMoney', function(source,cb)
		local src = source
		local xPlayer = ESX.GetPlayerFromId(src)
		if xPlayer ~= nil then
			MySQL.Async.fetchAll("SELECT `paycheck` FROM users WHERE identifier = @identifier", {
				['@identifier'] = xPlayer.identifier
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
		local xPlayer  = ESX.GetPlayerFromId(src)
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
						TriggerClientEvent('dsPaycheckSystem:notification',src,_U('success.payout_all', paycheckdb),'success')
					else
						TriggerClientEvent('dsPaycheckSystem:notification',src,_U('error.payout_all'),'error')
					end
			end)
		else
			print(('Someone is trying to do something shady. [dsPaycheckSystem]'):format(xPlayer.identifier))
		end
	end)
end