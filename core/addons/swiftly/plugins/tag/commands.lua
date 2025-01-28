AddEventHandler("Help_OnGetCommands", function(p_Event)
	local l_Commands = p_Event:GetReturn() or {}
	
	l_Commands["tag"] = {
		["description"] = "Sets a player's tag",
		["usage"] = "sw_tag [id]"
	}
	
	p_Event:SetReturn(l_Commands)
end)

commands:Register("tag", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerTags = l_Player:GetVar("tag.tags") or {}
	
	if #l_PlayerTags == 0 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You have no tags available")
		return
	end
	
	if p_ArgsCount ~= 0 then
		local l_Type = string.sub(p_Args[1], 1, 1)
		
		if l_Type ~= "t" and l_Type ~= "c" then
			exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "Invalid ID specified")
			return
		end
		
		local l_Index = tonumber(string.sub(p_Args[1], 2))
		
		if not l_Index or l_Index < 1 then
			exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "Invalid ID specified")
			return
		end
		
		if l_Type == "t" and l_Index > #l_PlayerTags then
			exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "Invalid ID specified")
			return
		end
		
		if l_Type == "c" and l_Index > #g_Config["colors"] then
			exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "Invalid ID specified")
			return
		end
		
		if l_Type == "t" then
			Tag_SetPlayerTag(p_PlayerId, l_Index)
		else
			Tag_SetPlayerTagColor(p_PlayerId, l_Index)
		end
	end
	
	if p_Prefix ~= "sw_" then
		l_Player:SendMsg(MessageType.Chat, string.format("{yellow}%s{default} See console for output", g_Config["tag"]))
	end
	
	local l_PlayerTagId = l_Player:GetVar("tag.tag.id") or 1
	local l_PlayerColorId = l_Player:GetVar("tag.color.id") or 1
	
	local l_TagBody = {}
	local l_TagHeader = {
		"ID",
		"Tag"
	}
	
	local l_ColorBody = {}
	local l_ColorHeader = {
		"ID",
		"Color"
	}
	
	for i = 1, #l_PlayerTags do
		local l_Tag = l_PlayerTags[i]
		
		table.insert(l_TagBody, {
			string.format("t%d", i),
			l_Tag
		})
	end
	
	for i = 1, #g_Config["colors"] do
		local l_Color = g_Config["colors"][i]["name"]
		
		table.insert(l_ColorBody, {
			string.format("c%d", i),
			l_Color
		})
	end
	
	l_TagBody[l_PlayerTagId][2] = l_TagBody[l_PlayerTagId][2] .. " (selected)"
	l_ColorBody[l_PlayerColorId][2] = l_ColorBody[l_PlayerColorId][2] .. " (selected)"
	
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s Tags\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	
	exports["helpers"]:PrintTableToConsole(p_PlayerId, g_Config["tag"], l_TagHeader, l_TagBody)
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	
	l_Player:SendMsg(MessageType.Console, string.format("%s Colors\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	
	exports["helpers"]:PrintTableToConsole(p_PlayerId, g_Config["tag"], l_ColorHeader, l_ColorBody)
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	
	l_Player:SendMsg(MessageType.Console, string.format("%s Use \"sw_tag [id]\" to set your tags\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
end)