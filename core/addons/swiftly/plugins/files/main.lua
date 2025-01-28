AddEventHandler("OnPluginStart", function(p_Event)
	Files_LoadConfig()
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Files_LoadConfig()
end)