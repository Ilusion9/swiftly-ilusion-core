AddEventHandler("OnPluginStart", function(p_Event)
	Help_LoadConfig()
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Help_LoadConfig()
end)