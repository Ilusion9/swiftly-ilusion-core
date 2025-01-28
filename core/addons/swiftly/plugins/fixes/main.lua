AddEventHandler("OnPluginStart", function(p_Event)
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	g_PluginIsLoading = true
	g_PluginIsLoadingLate = l_ServerTime > 0
	
	Fixes_ResetVars()
end)

AddEventHandler("OnAllPluginsLoaded", function(p_Event)
	if g_PluginIsLoadingLate then
		for i = 0, playermanager:GetPlayerCap() - 1 do
			Fixes_ResetPlayerVars(i)
		end
		
		Fixes_SetConVars()
	end
	
	if g_PluginIsLoading then
		if not g_ThinkTimer then
			Fixes_Think()
			g_ThinkTimer = SetTimer(THINK_INTERVAL, Fixes_Think)
		end
	end
	
	g_PluginIsLoading = nil
	g_PluginIsLoadingLate = nil
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Fixes_ResetVars()
	Fixes_SetConVars()
	
	if not g_PluginIsLoading then
		if not g_ThinkTimer then
			Fixes_Think()
			g_ThinkTimer = SetTimer(THINK_INTERVAL, Fixes_Think)
		end
	end
	
	SetTimeout(100, function()
		Fixes_SetConVars()
	end)
end)

AddEventHandler("OnMapUnload", function(p_Event, p_Map)
	if g_ThinkTimer then
		StopTimer(g_ThinkTimer)
		g_ThinkTimer = nil
	end
end)

AddEventHandler("OnPostRoundEnd", function(p_Event)
	Fixes_CheckMatchStatus()
end)

AddEventHandler("OnPostRoundAnnounceMatchStart", function(p_Event)
	for i = 0, playermanager:GetPlayerCap() - 1 do
		local l_PlayerIter = GetPlayer(i)
		
		if l_PlayerIter and l_PlayerIter:IsValid() then
			l_PlayerIter:SetVar("fixes.respawn.time", nil)
		end
	end
end)

AddEventHandler("Helpers_OnTerminateRoundPre", function(p_Event, p_Reason, p_Identifier)
	if type(p_Identifier) == "string" then
		return
	end
	
	local l_Reason = p_Event:GetReturn() or p_Reason
	
	if l_Reason ~= RoundEndReason_t.RoundDraw then
		return
	end
	
	local l_PlayerCount = exports["helpers"]:GetTeamPlayerAliveCount({Team.T, Team.CT}, false)
	
	if l_PlayerCount[Team.T] == 0 then
		p_Event:SetReturn(RoundEndReason_t.CTsWin)
	elseif l_PlayerCount[Team.CT] == 0 then
		p_Event:SetReturn(RoundEndReason_t.TerroristsWin)
	end
end)

AddEventHandler("OnClientKeyStateChange", function(p_Event, p_PlayerId, p_Key, p_IsPressed)
	if not p_IsPressed or p_Key ~= "space" then
		return
	end
	
	if not exports["helpers"]:IsWarmupPeriod() then
		return
	end
	
	Fixes_RespawnPlayerOnRequest(p_PlayerId)
end)

AddEventHandler("OnPostPlayerDisconnect", function(p_Event)
	Fixes_CheckRoundStatus()
end)

AddEventHandler("OnPostPlayerSpawn", function(p_Event)
	if not exports["helpers"]:IsWarmupPeriod() then
		return
	end
	
	local l_PlayerId = p_Event:GetInt("userid")
	local l_Player = GetPlayer(l_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	l_Player:SetVar("fixes.death.time", nil)
	l_Player:SetVar("fixes.respawn.time", nil)
end)

AddEventHandler("OnPostPlayerDeath", function(p_Event)
	local l_PlayerId = p_Event:GetInt("userid")
	local l_Player = GetPlayer(l_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if exports["helpers"]:IsWarmupPeriod() then
		local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
		
		l_Player:SetVar("fixes.death.time", l_ServerTime)
		l_Player:SetVar("fixes.respawn.time", l_ServerTime + exports["helpers"]:GetRespawnTime())
	else
		l_Player:SetVar("fixes.death.time", nil)
		l_Player:SetVar("fixes.respawn.time", nil)
	end
	
	Fixes_CheckRoundStatus()
end)

AddEventHandler("OnPostPlayerTeam", function(p_Event)
	if p_Event:GetBool("disconnect") then
		return
	end
	
	local l_PlayerId = p_Event:GetInt("userid")
	local l_Player = GetPlayer(l_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_Team = p_Event:GetInt("team")
	local l_OldTeam = p_Event:GetInt("oldteam")
	
	if exports["helpers"]:IsWarmupPeriod() then
		l_Player:SetVar("fixes.death.time", nil)
		
		if l_Team > Team.Spectator then
			local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
			
			l_Player:SetVar("fixes.respawn.time", l_ServerTime + 100)
		else
			l_Player:SetVar("fixes.respawn.time", nil)
		end
	end
	
	Fixes_SetPlayerTeam(l_PlayerId, l_Team)
	
	if l_Team > Team.Spectator then
		if l_OldTeam == Team.None or l_OldTeam == Team.Spectator then
			Fixes_CheckWarmupStatus()
		end
	end
	
	Fixes_CheckRoundStatus()
end)