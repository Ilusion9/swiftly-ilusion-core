AddEventHandler("Help_OnGetCommands", function(p_Event)
	local l_Commands = p_Event:GetReturn() or {}
	
	l_Commands["servers"] = {
		["description"] = "Shows the available servers",
		["usage"] = "sw_servers"
	}
	
	p_Event:SetReturn(l_Commands)
end)

commands:Register("servers", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if p_Prefix ~= "sw_" then
		l_Player:SendMsg(MessageType.Chat, string.format("{yellow}%s{default} See console for output", g_Config["tag"]))
	end
	
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	local l_Body = {}
	local l_Header = {
		"#",
		"Name",
		"Address",
		"Players",
		"Map",
		"Mode",
		"Game"
	}
	
	local l_FormatQueryTime = string.format("%s ago", exports["helpers"]:FormatTime(l_ServerTime - g_ServersQueryTime))
	
	for i = 1, #g_Servers do
		local l_Game = g_Servers[i]["game"]
		local l_Name = g_Servers[i]["name"]
		local l_Ip = g_Servers[i]["ip"]
		local l_Port = g_Servers[i]["port"]
		local l_Players = g_Servers[i]["players"]
		local l_MaxPlayers = g_Servers[i]["maxplayers"]
		local l_IsOnline = g_Servers[i]["is_online"]
		local l_Map = g_Servers[i]["map"]
		local l_Mode = g_Servers[i]["mode"]
		
		local l_FormatAddress = Servers_FormatAddress(l_Ip, l_Port)
		local l_FormatPlayers = Servers_FormatPlayers(l_Players, l_MaxPlayers, l_IsOnline)
		
		table.insert(l_Body, {
			string.format("%02d.", i),
			l_Name,
			l_FormatAddress,
			l_FormatPlayers,
			l_Map,
			l_Mode,
			l_Game
		})
	end
	
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s Servers\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s Query Time: %s\n", g_Config["tag"], l_FormatQueryTime))
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	
	exports["helpers"]:PrintTableToConsole(p_PlayerId, g_Config["tag"], l_Header, l_Body)
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
end)