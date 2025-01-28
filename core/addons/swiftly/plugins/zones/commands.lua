AddEventHandler("Help_OnGetCommands", function(p_Event)
	local l_Commands = p_Event:GetReturn() or {}
	
	l_Commands["zone"] = {
		["permission"] = "rcon",
		["description"] = "Sets a player's zone",
		["usage"] = "sw_zone <id>"
	}
	
	l_Commands["zone_abort"] = {
		["permission"] = "rcon",
		["description"] = "Aborts a player's zone",
		["usage"] = "sw_zone_abort"
	}
	
	l_Commands["zone_point1"] = {
		["permission"] = "rcon",
		["description"] = "Sets a player's zone point1",
		["usage"] = "sw_zone_point1"
	}
	
	l_Commands["zone_point2"] = {
		["permission"] = "rcon",
		["description"] = "Sets a player's zone point2",
		["usage"] = "sw_zone_point2"
	}
	
	l_Commands["zone_points"] = {
		["permission"] = "rcon",
		["description"] = "Shows a player's zone points",
		["usage"] = "sw_zone_points"
	}
	
	l_Commands["zone_value"] = {
		["permission"] = "rcon",
		["description"] = "Changes a player's zone points",
		["usage"] = "sw_zone_value <1|2> <x|y|z> <value>"
	}
	
	l_Commands["zones"] = {
		["permission"] = "rcon",
		["description"] = "Lists the zones",
		["usage"] = "sw_zones"
	}
	
	p_Event:SetReturn(l_Commands)
end)

commands:Register("zone", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	if p_PlayerId == -1 then
		return
	end
	
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "rcon") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if p_ArgsCount < 1 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "Usage: sw_zone <id>")
		return
	end
	
	local l_Id = tonumber(p_Args[1])
	
	if not l_Id or l_Id < 0 or l_Id > #g_Config["zones"] then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "Invalid ID specified")
		return
	end
	
	exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "Zone set")
	
	Zones_RemovePlayerZone(p_PlayerId)
	
	l_Player:SetVar("zones.zone", {
		["name"] = PLAYER_ZONE_NAME .. p_PlayerId,
		["point1"] = {
			g_Config["zones"][l_Id]["point1"][1],
			g_Config["zones"][l_Id]["point1"][2],
			g_Config["zones"][l_Id]["point1"][3]
		},
		["point2"] = {
			g_Config["zones"][l_Id]["point2"][1],
			g_Config["zones"][l_Id]["point2"][2],
			g_Config["zones"][l_Id]["point2"][3]
		},
		["color"] = PLAYER_ZONE_COLOR
	})
	
	Zones_CreatePlayerZone(p_PlayerId)
end)

commands:Register("zone_abort", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	if p_PlayerId == -1 then
		return
	end
	
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "rcon") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	local l_PlayerZone = l_Player:GetVar("zones.zone")
	
	if not l_PlayerZone or not l_PlayerZone["name"] then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "You must have a zone to use this command")
		return
	end
	
	exports["helpers"]:ReplyToCommand(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", "Zone aborted")
	
	Zones_RemovePlayerZone(p_PlayerId)
end)

commands:Register("zone_point1", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	if p_PlayerId == -1 then
		return
	end
	
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "rcon") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	local l_PlayerZone = l_Player:GetVar("zones.zone") or {}
	local l_PlayerOrigin = exports["helpers"]:GetPlayerOrigin(p_PlayerId)
	
	exports["helpers"]:ReplyToCommand(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", "Zone point1 set")
	
	l_PlayerZone["point1"] = {
		math.floor(l_PlayerOrigin[1]),
		math.floor(l_PlayerOrigin[2]),
		math.floor(l_PlayerOrigin[3])
	}
	
	Zones_RemovePlayerZone(p_PlayerId)
	
	l_PlayerZone["name"] = l_PlayerZone["point2"] and PLAYER_ZONE_NAME .. p_PlayerId
	l_PlayerZone["color"] = l_PlayerZone["point2"] and PLAYER_ZONE_COLOR
	
	l_Player:SetVar("zones.zone", l_PlayerZone)
	
	Zones_CreatePlayerZone(p_PlayerId)
end)

commands:Register("zone_point2", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	if p_PlayerId == -1 then
		return
	end
	
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "rcon") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	local l_PlayerZone = l_Player:GetVar("zones.zone")
	
	local l_PlayerMaxs = exports["helpers"]:GetPlayerMaxs(p_PlayerId)
	local l_PlayerOrigin = exports["helpers"]:GetPlayerOrigin(p_PlayerId)
	
	exports["helpers"]:ReplyToCommand(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", "Zone point2 set")
	
	l_PlayerZone["point2"] = {
		math.floor(l_PlayerOrigin[1]),
		math.floor(l_PlayerOrigin[2]),
		math.floor(l_PlayerOrigin[3] + l_PlayerMaxs[3])
	}
	
	Zones_RemovePlayerZone(p_PlayerId)
	
	l_PlayerZone["name"] = l_PlayerZone["point1"] and PLAYER_ZONE_NAME .. p_PlayerId
	l_PlayerZone["color"] = l_PlayerZone["point1"] and PLAYER_ZONE_COLOR
	
	l_Player:SetVar("zones.zone", l_PlayerZone)
	
	Zones_CreatePlayerZone(p_PlayerId)
end)

commands:Register("zone_points", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	if p_PlayerId == -1 then
		return
	end
	
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "rcon") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	local l_PlayerZone = l_Player:GetVar("zones.zone")
	
	if not l_PlayerZone or not l_PlayerZone["name"] then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "You must have a zone to use this command")
		return
	end
	
	exports["helpers"]:ReplyToCommand(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Zone point1: {lime}%0.2f %0.2f %0.2f{default}", l_PlayerZone["point1"][1], l_PlayerZone["point1"][2], l_PlayerZone["point1"][3]))
	
	exports["helpers"]:ReplyToCommand(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Zone point2: {lime}%0.2f %0.2f %0.2f{default}", l_PlayerZone["point2"][1], l_PlayerZone["point2"][2], l_PlayerZone["point2"][3]))
end)

commands:Register("zone_value", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	if p_PlayerId == -1 then
		return
	end
	
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "rcon") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	local l_PlayerZone = l_Player:GetVar("zones.zone")
	
	if not l_PlayerZone or not l_PlayerZone["name"] then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "You must have a zone to use this command")
		return
	end
	
	if p_ArgsCount < 3 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "Usage: sw_zone_value <1|2> <x|y|z> <value>")
		return
	end
	
	local l_Point = g_Points[p_Args[1]]
	
	if not l_Point then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "Invalid point specified {lime}(1|2){default}")
		return
	end
	
	local l_Axis = g_Axes[p_Args[2]]
	
	if not l_Axis then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "Invalid axis specified {lime}(x|y|z){default}")
		return
	end
	
	local l_Value = tonumber(p_Args[3])
	
	if not l_Value then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "Invalid value specified")
		return
	end
	
	exports["helpers"]:ReplyToCommand(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Zone %s set", l_Point))
	
	l_PlayerZone[l_Point][l_Axis] = l_PlayerZone[l_Point][l_Axis] + l_Value
	
	Zones_RemovePlayerZone(p_PlayerId)
	
	l_Player:SetVar("zones.zone", l_PlayerZone)
	
	Zones_CreatePlayerZone(p_PlayerId)
end)

commands:Register("zones", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	if p_PlayerId == -1 then
		return
	end
	
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "rcon") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if p_Prefix ~= "sw_" then
		l_Player:SendMsg(MessageType.Chat, string.format("{yellow}%s{default} See console for output", g_Config["tag"]))
	end
	
	local l_Body = {}
	local l_Header = {
		"ID",
		"Point1",
		"Point2",
		"Name"
	}
	
	for i = 1, #g_Config["zones"] do
		local l_Point1 = table.concat(g_Config["zones"][i]["point1"], " ")
		local l_Point2 = table.concat(g_Config["zones"][i]["point2"], " ")
		local l_Name = g_Config["zones"][i]["name"] or ""
		
		table.insert(l_Body, {
			i,
			l_Point1,
			l_Point2,
			l_Name
		})
	end
	
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s Zones\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
	
	exports["helpers"]:PrintTableToConsole(p_PlayerId, g_Config["tag"], l_Header, l_Body)
	l_Player:SendMsg(MessageType.Console, string.format("%s\n", g_Config["tag"]))
end)