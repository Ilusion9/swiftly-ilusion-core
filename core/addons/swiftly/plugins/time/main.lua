AddEventHandler("OnPluginStart", function(p_Event)
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	g_PluginIsLoading = true
	g_PluginIsLoadingLate = l_ServerTime > 0
	
	g_Database = Database("time")
	
	Time_LoadConfig()
	Time_CreateDatabase()
end)

AddEventHandler("OnAllPluginsLoaded", function(p_Event)
	if g_PluginIsLoadingLate then
		for i = 0, playermanager:GetPlayerCap() - 1 do
			Time_ResetPlayerVars(i)
			Time_SetPlayerConnectionTime(i)
		end
	end
	
	g_PluginIsLoading = nil
	g_PluginIsLoadingLate = nil
end)

AddEventHandler("OnPluginStop", function(p_Event)
	for i = 0, playermanager:GetPlayerCap() - 1 do
		Time_SavePlayerTime(i)
	end
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Time_LoadConfig()
end)

AddEventHandler("OnClientDisconnect", function(p_Event, p_PlayerId)
	Time_SavePlayerTime(p_PlayerId)
end)

AddEventHandler("OnPostPlayerConnectFull", function(p_Event)
	local l_PlayerId = p_Event:GetInt("userid")
	
	Time_SetPlayerConnectionTime(l_PlayerId)
end)

AddEventHandler("AFK_OnPlayerBAK", function(p_Event, p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	local l_PlayerAFKTime = l_Player:GetVar("time.afk.time") or 0
	
	l_PlayerAFKTime = l_PlayerAFKTime + exports["afk"]:GetPlayerAFKTime(p_PlayerId)
	
	l_Player:SetVar("time.afk.time", l_PlayerAFKTime)
end)