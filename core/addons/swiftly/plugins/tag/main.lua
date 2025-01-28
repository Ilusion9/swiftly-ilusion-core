AddEventHandler("OnPluginStart", function(p_Event)
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	g_PluginIsLoading = true
	g_PluginIsLoadingLate = l_ServerTime > 0
	
	Tag_LoadConfig()
end)

AddEventHandler("OnAllPluginsLoaded", function(p_Event)
	if g_PluginIsLoadingLate then
		for i = 0, playermanager:GetPlayerCap() - 1 do
			Tag_ResetPlayerVars(i)
			
			Tag_RemovePlayerTag(i)
			Tag_RemovePlayerTagColor(i)
			
			Tag_LoadPlayerTags(i)
		end
		
		exports["cookies"]:GetCookies()
	end
	
	g_PluginIsLoading = nil
	g_PluginIsLoadingLate = nil
end)

AddEventHandler("OnPluginStop", function(p_Event)
	exports["cookies"]:SetCookies()
	
	for i = 0, playermanager:GetPlayerCap() - 1 do
		Tag_RemovePlayerTag(i)
		Tag_RemovePlayerTagColor(i)
	end
end)

AddEventHandler("Helpers_OnPluginStartLate", function(p_Event)
	for i = 0, playermanager:GetPlayerCap() - 1 do
		Tag_SetPlayerChatTag(i)
	end
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Tag_LoadConfig()
end)

AddEventHandler("OnPostPlayerConnectFull", function(p_Event)
	local l_PlayerId = p_Event:GetInt("userid")
	
	Tag_LoadPlayerTags(l_PlayerId)
end)

AddEventHandler("Cookies_OnPlayerGetCookies", function(p_Event, p_PlayerId, p_Cookies)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	if p_Cookies["tag.tag"] then
		local l_Index = Tag_FindPlayerTag(p_PlayerId, p_Cookies["tag.tag"])
		
		if l_Index then
			Tag_SetPlayerTag(p_PlayerId, l_Index)
		end
	end
	
	if p_Cookies["tag.color"] then
		local l_Index = Tag_FindColor(p_Cookies["tag.color"])
		
		if l_Index then
			Tag_SetPlayerTagColor(p_PlayerId, l_Index)
		end
	end
end)

AddEventHandler("Cookies_OnPlayerSetCookies", function(p_Event, p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	local l_Cookies = p_Event:GetReturn() or {}
	
	l_Cookies["tag.tag"] = Tag_GetPlayerTag(p_PlayerId)
	l_Cookies["tag.color"] = Tag_GetPlayerTagColor(p_PlayerId)
	
	if not l_Cookies["tag.tag"] and not l_Cookies["tag.color"] then
		return
	end
	
	p_Event:SetReturn(l_Cookies)
end)

AddEventHandler("Helpers_OnPlayerRemoveChatTag", function(p_Event, p_PlayerId, p_Tag)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return EventResult.Continue
	end
	
	local l_PlayerTag = Tag_GetPlayerTag(p_PlayerId)
	
	if not l_PlayerTag or l_PlayerTag ~= p_Tag then
		return EventResult.Continue
	end
	
	return EventResult.Handled
end)