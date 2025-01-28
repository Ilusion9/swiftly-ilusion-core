AddEventHandler("OnPluginStart", function(p_Event)
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	g_PluginIsLoading = true
	g_PluginIsLoadingLate = l_ServerTime > 0
	
	Zones_ResetVars()
	Zones_LoadConfig()
end)

AddEventHandler("OnAllPluginsLoaded", function(p_Event)
	if g_PluginIsLoadingLate then
		for i = 0, playermanager:GetPlayerCap() - 1 do
			Zones_ResetPlayerVars(i)
		end
		
		Zones_CreateZones()
	end
	
	g_PluginIsLoading = nil
	g_PluginIsLoadingLate = nil
end)

AddEventHandler("OnPluginStop", function(p_Event)
	Zones_RemoveZones()
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Zones_ResetVars()
	Zones_LoadConfig()
end)

AddEventHandler("OnPostRoundStart", function(p_Event)
	Zones_CreateZones()
end)

AddEventHandler("OnPlayerPostThink", function(p_Event, p_PlayerId)
	Zones_CheckPlayerTouchZones(p_PlayerId)
end)

AddEventHandler("OnPlayerDisconnect", function(p_Event)
	local l_PlayerId = p_Event:GetInt("userid")
	
	Zones_RemovePlayerZone(l_PlayerId)
end)

AddEventHandler("OnPostPlayerSpawn", function(p_Event)
	local l_PlayerId = p_Event:GetInt("userid")
	local l_Player = GetPlayer(l_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	l_Player:SetVar("zones.touch.zones", nil)
end)

AddEventHandler("OnPostPlayerDeath", function(p_Event)
	local l_PlayerId = p_Event:GetInt("userid")
	local l_Player = GetPlayer(l_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	l_Player:SetVar("zones.touch.zones", nil)
end)