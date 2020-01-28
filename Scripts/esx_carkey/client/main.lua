ESX         = nil
local mycar = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx_carkey:keyuse')
AddEventHandler('esx_carkey:keyuse', function()
	local playerPed = PlayerPedId()
	local vehicle   = ESX.Game.GetVehicleInDirection()
	if not vehicle then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	end
	if vehicle ~= 0 then
		local vehdata = ESX.Game.GetVehicleProperties(vehicle)
		local found = false
		for i=1, #mycar, 1 do
			if mycar[i] == vehdata.plate then
				found = true
			end
		end
		if found then
			togglecarlock(vehicle)
		elseif not found and GetPedInVehicleSeat(vehicle, -1) == playerPed then
			table.insert(mycar,vehdata.plate)
			--ESX.ShowNotification(_U('vehicle_register'))
			exports['mythic_notify']:SendAlert('success', 'Vehicle succesfully rented!', 5000)
		elseif not found and GetPedInVehicleSeat(vehicle) == playerPed then
			--ESX.ShowNotification(_U('not_driver'))
			exports['mythic_notify']:SendAlert('error', 'You are not the rentee of this vehicle!', 5000)
			return
		else
			ESX.TriggerServerCallback('esx_carkey:ismycar', function (ismycar)
				if ismycar then
					togglecarlock(vehicle)
					table.insert(mycar, vehdata.plate)
				else
					--ESX.ShowNotification(_U('not_your_car'))
					exports['mythic_notify']:SendAlert('error', 'This vehicle is not yours!', 5000)
				end
			end, vehdata.plate)
		end
	else
		--ESX.ShowNotification(_U('no_proximity_car'))
		exports['mythic_notify']:SendAlert('error', 'There is no vehicle nearby!', 5000)
	end
end)

function togglecarlock(vehicle)
	local playerPed = PlayerPedId()
	local lockstate = GetVehicleDoorLockStatus(vehicle)
	local incar = GetVehiclePedIsIn(playerPed, false)
	if lockstate ~= 1 then
		if incar == 0 then
			loadAnimDict('anim@mp_player_intmenu@key_fob@')
			TaskPlayAnim(playerPed, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0, -8, -1, 49, 0, 0, 0, 0)
			SetVehicleDoorsLocked(vehicle, 1)
			SetVehicleDoorsLockedForAllPlayers(vehicle, false)
			Wait(1000)
			SetVehicleDoorsLocked(vehicle, 1)
			SetVehicleDoorsLockedForAllPlayers(vehicle, false)
			ClearPedTasksImmediately(playerPed)
			--ESX.ShowNotification(_U('connect_to_car'))
			exports['mythic_notify']:SendAlert('success', 'Connecting your vehicle..', 5000)
			Wait(3000)
		end
		SetVehicleDoorsLocked(vehicle, 1)
		SetVehicleDoorsLockedForAllPlayers(vehicle, false)
		TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 10, "unlock", 1.0)
		--ESX.ShowNotification(_U('doors_unlock'))
		exports['mythic_notify']:SendAlert('success', 'Doors unlocked', 5000)
	else
		if incar == 0 then
			loadAnimDict('anim@mp_player_intmenu@key_fob@')
			TaskPlayAnim(playerPed, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 8.0, -8, -1, 49, 0, 0, 0, 0)
			Wait(1000)	
			ClearPedTasksImmediately(playerPed)
		end
		SetVehicleDoorsLocked(vehicle, 2)
		SetVehicleDoorsLockedForAllPlayers(vehicle, true)
		TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 10, "lock", 1.0)
		--ESX.ShowNotification(_U('doors_lock'))
		exports['mythic_notify']:SendAlert('success', 'Doors locked', 5000)
	end
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(0)
    end
end

RegisterNetEvent('InteractSound_CL:PlayWithinDistance')
AddEventHandler('InteractSound_CL:PlayWithinDistance', function(playerNetId, maxDistance, soundFile, soundVolume)
    local lCoords = GetEntityCoords(GetPlayerPed(-1))
    local eCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerNetId)))
    local distIs  = Vdist(lCoords.x, lCoords.y, lCoords.z, eCoords.x, eCoords.y, eCoords.z)
    if(distIs <= maxDistance) then
        SendNUIMessage({
            transactionType     = 'playSound',
            transactionFile     = soundFile,
            transactionVolume   = soundVolume
        })
    end
end)