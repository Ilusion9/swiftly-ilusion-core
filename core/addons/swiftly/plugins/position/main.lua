AddEventHandler("OnPluginStart", function(p_Event)
	Position_LoadConfig()
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Position_LoadConfig()
end)