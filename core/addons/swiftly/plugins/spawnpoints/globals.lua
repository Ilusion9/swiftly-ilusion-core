SPAWNPOINT_CUSTOM = 0
SPAWNPOINT_MAP = 2

g_SpawnPointClassnames = {
	[Team.T] = "info_player_terrorist",
	[Team.CT] = "info_player_counterterrorist"
}

g_SpawnPointIdentifiers = {
	["custom"] = SPAWNPOINT_CUSTOM,
	["map"] = SPAWNPOINT_MAP,
	[SPAWNPOINT_CUSTOM] = "custom",
	[SPAWNPOINT_MAP] = "map"
}