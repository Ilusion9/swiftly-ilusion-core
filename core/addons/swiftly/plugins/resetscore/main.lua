AddEventHandler("OnPluginStart", function(p_Event)
	Resetscore_LoadConfig()
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Resetscore_LoadConfig()
end)