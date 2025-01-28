function Message_LoadConfig()
	config:Reload("message")
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("message.tag")
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Message]"
	end
end

function Message_PerformChat(p_PlayerId, p_Message)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	local l_PlayerColor = exports["helpers"]:GetPlayerChatColor(p_PlayerId)
	local l_PlayerPermission = exports["admin"]:HasPlayerPermission(p_PlayerId, "chat")
	
	logger:Write(LogType_t.Common, string.format("\"%s<%s>\" triggered sw_chat (text \"%s\")", l_PlayerName, l_PlayerSteam, p_Message))
	
	l_Player:SendMsg(MessageType.Console, string.format("%s %s: %s", l_PlayerPermission and "(ADMINS)" or "(TO ADMINS)", l_PlayerName, p_Message))
	
	l_Player:SendMsg(MessageType.Chat, string.format("%s %s%s:{default} %s", l_PlayerPermission and "{lime}(ADMINS){default}" or "{lime}(TO ADMINS){default}", l_PlayerColor, l_PlayerName, p_Message))
	
	for i = 0, playermanager:GetPlayerCap() - 1 do
		if i ~= p_PlayerId then
			local l_PlayerIter = GetPlayer(i)
			
			if l_PlayerIter and l_PlayerIter:IsValid() then
				if exports["admin"]:HasPlayerPermission(i, "chat") then
					l_PlayerIter:SendMsg(MessageType.Chat, string.format("%s %s%s:{default} %s", l_PlayerPermission and "{lime}(ADMINS){default}" or "{lime}(TO ADMINS){default}", l_PlayerColor, l_PlayerName, p_Message))
				end
			end
		end
	end
end

function Message_PerformSay(p_PlayerId, p_Message)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	logger:Write(LogType_t.Common, string.format("\"%s<%s>\" triggered sw_say (text \"%s\")", l_PlayerName, l_PlayerSteam, p_Message))
	
	exports["helpers"]:ShowActivity(p_PlayerId, "{lime}(ALL){default}", p_Message)
end