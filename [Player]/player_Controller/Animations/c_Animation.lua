engineLoadIFP( "Animations/Aim.ifp", 'FPS.Aim' )
engineLoadIFP( "Animations/Aim_Crouch.ifp", 'FPS.Aim.C' )

Aim = nil
animations = {}

function setAnimation ( ped,block,anim,stime,loop,updatePosition,interruptable,freezeLastFrame,blendTime,retainPedState )
	if isElement(ped) then
		setAnimation1 (ped,block,anim,stime,loop,updatePosition,interruptable,freezeLastFrame,blendTime,retainPedState)
		triggerServerEvent ( "applyAnimation", root,not(ped == localPlayer) and ped,block,anim,stime,loop,updatePosition,interruptable,freezeLastFrame,blendTime,retainPedState)
	end
end

function setAnimationProgress ( ped,animation,progress )
	if isElement(ped) then
		if animation then
			setPedAnimationProgress(ped,animation,progress)
			setElementData(ped,'anProgreess',{animation,progress})
		else
			setElementData(ped,'anProgreess',nil)
		end
	end
end

function setAnimationSpeed ( ped,animation,speed )
	if isElement(ped) then
		if animation then
			setPedAnimationSpeed(ped,animation,speed)
			setElementData(ped,'anSpeed',{animation,speed})
		else
			setElementData(ped,'anSpeed',nil)
		end
	end
end

function setAnimation1 ( ped,block,anim,stime,loop,updatePosition,interruptable,freezeLastFrame,blendTime,retainPedState )
	if isElement(ped) then
		if block then
			animations[ped] = {block,anim,stime,loop,updatePosition,interruptable,freezeLastFrame,blendTime,retainPedState}
		else
			animations[ped] = {nil}
		end
		setPedAnimation (ped,block,anim,stime or -1,getBoolen(loop,true),getBoolen(updatePosition,true),getBoolen(interruptable,true),getBoolen(freezeLastFrame,true),blendTime or 250,retainPedState )
	end
end
addEvent( "applyAnimation_C", true )
addEventHandler( "applyAnimation_C", root, setAnimation1 )

function setAnimation2 ( ped,block,anim,stime,loop,updatePosition,interruptable,freezeLastFrame,blendTime,retainPedState )
	if isElement(ped) then
		setPedAnimation (ped,block,anim,stime or -1,getBoolen(loop,true),getBoolen(updatePosition,true),getBoolen(interruptable,true),getBoolen(freezeLastFrame,true),blendTime or 250,retainPedState )
	end
end

progress2 = {}
function getLists()
	local tabl = {}
	for i,v in pairs(getElementsByType('player')) do
		table.insert(tabl,v)
	end
	for i,v in pairs(getElementsByType('ped')) do
		table.insert(tabl,v)
	end
	return tabl
end

offScreen = {}
function progress (  )
	for i,v in pairs(animations) do
		if isElement(i) then
			if isElementOnScreen(i) then
				if offScreen[i] then
					offScreen[i] = nil
					setAnimation2 ( i,unpack(v) )
				end
			else
				offScreen[i] = true
			end
		else
			animations[i] = nil
		end
	end
	
	
	for i,v in pairs(getLists()) do
		if getElementData(v,'anProgreess') then
			local an,pro,speed = unpack(getElementData(v,'anProgreess'))
			progress2[v] = progress2[v] or {}
			setPedAnimationSpeed(v,an,tonumber(speed) or 0)
			if (not (progress2[v][an] == pro)) then
				progress2[v][an] = pro
				setPedAnimationProgress ( v,an,pro)
			end
		end
		if getElementData(v,'anSpeed') then
			local an,pro = unpack(getElementData(v,'anSpeed'))
			setPedAnimationSpeed ( v,an,pro)
		end
	end
end
addEventHandler ( "onClientPreRender", root, progress )


function getBoolen(input,default)
	if (tostring(input) == 'nil') then
		return default
	else
		return input
	end
end
