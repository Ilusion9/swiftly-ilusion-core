function Filters_IsValidChat(p_Str)
	local l_Str = string.lower(exports["helpers"]:StringReplace(p_Str, " ", ""))
	
	for i = 1, #g_Config["chat.filters"] do
		if string.find(l_Str, g_Config["chat.filters"][i], 1, true) then
			return false
		end
	end
	
	return true
end

function Filters_IsValidName(p_Str)
	local l_Str = string.lower(exports["helpers"]:StringReplace(p_Str, " ", ""))
	
	if g_Config["name.utf"] and not exports["helpers"]:IsStringUTF8(l_Str) then
		return false
	end
	
	for i = 1, #g_Config["name.filters"] do
		if string.find(l_Str, g_Config["name.filters"][i], 1, true) then
			return false
		end
	end
	
	return true
end

function Filters_LoadConfig()
	config:Reload("filters")
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("filters.tag")
	g_Config["name.utf"] = config:Fetch("filters.name.utf")
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Filter]"
	end
	
	if type(g_Config["name.utf"]) ~= "boolean" then
		g_Config["name.utf"] = tonumber(g_Config["name.utf"])
		g_Config["name.utf"] = g_Config["name.utf"] and g_Config["name.utf"] ~= 0
	end
	
	Filters_LoadChatFilters()
	Filters_LoadNameFilters()
end

function Filters_LoadChatFilters()
	g_Config["chat.filters"] = {}
	
	local l_Filters = config:Fetch("filters.chat.filters")
	
	if type(l_Filters) ~= "table" then
		l_Filters = {}
	end
	
	for i = 1, #l_Filters do
		local l_Filter = l_Filters[i]
		
		if type(l_Filter) ~= "string" or #l_Filter == 0 then
			l_Filter = nil
		end
		
		if l_Filter then
			table.insert(g_Config["chat.filters"], string.lower(l_Filter))
		end
	end
end

function Filters_LoadNameFilters()
	g_Config["name.filters"] = {}
	
	local l_Filters = config:Fetch("filters.name.filters")
	
	if type(l_Filters) ~= "table" then
		l_Filters = {}
	end
	
	for i = 1, #l_Filters do
		local l_Filter = l_Filters[i]
		
		if type(l_Filter) ~= "string" or #l_Filter == 0 then
			l_Filter = nil
		end
		
		if l_Filter then
			table.insert(g_Config["name.filters"], string.lower(l_Filter))
		end
	end
end

function Filters_ValidatePlayerName(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerName = exports["helpers"]:GetPlayerName(p_PlayerId)
	
	if Filters_IsValidName(l_PlayerName) then
		return
	end
	
	exports["helpers"]:ChangePlayerName(p_PlayerId, "Player " .. p_PlayerId)
end