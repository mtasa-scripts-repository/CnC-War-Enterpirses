
animations = {}
function setAnimation ( ped,block,anim,stime,loop,updatePosition,interruptable,freezeLastFrame,blendTime,retainPedState  )
	local ped = ped or client
	animations[ped] = {block,anim,stime,loop,updatePosition,interruptable,freezeLastFrame,blendTime,retainPedState}
	for i,v in pairs(getElementsByType('player')) do
		if not (v == client) then
			triggerClientEvent ( v, "applyAnimation_C", v,ped, block,anim,stime,loop,updatePosition,interruptable,freezeLastFrame,blendTime,retainPedState)
		end
	end
end
addEvent( "applyAnimation", true )
addEventHandler( "applyAnimation", root, setAnimation )

function greetPlayer ( )
	for i,v in pairs(animations) do
		if isElement(i) then
			local block,anim,stime,loop,updatePosition,interruptable,freezeLastFrame,blendTime,retainPedState = unpack(v)
			triggerClientEvent ( source, "applyAnimation_C", source,i, block,anim,stime,loop,updatePosition,interruptable,freezeLastFrame,blendTime,retainPedState)
		else
			animations[i] = nil
		end
	end
end
addEventHandler ( "onPlayerJoin", getRootElement(), greetPlayer )