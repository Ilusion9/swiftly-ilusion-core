export("GetPlayerAFKTime", function(p_PlayerId)
	return AFK_GetPlayerAFKTime(p_PlayerId)
end)

export("IsPlayerAFK", function(p_PlayerId)
	return AFK_IsPlayerAFK(p_PlayerId)
end)