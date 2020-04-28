-- Tables --
lSecession.Properties = {}

-- Functions
functions.loadProperties = function(property)
	if property then
		if fileExists('Lists/Property Lists/'..property..'.txt') then
			return fileOpen('Lists/Property Lists/'..property..'.txt')
		end
	end
end

functions.prepProperties = function(property)
	if not lSecession.Properties[property] then
		local file = functions.loadProperties(property)
		if file then 
			lSecession.Properties[property] = {}
			local Data =  fileRead(file, fileGetSize(file))
			local Proccessed = split(Data,10)
			for i,v in pairs(Proccessed) do
				local splitA = split(vA,",")
				lSecession.Properties[property][splitA[1]] = splitA
			end
			fileClose (file)
		end
	end
end

functions.fetchProperties = function (property)
	functions.prepProperties(property)
	if lSecession.Properties[property] then
		if lSecession.Properties[property] then
			return functions.client(client,'retreiveProperties',i,property,lSecession.Properties[property])
		end
	end
end

