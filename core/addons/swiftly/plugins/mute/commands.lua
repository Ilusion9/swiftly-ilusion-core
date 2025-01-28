AddEventHandler("Help_OnGetCommands", function(p_Event)
	local l_Commands = p_Event:GetReturn() or {}
	
	l_Commands["mute"] = {
		["permission"] = "mute",
		["description"] = "Mutes a player",
		["usage"] = "sw_mute <@steam|#userid|name> <time> [reason]"
	}
	
	l_Commands["mute_database_create"] = {
		["permission"] = "rcon",
		["description"] = "Creates the player mute database",
		["usage"] = "sw_mute_database_create"
	}
	
	l_Commands["mute_database_delete"] = {
		["permission"] = "rcon",
		["description"] = "Deletes the player mute database",
		["usage"] = "sw_mute_database_delete"
	}
	
	l_Commands["mutehistory"] = {
		["description"] = "Shows a player's mute history",
		["usage"] = "sw_mutehistory [@steam|#userid|name]"
	}
	
	l_Commands["unmute"] = {
		["permission"] = "unmute",
		["description"] = "Unmutes a player",
		["usage"] = "sw_unmute <@steam|#userid|name>"
	}
	
	p_Event:SetReturn(l_Commands)
end)

commands:Register("mute", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "mute") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if p_ArgsCount < 2 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "Usage: sw_mute <@steam|#userid|name> <time> [reason]")
		return
	end
	
	local l_TargetId = nil
	local l_TargetSteam = nil
	
	if string.sub(p_Args[1], 1, 1) == "@" then
		l_TargetSteam = string.sub(p_Args[1], 2, DATABASE_STEAM_LENGTH + 1)
		
		if not exports["helpers"]:IsValidSteam(l_TargetSteam) then
			exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "Invalid steam specified")
			return
		end
		
		if not exports["admin"]:CanPlayerTargetSteam(p_PlayerId, l_TargetSteam) then
			exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You cannot target this steam")
			return
		end
	else
		l_TargetId = exports["helpers"]:FindTarget(p_PlayerId, p_Args[1], "in", g_Config["tag"])
		
		if not l_TargetId then
			return
		end
	end
	
	local l_Time = exports["helpers"]:GetArgTime(p_Args[2])
	
	if not l_Time or l_Time < 0 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "Invalid time specified")
		return
	end
	
	if not Mute_IsValidTime(l_Time) 
		and not exports["admin"]:HasPlayerPermission(p_PlayerId, "permmute") 
	then
		local l_FormatTime = exports["helpers"]:FormatTime(g_Config["time"])
		
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", string.format("Your maximum available time is {lime}%s{default}", l_FormatTime))
		return
	end
	
	local l_Reason = string.sub(table.concat(p_Args, " ", 3), 1, DATABASE_REASON_LENGTH)
	
	Mute_PerformMute(p_PlayerId, l_TargetId, l_TargetSteam, l_Time, l_Reason)
end)

commands:Register("mute_database_create", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "rcon") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if not g_Database:IsConnected() then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "There was an error processing your request")
		return
	end
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	logger:Write(LogType_t.Common, string.format("\"%s<%s>\" created the database", l_PlayerName, l_PlayerSteam))
	exports["helpers"]:ReplyToCommand(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", "Database created successfully")
	
	Mute_CreateDatabase()
end)

commands:Register("mute_database_delete", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "rcon") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if not g_Database:IsConnected() then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "There was an error processing your request")
		return
	end
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	logger:Write(LogType_t.Common, string.format("\"%s<%s>\" deleted the database", l_PlayerName, l_PlayerSteam))
	exports["helpers"]:ReplyToCommand(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", "Database deleted successfully")
	
	Mute_DeleteDatabase()
end)

commands:Register("mutehistory", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_TargetId = nil
	local l_TargetSteam = nil
	
	if p_ArgsCount ~= 0 then
		if not exports["admin"]:HasPlayerPermission(p_PlayerId, "mutehistory") then
			exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
			return
		end
		
		if string.sub(p_Args[1], 1, 1) == "@" then
			l_TargetSteam = string.sub(p_Args[1], 2, DATABASE_STEAM_LENGTH + 1)
			
			if not exports["helpers"]:IsValidSteam(l_TargetSteam) then
				exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "Invalid steam specified")
				return
			end
			
			if not exports["admin"]:CanPlayerTargetSteam(p_PlayerId, l_TargetSteam) then
				exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You cannot target this steam")
				return
			end
		else
			l_TargetId = exports["helpers"]:FindTarget(p_PlayerId, p_Args[1], "in", g_Config["tag"])
			
			if not l_TargetId then
				return
			end
		end
	else
		l_TargetId = p_PlayerId
	end
	
	Mute_PerformMuteHistory(p_PlayerId, l_TargetId, l_TargetSteam)
end)

commands:Register("unmute", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "unmute") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if p_ArgsCount < 1 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "Usage: sw_unmute <@steam|#userid|name>")
		return
	end
	
	local l_TargetId = nil
	local l_TargetSteam = nil
	
	if string.sub(p_Args[1], 1, 1) == "@" then
		l_TargetSteam = string.sub(p_Args[1], 2, DATABASE_STEAM_LENGTH + 1)
		
		if not exports["helpers"]:IsValidSteam(l_TargetSteam) then
			exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "Invalid steam specified")
			return
		end
		
		if not exports["admin"]:CanPlayerTargetSteam(p_PlayerId, l_TargetSteam) then
			exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You cannot target this steam")
			return
		end
	else
		l_TargetId = exports["helpers"]:FindTarget(p_PlayerId, p_Args[1], "in", g_Config["tag"])
		
		if not l_TargetId then
			return
		end
	end
	
	Mute_PerformUnmute(p_PlayerId, l_TargetId, l_TargetSteam)
end)