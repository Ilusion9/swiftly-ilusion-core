AddEventHandler("Help_OnGetCommands", function(p_Event)
	local l_Commands = p_Event:GetReturn() or {}
	
	l_Commands["team"] = {
		["permission"] = "team",
		["description"] = "Changes a player's team",
		["usage"] = "sw_team <#userid|name> <t|ct|spec>"
	}
	
	p_Event:SetReturn(l_Commands)
end)

commands:Register("team", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "team") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	if p_ArgsCount < 2 then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{yellow}" .. g_Config["tag"] .. "{default}", "Usage: sw_team <#userid|name> <t|ct|spec>")
		return
	end
	
	local l_TargetId = exports["helpers"]:FindTarget(p_PlayerId, p_Args[1], "i", g_Config["tag"])
	
	if not l_TargetId then
		return
	end
	
	local l_TargetTeam = exports["helpers"]:GetPlayerTeam(l_TargetId)
	
	if l_TargetTeam == Team.None then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "This player has no team")
		return
	end
	
	local l_Team = exports["helpers"]:GetTeamFromIdentifier(p_Args[2])
	
	if not l_Team then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "Invalid team specified")
		return
	end
	
	local l_TeamName = exports["helpers"]:GetTeamName(l_Team)
	local l_TeamColor = exports["helpers"]:GetTeamChatColor(l_Team)
	
	if l_Team == l_TargetTeam then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", string.format("This player is already at %s%s{default}", l_TeamColor, l_TeamName))
		return
	end
	
	local l_EventReturn, l_Event = TriggerEvent("Team_OnPlayerJoinTeam", l_TargetId, l_Team, true)
	
	if l_EventReturn == EventResult.Handled or l_EventReturn == EventResult.Stop then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", string.format("You cannot move players to %s%s{default}", l_TeamColor, l_TeamName))
		return
	end
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	local l_Target = GetPlayer(l_TargetId)
	local l_TargetName = exports["helpers"]:GetPlayerName(l_TargetId)
	local l_TargetSteam = exports["helpers"]:GetPlayerSteam(l_TargetId)
	local l_TargetColor = exports["helpers"]:GetPlayerChatColor(l_TargetId)
	
	logger:Write(LogType_t.Common, string.format("\"%s<%s>\" moved \"%s<%s>\" to \"%s\"", l_PlayerName, l_PlayerSteam, l_TargetName, l_TargetSteam, l_TeamName))
	
	exports["helpers"]:ShowActivity(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", string.format("Moved %s%s{default} to %s%s{default}", l_TargetColor, l_TargetName, l_TeamColor, l_TeamName))
	
	l_Target:SetVar("team.join.queue", true)
	
	exports["helpers"]:ChangePlayerTeam(l_TargetId, l_Team)
	
	l_Target:SetVar("team.join.queue", nil)
end)