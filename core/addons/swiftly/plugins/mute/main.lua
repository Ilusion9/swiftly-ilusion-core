AddEventHandler("OnPluginStart", function(p_Event)
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	g_PluginIsLoading = true
	g_PluginIsLoadingLate = l_ServerTime > 0
	
	g_Database = Database("mute")
	
	Mute_LoadConfig()
	Mute_CreateDatabase()
end)

AddEventHandler("OnAllPluginsLoaded", function(p_Event)
	if g_PluginIsLoadingLate then
		for i = 0, playermanager:GetPlayerCap() - 1 do
			Mute_ResetPlayerVars(i)
			
			Mute_RemovePlayerMute(i)
			Mute_LoadPlayerMute(i)
		end
	end
	
	if g_PluginIsLoading then
		if not g_ThinkTimer then
			Mute_Think()
			g_ThinkTimer = SetTimer(THINK_INTERVAL, Mute_Think)
		end
	end
	
	g_PluginIsLoading = nil
	g_PluginIsLoadingLate = nil
end)

AddEventHandler("OnPluginStop", function(p_Event)
	for i = 0, playermanager:GetPlayerCap() - 1 do
		Mute_RemovePlayerMute(i)
	end
end)

AddEventHandler("Helpers_OnPluginStartLate", function(p_Event)
	for i = 0, playermanager:GetPlayerCap() - 1 do
		Mute_SetPlayerClanTag(i)
	end
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Mute_LoadConfig()
	
	if not g_PluginIsLoading then
		if not g_ThinkTimer then
			Mute_Think()
			g_ThinkTimer = SetTimer(THINK_INTERVAL, Mute_Think)
		end
	end
end)

AddEventHandler("OnMapUnload", function(p_Event, p_Map)
	if g_ThinkTimer then
		StopTimer(g_ThinkTimer)
		g_ThinkTimer = nil
	end
end)

AddEventHandler("OnPostPlayerConnectFull", function(p_Event)
	local l_PlayerId = p_Event:GetInt("userid")
	
	Mute_LoadPlayerMute(l_PlayerId)
end)

AddEventHandler("Helpers_OnPlayerRemoveClanTag", function(p_Event, p_PlayerId, p_Tag)
	if p_Tag ~= PLAYER_TAG then
		return EventResult.Continue
	end
	
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return EventResult.Continue
	end
	
	local l_PlayerMute = Mute_GetPlayerMute(p_PlayerId)
	
	if not l_PlayerMute or l_PlayerMute["timeleft"] == 0 then
		return EventResult.Continue
	end
	
	return EventResult.Handled
end)