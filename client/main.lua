local paycheckdata
if Config.ESXOldVersion then
	ESX = nil
	Citizen.CreateThread(function()
		while ESX == nil do
			TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
			Citizen.Wait(0)
		end
	end)
end


if Config.Target then
	Citizen.CreateThread(function()
		local PedsTarget = {}
		for k,v in pairs (Config.NPCS) do
			PedsTarget = {v.model}
		end
		if Config.TargetSystem == 'qtarget' then
			exports['qtarget']:AddTargetModel(PedsTarget, {
				options = {
					{
						label = _U('target.collect_salary'),
						icon = "fas fa-car",
						event = "dsPaycheckSystem:Menu",
					},
					
				},
				job = {"all"},
				distance = 3.5
			})
		elseif Config.TargetSystem == 'ox_target' then
			local options = {
				label = _U('target.collect_salary'),
				icon = "fas fa-car",
				event = "dsPaycheckSystem:Menu",

			}
			exports.ox_target:addModel(PedsTarget, options)
		elseif Config.TargetSystem == 'custom' then
			-- Insert Your Custom Code Here
		end
	end)
end

if Config.DrawText then
	function DrawText3Ds(x, y, z, text)
		SetTextScale(0.35, 0.35)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextEntry("STRING")
		SetTextCentre(true)
		AddTextComponentString(text)
		SetDrawOrigin(x,y,z, 0)
		DrawText(0.0, 0.0)
		local factor = (string.len(text)) / 370
		DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
		ClearDrawOrigin()
	end
	Citizen.CreateThread(function()
		while Config.DrawText do
			Citizen.Wait(5)

			local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))

			for k, v in ipairs(Config.NPCS) do

				local dx, dy, dz = table.unpack(v.coords)
				local distance = GetDistanceBetweenCoords(x, y, z, dx, dy, dz, false)

				if distance <= 5.0 then
					DrawMarker(27, dx, dy, dz, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 1.5, 1.5, 1.0, 255, 255, 255, 100, false, true, 2, true, false, false, false)
					if distance <= 1.5 then
						DrawText3Ds(dx, dy, dz + 1, _U('drawtext.collect_salary'))
						if IsControlJustReleased(0, 38) then
							OpenPaycheckMenu()
						end
					end
				end

			end
		end
	end)
end



Citizen.CreateThread(function()
	Citizen.Wait(100)
	for k,v in pairs (Config.NPCS) do
		while not ESX do Wait(0) end
		if DoesEntityExist(ped) then
			DeletePed(ped)
		end
		Wait(250)
		ped = CreatingPed(v.model, v.coords, v.heading, v.animDict, v.animName)
	end
end)


function CreatingPed(hash, coords, heading, animDict, animName)
    RequestModel(GetHashKey(hash))
    while not HasModelLoaded(GetHashKey(hash)) do
        Wait(5)
    end

    local ped = CreatePed(5, hash, coords, false, false)
    SetEntityHeading(ped, heading)
    SetEntityAsMissionEntity(ped, true, true)
    SetPedHearingRange(ped, 0.0)
    SetPedSeeingRange(ped, 0.0)
    SetPedAlertness(ped, 0.0)
    SetPedFleeAttributes(ped, 0, 0)
	FreezeEntityPosition(ped, true) 
	SetEntityInvincible(ped, true) 
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCombatAttributes(ped, 46, true)
    SetPedFleeAttributes(ped, 0, 0)
	while not TaskPlayAnim(ped, animDict, animName, 8.0, 1.0, -1, 17, 0, 0, 0, 0) do
		Wait(1000)
	end
    return ped
end


RegisterNetEvent('dsPaycheckSystem:Menu')
AddEventHandler('dsPaycheckSystem:Menu',function()
	if Config.Menu == 'esx' then 
		OpenPaycheckMenuDefault()
	elseif Config.Menu == 'ox_lib' then
		OpenPaycheckMenuOX()
	end
end)


function OpenPaycheckMenuDefault()
	local elements = {}
	ESX.TriggerServerCallback('dsPaycheckSystem:server:GetDataMoney', function(count)
		paycheckdata = json.decode(count)
		table.insert(elements,{label = _U('menu.money_information', paycheckdata)})
		table.insert(elements,{label = _U('menu.withdraw_all'), value = 'withdraw_all'})
		if Config.WithdrawQuantity then
			table.insert(elements, {label = _U('menu.withdraw_quantity'), value = 'withdraw_quantity'})
		end
		table.insert(elements,{label = _U('menu.close_menu'), value = 'close'})
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'paycheck_actions', {
					title    = _U("menu.menu_title"),
					align    = 'center-left',
					elements = elements
				}, function(data, menu)
						if data.current.value == 'withdraw_all' then
							menu.close()
							if Config.ProgressBar == 'rprogress' then 
								exports.rprogress:Custom({
									Duration = 5000,
									Label = _U('menu.cashing_out'),
									Animation = {
										scenario = "WORLD_HUMAN_CLIPBOARD", 
										animationDictionary = "idle_a", 
									},
									DisableControls = {
										Mouse = false,
										Player = true,
										Vehicle = true
									}
								})
								Citizen.Wait(5000)
								TriggerServerEvent('dsPaycheckSystem:Payout')
							elseif Config.ProgressBar == 'ox_lib' then
								if lib.progressCircle({
									duration = 5000,
									label = _U('menu.cashing_out'),
									position = 'bottom',
									useWhileDead = false,
									canCancel = true,
									anim = {
										scenario = 'WORLD_HUMAN_CLIPBOARD'
									},
									disable = {
										move = true,
										car = true,
										combat = true
									}
								}) then
									TriggerServerEvent('dsPaycheckSystem:Payout')
								else
									TriggerEvent('dsPaycheckSystem:notification',_U('error.action_cancelled'),'error')
								end
							end
						elseif data.current.value == 'withdraw_quantity'then
							ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'withdraw_quantity_count', {
								title = _('menu.quantity_imput')
							}, function(data2, menu2)
								local count = tonumber(data2.value)
				
								if count == nil then
									TriggerEvent('dsPaycheckSystem:notification',_U('error.invalid_quantity'))
								else
									menu2.close()
									menu.close()
									if Config.ProgressBar == 'rprogress' then 
										exports.rprogress:Custom({
											Duration = 5000,
											Label = _U('menu.cashing_out'),
											Animation = {
												scenario = "WORLD_HUMAN_CLIPBOARD", 
												animationDictionary = "idle_a", 
											},
											DisableControls = {
												Mouse = false,
												Player = true,
												Vehicle = true
											}
										})
										Citizen.Wait(5000)
										TriggerServerEvent('dsPaycheckSystem:withdrawMoney', count)
									elseif Config.ProgressBar == 'ox_lib' then
										if lib.progressCircle({
											duration = 5000,
											label = _U('menu.cashing_out'),
											position = 'bottom',
											useWhileDead = false,
											canCancel = true,
											anim = {
												scenario = 'WORLD_HUMAN_CLIPBOARD'
											},
											disable = {
												move = true,
												car = true,
												combat = true
											}
										}) then
											TriggerServerEvent('dsPaycheckSystem:withdrawMoney', count)
										else
											TriggerEvent('dsPaycheckSystem:notification',_U('error.action_cancelled'),'error')
										end
									end
								end
							end)
						elseif data.current.value == 'close' then
							menu.close()
						end
		end, function(data, menu)
			menu.close()
		end)
	end)
end


function OpenPaycheckMenuOX() 
	ESX.TriggerServerCallback('dsPaycheckSystem:server:GetDataMoney', function(count)
		paycheckdata = json.decode(count) 
		lib.registerContext({
			id = 'paycheckMenu',
			title = 'Paycheck Menu',
			options = {
				{
					title = _U('menu.money_information', paycheckdata),
				},
				{
					title = _U('menu.withdraw_all'),
					description = _U('menu.withdraw_all_desc'),
					icon = 'circle',
					onSelect = function()
						if Config.ProgressBar == 'rprogress' then 
							exports.rprogress:Custom({
								Duration = 5000,
								Label = _U('menu.cashing_out'),
								Animation = {
									scenario = "WORLD_HUMAN_CLIPBOARD", 
									animationDictionary = "idle_a", 
								},
								DisableControls = {
									Mouse = false,
									Player = true,
									Vehicle = true
								}
							})
							Citizen.Wait(5000)
							TriggerServerEvent('dsPaycheckSystem:Payout')
						elseif Config.ProgressBar == 'ox_lib' then
							if lib.progressCircle({
								duration = 5000,
								label = _U('menu.cashing_out'),
								position = 'bottom',
								useWhileDead = false,
								canCancel = true,
								anim = {
									scenario = 'WORLD_HUMAN_CLIPBOARD'
								},
								disable = {
									move = true,
									car = true,
									combat = true
								}
							}) then
								TriggerServerEvent('dsPaycheckSystem:Payout')
							else
								TriggerEvent('dsPaycheckSystem:notification',_U('error.action_cancelled'),'error')
							end
						end
					end,
				},
				{
					title = _U('menu.withdraw_quantity'),
					description = _U('menu.withdraw_quantity_desc'),
					icon = 'circle',
					onSelect = function()
						local input = lib.inputDialog('payCheckAmount', _U('quantity_imput'))
						if not input then return end
						print(json.encode(input), input[1])
						if Config.ProgressBar == 'rprogress' then 
							exports.rprogress:Custom({
								Duration = 5000,
								Label = _U('menu.cashing_out'),
								Animation = {
									scenario = "WORLD_HUMAN_CLIPBOARD", 
									animationDictionary = "idle_a", 
								},
								DisableControls = {
									Mouse = false,
									Player = true,
									Vehicle = true
								}
							})
							Citizen.Wait(5000)
							TriggerServerEvent('dsPaycheckSystem:withdrawMoney', count)
						elseif Config.ProgressBar == 'ox_lib' then
							if lib.progressCircle({
								duration = 5000,
								label = _U('menu.cashing_out'),
								position = 'bottom',
								useWhileDead = false,
								canCancel = true,
								anim = {
									scenario = 'WORLD_HUMAN_CLIPBOARD'
								},
								disable = {
									move = true,
									car = true,
									combat = true
								}
							}) then
								TriggerServerEvent('dsPaycheckSystem:withdrawMoney', count)
							else
								TriggerEvent('dsPaycheckSystem:notification',_U('error.action_cancelled'),'error')
							end
						end
					end,
				},
			}
		})
	end)
	lib.showContext('paycheckMenu')
end
