AddEventHandler("OnPluginStart", function(p_Event)
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	g_PluginIsLoading = true
	g_PluginIsLoadingLate = l_ServerTime > 0
	
	Server_LoadConfig()
end)

AddEventHandler("OnAllPluginsLoaded", function(p_Event)
	if g_PluginIsLoadingLate then
		Server_SetConVars()
	end
	
	g_PluginIsLoading = nil
	g_PluginIsLoadingLate = nil
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Server_LoadConfig()
	
	SetTimeout(100, function()
		Server_SetConVars()
	end)
end)