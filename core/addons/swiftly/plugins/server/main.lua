AddEventHandler("OnPluginStart", function(p_Event)
	Server_LoadConfig()
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Server_LoadConfig()
end)