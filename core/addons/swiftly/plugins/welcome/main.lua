AddEventHandler("OnPluginStart", function(p_Event)
	Welcome_LoadConfig()
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Welcome_LoadConfig()
end)

AddEventHandler("OnPostPlayerTeam", function(p_Event)
	if p_Event:GetBool("disconnect") then
		return
	end
	
	local l_OldTeam = p_Event:GetInt("oldteam")
	
	if l_OldTeam ~= Team.None then
		return
	end
	
	local l_PlayerId = p_Event:GetInt("userid")
	
	Welcome_ShowPlayerChatMessages(l_PlayerId)
end)