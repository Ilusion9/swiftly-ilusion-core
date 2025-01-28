AddEventHandler("OnPluginStart", function(p_Event)
	Spawnpoints_LoadConfig()
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Spawnpoints_LoadConfig()
end)