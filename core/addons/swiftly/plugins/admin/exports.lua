export("CanPlayerTargetPlayer", function(p_PlayerId, p_TargetId)
	return Admin_CanPlayerTargetPlayer(p_PlayerId, p_TargetId)
end)

export("CanPlayerTargetSteam", function(p_PlayerId, p_Steam)
	return Admin_CanPlayerTargetSteam(p_PlayerId, p_Steam)
end)

export("GetPlayerGroups", function(p_PlayerId)
	return Admin_GetPlayerGroups(p_PlayerId)
end)

export("GetPlayerImmunity", function(p_PlayerId)
	return Admin_GetPlayerImmunity(p_PlayerId)
end)

export("GetPlayerUser", function(p_PlayerId)
	return Admin_GetPlayerUser(p_PlayerId)
end)

export("GetSteamGroups", function(p_Steam)
	return Admin_GetSteamGroups(p_Steam)
end)

export("GetSteamImmunity", function(p_Steam)
	return Admin_GetSteamImmunity(p_Steam)
end)

export("GetSteamUser", function(p_Steam)
	return Admin_GetSteamUser(p_Steam)
end)

export("HasPlayerGroups", function(p_PlayerId)
	return Admin_HasPlayerGroups(p_PlayerId)
end)

export("HasPlayerPermission", function(p_PlayerId, p_Permission)
	return Admin_HasPlayerPermission(p_PlayerId, p_Permission)
end)

export("HasSteamGroups", function(p_Steam)
	return Admin_HasSteamGroups(p_Steam)
end)

export("HasSteamPermission", function(p_Steam, p_Permission)
	return Admin_HasSteamPermission(p_Steam, p_Permission)
end)

export("ReloadAdmins", function()
	Admin_ReloadAdmins()
end)