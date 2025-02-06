AddEventHandler("OnPluginStart", function(p_Event)
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	g_PluginIsLoading = true
	g_PluginIsLoadingLate = l_ServerTime > 0
	
	Map_ResetVars()
	
	Map_LoadConfig()
	Map_LoadHistory()
	Map_LoadMaps()
	
	Map_LoadCurrentMap()
end)

AddEventHandler("OnAllPluginsLoaded", function(p_Event)
	if g_PluginIsLoadingLate then
		for i = 0, playermanager:GetPlayerCap() - 1 do
			Map_ResetPlayerVars(i)
		end
		
		Map_CheckCurrentMap()
		Map_SetConVars()
	end
	
	g_PluginIsLoading = nil
	g_PluginIsLoadingLate = nil
end)

AddEventHandler("OnPluginStop", function(p_Event)
	Map_AddMapInHistory(g_Map["map"], g_Map["time"], "plugin stop")
	Map_SaveHistory()
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Map_ResetVars()
	
	Map_LoadConfig()
	Map_LoadHistory()
	Map_LoadMaps()
	
	Map_LoadCurrentMap()
	Map_CheckCurrentMap()
	
	SetTimeout(100, function()
		Map_SetConVars()
	end)
end)

AddEventHandler("OnMapUnload", function(p_Event, p_Map)
	if g_ThinkTimer then
		StopTimer(g_ThinkTimer)
		g_ThinkTimer = nil
	end
	
	Map_AddMapInHistory(g_Map["map"], g_Map["time"], g_NextMapReason or "")
	Map_SaveHistory()
end)

AddEventHandler("OnPostCsIntermission", function(p_Event)
	local l_Delay = math.floor(convar:Get("mp_round_restart_delay") * 1000)
	
	Map_StartVote(l_Delay)
end)

AddEventHandler("OnCsWinPanelMatch", function(p_Event)
    p_Event:SetReturn(false)
    return EventResult.Handled
end)

AddEventHandler("OnPostRoundStart", function(p_Event)
	if not g_RTVNextRound then
		return
	end
	
	Map_StartRTV(1000)
end)

AddEventHandler("OnClientChat", function(p_Event, p_PlayerId, p_Text, p_TeamOnly)
	if not g_VotePeriod then
		return EventResult.Continue
	end
	
	Map_HandlePlayerVote(p_PlayerId, p_Text)
	
	p_Event:SetReturn(false)
	return EventResult.Handled
end)

AddEventHandler("OnPostPlayerDisconnect", function(p_Event)
	Map_CheckPlayerRTVCount()
end)