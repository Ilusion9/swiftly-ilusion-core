AddEventHandler("Help_OnGetCommands", function(p_Event)
	local l_Commands = p_Event:GetReturn() or {}
	
	if not l_Commands then
		l_Commands = {}
	end
	
	l_Commands["rs"] = {
		["description"] = "Resets a player's score",
		["usage"] = "sw_rs"
	}
	
	p_Event:SetReturn(l_Commands)
end)

commands:Register("rs", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	exports["helpers"]:ReplyToCommand(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", "Your score has been reset")
	
	exports["helpers"]:SetPlayerAssists(p_PlayerId, 0)
	exports["helpers"]:SetPlayerDamage(p_PlayerId, 0)
	exports["helpers"]:SetPlayerDeaths(p_PlayerId, 0)
	exports["helpers"]:SetPlayerKills(p_PlayerId, 0)
	exports["helpers"]:SetPlayerMVPs(p_PlayerId, 0)
	exports["helpers"]:SetPlayerScore(p_PlayerId, 0)
end)