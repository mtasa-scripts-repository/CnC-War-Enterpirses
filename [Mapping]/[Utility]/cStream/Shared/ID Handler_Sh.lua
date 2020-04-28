idIndex = {}
idIndex['Useable'] = 0
idIndex['Alpha'] = 0

-- Tables --
global = {}
idused = {}

-- Functions --
function readFile()
	local File =  fileOpen('Shared/IDs.ID')   
	local Data =  fileRead(File, fileGetSize(File))
	 fileClose ( File)
	return split(Data,10)
end

function index(table,name)
	local placeholder = {}
	for i,v in pairs(table) do
		local split = split(v,",")
		placeholder[tonumber(split[1])] = split[2]
		placeholder[split[2]] = split[1]
	end
	global[name] = placeholder
end

alphaList = {}
alphaList['immy_clothes_sv'] = true
alphaList['svcuntflorday'] = true
alphaList['svvgmdshadfloor'] = true
alphaList['svlabigkitchshad'] = true
alphaList['svlabigbits'] = true
alphaList['svlasmshad'] = true
alphaList['svsfsmshad'] = true
alphaList['svsfsmshadfloor2'] = true
alphaList['bihotelshad'] = true
alphaList['svsfmdshadflr1'] = true
alphaList['svlamidshad'] = true
alphaList['lamidshadflr'] = true
alphaList['svmidsavebits'] = true
alphaList['svrails'] = true
alphaList['int_tatooA01'] = true
alphaList['int_tatooA02'] = true
alphaList['int_tatooA03'] = true
alphaList['hotelferns1_LAn'] = true
alphaList['int_tatooA06'] = true
alphaList['int_tatooA07'] = true
alphaList['int_tatooA09'] = true
alphaList['int_tatooA11'] = true
alphaList['int_tatooA12'] = true
alphaList['int_tatooA14'] = true
alphaList['int_7_11A40_bits'] = true
alphaList['int_7_11A41_bits'] = true



function trim1(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function alphaS(strin)
	for i,v in pairs(alphaList) do
		
		local _, n = string.gsub (strin, i, "")
		if n > 0 then
			return true
		end
	end
end

function indexUsables(table,name,alpha)
	local placeholder = {}
	count = 0
	for i,v in pairs(table) do
		local split = split(v,",")
		if alphaS(split[2]) then
			if alpha then
				count = count + 1
				placeholder[count] = {tonumber(split[1]),split[2]}
			end
		else
			if not alpha then
				count = count + 1
				placeholder[count] = {tonumber(split[1]),split[2]}
			end
		end
	end
	global[name] = placeholder
end

index(readFile(),'EveryID') 
indexUsables(readFile(),'Useable')
indexUsables(readFile(),'Alpha',true)

function getModelFromID(id)
	return global['EveryID'][id]
end

function getFreeID(name,flag,looped)
	if data.id[name] then
		return data.id[name] -- If id is already assigned then just send back that ID
	else
		idIndex[flag or 'Useable'] = idIndex[flag or 'Useable'] + 1
		if not global[flag or 'Useable'][idIndex[flag or 'Useable']] then
			if (idIndex[flag or 'Useable'] == #global[flag or 'Useable']) and looped then
				print('dStream:','Out of IDs')
				return
			else
				idIndex[flag or 'Useable'] = 0
				return getFreeID(name,flag,true)
			end
		end
			
		if not idused[global[flag or 'Useable'][idIndex[flag or 'Useable']][1]] then
			return global[flag or 'Useable'][idIndex[flag or 'Useable']][1]
		else
			return getFreeID(name,flag,looped)
		end
	end
end
