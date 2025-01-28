function Files_LoadConfig()
	config:Reload("files")
	
	Files_LoadDeleteFiles()
end

function Files_LoadDeleteFiles()
	local l_Files = config:Fetch("files.delete")
	
	if type(l_Files) ~= "table" then
		l_Files = {}
	end
	
	for i = 1, #l_Files do
		local l_File = l_Files[i]
		
		if type(l_File) ~= "string" or #l_File == 0 then
			l_File = nil
		end
		
		if l_File then
			files:Delete(l_File)
		end
	end
end