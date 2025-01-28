AddEventHandler("OnPluginStart", function(p_Event)
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	g_PluginIsLoading = true
	g_PluginIsLoadingLate = l_ServerTime > 0
	
	g_Database = Database("gag")
	
	Gag_LoadConfig()
	Gag_CreateDatabase()
end)

AddEventHandler("OnAllPluginsLoaded", function(p_Event)
	if g_PluginIsLoadingLate then
		for i = 0, playermanager:GetPlayerCap() - 1 do
			Gag_ResetPlayerVars(i)
			
			Gag_RemovePlayerGag(i)
			Gag_LoadPlayerGag(i)
		end
	end
	
	if g_PluginIsLoading then
		if not g_ThinkTimer then
			Gag_Think()
			g_ThinkTimer = SetTimer(THINK_INTERVAL, Gag_Think)
		end
	end
	
	g_PluginIsLoading = nil
	g_PluginIsLoadingLate = nil
end)

AddEventHandler("OnPluginStop", function(p_Event)
	for i = 0, playermanager:GetPlayerCap() - 1 do
		Gag_RemovePlayerGag(i)
	end
end)

AddEventHandler("Helpers_OnPluginStartLate", function(p_Event)
	for i = 0, playermanager:GetPlayerCap() - 1 do
		Gag_SetPlayerClanTag(i)
	end
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Gag_LoadConfig()
	
	if not g_PluginIsLoading then
		if not g_ThinkTimer then
			Gag_Think()
			g_ThinkTimer = SetTimer(THINK_INTERVAL, Gag_Think)
		end
	end
end)

AddEventHandler("OnMapUnload", function(p_Event, p_Map)
	if g_ThinkTimer then
		StopTimer(g_ThinkTimer)
		g_ThinkTimer = nil
	end
end)

AddEventHandler("OnClientChat", function(p_Event, p_PlayerId, p_Text, p_TeamOnly)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return EventResult.Continue
	end
	
	local l_PlayerGag = Gag_GetPlayerGag(p_PlayerId)
	
	if not l_PlayerGag or l_PlayerGag["timeleft"] == 0 then
		return EventResult.Continue
	end
	
	if exports["helpers"]:IsChatTrigger(string.sub(p_Text, 1, 1)) then
		p_Event:SetReturn(false)
		return EventResult.Handled
	end
	
	local l_FormatTime = Gag_FormatTime(l_PlayerGag["timeleft"], "for {lightred}%s{default}", "permanently", true)
	local l_FormatReason = Gag_FormatReason(l_PlayerGag["reason"])
	
	l_Player:SendMsg(MessageType.Chat, string.format("{lightred}%s{default} You are gagged %s%s", g_Config["tag"], l_FormatTime, l_FormatReason))
	
	p_Event:SetReturn(false)
	return EventResult.Handled
end)

AddEventHandler("OnPostPlayerConnectFull", function(p_Event)
	local l_PlayerId = p_Event:GetInt("userid")
	
	Gag_LoadPlayerGag(l_PlayerId)
end)

AddEventHandler("Helpers_OnPlayerRemoveClanTag", function(p_Event, p_PlayerId, p_Tag)
	if p_Tag ~= PLAYER_TAG then
		return EventResult.Continue
	end
	
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return EventResult.Continue
	end
	
	local l_PlayerGag = Gag_GetPlayerGag(p_PlayerId)
	
	if not l_PlayerGag or l_PlayerGag["timeleft"] == 0 then
		return EventResult.Continue
	end
	
	return EventResult.Handled
end)