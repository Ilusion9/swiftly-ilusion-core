AddEventHandler("Help_OnGetCommands", function(p_Event)
	local l_Commands = p_Event:GetReturn() or {}
	
	l_Commands["getpos"] = {
		["permission"] = "rcon",
		["description"] = "Gets a player's position",
		["usage"] = "sw_getpos <#userid|name>"
	}
	
	l_Commands["setpos"] = {
		["permission"] = "rcon",
		["description"] = "Sets a player's position",
		["usage"] = "sw_setpos <#userid|name> <origin> [rotation]"
	}
	
	p_Event:SetReturn(l_Commands)
end)

commands:Register("getpos", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "rcon") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if p_ArgsCount < 1 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "Usage: sw_getpos <#userid|name>")
		return
	end
	
	local l_TargetId = exports["helpers"]:FindTarget(p_PlayerId, p_Args[1], "ai", g_Config["tag"])
	
	if not l_TargetId then
		return
	end
	
	if p_Prefix ~= "sw_" then
		l_Player:SendMsg(MessageType.Chat, string.format("{yellow}%s{default} See console for output", g_Config["tag"]))
	end
	
	local l_TargetName = exports["helpers"]:GetPlayerName(l_TargetId)
	local l_TargetOrigin = exports["helpers"]:GetPlayerOrigin(l_TargetId)
	local l_TargetRotation = exports["helpers"]:GetPlayerRotation(l_TargetId)
	
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s Position\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s Player: %s\n", g_Config["tag"], l_TargetName))
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	
	l_Player:SendMsg(MessageType.Console, string.format("%s Origin: %0.2f %0.2f %0.2f\n", g_Config["tag"], l_TargetOrigin[1], l_TargetOrigin[2], l_TargetOrigin[3]))
	l_Player:SendMsg(MessageType.Console, string.format("%s Rotation: %0.2f %0.2f %0.2f\n", g_Config["tag"], l_TargetRotation[1], l_TargetRotation[2], l_TargetRotation[3]))
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
end)

commands:Register("setpos", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "rcon") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if p_ArgsCount < 4 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "sw_setpos <#userid|name> <origin> [rotation]")
		return
	end
	
	local l_TargetId = exports["helpers"]:FindTarget(p_PlayerId, p_Args[1], "ai", g_Config["tag"])
	
	if not l_TargetId then
		return
	end
	
	local l_Origin = {
		p_Args[2],
		p_Args[3],
		p_Args[4]
	}
	
	if not exports["helpers"]:IsValidVector(l_Origin) then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "Invalid origin specified")
		return
	end
	
	local l_Rotation = {
		tonumber(p_Args[5]) or 0,
		tonumber(p_Args[6]) or 0,
		tonumber(p_Args[7]) or 0
	}
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	local l_TargetName = exports["helpers"]:GetPlayerName(l_TargetId)
	local l_TargetSteam = exports["helpers"]:GetPlayerSteam(l_TargetId)
	local l_TargetColor = exports["helpers"]:GetPlayerChatColor(l_TargetId)
	
	logger:Write(LogType_t.Common, string.format("\"%s<%s>\" teleported \"%s<%s>\"", l_PlayerName, l_PlayerSteam, l_TargetName, l_TargetSteam, l_Level))
	
	exports["helpers"]:ShowActivity(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Teleported %s%s{default}", l_TargetColor, l_TargetName))
	
	exports["helpers"]:TeleportPlayer(l_TargetId, l_Origin, l_Rotation, {0, 0, 0})
end)