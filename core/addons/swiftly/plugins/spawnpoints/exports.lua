export("GetCustomSpawnPoints", function(p_Team, p_Name)
	return Spawnpoints_GetCustomSpawnPoints(p_Team, p_Name)
end)

export("GetMapSpawnPoints", function(p_Team)
	return Spawnpoints_GetMapSpawnPoints(p_Team)
end)