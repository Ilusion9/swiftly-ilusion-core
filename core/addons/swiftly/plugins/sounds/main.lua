AddEventHandler("OnPluginStart", function(p_Event)
	Sounds_ResetVars()
	Sounds_LoadConfig()
end)

AddEventHandler("OnMapLoad", function(p_Event, p_Map)
	Sounds_ResetVars()
	Sounds_LoadConfig()
end)

AddEventHandler("OnPostRoundEnd", function(p_Event)
	if #g_Config["round.end.sounds"] == 0 then
		return
	end
	
	local l_Reason = p_Event:GetInt("reason")
	
	if l_Reason == RoundEndReason_t.Unknown 
		or l_Reason == RoundEndReason_t.GameCommencing 
		or l_Reason == RoundEndReason_t.RoundDraw 
		or l_Reason == RoundEndReason_t.SurvivalDraw 
	then
		return
	end
	
	Sounds_EmitRoundEndSound()
end)