function Helpers_ChangePlayerName(p_PlayerId, p_Name)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_EventReturn, l_Event = TriggerEvent("Helpers_OnPlayerChangeName", p_PlayerId, p_Name)
	local l_EventName = l_Event:GetReturn() or p_Name
	
	l_Player:CBasePlayerController().PlayerName = l_EventName
	
	Helpers_StorePlayerName(p_PlayerId)
end

function Helpers_ChangePlayerTeam(p_PlayerId, p_Team)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerTeam = Helpers_GetPlayerTeam(p_PlayerId)
	
	if p_Team == l_PlayerTeam then
		return
	end
	
	if Helpers_IsPlayerAlive(p_PlayerId) then
		Helpers_SlayPlayer(p_PlayerId)
	end
	
	l_Player:ChangeTeam(p_Team)
end

function Helpers_CreateBeamEntity(p_Point1, p_Point2, p_Name, p_Color)
	local l_Entity = CreateEntityByName("beam")

	if not l_Entity or not l_Entity:IsValid() then
		return
	end
	
	l_Entity = CBaseEntity(l_Entity:ToPtr())
	
	if not l_Entity or not l_Entity:IsValid() then
		return
	end
	
	local l_EntityBeam = CBeam(l_Entity:ToPtr())
	
	if not l_EntityBeam or not l_EntityBeam:IsValid() then
		return
	end
	
	local l_EntityModel = CBaseModelEntity(l_Entity:ToPtr())
	
	if not l_EntityModel or not l_EntityModel:IsValid() then
		return
	end
	
	l_Entity.Parent.Entity.Name = p_Name
	
	l_Entity:Spawn()
	l_Entity:Teleport(Vector(p_Point1[1], p_Point1[2], p_Point1[3]), QAngle(0, 0, 0))
	
	l_EntityBeam.Width = 1
	l_EntityBeam.EndPos = Vector(p_Point2[1], p_Point2[2], p_Point2[3])
	
	l_EntityModel.Render = Color(p_Color[1], p_Color[2], p_Color[3], p_Color[4])
end

function Helpers_EmitSoundToAll(p_Sound, p_Pitch, p_Volume)
	for i = 0, playermanager:GetPlayerCap() - 1 do
		Helpers_EmitSoundToPlayer(i, p_Sound, p_Pitch, p_Volume)
	end
end

function Helpers_EmitSoundToPlayer(p_PlayerId, p_Sound, p_Pitch, p_Volume)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	CBaseEntity(l_Player:CCSPlayerController():ToPtr()):EmitSound(p_Sound, p_Pitch, p_Volume)
end

function Helpers_EncodeString(p_Str)
	return Helpers_StringReplace(p_Str, g_EncodingPatterns, g_EncodingReplacements)
end

function Helpers_ExecuteCommandToAll(p_Command)
	for i = 0, playermanager:GetPlayerCap() - 1 do
		local l_PlayerIter = GetPlayer(i)
		
		if l_PlayerIter and l_PlayerIter:IsValid() then
			l_PlayerIter:ExecuteCommand(p_Command)
		end
	end
end

function Helpers_FindPlayerBySteam(p_Steam)
	for i = 0, playermanager:GetPlayerCap() - 1 do
		local l_PlayerIter = GetPlayer(i)
		
		if l_PlayerIter and l_PlayerIter:IsValid() then
			local l_PlayerIterSteam = Helpers_GetPlayerSteam(i)
			
			if l_PlayerIterSteam == p_Steam then
				return i
			end
		end
	end
	
	return nil
end

function Helpers_FindTarget(p_PlayerId, p_Arg, p_Flags, p_Tag)
	local l_Arg = string.lower(p_Arg)
	local l_Flags = {}
	
	for i = 1, #p_Flags do
		l_Flags[p_Flags[i]] = true
	end
	
	local l_Target = nil
	local l_TargetId = nil
	
	if string.sub(l_Arg, 1, 1) == "#" then
		l_TargetId = tonumber(string.sub(l_Arg, 2))
		
		if not l_TargetId then
			Helpers_ReplyToCommand(p_PlayerId, "{lightred}" .. p_Tag .. "{default}", "No matching client was found")
			return nil
		end
		
		l_Target = GetPlayer(l_TargetId)
		
		if not l_Target or not l_Target:IsValid() then
			Helpers_ReplyToCommand(p_PlayerId, "{lightred}" .. p_Tag .. "{default}", "No matching client was found")
			return nil
		end
	else
		for i = 0, playermanager:GetPlayerCap() - 1 do
			local l_PlayerIter = GetPlayer(i)
			
			if l_PlayerIter and l_PlayerIter:IsValid() then
				local l_PlayerIterName = string.lower(Helpers_GetPlayerName(i))
				
				if string.find(l_PlayerIterName, l_Arg, 1, true) then
					if l_Target then
						Helpers_ReplyToCommand(p_PlayerId, "{lightred}" .. p_Tag .. "{default}", "More than one client matches the pattern")
						return nil
					end
					
					l_Target = l_PlayerIter
					l_TargetId = i
				end
			end
		end
		
		if not l_Target then
			Helpers_ReplyToCommand(p_PlayerId, "{lightred}" .. p_Tag .. "{default}", "No matching client was found")
			return nil
		end
	end
	
	if l_Flags["n"] and l_Target:IsFakeClient() then
		Helpers_ReplyToCommand(p_PlayerId, "{lightred}" .. p_Tag .. "{default}", "Unable to perform this command on a bot")
		return nil
	end
	
	if l_Flags["a"] and not Helpers_IsPlayerAlive(l_TargetId) then
		Helpers_ReplyToCommand(p_PlayerId, "{lightred}" .. p_Tag .. "{default}", "This command can only be used on alive players")
		return nil
	end
	
	if l_Flags["d"] and Helpers_IsPlayerAlive(l_TargetId) then
		Helpers_ReplyToCommand(p_PlayerId, "{lightred}" .. p_Tag .. "{default}", "This command can only be used on dead players")
		return nil
	end
	
	if l_Flags["i"] and not exports["admin"]:CanPlayerTargetPlayer(p_PlayerId, l_TargetId) then
		Helpers_ReplyToCommand(p_PlayerId, "{lightred}" .. p_Tag .. "{default}", "You cannot target this player")
		return nil
	end
	
	return l_TargetId
end

function Helpers_FormatDate(p_Time)
	return os.date("!%Y/%m/%d - %H:%M:%S", math.floor(p_Time / 1000))
end

function Helpers_FormatTime(p_Time)
	local l_Time = math.floor(p_Time / 1000)
	local l_Days = math.floor(l_Time / 86400)
	local l_Hours = math.floor(l_Time / 3600) % 24
	local l_Minutes = math.floor(l_Time / 60) % 60
	local l_Seconds = l_Time % 60
	
	if l_Days > 0 then
		return string.format("%d %s", l_Days, l_Days ~= 1 and "days" or "day")
	end
	
	if l_Hours > 0 then
		return string.format("%d %s", l_Hours, l_Hours ~= 1 and "hours" or "hour")
	end
	
	if l_Minutes > 0 then
		return string.format("%d min", l_Minutes)
	end
	
	if l_Seconds > 0 then
		return string.format("%d sec", l_Seconds)
	end
	
	return "0 sec"
end

function Helpers_GetArgTime(p_Arg)
	local l_Type = string.sub(p_Arg, #p_Arg, #p_Arg)
	
	if l_Type == "d" or l_Type == "h" or l_Type == "m" then
		local l_Value = tonumber(string.sub(p_Arg, 1, #p_Arg - 1))
		
		if not l_Value then
			return nil
		end
		
		if l_Type == "d" then
			return l_Value * 86400000
		elseif l_Type == "h" then
			return l_Value * 3600000
		elseif l_Type == "m" then
			return l_Value * 60000
		end
	end
	
	local l_Value = tonumber(p_Arg)
	
	if not l_Value then
		return nil
	end
	
	return l_Value * 1000
end

function Helpers_GetBoxEdgesFromPoints(p_Point1, p_Point2)
	local l_Min = {}
	local l_Max = {}
	
	if p_Point1[1] > p_Point2[1] and p_Point1[2] > p_Point2[2] and p_Point1[3] > p_Point2[3] then
		l_Min = p_Point2
		l_Max = p_Point1
	else
		l_Min = p_Point1
		l_Max = p_Point2
	end
	
	local l_Pos1 = {l_Max[1], l_Max[2], l_Max[3]}
	local l_Pos2 = {l_Max[1], l_Max[2], l_Max[3]}
	local l_Pos3 = {l_Max[1], l_Max[2], l_Max[3]}
	local l_Pos4 = {l_Min[1], l_Min[2], l_Min[3]}
	local l_Pos5 = {l_Min[1], l_Min[2], l_Min[3]}
	local l_Pos6 = {l_Min[1], l_Min[2], l_Min[3]}
	
	l_Pos1[1] = l_Min[1]
	l_Pos2[2] = l_Min[2]
	l_Pos3[3] = l_Min[3]
	l_Pos4[1] = l_Max[1]
	l_Pos5[2] = l_Max[2]
	l_Pos6[3] = l_Max[3]
	
	return {
		{l_Max, l_Pos1},
		{l_Max, l_Pos2},
		{l_Max, l_Pos3},
		{l_Pos6, l_Pos1},
		{l_Pos6, l_Pos2},
		{l_Pos6, l_Min},
		{l_Pos4, l_Min},
		{l_Pos5, l_Min},
		{l_Pos5, l_Pos1},
		{l_Pos5, l_Pos3},
		{l_Pos4, l_Pos3},
		{l_Pos4, l_Pos2}
	}
end

function Helpers_GetBoxFromPoints(p_Point1, p_Point2)
	local l_Min = {}
	local l_Max = {}
	
	if p_Point1[1] > p_Point2[1] and p_Point1[2] > p_Point2[2] and p_Point1[3] > p_Point2[3] then
		l_Min = p_Point2
		l_Max = p_Point1
	else
		l_Min = p_Point1
		l_Max = p_Point2
	end
	
	local l_Middle = {
		(l_Max[1] - l_Min[1]) / 2,
		(l_Max[2] - l_Min[2]) / 2,
		(l_Max[3] - l_Min[3]) / 2
	}
	
	local l_Origin = {
		l_Min[1] + l_Middle[1],
		l_Min[2] + l_Middle[2],
		l_Min[3] + l_Middle[3]
	}
	
	l_Middle[1] = math.abs(l_Middle[1])
	l_Middle[2] = math.abs(l_Middle[2])
	l_Middle[3] = math.abs(l_Middle[3])
	
	local l_Mins = {
		-l_Middle[1],
		-l_Middle[2],
		-l_Middle[3]
	}
	
	return {
		["mins"] = l_Mins,
		["maxs"] = l_Middle,
		["origin"] = l_Origin
	}
end

function Helpers_GetItemIdClassname(p_Id)
	if type(p_Id) ~= "number" then
		return nil
	end
	
	return g_Items[p_Id]
end

function Helpers_GetItemIdFromClassname(p_Classname)
	if type(p_Classname) ~= "string" then
		return nil
	end
	
	return g_Items[p_Classname]
end

function Helpers_GetMapTimeLeft()
	local l_Entity = GetCCSGameRules()
	
	if not l_Entity or not l_Entity:IsValid() then
		return nil
	end
	
	if Helpers_IsWarmupPeriod() then
		return nil
	end
	
	local l_TimeLimit = math.max(convar:Get("mp_timelimit"), 0)
	
	if l_TimeLimit == 0 then
		return TIME_INDEFINITE
	end
	
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	local l_StartTime = math.floor(l_Entity.MatchStartTime * 1000)
	local l_TimeLeft = l_StartTime + math.floor(l_TimeLimit * 60000) - l_ServerTime
	
	return math.max(l_TimeLeft, 0)
end

function Helpers_GetPlayerActiveWeapon(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return nil
	end
	
	local l_PlayerWeaponServices = l_Player:CBasePlayerPawn().WeaponServices
	
	if not l_PlayerWeaponServices 
		or not l_PlayerWeaponServices:IsValid() 
		or not l_PlayerWeaponServices.ActiveWeapon 
		or not l_PlayerWeaponServices.ActiveWeapon:IsValid() 
	then
		return nil
	end
	
	return l_PlayerWeaponServices.ActiveWeapon:ToPtr()
end

function Helpers_GetPlayerArmorType(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return nil
	end
	
	local l_PlayerItemServices = CCSPlayer_ItemServices(l_Player:CBasePlayerPawn().ItemServices:ToPtr())
	
	if l_PlayerItemServices.HasHeavyArmor then
		return "heavyassaultsuit"
	end
	
	if l_PlayerItemServices.HasHelmet then
		return "assaultsuit"
	end
	
	local l_PlayerArmor = Helpers_GetPlayerArmor(p_PlayerId)
	
	if l_PlayerArmor ~= 0 then
		return "kevlar"
	end
	
	return nil
end

function Helpers_GetPlayerArmorValue(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return 0
	end
	
	return l_Player:CCSPlayerPawn().ArmorValue
end

function Helpers_GetPlayerAssists(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player 
		or not l_Player:CCSPlayerController() 
		or not l_Player:CCSPlayerController():IsValid() 
	then
		return 0
	end
	
	return l_Player:CCSPlayerController().ActionTrackingServices.MatchStats.Parent.Assists
end

function Helpers_GetPlayerChatColor(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return Helpers_GetTeamChatColor(Team.None)
	end
	
	local l_PlayerTeam = Helpers_GetPlayerTeam(p_PlayerId)
	
	return Helpers_GetTeamChatColor(l_PlayerTeam)
end

function Helpers_GetPlayerChatTags(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return nil
	end
	
	return l_Player:GetVar("helpers.chat.tags") or {}
end

function Helpers_GetPlayerClanTags(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return nil
	end
	
	return l_Player:GetVar("helpers.clan.tags") or {}
end

function Helpers_GetPlayerCount(p_Nobots)
	local l_PlayerCount = 0
	
	for i = 0, playermanager:GetPlayerCap() - 1 do
		local l_PlayerIter = GetPlayer(i)
		
		if l_PlayerIter and l_PlayerIter:IsValid() then
			if not p_Nobots or not l_PlayerIter:IsFakeClient() then
				l_PlayerCount = l_PlayerCount + 1
			end
		end
	end
	
	return l_PlayerCount
end

function Helpers_GetPlayerDamage(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player 
		or not l_Player:CCSPlayerController() 
		or not l_Player:CCSPlayerController():IsValid() 
	then
		return 0
	end
	
	return l_Player:CCSPlayerController().ActionTrackingServices.MatchStats.Parent.Damage
end

function Helpers_GetPlayerDeaths(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player 
		or not l_Player:CCSPlayerController() 
		or not l_Player:CCSPlayerController():IsValid() 
	then
		return 0
	end
	
	return l_Player:CCSPlayerController().ActionTrackingServices.MatchStats.Parent.Deaths
end

function Helpers_GetPlayerEntityName(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player 
		or not l_Player:CBaseEntity() 
		or not l_Player:CBaseEntity():IsValid() 
	then
		return ""
	end
	
	return l_Player:CBaseEntity().Parent.Entity.Name
end

function Helpers_GetPlayerHealth(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return 0
	end
	
	return l_Player:CBaseEntity().Health
end

function Helpers_GetPlayerHintColor(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return Helpers_GetTeamHintColor(Team.None)
	end
	
	local l_PlayerTeam = Helpers_GetPlayerTeam(p_PlayerId)
	
	return Helpers_GetTeamHintColor(l_PlayerTeam)
end

function Helpers_GetPlayerKills(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player 
		or not l_Player:CCSPlayerController() 
		or not l_Player:CCSPlayerController():IsValid() 
	then
		return 0
	end
	
	return l_Player:CCSPlayerController().ActionTrackingServices.MatchStats.Parent.Kills
end

function Helpers_GetPlayerMaxs(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return NULL_VECTOR
	end
	
	local l_PlayerMaxs = l_Player:CBaseEntity().Collision.Maxs
	
	return {
		l_PlayerMaxs.x,
		l_PlayerMaxs.y,
		l_PlayerMaxs.z
	}
end

function Helpers_GetPlayerMins(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return NULL_VECTOR
	end
	
	local l_PlayerMins = l_Player:CBaseEntity().Collision.Mins
	
	return {
		l_PlayerMins.x,
		l_PlayerMins.y,
		l_PlayerMins.z
	}
end

function Helpers_GetPlayerMVPs(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player 
		or not l_Player:CCSPlayerController() 
		or not l_Player:CCSPlayerController():IsValid() 
	then
		return 0
	end
	
	return l_Player:CCSPlayerController().MVPs
end

function Helpers_GetPlayerName(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return ""
	end
	
	local l_PlayerName = l_Player:GetVar("helpers.name")
	
	if l_Player:CBasePlayerController() 
		and l_Player:CBasePlayerController():IsValid() 
	then
		local l_PlayerConnected = l_Player:CBasePlayerController().Connected
		
		if l_PlayerConnected ~= PlayerConnectedState.PlayerDisconnecting 
			and l_PlayerConnected ~= PlayerConnectedState.PlayerDisconnected 
		then
			l_PlayerName = l_Player:CBasePlayerController().PlayerName
		end
	end
	
	if not l_PlayerName then
		return ""
	end
	
	if l_Player:IsFakeClient() then
		l_PlayerName = "BOT " .. l_PlayerName
	end
	
	return l_PlayerName
end

function Helpers_GetPlayerNextAttackTime(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return 0
	end
	
	local l_PlayerWeaponServices = l_Player:CBasePlayerPawn().WeaponServices
	
	if not l_PlayerWeaponServices or not l_PlayerWeaponServices:IsValid() then
		return 0
	end
	
	l_PlayerWeaponServices = CCSPlayer_WeaponServices(l_PlayerWeaponServices:ToPtr())
	
	if not l_PlayerWeaponServices or not l_PlayerWeaponServices:IsValid() then
		return 0
	end
	
	return math.floor(l_PlayerWeaponServices.NextAttack * 1000)
end

function Helpers_GetPlayerOrigin(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return NULL_VECTOR
	end
	
	local l_PlayerOrigin = l_Player:CBaseEntity().CBodyComponent.SceneNode.AbsOrigin
	
	return {
		l_PlayerOrigin.x,
		l_PlayerOrigin.y,
		l_PlayerOrigin.z
	}
end

function Helpers_GetPlayerRotation(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return 0
	end
	
	local l_PlayerRotation = l_Player:CBaseEntity().CBodyComponent.SceneNode.AbsRotation
	
	return {
		l_PlayerRotation.x,
		l_PlayerRotation.y,
		l_PlayerRotation.z
	}
end

function Helpers_GetPlayerScore(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player 
		or not l_Player:CCSPlayerController() 
		or not l_Player:CCSPlayerController():IsValid() 
	then
		return 0
	end
	
	return l_Player:CCSPlayerController().Score
end

function Helpers_GetPlayerSpeed(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return 0
	end
	
	local l_PlayerVelocity = Helpers_GetPlayerVelocity(p_PlayerId)
	local l_PlayerVelocityModifier = l_Player:CCSPlayerPawn().VelocityModifier
	
	l_PlayerVelocity[1] = l_PlayerVelocity[1] * l_PlayerVelocity[1]
	l_PlayerVelocity[2] = l_PlayerVelocity[2] * l_PlayerVelocity[2]
	l_PlayerVelocity[3] = l_PlayerVelocity[3] * l_PlayerVelocity[3]
	
	return math.floor(l_PlayerVelocityModifier * math.sqrt(l_PlayerVelocity[1] + l_PlayerVelocity[2] + l_PlayerVelocity[3]))
end

function Helpers_GetPlayerSteam(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return tostring(0)
	end
	
	return tostring(l_Player:GetSteamID())
end

function Helpers_GetPlayerTeam(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player 
		or not l_Player:CBaseEntity() 
		or not l_Player:CBaseEntity():IsValid() 
	then
		return Team.None
	end
	
	return l_Player:CBaseEntity().TeamNum
end

function Helpers_GetPlayerVelocity(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return NULL_VECTOR
	end
	
	local l_PlayerVelocity = l_Player:CBaseEntity().AbsVelocity
	
	return {
		l_PlayerVelocity.x,
		l_PlayerVelocity.y,
		l_PlayerVelocity.z
	}
end

function Helpers_GetPlayerVelocityModifier(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return 0
	end
	
	return l_Player:CCSPlayerPawn().VelocityModifier
end

function Helpers_GetRespawnTime()
	local l_Time = 0
	
	l_Time = l_Time + math.max(convar:Get("spec_freeze_deathanim_time"), 0)
	l_Time = l_Time + math.max(convar:Get("spec_freeze_time"), 0)
	
	return math.floor(l_Time * 1000)
end

function Helpers_GetRoundTime()
	local l_Entity = GetCCSGameRules()
	
	if not l_Entity or not l_Entity:IsValid() then
		return nil
	end
	
	return math.floor(l_Entity.RoundTime * 1000)
end

function Helpers_GetRoundTimeLeft()
	local l_Entity = GetCCSGameRules()
	
	if not l_Entity or not l_Entity:IsValid() then
		return nil
	end
	
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	local l_StartTime = math.floor(l_Entity.RoundStartTime * 1000)
	local l_Time = math.floor(l_Entity.RoundTime * 1000)
	
	return math.max(l_StartTime + l_Time - l_ServerTime, 0)
end

function Helpers_GetTeamChatColor(p_Team)
	return g_TeamChatColors[p_Team]
end

function Helpers_GetTeamFromIdentifier(p_Identifier)
	if type(p_Identifier) ~= "string" then
		return nil
	end
	
	return g_TeamIdentifiers[p_Identifier]
end

function Helpers_GetTeamHintColor(p_Team)
	return g_TeamHintColors[p_Team]
end

function Helpers_GetTeamIdentifier(p_Team)
	if type(p_Team) ~= "number" then
		return nil
	end
	
	return g_TeamIdentifiers[p_Team]
end

function Helpers_GetTeamName(p_Team)
	return g_TeamNames[p_Team]
end

function Helpers_GetTeamPlayerAliveCount(p_Team, p_Nobots)
	local l_PlayerCount = {}
	
	if type(p_Team) == "table" then
		for i = 1, #p_Team do
			l_PlayerCount[p_Team[i]] = 0
		end
	else
		l_PlayerCount[p_Team] = 0
	end
	
	for i = 0, playermanager:GetPlayerCap() - 1 do
		local l_PlayerIter = GetPlayer(i)
		
		if l_PlayerIter and l_PlayerIter:IsValid() and Helpers_IsPlayerAlive(i) then
			local l_PlayerIterTeam = Helpers_GetPlayerTeam(i)
			
			if l_PlayerCount[l_PlayerIterTeam] then
				if not p_Nobots or not l_PlayerIter:IsFakeClient() then
					l_PlayerCount[l_PlayerIterTeam] = l_PlayerCount[l_PlayerIterTeam] + 1
				end
			end
		end
	end
	
	return type(p_Team) == "table" and l_PlayerCount or l_PlayerCount[p_Team]
end

function Helpers_GetTeamPlayerCount(p_Team, p_Nobots)
	local l_PlayerCount = {}
	
	if type(p_Team) == "table" then
		for i = 1, #p_Team do
			l_PlayerCount[p_Team[i]] = 0
		end
	else
		l_PlayerCount[p_Team] = 0
	end
	
	for i = 0, playermanager:GetPlayerCap() - 1 do
		local l_PlayerIter = GetPlayer(i)
		
		if l_PlayerIter and l_PlayerIter:IsValid() then
			local l_PlayerIterTeam = Helpers_GetPlayerTeam(i)
			
			if l_PlayerCount[l_PlayerIterTeam] then
				if not p_Nobots or not l_PlayerIter:IsFakeClient() then
					l_PlayerCount[l_PlayerIterTeam] = l_PlayerCount[l_PlayerIterTeam] + 1
				end
			end
		end
	end
	
	return type(p_Team) == "table" and l_PlayerCount or l_PlayerCount[p_Team]
end

function Helpers_GetTeamScore(p_Team)
	local l_Entities = FindEntitiesByClassname("cs_team_manager")
	
	for i = 1, #l_Entities do
		local l_Entity = CCSTeam(l_Entities[i]:ToPtr())
		
		if l_Entity and l_Entity:IsValid() then
			if l_Entity.Parent.Parent.TeamNum == p_Team then
				return l_Entity.Parent.Score
			end
		end
	end
	
	return 0
end

function Helpers_GetTimeLeft(p_StartTime, p_Time, p_UseServerTime)
	if p_Time == 0 then
		return TIME_INDEFINITE
	end
	
	local l_TimeLeft = p_StartTime + p_Time
	
	if p_UseServerTime then
		local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
		
		l_TimeLeft = l_TimeLeft - l_ServerTime
	else
		local l_CurrentTime = GetTime()
		
		l_TimeLeft = l_TimeLeft - l_CurrentTime
	end
	
	return math.max(l_TimeLeft, 0)
end

function Helpers_GetVectorAngles(p_Point)
	local l_Pitch = 0
	local l_Yaw = 0
	
	if p_Point[1] == 0 and p_Point[2] == 0 then
		if p_Point[3] > 0 then
			l_Pitch = 270
		else
			l_Pitch = 90
		end
	else
		l_Pitch = math.atan(p_Point[3], math.sqrt(p_Point[1] * p_Point[1] + p_Point[2] * p_Point[2])) * 180 / math.pi
		l_Yaw = math.atan(p_Point[2], p_Point[1]) * 180 / math.pi
		
		if l_Pitch < 0 then
			l_Pitch = l_Pitch + 360
		end
		
		if l_Yaw < 0 then
			l_Yaw = l_Yaw + 360
		end
	end
	
	return {
		l_Pitch, l_Yaw, 0
	}
end

function Helpers_GetVectorDistance(p_Point1, p_Point2)
	local l_Difference = {
		p_Point1[1] - p_Point2[1],
		p_Point1[2] - p_Point2[2],
		p_Point1[3] - p_Point2[3]
	}
	
	l_Difference[1] = l_Difference[1] * l_Difference[1]
	l_Difference[2] = l_Difference[2] * l_Difference[2]
	l_Difference[3] = l_Difference[3] * l_Difference[3]
	
	return math.floor(math.sqrt(l_Difference[1] + l_Difference[2] + l_Difference[3]))
end

function Helpers_GivePlayerArmor(p_PlayerId, p_Type, p_Value)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() or not Helpers_IsPlayerAlive(p_PlayerId) then
		return
	end
	
	l_Player:GetWeaponManager():RemoveByClassname("item_heavyassaultsuit")
	l_Player:GetWeaponManager():RemoveByClassname("item_assaultsuit")
	l_Player:GetWeaponManager():RemoveByClassname("item_kevlar")
	
	l_Player:GetWeaponManager():GiveWeapon("item_" .. p_Type)
	
	if p_Value then
		l_Player:CCSPlayerPawn().ArmorValue = p_Value
	end
end

function Helpers_GivePlayerWeapon(p_PlayerId, p_Classname)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() or not Helpers_IsPlayerAlive(p_PlayerId) then
		return
	end
	
	local l_PlayerTeam = Helpers_GetPlayerTeam(p_PlayerId)
	local l_ItemId = Helpers_GetItemIdFromClassname(p_Classname)
	
	if g_TeamItems[l_ItemId] and l_PlayerTeam ~= g_TeamItems[l_ItemId] then
		Helpers_SetPlayerTeam(p_PlayerId, g_TeamItems[l_ItemId])
	end
	
	l_Player:GetWeaponManager():GiveWeapon(p_Classname)
	
	if g_TeamItems[l_ItemId] and l_PlayerTeam ~= g_TeamItems[l_ItemId] then
		Helpers_SetPlayerTeam(p_PlayerId, l_PlayerTeam)
	end
end

function Helpers_IsBoxTouchingBox(p_Origin1, p_Mins1, p_Maxs1, p_Origin2, p_Mins2, p_Maxs2)
	if p_Origin1[1] + p_Maxs1[1] < p_Origin2[1] + p_Mins2[1] 
		or p_Origin1[1] + p_Mins1[1] > p_Origin2[1] + p_Maxs2[1] 
		or p_Origin1[2] + p_Maxs1[2] < p_Origin2[2] + p_Mins2[2] 
		or p_Origin1[2] + p_Mins1[2] > p_Origin2[2] + p_Maxs2[2] 
		or p_Origin1[3] + p_Maxs1[3] < p_Origin2[3] + p_Mins2[3] 
		or p_Origin1[3] + p_Mins1[3] > p_Origin2[3] + p_Maxs2[3] 
	then
		return false
	end
	
	return true
end

function Helpers_IsChatTrigger(p_Str)
	return g_Config["core.commandPrefixes"][p_Str] or g_Config["core.commandSilentPrefixes"][p_Str]
end

function Helpers_IsFreezeTime()
	local l_Entity = GetCCSGameRules()
	
	if not l_Entity or not l_Entity:IsValid() then
		return false
	end
	
	return l_Entity.FreezePeriod
end

function Helpers_IsHalfTime()
	local l_Entity = GetCCSGameRules()
	
	if not l_Entity or not l_Entity:IsValid() then
		return false
	end
	
	return l_Entity.GamePhase == PERIOD_HALFTIME
end

function Helpers_IsItemClassnameKnife(p_Classname)
	if type(p_Classname) ~= "string" then
		return false
	end
	
	if not g_KnifeItems[p_Classname] then
		return false
	end
	
	return true
end

function Helpers_IsItemIdKnife(p_Id)
	if type(p_Id) ~= "number" then
		return false
	end
	
	if not g_KnifeItems[p_Id] then
		return false
	end
	
	return true
end

function Helpers_IsMatchOver()
	local l_Entity = GetCCSGameRules()
	
	if not l_Entity or not l_Entity:IsValid() then
		return false
	end
	
	return l_Entity.GamePhase == PERIOD_MATCH_END
end

function Helpers_IsPlayerAlive(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return false
	end
	
	local l_PlayerLifeState = l_Player:CBaseEntity().LifeState
	
	if l_PlayerLifeState ~= LifeState_t.LIFE_ALIVE then
		return false
	end
	
	return true
end

function Helpers_IsPlayerGod(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return false
	end
	
	return not l_Player:CBaseEntity().TakesDamage
end

function Helpers_IsPlayerInKickQueue(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return false
	end
	
	return l_Player:GetVar("helpers.kick.queue") or false
end

function Helpers_IsPlayerInSlayQueue(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return false
	end
	
	return l_Player:GetVar("helpers.slay.queue") or false
end

function Helpers_IsPlayerTouchingBox(p_PlayerId, p_Origin, p_Mins, p_Maxs)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return false
	end
	
	local l_PlayerMins = Helpers_GetPlayerMins(p_PlayerId)
	local l_PlayerMaxs = Helpers_GetPlayerMaxs(p_PlayerId)
	local l_PlayerOrigin = Helpers_GetPlayerOrigin(p_PlayerId)
	
	if l_PlayerOrigin[1] + l_PlayerMaxs[1] < p_Origin[1] + p_Mins[1] 
		or l_PlayerOrigin[1] + l_PlayerMins[1] > p_Origin[1] + p_Maxs[1] 
		or l_PlayerOrigin[2] + l_PlayerMaxs[2] < p_Origin[2] + p_Mins[2] 
		or l_PlayerOrigin[2] + l_PlayerMins[2] > p_Origin[2] + p_Maxs[2] 
		or l_PlayerOrigin[3] + l_PlayerMaxs[3] < p_Origin[3] + p_Mins[3] 
		or l_PlayerOrigin[3] + l_PlayerMins[3] > p_Origin[3] + p_Maxs[3] 
	then
		return false
	end
	
	return true
end

function Helpers_IsRoundOver()
	local l_Entity = GetCCSGameRules()
	
	if not l_Entity or not l_Entity:IsValid() then
		return false
	end
	
	return l_Entity.RoundWinStatus ~= 0
end

function Helpers_IsStringUTF8(p_Str)
	for l_Key, l_Value in utf8.codes(p_Str) do
		if #utf8.char(l_Value) > 1 then
			return false
		end
	end
	
	return true
end

function Helpers_IsTimeIndefinite(p_Time)
	return p_Time == TIME_INDEFINITE 
end

function Helpers_IsValidColor(p_Color)
	if #p_Color ~= 4 then
		return false
	end
	
	for i = 1, #p_Color do
		local l_Value = tonumber(p_Color[i])
		
		if not l_Value or l_Value < 0 or l_Value > 255 then
			return false
		end
	end
	
	return true
end

function Helpers_IsValidSteam(p_Steam)
	local l_Steam = tonumber(p_Steam)
	
	if not l_Steam or l_Steam < 1 then
		return false
	end
	
	return true
end

function Helpers_IsValidVector(p_Vector)
	if #p_Vector ~= 3 then
		return false
	end
	
	for i = 1, #p_Vector do
		local l_Value = tonumber(p_Vector[i])
		
		if not l_Value then
			return false
		end
	end
	
	return true
end

function Helpers_IsWarmupPeriod()
	local l_Entity = GetCCSGameRules()
	
	if not l_Entity or not l_Entity:IsValid() then
		return false
	end
	
	return l_Entity.WarmupPeriod
end

function Helpers_KickPlayer(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	l_Player:SetVar("helpers.kick.queue", true)
	
	SetTimeout(100, function()
		if not l_Player:IsValid() then
			return
		end
		
		l_Player:Drop(DisconnectReason.Kicked)
	end)
end

function Helpers_LoadCoreConfig()
	local l_Config = json.decode(files:Read("addons/swiftly/configs/core.json"))
	
	g_Config = {}
	g_Config["core.commandPrefixes"] = {}
	g_Config["core.commandSilentPrefixes"] = {}
	
	if type(l_Config) ~= "table" then
		l_Config = {}
	end
	
	if type(l_Config["commandPrefixes"]) ~= "table" then
		l_Config["commandPrefixes"] = {}
	end
	
	if type(l_Config["commandSilentPrefixes"]) ~= "table" then
		l_Config["commandSilentPrefixes"] = {}
	end
	
	for i = 1, #l_Config["commandPrefixes"] do
		local l_Prefix = l_Config["commandPrefixes"][i]
		
		if type(l_Prefix) ~= "string" or #l_Prefix == 0 then
			l_Prefix = nil
		end
		
		if l_Prefix then
			g_Config["core.commandPrefixes"][l_Prefix] = true
		end
	end
	
	for i = 1, #l_Config["commandSilentPrefixes"] do
		local l_Prefix = l_Config["commandSilentPrefixes"][i]
		
		if type(l_Prefix) ~= "string" or #l_Prefix == 0 then
			l_Prefix = nil
		end
		
		if l_Prefix then
			g_Config["core.commandSilentPrefixes"][l_Prefix] = true
		end
	end
end

function Helpers_ParseGameConfig(p_Path)
	local l_Config = {}
	
	if not files:ExistsPath(p_Path) then
		return l_Config
	end
	
	local l_Content = string.split(files:Read(p_Path), "\n")
	
	for i = 1, #l_Content do
		local l_InQuote = nil
		local l_InValue = nil
		
		local l_Cvar = nil
		local l_Value = nil
		
		for j = 1, #l_Content[i] do
			local l_Char = string.sub(l_Content[i], j, j)
			
			if l_Char == "/" 
				and string.sub(l_Content[i], j + 1, j + 1) == "/" 
				and not l_InQuote 
			then
				break
			end
			
			if (l_Char == " " or l_Char == "\t") and not l_InQuote then
				l_InValue = true
			else
				if l_Char == "\"" then
					l_InQuote = not l_InQuote
				elseif l_InValue then
					if not l_Value then
						l_Value = ""
					end
					
					l_Value = l_Value .. l_Char
				else
					if not l_Cvar then
						l_Cvar = ""
					end
					
					l_Cvar = l_Cvar .. l_Char
				end
			end
		end
		
		if l_Cvar and l_Value and not l_InQuote then
			l_Config[l_Cvar] = l_Value
		end
	end
	
	return l_Config
end

function Helpers_PrintTableToConsole(p_PlayerId, p_Tag, p_Header, p_Body)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	local l_Buffer = ""
	local l_Length = {}
	
	for i = 1, #p_Header do
		p_Header[i] = tostring(p_Header[i])
		
		table.insert(l_Length, #p_Header[i])
	end
	
	for i = 1, #p_Body do
		for j = 1, #p_Body[i] do
			p_Body[i][j] = tostring(p_Body[i][j])
			
			if #p_Body[i][j] > l_Length[j] then
				l_Length[j] = #p_Body[i][j]
			end
		end
	end
	
	for i = 1, #p_Header do
		l_Buffer = l_Buffer .. string.format("%s%s%s", p_Header[i], string.rep(" ", l_Length[i] - #p_Header[i]), p_Header[i] == "#" and " " or "   ")
	end
	
	l_Player:SendMsg(MessageType.Console, string.format("%s %s\n", p_Tag, l_Buffer))
	
	for i = 1, #p_Body do
		l_Buffer = ""
		
		for j = 1, #p_Body[i] do
			l_Buffer = l_Buffer .. string.format("%s%s%s", p_Body[i][j], string.rep(" ", l_Length[j] - #p_Body[i][j]), p_Header[j] == "#" and " " or "   ")
		end
		
		l_Player:SendMsg(MessageType.Console, string.format("%s %s\n", p_Tag, l_Buffer))
	end
end

function Helpers_RefillPlayerAmmo(p_PlayerId, p_Weapon)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() or not Helpers_IsPlayerAlive(p_PlayerId) then
		return
	end
	
	local l_PlayerWeapons = l_Player:GetWeaponManager():GetWeapons()
	
	for i = 1, #l_PlayerWeapons do
		local l_Entity = l_PlayerWeapons[i]:CBasePlayerWeapon()
		local l_EntityData = l_PlayerWeapons[i]:CCSWeaponBaseVData()
		
		l_Entity.ReserveAmmo = {
			l_EntityData.PrimaryReserveAmmoMax,
			l_Entity.ReserveAmmo[1]
		}
	end
end

function Helpers_RemovePlayerArmor(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() or not Helpers_IsPlayerAlive(p_PlayerId) then
		return
	end
	
	l_Player:GetWeaponManager():RemoveByClassname("item_heavyassaultsuit")
	l_Player:GetWeaponManager():RemoveByClassname("item_assaultsuit")
	l_Player:GetWeaponManager():RemoveByClassname("item_kevlar")
end

function Helpers_RemovePlayerChatTag(p_PlayerId, p_Tag)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerTags = l_Player:GetVar("helpers.chat.tags")
	
	if not l_PlayerTags then
		return
	end
	
	local l_Index = table.find(l_PlayerTags, p_Tag)
	
	if not l_Index then
		return
	end
	
	local l_EventReturn, l_Event = TriggerEvent("Helpers_OnPlayerRemoveChatTag", p_PlayerId, l_PlayerTags[i])
	
	if l_EventReturn == EventResult.Handled or l_EventReturn == EventResult.Stop then
		return
	end
	
	table.remove(l_PlayerTags, l_Index)
	
	if #l_PlayerTags == 0 then
		l_PlayerTags = nil
	end
	
	local l_Tag = ""
	
	if l_PlayerTags then
		l_Tag = "[" .. table.concat(l_PlayerTags, ", ") .. "]"
	end
	
	l_Player:SetChatTag(l_Tag)
	
	l_Player:SetVar("helpers.chat.tags", l_PlayerTags)
end

function Helpers_RemovePlayerChatTags(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerTags = l_Player:GetVar("helpers.chat.tags")
	
	if not l_PlayerTags then
		return
	end
	
	for i = #l_PlayerTags, 1, -1 do
		local l_EventReturn, l_Event = TriggerEvent("Helpers_OnPlayerRemoveChatTag", p_PlayerId, l_PlayerTags[i])
		
		if l_EventReturn ~= EventResult.Handled and l_EventReturn ~= EventResult.Stop then
			table.remove(l_PlayerTags, i)
		end
	end
	
	if #l_PlayerTags == 0 then
		l_PlayerTags = nil
	end
	
	local l_Tag = ""
	
	if l_PlayerTags then
		l_Tag = "[" .. table.concat(l_PlayerTags, ", ") .. "]"
	end
	
	l_Player:SetChatTag(l_Tag)
	
	l_Player:SetVar("helpers.chat.tags", l_PlayerTags)
end

function Helpers_RemovePlayerClanTag(p_PlayerId, p_Tag)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerTags = l_Player:GetVar("helpers.clan.tags")
	
	if not l_PlayerTags then
		return
	end
	
	local l_Index = table.find(l_PlayerTags, p_Tag)
	
	if not l_Index then
		return
	end
	
	local l_EventReturn, l_Event = TriggerEvent("Helpers_OnPlayerRemoveClanTag", p_PlayerId, l_PlayerTags[i])
	
	if l_EventReturn == EventResult.Handled or l_EventReturn == EventResult.Stop then
		return
	end
	
	table.remove(l_PlayerTags, l_Index)
	
	if #l_PlayerTags == 0 then
		l_PlayerTags = nil
	end
	
	local l_Tag = ""
	
	if l_PlayerTags then
		l_Tag = "[" .. table.concat(l_PlayerTags, ", ") .. "]"
	end
	
	l_Player:CCSPlayerController().Clan = l_Tag
	
	Event("OnNextlevelChanged"):FireEventToClient(p_PlayerId)
	
	l_Player:SetVar("helpers.clan.tags", l_PlayerTags)
end

function Helpers_RemovePlayerClanTags(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerTags = l_Player:GetVar("helpers.clan.tags")
	
	if not l_PlayerTags then
		return
	end
	
	for i = #l_PlayerTags, 1, -1 do
		local l_EventReturn, l_Event = TriggerEvent("Helpers_OnPlayerRemoveClanTag", p_PlayerId, l_PlayerTags[i])
		
		if l_EventReturn ~= EventResult.Handled and l_EventReturn ~= EventResult.Stop then
			table.remove(l_PlayerTags, i)
		end
	end
	
	if #l_PlayerTags == 0 then
		l_PlayerTags = nil
	end
	
	local l_Tag = ""
	
	if l_PlayerTags then
		l_Tag = "[" .. table.concat(l_PlayerTags, ", ") .. "]"
	end
	
	l_Player:CCSPlayerController().Clan = l_Tag
	
	Event("OnNextlevelChanged"):FireEventToClient(p_PlayerId)
	
	l_Player:SetVar("helpers.clan.tags", l_PlayerTags)
end

function Helpers_RemovePlayerGod(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	l_Player:CBaseEntity().TakesDamage = false
end

function Helpers_ReplyToCommand(p_PlayerId, p_Tag, p_Message)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_ConsoleTag = Helpers_StringReplace(p_Tag, g_ChatColors, "")
	local l_ConsoleMessage = Helpers_StringReplace(p_Message, g_ChatColors, "\"")
	
	l_ConsoleMessage = Helpers_StringReplace(l_ConsoleMessage, "\"\"\"\"", "\"\"")
	
	l_Player:SendMsg(MessageType.Console, string.format("%s %s\n", l_ConsoleTag, l_ConsoleMessage))
	l_Player:SendMsg(MessageType.Chat, string.format("%s %s", p_Tag, p_Message))
end

function Helpers_ResetPlayerVars(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	l_Player:SetVar("helpers.chat.tags", nil)
	l_Player:SetVar("helpers.clan.tags", nil)
	l_Player:SetVar("helpers.kick.queue", nil)
	l_Player:SetVar("helpers.name", nil)
	l_Player:SetVar("helpers.slay.queue", nil)
end

function Helpers_ResetVars()
	g_TerminateIdentifier = nil
end

function Helpers_RestorePlayerName(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerName = l_Player:GetVar("helpers.name")
	
	if not l_PlayerName then
		return
	end
	
	l_Player:CBasePlayerController().PlayerName = l_PlayerName
end

function Helpers_SetConVar(p_Name, p_Value)
	local l_Flags = convar:GetFlags(p_Name)
	
	if l_Flags & (ConvarFlags.FCVAR_CHEAT) ~= 0 then
		convar:RemoveFlags(p_Name, ConvarFlags.FCVAR_CHEAT)
		convar:Set(p_Name, p_Value)
		
		SetTimeout(100, function()
			convar:AddFlags(p_Name, ConvarFlags.FCVAR_CHEAT)
		end)
	else
		convar:Set(p_Name, p_Value)
	end
end

function Helpers_SetEntityRenderColor(p_EntityPtr, p_Color)
	local l_Entity = CBaseModelEntity(p_EntityPtr)
	
	if not l_Entity or not l_Entity:IsValid() then
		return
	end
	
	l_Entity.Render = Color(p_Color[1], p_Color[2], p_Color[3], p_Color[4])
end

function Helpers_SetPlayerAssists(p_PlayerId, p_Assists)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	l_Player:CCSPlayerController().ActionTrackingServices.MatchStats.Parent.Assists = p_Assists
end

function Helpers_SetPlayerChatTag(p_PlayerId, p_Tag)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerTags = l_Player:GetVar("helpers.chat.tags") or {}
	
	if table.contains(l_PlayerTags, p_Tag) then
		return
	end
	
	table.insert(l_PlayerTags, p_Tag)
	table.sort(l_PlayerTags)
	
	l_Player:SetChatTag("[" .. table.concat(l_PlayerTags, ", ") .. "] ")
	
	l_Player:SetVar("helpers.chat.tags", l_PlayerTags)
end

function Helpers_SetPlayerClanTag(p_PlayerId, p_Tag)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerTags = l_Player:GetVar("helpers.clan.tags") or {}
	
	if table.contains(l_PlayerTags, p_Tag) then
		return
	end
	
	table.insert(l_PlayerTags, p_Tag)
	table.sort(l_PlayerTags)
	
	l_Player:CCSPlayerController().Clan = "[" .. table.concat(l_PlayerTags, ", ") .. "]"
	
	Event("OnNextlevelChanged"):FireEventToClient(p_PlayerId)
	
	l_Player:SetVar("helpers.clan.tags", l_PlayerTags)
end

function Helpers_SetPlayerCollisionGroup(p_PlayerId, p_Group)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() or not Helpers_IsPlayerAlive(p_PlayerId) then
		return
	end
	
	l_Player:CBaseEntity().Collision.CollisionGroup = p_Group
	l_Player:CBaseEntity().Collision.CollisionAttribute.CollisionGroup = p_Group
	
	l_Player:CBaseEntity():CollisionRulesChanged()
end

function Helpers_SetPlayerConVar(p_PlayerId, p_Name, p_Value)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_Flags = convar:GetFlags(p_Name)
	
	if l_Flags & (ConvarFlags.FCVAR_CHEAT) ~= 0 then
		convar:RemoveFlags(p_Name, ConvarFlags.FCVAR_CHEAT)
		
		l_Player:SetConvar(p_Name, p_Value)
		
		SetTimeout(100, function()
			convar:AddFlags(p_Name, ConvarFlags.FCVAR_CHEAT)
		end)
	else
		l_Player:SetConvar(p_Name, p_Value)
	end
end

function Helpers_SetPlayerDamage(p_PlayerId, p_Damage)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	l_Player:CCSPlayerController().ActionTrackingServices.MatchStats.Parent.Damage = p_Damage
end

function Helpers_SetPlayerDeaths(p_PlayerId, p_Deaths)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	l_Player:CCSPlayerController().ActionTrackingServices.MatchStats.Parent.Deaths = p_Deaths
end

function Helpers_SetPlayerEntityName(p_PlayerId, p_Name)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	l_Player:CBaseEntity().Parent.Entity.Name = p_Name
end

function Helpers_SetPlayerGod(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	l_Player:CBaseEntity().TakesDamage = true
end

function Helpers_SetPlayerHealth(p_PlayerId, p_Health)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() or not Helpers_IsPlayerAlive(p_PlayerId) then
		return
	end
	
	l_Player:CBaseEntity().Health = p_Health
end

function Helpers_SetPlayerKills(p_PlayerId, p_Kills)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	l_Player:CCSPlayerController().ActionTrackingServices.MatchStats.Parent.Kills = p_Kills
end

function Helpers_SetPlayerMVPs(p_PlayerId, p_MVPs)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	l_Player:CCSPlayerController().MVPs = p_MVPs
end

function Helpers_SetPlayerScore(p_PlayerId, p_Score)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	l_Player:CCSPlayerController().Score = p_Score
end

function Helpers_SetPlayerTeam(p_PlayerId, p_Team)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	l_Player:CBaseEntity().TeamNum = p_Team
end

function Helpers_SetPlayerVelocity(p_PlayerId, p_Velocity)
	local l_Player = GetPlayer(p_PlayerId, p_Velocity)
	
	if not l_Player or not l_Player:IsValid() or not Helpers_IsPlayerAlive(p_PlayerId) then
		return
	end
	
	l_Player:CBaseEntity().AbsVelocity = Vector(p_Velocity[1], p_Velocity[2], p_Velocity[3])
end

function Helpers_SetPlayerVelocityModifier(p_PlayerId, p_Modifier)
	local l_Player = GetPlayer(p_PlayerId, p_Velocity)
	
	if not l_Player or not l_Player:IsValid() or not Helpers_IsPlayerAlive(p_PlayerId) then
		return
	end
	
	l_Player:CCSPlayerPawn().VelocityModifier = p_Modifier
end

function Helpers_SetRoundTime(p_Time)
	local l_Entity = GetCCSGameRules()
	
	if not l_Entity or not l_Entity:IsValid() then
		return
	end
	
	local l_TimeLeft = Helpers_GetRoundTimeLeft()
	
	if l_TimeLeft == p_Time then
		return
	end
	
	l_Entity.RoundTime = math.floor((p_Time + Helpers_GetRoundTime() - l_TimeLeft) / 1000)
end

function Helpers_SetTeamScore(p_Team, p_Score)
	local l_Entities = FindEntitiesByClassname("cs_team_manager")
	
	for i = 1, #l_Entities do
		local l_Entity = CCSTeam(l_Entities[i]:ToPtr())
		
		if l_Entity and l_Entity:IsValid() then
			if l_Entity.Parent.Parent.TeamNum == p_Team then
				l_Entity.Parent.Score = p_Score
				break
			end
		end
	end
end

function Helpers_ShowActivity(p_PlayerId, p_Tag, p_Message)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	local l_PlayerName = Helpers_GetPlayerName(p_PlayerId)
	local l_PlayerColor = Helpers_GetPlayerChatColor(p_PlayerId)
	
	local l_SpectatorColor = Helpers_GetTeamChatColor(Team.Spectator)
	
	for i = 0, playermanager:GetPlayerCap() - 1 do
		if i ~= p_PlayerId then
			local l_PlayerIter = GetPlayer(i)
			
			if l_PlayerIter and l_PlayerIter:IsValid() then
				if exports["admin"]:HasPlayerGroups(i) then
					l_PlayerIter:SendMsg(MessageType.Chat, string.format("%s %s%s:{default} %s", p_Tag, l_PlayerColor, l_PlayerName, p_Message))
				else
					l_PlayerIter:SendMsg(MessageType.Chat, string.format("%s %sADMIN:{default} %s", p_Tag, l_SpectatorColor, p_Message))
				end
			end
		end
	end
	
	Helpers_ReplyToCommand(p_PlayerId, p_Tag, string.format("%s%s:{default} %s", l_PlayerColor, l_PlayerName, p_Message))
end

function Helpers_ShowActivity2(p_Identity, p_Tag, p_Message)
	local l_NoneColor = Helpers_GetTeamChatColor(Team.None)
	
	for i = 0, playermanager:GetPlayerCap() - 1 do
		local l_PlayerIter = GetPlayer(i)
		
		if l_PlayerIter and l_PlayerIter:IsValid() then
			if exports["admin"]:HasPlayerGroups(i) then
				l_PlayerIter:SendMsg(MessageType.Chat, string.format("%s %s%s:{default} %s", p_Tag, l_NoneColor, p_Identity, p_Message))
			else
				l_PlayerIter:SendMsg(MessageType.Chat, string.format("%s %sADMIN:{default} %s", p_Tag, l_NoneColor, p_Message))
			end
		end
	end
end

function Helpers_ShuffleTable(p_Table)
	for i = #p_Table, 2, -1 do
		local l_Index = math.random(i)
		
		p_Table[i], p_Table[l_Index] = p_Table[l_Index], p_Table[i]
	end
	
	return p_Table
end

function Helpers_SlapPlayer(p_PlayerId, p_Damage)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() or not Helpers_IsPlayerAlive(p_PlayerId) then
		return
	end
	
	local l_PlayerHealth = Helpers_GetPlayerHealth(p_PlayerId)
	
	if l_PlayerHealth - p_Damage > 0 then
		local l_PlayerVelocity = Helpers_GetPlayerVelocity(p_PlayerId)
		
		l_PlayerVelocity[1] = l_PlayerVelocity[1] + math.random(50, 230) * (math.random(0, 1) == 1 and -1 or 1)
		l_PlayerVelocity[2] = l_PlayerVelocity[2] + math.random(50, 230) * (math.random(0, 1) == 1 and -1 or 1)
		l_PlayerVelocity[3] = l_PlayerVelocity[3] + math.random(100, 299)
		
		Helpers_SetPlayerHealth(p_PlayerId, l_PlayerHealth - p_Damage)
		Helpers_SetPlayerVelocity(p_PlayerId, l_PlayerVelocity)
	else
		Helpers_SlayPlayer(p_PlayerId)
	end
end

function Helpers_SlayPlayer(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() or not Helpers_IsPlayerAlive(p_PlayerId) then
		return
	end
	
	local l_Entity = CreateEntityByName("point_hurt")
	
	if not l_Entity or not l_Entity:IsValid() then
		return
	end
	
	l_Entity = CPointHurt(l_Entity:ToPtr())
	
	if not l_Entity or not l_Entity:IsValid() then
		return
	end
	
	local l_PlayerEntityName = Helpers_GetPlayerEntityName(p_PlayerId)
	local l_PlayerHealth = Helpers_GetPlayerHealth(p_PlayerId)
	
	l_Player:SetVar("helpers.slay.queue", true)
	
	Helpers_SetPlayerEntityName(p_PlayerId, "helpers_player_slay")
	
	Helpers_RemovePlayerArmor(p_PlayerId)
	Helpers_RemovePlayerGod(p_PlayerId)
	
	l_Entity.Damage = l_PlayerHealth
	l_Entity.StrTarget = "helpers_player_slay"
	
	l_Entity.Parent.Parent:Spawn()
	l_Entity.Parent.Parent:AcceptInput("Hurt", l_Player:CBaseEntity().Parent, l_Entity.Parent.Parent.Parent, "", 0)
	l_Entity.Parent.Parent:Despawn()
	
	Helpers_SetPlayerEntityName(p_PlayerId, l_PlayerEntityName)
	
	l_Player:SetVar("helpers.slay.queue", nil)
end

function Helpers_StorePlayerName(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerName = l_Player:CBasePlayerController().PlayerName
	
	l_Player:SetVar("helpers.name", l_PlayerName)
end

function Helpers_StringReplace(p_Str, p_Find, p_Replace)
	if type(p_Find) ~= "table" then
		p_Find = {
			p_Find
		}
	end
	
	if type(p_Replace) ~= "table" then
		p_Replace = {
			p_Replace
		}
		
		for i = 2, #p_Find do
			table.insert(p_Replace, p_Replace[1])
		end
	end
	
	local l_Index = 1
	local l_Buffer = ""
	
	while l_Index <= #p_Str do
		local l_Match = nil
		
		for i = 1, #p_Find do
			if string.lower(string.sub(p_Str, l_Index, l_Index + #p_Find[i] - 1)) == string.lower(p_Find[i]) then
				l_Match = true
				
				l_Buffer = l_Buffer .. p_Replace[i]
				l_Index = l_Index + #p_Find[i]
				
				break
			end
		end
		
		if not l_Match then
			l_Buffer = l_Buffer .. string.sub(p_Str, l_Index, l_Index)
			l_Index = l_Index + 1
		end
	end
	
	return l_Buffer
end

function Helpers_TeleportPlayer(p_PlayerId, p_Origin, p_Rotation, p_Velocity)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() or not Helpers_IsPlayerAlive(p_PlayerId) then
		return
	end
	
	local l_Origin = nil
	local l_Rotation = nil
	local l_Velocity = nil
	
	if p_Origin then
		l_Origin = Vector(p_Origin[1], p_Origin[2], p_Origin[3])
	end
	
	if p_Rotation then
		l_Rotation = QAngle(p_Rotation[1], p_Rotation[2], p_Rotation[3])
	end
	
	if p_Velocity then
		l_Velocity = Vector(p_Velocity[1], p_Velocity[2], p_Velocity[3])
	end
	
	l_Player:CBaseEntity():Teleport(l_Origin, l_Rotation, l_Velocity)
end

function Helpers_TerminateRound(p_Reason, p_Identifier)
	if Helpers_IsWarmupPeriod() or Helpers_IsRoundOver() or Helpers_IsMatchOver() then
		return
	end
	
	local l_Delay = math.max(convar:Get("mp_round_restart_delay"), 0)
	
	g_TerminateIdentifier = p_Identifier
	
	server:TerminateRound(l_Delay, p_Reason)
end