
setElementData(root,'Team_Count',2)
local refresh = {}

function getObjective(oType,ID,Team)
	for i,v in pairs(getElementsByType('object')) do
		if (getElementData(v,'eType') == 'Objective') then
			if (getElementData(v,'Obj Type') == oType) and (getElementData(v,'Team') == Team) and (tonumber(getElementData(v,'Obj ID')) == ID) then
				local x,y,z = getElementPosition(v)
				return x,y,z,v
			end
		end
	end
end

function onPlayerLoad(player)
	fadeCamera (player,false,2)
	setTimer ( onPlayerLoadDelayed, 2000, 1, player )
end


function onPlayerLoadDelayed(player)
	setPlayerHudComponentVisible (player,'all',false)
	
	fadeCamera (player,true,2)
	if not getElementData(player,'Camera') then
		setElementData(player,'Camera',true)
		if getElementData(player,'Team') == 'Blue' then
			setCameraMatrix(player,37.755729675293,-205.77565002441,217.5486907959,3.1784331798553,-117.23550415039,186.4833984375,0,100)
			setElementData(player,'Fade',600)
		else
			setCameraMatrix(player,37.755729675293,-205.77565002441,217.5486907959,3.1784331798553,-117.23550415039,186.4833984375,0,100)
			setElementData(player,'Fade',600)
		end
	end
end
addEventHandler("onPlayerLoadS", root, onPlayerLoad) 

function pointChecker ( )
	setWeather(12)
	for i,v in pairs(refresh) do
		v = v - 1
		if v < 0 then
			refresh[i] = nil
			return
		end
		refresh[i] = v
	end
	for i,v in pairs(getElementsByType('player')) do
		local x,y,z = getElementPosition(v)
		for ia = 1,2 do
			local ia = ia + 1
			local xa,ya,za,teleport = getObjective('Warp In',ia,'Neutral')
			local distance = getDistanceBetweenPoints3D (x,y,z,xa,ya,za)
			if distance < 2 then
				if not refresh[v] then
					refresh[v] = 10
					local xb,yb,zb,target = getObjective('Warp Out',ia,'Neutral')
					setElementPosition(v,xb,yb,zb+1)
					setElementData(v,'Blur',100)
					setElementData(v,'Blur Color',{0,255,0})
					triggerClientEvent ( root, "teleportSound", root, xb,yb,zb)
					triggerClientEvent ( root, "teleportSound", root, xa,ya,za)
				end
			end
		end
	end
end
setTimer ( pointChecker, 50, 0)
setWeather(12)
