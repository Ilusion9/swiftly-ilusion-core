AddEventHandler("Help_OnGetCommands", function(p_Event)
	local l_Commands = p_Event:GetReturn() or {}
	
	l_Commands["reloadadmins"] = {
		["permission"] = "reloadadmins",
		["description"] = "Reloads the admin cache",
		["usage"] = "sw_reloadadmins"
	}
	
	l_Commands["who"] = {
		["permission"] = "who",
		["description"] = "Shows the online admins",
		["usage"] = "sw_who"
	}
	
	p_Event:SetReturn(l_Commands)
end)

commands:Register("reloadadmins", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return 
	end
	
	if not Admin_HasPlayerPermission(p_PlayerId, "reloadadmins") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	logger:Write(LogType_t.Common, string.format("\"%s<%s>\" refreshed the admin cache", l_PlayerName, l_PlayerSteam))
	exports["helpers"]:ReplyToCommand(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", "Admin cache refreshed successfully")
	
	Admin_ReloadAdmins()
end)

commands:Register("who", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return 
	end
	
	if not Admin_HasPlayerPermission(p_PlayerId, "who") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if p_Prefix ~= "sw_" then
		l_Player:SendMsg(MessageType.Chat, string.format("{yellow}%s{default} See console for output", g_Config["tag"]))
	end
	
	local l_Body = {}
	local l_Header = {
		"ID",
		"Name",
		"Steam",
		"Groups",
		"Immunity",
		"User"
	}
	
	for i = 0, playermanager:GetPlayerCap() - 1 do
		local l_PlayerIter = GetPlayer(i)
		
		if l_PlayerIter and l_PlayerIter:IsValid() then
			local l_PlayerIterGroups = Admin_GetPlayerGroups(i)
			local l_PlayerIterImmunity = Admin_GetPlayerImmunity(i)
			
			if l_PlayerIterGroups then
				for j = 1, #l_PlayerIterGroups do
					l_PlayerIterGroups[j] = l_PlayerIterGroups[j]["group"]
				end
			end
			
			if l_PlayerIterGroups or l_PlayerIterImmunity ~= 0 then
				local l_PlayerIterName = exports["helpers"]:GetPlayerName(i)
				local l_PlayerIterSteam = exports["helpers"]:GetPlayerSteam(i)
				local l_PlayerIterUser = Admin_GetPlayerUser(i)
				
				table.insert(l_Body, {
					i,
					l_PlayerIterName,
					l_PlayerIterSteam,
					table.concat(l_PlayerIterGroups, ", "),
					l_PlayerIterImmunity,
					l_PlayerIterUser
				})
			end
		end
	end
	
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s Who\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	
	exports["helpers"]:PrintTableToConsole(p_PlayerId, g_Config["tag"], l_Header, l_Body)
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
end)