function Servers_FormatAddress(p_Ip, p_Port)
	return p_Ip and p_Port and string.format("%s:%s", p_Ip, p_Port) or ""
end

function Servers_FormatPlayers(p_Players, p_MaxPlayers, p_IsOnline)
	local l_Buffer = string.format("%d/%d", p_Players, p_MaxPlayers)
	
	if not p_IsOnline then
		l_Buffer = l_Buffer .. " (off)"
	end
	
	return l_Buffer
end

function Servers_GetServerIndex(p_Name, p_Players, p_IsOnline)
	for i = 1, #g_Servers do
		if p_IsOnline and g_Servers[i]["is_online"] then
			if p_Players > g_Servers[i]["players"] then
				return i
			elseif p_Players == g_Servers[i]["players"] and p_Name < g_Servers[i]["name"] then
				return i
			end
		elseif not g_Servers[i]["is_online"] then
			if p_IsOnline or p_Name < g_Servers[i]["name"] then
				return i
			end
		end
	end
	
	return #g_Servers + 1
end

function Servers_LoadConfig()
	config:Reload("servers")
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("servers.tag")
	g_Config["interval"] = tonumber(config:Fetch("servers.interval"))
	g_Config["method"] = config:Fetch("servers.method")
	g_Config["url"] = config:Fetch("servers.url")
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Servers]"
	end
	
	if not g_Config["interval"] or g_Config["interval"] < 1 then
		g_Config["interval"] = 1
	end
	
	if type(g_Config["method"]) ~= "string" 
		or g_Config["method"] ~= "GET" and g_Config["method"] ~= "POST" 
	then
		g_Config["method"] = ""
	end
	
	if type(g_Config["url"]) ~= "string" 
		or string.sub(g_Config["url"], 1, 7) ~= "http://" and string.sub(g_Config["url"], 1, 8) ~= "https://" 
	then
		g_Config["url"] = ""
	end
	
	g_Config["interval"] = math.floor(g_Config["interval"] * 1000)
end

function Servers_OnServersQueryResponse(p_Status, p_Body, p_Headers, p_Error)
	if p_Status ~= 200 then
		return
	end
	
	local l_Response = json.decode(p_Body)
	
	if type(l_Response) ~= "table" or type(l_Response["servers"]) ~= "table" then
		return
	end
	
	g_Servers = {}
	
	for l_Key, l_Value in next, l_Response["servers"] do
		local l_Game = l_Value["game"]
		local l_Name = l_Value["name"]
		
		if type(l_Game) ~= "string" or #l_Game == 0 then
			l_Game = nil
		end
		
		if type(l_Name) ~= "string" or #l_Name == 0 then
			l_Name = nil
		end
		
		if l_Name and l_Game then
			local l_Ip = l_Value["ip"]
			local l_Port = l_Value["port"]
			local l_Players = type(l_Value["query"]) == "table" and tonumber(l_Value["query"]["players"]) or nil
			local l_MaxPlayers = tonumber(l_Value["maxplayers"])
			local l_IsOnline = l_Value["is_online"]
			local l_Map = type(l_Value["query"]) == "table" and l_Value["query"]["map"] or nil
			local l_Mode = l_Value["mode"]
			
			if type(l_Ip) ~= "string" then
				l_Ip = nil
			end
			
			if type(l_Port) ~= "string" then
				l_Port = nil
			end
			
			if not l_Players then
				l_Players = 0
			end
			
			if not l_MaxPlayers then
				l_MaxPlayers = 0
			end
			
			if type(l_Map) ~= "string" then
				l_Map = ""
			end
			
			if type(l_Mode) ~= "string" then
				l_Mode = ""
			end
			
			local l_Index = Servers_GetServerIndex(l_Name, l_Players, l_IsOnline)
			
			if l_Index > #g_Servers then
				table.insert(g_Servers, 0)
			else
				table.insert(g_Servers, l_Index, 0)
			end
			
			g_Servers[l_Index] = {
				["game"] = l_Game,
				["name"] = l_Name,
				["ip"] = l_Ip,
				["port"] = l_Port,
				["players"] = l_Players,
				["maxplayers"] = l_MaxPlayers,
				["is_online"] = l_IsOnline,
				["map"] = l_Map,
				["mode"] = l_Mode
			}
		end
	end
end

function Servers_QueryServers()
	if #g_Config["url"] == 0 or #g_Config["method"] == 0 then
		return
	end
	
	local l_ServerTime = math.floor(server:GetCurrentTime() * 1000)
	
	if g_ServersQueryTime and g_ServersQueryTime + g_Config["interval"] > l_ServerTime then
		return
	end
	
	PerformHTTPRequest(g_Config["url"], Servers_OnServersQueryResponse, g_Config["method"])
	
	g_ServersQueryTime = l_ServerTime
end

function Servers_ResetVars()
	g_Servers = {}
	g_ServersQueryTime = nil
end

function Servers_Think()
	Servers_QueryServers()
end