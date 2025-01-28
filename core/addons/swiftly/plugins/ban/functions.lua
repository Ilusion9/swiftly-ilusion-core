function Ban_CreateDatabase()
	if not g_Database:IsConnected() then
		logger:Write(LogType_t.Warning, "Could not connect to the database")
		return
	end
	
	g_Database:Query("CREATE TABLE IF NOT EXISTS `player_bans` (`id` INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, `steam` VARCHAR(" .. DATABASE_STEAM_LENGTH .. ") CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL, `started_at` VARCHAR(" .. DATABASE_TIME_LENGTH .. ") CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL, `time` VARCHAR(" .. DATABASE_TIME_LENGTH .. ") CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL, `admin_steam` VARCHAR(" .. DATABASE_STEAM_LENGTH .. ") CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL, `reason` VARCHAR(" .. DATABASE_REASON_LENGTH .. ") CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL);", function(p_Error, p_Result)
		if #p_Error > 0 then
			logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			return
		end
		
		g_Database:Query("CREATE TABLE IF NOT EXISTS `player_removed_bans` (`id` INT UNSIGNED PRIMARY KEY AUTO_INCREMENT, `ban_id` INT UNSIGNED, `removed_at` VARCHAR(" .. DATABASE_TIME_LENGTH .. ") CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL, `admin_steam` VARCHAR(" .. DATABASE_STEAM_LENGTH .. ") CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL, FOREIGN KEY (`ban_id`) REFERENCES `player_bans`(`id`) ON UPDATE CASCADE ON DELETE CASCADE);", function(p_Error, p_Result)
			if #p_Error > 0 then
				logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
				return
			end
		end)
	end)
end

function Ban_DeleteDatabase()
	if not g_Database:IsConnected() then
		return
	end
	
	g_Database:Query("DROP TABLE IF EXISTS `player_removed_bans`;", function(p_Error, p_Result)
		if #p_Error > 0 then
			logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			return
		end
		
		g_Database:Query("DROP TABLE IF EXISTS `player_bans`;", function(p_Error, p_Result)
			if #p_Error > 0 then
				logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
				return
			end
		end)
	end)
end

function Ban_FormatAdmin(p_Admin)
	local l_User = exports["admin"]:GetSteamUser(p_Admin)
	
	if not l_User then
		return p_Admin
	end
	
	return string.format("%s (%s)", l_User, p_Admin)
end

function Ban_FormatStatus(p_StartTime, p_Time, p_UnbanAdminSteam, p_IsLast)
	if p_UnbanAdminSteam and p_UnbanAdminSteam ~= "NULL" then
		local l_FormatAdmin = Gag_FormatAdmin(p_UnbanAdminSteam)
		
		return string.format("Unbanned by %s", l_FormatAdmin)
	end
	
	local l_TimeLeft = exports["helpers"]:GetTimeLeft(p_StartTime, p_Time, false)
	
	if l_TimeLeft == 0 then
		return "Expired"
	end
	
	if not p_IsLast then
		return "Overridden"
	end
	
	local l_FormatTime = Ban_FormatTime(l_TimeLeft, "for %s", "permanently", true)
	
	return string.format("Banned %s", l_FormatTime)
end

function Ban_FormatTime(p_Time, p_Format, p_Permanent, p_IsTimeLeft)
	if p_IsTimeLeft then
		if exports["helpers"]:IsTimeIndefinite(p_Time) then
			return p_Permanent
		end
	else
		if p_Time == 0 then
			return p_Permanent
		end
	end
	
	local l_FormatTime = exports["helpers"]:FormatTime(p_Time)
	
	return string.format(p_Format, l_FormatTime)
end

function Ban_IsValidTime(p_Time)
	if g_Config["time"] == 0 then
		return true
	end
	
	if p_Time ~= 0 and p_Time <= g_Config["time"] then
		return true
	end
	
	return false
end

function Ban_LoadConfig()
	config:Reload("ban")
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("ban.tag")
	g_Config["history.size"] = tonumber(config:Fetch("ban.history.size"))
	g_Config["time"] = tonumber(config:Fetch("ban.time"))
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Ban]"
	end
	
	if not g_Config["history.size"] or g_Config["history.size"] < 0 then
		g_Config["history.size"] = HISTORY_SIZE
	end
	
	if not g_Config["time"] or g_Config["time"] < 0 then
		g_Config["time"] = 0
	end
	
	g_Config["time"] = math.floor(g_Config["time"] * 1000)
end

function Ban_LoadPlayerBan(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() or l_Player:IsFakeClient() then
		return
	end
	
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	g_Database:Query(string.format("SELECT a.`id`, a.`started_at`, a.`time`, a.`admin_steam`, a.`reason` FROM `player_bans` a LEFT JOIN `player_removed_bans` b ON a.`id` = b.`ban_id` WHERE a.`id` = (SELECT MAX(`id`) FROM `player_bans` WHERE `steam` = '%s') AND b.`admin_steam` IS NULL;", l_PlayerSteam), function(p_Error, p_Result)
		if #p_Error > 0 then
			logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			return
		end
		
		if #p_Result == 0 or not l_Player:IsValid() then
			return
		end
		
		local l_StartTime = tonumber(p_Result[1]["started_at"])
		local l_Time = tonumber(p_Result[1]["time"])
		
		local l_TimeLeft = exports["helpers"]:GetTimeLeft(l_StartTime, l_Time, false)
		
		if l_TimeLeft == 0 then
			return
		end
		
		local l_AdminSteam = p_Result[1]["admin_steam"]
		local l_Reason = p_Result[1]["reason"]
		
		Ban_PrintBanToConsole(p_PlayerId, l_StartTime, l_TimeLeft, l_AdminSteam, l_Reason)
		
		exports["helpers"]:KickClient(p_PlayerId)
	end)
end

function Ban_PerformBan(p_PlayerId, p_TargetId, p_TargetSteam, p_Time, p_Reason)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	if not g_Database:IsConnected() then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "There was an error processing your request")
		return
	end
	
	local l_TargetName = nil
	local l_TargetSteam = nil
	local l_TargetColor = nil
	
	if p_TargetId then
		l_TargetName = exports["helpers"]:GetPlayerName(p_TargetId)
		l_TargetSteam = exports["helpers"]:GetPlayerSteam(p_TargetId)
		l_TargetColor = exports["helpers"]:GetPlayerChatColor(p_TargetId)
	end
	
	g_Database:Query(string.format("SELECT a.`id`, a.`started_at`, a.`time`, a.`admin_steam`, a.`reason` FROM `player_bans` a LEFT JOIN `player_removed_bans` b ON a.`id` = b.`ban_id` WHERE a.`id` = (SELECT MAX(`id`) FROM `player_bans` WHERE `steam` = '%s') AND b.`admin_steam` IS NULL;", p_TargetId and l_TargetSteam or g_Database:EscapeString(l_TargetSteam)), function(p_Error, p_Result)
		if #p_Error > 0 then
			logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			
			if not l_Player:IsValid() then
				return
			end
			
			exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "There was an error processing your request")
			return
		end
		
		if not l_Player:IsValid() then
			return
		end
		
		if #p_Result ~= 0 then
			local l_StartTime = tonumber(p_Result[1]["started_at"])
			local l_Time = tonumber(p_Result[1]["time"])
			
			local l_TimeLeft = exports["helpers"]:GetTimeLeft(l_StartTime, l_Time, false)
			
			if l_TimeLeft ~= 0 then
				local l_AdminSteam = p_Result[1]["admin_steam"]
				local l_Reason = p_Result[1]["reason"]
				
				local l_FormatTime = Ban_FormatTime(l_TimeLeft, "for {lightred}%s{default}", "permanently", true)
				local l_FormatAdmin = Ban_FormatAdmin(l_AdminSteam)
				
				exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", string.format("This %s is already banned %s by {lightred}%s{default} (%s)", p_TargetId and "player" or "steam", l_FormatTime, l_FormatAdmin, l_Reason))
				
				return
			end
		end
		
		local l_CurrentTime = GetTime()
		
		local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
		local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
		
		g_Database:Query(string.format("INSERT INTO `player_bans` (`steam`, `started_at`, `time`, `admin_steam`, `reason`) VALUES ('%s', '%d', '%d', '%s', '%s');", p_TargetId and l_TargetSteam or g_Database:EscapeString(l_TargetSteam), l_CurrentTime, p_Time, l_PlayerSteam, g_Database:EscapeString(p_Reason)), function(p_Error, p_Result)
			if #p_Error > 0 then
				logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
				
				if not l_Player:IsValid() then
					return
				end
				
				exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "There was an error processing your request")
				return
			end
			
			local l_FormatTime = Ban_FormatTime(p_Time, "for {lime}%s{default}", "permanently", false)
			local l_FormatLogTime = Ban_FormatTime(p_Time, "%s", "permanent", false)
			
			if p_TargetId then
				local l_Target = GetPlayer(p_TargetId)
				
				logger:Write(LogType_t.Common, string.format("\"%s<%s>\" banned \"%s<%s>\" (time \"%s\") (reason \"%s\")", l_PlayerName, l_PlayerSteam, l_TargetName, l_TargetSteam, l_FormatLogTime, p_Reason))
				
				if l_Player:IsValid() then
					exports["helpers"]:ShowActivity(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Banned %s%s{default} %s (%s)", l_TargetColor, l_TargetName, l_FormatTime, p_Reason))
				else
					exports["helpers"]:ShowActivity2(l_PlayerName, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Banned %s%s{default} %s (%s)", l_TargetColor, l_TargetName, l_FormatTime, p_Reason))
				end
				
				if l_Target:IsValid() then
					Ban_PrintBanToConsole(p_TargetId, l_CurrentTime, p_Time, l_PlayerSteam, p_Reason)
					
					exports["helpers"]:KickPlayer(p_TargetId)
				end
			else
				local l_TargetId = exports["helpers"]:FindPlayerBySteam(l_TargetSteam)
				
				logger:Write(LogType_t.Common, string.format("\"%s<%s>\" banned steam \"%s\" (time \"%s\") (reason \"%s\")", l_PlayerName, l_PlayerSteam, l_TargetSteam, l_FormatLogTime, p_Reason))
				
				if l_Player:IsValid() then
					exports["helpers"]:ShowActivity(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Banned steam {lime}%s{default} %s (%s)", l_TargetSteam, l_FormatTime, p_Reason))
				else
					exports["helpers"]:ShowActivity2(l_PlayerName, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Banned steam {lime}%s{default} %s (%s)", l_TargetSteam, l_FormatTime, p_Reason))
				end
				
				if l_TargetId then
					Ban_PrintBanToConsole(l_TargetId, l_CurrentTime, p_Time, l_PlayerSteam, p_Reason)
					
					exports["helpers"]:KickPlayer(l_TargetId)
				end
			end
		end)
	end)
end

function Ban_PerformBanHistory(p_PlayerId, p_TargetId, p_TargetSteam)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	if not g_Database:IsConnected() then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "There was an error processing your request")
		return
	end
	
	local l_TargetName = nil
	local l_TargetSteam = nil
	
	if p_TargetId then
		l_TargetName = exports["helpers"]:GetPlayerName(p_TargetId)
		l_TargetSteam = exports["helpers"]:GetPlayerSteam(p_TargetId)
	end
	
	g_Database:Query(string.format("SELECT a.`id`, a.`started_at`, a.`time`, a.`admin_steam`, a.`reason`, b.`admin_steam` AS unban_admin_steam FROM `player_bans` a LEFT JOIN `player_removed_bans` b ON a.`id` = b.`ban_id` WHERE a.`steam` = '%s' ORDER BY a.`id` DESC LIMIT %d;", p_TargetId and l_TargetSteam or g_Database:EscapeString(l_TargetSteam), g_Config["history.size"]), function(p_Error, p_Result)
		if #p_Error > 0 then
			logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			
			if not l_Player:IsValid() then
				return
			end
			
			exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "There was an error processing your request")
			return
		end
		
		if not l_Player:IsValid() then
			return
		end
		
		if p_Prefix ~= "sw_" then
			l_Player:SendMsg(MessageType.Chat, string.format("{yellow}%s{default} See console for output", g_Config["tag"]))
		end
		
		local l_CurrentTime = GetTime()
		
		local l_Body = {}
		local l_Header = {
			"#",
			"Start Time",
			"Time",
			"Admin",
			"Reason",
			"Status"
		}
		
		for i = 1, #p_Result do
			local l_StartTime = tonumber(p_Result[i]["started_at"])
			local l_Time = tonumber(p_Result[i]["time"])
			local l_AdminSteam = p_Result[i]["admin_steam"]
			local l_Reason = p_Result[i]["reason"]
			
			local l_UnbanAdminSteam = p_Result[i]["unban_admin_steam"]
			
			local l_FormatStartTime = string.format("%s ago", exports["helpers"]:FormatTime(l_CurrentTime - l_StartTime))
			local l_FormatTime = Ban_FormatTime(l_Time, "%s", "Permanent", false)
			local l_FormatAdmin = Ban_FormatAdmin(l_AdminSteam)
			local l_FormatStatus = Ban_FormatStatus(l_StartTime, l_Time, l_UnbanAdminSteam, i == 1)
			
			table.insert(l_Body, {
				string.format("%02d.", i),
				l_FormatStartTime,
				l_FormatTime,
				l_FormatAdmin,
				l_Reason,
				l_FormatStatus
			})
		end
		
		l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
		l_Player:SendMsg(MessageType.Console, string.format("%s Ban History\n", g_Config["tag"]))
		l_Player:SendMsg(MessageType.Console, string.format("%s %s: %s\n", g_Config["tag"], p_TargetId and "Player" or "Steam", p_TargetId and l_TargetName or l_TargetSteam))
		l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
		
		exports["helpers"]:PrintTableToConsole(p_PlayerId, g_Config["tag"], l_Header, l_Body)
		l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	end)
end

function Ban_PerformUnban(p_PlayerId, p_TargetSteam)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	if not g_Database:IsConnected() then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "There was an error processing your request")
		return
	end
	
	g_Database:Query(string.format("SELECT a.`id`, a.`started_at`, a.`time`, a.`admin_steam`, a.`reason` FROM `player_bans` a LEFT JOIN `player_removed_bans` b ON a.`id` = b.`ban_id` WHERE a.`id` = (SELECT MAX(`id`) FROM `player_bans` WHERE `steam` = '%s') AND b.`admin_steam` IS NULL;", g_Database:EscapeString(l_TargetSteam)), function(p_Error, p_Result)
		if #p_Error > 0 then
			logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			
			if not l_Player:IsValid() then
				return
			end
			
			exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "There was an error processing your request")
			return
		end
		
		if not l_Player:IsValid() then
			return
		end
		
		if #p_Result == 0 then
			exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "This steam is not banned")
			return
		end
		
		local l_StartTime = tonumber(p_Result[1]["started_at"])
		local l_Time = tonumber(p_Result[1]["time"])
		
		local l_TimeLeft = exports["helpers"]:GetTimeLeft(l_StartTime, l_Time, false)
		
		if l_TimeLeft == 0 then
			exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "This steam is not banned")
			return
		end
		
		local l_CurrentTime = GetTime()
		
		local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
		local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
		
		local l_Id = p_Result[1]["id"]
		
		g_Database:Query(string.format("INSERT INTO `player_removed_bans` (`ban_id`, `removed_at`, `admin_steam`) VALUES (%d, '%d', '%s');", l_Id, l_CurrentTime, l_PlayerSteam), function(p_Error, p_Result)
			if #p_Error > 0 then
				logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
				
				if not l_Player:IsValid() then
					return
				end
				
				exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "There was an error processing your request")
				return
			end
			
			logger:Write(LogType_t.Common, string.format("\"%s<%s>\" unbanned steam \"%s\"", l_PlayerName, l_PlayerSteam, l_TargetSteam))
			
			if l_Player:IsValid() then
				exports["helpers"]:ShowActivity(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Unbanned steam {lime}%s{default}", l_TargetSteam))
			else
				exports["helpers"]:ShowActivity2(l_PlayerName, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Unbanned steam {lime}%s{default}", l_TargetSteam))
			end
		end)
	end)
end

function Ban_PrintBanToConsole(p_PlayerId, p_StartTime, p_Time, p_Admin, p_Reason)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_FormatDate = exports["helpers"]:FormatDate(p_StartTime)
	local l_FormatTime = Ban_FormatTime(p_Time, "%s", "permanent", false)
	local l_FormatAdmin = Ban_FormatAdmin(p_Admin)
	
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s You are banned from this server.\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s Date: %s UTC\n", g_Config["tag"], l_FormatDate))
	l_Player:SendMsg(MessageType.Console, string.format("%s Time: %s\n", g_Config["tag"], l_FormatTime))
	l_Player:SendMsg(MessageType.Console, string.format("%s Admin: %s\n", g_Config["tag"], l_FormatAdmin))
	l_Player:SendMsg(MessageType.Console, string.format("%s Reason: %s\n", g_Config["tag"], p_Reason))
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
end