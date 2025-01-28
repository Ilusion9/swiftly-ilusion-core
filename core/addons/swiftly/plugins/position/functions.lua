function Position_LoadConfig()
	config:Reload("position")
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("position.tag")
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Position]"
	end
end