-- Tables --
images = {}
chats = {}

-- Values --
xSize, ySize = guiGetScreenSize()
s = (1/1920)*xSize
count = 0
counta = 0
Add = 0
CountDownA = 0
CountDownB = 0
CountE = 100

-- Gen Functions --
function prepImage(path,mip)
	images[path] = images[path] or dxCreateTexture(path,'dxt5',mip)
	return images[path]
end

function rectotext (x,y,xs,ys)
	return x,y,x+xs,y+ys
end

function addChat(name,text,team,tag,teamChat)
	if teamChat then
		if (getElementData(localPlayer,'Team') == teamChat) then
			table.insert(chats,{name,text,team,tag,true})
			if #chats > 7 then
				Add = math.min(Add + 1,2)
			end
			CountE = 0
		end
	else
		table.insert(chats,{name,text,team,tag})
		if #chats > 7 then
			Add = math.min(Add + 1,2)
		end
		CountE = 0
	end
end

addEvent( "addChat", true )
addEventHandler( "addChat", root, addChat )

-- Other functions --

Indexing = {}
Indexing['Red'] = {255,0,0}
Indexing['Blue'] = {0,0,255}
Indexing['Green'] = {0,255,0}
Indexing['Yellow'] = {255,255,0}

Indexing['Nothing'] = {75,75,75}

toggle = false
toggleb = false

function prepedit(text,x,y,xs,ys)
	ToggleD = true
	if not edit then
		ToggleD = nil
	end
	
	edit = edit or guiCreateEdit ( x,y,xs,ys,text,false)
	guiSetPosition (edit,x,y,false)
	guiSetSize (edit,xs,ys,false)
	guiSetAlpha (edit,0)
	guiEditSetMaxLength(edit,150)
	
	if (not ToggleD) or ToggleG then
		ToggleG = nil
		guiEditSetCaretIndex(edit,string.len(text))
	end
	
	if not toggleb then
		toggleb = true
		guiFocus(edit)
	end
	Text = guiGetText(edit)
	return edit
end

function removeEdit()
	if isElement(edit) then
		destroyElement(edit)
	end
	edit = nil
	toggleb = nil
end

Text = ''

function blur()
	if (source == edit) then
		Focused = nil
	end
end

addEventHandler("onClientGUIBlur", root, blur)

function focus()
	if (source == edit) then
		Focused = true
	end
end

addEventHandler("onClientGUIFocus", root, focus)

CountE = 0

function string.count (text, search)
	if ( not text or not search ) then return false end
	
	return select ( 2, text:gsub ( search, "" ) );
end

function removeHex (s)
    if type (s) == "string" then
        while (s ~= s:gsub ("#%x%x%x%x%x%x", "")) do
            s = s:gsub ("#%x%x%x%x%x%x", "")
        end
    end
    return s or false
end

function CyclePlayers(Repeat,Repeate)
	local lastb = string.gsub ( last, "@","" )
	if Repeat or Repeate then
		for i,v in pairs(getElementsByType('player')) do
			if (string.count(string.lower(getPlayerName(v)),string.lower(lastb)) > 0) then
				if (AutoComplete[1] == getPlayerName(v)) then
					AutoComplete[3] = true
				end
								
			if (not (AutoComplete[1] == getPlayerName(v))) and (AutoComplete[3]) then
					AutoComplete = {getPlayerName(v),i,nil,true,last}
				end
			end
		end
		if (not AutoComplete[4]) then
			CyclePlayers(not Repeat)
		end
	end
end

Scroll = 0

function draw()
	
	local tScale = getChatboxLayout ( 'text_scale' )
	
	CountE = CountE + 1
	if (CountE < 350) then
		CountDownA = CountDownA + 1
		else
		CountDownA = math.max(CountDownA - 1,0)
	end
	
	local CountDown = math.min(CountDownA,100)/100
	
	guiSetInputMode ('no_binds_when_editing')
	showChat(false)

	if getKeyState(getElementData(localPlayer,'Chat Key') or 't') and (not isMTAWindowActive ()) and (not guiGetInputEnabled()) then
		if not toggle then
			showCursor(true)
			CountE = 0
		end
		toggle = true
		teamToggle = nil
		toggleb = nil
	end
	
	
	if getKeyState(getElementData(localPlayer,'Team Chat Key') or 'y') and (not isMTAWindowActive ()) and (not guiGetInputEnabled()) then
		if not toggle then
			showCursor(true)
			CountE = 0
		end
		toggle = true
		teamToggle = true
		toggleb = nil
	end
	
	
	
	counta = counta+1
	
	if (#chats) > 5 then
		count = 5-#chats
	end
	
	if #chats > 7 then
		Add = math.max(Add - 0.05,0)
	end
	
	
	local yStart = (-25)+((35)*9)
	
	if toggle then
		CountDownB = math.min(CountDownB + 5,110)
	else
		CountDownB = math.max(CountDownB - 5,0)
	end
	
	if (CountDownB > 0) then
		local fade = math.min(CountDownB,100)/100
		
		local prefix = teamToggle and 'Team | ' or 'Global | '
		
		local widtha = dxGetTextWidth (prefix, 1.15*tScale)+(28)
		local x,y,xs,ys = (15),yStart,widtha,(34*tScale)
			
		dxDrawRectangle (x,y,xs,ys,tocolor(0,0,0,50*fade))
		dxDrawRectangle ((x+1),(y+1),(xs-2),(ys-2),tocolor(0,0,0,15*fade))
		
		local x,y,xa,ya = rectotext (x+(18),y,xs,ys)
		dxDrawText (prefix,x,y,xa,ya, tocolor ( 255, 255, 255, 150*fade ), 1.15*tScale, "default",'left','center',false,false,false,false,true  )
		
		
		local width = dxGetTextWidth (Text, 1)+(38)
		local x,y,xs,ys = (16)+widtha,yStart,width,(34*tScale)
			
		dxDrawRectangle (x,y,xs,ys,tocolor(0,0,0,50*fade))
		dxDrawRectangle ((x+1),(y+1),(xs-2),(ys-2),tocolor(0,0,0,15*fade))
		
		if toggle or ToggleG then
			prepedit(Text,x+(10),y,xs,ys)
		end
		
		
		
		local x,y,xa,ya = rectotext (x+(18),y,xs,ys)
		dxDrawText (Text,x,y,xa,ya, tocolor ( 255, 255, 255, 150*fade ), 1, "default",'left','center',false,false,false,false,true  )
		
		list = split(Text,32)
		last = list[#list]

		AutoComplete = AutoComplete or {}
		
		if AutoComplete[1] then
			local Text = tostring(AutoComplete[1])
			local width = dxGetTextWidth (Text, 1)+(38)
			local x,y,xs,ys = (16)+widtha,yStart+(34*tScale),width,(34*tScale)
				
			dxDrawRectangle (x,y,xs,ys,tocolor(0,0,0,50*fade))
			dxDrawRectangle ((x+1),(y+1),(xs-2),(ys-2),tocolor(0,0,0,15*fade))

			local x,y,xa,ya = rectotext (x+(18),y,xs,ys)
			dxDrawText (Text,x,y,xa,ya, tocolor ( 255, 255, 255, 150*fade ), 1, "default",'left','center',false,false,false,false,true  )
		end
		
		
		if (not (AutoComplete[5] == last)) then
			 AutoComplete = {}
		end
		
		if (not AutoComplete[1]) then
			AutoComplete[3] = true
		end
		AutoComplete[4] = nil
		
		
		if last then
			if getKeyState('tab') then
				if not ToggleE then
					ToggleE = true
					CyclePlayers(false,true)
				end
			else
				ToggleE = nil
			end
		end
	end
	
	if isMTAWindowActive () then
		showCursor(false)
		toggle = nil
		Text = ''
		removeEdit()
	end
	
	if (getKeyState('enter')) and Text and toggle and (not isMTAWindowActive ()) and Focused and (not ToggleF) then
		if (AutoComplete[1]) then
			table.remove(list,#list)
			local list = table.concat(list, " ")
			if (string.count(AutoComplete[5],'@') < 1) then
				if (list == '') then
					Texta = list..AutoComplete[1]
				else
					Texta = list..' '..AutoComplete[1]
				end
			else
				if (list == '') then
					Texta = list..'@'..AutoComplete[1]
				else
					Texta = list..' @'..AutoComplete[1]
				end
			end
			guiSetText(edit,Texta)
			Text = Texta
			ToggleG = true
			AutoComplete = {}
		else
			if not ((Text == '') or (Text == ' ') or (Text == '  ')  or (Text == '   ')  or (Text == '    ')  or (Text == '     '))  then
				triggerServerEvent ( "outputChat", root,Text,teamToggle)
			end
			toggle = nil
			showCursor(false)
			Text = ''
			removeEdit()
		end
	end
	
	if getKeyState('enter') then
		ToggleF = true
	else
		ToggleF = nil
	end
	
	position = yStart+(40*Add)+Scroll

	if getKeyState('pgup') then
		CountG = 100
		Scroll = Scroll + 5
	elseif getKeyState('pgdn') then
		CountG = 100
		Scroll = math.max(Scroll-5,0)
	end
	
	CountG = CountG or 100
	
	CountG = CountG - 1
	
	if CountG < 0 then
		Scroll = math.max(Scroll-3,0)
	end
	
	
	for i=1,#chats do
		local number = (#chats-i)+1
		local v = chats[number]
	
		position = position - (35*tScale)
		
		if v and (position > 0) then
		
			local x,y = (15),position

			local fade = (y < 0) and ((math.min(math.max(20+y,0),20)/20)*CountDown) or CountDown
			
			if (fade > 0) then
			
				local color = Indexing[v[3] or 'Nothing']
				local r,g,b = unpack(color)
				
				local width = dxGetTextWidth (v[2], 1.2*tScale,"arial",true )+(50)
			
				local xs,ys = width,34*tScale
				local start = (yStart-(ys))
				local fade2 = (y > start) and ((y-(start))/ys) or 1

				local fade2 = (fade2>1) and 0 or fade2

				local fade = fade2*fade
				
				if (fade > 0) then
					local teamAddition = v[5] and ' #FFFFFF[Team]' or ''

					local plus = v[1] and (dxGetTextWidth (v[1]..teamAddition, 1.2*tScale,"arial",true )+(20)) or 0

					if (i == #chats) and (y > 0) and (#chats > 7) then
						Scroll = math.max(Scroll - 4,0)
					end
					
					if v[1] then
						local x,y,xs,ys = x-(2),y,plus,ys
						local x2,y2,xs2,ys2 = x+plus,y,width,ys
						
						dxDrawRectangle (x,y,xs,ys,tocolor(0,0,0,80*fade))
						
						if not (v[4] == getPlayerName(localPlayer)) then
							dxDrawRectangle ((x+1),(y+1),(xs-2),(ys-2),tocolor(r,g,b,45*fade))
						else
							dxDrawRectangle ((x+1),(y+1),(xs-2),(ys-2),tocolor(255,255,0,45*fade))
						end

						local x,y,xa,ya = rectotext (x,y,xs,ys)
						dxDrawText (removeHex(v[1]..teamAddition),x,y,xa+1,ya+1, tocolor ( 0, 0, 0, 60*fade ), 1.2*tScale, "arial",'center','center',false,false,false,true,true  )
						dxDrawText (removeHex(v[1]..teamAddition),x,y,xa,ya, tocolor ( 255, 255, 255, 150*fade ), 1.2*tScale, "arial",'center','center',false,false,false,true,true  )
					end
					
					
					local x,y,xa,ya = rectotext (x+plus+(5),y,width,ys)
					dxDrawText (v[2],x,y,xa+1,ya+1, tocolor ( 0, 0, 0, 60*fade ), 1.2*tScale, "arial",'left','center',false,false,false,true,true )
					dxDrawText (v[2],x,y,xa,ya, tocolor ( 255, 255, 255, 150*fade ), 1.2*tScale, "arial",'left','center',false,false,false,true,true )
				end
			end
		else
			if (i > 100) then
				table.remove(chats,1)
			end
		end
	end
end

addEventHandler ( "onClientRender", root, draw )