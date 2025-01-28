AddEventHandler("OnPluginStart", function(p_Event)
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	g_PluginIsLoading = true
	g_PluginIsLoadingLate = l_ServerTime > 0
	
	Team_LoadConfig()
end)

AddEventHandler("OnAllPluginsLoaded", function(p_Event)
	if g_PluginIsLoadingLate then
		for i = 0, playermanager:GetPlayerCap() - 1 do
			Team_ResetPlayerVars(i)
		end
	end
	
	g_PluginIsLoading = nil
	g_PluginIsLoadingLate = nil
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Team_LoadConfig()
end)

AddEventHandler("OnClientCommand", function(p_Event, p_PlayerId, p_Command)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return EventResult.Continue
	end
	
	local l_Args = string.split(p_Command, " ")
	
	if l_Args[1] ~= "jointeam" then
		return EventResult.Continue
	end
	
	local l_Team = tonumber(l_Args[2])
	
	if not l_Team or l_Team < Team.Spectator or l_Team > Team.CT then
		p_Event:SetReturn(false)
		return EventResult.Handled
	end
	
	local l_PlayerTeam = exports["helpers"]:GetPlayerTeam(p_PlayerId)
	
	if l_Team == l_PlayerTeam then
		p_Event:SetReturn(false)
		return EventResult.Handled
	end
	
	local l_EventReturn, l_Event = TriggerEvent("Team_OnPlayerJoinTeam", p_PlayerId, l_Team, false)
	
	if l_EventReturn == EventResult.Handled or l_EventReturn == EventResult.Stop then
		p_Event:SetReturn(false)
		return EventResult.Handled
	end
	
	l_Player:SetVar("team.join.queue", true)
	
	if exports["helpers"]:IsPlayerAlive(p_PlayerId) then
		exports["helpers"]:SlayPlayer(p_PlayerId)
	end
	
	NextTick(function()
		if not l_Player:IsValid() then
			return
		end
		
		exports["helpers"]:ChangePlayerTeam(p_PlayerId, l_Team)
		
		l_Player:SetVar("team.join.queue", nil)
	end)
	
	return EventResult.Continue
end)