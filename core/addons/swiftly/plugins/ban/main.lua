AddEventHandler("OnPluginStart", function(p_Event)
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	g_PluginIsLoading = true
	g_PluginIsLoadingLate = l_ServerTime > 0
	
	g_Database = Database("ban")
	
	Ban_LoadConfig()
	Ban_CreateDatabase()
end)

AddEventHandler("OnAllPluginsLoaded", function(p_Event)
	if g_PluginIsLoadingLate then
		for i = 0, playermanager:GetPlayerCap() - 1 do
			Ban_LoadPlayerBan(i)
		end
	end
	
	g_PluginIsLoading = nil
	g_PluginIsLoadingLate = nil
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Ban_LoadConfig()
end)

AddEventHandler("OnPostPlayerConnectFull", function(p_Event)
	local l_PlayerId = p_Event:GetInt("userid")
	
	Ban_LoadPlayerBan(l_PlayerId)
end)