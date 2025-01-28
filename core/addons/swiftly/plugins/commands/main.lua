AddEventHandler("OnPluginStart", function(p_Event)
	Commands_LoadConfig()
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Commands_LoadConfig()
end)

AddEventHandler("OnClientCommand", function(p_Event, p_PlayerId, p_Command)
	local l_Args = string.split(p_Command, " ")
	
	if not g_Config["block.commands"][l_Args[1]] then
		return EventResult.Continue
	end
	
	p_Event:SetReturn(false)
	return EventResult.Handled
end)