function Tag_FindColor(p_Color)
	for i = 1, #g_Config["colors"] do
		if p_Color == g_Config["colors"][i]["name"] then
			return i
		end
	end
	
	return nil
end

function Tag_FindPlayerTag(p_PlayerId, p_Tag)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return nil
	end
	
	local l_PlayerTags = l_Player:GetVar("tag.tags") or {}
	
	for i = 1, #l_PlayerTags do
		if p_Tag == l_PlayerTags[i] then
			return i
		end
	end
	
	return nil
end

function Tag_GetPlayerTag(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return nil
	end
	
	local l_PlayerTagId = l_Player:GetVar("tag.tag.id")
	
	if not l_PlayerTagId then
		return nil
	end
	
	local l_PlayerTags = l_Player:GetVar("tag.tags")
	
	return l_PlayerTags[l_PlayerTagId]
end

function Tag_GetPlayerTagColor(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return nil
	end
	
	local l_PlayerColorId = l_Player:GetVar("tag.color.id")
	
	if not l_PlayerColorId then
		return nil
	end
	
	return g_Config["colors"][l_PlayerColorId]["name"]
end

function Tag_LoadConfig()
	config:Reload("tag")
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("tag.tag")
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Tag]"
	end
	
	Tag_LoadConfigColors()
	Tag_LoadConfigUsers()
end

function Tag_LoadConfigColors()
	g_Config["colors"] = {}
	
	local l_Colors = config:Fetch("tag.colors")
	
	if type(l_Colors) ~= "table" then
		l_Colors = {}
	end
	
	for i = 1, #l_Colors do
		local l_Name = l_Colors[i]["name"]
		local l_Tag = l_Colors[i]["tag"]
		
		if type(l_Name) ~= "string" or #l_Name == 0 then
			l_Name = nil
		end
		
		if type(l_Tag) ~= "string" or #l_Tag == 0 then
			l_Tag = nil
		end
		
		if l_Name and l_Tag then
			table.insert(g_Config["colors"], {
				["name"] = l_Name,
				["tag"] = l_Tag
			})
		end
	end
	
	table.insert(g_Config["colors"], {
		["name"] = "Default",
		["tag"] = "{default}"
	})
end

function Tag_LoadConfigUsers()
	g_Config["users"] = {}
	
	local l_Users = config:Fetch("tag.users")
	
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
				g_Config["users"][l_Steam]["tags"] = nil
			else
				g_Config["users"][l_Steam] = {}
			end
			
			local l_Tags = l_Users[i]["tags"]
			
			if type(l_Tags) ~= "table" then
				l_Tags = {}
			end
			
			g_Config["users"][l_Steam]["user"] = l_User
			
			for j = 1, #l_Tags do
				local l_Tag = l_Tags[j]
				
				if type(l_Tag) ~= "string" or #l_Tag == 0 then
					l_Tag = nil
				end
				
				if l_Tag then
					if not g_Config["users"][l_Steam]["tags"] then
						g_Config["users"][l_Steam]["tags"] = {}
					end
					
					table.insert(g_Config["users"][l_Steam]["tags"], l_Tag)
				end
			end
		end
	end
end

function Tag_LoadPlayerTags(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() or l_Player:IsFakeClient() then
		return
	end
	
	local l_PlayerSteam = exports["helpers"]:GetPlayerSteam(p_PlayerId)
	local l_PlayerGroups = exports["admin"]:GetPlayerGroups(p_PlayerId)
	
	local l_Tags = {}
	
	if l_PlayerGroups then
		for i = 1, #l_PlayerGroups do
			table.insert(l_Tags, l_PlayerGroups[i]["rank"])
		end
	end
	
	if g_Config["users"][l_PlayerSteam] and g_Config["users"][l_PlayerSteam]["tags"] then
		for i = 1, #g_Config["users"][l_PlayerSteam]["tags"] do
			table.insert(l_Tags, g_Config["users"][l_PlayerSteam]["tags"][i])
		end
	end
	
	if #l_Tags == 0 then
		return
	end
	
	l_Player:SetVar("tag.tags", l_Tags)
	
	Tag_SetPlayerTag(p_PlayerId, 1)
	Tag_SetPlayerTagColor(p_PlayerId, 1)
end

function Tag_RemovePlayerTag(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerTag = Tag_GetPlayerTag(p_PlayerId)
	
	if not l_PlayerTag then
		return
	end
	
	exports["helpers"]:RemovePlayerChatTag(p_PlayerId, l_PlayerTag)
	
	l_Player:SetVar("tag.tag.id", nil)
end

function Tag_RemovePlayerTagColor(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	l_Player:SetChatTagColor("")
	
	l_Player:SetVar("tag.color.id", nil)
end

function Tag_ResetPlayerVars(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	l_Player:SetVar("tag.color.id", nil)
	l_Player:SetVar("tag.tag.id", nil)
	l_Player:SetVar("tag.tags", nil)
end

function Tag_SetPlayerChatTag(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerTag = Tag_GetPlayerTag(p_PlayerId)
	
	if not l_PlayerTag then
		return
	end
	
	exports["helpers"]:SetPlayerChatTag(p_PlayerId, l_PlayerTag)
end

function Tag_SetPlayerTag(p_PlayerId, p_Index)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerTags = l_Player:GetVar("tag.tags")
	
	if not l_PlayerTags then
		return
	end
	
	exports["helpers"]:SetPlayerChatTag(p_PlayerId, l_PlayerTags[p_Index])
	
	l_Player:SetVar("tag.tag.id", p_Index)
end

function Tag_SetPlayerTagColor(p_PlayerId, p_Index)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	l_Player:SetChatTagColor(g_Config["colors"][p_Index]["tag"])
	
	l_Player:SetVar("tag.color.id", p_Index)
end