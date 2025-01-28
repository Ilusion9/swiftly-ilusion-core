function Team_IsPlayerInJoinTeamQueue(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return false
	end
	
	return l_Player:GetVar("team.join.queue") or false
end

function Team_LoadConfig()
	config:Reload("team")
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("team.tag")
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Team]"
	end
end

function Team_ResetPlayerVars(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	l_Player:SetVar("team.join.queue", nil)
end