AddEventHandler("Help_OnGetCommands", function(p_Event)
	local l_Commands = p_Event:GetReturn() or {}
	
	l_Commands["help"] = {
		["description"] = "Shows the available commands",
		["usage"] = "sw_help"
	}
	
	p_Event:SetReturn(l_Commands)
end)

commands:Register("help", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_Commands = commands:GetAllCommands()
	
	if #l_Commands == 0 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "No commands available")
		return
	end
	
	local l_Page = tonumber(table.concat(p_Args, " "))
	
	if not l_Page or l_Page < 1 then
		l_Page = 1
	end
	
	local l_EventReturn, l_Event = TriggerEvent("Help_OnGetCommands")
	local l_EventCommands = l_Event:GetReturn() or {}
	
	local l_Help = {}
	
	for i = 1, #l_Commands do
		local l_Permission = nil
		local l_Description = nil
		local l_Usage = nil
		
		if l_EventCommands[l_Commands[i]] then
			l_Permission = l_EventCommands[l_Commands[i]]["permission"]
			l_Description = l_EventCommands[l_Commands[i]]["description"]
			l_Usage = l_EventCommands[l_Commands[i]]["usage"]
		end
		
		if not l_Permission then
			l_Permission = ""
		end
		
		if not l_Description then
			l_Description = ""
		end
		
		if not l_Usage then
			l_Usage = ""
		end
		
		if #l_Permission == 0 or exports["admin"]:HasPlayerPermission(p_PlayerId, l_Permission) then
			table.insert(l_Help, {
				["command"] = l_Commands[i],
				["description"] = l_Description,
				["usage"] = l_Usage
			})
		end
	end
	
	if #l_Help == 0 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "No commands available")
		return
	end
	
	local l_Start = (l_Page - 1) * g_Config["pagination.size"] + 1
	local l_End = math.min(l_Start + g_Config["pagination.size"] - 1, #l_Help)
	
	if l_Start > #l_Help then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "No commands available")
		return
	end
	
	if p_Prefix ~= "sw_" then
		l_Player:SendMsg(MessageType.Chat, string.format("{yellow}%s{default} See console for output", g_Config["tag"]))
	end
	
	local l_PageCount = math.floor(#l_Help / g_Config["pagination.size"]) + 1
	
	local l_Body = {}
	local l_Header = {
		"#",
		"Command",
		"Description",
		"Usage"
	}
	
	for i = l_Start, l_End do
		local l_Command = l_Help[i]["command"]
		local l_Description = l_Help[i]["description"]
		local l_Usage = l_Help[i]["usage"]
		
		table.insert(l_Body, {
			string.format("%02d.", i),
			"sw_" .. l_Command,
			l_Description,
			l_Usage
		})
	end
	
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s Help\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	
	exports["helpers"]:PrintTableToConsole(p_PlayerId, g_Config["tag"], l_Header, l_Body)
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	
	if l_PageCount == 1 then
		return
	end
	
	l_Player:SendMsg(MessageType.Console, string.format("%s Page %d / %d\n", g_Config["tag"], l_Page, l_PageCount))
	
	if l_End ~= #l_Help then
		l_Player:SendMsg(MessageType.Console, string.format("%s Type \"sw_help %d\" to see more\n", g_Config["tag"], l_Page + 1))
	end
	
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
end)