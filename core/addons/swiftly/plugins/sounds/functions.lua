function Sounds_EmitRoundEndSound()
	if not exports["helpers"]:IsRoundOver() then
		return
	end
	
	SetTimeout(100, function()
		if not exports["helpers"]:IsRoundOver() then
			return
		end
		
		local l_Sounds = {}
		
		for i = 1, #g_Config["round.end.sounds"] do
			if i ~= g_RoundEndSoundIndex then
				table.insert(l_Sounds, {
					["key"] = i,
					["value"] = g_Config["round.end.sounds"][i]
				})
			end
		end
		
		local l_Index = math.random(1, #l_Sounds)
		
		exports["helpers"]:EmitSoundToAll(l_Sounds[l_Index]["value"], 100, 1.0)
		
		g_RoundEndSoundIndex = l_Sounds[l_Index]["key"]
	end)
end

function Sounds_LoadConfig()
	config:Reload("sounds")
	
	g_Config = {}
	
	Sounds_LoadRoundEndSounds()
end

function Sounds_LoadRoundEndSounds()
	g_Config["round.end.sounds"] = {}
	
	local l_Sounds = config:Fetch("sounds.round.end")
	
	if type(l_Sounds) ~= "table" then
		l_Sounds = {}
	end
	
	for i = 1, #l_Sounds do
		local l_Sound = l_Sounds[i]
		
		if type(l_Sound) ~= "string" or #l_Sound == 0 then
			l_Sound = nil
		end
		
		if l_Sound then
			table.insert(g_Config["round.end.sounds"], l_Sound)
		end
	end
end

function Sounds_ResetVars()
	g_RoundEndSoundIndex = nil
end