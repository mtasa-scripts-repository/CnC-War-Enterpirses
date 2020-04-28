-- Tables --
images = {}
notifications = {}

-- Values --
xSize, ySize = guiGetScreenSize()
s = (1/1920)*xSize
count = 0
counta = 0

-- Gen Functions --
function prepImage(path,mip)
	images[path] = images[path] or dxCreateTexture(path,'dxt5',mip)
	return images[path]
end

function rectotext (x,y,xs,ys)
	return x,y,x+xs,y+ys
end

function addNotificationC(text,index)
	table.insert(notifications,{text,index,400})
	outputConsole((index or 'Global')..'| '..text)
end

addEvent( "addNotification", true )
addEventHandler( "addNotification", root, addNotificationC )

-- Other functions --

Indexing = {}
Indexing['Red'] = {'Content/Objective.png',{255,0,0}}
Indexing['Blue'] = {'Content/Guard.png',{0,0,255}}
Indexing['Green'] = {'Content/Guard.png',{0,255,0}}
Indexing['Yellow'] = {'Content/Guard.png',{255,255,0}}


Indexing['Nothing'] = {nil,{75,75,75}}

function removeHex (s)
    if type (s) == "string" then
        while (s ~= s:gsub ("#%x%x%x%x%x%x", "")) do
            s = s:gsub ("#%x%x%x%x%x%x", "")
        end
    end
    return s or false
end


function draw()
	counta = counta+1

	for i,v in pairs(notifications) do
		local count = v[3]-1
		
		local image,color = unpack(Indexing[v[2] or 'Nothing'])
		local r,g,b = unpack(color)
		
		local fade = math.min(count/100,1)
		local width = dxGetTextWidth (v[1], 1.3 )+(50)
		
		local x,y,xs,ys = (xSize)-((width*s)+(100*s)),(-25*s)+((40*s)*i),width,39*s
			
		local plus = image and (40*s) or 0
		
		if image then
			local x,y,xs,ys = x-(2*s),y,ys,ys
			local x2,y2,xs2,ys2 = x+(39*s),y,width,ys
			
			
			dxDrawRectangle (x,y,xs,ys,tocolor(0,0,0,50*fade))
			dxDrawRectangle ((x+1),(y+1),(xs-2),(ys-2),tocolor(0,0,0,15*fade))
			
			dxDrawRectangle (x2,y2,xs2,ys2,tocolor(0,0,0,50*fade))
			dxDrawRectangle ((x2+1),(y2+1),(xs2-2),(ys2-2),tocolor(r,g,b,15*fade))
			
			dxDrawImage ( x+(2*s),y,ys,ys,prepImage(image), 0, 0, 0,tocolor(255,255,255,60*fade) )
		else
			dxDrawRectangle (x,y,xs,ys,tocolor(0,0,0,50*fade))
			dxDrawRectangle ((x+1),(y+1),(xs-2),(ys-2),tocolor(r,g,b,15*fade))
		end
		
		
		local x,y,xa,ya = rectotext (x+plus,y,width,ys)
		dxDrawText (removeHex(v[1]),x,y,xa,ya, tocolor ( 255, 255, 255, 150*fade ), 1.3, "default",'center','center' )
		notifications[i] = {v[1],v[2],count}
		if count < 0.2 then
			table.remove(notifications,i)
		end
	end
end

addEventHandler ( "onClientRender", root, draw )