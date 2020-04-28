
Count = 0
CountB = 200

Aim = {}

local screenWidth, screenHeight = guiGetScreenSize() 

attatched = {}

function progress (  )
	for i,v in pairs(getElementsByType('player')) do
		if isElement(getElementData(v,'Ped')) then
			local ped = getElementData(v,'Ped')
			if isElementStreamedIn(v) and (getElementData(v,'Upper.Allow')) then
				if (v == localPlayer) then
					setElementStreamable(ped,false)
				end

				setElementModel(ped,getElementModel(v))
				
				setElementData(ped,'Legs',v)
				setElementCollidableWith(v,ped,false)
				setElementDoubleSided(v,true)
				if (not Aim[v]) then
					setElementFrozen(ped,false)
					local x,y,z = getElementPosition(v)
					local xr,yr,zr = getElementRotation(v)
					setElementPosition(ped,x,y,z,false)
					setElementPosition(ped,xr,yr,zr,false)
					Aim[v] = true
					attachElements(ped,v)
				end
					
				local _,_,zrA = getElementRotation(ped)
				local xr,yr,zr = getElementRotation(v)
				local zr = getElementData(v,'Rot')
				local rot = (getElementData(v,'rotate')) and 0 or 0
						
				setElementRotation(v,xr,yr,zr-rot,'default',true)

				local zr = blendRotation (zrA,zr,15,1)
				setElementRotation(ped,xr,yr,zr,'default',true)
				
				local _,_,bz = getPedBonePosition ( v,3 )
				local x,y,z = getElementPosition(v)
				local zc = z-bz
				
				local _,_,bz = getPedBonePosition ( ped,3 )
				local px,py,pz = getElementPosition(ped)
				local zd = pz-bz
				local diff = zc-zd
				
				setElementAttachedOffsets(ped,0,0,diff)

				
			else
				if Aim[v] then
					setElementFrozen(ped,true)
					setElementPosition(ped,0,0,0)
				end
			end
		end
	end
end
addEventHandler ( "onClientPreRender", root, progress,false,"high+6" )
