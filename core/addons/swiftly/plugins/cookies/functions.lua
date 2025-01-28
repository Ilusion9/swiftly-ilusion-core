function Cookies_CreateDatabase()
	if not g_Database:IsConnected() then
		logger:Write(LogType_t.Warning, "Could not connect to the database")
		return
	end
	
	g_Database:Query("CREATE TABLE IF NOT EXISTS `player_cookies` (`steam` VARCHAR(" .. DATABASE_STEAM_LENGTH .. ") CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci PRIMARY KEY, `cookies` JSON NOT NULL, `date` DATE NOT NULL);", function(p_Error, p_Result)
		if #p_Error > 0 then
			logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			return
		end
	end)
end

function Cookies_DeleteDatabase()
	if not g_Database:IsConnected() then
		return
	end
	
	g_Database:Query("DROP TABLE IF EXISTS `player_cookies`;", function(p_Error, p_Result)
		if #p_Error > 0 then
			logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			return
		end
	end)
end

function Cookies_DeleteOldCookies()
	if not g_Database:IsConnected() then
		return
	end
	
	g_Database:Query("DELETE FROM `player_cookies` WHERE `date` < CURRENT_DATE - INTERVAL 1 MONTH;", function(p_Error, p_Result)
		if #p_Error > 0 then
			logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			return
		end
	end)
end

function Cookies_GetCookies()
	for i = 0, playermanager:GetPlayerCap() - 1 do
		Cookies_GetPlayerCookies(i)
	end
end

function Cookies_GetPlayerCookies(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() or l_Player:IsFakeClient() then
		return
	end
	
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	g_GetCookies[l_PlayerSteam] = true
	
	if g_SetCookies[l_PlayerSteam] then
		return
	end
	
	g_Database:Query(string.format("SELECT `cookies` FROM `player_cookies` WHERE `steam` = '%s';", l_PlayerSteam), function(p_Error, p_Result)
		g_GetCookies[l_PlayerSteam] = nil
		
		if #p_Error > 0 then
			logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			return
		end
		
		if #p_Result == 0 or not l_Player:IsValid() then
			return
		end
		
		local l_Cookies = json.decode(p_Result[1]["cookies"])
		
		TriggerEvent("Cookies_OnPlayerGetCookies", p_PlayerId, l_Cookies)
	end)
end

function Cookies_LoadConfig()
	config:Reload("cookies")
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("cookies.tag")
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Cookies]"
	end
end

function Cookies_SetCookies()
	for i = 0, playermanager:GetPlayerCap() - 1 do
		Cookies_SetPlayerCookies(i)
	end
end

function Cookies_SetPlayerCookies(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or l_Player:IsFakeClient() then
		return
	end
	
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	local l_EventReturn, l_Event = TriggerEvent("Cookies_OnPlayerSetCookies", p_PlayerId)
	local l_EventCookies = l_Event:GetReturn() or {}
	
	g_SetCookies[l_PlayerSteam] = true
	
	g_Database:Query(string.format("SELECT `cookies` FROM `player_cookies` WHERE `steam` = '%s';", l_PlayerSteam), function(p_Error, p_Result)
		g_SetCookies[l_PlayerSteam] = nil
		
		if #p_Error > 0 then
			logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			
			if not g_GetCookies[l_PlayerSteam] then
				return
			end
			
			Cookies_GetPlayerCookies(p_PlayerId)
			return
		end
		
		local l_CurrentTime = GetTime()
		local l_CurrentDate = os.date("!%Y-%m-%d", math.floor(l_CurrentTime / 1000))
		
		local l_Cookies = {}
		
		if #p_Result ~= 0 then
			l_Cookies = json.decode(p_Result[1]["cookies"])
		end
		
		for l_Key, l_Value in next, l_EventCookies do
			l_Cookies[l_Key] = l_Value
		end
		
		g_SetCookies[l_PlayerSteam] = true
		
		g_Database:Query(string.format("INSERT INTO `player_cookies` (`steam`, `cookies`, `date`) VALUES ('%s', '%s', '%s') ON DUPLICATE KEY UPDATE `cookies` = VALUES(`cookies`), `date` = VALUES(`date`);", l_PlayerSteam, g_Database:EscapeString(json.encode(l_Cookies)), l_CurrentDate), function(p_Error, p_Result)
			g_SetCookies[l_PlayerSteam] = nil
			
			if #p_Error > 0 then
				logger:Write(LogType_t.Warning, string.format("Failed to query database: \"%s\"", p_Error))
			end
			
			if not g_GetCookies[l_PlayerSteam] then
				return
			end
			
			Cookies_GetPlayerCookies(p_PlayerId)
		end)
	end)
end