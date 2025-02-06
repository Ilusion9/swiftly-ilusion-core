AddEventHandler("Help_OnGetCommands", function(p_Event)
	local l_Commands = p_Event:GetReturn() or {}
	
	l_Commands["map"] = {
		["permission"] = "map",
		["description"] = "Changes the current map",
		["usage"] = "sw_map <map>"
	}
	
	l_Commands["maphistory"] = {
		["description"] = "Shows the map history",
		["usage"] = "sw_maphistory"
	}
	
	l_Commands["maplist"] = {
		["description"] = "Shows the available maps",
		["usage"] = "sw_maplist [page]"
	}
	
	l_Commands["nominate"] = {
		["description"] = "Nominates a map",
		["usage"] = "sw_nominate <map>"
	}
	
	l_Commands["nominations"] = {
		["description"] = "Shows a player's map nominations",
		["usage"] = "sw_nominations"
	}
	
	l_Commands["rtv"] = {
		["description"] = "Rocks the vote",
		["usage"] = "sw_rtv"
	}
	
	p_Event:SetReturn(l_Commands)
end)

commands:Register("map", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "map") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if p_ArgsCount < 1 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "Usage: sw_map <map>")
		return
	end
	
	local l_Index = Map_FindMap(table.concat(p_Args, " "))
	
	if not l_Index then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "This map was not found")
		return
	end
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	logger:Write(LogType_t.Common, string.format("\"%s<%s>\" changed the map to \"%s\"", l_PlayerName, l_PlayerSteam, g_MapCycle[l_Index]["map"]))
	
	exports["helpers"]:ShowActivity(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Changed the map to {lime}%s{default}", g_MapCycle[l_Index]["map"]))
	
	SetTimeout(3000, function()
		Map_ChangeMap(g_MapCycle[l_Index]["map"], g_MapCycle[l_Index]["workshop"], "sw_map")
	end)
end)

commands:Register("maphistory", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if p_Prefix ~= "sw_" then
		l_Player:SendMsg(MessageType.Chat, string.format("{yellow}%s{default} See console for output", g_Config["tag"]))
	end
	
	local l_CurrentTime = GetTime()
	
	local l_Body = {}
	local l_Header = {
		"#",
		"Map",
		"Start Time",
		"Time",
		"Reason"
	}
	
	table.insert(l_Body, {
		"00.",
		g_Map["map"],
		"",
		"",
		""
	})
	
	for i = #g_History, 1, -1 do
		local l_Map = g_History[i]["map"]
		local l_StartTime = tonumber(g_History[i]["started_at"])
		local l_Time = tonumber(g_History[i]["time"])
		local l_Reason = g_History[i]["reason"]
		
		local l_FormatStartTime = string.format("%s ago", exports["helpers"]:FormatTime(l_CurrentTime - l_StartTime))
		local l_FormatTime = exports["helpers"]:FormatTime(l_Time)
		
		table.insert(l_Body, {
			string.format("%02d.", #g_History - i + 1),
			l_Map,
			l_FormatStartTime,
			l_FormatTime,
			l_Reason
		})
	end
	
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s Map History\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	
	exports["helpers"]:PrintTableToConsole(p_PlayerId, g_Config["tag"], l_Header, l_Body)
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
end)

commands:Register("maplist", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_Page = tonumber(p_Args[1])
	
	if not l_Page or l_Page < 1 then
		l_Page = 1
	end
	
	local l_Start = (l_Page - 1) * g_Config["maplist.pagination.size"] + 1
	local l_End = math.min(l_Start + g_Config["maplist.pagination.size"] - 1, #g_MapCycle)
	
	if l_Start > #g_MapCycle then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "No maps available")
		return
	end
	
	if p_Prefix ~= "sw_" then
		l_Player:SendMsg(MessageType.Chat, string.format("{yellow}%s{default} See console for output", g_Config["tag"]))
	end
	
	local l_PageCount = math.floor(#g_MapCycle / g_Config["maplist.pagination.size"]) + 1
	
	local l_Body = {}
	local l_Header = {
		"#",
		"Map"
	}
	
	for i = l_Start, l_End do
		local l_Map = g_MapCycle[i]["map"]
		
		table.insert(l_Body, {
			string.format("%02d.", i),
			l_Map
		})
	end
	
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s Map List\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	
	exports["helpers"]:PrintTableToConsole(p_PlayerId, g_Config["tag"], l_Header, l_Body)
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	
	if l_PageCount == 1 then
		return
	end
	
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s Page %d / %d\n", g_Config["tag"], l_Page, l_PageCount))
	
	if l_End ~= #g_MapCycle then
		l_Player:SendMsg(MessageType.Console, string.format("%s Type \"sw_maplist %d\" to see more\n", g_Config["tag"], l_Page + 1))
	end
	
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
end)

commands:Register("nominate", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not g_Config["nominations.enable"] then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "This command is not available")
		return
	end
	
	if exports["helpers"]:IsMatchOver() then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "This command is no longer available")
		return
	end
	
	if p_ArgsCount < 1 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "Usage: sw_nominate <map>")
		return
	end
	
	local l_Index = Map_FindMap(table.concat(p_Args, " "))
	
	if not l_Index then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "This map was not found")
		return
	end
	
	local l_PlayerNominations = l_Player:GetVar("map.nominations") or {}
	
	if table.contains(l_PlayerNominations, l_Index) then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You have already nominated this map")
		return
	end
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerColor = exports["helpers"]:GetPlayerChatColor(p_PlayerId)
	
	l_Player:SendMsg(MessageType.Console, string.format("%s %s nominated %s", g_Config["tag"], l_PlayerName, g_MapCycle[l_Index]["map"]))
	
	playermanager:SendMsg(MessageType.Chat, string.format("{lime}%s{default} %s%s{default} nominated {lime}%s{default}", g_Config["tag"], l_PlayerColor, l_PlayerName, g_MapCycle[l_Index]["map"]))
	
	table.insert(l_PlayerNominations, l_Index)
	
	l_Player:SetVar("map.nominations", l_PlayerNominations)
end)

commands:Register("nominations", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not g_Config["nominations.enable"] then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "This command is not available")
		return
	end
	
	if p_Prefix ~= "sw_" then
		l_Player:SendMsg(MessageType.Chat, string.format("{yellow}%s{default} See console for output", g_Config["tag"]))
	end
	
	local l_PlayerNominations = l_Player:GetVar("map.nominations") or {}
	
	local l_Body = {}
	local l_Header = {
		"#",
		"Map"
	}
	
	for i = 1, #l_PlayerNominations do
		local l_Map = g_MapCycle[l_PlayerNominations[i]]["map"]
		
		table.insert(l_Body, {
			string.format("%02d.", i),
			l_Map
		})
	end
	
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s Nominations\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	
	exports["helpers"]:PrintTableToConsole(p_PlayerId, g_Config["tag"], l_Header, l_Body)
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
end)

commands:Register("rtv", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not g_Config["rtv.enable"] then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "This command is not available")
		return
	end
	
	if g_RTVNextRound or exports["helpers"]:IsMatchOver() then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "This command is no longer available")
		return
	end
	
	local l_PlayerRTVQueue = l_Player:GetVar("map.rtv.queue")
	
	if l_PlayerRTVQueue then
		local l_RemainingRTVCount = Map_GetRemainingRTVCount()
		
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", string.format("You already voted to rock the vote (%d more required)", l_RemainingRTVCount))
	else
		l_Player:SetVar("map.rtv.queue", true)
		
		local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
		local l_PlayerColor = exports["helpers"]:GetPlayerChatColor(p_PlayerId)
		
		local l_RemainingRTVCount = Map_GetRemainingRTVCount()
		
		if l_RemainingRTVCount ~= 0 then
			l_Player:SendMsg(MessageType.Console, string.format("%s %s wants to rock the vote (%d more required)", g_Config["tag"], l_PlayerName, l_RemainingRTVCount))
			
			playermanager:SendMsg(MessageType.Chat, string.format("{lime}%s{default} %s%s{default} wants to rock the vote (%d more required)", g_Config["tag"], l_PlayerColor, l_PlayerName, l_RemainingRTVCount))
		else
			l_Player:SendMsg(MessageType.Console, string.format("%s %s rocked the vote", g_Config["tag"], l_PlayerName))
			
			playermanager:SendMsg(MessageType.Chat, string.format("{lime}%s{default} %s%s{default} rocked the vote", g_Config["tag"], l_PlayerColor, l_PlayerName))
			
			Map_StartRTV()
		end
	end
end)