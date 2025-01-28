function Server_LoadConfig()
	config:Reload("server")
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("server.tag")
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Server]"
	end
end