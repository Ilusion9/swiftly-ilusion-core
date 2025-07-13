export("ChangePlayerName", function(p_PlayerId, p_Name)
	Helpers_ChangePlayerName(p_PlayerId, p_Name)
end)

export("ChangePlayerTeam", function(p_PlayerId, p_Team)
	Helpers_ChangePlayerTeam(p_PlayerId, p_Team)
end)

export("CreateBeamEntity", function(p_Point1, p_Point2, p_Name, p_Color)
	Helpers_CreateBeamEntity(p_Point1, p_Point2, p_Name, p_Color)
end)

export("EmitSoundToAll", function(p_Sound, p_Pitch, p_Volume)
	Helpers_EmitSoundToAll(p_Sound, p_Pitch, p_Volume)
end)

export("EmitSoundToPlayer", function(p_PlayerId, p_Sound, p_Pitch, p_Volume)
	Helpers_EmitSoundToPlayer(p_PlayerId, p_Sound, p_Pitch, p_Volume)
end)

export("EncodeString", function(p_Str)
	return Helpers_EncodeString(p_Str)
end)

export("ExecuteCommandToAll", function(p_Command)
	Helpers_ExecuteCommandToAll(p_Command)
end)

export("FindPlayerBySteam", function(p_Steam)
	return Helpers_FindPlayerBySteam(p_Steam)
end)

export("FindTarget", function(p_PlayerId, p_Arg, p_Flags, p_Tag)
	return Helpers_FindTarget(p_PlayerId, p_Arg, p_Flags, p_Tag)
end)

export("FormatDate", function(p_Time)
	return Helpers_FormatDate(p_Time)
end)

export("FormatTime", function(p_Time)
	return Helpers_FormatTime(p_Time)
end)

export("GetArgTime", function(p_Arg)
	return Helpers_GetArgTime(p_Arg)
end)

export("GetBots", function()
	return Helpers_GetBots()
end)

export("GetBotCount", function()
	return Helpers_GetBotCount()
end)

export("GetBoxEdgesFromPoints", function(p_Point1, p_Point2)
	return Helpers_GetBoxEdgesFromPoints(p_Point1, p_Point2)
end)

export("GetBoxFromPoints", function(p_Point1, p_Point2)
	return Helpers_GetBoxFromPoints(p_Point1, p_Point2)
end)

export("GetItemIdClassname", function(p_Id)
	return Helpers_GetItemIdClassname(p_Id)
end)

export("GetItemIdFromClassname", function(p_Classname)
	return Helpers_GetItemIdFromClassname(p_Classname)
end)

export("GetMapTimeLeft", function()
	return Helpers_GetMapTimeLeft()
end)

export("GetPlayerActiveWeapon", function(p_PlayerId)
	return Helpers_GetPlayerActiveWeapon(p_PlayerId)
end)

export("GetPlayerArmorType", function(p_PlayerId)
	return Helpers_GetPlayerArmorType(p_PlayerId)
end)

export("GetPlayerArmorValue", function(p_PlayerId)
	return Helpers_GetPlayerArmorValue(p_PlayerId)
end)

export("GetPlayerAssists", function(p_PlayerId)
	return Helpers_GetPlayerAssists(p_PlayerId)
end)

export("GetPlayerChatColor", function(p_PlayerId)
	return Helpers_GetPlayerChatColor(p_PlayerId)
end)

export("GetPlayerChatTags", function(p_PlayerId)
	return Helpers_GetPlayerChatTags(p_PlayerId)
end)

export("GetPlayerClanTags", function(p_PlayerId)
	return Helpers_GetPlayerClanTags(p_PlayerId)
end)

export("GetPlayerCount", function(p_Nobots)
	return Helpers_GetPlayerCount(p_Nobots)
end)

export("GetPlayerDamage", function(p_PlayerId)
	return Helpers_GetPlayerDamage(p_PlayerId)
end)

export("GetPlayerDeaths", function(p_PlayerId)
	return Helpers_GetPlayerDeaths(p_PlayerId)
end)

export("GetPlayerEntityName", function(p_PlayerId)
	return Helpers_GetPlayerEntityName(p_PlayerId)
end)

export("GetPlayerHealth", function(p_PlayerId)
	return Helpers_GetPlayerHealth(p_PlayerId)
end)

export("GetPlayerHintColor", function(p_PlayerId)
	return Helpers_GetPlayerHintColor(p_PlayerId)
end)

export("GetPlayerKills", function(p_PlayerId)
	return Helpers_GetPlayerKills(p_PlayerId)
end)

export("GetPlayerMaxs", function(p_PlayerId)
	return Helpers_GetPlayerMaxs(p_PlayerId)
end)

export("GetPlayerMins", function(p_PlayerId)
	return Helpers_GetPlayerMins(p_PlayerId)
end)

export("GetPlayerMVPs", function(p_PlayerId)
	return Helpers_GetPlayerMVPs(p_PlayerId)
end)

export("GetPlayerName", function(p_PlayerId)
	return Helpers_GetPlayerName(p_PlayerId)
end)

export("GetPlayerNextAttackTime", function(p_PlayerId)
	return Helpers_GetPlayerNextAttackTime(p_PlayerId)
end)

export("GetPlayerOrigin", function(p_PlayerId)
	return Helpers_GetPlayerOrigin(p_PlayerId)
end)

export("GetPlayerRotation", function(p_PlayerId)
	return Helpers_GetPlayerRotation(p_PlayerId)
end)

export("GetPlayerScore", function(p_PlayerId)
	return Helpers_GetPlayerScore(p_PlayerId)
end)

export("GetPlayerSpeed", function(p_PlayerId)
	return Helpers_GetPlayerSpeed(p_PlayerId)
end)

export("GetPlayerSteam", function(p_PlayerId)
	return Helpers_GetPlayerSteam(p_PlayerId)
end)

export("GetPlayerTeam", function(p_PlayerId)
	return Helpers_GetPlayerTeam(p_PlayerId)
end)

export("GetPlayerVelocity", function(p_PlayerId)
	return Helpers_GetPlayerVelocity(p_PlayerId)
end)

export("GetPlayerVelocityModifier", function(p_PlayerId)
	return Helpers_GetPlayerVelocityModifier(p_PlayerId)
end)

export("GetRespawnTime", function()
	return Helpers_GetRespawnTime()
end)

export("GetRoundTime", function()
	return Helpers_GetRoundTime()
end)

export("GetRoundTimeLeft", function()
	return Helpers_GetRoundTimeLeft()
end)

export("GetTeamAliveBots", function(p_Team)
	return Helpers_GetTeamAliveBots(p_Team)
end)

export("GetTeamAlivePlayers", function(p_Team, p_Nobots)
	return Helpers_GetTeamAlivePlayers(p_Team, p_Nobots)
end)

export("GetTeamBots", function(p_Team)
	return Helpers_GetTeamBots(p_Team)
end)

export("GetTeamBotAliveCount", function(p_Team)
	return Helpers_GetTeamBotAliveCount(p_Team)
end)

export("GetTeamBotCount", function(p_Team)
	return Helpers_GetTeamBotCount(p_Team)
end)

export("GetTeamChatColor", function(p_Team)
	return Helpers_GetTeamChatColor(p_Team)
end)

export("GetTeamFromIdentifier", function(p_Identifier)
	return Helpers_GetTeamFromIdentifier(p_Identifier)
end)

export("GetTeamHintColor", function(p_Team)
	return Helpers_GetTeamHintColor(p_Team)
end)

export("GetTeamIdentifier", function(p_Team)
	return Helpers_GetTeamIdentifier(p_Team)
end)

export("GetTeamName", function(p_Team)
	return Helpers_GetTeamName(p_Team)
end)

export("GetTeamPlayers", function(p_Team, p_Nobots)
	return Helpers_GetTeamPlayers(p_Team, p_Nobots)
end)

export("GetTeamPlayerAliveCount", function(p_Team, p_Nobots)
	return Helpers_GetTeamPlayerAliveCount(p_Team, p_Nobots)
end)

export("GetTeamPlayerCount", function(p_Team, p_Nobots)
	return Helpers_GetTeamPlayerCount(p_Team, p_Nobots)
end)

export("GetTeamScore", function(p_Team)
	return Helpers_GetTeamScore(p_Team)
end)

export("GetTimeLeft", function(p_StartTime, p_Time, p_UseServerTime)
	return Helpers_GetTimeLeft(p_StartTime, p_Time, p_UseServerTime)
end)

export("GetVectorAngles", function(p_Point)
	return Helpers_GetVectorAngles(p_Point)
end)

export("GetVectorDistance", function(p_Point1, p_Point2)
	return Helpers_GetVectorDistance(p_Point1, p_Point2)
end)

export("GivePlayerArmor", function(p_PlayerId, p_Type, p_Value)
	Helpers_GivePlayerArmor(p_PlayerId, p_Type, p_Value)
end)

export("GivePlayerWeapon", function(p_PlayerId, p_Classname)
	Helpers_GivePlayerWeapon(p_PlayerId, p_Classname)
end)

export("HasPlayerImmunity", function(p_PlayerId)
	return Helpers_HasPlayerImmunity(p_PlayerId)
end)

export("IsBoxTouchingBox", function(p_Origin1, p_Mins1, p_Maxs1, p_Origin2, p_Mins2, p_Maxs2)
	return Helpers_IsBoxTouchingBox(p_Origin1, p_Mins1, p_Maxs1, p_Origin2, p_Mins2, p_Maxs2)
end)

export("IsChatTrigger", function(p_Str)
	return Helpers_IsChatTrigger(p_Str)
end)

export("IsFreezeTime", function()
	return Helpers_IsFreezeTime()
end)

export("IsHalfTime", function()
	return Helpers_IsHalfTime()
end)

export("IsItemClassnameKnife", function(p_Classname)
	return Helpers_IsItemClassnameKnife(p_Classname)
end)

export("IsItemIdKnife", function(p_Id)
	return Helpers_IsItemIdKnife(p_Id)
end)

export("IsMatchOver", function()
	return Helpers_IsMatchOver()
end)

export("IsPlayerAlive", function(p_PlayerId)
	return Helpers_IsPlayerAlive(p_PlayerId)
end)

export("IsPlayerInKickQueue", function(p_PlayerId)
	return Helpers_IsPlayerInKickQueue(p_PlayerId)
end)

export("IsPlayerInSlayQueue", function(p_PlayerId)
	return Helpers_IsPlayerInSlayQueue(p_PlayerId)
end)

export("IsPlayerTouchingBox", function(p_PlayerId, p_Origin, p_Mins, p_Maxs)
	return Helpers_IsPlayerTouchingBox(p_PlayerId, p_Origin, p_Mins, p_Maxs)
end)

export("IsRoundOver", function()
	return Helpers_IsRoundOver()
end)

export("IsStringUTF8", function(p_Str)
	return Helpers_IsStringUTF8(p_Str)
end)

export("IsTimeIndefinite", function(p_Time)
	return Helpers_IsTimeIndefinite(p_Time)
end)

export("IsValidColor", function(p_Vector)
	return Helpers_IsValidColor(p_Vector)
end)

export("IsValidSteam", function(p_Steam)
	return Helpers_IsValidSteam(p_Steam)
end)

export("IsValidVector", function(p_Vector)
	return Helpers_IsValidVector(p_Vector)
end)

export("IsWarmupPeriod", function()
	return Helpers_IsWarmupPeriod()
end)

export("KickPlayer", function(p_PlayerId)
	Helpers_KickPlayer(p_PlayerId)
end)

export("ParseGameConfig", function(p_Path)
	return Helpers_ParseGameConfig(p_Path)
end)

export("PrintTableToConsole", function(p_PlayerId, p_Tag, p_Header, p_Body)
	Helpers_PrintTableToConsole(p_PlayerId, p_Tag, p_Header, p_Body)
end)

export("RefillPlayerAmmo", function(p_PlayerId)
	Helpers_RefillPlayerAmmo(p_PlayerId)
end)

export("RemovePlayerArmor", function(p_PlayerId)
	Helpers_RemovePlayerArmor(p_PlayerId)
end)

export("RemovePlayerChatTag", function(p_PlayerId, p_Tag)
	Helpers_RemovePlayerChatTag(p_PlayerId, p_Tag)
end)

export("RemovePlayerClanTag", function(p_PlayerId, p_Tag)
	Helpers_RemovePlayerClanTag(p_PlayerId, p_Tag)
end)

export("RemovePlayerImmunity", function(p_PlayerId)
	Helpers_RemovePlayerImmunity(p_PlayerId)
end)

export("ReplyToCommand", function(p_PlayerId, p_Tag, p_Message)
	Helpers_ReplyToCommand(p_PlayerId, p_Tag, p_Message)
end)

export("RestorePlayerName", function(p_PlayerId)
	Helpers_RestorePlayerName(p_PlayerId)
end)

export("SetConVar", function(p_Name, p_Value)
	Helpers_SetConVar(p_Name, p_Value)
end)

export("SetEntityRenderColor", function(p_EntityPtr, p_Color)
	Helpers_SetEntityRenderColor(p_EntityPtr, p_Color)
end)

export("SetPlayerAssists", function(p_PlayerId, p_Assists)
	Helpers_SetPlayerAssists(p_PlayerId, p_Assists)
end)

export("SetPlayerChatTag", function(p_PlayerId, p_Tag)
	Helpers_SetPlayerChatTag(p_PlayerId, p_Tag)
end)

export("SetPlayerClanTag", function(p_PlayerId, p_Tag)
	Helpers_SetPlayerClanTag(p_PlayerId, p_Tag)
end)

export("SetPlayerCollisionGroup", function(p_PlayerId, p_Group)
	Helpers_SetPlayerCollisionGroup(p_PlayerId, p_Group)
end)

export("SetPlayerConVar", function(p_PlayerId, p_Name, p_Value)
	Helpers_SetPlayerConVar(p_PlayerId, p_Name, p_Value)
end)

export("SetPlayerDamage", function(p_PlayerId, p_Damage)
	Helpers_SetPlayerDamage(p_PlayerId, p_Damage)
end)

export("SetPlayerDeaths", function(p_PlayerId, p_Deaths)
	Helpers_SetPlayerDeaths(p_PlayerId, p_Deaths)
end)

export("SetPlayerEntityName", function(p_PlayerId, p_Name)
	Helpers_SetPlayerEntityName(p_PlayerId, p_Name)
end)

export("SetPlayerHealth", function(p_PlayerId, p_Health)
	Helpers_SetPlayerHealth(p_PlayerId, p_Health)
end)

export("SetPlayerImmunity", function(p_PlayerId)
	Helpers_SetPlayerImmunity(p_PlayerId)
end)

export("SetPlayerKills", function(p_PlayerId, p_Kills)
	Helpers_SetPlayerKills(p_PlayerId, p_Kills)
end)

export("SetPlayerMVPs", function(p_PlayerId, p_MVPs)
	Helpers_SetPlayerMVPs(p_PlayerId, p_MVPs)
end)

export("SetPlayerRenderColor", function(p_PlayerId, p_Color)
	Helpers_SetPlayerRenderColor(p_PlayerId, p_Color)
end)

export("SetPlayerScore", function(p_PlayerId, p_Score)
	Helpers_SetPlayerScore(p_PlayerId, p_Score)
end)

export("SetPlayerTeam", function(p_PlayerId, p_Team)
	Helpers_SetPlayerTeam(p_PlayerId, p_Team)
end)

export("SetPlayerVelocity", function(p_PlayerId, p_Velocity)
	Helpers_SetPlayerVelocity(p_PlayerId, p_Velocity)
end)

export("SetPlayerVelocityModifier", function(p_PlayerId, p_Modifier)
	Helpers_SetPlayerVelocityModifier(p_PlayerId, p_Modifier)
end)

export("SetRoundTime", function(p_Time)
	Helpers_SetRoundTime(p_Time)
end)

export("SetTeamScore", function(p_Team, p_Score)
	Helpers_SetTeamScore(p_Team, p_Score)
end)

export("ShowActivity", function(p_PlayerId, p_Tag, p_Message)
	Helpers_ShowActivity(p_PlayerId, p_Tag, p_Message)
end)

export("ShowActivity2", function(p_From, p_Tag, p_Message)
	Helpers_ShowActivity2(p_From, p_Tag, p_Message)
end)

export("ShuffleTable", function(p_Table)
	return Helpers_ShuffleTable(p_Table)
end)

export("SlapPlayer", function(p_PlayerId, p_Damage)
	Helpers_SlapPlayer(p_PlayerId, p_Damage)
end)

export("SlayPlayer", function(p_PlayerId)
	Helpers_SlayPlayer(p_PlayerId)
end)

export("StringReplace", function(p_Str, p_Find, p_Replace)
	return Helpers_StringReplace(p_Str, p_Find, p_Replace)
end)

export("TeleportPlayer", function(p_PlayerId, p_Origin, p_Rotation, p_Velocity)
	Helpers_TeleportPlayer(p_PlayerId, p_Origin, p_Rotation, p_Velocity)
end)

export("TerminateRound", function(p_Reason, p_Identifier)
	Helpers_TerminateRound(p_Reason, p_Identifier)
end)