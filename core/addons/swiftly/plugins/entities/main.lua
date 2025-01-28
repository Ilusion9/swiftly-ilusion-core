g_Hook_OnEntityOutput = AddHookEntityOutput("*", "*")

AddEventHandler("OnPluginStart", function(p_Event)
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	g_PluginIsLoading = true
	g_PluginIsLoadingLate = l_ServerTime > 0
	
	Entities_LoadConfig()
end)

AddEventHandler("OnAllPluginsLoaded", function(p_Event)
	if g_PluginIsLoadingLate then
		for i = 0, playermanager:GetPlayerCap() - 1 do
			Entities_ResetPlayerVars(i)
		end
	end
	
	g_PluginIsLoading = nil
	g_PluginIsLoadingLate = nil
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Entities_LoadConfig()
end)

AddEventHandler("OnEntitySpawned", function(p_Event, p_EntityPtr)
	Entities_DeleteEntity(p_EntityPtr)
end)

AddEventHandler("OnEntityAcceptInput", function(p_Event, p_EntityPtr, p_InputName, p_ActivatorPtr, p_CallerPtr, p_Value, p_OutputID)
	for i = 0, playermanager:GetPlayerCap() - 1 do
		Entities_ShowPlayerEntityInput(i, p_EntityPtr, p_InputName)
	end
end)

AddPostHookListener(g_Hook_OnEntityOutput, function(p_Event, p_IOOutputPtr, p_OutputName, p_ActivatorPtr, p_CallerPtr, p_Delay)
	for i = 0, playermanager:GetPlayerCap() - 1 do
		Entities_ShowPlayerEntityOutput(i, p_CallerPtr, p_OutputName)
	end
end)