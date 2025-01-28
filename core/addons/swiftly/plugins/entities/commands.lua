AddEventHandler("Help_OnGetCommands", function(p_Event)
	local l_Commands = p_Event:GetReturn() or {}
	
	l_Commands["entity_inputs"] = {
		["permission"] = "rcon",
		["description"] = "Shows entity inputs",
		["usage"] = "sw_entity_inputs"
	}
	
	l_Commands["entity_outputs"] = {
		["permission"] = "rcon",
		["description"] = "Shows entity outputs",
		["usage"] = "sw_entity_outputs"
	}
	
	p_Event:SetReturn(l_Commands)
end)

commands:Register("entity_inputs", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "rcon") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	local l_PlayerInputs = l_Player:GetVar("entities.inputs")
	
	if l_PlayerInputs then
		l_Player:SetVar("entities.inputs", nil)
		
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", "Entity inputs {lightred}OFF{default}")
	else
		l_Player:SetVar("entities.inputs", true)
		
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", "Entity inputs {lime}ON{default}")
	end
end)

commands:Register("entity_outputs", function(p_PlayerId, p_Args, p_ArgsCount, p_Silent, p_Prefix)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	if not exports["admin"]:HasPlayerPermission(p_PlayerId, "rcon") then
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lightred}" .. g_Config["tag"] .. "{default}", "You do not have access to this command")
		return
	end
	
	local l_PlayerOutputs = l_Player:GetVar("entities.outputs")
	
	if l_PlayerOutputs then
		l_Player:SetVar("entities.outputs", nil)
		
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", "Entity outputs {lightred}OFF{default}")
	else
		l_Player:SetVar("entities.outputs", true)
		
		exports["helpers"]:ReplyToCommand(p_PlayerId, "{lime}" .. g_Config["tag"] .. "{default}", "Entity outputs {lime}ON{default}")
	end
end)
