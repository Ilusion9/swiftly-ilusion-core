AddEventHandler("OnPluginStart", function(p_Event)
	Chat_LoadConfig()
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Chat_LoadConfig()
end)

AddEventHandler("OnClientChat", function(p_Event, p_PlayerId, p_Text, p_TeamOnly)
	Chat_SetPlayerNameColor(p_PlayerId)
end)