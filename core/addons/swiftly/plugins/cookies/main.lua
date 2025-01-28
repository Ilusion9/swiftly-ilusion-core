AddEventHandler("OnPluginStart", function(p_Event)
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	g_PluginIsLoading = true
	g_PluginIsLoadingLate = l_ServerTime > 0
	
	g_Database = Database("cookies")
	
	g_GetCookies = {}
	g_SetCookies = {}
	
	Cookies_LoadConfig()
	Cookies_CreateDatabase()
end)

AddEventHandler("OnAllPluginsLoaded", function(p_Event)
	if g_PluginIsLoadingLate then
		Cookies_GetCookies()
	end
	
	g_PluginIsLoading = nil
	g_PluginIsLoadingLate = nil
end)

AddEventHandler("OnPluginStop", function(p_Event)
	Cookies_SetCookies()
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Cookies_LoadConfig()
	Cookies_DeleteOldCookies()
end)

AddEventHandler("OnClientDisconnect", function(p_Event, p_PlayerId)
	Cookies_SetPlayerCookies(p_PlayerId)
end)

AddEventHandler("OnPostPlayerConnectFull", function(p_Event)
	local l_PlayerId = p_Event:GetInt("userid")
	
	Cookies_GetPlayerCookies(l_PlayerId)
end)