AddEventHandler("Help_OnGetCommands", function(p_Event)
	local l_Commands = p_Event:GetReturn() or {}
	
	l_Commands["kick"] = {
		["permission"] = "kick",
		["description"] = "Kicks a player",
		["usage"] = "sw_kick <#userid|name> [reason]"
	}
	
	l_Commands["playerhistory"] = {
		["description"] = "Shows the player history",
		["usage"] = "sw_playerhistory"
	}
	
	l_Commands["players"] = {
		["description"] = "Shows the current players",
		["usage"] = "sw_players"
	}
	
	l_Commands["rename"] = {
		["permission"] = "rename",
		["description"] = "Changes a player's name",
		["usage"] = "sw_rename <#userid|name> [newname]"
	}
	
	l_Commands["slap"] = {
		["permission"] = "slap",
		["description"] = "Slaps a player",
		["usage"] = "sw_slap <#userid|name> [damage]"
	}
	
	l_Commands["slay"] = {
		["permission"] = "slay",
		["description"] = "Slays a player",
		["usage"] = "sw_slap <#userid|name>"
	}
	
	p_Event:SetReturn(l_Commands)
end)

commands:Register("kick", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "kick") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if p_ArgsCount < 1 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "Usage: sw_kick <#userid|name> [reason]")
		return
	end
	
	local l_TargetId = exports["helpers"]:FindTarget(p_PlayerId, p_Args[1], "i", g_Config["tag"])
	
	if not l_TargetId then
		return
	end
	
	local l_Reason = table.concat(p_Args, " ", 2)
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	local l_Target = GetPlayer(l_TargetId)
	local l_TargetName = exports["helpers"]:GetPlayerName(l_TargetId)
	local l_TargetSteam = exports["helpers"]:GetPlayerSteam(l_TargetId)
	local l_TargetColor = exports["helpers"]:GetPlayerChatColor(l_TargetId)
	
	local l_FormatReason = Player_FormatReason(l_Reason)
	
	logger:Write(LogType_t.Common, string.format("\"%s<%s>\" kicked \"%s<%s>\" (reason \"%s\")", l_PlayerName, l_PlayerSteam, l_TargetName, l_TargetSteam, l_Reason))
	
	exports["helpers"]:ShowActivity(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Kicked %s%s{default}%s", l_TargetColor, l_TargetName, l_FormatReason))
	
	l_Target:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	l_Target:SendMsg(MessageType.Console, string.format("%s Kicked by admin%s\n", g_Config["tag"], l_FormatReason))
	l_Target:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	
	exports["helpers"]:KickPlayer(l_TargetId)
end)

commands:Register("playerhistory", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if p_Prefix ~= "sw_" then
		l_Player:SendMsg(MessageType.Chat, string.format("{yellow}%s{default} See console for output", g_Config["tag"]))
	end
	
	local l_CurrentTime = GetTime()
	
	local l_Body = {}
	local l_Header = {
		"#",
		"Name",
		"Steam",
		"Quit Time"
	}
	
	for i = #g_History, 1, -1 do
		local l_Name = g_History[i]["name"]
		local l_Steam = g_History[i]["steam"]
		local l_QuitTime = tonumber(g_History[i]["disconnected_at"])
		
		local l_FormatQuitTime = string.format("%s ago", exports["helpers"]:FormatTime(l_CurrentTime - l_QuitTime))
		
		table.insert(l_Body, {
			string.format("%02d.", #g_History - i + 1),
			l_Name,
			l_Steam,
			l_FormatQuitTime
		})
	end
	
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s Player History\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	
	exports["helpers"]:PrintTableToConsole(p_PlayerId, g_Config["tag"], l_Header, l_Body)
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
end)

commands:Register("players", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if p_Prefix ~= "sw_" then
		l_Player:SendMsg(MessageType.Chat, string.format("{yellow}%s{default} See console for output", g_Config["tag"]))
	end
	
	local l_Body = {}
	local l_Header = {
		"ID",
		"Name",
		"Steam"
	}
	
	for i = 0, playermanager:GetPlayerCap() - 1 do
		local l_PlayerIter = GetPlayer(i)
		
		if l_PlayerIter and l_PlayerIter:IsValid() then
			local l_PlayerIterName = exports["helpers"]:GetPlayerName(i)
			local l_PlayerIterSteam = exports["helpers"]:GetPlayerSteam(i)
			
			table.insert(l_Body, {
				i,
				l_PlayerIterName,
				l_PlayerIterSteam
			})
		end
	end
	
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s Players\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	
	exports["helpers"]:PrintTableToConsole(p_PlayerId, g_Config["tag"], l_Header, l_Body)
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
end)

commands:Register("rename", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "rename") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if p_ArgsCount < 1 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "Usage: sw_rename <#userid|name> [newname]")
		return
	end
	
	local l_TargetId = exports["helpers"]:FindTarget(p_PlayerId, p_Args[1], "i", g_Config["tag"])
	
	if not l_TargetId then
		return
	end
	
	local l_Name = p_Args[2] and table.concat(p_Args, " ", 2) or ("Player " .. l_TargetId)
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	local l_TargetName = exports["helpers"]:GetPlayerName(l_TargetId)
	local l_TargetSteam = exports["helpers"]:GetPlayerSteam(l_TargetId)
	local l_TargetColor = exports["helpers"]:GetPlayerChatColor(l_TargetId)
	
	logger:Write(LogType_t.Common, string.format("\"%s<%s>\" renamed \"%s<%s>\" (to \"%s\")", l_PlayerName, l_PlayerSteam, l_TargetName, l_TargetSteam, l_Name))
	
	exports["helpers"]:ShowActivity(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Renamed %s%s{default} to {lime}%s{default}", l_TargetColor, l_TargetName, l_Name))
	
	exports["helpers"]:ChangePlayerName(l_TargetId, l_Name)
end)

commands:Register("slap", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "slap") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if p_ArgsCount < 1 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "Usage: sw_slap <#userid|name> [damage]")
		return
	end
	
	local l_TargetId = exports["helpers"]:FindTarget(p_PlayerId, p_Args[1], "ai", g_Config["tag"])
	
	if not l_TargetId then
		return
	end
	
	local l_Damage = tonumber(p_Args[2] or 0)
	
	if not l_Damage or l_Damage < 0 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "Invalid damage specified")
		return
	end
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	local l_Target = GetPlayer(l_TargetId)
	local l_TargetName = exports["helpers"]:GetPlayerName(l_TargetId)
	local l_TargetSteam = exports["helpers"]:GetPlayerSteam(l_TargetId)
	local l_TargetColor = exports["helpers"]:GetPlayerChatColor(l_TargetId)
	
	logger:Write(LogType_t.Common, string.format("\"%s<%s>\" slapped \"%s<%s>\" (damage \"%d\")", l_PlayerName, l_PlayerSteam, l_TargetName, l_TargetSteam, l_Damage))
	
	exports["helpers"]:ShowActivity(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Slapped %s%s{default} with {lime}%d{default} damage", l_TargetColor, l_TargetName, l_Damage))
	
	l_Target:SetVar("player.slap.queue", true)
	
	exports["helpers"]:SlapPlayer(l_TargetId, l_Damage)
	
	l_Target:SetVar("player.slap.queue", nil)
end)

commands:Register("slay", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "slay") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if p_ArgsCount < 1 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "Usage: sw_slay <#userid|name>")
		return
	end
	
	local l_TargetId = exports["helpers"]:FindTarget(p_PlayerId, p_Args[1], "ai", g_Config["tag"])
	
	if not l_TargetId then
		return
	end
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	local l_Target = GetPlayer(l_TargetId)
	local l_TargetName = exports["helpers"]:GetPlayerName(l_TargetId)
	local l_TargetSteam = exports["helpers"]:GetPlayerSteam(l_TargetId)
	local l_TargetColor = exports["helpers"]:GetPlayerChatColor(l_TargetId)
	
	logger:Write(LogType_t.Common, string.format("\"%s<%s>\" slayed \"%s<%s>\"", l_PlayerName, l_PlayerSteam, l_TargetName, l_TargetSteam))
	
	exports["helpers"]:ShowActivity(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Slayed %s%s{default}", l_TargetColor, l_TargetName))
	
	l_Target:SetVar("player.slay.queue", true)
	
	exports["helpers"]:SlayPlayer(l_TargetId)
	
	l_Target:SetVar("player.slay.queue", nil)
end)