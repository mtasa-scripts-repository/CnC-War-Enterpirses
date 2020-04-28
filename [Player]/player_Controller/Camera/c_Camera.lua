local rotX, rotY = 0, 0
local mouseFrameDelay = 0
local PI = math.pi
local enabled = true

local options = {
	mouseSensitivity = 0.07,
	allowdebug = true
}

-- Elements --
local camera = createObject(2996,0,0,0,0,0,0)
setElementCollisionsEnabled(camera,false)
setElementAlpha(camera,0)
setElementFrozen(camera,true)

addEventHandler( "onResourceStop", resourceRoot,
    function( resource )
		if isElement(camera) then
			destroyElement(camera)
		end
   end
)

toggleC = false


showFirstPerson = false
function firstPersonNull()
	if showFirstPerson then
		return
	end
	if getElementData(localPlayer,'Ped') then
		null("*marine_torso*",getElementData(localPlayer,'Ped') )
		null("*face*",getElementData(localPlayer,'Ped') )
		null("*hats*",getElementData(localPlayer,'Ped') )
		null("*helmet*",getElementData(localPlayer,'Ped') )
		null("*marine_torso*",localPlayer )
		null("*face*",localPlayer )
		null("*hats*",localPlayer )
		null("*helmet*",localPlayer )
	end
end

function thirdPersonUnNull()
	if getElementData(localPlayer,'Ped') then
		unnull("*marine_torso*",getElementData(localPlayer,'Ped') )
		unnull("*face*",getElementData(localPlayer,'Ped') )
		unnull("*hats*",getElementData(localPlayer,'Ped') )
		unnull("*helmet*",getElementData(localPlayer,'Ped') )
		unnull("*marine_torso*",localPlayer )
		unnull("*face*",localPlayer )
		unnull("*hats*",localPlayer )
		unnull("*helmet*",localPlayer )
	end
end

legsPrepped = {}
function prepPed(element)
	if isElement(getElementData(element,'Ped')) then
		if (getElementData(getElementData(element,'Ped'),'State.Teleported')) then
			if getElementData(element,'Ped') then
				null("*legs*",getElementData(element,'Ped') )
			end
			null("*torso*",element )
			null("*face*",element )
			null("*hats*",element )
			null("*helmet*",element )
			null("*arm*",element )
		else
			legsPrepped[element] = nil
			unnull("*torso*",element )
			unnull("*face*",element )
			unnull("*hats*",element )
			unnull("*helmet*",element )
			unnull("*arm*",element )
		end
	end
end

Count = 0

function usePed()
	if (getElementData(localPlayer,'State.Teleported')) then
		return getElementData(localPlayer,'Ped')
	else
		return localPlayer
	end
end


toggle = {}

function LastHit ( key, keyState )
	if (keyState == 'down') then
		lastHit = key
	else
		if (lastHit == key) then
			lastHit = nil
		end
	end
end

function LastHit2 ( key, keyState )
	if (keyState == 'down') then
		lastHit2 = key
	else
		if (lastHit2 == key) then
			lastHit2 = nil
		end
	end
end

function LastHit3 ( key, keyState )
	local key = (key == crouchControl) and 'crouch' or key
	if (keyState == 'down') then
		if (lastHit3 == key) then
			lastHit3 = nil
		else
			lastHit3 = key
		end
	end
end


function deathReset ()
	lastHit3 = nil
	lastHit2 = nil
	lastHit = nil
	setAnimation(localPlayer)
end
addEventHandler ( "onClientPlayerWasted", getLocalPlayer(), deathReset ) 


bindKey( "forwards", "both", LastHit2 )
bindKey( "left", "both", LastHit )
bindKey( "right", "both", LastHit)
bindKey( "backwards", "both", LastHit2 )

crouchControl = 'c'
bindKey( crouchControl, "both", LastHit3 )


function regularRender()
	if (isMTAWindowActive()) or (isCursorShowing()) then
		lastHit2 = nil
		lastHit = nil
	end



	if not ((getElementData(localPlayer,'Crouch') or 'c') == crouchControl) then
		unbindKey(crouchControl, "both", LastHit3 )
		crouchControl = getElementData(localPlayer,'Crouch') or 'c'
		bindKey(crouchControl, "both", LastHit3 )
	end
	
	toggleControl('crouch',false)
	posX,posY,posZ = getPedBonePosition ( localPlayer, 7 )
	
	if zoomDegree then
		zoomDegree = math.min(zoomDegree,math.max(4*((getElementData(localPlayer,'wep.Zoom') or 0)/3),4))
	end
	
	for i,v in pairs(getElementsByType('player')) do
		prepPed(v)
	end
	
	if not getPedOccupiedVehicle(localPlayer) then
		if walkAnimations then
			walkAnimations()
		end
	end
end

function getAnimation()
	local task,task2 = getPedTask (localPlayer, "primary", 3 )
	local task3 = getPedTask (localPlayer, "secondary", 1 )
	
	if (not (task == 'TASK_COMPLEX_JUMP')) and (not ((task2 == 'TASK_SIMPLE_CLIMB') or (task2 == 'TASK_COMPLEX_GO_TO_CAR_DOOR_AND_STAND_STILL'))) or isElement(getElementData(localPlayer,'turrent')) then
		if (lastHit2 == 'forwards') then
			if weapon.State.Mid then
				if (lastHit == 'left') then
					return 'FPS.Aim','Walk_FL',1.7
				elseif (lastHit == 'right') then
					return 'FPS.Aim','Walk_FR',1.7
				else
					return 'FPS.Aim','Walk_F',2.6
				end
			else
				return
			end
		elseif (lastHit2 == 'backwards') then
			if (lastHit == 'left') then
				return 'FPS.Aim','Walk_BL',1.5
			elseif (lastHit == 'right') then
				return 'FPS.Aim','Walk_BR',1.5
			else
				if weapon.State.Mid then
					return 'FPS.Aim','Walk_B',2.1
				else
					return 'ped','FightSh_BWD',1.3
				end
			end
		else
			if weapon.State.Mid then
				if (lastHit == 'left') then
					return 'FPS.Aim','Walk_L',1.5
				elseif (lastHit == 'right') then
					return 'FPS.Aim','Walk_R',1.5
				else
					if (lastHit3 == 'crouch') then
						return 'FPS.Aim.C','crouch',1
					end
					return
				end
			else
				if (lastHit == 'left') then
					return 'ped','run_left',1
				elseif (lastHit == 'right') then
					return 'ped','run_right',1
				else
					if (lastHit3 == 'crouch') then
						return 'ped','weapon_crouch',1
					end
					return
				end
			end
		end
	else
		return
	end
end

function walkAnimations()
	local group,animation,speed = getAnimation()
	
	if (getElementHealth(localPlayer) < 5) then
		setAnimation(localPlayer)
		return
	end
	
	
	if group then
		if (not (gGroup == group)) or (not (gAnimation == animation)) then
			gGroup = group
			gAnimation = animation
			
			setAnimation(localPlayer,gGroup,gAnimation,-1,true,true,false,true,280)
			
			if not weapon.State.Int then
				if (gAnimation == 'weapon_crouch') then
					if getElementData(localPlayer,'Ped') then
						setAnimation(getElementData(localPlayer,'Ped'),'FPS.Aim.C','Aim_M',-1,true,false,false,true,2)
					end
				else
					if getElementData(localPlayer,'Ped') then
						setAnimation(getElementData(localPlayer,'Ped'))
					end
				end
			end
		end
		
		
		if (getElementData(localPlayer,'State.Weapon')) then
			local mult = getKeyState('lalt') and 0.5 or 0.8
			setAnimationSpeed (localPlayer,gAnimation,((getElementData(localPlayer,'wep.Size') == 'Small') and speed*1.5 or speed*1.4)*mult)
		else
			local mult = getKeyState('lalt') and 0.3 or 1.1
			setAnimationSpeed (localPlayer,gAnimation,speed*mult)
		end
	else
		if gGroup then
			gGroup = nil
			gAnimation = nil

			if weapon.State.Mid then
				setAnimation(localPlayer,'FPS.Aim','Aim_Idle',300,false,false,false,true,300)
				setAnimation(localPlayer,nil)
			else
				setAnimation(localPlayer,'ped','idle_stance',300,false,false,false,false,300)
				setAnimation(localPlayer,nil)
			end
			setAnimationSpeed (localPlayer,nil)
		end
	end
end
addEventHandler ( "onClientRender", root, regularRender )


zoomDegree = 0
addEventHandler( "onClientKey", root, function(button,press) 
	if press then	
		if weapon.State.Aim then
			if button == (getElementData(localPlayer,'Zoom In') or "mouse_wheel_up") then
				if zoomDegree < math.max(4*(getElementData(localPlayer,'wep.Zoom')/3),4) then
					local blur = math.max(getElementData(localPlayer,'Blur2'),0)
					setElementData(localPlayer,'Blur2',math.min(blur+50,50))
					zoomDegree = math.min(zoomDegree+(0.5*(tonumber(getElementData(localPlayer,'Zoom Sensitivity')) or 1)),math.max(4*(getElementData(localPlayer,'wep.Zoom')/3),4))
					playSound('Sounds/zoom_in.wav')
				end
			elseif button == (getElementData(localPlayer,'Zoom Out') or "mouse_wheel_down") then
				if zoomDegree > -4 then
					zoomDegree = math.max(zoomDegree-(0.5*(tonumber(getElementData(localPlayer,'Zoom Sensitivity')) or 1)),-4)
					local blur = math.max(getElementData(localPlayer,'Blur'),0)
					setElementData(localPlayer,'Blur2',math.min(blur+50,50))
					playSound('Sounds/zoom_in.wav')
				end
			end
		end
	end
end )

fpsCooldown = 500

local weaponOffsets = {}
weaponOffsets['Small'] = Vector3(-0.08,-0.8,0.38)
weaponOffsets['Medium'] = Vector3(-0.2,-0.4,0.38)
weaponOffsets['Massive'] = Vector3(-0.2,-0.4,0.48)

function preRender (msSinceLastFrame)
	
	
	speed = (60/tonumber(getElementData(localPlayer,'FPS') or 60))
	
	-- Handle Blur Fading --
	setElementData(localPlayer,'Blur',(tonumber(getElementData(localPlayer,'Blur')) or 0)-5)
	setElementData(localPlayer,'Blur2',(tonumber(getElementData(localPlayer,'Blur2')) or 0)-2)
	-- # --
	
	-- Handle FPS calculations --
	fpsCooldown = fpsCooldown + speed
	
	if fpsCooldown > 50 then
		fpsCooldown = 0
		fps = math.floor((1 / msSinceLastFrame) * 1000)

		setElementData(localPlayer,'FPS',fps)
		local avg = math.floor(((getElementData(localPlayer,'FPS AVG') or 60)+fps)/2)
		
		setElementData(localPlayer,'FPS AVG',math.min(avg+1,60))
	end
	
	-- # --
	
	local enabled = not (getElementData(localPlayer,'Camera') or getPedOccupiedVehicle(localPlayer))
	
	if enabled then
		
		if not fpsToggle then
			setElementData(localPlayer,'Firstperson',true)
		end
		
		firstPersonNull()
		
		fpsToggle = true
		
		local cameraAngleX = rotX 
		local cameraAngleY = rotY
		
		if isPedInVehicle ( localPlayer ) then
			local dist = math.rad ( -getPedRotation ( localPlayer ) )
		
			if dist > PI then
				dist = dist - 2 * PI
			elseif rotX < -PI then
				dist = dist + 2 * PI
			end
		
			cameraAngleX = cameraAngleX + dist
		end
		
		local freeModeAngleZ = math.sin ( cameraAngleY )
		local freeModeAngleY = math.cos ( cameraAngleY ) * math.cos ( cameraAngleX )
		local freeModeAngleX = math.cos ( cameraAngleY ) * math.sin ( cameraAngleX )
		
		
		local isCrouching = (lastHit3 == 'crouch') and (not lastHit) and (not lastHit2)

		local aiming = (not isCrouching) and (getTickCount()-(weapon.Delay.Weapon or getTickCount()) > 300) or (getTickCount()-(weapon.Delay.Weapon or getTickCount()) > 100)


		local weaponEnt = getElementData(localPlayer,'Weapon')
		
		options.mouseSensitivity = 0.07
		
		if aiming and isElement(weaponEnt) then
			
			if weapon.State.Aim then
				options.mouseSensitivity = math.max(0.03-(0.1*(getElementData(localPlayer,'wep.Zoom') or 1)),0.025)
			end
			
			local wepSmall = (getElementData(localPlayer,'wep.Size') == 'Small')
			local wepLarge = (getElementData(localPlayer,'wep.Size') == 'Large')
			local wepMassive = (getElementData(localPlayer,'wep.Size') == 'Massive')
		
		
			local offY,offZ = (wepSmall and -0.6 or wepMassive and -0.8 or wepLarge and -1.6 or -0.9),(wepSmall and 0.15 or wepMassive and 0.3 or wepLarge and 0.18 or 0.25)
			
			local Ax,Ay,Az = unpack(getElementData(localPlayer,'wep.Offset') or {0,0,0})
			local offset = weapon.State.Aim and (Vector3(Ax,Ay+offY,Az+offZ)) or (weaponOffsets[getElementData(localPlayer,'wep.Size')] or weaponOffsets['Medium'])
			
			if (not weapon.State.Aim) then
				zoomDegree = 0
			end
			
			fov = (not weapon.State.Aim) and 85 or (80-(10*(getElementData(localPlayer,'wep.Zoom') or 1)-1)-(5*(zoomDegree/2)))
			
			
			local matrix = weaponEnt.matrix
			local posVector = Vector3(offset.x,offset.y,offset.z)
			local offsets = matrix:transformPosition(posVector)
			
			local camTargetX = offsets.x + freeModeAngleX*100
			local camTargetY = offsets.y + freeModeAngleY*100
			local camTargetZ = offsets.z + freeModeAngleZ*100
			
			local xr,yr,zr = findRotation3D(offsets.x,offsets.y,offsets.z,camTargetX,camTargetY,camTargetZ)
			
			if not getPedOccupiedVehicle(localPlayer) then
				local _,_,zra = getElementRotation(localPlayer)
				local _,_,zrb = getElementRotation(getCamera())

				local _,taskb = getPedTask ( localPlayer, "primary", 3 )
				
				if (not (taskb == 'TASK_SIMPLE_CLIMB')) and (not (taskb == 'TASK_COMPLEX_GO_TO_CAR_DOOR_AND_STAND_STILL')) and (not isElement(getElementData(localPlayer,'turrent'))) then
					setElementRotation(localPlayer,0,0,zr,'default',true)
					setElementData(localPlayer,'Rot',zr)
				end
			end
			
			local matrix = weaponEnt.matrix
			local posVector = Vector3(offset.x,offset.y-0.05,offset.z)
			local offsets = matrix:transformPosition(posVector)
			setElementPosition(camera,offsets.x,offsets.y,offsets.z)
			local posVector = Vector3(offset.x,offset.y+1,offset.z)
			local offsett = matrix:transformPosition(posVector)
			
			if weapon.State.Weapon then
				local xr,yr,zr = findRotation3D(offsets.x,offsets.y,offsets.z,offsett.x,offsett.y,offsett.z) 
				setElementRotation(camera,xr,yr,zr)
			else
				local xr,yr,zr = findRotation3D(offsets.x,offsets.y,offsets.z,offsett.x,offsett.y,offsets.z) 
				setElementRotation(camera,xr,yr,zr)
			end
		elseif isElement(getElementData(localPlayer,'turrent')) then
			fov = nil
			local vehicle = (getElementData(localPlayer,'turrent'))
			
			local x,y,z = getVehicleComponentPosition(vehicle,'Turrent_Stand','root')
			local matrix = vehicle.matrix
			local posVector = Vector3(x,y,z+2)
			local offsett = matrix:transformPosition(posVector)
			
			setElementPosition(camera,offsett.x,offsett.y,offsett.z)
			
			
			local vxr,yr,zr = getVehicleComponentRotation(vehicle,'Turrent_Machine','world')

			
			local xr,yr = getElementRotation(vehicle)
			setElementRotation(camera,xr,yr,zr-90)
			setElementRotation(localPlayer,xr,yr,zr-90,'default',true)
		else
			fov = nil
			posX,posY,posZ = posX or 0,posY or 0,posZ or 0
			
			
			setElementPosition(camera,posX,posY,posZ+(isPedDead(localPlayer) and 5 or 0))
			
			local camTargetX = posX + freeModeAngleX*100
			local camTargetY = posY + freeModeAngleY*100
			local camTargetZ = posZ + freeModeAngleZ*100
			
			local xr,yr,zr = findRotation3D(posX,posY,posZ,camTargetX,camTargetY,camTargetZ) 
			setElementRotation(camera,xr,yr,zr)
			
			
			if not getPedOccupiedVehicle(localPlayer) then
				local allow = not (getPedControlState(localPlayer,'forwards') and (getPedControlState(localPlayer,'left') or getPedControlState(localPlayer,'right')))
			
				if allow then

					local _,_,zra = getElementRotation(localPlayer)
					local _,_,zrb = getElementRotation(getCamera())

					local _,taskb = getPedTask ( localPlayer, "primary", 3 )
					if (not (taskb == 'TASK_SIMPLE_CLIMB')) and (not (taskb == 'TASK_COMPLEX_GO_TO_CAR_DOOR_AND_STAND_STILL')) then
						setElementRotation(localPlayer,0,0,zr,'default',true)
						setElementData(localPlayer,'Rot',zr)
					end
				end
			end
		end
		
		
		local matrix = camera.matrix
		local posVector = Vector3(0,5,0)
		local offset = matrix:transformPosition(posVector)
			
		local matrix = camera.matrix
		local posVector = Vector3(0,-0.2,0)
		local offset2 = matrix:transformPosition(posVector)
		
		local matrix = camera.matrix
		local posVector = Vector3(0,1,0)
		local offset3 = matrix:transformPosition(posVector)
		
		local camPosX,camPosY,camPosZ = getElementPosition(camera)
		
		collision = nil
		
		local xa,ya,za = getElementRotation(camera)
		local ya = -ya
		
		if not getElementData(localPlayer,'Freecam') then
			if not getPedOccupiedVehicle(localPlayer) then
				local hit, x, y, z, elementHit = processLineOfSight ( offset2.x, offset2.y, offset2.z, offset3.x, offset3.y, offset3.z,true,false,false )
				if hit then
					collision = true
					setNearClipDistance(0.1)
					setCameraMatrix (offset2.x,offset2.y, offset2.z, offset.x,offset.y,offset.z,ya,(fov or 83))
				else
					setNearClipDistance(0.2)
					setCameraMatrix ( camPosX, camPosY, camPosZ, offset.x,offset.y,offset.z,ya,fov or 83 )
				end
			else
				setNearClipDistance(0.2)
				setCameraMatrix ( camPosX, camPosY, camPosZ, offset.x,offset.y,offset.z,ya,fov or 83 )
			end
		end
		controlAiming()
	else
		if fpsToggle then
			thirdPersonUnNull()
			fpsToggle = nil
			if not (getElementData(localPlayer,'Camera')) then
				setCameraTarget(localPlayer)
			end
			
			setElementData(localPlayer,'Firstperson',nil)
		end
	end
end
addEventHandler ( "onClientPreRender", root, preRender,false,"low-1" )

weapon = {State = {},Delay = {},Previous = {fade = -1},speed = 1,fade = {main=0},progress = 0,aimType = 'Aim_S',AimState = 'FPS.Aim'}


function controlAiming()
	
	local aim_State = getPedControlState(localPlayer,'aim_weapon')
	local weapon_H = (getElementData(localPlayer,'weapon_Slot'))
	local ped = getElementData(localPlayer,'Ped')
	
	local task,task2 = getPedTask (localPlayer, "primary", 3 )
	local task3 = getPedTask (localPlayer, "secondary", 1 )

	local isCrouching = (lastHit3 == 'crouch') and (not lastHit) and (not lastHit2)
	-- Jump Handler --
	if weapon.State.Mid then
		if getKeyState(getElementData(localPlayer,'Jump [Has to match MTA bind]') or 'lshift') then
			if ((not isMTAWindowActive()) and (not isCursorShowing())) then
				if getPedControlState(localPlayer,'jump') then
					if not isMTAWindowActive () then
						if not weapon.fade.jump then
							weapon.fade.jump = 14
							weapon.fade.main = 50
						end
					end
				end
			end
		else
			if weapon.fade.jump then
				if weapon.fade.jump < -10 then
					weapon.fade.jump = nil
				end
			end
		end
	end
	
	if weapon.fade.jump then
		weapon.fade.jump = weapon.fade.jump - speed
		if weapon.fade.jump > 20 then
			if (not isPedDead(localPlayer)) then
				setPedControlState(localPlayer,'jump',false)
				setPedControlState(localPlayer,'forwards',false)
			end
		elseif weapon.fade.jump < 0 then
			if (not isPedDead(localPlayer)) then
				setPedControlState(localPlayer,'jump',true)
			end
		end
	end
	-- Jump Handler End --
	
	if not (weapon_H == weapon.Previous.wep) then
		if weapon.Previous.wep then
			weapon.switch = 23
			weapon.fade.main = 23
		end
		weapon.Previous.wep = weapon_H
	end
	
	if weapon.fade.main then
		weapon.fade.main = weapon.fade.main - speed
	end

	weapon.switch = weapon.switch or 0
	if weapon.switch then
		if weapon.switch > 0 then
			weapon.switch = weapon.switch -1
			setElementData(localPlayer,'Switch',weapon.switch)
		else
			setElementData(localPlayer,'weapon_Slot_E',weapon_H)
		end
	end
	
	
	local isNotSpace = ((isCursorShowing() or isMTAWindowActive()) and true) or (not getKeyState(getElementData(localPlayer,'Put Down Weapon') or 'space'))
	
	if (task == 'TASK_COMPLEX_JUMP') then
		weapon.fade.main = 13
	end
	
	if (task2 == 'TASK_COMPLEX_GO_TO_CAR_DOOR_AND_STAND_STILL') then
		weapon.fade.main = weapon.fade.main + 1
	end
	
	--- getTickCount()
						
	toggleControl('sprint',false)
	if weapon_H and (not isElement(getElementData(localPlayer,'turrent'))) and (not getPedOccupiedVehicle(localPlayer)) and (weapon.fade.main < 0) and (not (task == 'TASK_COMPLEX_JUMP')) and (not ((task2 == 'TASK_SIMPLE_CLIMB') or (task2 == 'TASK_COMPLEX_GO_TO_CAR_DOOR_AND_STAND_STILL'))) and (isNotSpace) and (not isPedDead(localPlayer)) then
		if weapon.State.Int then -- Int
			if weapon.State.Mid then -- Med
				toggleControl('fire',false)
				-- Crouch Handler -- 
				
				if not AimState then
					setElementData(localPlayer,'State.Weapon',2)
					setElementData(localPlayer,'State.Weapon_Aim',2)
					weapon.progress = 0
					weapon.State.Weapon = nil
				end
				
				if isCrouching and (not lastHit2) and (not lastHit) then
					if not (AimState == 'FPS.Aim.C') then
						AimState = 'FPS.Aim.C'
						setAnimation(ped,'FPS.Aim.C',weapon.aimType,-1,false)
					end
				else
					if not (AimState == 'FPS.Aim') then
						AimState = 'FPS.Aim'
						setAnimation(ped,'FPS.Aim',weapon.aimType,-1,false)
					end
				end
				
				if weapon.State.Weapon then -- Weapon
					setAnimationSpeed (ped,weapon.aimType,0)
					
					if ((getTickCount()-weapon.Delay.Aim) > 500) then
						setElementData(localPlayer,'State.Weapon_Aim',4)
					end
					
					if not weapon.Delay.Weapon then
						weapon.Delay.Weapon = getTickCount()
					end
					
					if getKeyState(getElementData(localPlayer,'Aim') or 'mouse2') then
						weapon.State.Aim = true
						setElementData(localPlayer,'Zoom',true)
					else
						weapon.State.Aim = nil
						setElementData(localPlayer,'Zoom',nil)
					end
				else
					if ((getTickCount()-weapon.Delay.Aim) > 100) then
						setAnimationSpeed (ped,weapon.aimType,0)
						setAnimationProgress(ped,weapon.aimType,0.5)
						
						weapon.State.Weapon = true
						setElementData(localPlayer,'State.Weapon',3)
						setElementData(localPlayer,'State.Weapon_Aim',3)
					else
						if not weapon.Delay.Aim then
							weapon.Delay.Aim = getTickCount()
						end
					end
				end
			else
				if ((getTickCount()-(weapon.Delay.Int or getTickCount())) > 300) then
					if getElementData(ped,'State.Teleported') then
						setElementData(localPlayer,'State.Light.Fade',true)
						weapon.State.Mid = true
						setAnimationProgress(ped,weapon.aimType,0.5)
						
						local prefix = isCrouching and '.C' or ''
						
						setAnimation(localPlayer,'FPS.Aim'..prefix,'Aim_Idle',300,false,false,false,true,300)
						local weaponSize = getElementData(localPlayer,'wep.Size')
						
						if (weaponSize == 'Small') then
							weapon.aimType = 'Aim_S'
						else
							weapon.aimType = 'Aim_M'
						end
						
						setAnimation(ped,'FPS.Aim'..prefix,weapon.aimType,-1,false)
						AimState = 'FPS.Aim'
						weapon.Delay.Aim = getTickCount()
						setAnimationProgress(ped,nil)
						if isCrouching then
							setAnimationSpeed (ped,weapon.aimType,1)
						else
							setAnimationSpeed (ped,weapon.aimType,1.5)
						end
						setElementData(localPlayer,'State.Weapon',2)
						setElementData(localPlayer,'State.Weapon_Aim',2)
						weapon.progress = 0
					end
				else
					if not tonumber(weapon.Delay.Int) then
						weapon.Delay.Int = getTickCount()
					end
				end
			end
		else
			setElementData(localPlayer,'State.Weapon',1)
			setElementData(localPlayer,'State.Weapon_Aim',1)
			triggerServerEvent ( "prepLegs",root,isCrouching)
			weapon.State.Int = true
			weapon.Delay.Int = getTickCount()
			weapon.Delay.Fade = nil
		end
	else
		setElementData(localPlayer,'Zoom',nil)
		toggleControl('fire',true)
		if weapon.State.Mid then
			setElementData(localPlayer,'State.Weapon_Aim',0)
			weapon.State.Mid = nil
			if ((task3 == 'TASK_SIMPLE_DUCK')) or isCrouching then
				setAnimation(ped,'ped','weapon_crouch',-1,false)
				setAnimation(localPlayer,'ped','weapon_crouch',-1,false,false,true,false)
			else
				setAnimation(ped,'ped','idle_stance',-1,false)
				setAnimation(localPlayer,'ped','idle_stance',-1,false,false,true,false)
			end
		end
		
		if weapon.Delay.Weapon then
			weapon.Delay.Weapon = nil
		end
		
		if (getTickCount()-(tonumber(weapon.Delay.Fade) or getTickCount()) > 200) then
			if weapon.State.Int then
				setElementData(localPlayer,'State.Weapon',nil)
				setElementData(localPlayer,'State.Light.Fade',nil)
				triggerServerEvent ( "prepLegs",root)
				if (not (lastHit3 == 'crouch')) then
					setAnimation(localPlayer,'ped','idle_stance',300,false,false,false,false,300)
					setAnimation(localPlayer,nil)
				end
				gGroup = nil
				gAnimation = nil
				weapon.State = {}
			end
		else
			if not weapon.Delay.Fade then
				weapon.Delay.Fade = getTickCount()
			end
		end
	end
	
	if weapon.State.Weapon then
		local maximum = maximum or PI/2.6
		local minumum = minumum or -PI / 6

		local upperSen = 1
		local lowerSen = 1
				
		local zra = rotY>0 and ((rotY*upperSen)/maximum) or ((rotY*lowerSen)/-minumum)
		local zra = (zra + 1)/2
				
		rotation = (zra+ (tonumber(getElementData(ped,'rotAddition')) or 0))
			
		setAnimationProgress(ped,weapon.aimType,rotation)
	end
end

function isMinimized()
	return Minimized
end

function handleMinimize()
    Minimized = true
end
addEventHandler( "onClientMinimize", root, handleMinimize )

function handleMinimize()
    Minimized = true
end
addEventHandler( "onClientMinimize", root, handleMinimize )

function handleRestore( )
	Minimized = nil
end
addEventHandler("onClientRestore",root,handleRestore)


function mousecalc ( _, _, aX, aY )
	if isCursorShowing ( ) or isMTAWindowActive ( ) or isMinimized ( ) then
		mouseFrameDelay = 5
		return
	elseif mouseFrameDelay > 0 then
		mouseFrameDelay = mouseFrameDelay - 1
		return
	end
		
	local aX = aX - screenWidth / 2 
	local aY = aY - screenHeight / 2
	 
	local aY = options.invertMouseLook and -aY or aY
	
	rotX = rotX + aX * options.mouseSensitivity * 0.01745 * (tonumber(getElementData(localPlayer,'Look Sensitivity')) or 1)
		
	local mul = getKeyState('mouse3') and -1 or 1
	rotY = rotY - aY * options.mouseSensitivity * 0.01745 * mul * (tonumber(getElementData(localPlayer,'Look Sensitivity')) or 1)
	 
	if rotX > PI then
		rotX = rotX - 2 * PI
	elseif rotX < -PI then
		rotX = rotX + 2 * PI
	end
		
	if rotY > PI then
		rotY = rotY - 2 * PI
	elseif rotY < -PI then
		rotY = rotY + 2 * PI
	end
	 

	maximum = PI/2.4
	minumum = -PI / 4.5
	rotY = math.clamp (-PI / 4.5, rotY, PI/2.4)
end
addEventHandler ( "onClientCursorMove", root, mousecalc )


function math.clamp ( low, value, high )
    return math.max ( low, math.min ( value, high ) )
end