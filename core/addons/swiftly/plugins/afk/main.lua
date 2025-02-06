AddEventHandler("OnPluginStart", function(p_Event)
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	g_PluginIsLoading = true
	g_PluginIsLoadingLate = l_ServerTime > 0
	
	AFK_LoadConfig()
end)

AddEventHandler("OnAllPluginsLoaded", function(p_Event)
	if g_PluginIsLoadingLate then
		for i = 0, playermanager:GetPlayerCap() - 1 do
			AFK_ResetPlayerVars(i)
		end
	end
	
	if g_PluginIsLoading then
		if not g_ThinkTimer then
			AFK_Think()
			g_ThinkTimer = SetTimer(THINK_INTERVAL, AFK_Think)
		end
	end
	
	g_PluginIsLoading = nil
	g_PluginIsLoadingLate = nil
end)

AddEventHandler("OnPluginStop", function(p_Event)
	for i = 0, playermanager:GetPlayerCap() - 1 do
		AFK_ResetPlayerSlayTime(i, true)
		AFK_ResetPlayerMoveTime(i, true)
		AFK_ResetPlayerKickTime(i, true)
	end
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	AFK_LoadConfig()
	
	if not g_PluginIsLoading then
		if not g_ThinkTimer then
			AFK_Think()
			g_ThinkTimer = SetTimer(THINK_INTERVAL, AFK_Think)
		end
	end
end)

AddEventHandler("OnMapUnload", function(p_Event, p_Map)
	if g_ThinkTimer then
		StopTimer(g_ThinkTimer)
		g_ThinkTimer = nil
	end
end)

AddEventHandler("OnPostCsIntermission", function(p_Event)
	for i = 0, playermanager:GetPlayerCap() - 1 do
		AFK_ResetPlayerSlayTime(i)
		AFK_ResetPlayerMoveTime(i)
		AFK_ResetPlayerKickTime(i)
	end
end)

AddEventHandler("OnClientChat", function(p_Event, p_PlayerId, p_Text, p_TeamOnly)
	AFK_SetPlayerActive(p_PlayerId)
end)

AddEventHandler("OnClientCommand", function(p_Event, p_PlayerId, p_Command)
	AFK_SetPlayerActive(p_PlayerId)
end)

AddEventHandler("OnClientKeyStateChange", function(p_Event, p_PlayerId, p_Key, p_IsPressed)
	AFK_SetPlayerActive(p_PlayerId)
end)

AddEventHandler("OnPlayerDisconnect", function(p_Event)
	AFK_CheckPlayerMoveCount()
	AFK_CheckPlayerKickCount()
end)

AddEventHandler("OnPostPlayerSpawn", function(p_Event)
	local l_PlayerId = p_Event:GetInt("userid")
	
	AFK_ResetPlayerSlayTime(l_PlayerId)
end)

AddEventHandler("OnPostPlayerDeath", function(p_Event)
	local l_PlayerId = p_Event:GetInt("userid")
	
	AFK_ResetPlayerSlayTime(l_PlayerId)
end)

AddEventHandler("OnPostPlayerTeam", function(p_Event)
	if p_Event:GetBool("disconnect") then
		return
	end
	
	local l_Team = p_Event:GetInt("team")
	local l_OldTeam = p_Event:GetInt("oldteam")
	
	if l_OldTeam > Team.Spectator and l_Team > Team.Spectator then
		return
	end
	
	local l_PlayerId = p_Event:GetInt("userid")
	
	AFK_ResetPlayerMoveTime(l_PlayerId)
	AFK_CheckPlayerMoveCount()
end)

AddEventHandler("OnPostPlayerShoot", function(p_Event)
	local l_PlayerId = p_Event:GetInt("userid")
	
	AFK_SetPlayerActive(l_PlayerId)
end)