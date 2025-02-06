function AFK_CheckPlayerKickCount()
	if g_Config["kick.players.min"] == 0 or exports["helpers"]:IsMatchOver() then
		return
	end
	
	SetTimeout(100, function()
		if exports["helpers"]:IsMatchOver() then
			return
		end
		
		local l_PlayerCount = exports["helpers"]:GetTeamPlayerCount({Team.Spectator, Team.T, Team.CT}, true)
		local l_PlayerKickCount = l_PlayerCount[Team.Spectator] + l_PlayerCount[Team.T] + l_PlayerCount[Team.CT]
		
		if l_PlayerKickCount >= g_Config["kick.players.min"] then
			return
		end
		
		for i = 0, playermanager:GetPlayerCap() - 1 do
			AFK_ResetPlayerKickTime(i, true)
		end
	end)
end

function AFK_CheckPlayerMoveCount()
	if g_Config["move.players.min"] == 0 or exports["helpers"]:IsMatchOver() then
		return
	end
	
	SetTimeout(100, function()
		if exports["helpers"]:IsMatchOver() then
			return
		end
		
		local l_PlayerCount = exports["helpers"]:GetTeamPlayerCount({Team.T, Team.CT}, true)
		local l_PlayerMoveCount = l_PlayerCount[Team.T] + l_PlayerCount[Team.CT]
		
		if l_PlayerMoveCount >= g_Config["move.players.min"] then
			return
		end
		
		for i = 0, playermanager:GetPlayerCap() - 1 do
			AFK_ResetPlayerMoveTime(i, true)
		end
	end)
end

function AFK_GetPlayerAFKTime(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return 0
	end
	
	local l_PlayerAFK = l_Player:GetVar("afk")
	
	if not l_PlayerAFK then
		return 0
	end
	
	return l_Player:GetVar("afk.time") or 0
end

function AFK_IncreasePlayerKickTime(p_PlayerId, p_Time, p_PlayerCount)
	if not g_Config["kick.enable"] or p_PlayerCount < g_Config["kick.players.min"] then
		return {
			["time"] = 0
		}
	end
	
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return {
			["time"] = 0
		}
	end
	
	local l_PlayerTeam = exports["helpers"]:GetPlayerTeam(p_PlayerId)
	
	if l_PlayerTeam == Team.None then
		return {
			["time"] = 0
		}
	end
	
	local l_PlayerKickTime = l_Player:GetVar("afk.kick.time") or 0
	
	if exports["helpers"]:IsFreezeTime() 
		or exports["helpers"]:IsHalfTime() 
		or exports["helpers"]:IsMatchOver() 
	then
		return {
			["time"] = l_PlayerKickTime,
			["pause"] = true
		}
	end
	
	if l_PlayerTeam ~= Team.Spectator then
		if not exports["helpers"]:IsPlayerAlive(p_PlayerId) then
			return {
				["time"] = l_PlayerKickTime,
				["pause"] = true
			}
		end
	end
	
	return {
		["time"] = l_PlayerKickTime + p_Time,
		["queue"] = true
	}
end

function AFK_IncreasePlayerMoveTime(p_PlayerId, p_Time, p_PlayerCount)
	if not g_Config["move.enable"] or p_PlayerCount < g_Config["move.players.min"] then
		return {
			["time"] = 0
		}
	end
	
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return {
			["time"] = 0
		}
	end
	
	local l_PlayerTeam = exports["helpers"]:GetPlayerTeam(p_PlayerId)
	
	if l_PlayerTeam == Team.None or l_PlayerTeam == Team.Spectator then
		return {
			["time"] = 0
		}
	end
	
	local l_PlayerMoveTime = l_Player:GetVar("afk.move.time") or 0
	
	if exports["helpers"]:IsFreezeTime() 
		or exports["helpers"]:IsHalfTime() 
		or exports["helpers"]:IsMatchOver() 
		or not exports["helpers"]:IsPlayerAlive(p_PlayerId) 
	then
		return {
			["time"] = l_PlayerMoveTime,
			["pause"] = true
		}
	end
	
	return {
		["time"] = l_PlayerMoveTime + p_Time,
		["queue"] = true
	}
end

function AFK_IncreasePlayerSlayTime(p_PlayerId, p_Time)
	if not g_Config["slay.enable"] then
		return {
			["time"] = 0
		}
	end
	
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player 
		or not l_Player:IsValid() 
		or not exports["helpers"]:IsPlayerAlive(p_PlayerId) 
	then
		return {
			["time"] = 0
		}
	end
	
	local l_PlayerSlayTime = l_Player:GetVar("afk.slay.time") or 0
	
	if exports["helpers"]:IsFreezeTime() 
		or exports["helpers"]:IsHalfTime() 
		or exports["helpers"]:IsMatchOver() 
	then
		return {
			["time"] = l_PlayerSlayTime,
			["pause"] = true
		}
	end
	
	return {
		["time"] = l_PlayerSlayTime + p_Time,
		["queue"] = true
	}
end

function AFK_IsPlayerAFK(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return false
	end
	
	return l_Player:GetVar("afk") or false
end

function AFK_KickPlayer(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	AFK_ResetPlayerKickTime(p_PlayerId)
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerColor = exports["helpers"]:GetPlayerChatColor(p_PlayerId)
	
	playermanager:SendMsg(MessageType.Chat, string.format("{lime}%s{default} Kicked %s%s{default} for being AFK too long", g_Config["tag"], l_PlayerColor, l_PlayerName))
	
	l_Player:SendMsg(MessageType.Console, g_Config["tag"] .. "\n")
	l_Player:SendMsg(MessageType.Console, string.format("%s Kicked for being AFK too long\n", g_Config["tag"]))
	l_Player:SendMsg(MessageType.Console, g_Config["tag"] .. "\n")
	
	exports["helpers"]:KickPlayer(p_PlayerId)
end

function AFK_LoadConfig()
	config:Reload("afk")
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("afk.tag")
	g_Config["kick.enable"] = config:Fetch("afk.kick.enable")
	g_Config["kick.players.min"] = tonumber(config:Fetch("afk.kick.players.min"))
	g_Config["kick.time"] = tonumber(config:Fetch("afk.kick.time"))
	g_Config["move.enable"] = config:Fetch("afk.move.enable")
	g_Config["move.players.min"] = tonumber(config:Fetch("afk.move.players.min"))
	g_Config["move.time"] = tonumber(config:Fetch("afk.move.time"))
	g_Config["slay.enable"] = config:Fetch("afk.slay.enable")
	g_Config["slay.time"] = tonumber(config:Fetch("afk.slay.time"))
	g_Config["time"] = tonumber(config:Fetch("afk.time"))
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[AFK]"
	end
	
	if type(g_Config["kick.enable"]) ~= "boolean" then
		g_Config["kick.enable"] = tonumber(g_Config["kick.enable"])
		g_Config["kick.enable"] = g_Config["kick.enable"] and g_Config["kick.enable"] ~= 0
	end
	
	if not g_Config["kick.players.min"] or g_Config["kick.players.min"] < 0 then
		g_Config["kick.players.min"] = 0
	end
	
	if not g_Config["kick.time"] or g_Config["kick.time"] < AFK_TIME then
		g_Config["kick.time"] = AFK_TIME
	end
	
	if type(g_Config["move.enable"]) ~= "boolean" then
		g_Config["move.enable"] = tonumber(g_Config["move.enable"])
		g_Config["move.enable"] = g_Config["move.enable"] and g_Config["move.enable"] ~= 0
	end
	
	if not g_Config["move.players.min"] or g_Config["move.players.min"] < 0 then
		g_Config["move.players.min"] = 0
	end
	
	if not g_Config["move.time"] or g_Config["move.time"] < AFK_TIME then
		g_Config["move.time"] = AFK_TIME
	end
	
	if type(g_Config["slay.enable"]) ~= "boolean" then
		g_Config["slay.enable"] = tonumber(g_Config["slay.enable"])
		g_Config["slay.enable"] = g_Config["slay.enable"] and g_Config["slay.enable"] ~= 0
	end
	
	if not g_Config["slay.time"] or g_Config["slay.time"] < AFK_TIME then
		g_Config["slay.time"] = AFK_TIME
	end
	
	if not g_Config["time"] or g_Config["time"] < AFK_TIME then
		g_Config["time"] = AFK_TIME
	end
	
	g_Config["kick.time"] = math.floor(g_Config["kick.time"] * 1000)
	g_Config["move.time"] = math.floor(g_Config["move.time"] * 1000)
	g_Config["slay.time"] = math.floor(g_Config["slay.time"] * 1000)
	g_Config["time"] = math.floor(g_Config["time"] * 1000)
	
	g_Config["slay.warn.time"] = math.min(math.floor(g_Config["slay.time"] / 2), 60000)
	g_Config["move.warn.time"] = math.min(math.floor(g_Config["move.time"] / 2), 60000)
	g_Config["kick.warn.time"] = math.min(math.floor(g_Config["kick.time"] / 2), 60000)
end

function AFK_MovePlayer(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	AFK_ResetPlayerMoveTime(p_PlayerId)
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerColor = exports["helpers"]:GetPlayerChatColor(p_PlayerId)
	
	local l_SpectatorColor = exports["helpers"]:GetTeamChatColor(Team.Spectator)
	
	playermanager:SendMsg(MessageType.Chat, string.format("{lime}%s{default} Moved %s%s{default} to %sSpectators{default} for being AFK too long", g_Config["tag"], l_PlayerColor, l_PlayerName, l_SpectatorColor))
	
	exports["helpers"]:ChangePlayerTeam(p_PlayerId, Team.Spectator)
end

function AFK_ResetPlayerKickTime(p_PlayerId, p_Warn)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerWarnTime = l_Player:GetVar("afk.kick.warn.time")
	
	l_Player:SetVar("afk.kick.time", nil)
	l_Player:SetVar("afk.kick.warn.time", nil)
	
	if not p_Warn or not l_PlayerWarnTime then
		return
	end
	
	l_Player:SendMsg(MessageType.Chat, string.format("{lime}%s{default} You can no longer be kicked", g_Config["tag"]))
end

function AFK_ResetPlayerMoveTime(p_PlayerId, p_Warn)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerWarnTime = l_Player:GetVar("afk.move.warn.time")
	
	l_Player:SetVar("afk.move.time", nil)
	l_Player:SetVar("afk.move.warn.time", nil)
	
	if not p_Warn or not l_PlayerWarnTime then
		return
	end
	
	local l_SpectatorColor = exports["helpers"]:GetTeamChatColor(Team.Spectator)
	
	l_Player:SendMsg(MessageType.Chat, string.format("{lime}%s{default} You can no longer be moved to %sSpectators{default}", g_Config["tag"], l_SpectatorColor))
end

function AFK_ResetPlayerSlayTime(p_PlayerId, p_Warn)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerWarnTime = l_Player:GetVar("afk.slay.warn.time")
	
	l_Player:SetVar("afk.slay.time", nil)
	l_Player:SetVar("afk.slay.warn.time", nil)
	
	if not p_Warn or not l_PlayerWarnTime then
		return
	end
	
	l_Player:SendMsg(MessageType.Chat, string.format("{lime}%s{default} You can no longer be slayed", g_Config["tag"]))
end

function AFK_ResetPlayerVars(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	l_Player:SetVar("afk", nil)
	l_Player:SetVar("afk.kick.time", nil)
	l_Player:SetVar("afk.kick.warn.time", nil)
	l_Player:SetVar("afk.move.time", nil)
	l_Player:SetVar("afk.move.warn.time", nil)
	l_Player:SetVar("afk.slay.time", nil)
	l_Player:SetVar("afk.slay.warn.time", nil)
	l_Player:SetVar("afk.time", nil)
end

function AFK_RoundWarnTime(p_Time)
	local l_Time = math.floor(p_Time / 1000)
	
	if l_Time > 30 then
		local l_Remainder = l_Time % 10
		
		if l_Remainder ~= 0 then
			l_Time = l_Time + 10 - l_Remainder
		end
	elseif l_Time > 5 then
		local l_Remainder = l_Time % 5
		
		if l_Remainder ~= 0 then
			l_Time = l_Time + 5 - l_Remainder
		end
	end
	
	return l_Time * 1000 + p_Time % 1000
end

function AFK_SetPlayerActive(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerAFK = l_Player:GetVar("afk")
	
	if l_PlayerAFK then
		TriggerEvent("AFK_OnPlayerBAK", p_PlayerId)
	end
	
	l_Player:SetVar("afk", nil)
	l_Player:SetVar("afk.time", nil)
	
	AFK_ResetPlayerSlayTime(p_PlayerId, true)
	AFK_ResetPlayerMoveTime(p_PlayerId, true)
	AFK_ResetPlayerKickTime(p_PlayerId, true)
end

function AFK_SlayPlayer(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	AFK_ResetPlayerSlayTime(p_PlayerId)
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	local l_PlayerColor = exports["helpers"]:GetPlayerChatColor(p_PlayerId)
	
	playermanager:SendMsg(MessageType.Chat, string.format("{lime}%s{default} Slayed %s%s{default} for being AFK too long", g_Config["tag"], l_PlayerColor, l_PlayerName))
	
	exports["helpers"]:SlayPlayer(p_PlayerId)
end

function AFK_Think()
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	local l_PlayerCount = exports["helpers"]:GetTeamPlayerCount({Team.Spectator, Team.T, Team.CT}, true)
	local l_PlayerMoveCount = l_PlayerCount[Team.T] + l_PlayerCount[Team.CT]
	local l_PlayerKickCount = l_PlayerCount[Team.T] + l_PlayerCount[Team.CT] + l_PlayerCount[Team.Spectator]
	
	for i = 0, playermanager:GetPlayerCap() - 1 do
		local l_PlayerIter = GetPlayer(i)
		
		if l_PlayerIter and l_PlayerIter:IsValid() and not l_PlayerIter:IsFakeClient() then
			local l_PlayerIterAFK = l_PlayerIter:GetVar("afk")
			local l_PlayerIterAFKTime = l_PlayerIter:GetVar("afk.time") or 0
			
			local l_PlayerIterSlay = AFK_IncreasePlayerSlayTime(i, THINK_INTERVAL)
			local l_PlayerIterMove = AFK_IncreasePlayerMoveTime(i, THINK_INTERVAL, l_PlayerMoveCount)
			local l_PlayerIterKick = AFK_IncreasePlayerKickTime(i, THINK_INTERVAL, l_PlayerKickCount)
			
			l_PlayerIterAFKTime = l_PlayerIterAFKTime + THINK_INTERVAL
			
			l_PlayerIterSlay["timeleft"] = math.max(g_Config["slay.time"] - l_PlayerIterSlay["time"], 0)
			l_PlayerIterMove["timeleft"] = math.max(g_Config["move.time"] - l_PlayerIterMove["time"], 0)
			l_PlayerIterKick["timeleft"] = math.max(g_Config["kick.time"] - l_PlayerIterKick["time"], 0)
			
			l_PlayerIterSlay["timeleft"] = l_PlayerIterSlay["timeleft"] - l_PlayerIterSlay["timeleft"] % 1000
			l_PlayerIterMove["timeleft"] = l_PlayerIterMove["timeleft"] - l_PlayerIterMove["timeleft"] % 1000
			l_PlayerIterKick["timeleft"] = l_PlayerIterKick["timeleft"] - l_PlayerIterKick["timeleft"] % 1000
			
			l_PlayerIter:SetVar("afk.time", l_PlayerIterAFKTime)
			
			if not l_PlayerIterAFK and l_PlayerIterAFKTime >= g_Config["time"] then
				l_PlayerIter:SetVar("afk", true)
				
				TriggerEvent("AFK_OnPlayerAFK", i)
			end
			
			if l_PlayerIterSlay["time"] ~= 0 then
				l_PlayerIter:SetVar("afk.slay.time", l_PlayerIterSlay["time"])
			end
			
			if l_PlayerIterMove["time"] ~= 0 then
				l_PlayerIter:SetVar("afk.move.time", l_PlayerIterMove["time"])
			end
			
			if l_PlayerIterKick["time"] ~= 0 then
				l_PlayerIter:SetVar("afk.kick.time", l_PlayerIterKick["time"])
			end
			
			if l_PlayerIterKick["queue"] and l_PlayerIterKick["timeleft"] == 0 then
				AFK_KickPlayer(i)
			elseif l_PlayerIterMove["queue"] and l_PlayerIterMove["timeleft"] == 0 then
				AFK_MovePlayer(i)
			elseif l_PlayerIterSlay["queue"] and l_PlayerIterSlay["timeleft"] == 0 then
				AFK_SlayPlayer(i)
			end
			
			AFK_WarnPlayerSlay(i, l_PlayerIterSlay, l_PlayerIterMove, l_PlayerIterKick)
			AFK_WarnPlayerMove(i, l_PlayerIterMove, l_PlayerIterKick)
			AFK_WarnPlayerKick(i, l_PlayerIterKick)
		end
	end
end

function AFK_WarnPlayerKick(p_PlayerId, p_Kick)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not p_Kick["queue"] 
		or p_Kick["timeleft"] == 0 
		or p_Kick["timeleft"] > g_Config["kick.warn.time"] 
	then
		return
	end
	
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	local l_PlayerWarnTime = l_Player:GetVar("afk.kick.warn.time")
	local l_TimeLeft = p_Kick["timeleft"]
	
	if p_Kick["pause"] then
		if not l_PlayerWarnTime or l_ServerTime - l_PlayerWarnTime < 5000 then
			return
		end
		
		l_TimeLeft = AFK_RoundWarnTime(l_TimeLeft)
	else
		if l_PlayerWarnTime and l_ServerTime - l_PlayerWarnTime < 1000 then
			return
		end
		
		if l_TimeLeft ~= AFK_RoundWarnTime(l_TimeLeft) then
			return
		end
	end
	
	l_Player:SendMsg(MessageType.Chat, string.format("{lightred}%s{default} You can be kicked in {lightred}%s{default}", g_Config["tag"], exports["helpers"]:FormatTime(l_TimeLeft)))
	
	l_Player:SetVar("afk.kick.warn.time", l_ServerTime)
end

function AFK_WarnPlayerMove(p_PlayerId, p_Move, p_Kick)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not p_Move["queue"] 
		or p_Move["timeleft"] == 0 
		or p_Move["timeleft"] > g_Config["move.warn.time"] 
	then
		return
	end
	
	if p_Kick["queue"] and p_Move["timeleft"] >= p_Kick["timeleft"] then
		return
	end
	
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	local l_PlayerWarnTime = l_Player:GetVar("afk.move.warn.time")
	local l_TimeLeft = p_Move["timeleft"]
	
	if p_Move["pause"] then
		if not l_PlayerWarnTime or l_ServerTime - l_PlayerWarnTime < 5000 then
			return
		end
		
		l_TimeLeft = AFK_RoundWarnTime(l_TimeLeft)
	else
		if l_PlayerWarnTime and l_ServerTime - l_PlayerWarnTime < 1000 then
			return
		end
		
		if l_TimeLeft ~= AFK_RoundWarnTime(l_TimeLeft) then
			return
		end
	end
	
	local l_SpectatorColor = exports["helpers"]:GetTeamChatColor(Team.Spectator)
	
	l_Player:SendMsg(MessageType.Chat, string.format("{lightred}%s{default} You can be moved to %sSpectators{default} in {lightred}%s{default}", g_Config["tag"], l_SpectatorColor, exports["helpers"]:FormatTime(l_TimeLeft)))
	
	l_Player:SetVar("afk.move.warn.time", l_ServerTime)
end

function AFK_WarnPlayerSlay(p_PlayerId, p_Slay, p_Move, p_Kick)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not p_Slay["queue"] 
		or p_Slay["timeleft"] == 0 
		or p_Slay["timeleft"] > g_Config["slay.warn.time"] 
	then
		return
	end
	
	if p_Move["queue"] and p_Slay["timeleft"] >= p_Move["timeleft"] 
		or p_Kick["queue"] and p_Slay["timeleft"] >= p_Kick["timeleft"] 
	then
		return
	end
	
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	local l_PlayerWarnTime = l_Player:GetVar("afk.slay.warn.time")
	local l_TimeLeft = p_Slay["timeleft"]
	
	if p_Slay["pause"] then
		if not l_PlayerWarnTime or l_ServerTime - l_PlayerWarnTime < 5000 then
			return
		end
		
		l_TimeLeft = AFK_RoundWarnTime(l_TimeLeft)
	else
		if l_PlayerWarnTime and l_ServerTime - l_PlayerWarnTime < 1000 then
			return
		end
		
		if l_TimeLeft ~= AFK_RoundWarnTime(l_TimeLeft) then
			return
		end
	end
	
	l_Player:SendMsg(MessageType.Chat, string.format("{lightred}%s{default} You can be slayed in {lightred}%s{default}", g_Config["tag"], exports["helpers"]:FormatTime(l_TimeLeft)))
	
	l_Player:SetVar("afk.slay.warn.time", l_ServerTime)
end