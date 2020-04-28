-- Tables --
HudLeft = {}
HudRight = {}
get = {}
images = {}

-- Values --
xSize, ySize = guiGetScreenSize()
s = (1/1920)*xSize
boarder = 30*s
size = 50*s


-- Gen Functions --
function prepImage(path,mip)
	images[path] = images[path] or dxCreateTexture('Content/'..path..'.png','dxt5',mip)
	return images[path]
end

function rectotext (x,y,xs,ys)
	return x,y,x+xs,y+ys
end

get['Health'] = function()
	return math.floor(getElementHealth(localPlayer)),(math.floor(getElementHealth(localPlayer))/100),125,70,70,110
end

get['Ammo'] = function()
	if getElementData(localPlayer,'weapon_Slot') then
		return getElementData(localPlayer,'Rounds.'..(getElementData(localPlayer,'weapon_Slot') or ''))
	end
end

get['Magazine'] = function()
	if getElementData(localPlayer,'weapon_Slot') then
		return getElementData(localPlayer,'Ammo.'..(getElementData(localPlayer,'weapon_Slot') or ''))
	end
end



HudLeft = {'Magazine','Ammo'}
HudRight = {'Health'}

ringTable = {}


function handleRestore( didClearRenderTargets )
	if didClearRenderTargets then
		for i,v in pairs(ringTable) do
			if isElement(v[1]) then
				destroyElement(v[1])
			end
		end
		ringTable = {}
	end
end
addEventHandler("onClientRestore",root,handleRestore)

function getRing (sType, radius, width, startAngle, amount, color, postGUI, absoluteAmount, anglesPerLine)
	ringTable[sType] = ringTable[sType] or {dxCreateRenderTarget( radius*2.5, radius*2.5,true ),0}
	
	if (ringTable[sType][2] == amount) then
		return ringTable[sType][1]
	else
		ringTable[sType][2] = amount
		dxSetRenderTarget(ringTable[sType][1],true)
			if (type (startAngle) ~= "number") or (type (amount) ~= "number") then
				return false
			end
			
			if absoluteAmount then
				stopAngle = amount + startAngle
			else
				stopAngle = (amount * 360) + startAngle
			end
			
			anglesPerLine = type (anglesPerLine) == "number" and anglesPerLine or 2
			radius = (type (radius) == "number" and radius or 50)
			width = (type (width) == "number" and width or 5)
			color = color or tocolor (255, 255, 255, 255)
			postGUI = type (postGUI) == "boolean" and postGUI or false
			absoluteAmount = type (absoluteAmount) == "boolean" and absoluteAmount or false
			
			for i = startAngle, stopAngle, anglesPerLine do
				local startX = math.cos (math.rad (i)) * (radius - width)
				local startY = math.sin (math.rad (i)) * (radius - width)
				local endX = math.cos (math.rad (i)) * (radius + width)
				local endY = math.sin (math.rad (i)) * (radius + width)
				dxDrawLine (startX+(radius*1.25), startY+(radius*1.25), endX+(radius*1.25), endY+(radius*1.25), color, width, postGUI)
			end
		dxSetRenderTarget()
		return ringTable[sType][1]
	end
end




function draw()

	if getElementData(localPlayer,'weapon_Slot') then
		local wSize = size*2
		local x,y,xs,ys = xSize-(wSize*2.2)-boarder,ySize-boarder-(size*3),wSize*2.5,wSize
		
		dxDrawImage (x,y,xs,ys,prepImage('Weapon Icons/'..getElementData(localPlayer,'weapon_Slot')), 0, 0, 0,tocolor(255,255,255,50) )
	end
	
	for i,v in pairs(HudLeft) do
		local x,y,xs,ys = boarder+((size+(110*s))*(i-1)),ySize-boarder-size,size,size
		
		local xa,ya,xsa,ysa = rectotext (x+xs,y-(5*s),85*s,ys)
		
		if get[v] then
			if get[v]() and (not (get[v]() == ' ')) then
			
				local text,amount = get[v]()
				
				if amount then
					local ring = getRing (v,xs/2,2*s,0,amount,tocolor(255,255,255,255) )
					dxDrawImage (x-8*s,y-8*s,xs+14*s,ys+14*s,ring, 0, 0, 0,tocolor(255,255,255,50) )
				end
				
				
				dxDrawImage (x,y,xs,ys,prepImage(v), 0, 0, 0,tocolor(255,255,255,80) )
				dxDrawText ( text or '', xa,ya,xsa,ysa, tocolor (255,255,255,80), 3.2*s, "clear",'center','center')
			end
		end
	end
	
	for i,v in pairs(HudRight) do
		local x,y,xs,ys = xSize-(boarder+((size+(110*s))*(i))),ySize-boarder-size,size,size
	
		
		local xa,ya,xsa,ysa = rectotext (x+xs,y-(2*s),90*s,ys)
		
		if get[v] then
			if get[v]() then
				local text,amount,r,g,b,a = get[v]()
				
				if amount then
				local ring = getRing (v,xs/2,2*s,0,amount,tocolor(255,255,255,255) )
				dxDrawImage (x-8*s,y-8*s,xs+14*s,ys+14*s,ring, 0, 0, 0,tocolor(r,g,b,a) )
				end
				
				dxDrawImage (x,y,xs,ys,prepImage(v), 0, 0, 0,tocolor(255,255,255,80) )
				dxDrawText ( text or '', xa,ya,xsa,ysa, tocolor (r or 255,g or 255,b or 255,a or 80), 3.2*s, "clear",'center','center')
			end
		end
	end

end

addEventHandler ( "onClientRender", root, draw )