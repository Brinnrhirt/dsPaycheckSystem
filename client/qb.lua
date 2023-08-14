local paycheckdata
Peds = {}
if Config.Framework == 'QBCore' then
	local QBCore = exports['qb-core']:GetCoreObject()


	if Config.Target then
		Citizen.CreateThread(function()
			local PedsTarget = {}
			for k,v in pairs (Config.NPCS) do
				PedsTarget = {v.model}
			end
			if Config.TargetSystem == 'qb-target' then
				exports['qb-target']:AddTargetModel(PedsTarget, {
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
								TriggerEvent("dsPaycheckSystem:Menu")
							end
						end
					end

				end
			end
		end)
	end



	Citizen.CreateThread(function()
		Citizen.Wait(100)
		GeneratePeds()
	end)

	function GeneratePeds()
		while not QBCore do Wait(0) end
		for k, v in ipairs(Config.NPCS) do
			v = Config.NPCS[k]
			print(k)
			if DoesEntityExist(Peds[k]) then
				DeletePed(Peds[k])
			end
			Wait(250)
			RequestModel(GetHashKey(v.model))
			while not HasModelLoaded(GetHashKey(v.model)) do
				Wait(5)
			end
			Peds[k] = CreatePed(5, v.model, v.coords, false, false)
			SetEntityHeading(Peds[k], v.heading)
			SetEntityAsMissionEntity(Peds[k], true, true)
			SetPedHearingRange(Peds[k], 0.0)
			SetPedSeeingRange(Peds[k], 0.0)
			SetPedAlertness(Peds[k], 0.0)
			SetPedFleeAttributes(Peds[k], 0, 0)
			FreezeEntityPosition(Peds[k], true) 
			SetEntityInvincible(Peds[k], true) 
			SetBlockingOfNonTemporaryEvents(Peds[k], true)
			SetPedCombatAttributes(Peds[k], 46, true)
			SetPedFleeAttributes(Peds[k], 0, 0)
			while not TaskPlayAnim(Peds[k], v.animDict, v.animName, 8.0, 1.0, -1, 17, 0, 0, 0, 0) do
				Wait(1000)
			end
		end
	end


	RegisterNetEvent('dsPaycheckSystem:Menu')
	AddEventHandler('dsPaycheckSystem:Menu',function()
		if Config.Menu == 'qb' then 
			OpenPaycheckMenuQBDefault()
		elseif Config.Menu == 'ox_lib' then
			OpenPaycheckMenuOX()
		end
	end)


	function OpenPaycheckMenuQBDefault()
		local elements = {}
		
		QBCore.Functions.TriggerCallback('dsPaycheckSystem:server:GetDataMoney', function(count)
			paycheckdata = json.decode(count) 
			exports['qb-menu']:openMenu({
                {
                    header = _U('menu.money_information', paycheckdata),
                    icon = 'fas fa-money',
                    isMenuHeader = true, -- Set to true to make a nonclickable title
                },
                {
                    header = _U('menu.withdraw_all'),
                    txt = _U('menu.withdraw_all_desc'),
                    icon = 'fas fa-money',
                    params = {
                        event = 'dsPaycheckSystem:PayoutMenu',
                        args = {
                            type = true
                        }
                    }
                },
                {
                    header = _U('menu.withdraw_quantity'),
                    txt = _U('menu.withdraw_quantity_desc'),
                    icon = 'fas fa-money',
					hidden = not Config.WithdrawQuantity,
                    params = {
                        event = 'dsPaycheckSystem:PayoutMenu',
                        args = {
                             type = false
                        }
                    }
                }, 
            })
		end)
	end


	function OpenPaycheckMenuOX() 
		QBCore.Functions.TriggerCallback('dsPaycheckSystem:server:GetDataMoney', function(count)
			paycheckdata = json.decode(count) 
			lib.registerContext({
				id = 'paycheckMenuSystem',
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
							elseif Config.ProgressBar == 'qb' then
								QBCore.Functions.Progressbar("dsPaycheckSystem", _U('menu.cashing_out'), 5000, false, true, {
									disableMovement = true,
									disableCarMovement = false,
									disableMouse = false,
									disableCombat = true,
								 }, {
									animDict = "WORLD_HUMAN_CLIPBOARD",
									anim = "idle_a",
									flags = 49,
								 }, {}, {}, function() -- Done
									TriggerServerEvent('dsPaycheckSystem:Payout')
								 end, function() -- Cancel
								 end)
							end
						end,
					},
                    {
						title = _U('menu.withdraw_quantity'),
						description = _U('menu.withdraw_quantity_desc'),
						icon = 'circle',
						disabled = not Config.WithdrawQuantity,
						onSelect = function()
							local input = lib.inputDialog(_U('menu.quantity_imput'), {_U('menu.withdraw_quantity')})
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
								TriggerServerEvent('dsPaycheckSystem:withdrawMoney', tonumber(input[1]))
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
									TriggerServerEvent('dsPaycheckSystem:withdrawMoney', tonumber(input[1]))
								else
									TriggerEvent('dsPaycheckSystem:notification',_U('error.action_cancelled'),'error')
								end
							elseif Config.ProgressBar == 'qb' then
								QBCore.Functions.Progressbar("dsPaycheckSystem", _U('menu.cashing_out'), 5000, false, true, {
									disableMovement = true,
									disableCarMovement = false,
									disableMouse = false,
									disableCombat = true,
								 }, {
									animDict = "WORLD_HUMAN_CLIPBOARD",
									anim = "idle_a",
									flags = 49,
								 }, {}, {}, function() -- Done
									TriggerServerEvent('dsPaycheckSystem:withdrawMoney', tonumber(input[1]))
								 end, function() -- Cancel
								 end)
							end
						end,
					},
				}
			})
		lib.showContext('paycheckMenuSystem')
		end)
	end

    RegisterNetEvent('dsPaycheckSystem:PayoutMenu')
	AddEventHandler('dsPaycheckSystem:PayoutMenu',function(data)
		local option = data.type
        if option then
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
			elseif Config.ProgressBar == 'qb' then
				QBCore.Functions.Progressbar("dsPaycheckSystem", _U('menu.cashing_out'), 5000, false, true, {
					disableMovement = true,
					disableCarMovement = false,
					disableMouse = false,
					disableCombat = true,
				 }, {
					animDict = "WORLD_HUMAN_CLIPBOARD",
					anim = "idle_a",
					flags = 49,
				 }, {}, {}, function() -- Done
					TriggerServerEvent('dsPaycheckSystem:Payout')
				 end, function() -- Cancel
				 end)
			end
        else
            local count = exports['qb-input']:ShowInput({
                header = _U('menu.withdraw_quantity'),
                submitText = "OK",
                inputs = {
                    {
                        text = _U('menu.quantity_imput'), -- text you want to be displayed as a place holder
						name = 'quantity',
                        type = "number", -- type of the input
                        isRequired = true, -- Optional [accepted values: true | false] but will submit the form if no value is inputted
                    },
                }
            })
            if count ~= nil then
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
					TriggerServerEvent('dsPaycheckSystem:withdrawMoney', tonumber(count.quantity))
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
						TriggerServerEvent('dsPaycheckSystem:withdrawMoney', tonumber(count.quantity))
					else
						TriggerEvent('dsPaycheckSystem:notification',_U('error.action_cancelled'),'error')
					end 
				elseif Config.ProgressBar == 'qb' then
					QBCore.Functions.Progressbar("dsPaycheckSystem", _U('menu.cashing_out'), 5000, false, true, {
						disableMovement = true,
						disableCarMovement = false,
						disableMouse = false,
						disableCombat = true,
					 }, {
						animDict = "WORLD_HUMAN_CLIPBOARD",
						anim = "idle_a",
						flags = 49,
					 }, {}, {}, function() -- Done
						print()
						TriggerServerEvent('dsPaycheckSystem:withdrawMoney', tonumber(count.quantity))
					 end, function() -- Cancel
					 end)
				end
            end
        end
	end)
end 