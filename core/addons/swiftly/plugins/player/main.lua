AddEventHandler("OnPluginStart", function(p_Event)
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	g_PluginIsLoading = true
	g_PluginIsLoadingLate = l_ServerTime > 0
	
	Player_LoadConfig()
	Player_LoadHistory()
end)

AddEventHandler("OnAllPluginsLoaded", function(p_Event)
	if g_PluginIsLoadingLate then
		for i = 0, playermanager:GetPlayerCap() - 1 do
			Player_ResetPlayerVars(i)
		end
	end
	
	g_PluginIsLoading = nil
	g_PluginIsLoadingLate = nil
end)

AddEventHandler("OnPluginStop", function(p_Event)
	Player_SaveHistory()
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Player_LoadConfig()
	Player_LoadHistory()
end)

AddEventHandler("OnMapUnload", function(p_Event, p_Map)
	Player_SaveHistory()
end)

AddEventHandler("OnPlayerDisconnect", function(p_Event)
	local l_PlayerId = p_Event:GetInt("userid")
	
	Player_AddPlayerInHistory(l_PlayerId)
end)