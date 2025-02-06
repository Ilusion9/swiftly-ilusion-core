function Map_AddMapInHistory(p_Map, p_StartTime, p_Reason)
	local l_CurrentTime = GetTime()
	
	table.insert(g_History, {
		["map"] = p_Map,
		["started_at"] = p_StartTime,
		["time"] = l_CurrentTime - p_StartTime,
		["reason"] = p_Reason
	})
end

function Map_ChangeMap(p_Map, p_Workshop, p_Reason)
	if g_ThinkTimer then
		StopTimer(g_ThinkTimer)
		g_ThinkTimer = nil
	end
	
	g_NextMapReason = p_Reason
	
	if p_Workshop then
		server:Execute("host_workshop_map " .. p_Workshop)
	else
		server:Execute("changelevel " .. p_Map)
	end
	
	NextTick(function()
		g_NextMapReason = nil
	end)
end

function Map_CheckCurrentMap()
	if g_Map["index"] or #g_MapCycle == 0 then
		return
	end
	
	SetTimeout(5000, function()
		Map_ChangeMap(g_MapCycle[1]["map"], g_MapCycle[1]["workshop"], "mapcycle")
	end)
end

function Map_CheckPlayerRTVCount()
	if not g_Config["rtv.enable"] or exports["helpers"]:IsMatchOver() then
		return
	end
	
	SetTimeout(100, function()
		if exports["helpers"]:IsMatchOver() then
			return
		end
		
		local l_RemainingRTVCount = Map_GetRemainingRTVCount()
		
		if l_RemainingRTVCount == 0 then
			Map_StartRTV()
		end
	end)
end

function Map_EmitSoundToAll(p_Sound)
	if #p_Sound == 0 then
		return
	end
	
	exports["helpers"]:EmitSoundToAll(p_Sound, 100, 1.0)
end

function Map_EmitSoundToPlayer(p_PlayerId, p_Sound)
	if #p_Sound == 0 then
		return
	end
	
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	exports["helpers"]:EmitSoundToPlayer(p_PlayerId, p_Sound, 100, 1.0)
end

function Map_EndVote()
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	local l_Votes = {}
	local l_VoteMaps = {}
	
	g_VotePeriod = nil
	
	for i = 1, #g_VoteMaps do
		table.insert(l_VoteMaps, {
			["key"] = i,
			["value"] = g_VoteMaps[i]
		})
	end
	
	for i = 0, playermanager:GetPlayerCap() - 1 do
		local l_PlayerIter = GetPlayer(i)
		
		if l_PlayerIter and l_PlayerIter:IsValid() and not l_PlayerIter:IsFakeClient() then
			local l_PlayerIterVote = l_PlayerIter:GetVar("map.vote") or 0
			
			if l_PlayerIterVote ~= 0 then
				if l_Votes[l_PlayerIterVote] then
					l_Votes[l_PlayerIterVote] = l_Votes[l_PlayerIterVote] + 1
				else
					l_Votes[l_PlayerIterVote] = 1
				end
			end
		end
	end
	
    table.sort(l_VoteMaps, function(p_First, p_Second)
		if l_Votes[p_First["value"]] and l_Votes[p_Second["value"]] then
			return l_Votes[p_First["value"]] > l_Votes[p_Second["value"]]
		elseif l_Votes[p_First["value"]] then
			return true
		elseif l_Votes[p_Second["value"]] then
			return false
		end
		
		return p_Second["key"] > p_First["key"]
    end)
	
	for i = 1, #l_VoteMaps do
		l_VoteMaps[i] = l_VoteMaps[i]["value"]
	end
	
	local l_Count = 1
	
	for i = 2, #l_VoteMaps do
		if l_Votes[l_VoteMaps[i]] ~= l_Votes[l_VoteMaps[1]] then
			break
		end
		
		l_Count = l_Count + 1
	end
	
	local l_Index = math.random(1, l_Count)
	
	g_NextMap = {
		["map"] = g_MapCycle[l_VoteMaps[l_Index]]["map"],
		["index"] = l_VoteMaps[l_Index]
	}
	
	g_NextMapPeriod = true
	g_NextMapTime = l_ServerTime + 3000
	
	playermanager:SendMsg(MessageType.Chat, string.format("{lime}%s{default} The nextmap will be {lime}%s{default}", g_Config["tag"], g_NextMap["map"]))
	
	Map_EmitSoundToAll(g_Config["mapchooser.sounds.nextmap"])
end

function Map_FindMap(p_Str)
	local l_Index = nil
	
	for i = 1, #g_MapCycle do
		if g_MapCycle[i]["map"] == p_Str then
			return i
		end
		
		if not l_Index and string.find(g_MapCycle[i]["map"], p_Str, 1, true) then
			l_Index = i
		end
	end
	
	return l_Index
end

function Map_GetNextMaps()
	local l_Maps = {}
	local l_NextMaps = {}
	local l_Nominations = Map_GetNominations()
	local l_PastMaps = Map_GetPastMaps()
	
	for i = 1, #g_MapCycle do
		table.insert(l_Maps, i)
	end
	
	l_Maps = exports["helpers"]:ShuffleTable(l_Maps)
	
	for i = 1, #l_Maps do
		l_Maps[i] = {
			["key"] = i,
			["value"] = l_Maps[i]
		}
	end
	
    table.sort(l_Maps, function(p_First, p_Second)
		if l_Nominations[p_First["value"]] and l_Nominations[p_Second["value"]] then
			return l_Nominations[p_First["value"]] > l_Nominations[p_Second["value"]]
		elseif l_Nominations[p_First["value"]] then
			return true
		elseif l_Nominations[p_Second["value"]] then
			return false
		end
		
		return p_Second["key"] > p_First["key"]
    end)
	
	for i = 1, #l_Maps do
		l_Maps[i] = l_Maps[i]["value"]
		
		if not table.contains(l_PastMaps, l_Maps[i]) then
			table.insert(l_NextMaps, l_Maps[i])
		end
	end
	
	if #l_NextMaps == 0 then
		if #l_PastMaps ~= 0 then
			table.insert(l_NextMaps, l_PastMaps[#l_PastMaps])
		end
	end
	
	return l_NextMaps
end

function Map_GetNominations()
	local l_Nominations = {}
	
	for i = 0, playermanager:GetPlayerCap() - 1 do
		local l_PlayerIter = GetPlayer(i)
		
		if l_PlayerIter and l_PlayerIter:IsValid() and not l_PlayerIter:IsFakeClient() then
			local l_PlayerIterNominations = l_PlayerIter:GetVar("map.nominations") or {}
			
			for j = 1, #l_PlayerIterNominations do
				if l_Nominations[l_PlayerIterNominations[j]] then
					l_Nominations[l_PlayerIterNominations[j]] = l_Nominations[l_PlayerIterNominations[j]] + 1
				else
					l_Nominations[l_PlayerIterNominations[j]] = 1
				end
			end
		end
	end
	
	return l_Nominations
end

function Map_GetPastMaps()
	local l_PastMaps = {}
	
	if g_Config["mapchooser.exclude.count"] == 0 then
		return l_PastMaps
	end
	
	if g_Map["index"] then
		table.insert(l_PastMaps, g_Map["index"])
		
		if #l_PastMaps == g_Config["mapchooser.exclude.count"] then
			return l_PastMaps
		end
	end
	
	local l_CurrentTime = GetTime()
	
	for i = 1, #g_History do
		local l_Map = g_History[i]["map"]
		local l_StartTime = g_History[i]["started_at"]
		
		local l_Index = Map_FindMap(l_Map)
		
		if l_Index and not table.contains(l_PastMaps, l_Index) then
			if g_Config["mapchooser.exclude.time"] == 0 
				or l_StartTime + g_Config["mapchooser.exclude.time"] > l_CurrentTime 
			then
				table.insert(l_PastMaps, l_Index)
				
				if #l_PastMaps == g_Config["mapchooser.exclude.count"] then
					break
				end
			end
		end
	end
	
	return l_PastMaps
end

function Map_GetRemainingRTVCount()
	local l_PlayerCount = 0
	local l_RTVCount = 0
	
	for i = 0, playermanager:GetPlayerCap() - 1 do
		local l_PlayerIter = GetPlayer(i)
		
		if l_PlayerIter and l_PlayerIter:IsValid() and not l_PlayerIter:IsFakeClient() then
			local l_PlayerIterRTVQueue = l_PlayerIter:GetVar("map.rtv.queue")
			
			if l_PlayerIterRTVQueue then
				l_RTVCount = l_RTVCount + 1
			end
			
			l_PlayerCount = l_PlayerCount + 1
		end
	end
	
	if l_PlayerCount == 0 then
		return nil
	end
	
	local l_RemainingRTVCount = math.ceil(l_PlayerCount * g_Config["rtv.required.percent"] / 100) - l_RTVCount
	
	return math.max(l_RemainingRTVCount, 0)
end

function Map_HandlePlayerVote(p_PlayerId, p_Text)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_Index = tonumber(p_Text)
	
	if not l_Index or l_Index < 1 or l_Index > #g_VoteMaps then
		l_Player:SendMsg(MessageType.Chat, string.format("{lightred}%s{default} Invalid ID specified", g_Config["tag"]))
		
		Map_EmitSoundToPlayer(p_PlayerId, g_Config["mapchooser.sounds.player.error"])
		
		return
	end
	
	local l_PlayerVote = l_Player:GetVar("map.vote")
	
	if l_PlayerVote then
		l_Player:SendMsg(MessageType.Chat, string.format("{lightred}%s{default} You already voted {lime}(%s){default}", g_Config["tag"], g_MapCycle[l_PlayerVote]["map"]))
		
		Map_EmitSoundToPlayer(p_PlayerId, g_Config["mapchooser.sounds.player.error"])
		
		return
	end
	
	l_Player:SendMsg(MessageType.Chat, string.format("{lime}%s{default} You voted for {lime}%s{default}", g_Config["tag"], g_MapCycle[g_VoteMaps[l_Index]]["map"]))
	
	Map_EmitSoundToPlayer(p_PlayerId, g_Config["mapchooser.sounds.player.success"])
	
	l_Player:SetVar("map.vote", g_VoteMaps[l_Index])
end

function Map_LoadConfig()
	config:Reload("map")
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("map.tag")
	g_Config["history.size"] = tonumber(config:Fetch("map.history"))
	g_Config["mapchooser.include.count"] = tonumber(config:Fetch("map.mapchooser.include.count"))
	g_Config["mapchooser.exclude.count"] = tonumber(config:Fetch("map.mapchooser.exclude.count"))
	g_Config["mapchooser.exclude.time"] = tonumber(config:Fetch("map.mapchooser.exclude.time"))
	g_Config["mapchooser.sounds.player.success"] = config:Fetch("map.mapchooser.sounds.player.success")
	g_Config["mapchooser.sounds.player.error"] = config:Fetch("map.mapchooser.sounds.player.error")
	g_Config["mapchooser.sounds.timer"] = config:Fetch("map.mapchooser.sounds.timer")
	g_Config["mapchooser.sounds.nextmap"] = config:Fetch("map.mapchooser.sounds.nextmap")
	g_Config["mapchooser.time"] = tonumber(config:Fetch("map.mapchooser.time"))
	g_Config["maplist.pagination.size"] = tonumber(config:Fetch("map.maplist.pagination.size"))
	g_Config["nominations.enable"] = config:Fetch("map.nominations.enable")
	g_Config["rtv.enable"] = config:Fetch("map.rtv.enable")
	g_Config["rtv.required.percent"] = tonumber(config:Fetch("map.rtv.required.percent"))
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Map]"
	end
	
	if not g_Config["history.size"] or g_Config["history.size"] < 0 then
		g_Config["history.size"] = HISTORY_SIZE
	end
	
	if not g_Config["mapchooser.include.count"] 
		or g_Config["mapchooser.include.count"] < MAPCHOOSER_INCLUDE 
	then
		g_Config["mapchooser.include.count"] = MAPCHOOSER_INCLUDE
	end
	
	if not g_Config["mapchooser.exclude.count"] or g_Config["mapchooser.exclude.count"] < 0 then
		g_Config["mapchooser.exclude.count"] = 0
	end
	
	if not g_Config["mapchooser.exclude.time"] or g_Config["mapchooser.exclude.time"] < 0 then
		g_Config["mapchooser.exclude.time"] = 0
	end
	
	if type(g_Config["mapchooser.sounds.player.success"]) ~= "string" then
		g_Config["mapchooser.sounds.player.success"] = ""
	end
	
	if type(g_Config["mapchooser.sounds.player.error"]) ~= "string" then
		g_Config["mapchooser.sounds.player.error"] = ""
	end
	
	if type(g_Config["mapchooser.sounds.timer"]) ~= "string" then
		g_Config["mapchooser.sounds.timer"] = ""
	end
	
	if type(g_Config["mapchooser.sounds.nextmap"]) ~= "string" then
		g_Config["mapchooser.sounds.nextmap"] = ""
	end
	
	if not g_Config["mapchooser.time"] or g_Config["mapchooser.time"] < MAPCHOOSER_TIME then
		g_Config["mapchooser.time"] = MAPCHOOSER_TIME
	end
	
	if not g_Config["maplist.pagination.size"] or g_Config["maplist.pagination.size"] < 0 then
		g_Config["maplist.pagination.size"] = PAGINATION_SIZE
	end
	
	if type(g_Config["nominations.enable"]) ~= "boolean" then
		g_Config["nominations.enable"] = tonumber(g_Config["nominations.enable"])
		g_Config["nominations.enable"] = g_Config["nominations.enable"] and g_Config["nominations.enable"] ~= 0
	end
	
	if type(g_Config["rtv.enable"]) ~= "boolean" then
		g_Config["rtv.enable"] = tonumber(g_Config["rtv.enable"])
		g_Config["rtv.enable"] = g_Config["rtv.enable"] and g_Config["rtv.enable"] ~= 0
	end
	
	if not g_Config["rtv.required.percent"] or g_Config["rtv.required.percent"] < 0 then
		g_Config["rtv.required.percent"] = 0
	elseif g_Config["rtv.required.percent"] > 100 then
		g_Config["rtv.required.percent"] = 100
	end
	
	g_Config["mapchooser.exclude.time"] = math.floor(g_Config["mapchooser.exclude.time"] * 1000)
	g_Config["mapchooser.time"] = math.floor(g_Config["mapchooser.time"] * 1000)
end

function Map_LoadCurrentMap()
	local l_CurrentTime = GetTime()
	
	local l_Map = server:GetMap()
	local l_Index = Map_FindMap(l_Map)
	
	g_Map = {
		["map"] = l_Map,
		["index"] = l_Index,
		["time"] = l_CurrentTime
	}
end

function Map_LoadHistory()
	local l_History = json.decode(files:Read("maphistory.json"))
	
	if type(l_History) ~= "table" then
		l_History = {}
	end
	
	g_History = l_History
end

function Map_LoadMaps()
	g_MapCycle = {}
	
	local l_Maps = {}
	local l_MapCycle = json.decode(files:Read("mapcycle.json"))
	
	if type(l_MapCycle) ~= "table" then
		l_MapCycle = {}
	end
	
	for i = 1, #l_MapCycle do
		local l_Map = l_MapCycle[i]["map"]
		local l_Workshop = tonumber(l_MapCycle[i]["workshop"])
		
		if type(l_Map) ~= "string" or #l_Map == 0 then
			l_Map = nil
		end
		
		if not l_Workshop or l_Workshop < 1 then
			l_Workshop = nil
		end
		
		if l_Map and not l_Maps[l_Map] then
			table.insert(g_MapCycle, {
				["map"] = l_Map,
				["workshop"] = l_Workshop
			})
			
			l_Maps[l_Map] = true
		end
	end
end

function Map_ResetPlayerVars(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	l_Player:SetVar("map.nominations", nil)
	l_Player:SetVar("map.rtv.queue", nil)
	l_Player:SetVar("map.vote", nil)
end

function Map_ResetVars()
	g_Map = nil
	
	g_NextMap = nil
	g_NextMapPeriod = nil
	g_NextMapReason = nil
	g_NextMapTime = nil
	
	g_RTVNextRound = nil
	
	g_ThinkSoundTime = nil
	
	g_VoteMaps = nil
	g_VotePeriod = nil
	g_VoteEndTime = nil
end

function Map_SaveHistory()
	if #g_History == 0 then
		return
	end
	
	local l_History = {}
	
	for i = 1, #g_History do
		table.insert(l_History, g_History[i])
	end
	
	for i = #l_History - g_Config["history.size"], 1, -1 do
		table.remove(l_History, i)
	end
	
	files:Write("maphistory.json", json.encode(l_History), false)
end

function Map_SetConVars()
	local l_Config = {}
	
	l_Config["mp_endmatch_votenextleveltime"] = 0
	l_Config["mp_match_end_changelevel"] = 1
	l_Config["mp_match_end_restart"] = 0
	l_Config["mp_match_restart_delay"] = 3600
	l_Config["mp_win_panel_display_time"] = 0
	
	for l_Key, l_Value in next, l_Config do
		exports["helpers"]:SetConVar(l_Key, l_Value)
	end
end

function Map_StartRTV(p_Delay)
	local l_Function = function()
		if exports["helpers"]:IsMatchOver() then
			return
		end
		
		for i = 0, playermanager:GetPlayerCap() - 1 do
			local l_PlayerIter = GetPlayer(i)
			
			if l_PlayerIter and l_PlayerIter:IsValid() then
				l_PlayerIter:SetVar("map.rtv.queue", nil)
			end
		end
		
		if exports["helpers"]:IsWarmupPeriod() or exports["helpers"]:IsRoundOver() then
			if not g_RTVNextRound then
				playermanager:SendMsg(MessageType.Chat, string.format("{lime}%s{default} The vote will start on the next round", g_Config["tag"]))
			end
			
			g_RTVNextRound = true
			return
		end
		
		g_RTVNextRound = nil
		
		exports["helpers"]:SetConVar("mp_fraglimit", 0)
		exports["helpers"]:SetConVar("mp_maxrounds", 0)
		exports["helpers"]:SetConVar("mp_timelimit", 0)
		exports["helpers"]:SetConVar("mp_winlimit", 0)
		
		exports["helpers"]:TerminateRound(RoundEndReason_t.RoundDraw, "map")
	end
	
	if p_Delay then
		if exports["helpers"]:IsMatchOver() then
			return
		end
		
		SetTimeout(p_Delay, l_Function)
	else
		l_Function()
	end
end

function Map_StartVote(p_Delay)
	local l_Function = function()
		if g_VotePeriod or g_NextMapPeriod or not exports["helpers"]:IsMatchOver() then
			return
		end
		
		local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
		local l_NextMaps = Map_GetNextMaps()
		
		if #l_NextMaps > 1 then
			g_VoteMaps = {}
			
			for i = 1, #l_NextMaps do
				table.insert(g_VoteMaps, l_NextMaps[i])
				
				if i == g_Config["mapchooser.include.count"] then
					break
				end
			end
			
			g_VoteEndTime = l_ServerTime + g_Config["mapchooser.time"]
			g_VotePeriod = true
		else
			if #l_NextMaps == 1 then
				g_NextMap = {
					["map"] = g_MapCycle[l_NextMaps[1]]["map"],
					["index"] = l_NextMaps[1]
				}
			else
				g_NextMap = {
					["map"] = g_Map["map"],
					["index"] = g_Map["index"]
				}
			end
			
			g_NextMapPeriod = true
			g_NextMapTime = l_ServerTime + 3000
			
			playermanager:SendMsg(MessageType.Chat, string.format("{lime}%s{default} The nextmap will be {lime}%s{default}", g_Config["tag"], g_NextMap["map"]))
			
			Map_EmitSoundToAll(g_Config["mapchooser.sounds.nextmap"])
		end
		
		Map_Think()
		g_ThinkTimer = SetTimer(THINK_INTERVAL, Map_Think)
	end
	
	if p_Delay then
		if g_VotePeriod or g_NextMapPeriod or not exports["helpers"]:IsMatchOver() then
			return
		end
		
		SetTimeout(p_Delay, l_Function)
	else
		l_Function()
	end
end

function Map_Think()
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	if g_VotePeriod and l_ServerTime >= g_VoteEndTime then
		Map_EndVote()
	end
	
	if g_NextMapPeriod and l_ServerTime >= g_NextMapTime then
		Map_ChangeMap(g_NextMap["map"], g_NextMap["index"] and g_MapCycle[g_NextMap["index"]]["workshop"], "changelevel")
		return
	end
	
	local l_PlayerCount = 0
	
	local l_VoteCount = 0
	local l_VoteTime = g_VotePeriod and math.ceil((g_VoteEndTime - l_ServerTime) / 1000) or 0
	
	for i = 0, playermanager:GetPlayerCap() - 1 do
		local l_PlayerIter = GetPlayer(i)
		
		if l_PlayerIter and l_PlayerIter:IsValid() and not l_PlayerIter:IsFakeClient() then
			local l_HintTextTop = ""
			local l_HintTextBottom = ""
			
			if g_VotePeriod then
				local l_PlayerIterVote = l_PlayerIter:GetVar("map.vote")
				
				l_HintTextTop = "<font color='#A5FF50'>VOTE MAP</font>" 
				l_HintTextTop = l_HintTextTop .. "<br>" 
				l_HintTextTop = l_HintTextTop .. string.format("Time <font color='#FFEA50'>%02d:%02d</font>", math.floor(l_VoteTime / 60), l_VoteTime % 60)
				
				for j = 1, #g_VoteMaps do
					if #l_HintTextBottom ~= 0 then
						l_HintTextBottom = l_HintTextBottom .. "<br>"
					end
					
					l_HintTextBottom = l_HintTextBottom 
						.. string.format("<font color='%s'>[%d]</font> %s", g_VoteMaps[j] == l_PlayerIterVote and "#A5FF50" or "#FFA500", j, g_MapCycle[g_VoteMaps[j]]["map"])
				end
				
				l_HintTextBottom = l_HintTextBottom .. "<br>"
				l_HintTextBottom = l_HintTextBottom .. "<br>"
				l_HintTextBottom = l_HintTextBottom .. "Type the ID in chat"
				
				if not g_ThinkSoundTime or l_ServerTime >= g_ThinkSoundTime + THINK_SOUND_INTERVAL then
					Map_EmitSoundToPlayer(i, g_Config["mapchooser.sounds.timer"])
				end
				
				if l_PlayerIterVote then
					l_VoteCount = l_VoteCount + 1
				end
			elseif g_NextMapPeriod then
				l_HintTextBottom = string.format("Nextmap <font color='#A5FF50'>%s</font>", g_NextMap["map"])
			end
			
			if #l_HintTextTop ~= 0 and #l_HintTextBottom ~= 0 then
				l_PlayerIter:SendMsg(MessageType.Center, string.format("%s<br><font color='gray'> -------------------------------- </font><br>%s", l_HintTextTop, l_HintTextBottom))
			elseif #l_HintTextTop ~= 0 then
				l_PlayerIter:SendMsg(MessageType.Center, l_HintTextTop)
			elseif #l_HintTextBottom ~= 0 then
				l_PlayerIter:SendMsg(MessageType.Center, l_HintTextBottom)
			end
			
			l_PlayerCount = l_PlayerCount + 1
		end
	end
	
	if g_VotePeriod then
		if l_PlayerCount ~= 0 and l_PlayerCount == l_VoteCount then
			Map_EndVote()
		elseif not g_ThinkSoundTime or l_ServerTime >= g_ThinkSoundTime + THINK_SOUND_INTERVAL then
			g_ThinkSoundTime = l_ServerTime
		end
	end
end