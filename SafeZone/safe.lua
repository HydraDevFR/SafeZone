local zones = {

	['20'] = { ['x'] = -490.27, ['y'] = -697.63, ['z'] = 33.24}, -- Spawn


	['46'] = { ['x'] = 447.452, ['y'] = -992.327, ['z'] = 24.420}, -- Comico


	['50'] = { ['x'] = 299.89, ['y'] = -585.14, ['z'] = 43.29}, -- Devant hopital
	

	['30'] = { ['x'] = -796.32, ['y'] = -223.28, ['z'] = 37.07}, -- Concess


}

ESX = nil
local notifIn = false
local notifOut = false
local veh = false
local closestZone = 1
local distance = 0
local safe = false
local PlayerData = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData() == nil do
		Citizen.Wait(10)
	end
	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)


Citizen.CreateThread(function()
	while true do
		local playerPed = GetPlayerPed(-1)
		local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
		local minDistance = 100000
		for k,v in pairs(zones) do
			dist = Vdist(zones[k].x, zones[k].y, zones[k].z, x, y, z)
			if dist < minDistance then

				minDistance = dist

				closestZone = k

				distance = tonumber(k)

			end

		end

		local vehs = GetVehiclePedIsUsing(GetPlayerPed(PlayerId()), false)
		if (GetPedInVehicleSeat(vehs, -1) == GetPlayerPed(PlayerId())) and veh == false then	
		SetEntityInvincible(vehs, false)
		elseif (GetPedInVehicleSeat(vehs, -1) == GetPlayerPed(PlayerId())) and veh == true then
		SetEntityInvincible(vehs, true)

		end

		Citizen.Wait(10000)

	end

end)



Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		local player = GetPlayerPed(-1)
		local x,y,z = table.unpack(GetEntityCoords(player, true))
		local dist = Vdist(zones[closestZone].x, zones[closestZone].y, zones[closestZone].z, x, y, z)


    if PlayerData.job ~= nil and PlayerData.job.name == 'fbi' or PlayerData.job.name == 'police' or PlayerData.job.name == 'sheriff' then
		if dist <= distance then

			if not notifOut then
				veh = false
				local vehs = GetVehiclePedIsUsing(GetPlayerPed(PlayerId()), false)
				if (GetPedInVehicleSeat(vehs, -1) == GetPlayerPed(PlayerId())) then	
				SetEntityInvincible(vehs, false)
				end
				safe = false
				SetEntityInvincible(player, false)
				NetworkSetFriendlyFireOption(true)
                ESX.ShowNotification("Vous êtes immuniser avec votre métier contre la ~g~Zone Safe")
				notifOut = true
				notifIn = false

			end
			
			else
			
			if not notifIn then	
				veh = false
				local vehs = GetVehiclePedIsUsing(GetPlayerPed(PlayerId()), false)
				if (GetPedInVehicleSeat(vehs, -1) == GetPlayerPed(PlayerId())) then	
				SetEntityInvincible(vehs, false)
				end
				safe = false
				SetEntityInvincible(player, false)
				NetworkSetFriendlyFireOption(true)
				ESX.ShowNotification("Vous n'êtes plus en ~g~Zone Safe.")
				notifIn = true
				notifOut = false

			end

		end


		else
		if dist <= distance then

			if not notifIn then	
				veh = true				
				local vehs = GetVehiclePedIsUsing(GetPlayerPed(PlayerId()), false)
				if (GetPedInVehicleSeat(vehs, -1) == GetPlayerPed(PlayerId())) then	
				SetEntityInvincible(vehs, true)
				end
				safe = true
				SetEntityInvincible(player, true)												  
				NetworkSetFriendlyFireOption(false)
				SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
				ESX.ShowNotification("Vous êtes dans une ~g~Zone Safe.")
				ESX.ShowNotification("Vos armes sont ~r~bloquées")
				notifIn = true
				notifOut = false

			end

		else

			if not notifOut then
				veh = false
				local vehs = GetVehiclePedIsUsing(GetPlayerPed(PlayerId()), false)
				if (GetPedInVehicleSeat(vehs, -1) == GetPlayerPed(PlayerId())) then	
				SetEntityInvincible(vehs, false)
				end
				safe = false
				SetEntityInvincible(player, false)
				NetworkSetFriendlyFireOption(true)
                ESX.ShowNotification("Vous n\'êtes plus en ~g~Zone Safe.")
				ESX.ShowNotification("Vos armes sont ~r~débloquées")
				notifOut = true
				notifIn = false

			end

		end

		if notifIn then
		DisableControlAction(2, 37, true)
		DisablePlayerFiring(player, true)
		DisableControlAction(0, 106, true)
		DisableControlAction(0, 140, true)
			if IsDisabledControlJustPressed(2, 37) then
				SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
			end
			if IsDisabledControlJustPressed(0, 106) then
				SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
			end

		end
		end

	end

end)

AddEventHandler('safe:Check', function(cb)
cb(safe)
end)
