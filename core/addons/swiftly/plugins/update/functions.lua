function Update_LoadConfig()
	config:Reload("update")
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("update.tag")
	g_Config["interval"] = tonumber(config:Fetch("update.interval"))
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Update]"
	end
	
	if not g_Config["interval"] or g_Config["interval"] < 1 then
		g_Config["interval"] = 1
	end
	
	g_Config["interval"] = math.floor(g_Config["interval"] * 1000)
end

function Update_LoadVersion()
	if not files:ExistsPath("steam.inf") then
		return
	end
	
	local l_Content = string.split(files:Read("steam.inf"), "\n")
	
	for i = 1, #l_Content do
		if string.sub(l_Content[i], 1, 13) == "PatchVersion=" then
			g_Version = string.sub(l_Content[i], 14)
			break
		end
	end
end

function Update_OnVersionQueryResponse(p_Status, p_Body, p_Headers, p_Error)
	if p_Status ~= 200 then
		return
	end
	
	local l_Response = json.decode(p_Body)
	
	if type(l_Response) ~= "table" 
		or type(l_Response["response"]) ~= "table" 
		or type(l_Response["response"]["up_to_date"]) ~= "boolean" 
		or l_Response["response"]["up_to_date"] 
	then
		return
	end
	
	Update_RestartServer()
end

function Update_QueryVersion()
	if not g_Version then
		return
	end
	
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	if g_VersionQueryTime and g_VersionQueryTime + g_Config["interval"] > l_ServerTime then
		return
	end
	
	local l_Url = string.format("http://api.steampowered.com/ISteamApps/UpToDateCheck/v1/?appid=730&version=%s", g_Version)
	
	PerformHTTPRequest(l_Url, Update_OnVersionQueryResponse)
	
	g_VersionQueryTime = l_ServerTime
end

function Update_ResetVars()
	g_Version = nil
	g_VersionQueryTime = nil
end

function Update_RestartServer()
	if g_ThinkTimer then
		StopTimer(g_ThinkTimer)
		g_ThinkTimer = nil
	end
	
	for i = 0, playermanager:GetPlayerCap() - 1 do
		local l_PlayerIter = GetPlayer(i)
		
		if l_PlayerIter and l_PlayerIter:IsValid() and not l_PlayerIter:IsFakeClient() then
			l_PlayerIter:SendMsg(MessageType.Chat, string.format("{lime}%s{default} The server will restart due to a new game update", g_Config["tag"]))
			l_PlayerIter:SendMsg(MessageType.Chat, string.format("{lime}%s{default} The server will restart due to a new game update", g_Config["tag"]))
			l_PlayerIter:SendMsg(MessageType.Chat, string.format("{lime}%s{default} The server will restart due to a new game update", g_Config["tag"]))
			l_PlayerIter:SendMsg(MessageType.Chat, string.format("{lime}%s{default} The server will restart due to a new game update", g_Config["tag"]))
			l_PlayerIter:SendMsg(MessageType.Chat, string.format("{lime}%s{default} The server will restart due to a new game update", g_Config["tag"]))
		end
	end
	
	SetTimeout(3000, function()
		for i = 0, playermanager:GetPlayerCap() - 1 do
			local l_PlayerIter = GetPlayer(i)
			
			if l_PlayerIter and l_PlayerIter:IsValid() and not l_PlayerIter:IsFakeClient() then
				l_PlayerIter:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
				l_PlayerIter:SendMsg(MessageType.Console, string.format("%s The server will restart due to a new game update\n", g_Config["tag"]))
				l_PlayerIter:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
				
				exports["helpers"]:KickPlayer(i)
			end
		end
	end)
	
	SetTimeout(5000, function()
		logger:Write(LogType_t.Common, "\"Console<0>\" restarted the server")
		
		server:Execute("quit")
	end)
end

function Update_Think()
	Update_QueryVersion()
end