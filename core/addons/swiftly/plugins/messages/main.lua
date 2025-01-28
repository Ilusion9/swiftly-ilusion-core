AddEventHandler("OnPluginStart", function(p_Event)
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	g_PluginIsLoading = true
	g_PluginIsLoadingLate = l_ServerTime > 0
	
	Messages_LoadConfig()
end)

AddEventHandler("OnAllPluginsLoaded", function(p_Event)
	if g_PluginIsLoadingLate then
		for i = 0, playermanager:GetPlayerCap() - 1 do
			Messages_ResetPlayerVars(i)
			Messages_SetPlayerConnectionTime(i)
		end
	end
	
	if g_PluginIsLoading then
		if not g_ThinkTimer then
			Messages_Think()
			g_ThinkTimer = SetTimer(THINK_INTERVAL, Messages_Think)
		end
	end
	
	g_PluginIsLoading = nil
	g_PluginIsLoadingLate = nil
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Messages_LoadConfig()
	
	if not g_PluginIsLoading then
		if not g_ThinkTimer then
			Messages_Think()
			g_ThinkTimer = SetTimer(THINK_INTERVAL, Messages_Think)
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
	
	Messages_SetPlayerConnectionTime(l_PlayerId)
end)