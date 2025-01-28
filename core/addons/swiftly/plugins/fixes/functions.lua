function Fixes_CheckMatchStatus(p_Delay)
	SetTimeout(100, function()
		if not exports["helpers"]:IsMatchOver() then
			return
		end
		
		local l_PlayerCount = exports["helpers"]:GetPlayerCount(true)
		
		if l_PlayerCount ~= 0 then
			return
		end
		
		TriggerEvent("OnCsIntermission")
		TriggerEvent("OnPostCsIntermission")
	end)
end

function Fixes_CheckRoundStatus()
	if exports["helpers"]:IsWarmupPeriod() 
		or exports["helpers"]:IsRoundOver() 
		or exports["helpers"]:IsMatchOver() 
	then
		return
	end
	
	SetTimeout(100, function()
		if exports["helpers"]:IsWarmupPeriod() 
			or exports["helpers"]:IsRoundOver() 
			or exports["helpers"]:IsMatchOver() 
		then
			return
		end
		
		local l_PlayerCount = exports["helpers"]:GetTeamPlayerAliveCount({Team.T, Team.CT}, false)
		
		if l_PlayerCount[Team.T] == 0 then
			exports["helpers"]:TerminateRound(RoundEndReason_t.CTsWin, "fixes")
		elseif l_PlayerCount[Team.CT] == 0 then
			exports["helpers"]:TerminateRound(RoundEndReason_t.TerroristsWin, "fixes")
		end
	end)
end

function Fixes_CheckWarmupStatus()
	if not exports["helpers"]:IsWarmupPeriod() then
		return
	end
	
	SetTimeout(100, function()
		if not exports["helpers"]:IsWarmupPeriod() then
			return
		end
		
		local l_PlayerCount = exports["helpers"]:GetTeamPlayerCount({Team.T, Team.CT}, true)
		
		if l_PlayerCount[Team.T] + l_PlayerCount[Team.CT] ~= 1 then
			return
		end
		
		server:Execute("mp_warmup_start")
	end)
end

function Fixes_ResetPlayerVars(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	l_Player:SetVar("fixes.death.time", nil)
	l_Player:SetVar("fixes.respawn.time", nil)
end

function Fixes_ResetVars()
	g_RuleEntity = nil
	
	g_ThinkFunctionTime = nil
end

function Fixes_RespawnPlayer(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerRespawnTime = l_Player:GetVar("fixes.respawn.time")
	
	if not l_PlayerRespawnTime then
		return
	end
	
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	if l_PlayerRespawnTime > l_ServerTime then
		return
	end
	
	l_Player:SetVar("fixes.respawn.time", nil)
	l_Player:Respawn()
end

function Fixes_RespawnPlayerOnRequest(p_PlayerId)
	if convar:Get("mp_deathcam_skippable") == 0 then
		return
	end
	
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerRespawnTime = l_Player:GetVar("fixes.respawn.time")
	
	if not l_PlayerRespawnTime then
		return
	end
	
	local l_PlayerDeathTime = l_Player:GetVar("fixes.death.time")
	
	if not l_PlayerDeathTime then
		return
	end
	
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	local l_RespawnLockTime = math.max(convar:Get("spec_freeze_time_lock"), 0)
	
	if l_PlayerDeathTime + math.floor(l_RespawnLockTime * 1000) > l_ServerTime then
		return
	end
	
	l_Player:SetVar("fixes.respawn.time", nil)
	l_Player:Respawn()
end

function Fixes_RestorePlayerName(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	exports["helpers"]:RestorePlayerName(p_PlayerId)
end

function Fixes_SetConVars()
	local l_Config = {}
	
	l_Config["sv_disconnected_player_data_hold_time"] = 1
	l_Config["sv_disconnected_players_cleanup_delay"] = 1
	l_Config["sv_hibernate_postgame_delay"] = 60
	l_Config["sv_hibernate_when_empty"] = 0
	
	for l_Key, l_Value in next, l_Config do
		exports["helpers"]:SetConVar(l_Key, l_Value)
	end
end

function Fixes_SetPlayerTeam(p_PlayerId, p_Team)
	NextTick(function()
		local l_Player = GetPlayer(p_PlayerId)
		
		if not l_Player or not l_Player:IsValid() then
			return
		end
		
		exports["helpers"]:SetPlayerTeam(p_PlayerId, p_Team)
	end)
end

function Fixes_Think()
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	for i = 0, playermanager:GetPlayerCap() - 1 do
		if not g_ThinkFunctionTime or l_ServerTime >= g_ThinkFunctionTime + THINK_FUNCTION_INTERVAL then
			Fixes_RespawnPlayer(i, false)
			Fixes_RestorePlayerName(i)
		end
	end
	
	if not g_ThinkFunctionTime or l_ServerTime >= g_ThinkFunctionTime + THINK_FUNCTION_INTERVAL then
		g_ThinkFunctionTime = l_ServerTime
	end
end