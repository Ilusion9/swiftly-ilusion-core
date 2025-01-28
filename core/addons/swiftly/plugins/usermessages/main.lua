AddEventHandler("OnPluginStart", function(p_Event)
	Usermessages_LoadConfig()
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Usermessages_LoadConfig()
end)

AddEventHandler("OnUserMessageSend", function(p_Event, p_UUID, p_IsReliable)
	local l_MessageId = GetUserMessage(p_UUID):GetMessageID()
	
	if g_Config["block.messages"][l_MessageId] then
		return EventResult.Stop
	end
	
	return EventResult.Continue
end)