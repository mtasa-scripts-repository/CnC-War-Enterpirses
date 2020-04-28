-- Tables --
functions = {}
menus = {settings = {}}
images = {}
-- Values --
xSize, ySize = guiGetScreenSize()
s = (1/1920)*xSize
menus.width = 400*s
menus.height = 45*s
menus.startHeight = (ySize/2)-(350*s)

menus.Cwidth = 520*s
menus.Cheight = ((menus.Cwidth/1920)*1080)


function prepImage(path,mip,loadImg)
	if loadImg then
		if not images[path] then
			images[path] = dxCreateTexture(path,'dxt5',mip) or true
		end
		return images[path],(not (images[path] == true))
	else
		return false
	end
end

function isCursorOnElement( posX, posY, width, height )
	if isCursorShowing( ) then
		local mouseX, mouseY = getCursorPosition( )
		local clientW, clientH = guiGetScreenSize( )
		local mouseX, mouseY = mouseX * clientW, mouseY * clientH
		if ( mouseX > posX and mouseX < ( posX + width ) and mouseY > posY and mouseY < ( posY + height ) ) then
			return true
		end
	end
	return false
end


function rectotax (x,y,xs,ys)
	return x,y,x+xs,y+ys
end

extend = 0
extend2 = 0
extend3 = 0

Lists = {}
function getTeamList(Team)
	Lists[Team] = {}
	for i,v in pairs(getElementsByType('player')) do
		if (getElementData(v,'Team') == Team) then
			table.insert(Lists[Team],{i,v})
		end
	end
	return Lists[Team]
end

function rectotext (x,y,xs,ys)
	return x,y,x+xs,y+ys
end

Votes = {}
function getVotes(Index)
	total = 0
	for i,v in pairs(Votes) do
		if isElement(i) then
			if Index == v then
				total = total + 1
			end
		else
			Votes[i] = nil
		end
	end
	return total
end

function populateList(list)
	votingList = list
end

addEvent( "sendVoting", true )
addEventHandler( "sendVoting", localPlayer, populateList )

function updateVotes(list)
	Votes = list
end

addEvent( "updateVotes", true )
addEventHandler( "updateVotes", localPlayer, updateVotes )


function updateCountDown(number)
	Count = number
end

addEvent( "updateCountDown", true )
addEventHandler( "updateCountDown", localPlayer, updateCountDown )

function removeHex (s)
    if type (s) == "string" then
        while (s ~= s:gsub ("#%x%x%x%x%x%x", "")) do
            s = s:gsub ("#%x%x%x%x%x%x", "")
        end
    end
    return s or false
end

toggled = false
function drawVoting()
	if not votingList then
		if toggled then
			showCursor(false)
			toggled = nil
		end
	
	else
		toggled = true
		showCursor(true)
		
		if Count then
			local x,y,xs,ys = xSize-(200*s),(100*s),(100*s),(100*s)
			local xB,yB,xaB,yaB = rectotax(x,y,xs,ys)
			dxDrawRectangle (x,y,xs,ys, tocolor ( 0, 0, 0, 50 ),false )
			dxDrawText(Count,xB,yB,xaB+5*s,yaB+5*s, tocolor(0, 0, 0, 100), 4*s, "default", "center", "center", false, false, false, false, false)
			dxDrawText(Count,xB,yB,xaB,yaB, tocolor(255, 255, 255, 200), 4*s, "default", "center", "center", false, false, false, false, false)
		end
		
		local extend = math.min(extend,1)
		local extend2 = math.min(extend2,1)
			
		local playerCount = 5
		
		PositionA = (ySize/2)-((playerCount+2)*(menus.height))/2
		
		local x,y,xs,ys = 60*s,PositionA,menus.width+(12*s),menus.height*0.6
		local y = (y - ys - (1*s))
		dxDrawRectangle (x,y,xs,ys, tocolor ( 0, 0, 0, 150 ),false )
		dxDrawRectangle (x+1,y+1,xs-2,ys-2, tocolor ( 255,0,0,30) ,false )
		local xB,yB,xaB,yaB = rectotax(x,y,xs,ys)
		dxDrawText('Red',xB,yB,xaB,yaB, tocolor(255, 255, 255, 100), 1.2*s, "default", "center", "center", false, false, false, false, false)
		
		local redList = getTeamList('Red')
		for i=1,#redList do
			local tabl = redList[i]
			
			local x,y,xsa,ys = (60*s),PositionA,10*s,menus.height
			dxDrawRectangle (x,y,xsa,ys, tocolor ( 0, 0, 0, 150 ),false )
			dxDrawRectangle (x,y,xsa,ys, tocolor ( 255, 0, 0, 30 ),false )
			
			local x,y,xs,ys = (61*s)+xsa,PositionA,30*s,menus.height
			dxDrawRectangle (x,y,xs,ys, tocolor ( 0, 0, 0, 150 ),false )
			local xB,yB,xaB,yaB = rectotax(x,y,xs,ys)
			dxDrawText(tabl[1],xB,yB,xaB,yaB, tocolor(255, 255, 255, 100), 1.3*s, "default", "center", "center", false, false, false, false, false)
			
			
			local x,y,xs,ys = (62*s)+xs+xsa,PositionA,menus.width-xs,menus.height
			PositionA = PositionA + ys + (1*s)
			dxDrawRectangle (x,y,xs,ys, tocolor ( 0, 0, 0, 150 ),false )
			local xB,yB,xaB,yaB = rectotax(x,y,xs,ys)		
			dxDrawText(removeHex(getPlayerName(tabl[2])),xB,yB,xaB,yaB, tocolor(255, 255, 255, 100), 1.4*s, "default", "center", "center", false, false, false, false, false)
		end
		
		local playerCount = 5
		
		PositionB = (ySize/2)-((playerCount+2)*(menus.height+1))/2
		
		local xPos = (xSize-menus.width-(12*s)-60*s)
		local x,y,xs,ys = xPos,PositionB,menus.width+(12*s),menus.height*0.6
		local y = (y - ys - (1*s))
		dxDrawRectangle (x,y,xs,ys, tocolor ( 0, 0, 0, 150 ),false )
		dxDrawRectangle (x+1,y+1,xs-2,ys-2, tocolor ( 0,0,255,30) ,false )
		local xB,yB,xaB,yaB = rectotax(x,y,xs,ys)
		dxDrawText('Blue',xB,yB,xaB,yaB, tocolor(255, 255, 255, 100), 1.2*s, "default", "center", "center", false, false, false, false, false)

		local blueList = getTeamList('Blue')
		for i=1,#blueList do
			local tabl = blueList[i]
			
			local x,y,xsa,ys = xSize-(70*s),PositionB,10*s,menus.height
			dxDrawRectangle (x,y,xsa,ys, tocolor ( 0, 0, 0, 150 ),false )
			dxDrawRectangle (x,y,xsa,ys, tocolor ( 0, 0, 255, 30 ),false )
			
			local x,y,xs,ys = x-(31*s),PositionB,30*s,menus.height
			dxDrawRectangle (x,y,xs,ys, tocolor ( 0, 0, 0, 150 ),false )
			local xB,yB,xaB,yaB = rectotax(x,y,xs,ys)
			dxDrawText(tabl[1],xB,yB,xaB,yaB, tocolor(255, 255, 255, 100), 1.3*s, "default", "center", "center", false, false, false, false, false)
			
			
			local x,y,xs,ys = xPos,PositionB,menus.width-xs,menus.height
			PositionB = PositionB + ys + (1*s)
			dxDrawRectangle (x,y,xs,ys, tocolor ( 0, 0, 0, 150 ),false )
			local xB,yB,xaB,yaB = rectotax(x,y,xs,ys)		
			dxDrawText(removeHex(getPlayerName(tabl[2])),xB,yB,xaB,yaB, tocolor(255, 255, 255, 100), 1.4*s, "default", "center", "center", false, false, false, false, false)
		end

		local centered = (xSize/2)-((menus.Cwidth/2))
		PositionC = (ySize/2)-((menus.Cheight+(menus.height/2))*((#votingList-1)/2))
		
		for i=1,#votingList do
			local tabl = votingList[i]
			
			local image,loaded = prepImage('Media/'..tabl[1]..'.png',true,tabl[2])
			
			local x,y,xs,ys = centered,PositionC,(menus.Cwidth),(menus.Cheight)-(menus.height+1)

			
			if loaded then
				dxDrawRectangle (x,y,xs,ys, tocolor ( 0, 0, 0, 100 ),false )
				dxDrawImage (x+2,y+2,xs-4,ys-4,image,0,0,0, tocolor ( 255, 255, 255, 150 ),false )
			end
			
			local x,y,xs,ys = centered,PositionC+(loaded and menus.Cheight or 0)-(loaded and menus.height or 0),menus.height,menus.height
			dxDrawRectangle (x,y,xs,ys, tocolor ( 0, 0, 0, 150 ),false )
			dxDrawRectangle (x,y,xs,ys, tocolor ( 0, 0, 0, 30 ),false )
			local xB,yB,xaB,yaB = rectotax(x,y,xs,ys)
			dxDrawText(i,xB,yB,xaB,yaB, tocolor(255, 255, 255, 100), 1.3*s, "default", "center", "center", false, false, false, false, false)
			
			local x,y,xs,ys = centered+menus.height+1,PositionC+(loaded and menus.Cheight or 0)-(loaded and menus.height or 0),((menus.Cwidth)-(menus.height*2)-2),menus.height
			
			if isCursorOnElement( x,y,xs,ys ) or isCursorOnElement( centered,PositionC,(menus.Cwidth),(menus.Cheight)-(menus.height+1) ) then
				local number = getKeyState('mouse1') and 25 or 0
				
				if getKeyState('mouse1') then
					if not MouseToggle then
						MouseToggle = true
						triggerServerEvent ( "sendVote", resourceRoot,i )
					end
				else
					MouseToggle = nil
				end
				
				dxDrawRectangle (x,y,xs,ys, tocolor ( 15, 15, 15, 100 ),false )
				dxDrawRectangle (x,y,xs,ys, tocolor ( number, number, number, 30 ),false )
			else
				dxDrawRectangle (x,y,xs,ys, tocolor ( 0, 0, 0, 150 ),false )
				dxDrawRectangle (x,y,xs,ys, tocolor ( 0, 0, 0, 30 ),false )
			end
			
			local xB,yB,xaB,yaB = rectotax(x,y,xs,ys)
			
			if tabl[2] then
				dxDrawText(tabl[2]..' on '..tabl[1],xB,yB,xaB,yaB, tocolor(255, 255, 255, 100), 1.3*s, "default", "center", "center", false, false, false, false, false)--
			else
				dxDrawText(tabl[1],xB,yB,xaB,yaB, tocolor(255, 255, 255, 100), 1.3*s, "default", "center", "center", false, false, false, false, false)
			end
			
			local x,y,xs,ys = centered+menus.height+2+xs,PositionC+(loaded and menus.Cheight or 0)-(loaded and menus.height or 0),menus.height,menus.height
			dxDrawRectangle (x,y,xs,ys, tocolor ( 0, 0, 0, 150 ),false )
			dxDrawRectangle (x,y,xs,ys, tocolor ( 0, 0, 0, 30 ),false )
			
			local xB,yB,xaB,yaB = rectotax(x,y,xs,ys)
			local highLight = (Votes[localPlayer] == i) and 255 or 0
			dxDrawText(getVotes(i),xB,yB,xaB,yaB, tocolor(255, 255-(highLight/2), 255-highLight, 100), 1.3*s, "default", "center", "center", false, false, false, false, false)
			
			PositionC = PositionC + ((menus.Cheight) + (menus.height/2))
		end
	end
end

triggerServerEvent ( "fetchMaps", resourceRoot )


addEventHandler ( "onClientRender", root, drawVoting )