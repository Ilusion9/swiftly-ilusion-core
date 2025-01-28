function Messages_LoadConfig()
	config:Reload("messages")
	
	g_Config = {}
	g_Config["chat.interval"] = tonumber(config:Fetch("messages.chat.interval"))
	
	if not g_Config["chat.interval"] or g_Config["chat.interval"] < 1 then
		g_Config["chat.interval"] = 1
	end
	
	g_Config["chat.interval"] = math.floor(g_Config["chat.interval"] * 1000)
	
	Messages_LoadConfigChatMessages()
end

function Messages_LoadConfigChatMessages()
	g_Config["chat.messages"] = {}
	
	local l_Messages = config:Fetch("messages.chat.messages")
	
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

function Messages_ResetPlayerVars(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	l_Player:SetVar("messages.chat.id", nil)
	l_Player:SetVar("messages.chat.time", nil)
	l_Player:SetVar("messages.connection.time", nil)
end

function Messages_SetPlayerConnectionTime(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	l_Player:SetVar("messages.connection.time", l_ServerTime)
end

function Messages_ShowPlayerChatMessage(p_PlayerId)
	if #g_Config["chat.messages"] == 0 then
		return
	end
	
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() or l_Player:IsFakeClient() then
		return
	end
	
	local l_PlayerConnectionTime = l_Player:GetVar("messages.connection.time")
	
	if not l_PlayerConnectionTime then
		return
	end
	
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	local l_PlayerMessageTime = l_Player:GetVar("messages.chat.time") or l_PlayerConnectionTime
	
	if l_PlayerMessageTime + g_Config["chat.interval"] > l_ServerTime then
		return
	end
	
	local l_PlayerMessageId = l_Player:GetVar("messages.chat.id") or math.random(1, #g_Config["chat.messages"])
	
	l_PlayerMessageId = l_PlayerMessageId + 1
	l_PlayerMessageId = l_PlayerMessageId > #g_Config["chat.messages"] and 1 or l_PlayerMessageId
	
	l_Player:SetVar("messages.chat.id", l_PlayerMessageId)
	l_Player:SetVar("messages.chat.time", l_ServerTime)
	
	l_Player:SendMsg(MessageType.Chat, g_Config["chat.messages"][l_PlayerMessageId])
end

function Messages_Think()
	for i = 0, playermanager:GetPlayerCap() - 1 do
		Messages_ShowPlayerChatMessage(i)
	end
end