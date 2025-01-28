function Player_AddPlayerInHistory(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or l_Player:IsFakeClient() then
		return
	end
	
	local l_CurrentTime = GetTime()
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	table.insert(g_History, {
		["name"] = l_PlayerName,
		["steam"] = l_PlayerSteam,
		["disconnected_at"] = l_CurrentTime
	})
end

function Player_FormatReason(p_Reason)
	return #p_Reason ~= 0 and string.format(" (%s)", p_Reason) or ""
end

function Player_IsPlayerInSlapQueue(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return false
	end
	
	return l_Player:GetVar("player.slap.queue") or false
end

function Player_IsPlayerInSlayQueue(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return false
	end
	
	return l_Player:GetVar("player.slay.queue") or false
end

function Player_LoadConfig()
	config:Reload("player")
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("player.tag")
	g_Config["history.size"] = tonumber(config:Fetch("player.history.size"))
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Player]"
	end
	
	if not g_Config["history.size"] or g_Config["history.size"] < 0 then
		g_Config["history.size"] = HISTORY_SIZE
	end
end

function Player_LoadHistory()
	g_History = {}
	
	local l_History = json.decode(files:Read("playerhistory.json"))
	
	if type(l_History) == "table" and #l_History ~= 0 then
		g_History = l_History
	end
end

function Player_ResetPlayerVars(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	l_Player:SetVar("player.slap.queue", nil)
	l_Player:SetVar("player.slay.queue", nil)
end

function Player_SaveHistory()
	if #g_History == 0 then
		return
	end
	
	for i = #g_History - g_Config["history.size"], 1, -1 do
		table.remove(g_History, i)
	end
	
	files:Write("playerhistory.json", json.encode(g_History), false)
end