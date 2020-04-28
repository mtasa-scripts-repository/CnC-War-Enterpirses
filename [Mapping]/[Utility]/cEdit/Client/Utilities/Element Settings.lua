-- Basic Settings --
functions.getSetting = function(element,sType,setting)
	if element then
		if sType == 'data' then
			return getElementData(element,setting)
		else
			if mGet[sType] then
				return mGet[sType](element)
			end
		end
	end
end

functions.isSetting = function(sType,setting,expectedValue)
	for i,v in pairs(lSecession.Selected) do
		if (functions.getSetting(v,sType,setting)) then
			return true
		end
	end
end


functions.findSetting = function(sType,setting)
	local value = functions.getSetting(lSecession.Selected[1],sType,setting)
	if #lSecession.Selected > 1 then
		for i,v in pairs(lSecession.Selected) do
			if not (toJSON(functions.getSetting(v,sType,setting)) == toJSON(value)) then
				return ' '
			end
		end
	end
	return value
end

functions.setGElementData = function(sIndex,sData)
	for i,v in pairs(lSecession.Selected) do
		setElementData(v,sIndex,sData)
	end
end

functions.prepCustomization = {}


--'Number Box', 'Name'
--'Check Box', 'Name'
--'Text Box', 'Name'
--'Option', 'Name',{Options}}
--'Side Option' 'Name', {Options}
--'Color Picker', 'Name', {r,g,b,a}

--lSecession.variables['Name'] = {functions.findSetting('Name')}


--'Space' -- Blank space 
functions.prepCustomization.Main = function ()
	lSecession.CGo = nil
	menus.right.items['Customize'] = {}
	
	--table.insert(menus.right.items['Customize'],{'list','Generic'})
	--menus.right['Customize'].lists['Generic'] = {}

	for i,v in pairs(functions.prepCustomization) do
		if (functions.findSetting('data','eType') == i) then
			v()
		end
	end
	functions.finalizeCustomization()
end

functions.findTable = function (tabl,name)
	for i,v in pairs(tabl) do
		if v == name then
			return i
		end
	end
end

lSecession.cDefaults = {}

functions['Copy Table'] = function (inTable)
	local outTable = {}
	for i,v in pairs(inTable or {}) do
		outTable[i] = v
	end
	return outTable
end


functions.finalizeCustomization = function () -- // System did not work as intended.
	lSecession.CItems = {} -- Grabs a list of defaults, indexes it by type.
	for i,v in pairs(menus.right.items['Customize']) do
		if v[1] == 'list' then
			for ia,va in pairs(menus.right['Customize'].lists[v[2]]) do
				lSecession.CItems[va[1]] = lSecession.CItems[va[1]] or {}
				lSecession.CItems[va[1]][va[2]] = functions['Copy Table'](lSecession.variables[va[2]])
			end
		else
			lSecession.CItems[v[1]] = lSecession.CItems[v[1]] or {}
			lSecession.CItems[v[1]][v[2]] = functions['Copy Table'](lSecession.variables[v[2]])
		end
	end
	lSecession.CGo = true
end

mRender.updateSettings = function()
	if lSecession.CGo then
		for sIndex,sList in pairs(lSecession.CItems) do
			for iIndex,iTable in pairs(sList) do
				if sIndex == 'Color Picker' then
					local r,g,b = unpack(iTable[iIndex] or {})
					local ra,ga,ba = unpack(lSecession.variables[iIndex] or {})
					if ra and ga and ba then
						if not (r == ra) or not (g == ga) or not (b == ba) then
							functions.setGElementData(iIndex,{ra,ga,ba})
							iTable[iIndex] = {ra,ga,ba}
						end
					end
				else
					
					if not (iTable[1] == ((lSecession.variables[iIndex] or {})[1])) then
						print(iIndex)
						functions.setGElementData(iIndex,(lSecession.variables[iIndex] or {})[1])
						lSecession.CItems[sIndex][iIndex] = (lSecession.variables[iIndex] or {})
					end
				end
			end
		end
	end
end



