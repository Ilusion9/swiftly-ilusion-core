AddEventHandler("Help_OnGetCommands", function(p_Event)
	local l_Commands = p_Event:GetReturn() or {}
	
	l_Commands["spawnpoints"] = {
		["permission"] = "rcon",
		["description"] = "Lists the spawnpoints",
		["usage"] = "sw_spawnpoints <map|custom>"
	}
	
	p_Event:SetReturn(l_Commands)
end)

commands:Register("spawnpoints", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "rcon") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if p_ArgsCount < 1 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "Usage: sw_spawnpoints <map|custom>")
		return
	end
	
	local l_Type = g_SpawnPointIdentifiers[p_Args[1]]
	
	if not l_Type then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "Invalid type specified {lime}(map|custom){default}")
		return
	end
	
	if p_Prefix ~= "sw_" then
		l_Player:SendMsg(MessageType.Chat, string.format("{yellow}%s{default} See console for output", g_Config["tag"]))
	end
	
	local l_Body = {}
	local l_Header = {}
	
	if l_Type == SPAWNPOINT_CUSTOM then
		l_Header = {
			"Origin",
			"Rotation",
			"Team",
			"Name"
		}
		
		for i = 1, #g_Config["spawnpoints"] do
			local l_Origin = g_Config["spawnpoints"][i]["origin"]
			local l_Rotation = g_Config["spawnpoints"][i]["rotation"]
			local l_Team = g_Config["spawnpoints"][i]["team"]
			local l_Name = g_Config["spawnpoints"][i]["name"]
			
			table.insert(l_Body, {
				table.concat(l_Origin, " "),
				table.concat(l_Rotation, " "),
				string.upper(exports["helpers"]:GetTeamIdentifier(l_Team) or ""),
				l_Name or ""
			})
		end
	elseif l_Type == SPAWNPOINT_MAP then
		l_Header = {
			"Origin",
			"Rotation",
			"Team"
		}
		
		local l_TerroristSpawnPoints = Spawnpoints_GetMapSpawnPoints(Team.T)
		local l_CTSpawnPoints = Spawnpoints_GetMapSpawnPoints(Team.CT)
		
		for i = 1, #l_TerroristSpawnPoints do
			local l_Origin = l_TerroristSpawnPoints[i]["origin"]
			local l_Rotation = l_TerroristSpawnPoints[i]["rotation"]
			
			table.insert(l_Body, {
				table.concat(l_Origin, " "),
				table.concat(l_Rotation, " "),
				"T"
			})
		end
		
		for i = 1, #l_CTSpawnPoints do
			local l_Origin = l_CTSpawnPoints[i]["origin"]
			local l_Rotation = l_CTSpawnPoints[i]["rotation"]
			
			table.insert(l_Body, {
				table.concat(l_Origin, " "),
				table.concat(l_Rotation, " "),
				"CT"
			})
		end
	end
	
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s Spawnpoints\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s Type: %s%s\n", g_Config["tag"], string.upper(string.sub(g_SpawnPointIdentifiers[l_Type], 1, 1)), string.sub(g_SpawnPointIdentifiers[l_Type], 2)))
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	
	exports["helpers"]:PrintTableToConsole(p_PlayerId, g_Config["tag"], l_Header, l_Body)
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
end)