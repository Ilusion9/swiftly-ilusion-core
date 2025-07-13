g_Memory_TerminateRound = Memory()
g_Memory_TerminateRound:LoadFromSignatureName("CGameRules_TerminateRound")

g_Hook_TerminateRound = AddHook(g_Memory_TerminateRound, "pfuIu", "v")

AddEventHandler("OnPluginStart", function(p_Event)
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	g_PluginIsLoading = true
	g_PluginIsLoadingLate = l_ServerTime > 0
	
	Helpers_ResetVars()
	Helpers_LoadCoreConfig()
end)

AddEventHandler("OnAllPluginsLoaded", function(p_Event)
	if g_PluginIsLoadingLate then
		for i = 0, playermanager:GetPlayerCap() - 1 do
			Helpers_ResetPlayerVars(i)
			
			Helpers_RemovePlayerChatTags(i)
			Helpers_RemovePlayerClanTags(i)
			
			Helpers_StorePlayerName(i)
		end
		
		TriggerEvent("Helpers_OnPluginStartLate")
	end
	
	g_PluginIsLoading = nil
	g_PluginIsLoadingLate = nil
end)

AddEventHandler("OnPluginStop", function(p_Event)
	if g_PluginIsLoadingLate then
		for i = 0, playermanager:GetPlayerCap() - 1 do
			Helpers_RemovePlayerChatTags(i)
			Helpers_RemovePlayerClanTags(i)
		end
	end
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Helpers_ResetVars()
	Helpers_LoadCoreConfig()
end)

AddPreHookListener(g_Hook_TerminateRound, function(p_Event)
	local l_Identifier = g_TerminateIdentifier
	local l_Reason = p_Event:GetHookUInt(2)
	
	g_TerminateIdentifier = nil
	
	local l_EventReturn, l_Event = TriggerEvent("Helpers_OnTerminateRoundPre", l_Reason, l_Identifier)
	local l_EventReason = l_Event:GetReturn() or l_Reason
	
	l_Reason = l_EventReason
	
	l_EventReturn, l_Event = TriggerEvent("Helpers_OnTerminateRound", l_Reason, l_Identifier)
	l_EventReason = l_Event:GetReturn() or l_Reason
	
	p_Event:SetHookUInt(2, l_EventReason)
	
	if l_EventReturn == EventResult.Continue 
		or l_EventReturn == EventResult.Handled 
		or l_EventReturn == EventResult.Stop 
	then
		return l_EventReturn
	end
end)

AddEventHandler("OnPostPlayerConnectFull", function(p_Event)
	local l_PlayerId = p_Event:GetInt("userid")
	
	Helpers_StorePlayerName(l_PlayerId)
end)

AddEventHandler("OnPostPlayerChangename", function(p_Event)
	local l_PlayerId = p_Event:GetInt("userid")
	
	Helpers_StorePlayerName(l_PlayerId)
end)