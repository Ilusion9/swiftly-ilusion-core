AddEventHandler("OnPluginStart", function(p_Event)
	Admin_LoadConfig()
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Admin_LoadConfig()
end)