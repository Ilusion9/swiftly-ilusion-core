AddEventHandler("OnPluginStart", function(p_Event)
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	g_PluginIsLoading = true
	g_PluginIsLoadingLate = l_ServerTime > 0
	
	Filters_LoadConfig()
end)

AddEventHandler("OnAllPluginsLoaded", function(p_Event)
	if g_PluginIsLoadingLate then
		for i = 0, playermanager:GetPlayerCap() - 1 do
			Filters_ValidatePlayerName(i)
		end
	end
	
	g_PluginIsLoading = nil
	g_PluginIsLoadingLate = nil
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Filters_LoadConfig()
end)

AddEventHandler("OnClientChat", function(p_Event, p_PlayerId, p_Text, p_TeamOnly)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return EventResult.Continue
	end
	
	if Filters_IsValidChat(p_Text) then
		return EventResult.Continue
	end
	
	l_Player:SendMsg(MessageType.Chat, string.format("{lightred}%s{default} This message contains restricted content", g_Config["tag"]))
	
	p_Event:SetReturn(false)
	return EventResult.Handled
end)

AddEventHandler("OnPostPlayerConnectFull", function(p_Event)
	local l_PlayerId = p_Event:GetInt("userid")
	
	Filters_ValidatePlayerName(l_PlayerId)
end)

AddEventHandler("OnPostPlayerChangename", function(p_Event)
	local l_PlayerId = p_Event:GetInt("userid")
	
	Filters_ValidatePlayerName(l_PlayerId)
end)

AddEventHandler("Helpers_OnPlayerChangeName", function(p_Event, p_PlayerId, p_Name)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	local l_Name = p_Event:GetReturn() or p_Name
	
	if Filters_IsValidName(l_Name) then
		return
	end
	
	p_Event:SetReturn("Player " .. p_PlayerId)
end)
