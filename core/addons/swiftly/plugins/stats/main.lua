AddEventHandler("OnPluginStart", function(p_Event)
	g_Database = Database("stats")
	
	Stats_LoadConfig()
	Stats_CreateDatabase()
end)

AddEventHandler("OnPluginStop", function(p_Event)
	Stats_SaveStats()
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Stats_LoadConfig()
	Stats_DeleteOldStats()
end)

AddEventHandler("OnClientDisconnect", function(p_Event, p_PlayerId)
	Stats_SavePlayerStats(p_PlayerId)
end)