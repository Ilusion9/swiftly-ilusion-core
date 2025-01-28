function Admin_CanPlayerTargetPlayer(p_PlayerId, p_TargetId)
	if Admin_GetPlayerImmunity(p_PlayerId) < Admin_GetPlayerImmunity(p_TargetId) then
		return false
	end
	
	return true
end

function Admin_CanPlayerTargetSteam(p_PlayerId, p_Steam)
	if Admin_GetPlayerImmunity(p_PlayerId) < Admin_GetSteamImmunity(p_Steam) then
		return false
	end
	
	return true
end

function Admin_GetPlayerGroups(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return nil
	end
	
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	return Admin_GetSteamGroups(l_PlayerSteam)
end

function Admin_GetPlayerImmunity(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return 0
	end
	
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	return Admin_GetSteamImmunity(l_PlayerSteam)
end

function Admin_GetPlayerUser(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return nil
	end
	
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	return Admin_GetSteamUser(l_PlayerSteam)
end

function Admin_GetSteamGroups(p_Steam)
	local l_Steam = tostring(p_Steam)
	
	if not g_Config["users"][l_Steam] or not g_Config["users"][l_Steam]["groups"] then
		return nil
	end
	
	local l_Groups = {}
	
	for i = 1, #g_Config["users"][l_Steam]["groups"] do
		local l_Group = g_Config["users"][l_Steam]["groups"][i]
		
		table.insert(l_Groups, {
			["group"] = l_Group,
			["rank"] = g_Config["groups"][l_Group]["rank"]
		})
	end
	
	return l_Groups
end

function Admin_GetSteamImmunity(p_Steam)
	local l_Steam = tostring(p_Steam)
	
	if not g_Config["users"][l_Steam] then
		return 0
	end
	
	local l_Immunity = g_Config["users"][l_Steam]["immunity"]
	
	if not g_Config["users"][l_Steam]["groups"] then
		return l_Immunity
	end
	
	for i = 1, #g_Config["users"][l_Steam]["groups"] do
		local l_Group = g_Config["users"][l_Steam]["groups"][i]
		
		if g_Config["groups"][l_Group]["immunity"] > l_Immunity then
			l_Immunity = g_Config["groups"][l_Group]["immunity"]
		end
	end
	
	return l_Immunity
end

function Admin_GetSteamUser(p_Steam)
	local l_Steam = tostring(p_Steam)
	
	if not g_Config["users"][l_Steam] then
		return nil
	end
	
	return g_Config["users"][l_Steam]["user"]
end

function Admin_HasPlayerGroups(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return false
	end
	
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	return Admin_HasSteamGroups(l_PlayerSteam)
end

function Admin_HasPlayerPermission(p_PlayerId, p_Permission)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return false
	end
	
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	
	return Admin_HasSteamPermission(l_PlayerSteam, p_Permission)
end

function Admin_HasSteamGroups(p_Steam)
	local l_Steam = tostring(p_Steam)
	
	if not g_Config["users"][l_Steam] or not g_Config["users"][l_Steam]["groups"] then
		return false
	end
	
	return true
end

function Admin_HasSteamPermission(p_Steam, p_Permission)
	if not g_Config["permissions"][p_Permission] then
		return false
	end
	
	local l_Steam = tostring(p_Steam)
	
	if not g_Config["users"][l_Steam] or not g_Config["users"][l_Steam]["groups"] then
		return false
	end
	
	for i = 1, #g_Config["users"][l_Steam]["groups"] do
		local l_Group = g_Config["users"][l_Steam]["groups"][i]
		
		if g_Config["permissions"][p_Permission][l_Group] then
			return true
		end
	end
	
    return false
end

function Admin_LoadConfig()
	config:Reload("admin")

	g_Config = {}
	g_Config["tag"] = config:Fetch("admin.tag")
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Admin]"
	end
	
	Admin_LoadConfigGroups()
	Admin_LoadConfigUsers()
	
	Admin_RemoveInvalidGroups()
end

function Admin_LoadConfigGroups()
	g_Config["groups"] = {}
	g_Config["permissions"] = {}
	
	local l_Groups = config:Fetch("admin.groups")
	
	if type(l_Groups) ~= "table" then
		l_Groups = {}
	end
	
	for i = 1, #l_Groups do
		local l_Group = l_Groups[i]["group"]
		local l_Rank = l_Groups[i]["rank"]
		
		if type(l_Group) ~= "string" or #l_Group == 0 then
			l_Group = nil
		end
		
		if type(l_Rank) ~= "string" or #l_Rank == 0 then
			l_Rank = nil
		end
		
		if l_Group and l_Rank then
			if not g_Config["groups"][l_Group] then
				g_Config["groups"][l_Group] = {}
			end
			
			local l_Immunity = tonumber(l_Groups[i]["immunity"])
			local l_Permissions = l_Groups[i]["permissions"]
			
			if not l_Immunity or l_Immunity < 0 then
				l_Immunity = 0
			end
			
			if type(l_Permissions) ~= "table" then
				l_Permissions = {}
			end
			
			g_Config["groups"][l_Group]["immunity"] = l_Immunity
			g_Config["groups"][l_Group]["rank"] = l_Rank
			
			for j = #g_Config["permissions"], 1, -1 do
				g_Config["permissions"][j][l_Group] = nil
				
				if not next(g_Config["permissions"][j]) then
					table.remove(g_Config["permissions"], j)
				end
			end
			
			for j = 1, #l_Permissions do
				local l_Permission = l_Permissions[j]
				
				if type(l_Permission) ~= "string" or #l_Permission == 0 then
					l_Permission = nil
				end
				
				if l_Permission then
					if not g_Config["permissions"][l_Permission] then
						g_Config["permissions"][l_Permission] = {}
					end
					
					g_Config["permissions"][l_Permission][l_Group] = true
				end
			end
		end
	end
end

function Admin_LoadConfigUsers()
	g_Config["users"] = {}
	
	local l_Users = config:Fetch("admin.users")
	
	if type(l_Users) ~= "table" then
		l_Users = {}
	end
	
	for i = 1, #l_Users do
		local l_User = l_Users[i]["user"]
		local l_Steam = l_Users[i]["steam"]
		
		if type(l_User) ~= "string" or #l_User == 0 then
			l_User = nil
		end
		
		if type(l_Steam) ~= "string" or #l_Steam == 0 then
			l_Steam = nil
		end
		
		if l_User and l_Steam then
			if g_Config["users"][l_Steam] then
				g_Config["users"][l_Steam]["groups"] = nil
			else
				g_Config["users"][l_Steam] = {}
			end
			
			local l_Immunity = tonumber(l_Users[i]["immunity"])
			local l_Groups = l_Users[i]["groups"]
			
			if not l_Immunity or l_Immunity < 0 then
				l_Immunity = 0
			end
			
			if type(l_Groups) ~= "table" then
				l_Groups = {}
			end
			
			g_Config["users"][l_Steam]["immunity"] = l_Immunity
			g_Config["users"][l_Steam]["user"] = l_User
			
			for j = 1, #l_Groups do
				local l_Group = l_Groups[j]
				
				if type(l_Group) ~= "string" or #l_Group == 0 then
					l_Group = nil
				end
				
				if l_Group then
					if not g_Config["users"][l_Steam]["groups"] then
						g_Config["users"][l_Steam]["groups"] = {}
					end
					
					table.insert(g_Config["users"][l_Steam]["groups"], l_Group)
				end
			end
		end
	end
end

function Admin_ReloadAdmins()
	config:Reload("admin")
	
	Admin_LoadConfigGroups()
	Admin_LoadConfigUsers()
	
	Admin_RemoveInvalidGroups()
end

function Admin_RemoveInvalidGroups()
	for l_Key, l_Value in next, g_Config["users"] do
		if l_Value["groups"] then
			for i = #l_Value["groups"], 1, -1 do
				local l_Group = l_Value["groups"][i]
				
				if not g_Config["groups"][l_Group] then
					table.remove(l_Value["groups"], i)
				end
			end
			
			if #l_Value["groups"] == 0 then
				l_Value["groups"] = nil
			end
		end
	end
end