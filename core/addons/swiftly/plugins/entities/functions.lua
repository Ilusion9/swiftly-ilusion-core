function Entities_DeleteEntity(p_EntityPtr)
	local l_Entity = CBaseEntity(p_EntityPtr)
	
	if not l_Entity or not l_Entity:IsValid() then
		return
	end
	
	local l_EntityClassname = l_Entity:GetClassname()
	
	if g_Config["delete.entities"]["c:" .. l_EntityClassname] 
		or g_Config["delete.entities"]["n:" .. l_Entity.Parent.Entity.Name] 
		or g_Config["delete.entities"]["h:" .. l_Entity.UniqueHammerID] 
	then
		l_Entity:Despawn()
	end
end

function Entities_LoadConfig()
	local l_Map = server:GetMap()
	
	config:Reload("entities")
	config:Reload("entities/" .. l_Map)
	
	g_Config = {}
	g_Config["tag"] = config:Fetch("entities.tag")
	
	if type(g_Config["tag"]) ~= "string" then
		g_Config["tag"] = "[Entities]"
	end
	
	Entities_LoadDeleteEntites()
end

function Entities_LoadDeleteEntites()
	g_Config["delete.entities"] = {}
	
	local l_Map = server:GetMap()
	local l_Entities = config:Fetch("entities." .. l_Map .. ".delete")
	
	if type(l_Entities) ~= "table" then
		l_Entities = {}
	end
	
	for i = 1, #l_Entities do
		local l_Classname = l_Entities[i]["classname"]
		local l_Name = l_Entities[i]["name"]
		local l_Hammer = l_Entities[i]["hammer"]
		
		if type(l_Classname) ~= "string" or #l_Classname == 0 then
			l_Classname = nil
		end
		
		if type(l_Name) ~= "string" or #l_Name == 0 then
			l_Name = nil
		end
		
		if type(l_Hammer) ~= "number" and (type(l_Hammer) ~= "string" or #l_Hammer == 0) then
			l_Hammer = nil
		end
		
		if l_Classname then
			g_Config["delete.entities"]["c:" .. l_Classname] = true
		elseif l_Name then
			g_Config["delete.entities"]["n:" .. l_Name] = true
		elseif l_Hammer then
			g_Config["delete.entities"]["h:" .. tostring(l_Hammer)] = true
		end
	end
end

function Entities_ResetPlayerVars(p_PlayerId)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player then
		return
	end
	
	l_Player:SetVar("entities.inputs", nil)
	l_Player:SetVar("entities.outputs", nil)
end

function Entities_ShowPlayerEntityInput(p_PlayerId, p_EntityPtr, p_Input)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerInputs = l_Player:GetVar("entities.inputs")
	
	if not l_PlayerInputs then
		return
	end
	
    local l_Entity = CBaseEntity(p_EntityPtr)
    
    if not l_Entity or not l_Entity:IsValid() then
        return
    end
    
	local l_EntityClassname = l_Entity:GetClassname()
	
	l_Player:SendMsg(MessageType.Console, string.format("%s [Input] Classname \"%s\" - Input \"%s\" - Name \"%s\" - Hammer \"%s\"", g_Config["tag"], l_EntityClassname, p_Input, l_Entity.Parent.Entity.Name, l_Entity.UniqueHammerID))
end

function Entities_ShowPlayerEntityOutput(p_PlayerId, p_EntityPtr, p_Output)
	local l_Player = GetPlayer(p_PlayerId)
	
	if not l_Player or not l_Player:IsValid() then
		return
	end
	
	local l_PlayerOutputs = l_Player:GetVar("entities.outputs")
	
	if not l_PlayerOutputs then
		return
	end
	
    local l_Entity = CBaseEntity(p_EntityPtr)
    
    if not l_Entity or not l_Entity:IsValid() then
        return
    end
    
	local l_EntityClassname = l_Entity:GetClassname()
	
	l_Player:SendMsg(MessageType.Console, string.format("%s [Output] Classname \"%s\" - Output \"%s\" - Name \"%s\" - Hammer \"%s\"", g_Config["tag"], l_EntityClassname, p_Output, l_Entity.Parent.Entity.Name, l_Entity.UniqueHammerID))
end
