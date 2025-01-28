function Spawnpoints_GetCustomSpawnPoints(p_Team, p_Name)
	local l_SpawnPoints = {}
	
	for i = 1, #g_Config["spawnpoints"] do
		if (not p_Team or p_Team == g_Config["spawnpoints"][i]["team"]) 
			and (not p_Name or p_Name == g_Config["spawnpoints"][i]["name"]) 
		then
			table.insert(l_SpawnPoints, {
				["name"] = g_Config["spawnpoints"][i]["name"],
				["team"] = g_Config["spawnpoints"][i]["team"],
				["origin"] = g_Config["spawnpoints"][i]["origin"],
				["rotation"] = g_Config["spawnpoints"][i]["rotation"]
			})
		end
	end
	
	return l_SpawnPoints
end

function Spawnpoints_GetMapSpawnPoints(p_Team)
	local l_SpawnPoints = {}
	
	if p_Team ~= Team.T and p_Team ~= Team.CT then
		return l_SpawnPoints
	end
	
	local l_Entities = FindEntitiesByClassname(g_SpawnPointClassnames[p_Team])
	
	for i = 1, #l_Entities do
		local l_Entity = SpawnPoint(l_Entities[i]:ToPtr())
		
		if l_Entity and l_Entity:IsValid() and l_Entity.Enabled then
			table.insert(l_SpawnPoints, {
				["origin"] = {
					l_Entity.Parent.Parent.Parent.CBodyComponent.SceneNode.AbsOrigin.x,
					l_Entity.Parent.Parent.Parent.CBodyComponent.SceneNode.AbsOrigin.y,
					l_Entity.Parent.Parent.Parent.CBodyComponent.SceneNode.AbsOrigin.z
				},
				["rotation"] = {
					l_Entity.Parent.Parent.Parent.CBodyComponent.SceneNode.AbsRotation.x,
					l_Entity.Parent.Parent.Parent.CBodyComponent.SceneNode.AbsRotation.y,
					l_Entity.Parent.Parent.Parent.CBodyComponent.SceneNode.AbsRotation.z
				}
			})
		end
	end
	
	return l_SpawnPoints
end

function Spawnpoints_LoadConfig()
	local l_Map = server:GetMap()
	
	config:Reload("spawnpoints")
	config:Reload("spawnpoints/" .. l_Map)
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("spawnpoints.tag")
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Spawnpoints]"
	end
	
	Spawnpoints_LoadConfigSpawnPoints()
end

function Spawnpoints_LoadConfigSpawnPoints()
	g_Config["spawnpoints"] = {}
	
	local l_Map = server:GetMap()
	local l_SpawnPoints = config:Fetch("spawnpoints." .. l_Map .. ".spawnpoints")
	
	if type(l_SpawnPoints) ~= "table" then
		l_SpawnPoints = {}
	end
	
	for i = 1, #l_SpawnPoints do
		local l_Name = l_SpawnPoints[i]["name"]
		local l_Team = l_SpawnPoints[i]["team"]
		local l_Origin = l_SpawnPoints[i]["origin"]
		local l_Rotation = l_SpawnPoints[i]["rotation"]
		
		if type(l_Name) ~= "string" or #l_Name == 0 then
			l_Name = nil
		end
		
		if type(l_Team) ~= "string" or #l_Team == 0 then
			l_Team = nil
		end
		
		if type(l_Origin) ~= "table" or not exports["helpers"]:IsValidVector(l_Origin) then
			l_Origin = nil
		end
		
		if type(l_Rotation) ~= "table" or not exports["helpers"]:IsValidVector(l_Rotation) then
			l_Rotation = nil
		end
		
		l_Team = exports["helpers"]:GetTeamFromIdentifier(l_Team)
		
		if l_Origin and l_Rotation then
			table.insert(g_Config["spawnpoints"], {
				["name"] = l_Name,
				["team"] = l_Team,
				["origin"] = l_Origin,
				["rotation"] = l_Rotation
			})
		end
	end
end