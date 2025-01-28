function Usermessages_LoadConfig()
	config:Reload("usermessages")
	
	g_Config = {}
	
	Usermessages_LoadBlockMessages()
end

function Usermessages_LoadBlockMessages()
	g_Config["block.messages"] = {}
	
	local l_UserMessages = config:Fetch("usermessages.block")
	
	if type(l_UserMessages) ~= "table" then
		l_UserMessages = {}
	end
	
	for i = 1, #l_UserMessages do
		local l_Id = tonumber(l_UserMessages[i]["id"])
		
		if not l_Id or l_Id < 1 then
			l_Id = nil
		end
		
		if l_Id then
			g_Config["block.messages"][l_Id] = true
		end
	end
end