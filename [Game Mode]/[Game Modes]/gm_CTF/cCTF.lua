-- Tables --
images = {}
hitVeh = {}
Score = {}

-- Values --
setBlurLevel (0)
xSize, ySize = guiGetScreenSize()
s = (1/1920)*xSize
DIS = 0
Size = 1
Flash = 1
Reverse = 0.03
FReverse = 0.05
Min,Sec = 10,60
refresh = 0
slide = 0
count = 0

-- Gen Functions --
function prepImage(path,mip)
	images[path] = images[path] or dxCreateTexture(path,'dxt5',mip)
	return images[path]
end

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end

function getSpeed(element)
	local speedx, speedy, speedz = getElementVelocity (element)
	local speed = (speedx^2 + speedy^2 + speedz^2)^(0.5)
	return speed* 50
end

function rectotext (x,y,xs,ys)
	return x,y,x+xs,y+ys
end

-- Other functions --
function getScore(Team)
	Score[Team] = 0 
	for i,v in pairs(getElementsByType('player')) do
		if getElementData(v,'Team') == Team then
			Score[Team] = Score[Team] + getElementData(v,'Score')
		end
	end
end

function handleFade()
	Sec = Sec + 0.01
	if Sec > 60 then
		Min = Min+1
		Sec = 0
	end
	
	local x,y,xs,ys = (xSize/2)-(34*s),2*s,(68*s),(58*s)
	local x,y,xa,ya = rectotext (x,y,xs,ys)
	
	local x,y,xs,ys = (xSize/2)-(95*s),(1*s),60*s,60*s
	dxDrawImage ( x,y,xs,ys,'Content/Objective.png', 0, 0, 0,tocolor(255,255,255,40) )
			
	local x,y,xs,ys = (xSize/2)+(35*s),(1*s),60*s,60*s
	dxDrawImage ( x,y,xs,ys,'Content/Guard.png', 0, 0, 0,tocolor(255,255,255,40) )
	
	count = count or getElementData(localPlayer,'Fade')
	if getElementData(localPlayer,'Fade') then
		slide = math.min(slide + 3,100)
	else
		slide = math.max(slide - 4,0)
	end
	
	local xb,yb,zb = getElementPosition(localPlayer)

	setPedTargetingMarkerEnabled(false)
	
	if getElementData(localPlayer,'Flag') then
		dxDrawText ('Hit ['..(getElementData(localPlayer,'Interact') or 'e')..'] to pickup flag.',xSize/2,ySize/2,xSize/2,ySize/2,tocolor(255,255,255,80), 1, 2, "clear",'center','center',false,false,false,true )
		if getKeyState((getElementData(localPlayer,'Interact') or 'e')) then
			setElementData(localPlayer,'pickup',true)
		else
			setElementData(localPlayer,'pickup',nil)
		end
	end
	
	for i,v in pairs(getElementsByType('player')) do
		setPlayerNametagShowing(v,false)
		if (v == localPlayer) then
			if getElementData(v,'Show Marker') then
				local show = tonumber(getElementData(v,'Show Marker')) or 0

				setElementData(v,'Show Marker',math.max(show-1,0))
			else
				setElementData(v,'Show Marker',0)
			end
		end
		
		if not (localPlayer == v) then
		
			local x,y,z = getElementPosition(v)
			local xa,ya = getScreenFromWorldPosition ( x,y,z+1.1,0.1,false)
			local color = ((getElementData(v,'Team') == 'Red') and {255,0,0} or {0,0,255})
			local distance = getDistanceBetweenPoints3D (x,y,z,xb,yb,zb) 
			
			local maxDistance = getElementData(v,'Team') == getElementData(localPlayer,'Team') and 100 or 30
			if (distance < maxDistance) then
				if isLineOfSightClear(xb,yb,zb,x,y,z+1,true,false,false) then
					local up = distance
					local size = (maxDistance-distance)/maxDistance
					if xa then
						local colorCode = ((getElementData(v,'Team') == 'Red') and '#FF0000' or '#0000ff')
						if getElementData(v,'Team') == getElementData(localPlayer,'Team') then
							dxDrawText (getPlayerName(v)..' | '..colorCode..getElementData(v,'Team'),xa,ya-up,xa,ya-up,tocolor(255,255,255,180), 1, 1.5*size, "clear",'center','center',false,false,false,true )
						else
							dxDrawText (getPlayerName(v)..' | '..colorCode..getElementData(v,'Team'),xa,ya-up,xa,ya-up,tocolor(255,255,255,80), 1, 1*size, "clear",'center','center',false,false,false,true )
						end
					end
				end
			end
			
			local alpha = ((getElementData(v,'Team') == getElementData(localPlayer,'Team')) and 150 or 0) + (tonumber(getElementData(v,'Show Marker') or 0)*3)
			
			if alpha > 0 then
				local x,y,z = getElementPosition(v)

				dxDrawMaterialLine3D(x,y,z+1.1+0.5,x,y,z+1.1,prepImage('Content/player.png'),0.5,tocolor(color[1],color[2],color[3],alpha))
			end
		end
	end
	
	if (slide > 0) then 
		
		local slie = slide/100

		local team = getElementData(localPlayer,'Team')
		
		local color = (team == 'Red') and tocolor(255,0,0,60) or tocolor(0,0,255,60)
		
		local x,y,xs,ys = ((xSize/2)-(300*s))*slie,(ySize/2)+(150)*s,250*s,51*s
		dxDrawRectangle (x,y,xs,ys,tocolor(0,0,0,80))
		dxDrawRectangle ((x+(1*s)),(y+(1*s)),(xs-(2*s)),(ys-(2*s)),color)
		local x,y,xa,ya = rectotext (x,y,xs,ys)
		dxDrawText ( 'Capture The Flag',x,y,xa,ya, tocolor ( 255, 255, 255, 150 ), 2*s, "default",'center','center' )
		
		local x,y,xs,ys = ((xSize/2)+(50*s))*slie,(ySize/2)+(150*s),250*s,51*s
		dxDrawRectangle (x,y,xs,ys,tocolor(0,0,0,80))
		dxDrawRectangle ((x+1),(y+1),(xs-2),(ys-2),color)
		local x,y,xa,ya = rectotext (x,y,xs,ys)
		dxDrawText ( team..' Team',x,y,xa,ya, tocolor ( 255, 255, 255, 150 ), 2*s, "default",'center','center' )

		local x,y,xs,ys = ((xSize/2)-(50*s))*slie,(ySize/2)+(150*s),100*s,51*s
		dxDrawRectangle (x,y,xs,ys,tocolor(0,0,0,80))
		local x,y,xa,ya = rectotext (x,y,xs,ys)
		
		local dif = (ys-xs)
		
		
		local xb,yb,xsb,ysb = ((xSize/2)-(25*s))*slie,(ySize/2)+(150*s),50*s,50*s
		dxDrawImage ( xb,yb,xsb,ysb, (team == 'Red') and 'Content/Objective.png' or  'Content/Guard.png', 0, 0, 0,tocolor(255,255,255,40) )
		
		
		local counta = (count / 100)
		dxDrawText ( math.floor(counta),x,y,xa,ya, tocolor ( 255, 255, 255, 150 ), 2*s, "default",'center','center' )
		
		count = count - 1
		
		if count < 0 then
			count = 0
		end

		local x,y,xs,ys = ((xSize/2)-(300*s))*slie,(ySize/2)+(202*s),600*s,200*s
		dxDrawRectangle (x,y,xs,ys,tocolor(0,0,0,150))
		
		local x,y,xa,ya = rectotext (x,y+(10*s),xs,ys)
		if team == 'Red' then
			dxDrawText ( 'Capture the blues flag and return it to your base in order\n to gain the most points,\n\nCapture 10 flags to win.',x,y,xa,ya, tocolor ( 255, 255, 255, 150 ), 1.6*s, "default",'center','top' )
		else
			dxDrawText ( 'Capture the reds flag and return it to your base in order\n to gain the most points,\n\nCapture 10 flags to win.',x,y,xa,ya, tocolor ( 255, 255, 255, 150 ), 1.6*s, "default",'center','top' )
		end
	else
		count = nil
		if getElementData(localPlayer,'Camera') and (not getElementData(localPlayer,'Freecam'))  then
			setElementData(localPlayer,'Camera',false)
		end
	end
end

function getObjective(oType,ID,Team)
	for i,v in pairs(getElementsByType('object')) do
		if (getElementData(v,'eType') == 'Objective') then
			if (getElementData(v,'Obj Type') == oType) and (getElementData(v,'Team') == Team) and (getElementData(v,'Obj ID') == ID) then
				local x,y,z = getElementPosition(v)
				return x,y,z,v
			end
		end
	end
end

Objects = {}

function getObject (eID)
	if Objects[eID] then
		return Objects[eID]
	else
		for i,v in pairs(getElementsByType('object')) do
			if (getElementID(v) == eID) then
				Objects[eID] = v
				return v
			end
		end
	end
end

function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z                               -- Return the transformed point
end


function handleFlag(Team)
	local xa,ya,za,object = getObjective('Flag Spawn',1,Team)
	
	local flag_Top = getObject ('Flag_Top_'..Team)
			
	local flag_Bottom = getObject ('Flag_Bottom_'..Team)
	
	if object then
		if isElement(getElementData(object,'Holder')) then
			local holder = getElementData(object,'Holder')
			
			local x,y,z = getPedBonePosition(holder,51)
			
			local xC,yC = getElementPosition(holder)
			local xB,yB = getPositionFromElementOffset(holder,0,-0.25,0.1)
			
			local xC = (xB-xC)
			local yC = (yB-yC)
			
			setElementPosition(object,x+xC,y+yC,z)
			
			local _,_,zr = getElementRotation(holder)
			setElementRotation(flag_Top,0,0,zr+90)
			setElementRotation(flag_Bottom,0,0,zr+90)
			
			if getLowLODElement (flag_Top) and getLowLODElement (flag_Bottom) then
				setElementRotation(getLowLODElement(flag_Top),0,0,zr+90)
				setElementRotation(getLowLODElement(flag_Bottom),0,0,zr+90)
			end
		else
			local hit, x, y, z, elementHit = processLineOfSight ( xa,ya,za+5,xa,ya,za-10,true,false,false )
			if hit then
				setElementPosition(object,x,y,z)
			end
		end
	end
	
	local xa,ya,za = getElementPosition(object)
	
	setElementPosition(flag_Top,xa,ya,za)
	setElementPosition(flag_Bottom,xa,ya,za)
	
	if getLowLODElement (flag_Top) and getLowLODElement (flag_Bottom) then
		setElementPosition(getLowLODElement(flag_Top),xa,ya,za)
		setElementPosition(getLowLODElement(flag_Bottom),xa,ya,za)
	end
	
	local hold = getElementData(object,'Holder') 
	
	
	Size = Size + Reverse
		
	if (Size > 0.5) and (Reverse > 0) then
		Reverse = -0.004
	elseif Size < 0 then
		Reverse = 0.004
	end
		
	Flash = Flash + FReverse
		
	if (Flash > 1) and (FReverse > 0) then
		FReverse = -0.02
	elseif Flash < 0 then
		FReverse = 0.02
	end
		
		
	if hold then
		if (Team == 'Red') then
			local x,y,xs,ys = (0*s),ySize-(300*s),200*s,200*s
			dxDrawImage ( x,y,xs,ys,'Content/Objective.png', 0, 0, 0,tocolor(255,0,0,((hold == localPlayer) and 80 or 50)*Flash) )
		else
			local x,y,xs,ys = (0*s),ySize-(600*s),200*s,200*s
			dxDrawImage ( x,y,xs,ys,'Content/Objective.png', 0, 0, 0,tocolor(0,0,255,((hold == localPlayer) and 80 or 50)*Flash) )
		end
	end
		
		
	if (hold == localPlayer) then
		
		local x,y,z = getObjective('Flag Capture',1,getElementData(localPlayer,'Team'))
		
		dxDrawMaterialLine3D(x,y,z+10+20+Size,x,y,z+2+Size+20,prepImage('Content/Guard.png'),8,tocolor(255,0,0,150))
	end
end


function updateCamera ()
	handleFlag('Blue')
	handleFlag('Red')

	handleFade()
end
addEventHandler ( "onClientRender", root, updateCamera )
