AddEventHandler("OnPluginStart", function(p_Event)
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	g_PluginIsLoading = true
	g_PluginIsLoadingLate = l_ServerTime > 0
	
	Update_ResetVars()
	
	Update_LoadConfig()
	Update_LoadVersion()
end)

AddEventHandler("OnAllPluginsLoaded", function(p_Event)
	if g_PluginIsLoading then
		if not g_ThinkTimer then
			Update_Think()
			g_ThinkTimer = SetTimer(THINK_INTERVAL, Update_Think)
		end
	end
	
	g_PluginIsLoading = nil
	g_PluginIsLoadingLate = nil
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Update_ResetVars()
	
	Update_LoadConfig()
	Update_LoadVersion()
	
	if not g_PluginIsLoading then
		if not g_ThinkTimer then
			Update_Think()
			g_ThinkTimer = SetTimer(THINK_INTERVAL, Update_Think)
		end
	end
end)

AddEventHandler("OnMapUnload", function(p_Event, p_Map)
	if g_ThinkTimer then
		StopTimer(g_ThinkTimer)
		g_ThinkTimer = nil
	end
end)