export("ChangeMap", function(p_Map, p_Workshop, p_Reason)
	Map_ChangeMap(p_Map, p_Workshop, p_Reason)
end)

export("FindMap", function(p_Str)
	return Map_FindMap(p_Str)
end)

export("GetMaps", function()
	return Map_GetMaps()
end)