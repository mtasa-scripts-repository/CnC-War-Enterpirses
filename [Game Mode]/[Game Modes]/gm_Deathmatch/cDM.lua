-- Tables --
images = {}
hitVeh = {}
Score = {}

-- Values --
setBlurLevel (0)
xSize, ySize = guiGetScreenSize()
s = (1/1920)*xSize
Size = 1
Min,Sec = 0,0
slide = 0
count = 0

-- Gen Functions --
function prepImage(path,mip)
	images[path] = images[path] or dxCreateTexture(path,'dxt5',mip)
	return images[path]
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
		dxDrawText ( 'Death Match',x,y,xa,ya, tocolor ( 255, 255, 255, 150 ), 2*s, "default",'center','center' )
		
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

		local x,y,xs,ys = ((xSize/2)-(300*s))*slie,(ySize/2)+(202*s),600*s,200*s
		dxDrawRectangle (x,y,xs,ys,tocolor(0,0,0,150))
		
		local x,y,xa,ya = rectotext (x,y+(10*s),xs,ys)
		if team == 'Red' then
			dxDrawText ( 'Kill the opposing team members\n in order to score points.\n\n Score 50 points to win.',x,y,xa,ya, tocolor ( 255, 255, 255, 150 ), 1.6*s, "default",'center','top' )
		else
			dxDrawText ( 'Kill the opposing team members\n in order to score points.\n\n Score 50 points to win the match.',x,y,xa,ya, tocolor ( 255, 255, 255, 150 ), 1.6*s, "default",'center','top' )
		end
	else
		count = nil
		if getElementData(localPlayer,'Camera') and (not getElementData(localPlayer,'Freecam'))  then
			setElementData(localPlayer,'Camera',false)
		end
	end
end

addEventHandler ( "onClientRender", root, handleFade )
