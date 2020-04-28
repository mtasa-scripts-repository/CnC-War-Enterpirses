
-- Tables --
functions = {}
menus = {settings = {},options = {}}
images = {}

-- Values --
xSize, ySize = guiGetScreenSize()
s = (1/1920)*xSize
menus.settings.width = 400*s
menus.settings.height = 60*s


menus.options.width = 400*s
menus.options.height = 50*s


function prepImage(path,mip)
	images[path] = images[path] or dxCreateTexture('Content/'..path..'.png','dxt5',mip)
	return images[path]
end

function rectotext (x,y,xs,ys)
	return x,y,x+xs,y+ys
end


MainOptions = {}
Relisting = {}

MainOptions['Graphics'] = {}
	local tabl = MainOptions['Graphics']
	--table.insert(tabl,{'Graphics Quality','Selection',{'Low','Medium','High','Ultra'},3,3})
	table.insert(tabl,{'Bloom','Selection',{'Off','Low','Medium','High'},3,3})
	table.insert(tabl,{'Dynamic Vertex Lighting','Selection',{'Basic','Advanced'},2,2})
	table.insert(tabl,{'FXAA','Selection',{'Off','x1','x2','x3','x4'},3,3})
	table.insert(tabl,{'DOF','Selection',{'Off','Low','Medium','High','Cinematic'},3,3})
	table.insert(tabl,{'Color Correction','Selection',{'Off','On'},2,2})
	table.insert(tabl,{'Soft Particles','Selection',{'Off','On'},2,2})
	table.insert(tabl,{'Vegitation Sway','Selection',{'Off','On'},2,2})
	table.insert(tabl,{'Flag Effects','Selection',{'Off','On'},2,2})
	table.insert(tabl,{'Blur Enabled','Selection',{'Off','Low','Medium','High'},3,3})
	table.insert(tabl,{'Bullet Hole Limit','Selection',{'50','100','150','200','250','300','350'},4,4})

MainOptions['Graphics (Experimental)'] = {}
	local tabl = MainOptions['Graphics (Experimental)']
	table.insert(tabl,{'SSAO','Selection',{'Off','Low','Medium','High'},1,1})

MainOptions['Main Controls'] = {}
	local tabl = MainOptions['Main Controls']
	table.insert(tabl,{'Show Scoreboard','Bind','F1','F1'})
	table.insert(tabl,{'Show Settings','Bind','F2','F2'})
	table.insert(tabl,{'Interact','Bind','e','e'})
	table.insert(tabl,{'Chat Key','Bind','t','t'})
	table.insert(tabl,{'Team Chat Key','Bind','y','y'})
	
MainOptions['Weapon Controls'] = {}
	local tabl = MainOptions['Weapon Controls']
	table.insert(tabl,{'Throw Grenade','Bind','mouse3','mouse3'})
	table.insert(tabl,{'Next Weapon','Bind','tab','tab'})
	table.insert(tabl,{'Previous Weapon','Bind','',''})
	table.insert(tabl,{'Zoom In','Bind','mouse_wheel_up','mouse_wheel_up'})
	table.insert(tabl,{'Zoom Out','Bind','mouse_wheel_down','mouse_wheel_down'})
	table.insert(tabl,{'Aim','Bind','mouse2','mouse2'})
	table.insert(tabl,{'Jump [Has to match MTA bind]','Bind','lshift','lshift'})
	table.insert(tabl,{'Put Down Weapon','Bind','space','space'})
	
MainOptions['Gameplay'] = {}
	local tabl = MainOptions['Gameplay']
	table.insert(tabl,{'Look Sensitivity','Selection',{'0.25','0.5','0.75','1','1.25','1.5','2'},4,4})
	table.insert(tabl,{'Zoom Sensitivity','Selection',{'0.25','0.5','1','1.5','2'},3,3})



function triggerChange(name,option)
	setElementData(localPlayer,name,option)
	triggerEvent ( name, root, option)
end


function loadSettings()
	if fileExists("Settings.txt") then
		local File = fileOpen("Settings.txt")

		
		local Data =  fileRead(File, fileGetSize(File))
		local Proccessed = split(Data,10)
		fileClose (File)
		local tabl = {}
		for i,v in pairs(Proccessed) do
			local list = fromJSON(v)
			tabl[list[1]] = list
		end
		
		for ia,va in pairs(MainOptions) do
			for i,v in pairs(va) do
				if (v[2] == 'Selection') then
					if tabl[v[1]] then
						MainOptions[ia][i][4] = tabl[v[1]][4]
					end
					setTimer ( triggerChange, 500, 1,MainOptions[ia][i][1],MainOptions[ia][i][3][MainOptions[ia][i][4]])
				else
					if tabl[v[1]] then
						MainOptions[ia][i] = tabl[v[1]]
					end
					triggerChange(MainOptions[ia][i][1],MainOptions[ia][i][3])
				end
			end
		end
	end
end

bindNames = {}
bindNames['mouse3'] = 'middle mouse'
bindNames['mouse1'] = 'left mouse'
bindNames['mouse2'] = 'right mouse'
bindNames['mouse_wheel_up'] = 'scroll up'
bindNames['mouse_wheel_down'] = 'scroll down'

totalHeight = 0
for i,v in pairs(MainOptions) do
	totalHeight = totalHeight + menus.settings.height + 1
end

local start = (ySize*0.3)

local selected = 'Graphics'
local selected2 = 'Bloom'

draw = {}

keyPress = false

draw.Selection = function(x,y,xs,ys,list,tabl)
	local offset = (ys/4)
	
	if isCursorOnElement( x,y+offset,ys-(offset*2),ys-(offset*2) ) then
		if getKeyState('mouse1') then
			if not keyPress then
				if tabl[4] > 1 then
					tabl[4] = tabl[4] - 1
				else
					tabl[4] = #list
				end
				triggerChange(tabl[1],list[tabl[4] or 2])
				keyPress = true
			end
			
			dxDrawImage (x,y+offset,ys-(offset*2),ys-(offset*2),prepImage('arrow'), 0, 0, 0,tocolor(200,200,200,50) )
		else
			dxDrawImage (x,y+offset,ys-(offset*2),ys-(offset*2),prepImage('arrow'), 0, 0, 0,tocolor(200,200,200,80) )
		end
	else
		dxDrawImage (x,y+offset,ys-(offset*2),ys-(offset*2),prepImage('arrow'), 0, 0, 0,tocolor(255,255,255,80) )
	end
	
	if isCursorOnElement( x+xs-(ys/2),y+offset,ys-(offset*2),ys-(offset*2) ) then
		if getKeyState('mouse1') then
			if not keyPress then
				if tabl[4] < #list then
					tabl[4] = tabl[4] + 1
				else
					tabl[4] = 1
				end
				triggerChange(tabl[1],list[tabl[4] or 2])
				keyPress = true
			end
			dxDrawImage (x+xs-(ys/2),y+offset,ys-(offset*2),ys-(offset*2),prepImage('arrow'), 180, 0, 0,tocolor(200,200,200,50) )
		else
			dxDrawImage (x+xs-(ys/2),y+offset,ys-(offset*2),ys-(offset*2),prepImage('arrow'), 180, 0, 0,tocolor(200,200,200,80) )
		end
	else
		dxDrawImage (x+xs-(ys/2),y+offset,ys-(offset*2),ys-(offset*2),prepImage('arrow'), 180, 0, 0,tocolor(255,255,255,80) )
	end
	
	local x,y,xa,ya = rectotext (x,y,xs,ys)
	dxDrawText (list[tabl[4] or 2],x,y,xa,ya, tocolor ( 255, 255, 255, 90 ), 1.5*s, "clear",'center','center' )
end

rebindKey = nil
draw.Bind = function(x,y,xs,ys,bind,tabl)
	local offset = (ys/5)
	
	if isCursorOnElement( x+offset,y+offset,xs-offset*2,ys-offset*2 ) then
		if getKeyState('mouse1') then
			if not keyPress then
				keyPress = true
				rebindKey = {tabl[1],tabl}
			end
			dxDrawRectangle (x+offset,y+offset,xs-offset*2,ys-offset*2,tocolor(90,90,90,50))
		else
			dxDrawRectangle (x+offset,y+offset,xs-offset*2,ys-offset*2,tocolor(70,70,70,50))
		end
	else
		dxDrawRectangle (x+offset,y+offset,xs-offset*2,ys-offset*2,tocolor(50,50,50,50))
	end
	
	local x,y,xa,ya = rectotext (x+offset,y+offset,xs-offset*2,ys-offset*2)
	if (rebindKey or {})[1] == tabl[1] then
		dxDrawText ('[Hit Key or Back Space]',x,y,xa,ya, tocolor ( 255, 255, 255, 90 ), 1.5*s, "clear",'center','center' )
	else
		dxDrawText (bindNames[bind] or bind or bindNames[tabl[4]] or tabl[4],x,y,xa,ya, tocolor ( 255, 255, 255, 90 ), 1.5*s, "clear",'center','center' )
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


function rebind(button, press)
    if (press) then
		if rebindKey then
			if button == 'backspace' then
				rebindKey[2][3] = ''
			else
				rebindKey[2][3] = button
			end
			
			triggerChange(rebindKey[2][1],rebindKey[2][3])
			
			rebindKey = nil
		end
    end
end
addEventHandler("onClientKey", root, rebind)


function drawScoreboard()

	dxDrawText ('['..(Old or '')..'] For Settings',xSize/2,10*s,10*s,10*s, tocolor ( 255, 255, 255, 90 ), 1*s, "clear",'center','center' )
	
	
	if showSettings then
		if not getKeyState('mouse1') then
			keyPress = nil
		end
		
		yAdj = 0
		for i,v in pairs(MainOptions) do
			local x,y,xs,ys = (xSize/2)-menus.settings.width*2,(start*s)+((menus.settings.height)*yAdj),menus.settings.width,menus.settings.height-(2*s)
			
			if isCursorOnElement( x,y,xs,ys ) then
				if getKeyState('mouse1') then
					selected = i
					dxDrawRectangle (x,y,xs,ys,tocolor(15,15,15,120))
				else
					dxDrawRectangle (x,y,xs,ys,tocolor(15,15,15,150))
				end
				dxDrawRectangle ((x+1),(y+ys-3),(xs-2),(3),tocolor(0,0,255,25))
			else
				dxDrawRectangle (x,y,xs,ys,tocolor(0,0,0,150))
				if (i == selected) then
					dxDrawRectangle ((x+1),(y+ys-3),(xs-2),(3),tocolor(0,0,255,50))
				end
			end
			
			local x,y,xa,ya = rectotext (x,y,xs,ys)
			dxDrawText (i,x,y,xa,ya, tocolor ( 255, 255, 255, 90 ), 1.6*s, "clear",'center','center' )
			yAdj = yAdj + 1
		end
		yAdj = -1
		
		local x,y,xs,ys = (xSize/2)-menus.options.width*0.90,(start*s)+((menus.options.height)*yAdj),menus.options.width*1.95,menus.options.height-(2*s)
		local x,y,xa,ya = rectotext (x,y,xs,ys)
		dxDrawText (selected,x+1,y+1,xa,ya, tocolor ( 0, 0, 0, 90 ), 2*s, "clear",'left','center' )
		dxDrawText (selected,x,y,xa,ya, tocolor ( 255, 255, 255, 150 ), 2*s, "clear",'left','center' )
		
		yAdj = 0	
		for i,v in ipairs(MainOptions[selected]) do
			local x,y,xs,ys = (xSize/2)-menus.options.width*0.95,(start*s)+((menus.options.height)*yAdj),menus.options.width*1.95,menus.options.height-(2*s)
			
			dxDrawRectangle (x,y,xs,ys,tocolor(0,0,0,150))
			
			if isCursorOnElement(x,y,xs,ys) then
				dxDrawRectangle ((x+1),(y+1),(xs-2),(ys-2),tocolor(0,0,255,20))
				dxDrawRectangle ((x+1),(y+ys-3),(xs-2),(3),tocolor(0,0,255,50))
			end
			
			
			draw[v[2]]((x+xs)-(xs/2.4),y,(xs/2.5),ys,v[3],v)
			
			
			local x,y,xa,ya = rectotext (x+(20*s),y,xs/2,ys-3)
			dxDrawText (v[1],x,y,xa,ya, tocolor ( 255, 255, 255, 90 ), 1.5*s, "clear",'left','center' )
			yAdj = yAdj + 1
		end
	end
end
addEventHandler ( "onClientRender", root, drawScoreboard )

function openSettings()
	showSettings = not showSettings
	showCursor(showSettings)
end

bindKey( "F2", "down", openSettings )


Old = 'F2'
function changeSetting(setting)
	unbindKey( Old, "down", openSettings )
	bindKey( setting, "down", openSettings )
	Old = setting
end

addEvent ( "Show Settings", true )
addEventHandler ( "Show Settings", root, changeSetting )


function saveSettings ()
local fileHandle = fileCreate("Settings.txt") 
	if fileHandle then
		for ia,va in pairs(MainOptions) do
			for i,v in pairs(va) do
				fileWrite(fileHandle,toJSON(v)..'\n')
			end
		end
		fileClose(fileHandle)
	end
end
addEventHandler( "onClientResourceStop", resourceRoot, saveSettings )

function prepLoad()
	if isTransferBoxActive() then
		setTimer ( prepLoad, 1000, 1)
	else
		setTimer ( loadSettings, 1000, 1)
	end
end

setTimer ( prepLoad, 1000, 1)