function Zones_CheckPlayerTouchZones(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player 
		or not l_Player:IsValid() 
		or not exports["helpers"]:IsPlayerAlive(p_PlayerId) 
	then
		return
	end
	
	local l_PlayerTouchZones = l_Player:GetVar("zones.touch.zones") or {}
	
	for i = 1, #g_Zones do
		if exports["helpers"]:IsPlayerTouchingBox(p_PlayerId, g_Zones[i]["origin"], g_Zones[i]["mins"], g_Zones[i]["maxs"]) then
			if not l_PlayerTouchZones[i] then
				l_PlayerTouchZones[i] = true
				
				TriggerEvent("Zones_OnPlayerStartTouch", p_PlayerId, g_Zones[i]["name"], g_Zones[i]["origin"], g_Zones[i]["mins"], g_Zones[i]["maxs"])
			end
		else
			if l_PlayerTouchZones[i] then
				l_PlayerTouchZones[i] = nil
				
				TriggerEvent("Zones_OnPlayerEndTouch", p_PlayerId, g_Zones[i]["name"], g_Zones[i]["origin"], g_Zones[i]["mins"], g_Zones[i]["maxs"])
			end
		end
	end
	
	l_Player:SetVar("zones.touch.zones", next(l_PlayerTouchZones) and l_PlayerTouchZones or nil)
end

function Zones_CreatePlayerZone(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerZone = l_Player:GetVar("zones.zone")
	
	if not l_PlayerZone or not l_PlayerZone["name"] then
		return
	end
	
	Zones_CreateZone(l_PlayerZone)
	
	g_ZoneNames["p:" .. l_PlayerZone["name"]] = true
end

function Zones_CreateZone(p_Zone)
	local l_Box = exports["helpers"]:GetBoxFromPoints(p_Zone["point1"], p_Zone["point2"])
	
	if p_Zone["color"] then
		local l_Edges = exports["helpers"]:GetBoxEdgesFromPoints(p_Zone["point1"], p_Zone["point2"])
		
		for i = 1, #l_Edges do
			exports["helpers"]:CreateBeamEntity(l_Edges[i][1], l_Edges[i][2], p_Zone["name"], p_Zone["color"])
		end
	end
	
	return {
		["name"] = p_Zone["name"],
		["mins"] = l_Box["mins"],
		["maxs"] = l_Box["maxs"],
		["origin"] = l_Box["origin"]
	}
end

function Zones_CreateZones()
	g_Zones = {}
	g_ZoneNames = {}
	
	for i = 1, #g_Config["zones"] do
		local l_Zone = Zones_CreateZone(g_Config["zones"][i])
		
		table.insert(g_Zones, l_Zone)
		
		g_ZoneNames["z:" .. l_Zone["name"]] = true
	end
	
	for i = 0, playermanager:GetPlayerCap() - 1 do
		Zones_CreatePlayerZone(i)
	end
end

function Zones_GetZones(p_Name)
	local l_Zones = {}
	
	for i = 1, #g_Zones do
		if not p_Name or g_Zones[i]["name"] == p_Name then
			table.insert(l_Zones, {
				["mins"] = g_Zones[i]["mins"],
				["maxs"] = g_Zones[i]["maxs"],
				["origin"] = g_Zones[i]["origin"]
			})
		end
	end
	
	return l_Zones
end

function Zones_LoadConfig()
	local l_Map = server:GetMap()
	
	config:Reload("zones")
	config:Reload("zones/" .. l_Map)
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("zones.tag")
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Zones]"
	end
	
	Zones_LoadZones()
end

function Zones_LoadZones()
	g_Config["zones"] = {}
	
	local l_Map = server:GetMap()
	local l_Zones = config:Fetch("zones." .. l_Map .. ".zones")
	
	if type(l_Zones) ~= "table" then
		l_Zones = {}
	end
	
	for i = 1, #l_Zones do
		local l_Name = l_Zones[i]["name"]
		local l_Point1 = l_Zones[i]["point1"]
		local l_Point2 = l_Zones[i]["point2"]
		local l_Color = l_Zones[i]["color"]
		
		if type(l_Name) ~= "string" or #l_Name == 0 then
			l_Name = nil
		end
		
		if type(l_Point1) ~= "table" or not exports["helpers"]:IsValidVector(l_Point1) then
			l_Point1 = nil
		end
		
		if type(l_Point2) ~= "table" or not exports["helpers"]:IsValidVector(l_Point2) then
			l_Point2 = nil
		end
		
		if type(l_Color) ~= "table" or not exports["helpers"]:IsValidColor(l_Color) then
			l_Color = nil
		end
		
		if l_Name and l_Point1 and l_Point2 then
			table.insert(g_Config["zones"], {
				["name"] = l_Name,
				["point1"] = l_Point1,
				["point2"] = l_Point2,
				["color"] = l_Color
			})
		end
	end
end

function Zones_RemovePlayerZone(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	local l_PlayerZone = l_Player:GetVar("zones.zone")
	
	if not l_PlayerZone or not l_PlayerZone["name"] then
		return
	end
	
	local l_Entities = FindEntitiesByClassname("beam")
	
	l_Player:SetVar("zones.zone", nil)
	
	for i = 1, #l_Entities do
		local l_Entity = CBaseEntity(l_Entities[i]:ToPtr())
		
		if l_Entity and l_Entity:IsValid() then
			if l_PlayerZone["name"] == l_Entity.Parent.Entity.Name then
				l_Entity:Despawn()
			end
		end
	end
	
	g_ZoneNames["p:" .. l_PlayerZone["name"]] = nil
end

function Zones_RemoveZones()
	local l_Entities = FindEntitiesByClassname("beam")
	
	for i = 1, #l_Entities do
		local l_Entity = CBaseEntity(l_Entities[i]:ToPtr())
		
		if l_Entity and l_Entity:IsValid() then
			if g_ZoneNames["z:" .. l_Entity.Parent.Entity.Name] 
				or g_ZoneNames["p:" .. l_Entity.Parent.Entity.Name] 
			then
				l_Entity:Despawn()
			end
		end
	end
	
	g_Zones = {}
	g_ZoneNames = {}
end

function Zones_ResetPlayerVars(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	l_Player:SetVar("zones.touch.zones", nil)
	l_Player:SetVar("zones.zone", nil)
end

function Zones_ResetVars()
	g_Zones = {}
	g_ZoneNames = {}
end

function Zones_ZoneExists(p_Name)
	return g_ZoneNames["z:" .. p_Name] or false
end