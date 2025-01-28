function Time_CreateDatabase()
	if not g_Database:IsConnected() then
		logger:Write(LogType_t.Warning, "Could not connect to the database")
		return
	end
	
	g_Database:Query("CREATE TABLE IF NOT EXISTS `player_time` (`steam` VARCHAR(" .. DATABASE_STEAM_LENGTH .. ") CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL, `date` DATE NOT NULL, `time` INT UNSIGNED NOT NULL, PRIMARY KEY (`steam`, `date`));", function(p_Error, p_Result)
		if #p_Error > 0 then
			logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			return
		end
	end)
end

function Time_DeleteDatabase()
	if not g_Database:IsConnected() then
		return
	end
	
	g_Database:Query("DROP TABLE IF EXISTS `player_time`;", function(p_Error, p_Result)
		if #p_Error > 0 then
			logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			return
		end
	end)
end

function Time_FormatInterval(p_Type, p_Value)
	if p_Type == INTERVAL_YEAR then
		return p_Value ~= 1 and (p_Value .. " years") or "year"
	end
	
	if p_Type == INTERVAL_MONTH then
		return p_Value ~= 1 and (p_Value .. " months") or "month"
	end
	
	if p_Type == INTERVAL_WEEK then
		return p_Value ~= 1 and (p_Value .. " weeks") or "week"
	end
	
	return p_Value ~= 1 and (p_Value .. " days") or "day"
end

function Time_FormatIntervalQuery()
	local l_CurrentTime = GetTime()
	local l_CurrentDate = os.date("!%Y-%m-%d", math.floor(l_CurrentTime / 1000))
	
	local l_Buffer = ""
	
	for i = 1, #g_Config["intervals"] do
		local l_Type = g_Intervals[g_Config["intervals"][i]["type"]]
		local l_Value = g_Config["intervals"][i]["value"]
		
		l_Buffer = l_Buffer .. string.format("COALESCE(SUM(CASE WHEN `date` > '%s' - INTERVAL %d %s THEN `time` END), 0) AS %d%s, ", l_CurrentDate, l_Value, string.upper(l_Type), l_Value, l_Type)
	end
	
	return l_Buffer
end

function Time_LoadConfig()
	config:Reload("time")
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("time.tag")
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Time]"
	end
	
	Time_LoadIntervals()
end

function Time_LoadIntervals()
	g_Config["intervals"] = {}
	
	local l_Intervals = config:Fetch("time.intervals")
	
	if type(l_Intervals) ~= "table" then
		l_Intervals = {}
	end
	
	for i = 1, #l_Intervals do
		local l_Type = l_Intervals[i]["type"]
		local l_Value = tonumber(l_Intervals[i]["value"])
		
		if l_Type ~= "day" 
			and l_Type ~= "week" 
			and l_Type ~= "month" 
			and l_Type ~= "year" 
		then
			l_Type = nil
		end
		
		if not l_Value or l_Value < 1 then
			l_Value = nil
		end
		
		if l_Type and l_Value then
			table.insert(g_Config["intervals"], {
				["type"] = g_Intervals[l_Type],
				["value"] = l_Value
			})
		end
	end
end

function Time_PerformTime(p_PlayerId, p_TargetId, p_TargetSteam)
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
	
	g_Database:Query(string.format("SELECT %sCOALESCE(SUM(`time`), 0) AS total FROM `player_time` WHERE `steam` = '%s';", Time_FormatIntervalQuery(), p_TargetId and l_TargetSteam or g_Database:EscapeString(l_TargetSteam)), function(p_Error, p_Result)
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
		
		local l_Total = 0
		local l_Intervals = {}
		
		for i = 1, #g_Config["intervals"] do
			l_Intervals[i] = 0
		end
		
		if #p_Result ~= 0 then
			l_Total = tonumber(p_Result[1]["total"])
			
			for i = 1, #g_Config["intervals"] do
				local l_Type = g_Intervals[g_Config["intervals"][i]["type"]]
				local l_Value = g_Config["intervals"][i]["value"]
				
				l_Intervals[i] = tonumber(p_Result[1][string.format("%d%s", l_Value, l_Type)])
			end
		end
		
		l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
		l_Player:SendMsg(MessageType.Console, string.format("%s Time\n", g_Config["tag"]))
		l_Player:SendMsg(MessageType.Console, string.format("%s %s: %s\n", g_Config["tag"], p_TargetId and "Player" or "Steam", p_TargetId and l_TargetName or l_TargetSteam))
		l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
		
		for i = 1, #g_Config["intervals"] do
			local l_Type = g_Config["intervals"][i]["type"]
			local l_Value = g_Config["intervals"][i]["value"]
			
			local l_FormatInterval = Time_FormatInterval(l_Type, l_Value)
			local l_FormatTime = exports["helpers"]:FormatTime(l_Intervals[i])
			
			l_Player:SendMsg(MessageType.Console, string.format("%s Past %s: %s\n", g_Config["tag"], l_FormatInterval, l_FormatTime))
		end
		
		local l_FormatTime = exports["helpers"]:FormatTime(l_Total)
		
		l_Player:SendMsg(MessageType.Console, string.format("%s Total: %s\n", g_Config["tag"], l_FormatTime))
		l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	end)
end

function Time_ResetPlayerVars(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	l_Player:SetVar("time.afk.time", nil)
	l_Player:SetVar("time.connection.time", nil)
end

function Time_SavePlayerTime(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or l_Player:IsFakeClient() then
		return
	end
	
	local l_PlayerConnectionTime = l_Player:GetVar("time.connection.time")
	
	if not l_PlayerConnectionTime then
		return
	end
	
	local l_CurrentTime = GetTime()
	local l_CurrentDate = os.date("!%Y-%m-%d", math.floor(l_CurrentTime / 1000))
	
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	local l_PlayerAFKTime = l_Player:GetVar("time.afk.time") or 0
	
	l_PlayerAFKTime = l_PlayerAFKTime + exports["afk"]:GetPlayerAFKTime(p_PlayerId)
	
	local l_Time = l_CurrentTime - l_PlayerConnectionTime - l_PlayerAFKTime
	
	l_Player:SetVar("time.afk.time", nil)
	l_Player:SetVar("time.connection.time", l_CurrentTime)
	
	g_Database:Query(string.format("INSERT INTO `player_time` (`steam`, `date`, `time`) VALUES ('%s', '%s', %d) ON DUPLICATE KEY UPDATE time = `time` + VALUES(`time`);", l_PlayerSteam, l_CurrentDate, math.max(l_Time, 0)), function(p_Error, p_Result)
		if #p_Error > 0 then
			logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			return
		end
	end)
end

function Time_SetPlayerConnectionTime(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	local l_CurrentTime = GetTime()
	
	l_Player:SetVar("time.connection.time", l_CurrentTime)
end