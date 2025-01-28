AddEventHandler("Help_OnGetCommands", function(p_Event)
	local l_Commands = p_Event:GetReturn() or {}
	
	l_Commands["cvar"] = {
		["permission"] = "cvar",
		["description"] = "Changes a server's convar",
		["usage"] = "sw_cvar <cvar> [newvalue]"
	}
	
	l_Commands["exec"] = {
		["permission"] = "exec",
		["description"] = "Executes a server's config",
		["usage"] = "sw_exec <config>"
	}
	
	l_Commands["rcon"] = {
		["permission"] = "rcon",
		["description"] = "Executes a server's command",
		["usage"] = "sw_rcon <command>"
	}
	
	p_Event:SetReturn(l_Commands)
end)

commands:Register("cvar", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "cvar") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if p_ArgsCount < 1 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "Usage: sw_cvar <cvar> [newvalue]")
		return
	end
	
	local l_Cvar = p_Args[1]
	
	if not convar:Exists(l_Cvar) and not convar:ExistsFake(l_Cvar) then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "Invalid cvar specified")
		return
	end
	
	if not p_Args[2] then
		local l_Value = tostring(convar:Get(l_Cvar) or "")
		
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", string.format("The value of {lime}%s{default} is {lime}%s{default}", l_Cvar, #l_Value ~= 0 and l_Value or "\"\""))
		return
	end
	
	local l_Value = table.concat(p_Args, " ", 2)
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	logger:Write(LogType_t.Common, string.format("\"%s<%s>\" changed cvar \"%s\" (to \"%s\")", l_PlayerName, l_PlayerSteam, l_Cvar, l_Value))
	
	exports["helpers"]:ShowActivity(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Changed cvar {lime}%s{default} to {lime}%s{default}", l_Cvar, #l_Value ~= 0 and l_Value or "\"\""))
	
	exports["helpers"]:SetConVar(l_Cvar, l_Value)
end)

commands:Register("exec", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "exec") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if p_ArgsCount < 1 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "Usage: sw_exec <config>")
		return
	end
	
	local l_Config = table.concat(p_Args, " ")
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	logger:Write(LogType_t.Common, string.format("\"%s<%s>\" executed config \"%s\"", l_PlayerName, l_PlayerSteam, l_Config))
	
	exports["helpers"]:ShowActivity(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Executed config {lime}%s{default}", l_Config))
	
	server:Execute("exec " .. l_Config)
end)

commands:Register("rcon", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "rcon") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if p_ArgsCount < 1 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "Usage: sw_rcon <command>")
		return
	end
	
	local l_Command = table.concat(p_Args, " ")
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	logger:Write(LogType_t.Common, string.format("\"%s<%s>\" executed command \"%s\"", l_PlayerName, l_PlayerSteam, l_Command))
	
	exports["helpers"]:ReplyToCommand(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Executed command {lime}%s{default}", l_Command))
	
	server:Execute(l_Command)
end)