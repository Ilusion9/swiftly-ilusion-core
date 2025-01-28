function Commands_LoadConfig()
	config:Reload("commands")
	
	g_Config = {}
	
	Commands_LoadBlockCommands()
end

function Commands_LoadBlockCommands()
	g_Config["block.commands"] = {}
	
	local l_Commands = config:Fetch("commands.block")
	
	if type(l_Commands) ~= "table" then
		l_Commands = {}
	end
	
	for i = 1, #l_Commands do
		local l_Command = l_Commands[i]
		
		if type(l_Command) ~= "string" or #l_Command == 0 then
			l_Command = nil
		end
		
		if l_Command then
			g_Config["block.commands"][l_Command] = true
		end
	end
end