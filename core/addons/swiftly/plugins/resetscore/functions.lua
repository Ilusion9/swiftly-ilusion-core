function Resetscore_LoadConfig()
	config:Reload("resetscore")
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("resetscore.tag")
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Resetscore]"
	end
end