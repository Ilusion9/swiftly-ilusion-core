function Stats_CreateDatabase()
	if not g_Database:IsConnected() then
		logger:Write(LogType_t.Warning, "Could not connect to the database")
		return
	end
	
	g_Database:Query("CREATE TABLE IF NOT EXISTS `player_stats_usernames` (`steam` VARCHAR(" .. DATABASE_STEAM_LENGTH .. ") CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci PRIMARY KEY, `username` VARCHAR(" .. DATABASE_USERNAME_LENGTH .. ") CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL);", function(p_Error, p_Result)
		if #p_Error > 0 then
			logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			return
		end
		
		g_Database:Query("CREATE TABLE IF NOT EXISTS `player_stats` (`steam` VARCHAR(" .. DATABASE_STEAM_LENGTH .. ") CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL, `date` DATE NOT NULL, `points` INT NOT NULL, `custom1` INT UNSIGNED NOT NULL, `custom2` INT UNSIGNED NOT NULL, `custom3` INT UNSIGNED NOT NULL, `custom4` INT UNSIGNED NOT NULL, `custom5` INT UNSIGNED NOT NULL, `custom6` INT UNSIGNED NOT NULL, `custom7` INT UNSIGNED NOT NULL, `custom8` INT UNSIGNED NOT NULL, `custom9` INT UNSIGNED NOT NULL, `custom10` INT UNSIGNED NOT NULL, `custom11` INT UNSIGNED NOT NULL, `custom12` INT UNSIGNED NOT NULL, PRIMARY KEY (`steam`, `date`));", function(p_Error, p_Result)
			if #p_Error > 0 then
				logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
				return
			end
		end)
	end)
end

function Stats_DeleteDatabase()
	if not g_Database:IsConnected() then
		return
	end
	
	g_Database:Query("DROP TABLE IF EXISTS `player_stats_usernames`;", function(p_Error, p_Result)
		if #p_Error > 0 then
			logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			return
		end
		
		g_Database:Query("DROP TABLE IF EXISTS `player_stats`;", function(p_Error, p_Result)
			if #p_Error > 0 then
				logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
				return
			end
		end)
	end)
end

function Stats_DeleteOldStats()
	if not g_Database:IsConnected() then
		return
	end
	
	g_Database:Query("DELETE FROM `player_stats` WHERE `date` < CURRENT_DATE - INTERVAL 1 MONTH;", function(p_Error, p_Result)
		if #p_Error > 0 then
			logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			return
		end
		
		g_Database:Query("DELETE a.* FROM `player_stats_usernames` a LEFT JOIN `player_stats` b ON b.`steam` = a.`steam` WHERE b.`steam` IS NULL;", function(p_Error, p_Result)
			if #p_Error > 0 then
				logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
				return
			end
		end)
	end)
end

function Stats_LoadConfig()
	config:Reload("stats")
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("stats.tag")
	g_Config["top.size"] = tonumber(config:Fetch("stats.top.size"))
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Stats]"
	end
	
	if not g_Config["top.size"] or g_Config["top.size"] < 0 then
		g_Config["top.size"] = TOP_SIZE
	end
end

function Stats_PerformRank(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	if not g_Database:IsConnected() then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "There was an error processing your request")
		return
	end
	
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	g_Database:Query(string.format("SELECT COUNT(`steam`) AS rank, 0 AS points FROM `player_stats_usernames` UNION ALL SELECT r.`rank`, r.`points` FROM (SELECT @rank := @rank + 1 AS rank, s.* FROM (SELECT `steam`, SUM(`points`) AS points FROM `player_stats` GROUP BY `steam` ORDER BY `points` DESC, `steam` ASC) s, (SELECT @rank := 0) init) r WHERE r.`steam` = '%s';", l_PlayerSteam), function(p_Error, p_Result)
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
		
		local l_Count = tonumber(p_Result[1]["rank"]) + (#p_Result ~= 2 and 1 or 0)
		
		local l_Rank = tonumber(p_Result[#p_Result]["rank"]) + (#p_Result ~= 2 and 1 or 0)
		local l_Points = tonumber(p_Result[#p_Result]["points"])
		
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", string.format("You are ranked {lime}%d{default} of {lime}%d{default} with {lime}%d{default} %s", l_Rank, l_Count, l_Points, l_Points ~= 1 and "points" or "point"))
	end)
end

function Stats_PerformStats(p_PlayerId, p_TargetId, p_TargetSteam)
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
	
	g_Database:Query(string.format("SELECT COUNT(`steam`) AS rank, 0 AS points, 0 AS custom1, 0 AS custom2, 0 AS custom3, 0 AS custom4, 0 AS custom5, 0 AS custom6, 0 AS custom7, 0 AS custom8, 0 AS custom9, 0 AS custom10, 0 AS custom11, 0 AS custom12 FROM `player_stats_usernames` UNION ALL SELECT r.`rank`, r.`points`, r.`custom1`, r.`custom2`, r.`custom3`, r.`custom4`, r.`custom5`, r.`custom6`, r.`custom7`, r.`custom8`, r.`custom9`, r.`custom10`, r.`custom11`, r.`custom12` FROM (SELECT @rank := @rank + 1 AS rank, s.* FROM (SELECT `steam`, SUM(`points`) AS points, SUM(`custom1`) AS custom1, SUM(`custom2`) AS custom2, SUM(`custom3`) AS custom3, SUM(`custom4`) AS custom4, SUM(`custom5`) AS custom5, SUM(`custom6`) AS custom6, SUM(`custom7`) AS custom7, SUM(`custom8`) AS custom8, SUM(`custom9`) AS custom9, SUM(`custom10`) AS custom10, SUM(`custom11`) AS custom11, SUM(`custom12`) AS custom12 FROM `player_stats` GROUP BY `steam` ORDER BY `points` DESC, `steam` ASC) s, (SELECT @rank := 0) init) r WHERE r.`steam` = '%s';", p_TargetId and l_TargetSteam or g_Database:EscapeString(l_TargetSteam)), function(p_Error, p_Result)
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
		
		local l_Count = tonumber(p_Result[1]["rank"]) + (#p_Result ~= 2 and 1 or 0)
		
		local l_Rank = tonumber(p_Result[#p_Result]["rank"]) + (#p_Result ~= 2 and 1 or 0)
		local l_Points = tonumber(p_Result[#p_Result]["points"])
		
		local l_Custom1 = tonumber(p_Result[#p_Result]["custom1"])
		local l_Custom2 = tonumber(p_Result[#p_Result]["custom2"])
		local l_Custom3 = tonumber(p_Result[#p_Result]["custom3"])
		local l_Custom4 = tonumber(p_Result[#p_Result]["custom4"])
		local l_Custom5 = tonumber(p_Result[#p_Result]["custom5"])
		local l_Custom6 = tonumber(p_Result[#p_Result]["custom6"])
		local l_Custom7 = tonumber(p_Result[#p_Result]["custom7"])
		local l_Custom8 = tonumber(p_Result[#p_Result]["custom8"])
		local l_Custom9 = tonumber(p_Result[#p_Result]["custom9"])
		local l_Custom10 = tonumber(p_Result[#p_Result]["custom10"])
		local l_Custom11 = tonumber(p_Result[#p_Result]["custom11"])
		local l_Custom12 = tonumber(p_Result[#p_Result]["custom12"])
		
		local l_Stats = {
			["custom1"] = l_Custom1,
			["custom2"] = l_Custom2,
			["custom3"] = l_Custom3,
			["custom4"] = l_Custom4,
			["custom5"] = l_Custom5,
			["custom6"] = l_Custom6,
			["custom7"] = l_Custom7,
			["custom8"] = l_Custom8,
			["custom9"] = l_Custom9,
			["custom10"] = l_Custom10,
			["custom11"] = l_Custom11,
			["custom12"] = l_Custom12
		}
		
		local l_EventReturn, l_Event = TriggerEvent("Stats_OnPlayerGetStats", p_PlayerId, l_Stats)
		local l_EventResult = l_Event:GetReturn() or {}
		
		l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
		l_Player:SendMsg(MessageType.Console, string.format("%s Stats\n", g_Config["tag"]))
		l_Player:SendMsg(MessageType.Console, string.format("%s %s: %s\n", g_Config["tag"], p_TargetId and "Player" or "Steam", p_TargetId and l_TargetName or l_TargetSteam))
		l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
		
		l_Player:SendMsg(MessageType.Console, string.format("%s Rank: %d of %d\n", g_Config["tag"], l_Rank, l_Count))
		l_Player:SendMsg(MessageType.Console, string.format("%s Points: %d\n", g_Config["tag"], l_Points))
		l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
		
		if #l_EventResult == 0 then
			return
		end
		
		for i = 1, #l_EventResult do
			l_Player:SendMsg(MessageType.Console, string.format("%s %s\n", g_Config["tag"], l_EventResult[i]))
		end
		
		l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	end)
end

function Stats_PerformTop(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	if not g_Database:IsConnected() then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "There was an error processing your request")
		return
	end
	
	g_Database:Query(string.format("SELECT r.`rank`, r.`username`, r.`points`, r.`custom1`, r.`custom2`, r.`custom3`, r.`custom4`, r.`custom5`, r.`custom6`, r.`custom7`, r.`custom8`, r.`custom9`, r.`custom10`, r.`custom11`, r.`custom12` FROM (SELECT @rank := @rank + 1 AS rank, s.* FROM (SELECT b.`username`, SUM(a.`points`) AS points, SUM(a.`custom1`) AS custom1, SUM(a.`custom2`) AS custom2, SUM(a.`custom3`) AS custom3, SUM(a.`custom4`) AS custom4, SUM(a.`custom5`) AS custom5, SUM(a.`custom6`) AS custom6, SUM(a.`custom7`) AS custom7, SUM(a.`custom8`) AS custom8, SUM(a.`custom9`) AS custom9, SUM(a.`custom10`) AS custom10, SUM(a.`custom11`) AS custom11, SUM(a.`custom12`) AS custom12 FROM `player_stats` a JOIN `player_stats_usernames` b ON a.`steam` = b.`steam` GROUP BY a.`steam` ORDER BY `points` DESC, a.`steam` ASC LIMIT %d) s, (SELECT @rank := 0) init) r;", g_Config["top.size"]), function(p_Error, p_Result)
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
		
		local l_Body = {}
		local l_Header = {
			"#",
			"Username",
			"Points"
		}
		
		local l_Stats = {}
		
		for i = 1, #p_Result do
			local l_Rank = tonumber(p_Result[i]["rank"])
			local l_Username = p_Result[i]["username"]
			local l_Points = tonumber(p_Result[i]["points"])
			
			local l_Custom1 = tonumber(p_Result[i]["custom1"])
			local l_Custom2 = tonumber(p_Result[i]["custom2"])
			local l_Custom3 = tonumber(p_Result[i]["custom3"])
			local l_Custom4 = tonumber(p_Result[i]["custom4"])
			local l_Custom5 = tonumber(p_Result[i]["custom5"])
			local l_Custom6 = tonumber(p_Result[i]["custom6"])
			local l_Custom7 = tonumber(p_Result[i]["custom7"])
			local l_Custom8 = tonumber(p_Result[i]["custom8"])
			local l_Custom9 = tonumber(p_Result[i]["custom9"])
			local l_Custom10 = tonumber(p_Result[i]["custom10"])
			local l_Custom11 = tonumber(p_Result[i]["custom11"])
			local l_Custom12 = tonumber(p_Result[i]["custom12"])
			
			table.insert(l_Body, {
				string.format("%02d.", l_Rank),
				l_Username,
				l_Points
			})
			
			table.insert(l_Stats, {
				["custom1"] = l_Custom1,
				["custom2"] = l_Custom2,
				["custom3"] = l_Custom3,
				["custom4"] = l_Custom4,
				["custom5"] = l_Custom5,
				["custom6"] = l_Custom6,
				["custom7"] = l_Custom7,
				["custom8"] = l_Custom8,
				["custom9"] = l_Custom9,
				["custom10"] = l_Custom10,
				["custom11"] = l_Custom11,
				["custom12"] = l_Custom12
			})
		end
		
		local l_EventReturn, l_Event = TriggerEvent("Stats_OnPlayerGetTop", p_PlayerId, l_Stats)
		local l_EventResult = l_Event:GetReturn() or {}
		
		l_EventResult["header"] = l_EventResult["header"] or {}
		l_EventResult["body"] = l_EventResult["body"] or {}
		
		for i = 1, #l_EventResult["header"] do
			table.insert(l_Header, l_EventResult["header"][i])
		end
		
		for i = 1, #l_EventResult["body"] do
			for j = 1, #l_EventResult["body"][i] do
				table.insert(l_Body[i], l_EventResult["body"][i][j])
			end
		end
		
		l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
		l_Player:SendMsg(MessageType.Console, string.format("%s Top\n", g_Config["tag"]))
		l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
		
		exports["helpers"]:PrintTableToConsole(p_PlayerId, g_Config["tag"], l_Header, l_Body)
		l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	end)
end

function Stats_SavePlayerStats(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or l_Player:IsFakeClient() then
		return
	end
	
	local l_CurrentTime = GetTime()
	local l_CurrentDate = os.date("!%Y-%m-%d", math.floor(l_CurrentTime / 1000))
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	local l_EventReturn, l_Event = TriggerEvent("Stats_OnPlayerSetStats", p_PlayerId)
	local l_EventStats = l_Event:GetReturn() or {}
	
	g_Database:Query(string.format("INSERT INTO `player_stats_usernames` (`steam`, `username`) VALUES ('%s', '%s') ON DUPLICATE KEY UPDATE `username` = VALUES(`username`);", l_PlayerSteam, g_Database:EscapeString(l_PlayerName)), function(p_Error, p_Result)
		if #p_Error > 0 then
			logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			return
		end
		
		g_Database:Query(string.format("INSERT INTO `player_stats` (`steam`, `date`, `points`, `custom1`, `custom2`, `custom3`, `custom4`, `custom5`, `custom6`, `custom7`, `custom8`, `custom9`, `custom10`, `custom11`, `custom12`) VALUES ('%s', '%s', %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d) ON DUPLICATE KEY UPDATE `points` = `points` + VALUES(`points`), `custom1` = `custom1` + VALUES(`custom1`), `custom2` = `custom2` + VALUES(`custom2`), `custom3` = `custom3` + VALUES(`custom3`), `custom4` = `custom4` + VALUES(`custom4`), `custom5` = `custom5` + VALUES(`custom5`), `custom6` = `custom6` + VALUES(`custom6`), `custom7` = `custom7` + VALUES(`custom7`), `custom8` = `custom8` + VALUES(`custom8`), `custom9` = `custom9` + VALUES(`custom9`), `custom10` = `custom10` + VALUES(`custom10`), `custom11` = `custom11` + VALUES(`custom11`), `custom12` = `custom12` + VALUES(`custom12`);", l_PlayerSteam, l_CurrentDate, l_EventStats["points"] or 0, l_EventStats["custom1"] or 0, l_EventStats["custom2"] or 0, l_EventStats["custom3"] or 0, l_EventStats["custom4"] or 0, l_EventStats["custom5"] or 0, l_EventStats["custom6"] or 0, l_EventStats["custom7"] or 0, l_EventStats["custom8"] or 0, l_EventStats["custom9"] or 0, l_EventStats["custom10"] or 0, l_EventStats["custom11"] or 0, l_EventStats["custom12"] or 0), function(p_Error, p_Result)
			if #p_Error > 0 then
				logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
				return
			end
		end)
	end)
end

function Stats_SaveStats()
	for i = 0, playermanager:GetPlayerCap() - 1 do
		Stats_SavePlayerStats(i)
	end
end