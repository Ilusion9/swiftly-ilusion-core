function Server_LoadConfig()
	config:Reload("server")
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("server.tag")
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Server]"
	end
end

function Server_SetConVars()
	local l_Config = exports["helpers"]:ParseGameConfig("cfg/swiftly/server.cfg")
	
	for l_Key, l_Value in next, l_Config do
		exports["helpers"]:SetConVar(l_Key, l_Value)
	end
end