function Chat_LoadConfig()
	config:Reload("chat")
	
	g_Config = {}
	g_Config["name.color"] = {}
	
	g_Config["name.color"][Team.T] = config:Fetch("chat.name.color.t")
	g_Config["name.color"][Team.CT] = config:Fetch("chat.name.color.ct")
	g_Config["name.color"][Team.Spectator] = config:Fetch("chat.name.color.spec")
	
	if type(g_Config["name.color"][Team.T]) ~= "string" then
		g_Config["name.color"][Team.T] = ""
	end
	
	if type(g_Config["name.color"][Team.CT]) ~= "string" then
		g_Config["name.color"][Team.CT] = ""
	end
	
	if type(g_Config["name.color"][Team.Spectator]) ~= "string" then
		g_Config["name.color"][Team.Spectator] = ""
	end
	
	g_Config["name.color"][Team.None] = g_Config["name.color"][Team.Spectator]
end

function Chat_SetPlayerNameColor(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerTeam = exports["helpers"]:GetPlayerTeam(p_PlayerId)
	
	if not g_Config["name.color"][l_PlayerTeam] then
		return
	end
	
	l_Player:SetNameColor(g_Config["name.color"][l_PlayerTeam])
end