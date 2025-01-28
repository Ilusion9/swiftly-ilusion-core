AddEventHandler("Help_OnGetCommands", function(p_Event)
	local l_Commands = p_Event:GetReturn() or {}
	
	l_Commands["rank"] = {
		["description"] = "Shows a player's rank",
		["usage"] = "sw_rank"
	}
	
	l_Commands["stats"] = {
		["description"] = "Shows a player's stats",
		["usage"] = "sw_stats [@steam|#userid|name]"
	}
	
	l_Commands["stats_database_create"] = {
		["permission"] = "rcon",
		["description"] = "Creates the player stats database",
		["usage"] = "sw_stats_database_create"
	}
	
	l_Commands["stats_database_delete"] = {
		["permission"] = "rcon",
		["description"] = "Deletes the player stats database",
		["usage"] = "sw_stats_database_delete"
	}
	
	l_Commands["top"] = {
		["description"] = "Shows the top players",
		["usage"] = "sw_top"
	}
	
	p_Event:SetReturn(l_Commands)
end)

commands:Register("rank", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	Stats_PerformRank(p_PlayerId)
end)

commands:Register("stats", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_TargetId = nil
	local l_TargetSteam = nil
	
	if p_ArgsCount ~= 0 then
		if not exports["admin"]:HasPlayerPermission(p_PlayerId, "rcon") then
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
	
	Stats_PerformStats(p_PlayerId, l_TargetId, l_TargetSteam)
end)

commands:Register("stats_database_create", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
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
	
	Stats_CreateDatabase()
end)

commands:Register("stats_database_delete", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
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
	
	Stats_DeleteDatabase()
end)

commands:Register("top", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	Stats_PerformTop(p_PlayerId)
end)