Aim = {}

function progress (  )
	for i,v in pairs(getElementsByType('player')) do
		if isElement(getElementData(v,'Ped')) then
			local ped = getElementData(v,'Ped')
			
			if (getElementHealth(v) < 5) then
				setElementAlpha(ped,0)
			else
				setElementAlpha(ped,255)
			end
			
			if (v == localPlayer) then
				setElementStreamable(ped,false)
			end
			
			setElementModel(ped,getElementModel(v))
			
			setElementData(ped,'Legs',v)
			setElementCollidableWith(v,ped,false)
			setElementDoubleSided(v,true)
			if (getElementData(v,'State.Weapon')) then
				if (not Aim[v]) then
					setElementFrozen(ped,false)
					local x,y,z = getElementPosition(v)
					local xr,yr,zr = getElementRotation(v)
					setElementPosition(ped,x,y,z,false)
					setElementRotation(ped,xr,yr,zr)
					Aim[v] = true
					if (not isElementAttached(ped)) then
						attachElements(ped,v)
					end
				end
				
				local _,_,zrA = getElementRotation(ped)
				local xr,yr,zr = getElementRotation(v)
				local zr = getElementData(v,'Rot')
				local rot = (getElementData(v,'rotate')) and 0 or 0
					
				setElementRotation(v,xr,yr,zr-rot,'default',true)

				local zr = blendRot (zrA,zr,15,1)
				setElementRotation(ped,xr,yr,zr,'default',true)
				
			else
				Aim[v] = nil
			end
		end
	end
end
addEventHandler ( "onClientPreRender", root, progress,false,"high+6" )
