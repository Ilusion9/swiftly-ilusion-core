AddEventHandler("Help_OnGetCommands", function(p_Event)
	local l_Commands = p_Event:GetReturn() or {}
	
	l_Commands["chat"] = {
		["description"] = "Sends a message to admins",
		["usage"] = "sw_chat <message>"
	}
	
	l_Commands["psay"] = {
		["description"] = "Sends a private message to a player",
		["usage"] = "sw_psay <#userid|name> <message>"
	}
	
	l_Commands["say"] = {
		["permission"] = "say",
		["description"] = "Sends a message to all players",
		["usage"] = "sw_say <message>"
	}
	
	p_Event:SetReturn(l_Commands)
end)

commands:Register("chat", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if p_ArgsCount < 1 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{orange}" .. g_Config["tag"] .. "{default}", "Usage: sw_chat <message>")
		return
	end
	
	local l_Message = table.concat(p_Args, " ")
	
	Message_PerformChat(p_PlayerId, l_Message)
end)

commands:Register("psay", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if p_ArgsCount < 2 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{orange}" .. g_Config["tag"] .. "{default}", "Usage: sw_psay <#userid|name> <message>")
		return
	end
	
	local l_TargetId = exports["helpers"]:FindTarget(p_PlayerId, p_Args[1], "n", g_Config["tag"])
	
	if not l_TargetId then
		return
	end
	
	local l_Message = table.concat(p_Args, " ", 2)
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	local l_PlayerColor = exports["helpers"]:GetPlayerChatColor(p_PlayerId)
	
	local l_Target = GetPlayer(l_TargetId)
	local l_TargetName = exports["helpers"]:GetPlayerName(l_TargetId)
	local l_TargetSteam = exports["helpers"]:GetPlayerSteam(l_TargetId)
	
	logger:Write(LogType_t.Common, string.format("\"%s<%s>\" triggered sw_psay to \"%s<%s>\" (text \"%s\")", l_PlayerName, l_PlayerSteam, l_TargetName, l_TargetSteam, l_Message))
	
	exports["helpers"]:ReplyToCommand(p_PlayerId, string.format("{lime}(TO %s){default}", l_TargetName), string.format("%s%s:{default} %s", l_PlayerColor, l_PlayerName, l_Message))
	
	if p_PlayerId == l_TargetId then
		return
	end
	
	l_Target:SendMsg(MessageType.Chat, string.format("{lime}(TO %s){default} %s%s:{default} %s", l_TargetName, l_PlayerColor, l_PlayerName, l_Message))
end)

commands:Register("say", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "say") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if p_ArgsCount < 1 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{orange}" .. g_Config["tag"] .. "{default}", "Usage: sw_say <message>")
		return
	end
	
	local l_Message = table.concat(p_Args, " ")
	
	Message_PerformSay(p_PlayerId, l_Message)
end)