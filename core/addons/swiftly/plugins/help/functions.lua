function Help_LoadConfig()
	config:Reload("help")
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("help.tag")
	g_Config["pagination.size"] = tonumber(config:Fetch("help.pagination.size"))
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Help]"
	end
	
	if not g_Config["pagination.size"] or g_Config["pagination.size"] < 0 then
		g_Config["pagination.size"] = PAGINATION_SIZE
	end
end