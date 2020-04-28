
Peds = {}
Attatched = {}

function prepPedModel(v)
	Peds[v] = Peds[v] or createPed ( getElementModel(v), 0,0,0 ,0, false)
	local ped = Peds[v]
	local model = getElementModel(v)
	setElementDoubleSided(ped,true)
	setElementModel(ped,model)
	setElementData(v,'Ped',ped)
	setElementData(Peds[v],'Legs',v)
	return Peds[v]
end


function updateLegs ( )
	for i,v in pairs(getElementsByType('player')) do
		prepPedModel(v)
	end
	
	for i,v in pairs(Peds) do
		if (not isElement(i)) then
			destroyElement(v)
			Peds[i] = nil
		end
	end
end
setTimer ( updateLegs, 500, 0 )


function dettachElements ( client,ped )
	if isElement(client) and isElement(ped) then
		Attatched[client] = nil
		detachElements(ped)
		setElementPosition(ped,0,0,0,false)
		setElementData(client,'tele',nil)
		setElementAlpha(ped,0)
	end
	timer[client] = nil
end

timer = {}

function prepLegs (ducking)
	local x,y,z = getElementPosition(client)
	Peds[client] = Peds[client] or prepPedModel(client)
	
	setElementModel(Peds[client],getElementModel(client))
	
	local ped = Peds[client]
	if (getElementData(client,'State.Weapon')) then
	
		if (timer[client]) then
			Attatched[client] = nil
			killTimer(timer[client])
			timer[client] = nil
		end
			
		if (not Attatched[client]) then
			
			if ducking then
				setAnimation(ped,'FPS.Aim.C','Aim_M',-1,true,false,false,true,2)
			else
				setAnimation(ped,'ped','idle_stance',-1,true,false,false,true,2)
			end
			
			setElementCollisionsEnabled(ped,false)
			setElementFrozen(ped,true)
			setElementAlpha(ped,255)
			local x,y,z = getElementPosition(client)
			local xr,yr,zr = getElementRotation(client)
			setElementRotation(ped,xr,yr,zr,'default',true)
			setElementPosition(ped,x,y,z,false)
			attachElements(ped,client)
			Attatched[client] = true
			setElementData(ped,'State.Teleported',true)
			setElementFrozen(ped,false)
		end
	else
		if Attatched[client] then
			if (timer[client]) then
				killTimer(timer[client])
				timer[client] = nil
			end
			setElementData(ped,'State.Teleported',nil)
			timer[client] = setTimer ( dettachElements, 100, 1, client,ped )
		end
	end
end

addEvent( "prepLegs", true )
addEventHandler( "prepLegs", root, prepLegs )

