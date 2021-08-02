ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

    ESXLoaded = true
end)


Citizen.CreateThread(function()
	local PedsTarget = {}
	for k,v in pairs (Config.NPCS) do
		PedsTarget = {v.model}
	end
	exports['qtarget']:AddTargetModel(PedsTarget, {
		options = {
			{
				event = "brinn_paycheck:Menu",
				icon = "fas fa-car",
				label = "Collect salary",
			},
			
		},
		job = {"all"},
		distance = 3.5
	})
end)




Citizen.CreateThread(function()
	Citizen.Wait(100)
	for k,v in pairs (Config.NPCS) do
		while not ESXLoaded do Wait(0) end
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


RegisterNetEvent('brinn_paycheck:Menu')
AddEventHandler('brinn_paycheck:Menu',function()
	OpenPaycheckMenu()
end)


function OpenPaycheckMenu()
	local elements = {
		{label = '&nbsp;&nbsp;<span style="color:#13ea13 ;"> Withdraw All </span>', value = 'withdraw_all'},
		{label = '&nbsp;&nbsp;<span style="color:#13ea13 ;"> Withdraw an amount </span>', value = 'withdraw_quantity'},
		{label = '&nbsp;&nbsp;<span style="color:#EA1313;"> Close</span>' , value = 'Salir'},
	}
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'paycheck_actions', {
				title    = 'City Hall',
				align    = 'top-left',
				elements = elements
			}, function(data, menu)
					if data.current.value == 'withdraw_all' then
						exports.rprogress:Custom({
							Duration = 5000,
							Label = "Cashing out...",
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
						TriggerServerEvent('brinn_paycheck:Payout')
						menu.close()
					elseif data.current.value == 'withdraw_quantity'then
						ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'withdraw_quantity_count', {
							title = 'Quantity'
						}, function(data2, menu2)
							local count = tonumber(data2.value)
			
							if count == nil then
								ESX.ShowNotification('Invalid Quantity')
							else
								menu2.close()
								menu.close()
								exports.rprogress:Custom({
									Duration = 5000,
									Label = "Cashing out...",
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
								TriggerServerEvent('brinn_paycheck:withdrawMoney', count)
							end
						end)
					elseif data.current.value == 'Salir' then
						menu.close()
					end
	end, function(data, menu)
		menu.close()
	end)
end
