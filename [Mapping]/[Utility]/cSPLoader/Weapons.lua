
weaponStuff = {
{'Wep Type',1},
{'Weapon',1},
{'Ammo Count',1},
{'wep_Respawn',1}
}

altFunt.weapons = function(resourceName)
	if fileExists(':'..resourceName..'/CSP/Weapons.CSP') then
		local File = fileOpen(':'..resourceName..'/CSP/Weapons.CSP')
		local Data = fileRead(File, fileGetSize(File))
		local Proccessed = split(Data,10)
		fileClose (File)

		ItemList[resourceName] = ItemList[resourceName] or {}

		XA,YA,ZA = 0

		for iA,vA in pairs(Proccessed) do
			if iA == 1 then
				local x,y,z = split(vA,",")[1],split(vA,",")[2],split(vA,",")[3]
				XA,YA,ZA = tonumber(x),tonumber(y),tonumber(z)
			else
				local SplitA = split(vA,",")
				if not (SplitA[1] == '!') then
					for i=1,8 do
						if not SplitA[i] then
							print(SplitA[1],'| CSP Error')
							return
						end
					end
						
					local object = exports.cStream:CcreateObject(2996,tonumber(SplitA[2])+XA,tonumber(SplitA[3])+YA,tonumber(SplitA[4])+ZA,0,0,tonumber(SplitA[5]),resourceName)
					if not getElementData(root,'mapEditor') then
						setElementAlpha(object,0)
						setElementCollisionsEnabled(object,false)
					end
					
					count = 5
					for i,v in pairs(weaponStuff) do
						if v[2] == 3 then
							count = count + 1
							local r = SplitA[count]
							count = count + 1
							local g = SplitA[count]
							count = count + 1
							local b = SplitA[count]
							setElementData(object,v[1],{r,g,b})
						else
							count = count + 1
							local data = SplitA[count]
							setElementData(object,v[1],data)
						end
					end
					setElementData(object,'eType','Weapon')
					setElementData(object,'mID',SplitA[1])
					if object then
						table.insert(ItemList[resourceName],object)
						table.insert(Items,object)
					end
				end
			end
		end
	end
end

