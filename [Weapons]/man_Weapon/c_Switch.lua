

weaponList = {'Weapon_Primary','Weapon_Secoundary',false}
weaponSize  = {}
weaponSize['Pistol'] = 'Small'
weaponSize['Sniper'] = 'Large'
weaponSize['Rocket Launcher'] = 'Massive'


selected = false
function onPlayerScroll(button, press)
	if getElementData(localPlayer,'Reload') then return end
	if ((not isCursorShowing()) and (not isMTAWindowActive())) and (getElementHealth(localPlayer) > 5) then
		if (press) then

			for i,v in pairs(weaponList) do
				if (v == selected) then
					index = i
				end
			end
			index = index or 3
			
			if (button == (getElementData(localPlayer,'Next Weapon') or 'tab')) then
				if (index == #weaponList) then
					index = 1
				else
					index = index + 1
				end
			elseif (button == getElementData(localPlayer,'Previous Weapon')) then
				if (index == 1) then
					index = #weaponList
				else
					index = index - 1
				end
			end
			
			if weaponList[index] then
				weapon = getElementData(localPlayer,weaponList[index])
			else
				weapon = nil
			end
			
			selected = weaponList[index]

			setElementData(localPlayer,'weapon_Slot',weapon or false)
			setElementData(localPlayer,'wep.Size',weaponSize[weapon])
		end
	end
end
addEventHandler("onClientKey", root, onPlayerScroll)