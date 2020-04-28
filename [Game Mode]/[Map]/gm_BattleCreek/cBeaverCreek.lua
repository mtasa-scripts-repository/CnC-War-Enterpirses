onLadder = nil


local w, h = guiGetScreenSize ()
function updateCamera ()
	local x,y,z = getElementPosition(localPlayer)
	if z > 256 then
		setElementVelocity ( localPlayer,0,0,-10 )
	end
	
	if getPedControlState(localPlayer,'forwards') and getKeyState((getElementData(localPlayer,'Put Down Weapon') or 'space'))then

		
		local xa,ya,za = getWorldFromScreenPosition (w/2, h/2, 2)
		
		local hit,xb,yb,zb,hitElement = processLineOfSight (x,y,z,xa,ya,z,true,true,false )
		
		if hit and hitElement then
			if (getElementID(hitElement) == 'Ladder') or (getElementID(hitElement) == 'Ladder001') then
				if not onLadder then
					local x,y,z = getElementPosition(localPlayer)
					setElementPosition(localPlayer,x,y,z+0.1)
				end
				
				local sx,sy,sz = (-(x-xb))/10,(-(y-yb))/10,0.08
				
				onLadder = {sx,sy,sz,getTickCount()}
				setElementVelocity ( localPlayer,sx,sy,sz )
			end
		end
		if onLadder then
			
			local x,y,z,t = unpack(onLadder)
			setElementVelocity ( localPlayer,x,y,z )
			if (getTickCount()-(t or getTickCount())) > 600 then
				onLadder = nil
			end
		end
	end
	setWeather(12)
end
addEventHandler ( "onClientRender", root, updateCamera )