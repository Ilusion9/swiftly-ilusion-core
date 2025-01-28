export("GetZones", function(p_Name)
	return Zones_GetZones(p_Name)
end)

export("ZoneExists", function(p_Name)
	return Zones_ZoneExists(p_Name)
end)