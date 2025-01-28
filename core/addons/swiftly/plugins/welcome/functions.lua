function Welcome_LoadConfig()
	config:Reload("welcome")
	
	g_Config = {}
	
	Welcome_LoadConfigChatMessages()
end

function Welcome_LoadConfigChatMessages()
	g_Config["chat.messages"] = {}
	
	local l_Messages = config:Fetch("welcome.chat.messages")
	
	if type(l_Messages) ~= "table" then
		l_Messages = {}
	end
	
	for i = 1, #l_Messages do
		local l_Message = l_Messages[i]
		
		if type(l_Message) ~= "string" or #l_Message == 0 then
			l_Message = nil
		end
		
		if l_Message then
			table.insert(g_Config["chat.messages"], l_Message)
		end
	end
end

function Welcome_ShowPlayerChatMessages(p_PlayerId)
	if #g_Config["chat.messages"] == 0 then
		return
	end
	
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() or l_Player:IsFakeClient() then
		return
	end
	
	for i = 1, #g_Config["chat.messages"] do
		l_Player:SendMsg(MessageType.Chat, g_Config["chat.messages"][i])
	end
end