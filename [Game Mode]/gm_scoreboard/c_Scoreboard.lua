
-- Tables --
functions = {}
menus = {settings = {}}

-- Values --
xSize, ySize = guiGetScreenSize()
s = (1/1920)*xSize
menus.settings.boarder = 8*s
menus.settings.width = 900*s
menus.settings.height = 40*s
menus.settings.startHeight = (ySize/2)-(350*s)


teamNames = {{'Red',255,0,0},{'Blue',0,0,255},{'Green',0,255,0},{'Yellow',255,255,0},{'Loading',115,115,115}}

playerData = {{'',0.05},{'#',0.2},{'Player',2},{'Score',1},{'Kills',1},{'Deaths',1},{'Captures',1},{'Ping',1},{'FPS AVG',1}}


teamData = {{'Team Name',2.25,2*s},{'Score',1,0,0.5},{'Kills',1,0,0.5},{'Deaths',1,0,0.5},{'Captures',1,0,0.5},{' ',2,1*s,0.5}}
function rectotax (x,y,xs,ys)
	return x,y,x+xs,y+ys
end

function removeHex (s)
    if type (s) == "string" then
        while (s ~= s:gsub ("#%x%x%x%x%x%x", "")) do
            s = s:gsub ("#%x%x%x%x%x%x", "")
        end
    end
    return s or false
end


functions.indexPlayers = function()
	local tabl = {}
	local tablc = {}
	for i,v in pairs(getElementsByType('player')) do
		local team = (getElementData(v,'Team') or 'Loading')
		tabl[team] = tabl[team] or {}
		tablc[team] = tablc[team] or {}
		local tabla = tabl[team]
		tabla[#tabla+1] = {['Player']=(removeHex(getPlayerName(v))),['#']=i}
		for ia,va in pairs(playerData) do
			tabla[#tabla][va[1]] = tabla[#tabla][va[1]] or getElementData(v,va[1]) or ''
			
			tablc[team][va[1]] = tonumber(tablc[team][va[1]]) or 0
			tablc[team][va[1]] = (tablc[team][va[1]]+(tonumber(getElementData(v,va[1])) or 0))
		end
	end
	return tabl,tablc
end


extend = 0
extend2 = 0
extend3 = 0

Score = {}
function getScore(Team)
	Score[Team] = 0 
	for i,v in pairs(getElementsByType('player')) do
		if getElementData(v,'Team') == Team then
			if getElementData(v,'Score') then
				Score[Team] = Score[Team] + getElementData(v,'Score')
			end
		end
	end
end

refresh = 150

function rectotext (x,y,xs,ys)
	return x,y,x+xs,y+ys
end

function drawScoreboard()
	if (getKeyState(getElementData(localPlayer,'Show Scoreboard') or 'F1') or isPedDead(localPlayer)) and (not isMTAWindowActive ()) and (not guiGetInputEnabled())  then
		if extend3 > 20 then
			extend = 0
		end
		extend = math.min(extend+0.1,2)
		if extend > 0.9 then
			extend2 = math.min(extend2+0.1,2)
		end
	else
		extend2 = math.max(extend2-0.1,0)
		
		if extend2 < 0.5 then
			extend = math.max(extend-0.1,-1)
		end
		
	end
	
	refresh = refresh - 1
	if refresh < 0 then
		refresh = 150
		getScore('Red')
		getScore('Blue')
	end
	
	local x,y,xs,ys = (xSize/2)-(95*s),(1*s),60*s,60*s
	dxDrawRectangle (x,y,xs,ys,tocolor(0,0,0,50))
	dxDrawRectangle ((x+1),(y+1),(xs-2),(ys-2),tocolor(255,0,0,20))
	local x,y,xa,ya = rectotext (x,y,xs,ys)
	dxDrawText (Score['Red'] or 0,x,y,xa,ya, tocolor ( 255, 255, 255, 90 ), 2*s, "default",'center','center' )
			
		
	local x,y,xs,ys = (xSize/2)-(30*s),(1*s),60*s,60*s
	dxDrawRectangle (x,y,xs,ys,tocolor(0,0,0,50))
	dxDrawRectangle ((x+1),(y+1),(xs-2),(ys-2),tocolor(0,0,0,15))
	local x,y,xa,ya = rectotext (x,y,xs,ys)
	dxDrawText (getElementData(root,'Game Type'),x,y,xa,ya, tocolor ( 255, 255, 255, 90 ), 1.2*s, "default",'center','center',false,true )
	
	
	local x,y,xs,ys = (xSize/2)+(35*s),(1*s),60*s,60*s
	dxDrawRectangle (x,y,xs,ys,tocolor(0,0,0,50))
	dxDrawRectangle ((x+1),(y+1),(xs-2),(ys-2),tocolor(0,0,255,20))
	local x,y,xa,ya = rectotext (x,y,xs,ys)
	dxDrawText (Score['Blue'] or 0,x,y,xa,ya, tocolor ( 255, 255, 255, 90 ), 2*s, "default",'center','center' )

	if (extend > 0.01) then
		
		local extend = math.min(extend,1)
		local extend2 = math.min(extend2,1)
		
		local players,teamV = functions.indexPlayers()
		
		local teams = 5
		local unique = {}
		yHeight = menus.settings.startHeight
		
		total = 0
		for i,v in pairs(playerData) do
			total = total + v[2]
		end
			
		for i=1,teams do
			local startHeight = yHeight
			local xs = (menus.settings.width)
			local x = (xSize/2)-(xs/2)
			
			local split = xs/(total)
			
			local name,r,g,b = unpack(teamNames[i])
			if #(players[name] or {}) > 0 then
				heightX = math.max(menus.settings.startHeight,(yHeight+(21*s))*extend2)
				for ib,vb in pairs(players[name]) do
					position = 0
					for ia,v in pairs(playerData) do
						local width = (split*v[2])
						dxDrawRectangle ((extend3*s)+(x+position)*extend,heightX,width,menus.settings.height, tocolor ( 0, 0, 0, 150 ),false )
						local xB,yB,xaB,yaB = rectotax((extend3*s)+(x+position)*extend,heightX,width,menus.settings.height)
						
						local player = players[name][ib]
						
						dxDrawText(player[v[1]],xB,yB,xaB,yaB, tocolor(255, 255, 255, 150), 1.2*s, "clear", "center", "center", false, false, false, false, false)
						
						if not unique[v[1]] then
							unique[v[1]] = true
							dxDrawRectangle ((extend3*s)+(x+position)*extend,menus.settings.startHeight-((menus.settings.height-(9*s))*extend2),width,menus.settings.height-(10*s), tocolor ( 0, 0, 0, 150 ),false )
							local x,y,xa,ya = rectotax((extend3*s)+(x+position)*extend,menus.settings.startHeight-((menus.settings.height-(9*s))*extend2),width,menus.settings.height-(10*s))
							dxDrawText(v[1],x,y,xa,ya, tocolor(255, 255, 255, 170), 1.3*s, "default", "center", "center", false, false, false, false, false)
						end

						if v[1] == '' then
							dxDrawRectangle ((extend3*s)+(x+position)*extend,heightX,width,menus.settings.height, tocolor ( r,g,b, 30 ),false )
						end
						
						position = position + width + (1*s)
					end
					heightX = math.max(menus.settings.startHeight,(menus.settings.height + ((1*s) + heightX)*extend2))
					yHeight = heightX
				end
				
				totalA = 0
				for i,v in pairs(teamData) do
					totalA = totalA + v[2]
				end
				local split = xs/(totalA)


				positionB = 0
				for ia,v in pairs(teamData) do
					local width = (split*v[2]+(v[3] or 0))
					dxDrawRectangle ((extend3*s)+(x+positionB)*extend,startHeight,width,(20*s), tocolor ( 0, 0, 0, 150 ),false )
					dxDrawRectangle ((extend3*s)+(x+positionB)*extend,startHeight,width,(20*s), tocolor ( r,g,b, 30*(v[4] or 1) ),false )
					local xB,yB,xaB,yaB = rectotax((extend3*s)+(x+positionB)*extend,startHeight,width,(20*s))
					
					if v[1] == 'Team Name' then
						dxDrawText(name,xB,yB,xaB,yaB, tocolor(255, 255, 255, 100), 1.2*s, "default", "center", "center", false, false, false, false, false)
					else
						dxDrawText(teamV[name][v[1]] or '',xB,yB,xaB,yaB, tocolor(255, 255, 255, 100), 1.2*s, "default", "center", "center", false, false, false, false, false)
					end

					positionB = positionB + width + (1*s)
				end
			end
		end
	end
end
addEventHandler ( "onClientRender", root, drawScoreboard )