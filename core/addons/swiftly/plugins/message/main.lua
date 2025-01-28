AddEventHandler("OnPluginStart", function(p_Event)
	Message_LoadConfig()
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Message_LoadConfig()
end)

AddEventHandler("OnClientChat", function(p_Event, p_PlayerId, p_Text, p_TeamOnly)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return EventResult.Continue
	end
	
	if string.sub(p_Text, 1, 1) ~= "@" then
		return EventResult.Continue
	end
	
	local l_Text = string.sub(p_Text, 2, #p_Text)
	
	if p_TeamOnly then
		Message_PerformChat(p_PlayerId, l_Text)
		
		p_Event:SetReturn(false)
		return EventResult.Handled
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "say") then
		l_Player:SendMsg(MessageType.Chat, "{lightred}" .. g_Config["tag"] .. "{default} You do not have access to this command")
		
		p_Event:SetReturn(false)
		return EventResult.Handled
	end
	
	Message_PerformSay(p_PlayerId, l_Text)
	
	p_Event:SetReturn(false)
	return EventResult.Handled
end)