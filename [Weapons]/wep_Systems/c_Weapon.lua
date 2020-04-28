
Bullets = {}
BulletMarkers = {}

function findRotation3D( x1, y1, z1, x2, y2, z2 ) 
	local rotx = math.atan2 ( z2 - z1, getDistanceBetweenPoints2D ( x2,y2, x1,y1 ) )
	rotx = math.deg(rotx)
	local rotz = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
	rotz = rotz < 0 and rotz + 360 or rotz
	return rotx, 0,rotz
end



function createBulletB(tabl,add,sPlayer,id)

	local x,y,z = unpack(add)
		
	local posx,posy = unpack(getElementData(sPlayer,'wep.Pos'))
	local tarx,tary,tarz = unpack(getElementData(sPlayer,'wep.Target'))

	tabl[2],tabl[3] = posx,posy


	tabl[11],tabl[12] = posx,posy
	tabl[5],tabl[6] = tarx+x,tary+y
	
	local xa,ya,za = findRotation3D(tabl[5],tabl[6],tabl[7],tabl[2],tabl[3],tabl[4] ) 
	
	if (id < 5) then
		createEffect ( 'gunsmoke', tabl[2],tabl[3],tabl[4],xa,ya,za )
	end
	
	if (id < 2) then
		playShotSound(getElementData(sPlayer,'weapon_Slot'),tabl[2],tabl[3],tabl[4])
		createEffect ( 'gunsmoke', tabl[2],tabl[3],tabl[4],xa,ya,za )
	end
	
	local weapChart = weaponChart[getElementData(sPlayer,'weapon_Slot') or 'AR']
	
	local model = weapChart[9]
	if model then
		tabl[16] = exports.cStream:CcreateObject(model,0,0,0)
		tabl[17] = model
		setElementData(tabl[16],'Weapon',localPlayer)
		
		local xa,ya,za = findRotation3D(tabl[2],tabl[3],tabl[4],tabl[5],tabl[6],tabl[7] ) 
		
		if model == 'Rocket' then
			createEffect ( 'explosion_tiny', tabl[5],tabl[6],tabl[7],xa,ya,za )
		end
	end
	

	if (getElementData(sPlayer,'weapon_Slot') == 'Sniper') then
		tabl[18],tabl[19],tabl[20] = tabl[2],tabl[3],tabl[4]
		tabl[16] = false
		tabl[17] = false
	end
	
	tabl[15] = sPlayer
	table.insert(Bullets,tabl)
end

addEvent( "createBulletC", true )
addEventHandler( "createBulletC", localPlayer, createBulletB )

weaponChart = {}
Holes = {}
sniperTrails = {}

-- FireSpeed, Bullet Speed, Drop, Kickback, Kickback time,  Time in air, Damage, Delay Multiplier, Projectial model, Cool down, Cool down rest
weaponChart['AR'] = {10,5.2,0.0001,0.01,9,60,25,1.1}
weaponChart['Shotgun'] = {100,4.4,0.00005,0.05,40,30,10,1.5}
weaponChart['Pistol'] = {45,7.5,0.00001,0.029,28,70,60,2}
weaponChart['BR'] = {13,4,0.00001,0.01,8,70,25,1.1,nil,3,5}
weaponChart['Sniper'] = {200,8,0.00001,0.09,40,70,130,2}
weaponChart['Rocket Launcher'] = {250,4,0.0003,0.1,40,50,1000,4,'Rocket'}

limit = 300
coolDown = 0
lastFire = 0

bulletHoles = {}


function getPositionFromElementOffset(element,offX,offY,offZ)
    local m = getElementMatrix ( element )  -- Get the matrix
    local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
    local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
    local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
    return x, y, z   
end

function getOffsetFromXYZ( mat, vec )
    mat[1][4] = 0
    mat[2][4] = 0
    mat[3][4] = 0
    mat[4][4] = 1
    mat = matrix.invert( mat )
    local offX = vec[1] * mat[1][1] + vec[2] * mat[2][1] + vec[3] * mat[3][1] + mat[4][1]
    local offY = vec[1] * mat[1][2] + vec[2] * mat[2][2] + vec[3] * mat[3][2] + mat[4][2]
    local offZ = vec[1] * mat[1][3] + vec[2] * mat[2][3] + vec[3] * mat[3][3] + mat[4][3]
    return offX, offY, offZ
end

function createBullet(chart,addx,addy,addz,bsize,id)
	local id = id or 1
	local addx,addy,addz = (tonumber(addx) or 0),(tonumber(addy) or 0),(tonumber(addz) or 0)
	local bsize = tonumber(bsize) or 1
	
	local posx,posy,posz = unpack(getElementData(localPlayer,'wep.Pos'))
	local tarx,tary,tarz = unpack(getElementData(localPlayer,'wep.Target'))
	
	
	if getElementData(localPlayer,'wep.Pos') then
		local tabl = {getElementData(localPlayer,'weapon_Slot'),posx,posy,posz,tarx,tary,tarz+addz,chart[6],math.random(155,255),(math.random(50,100)/100)*bsize,posx,posy,posz,math.random(-100000,100000)}
		triggerServerEvent ( "createBullet", resourceRoot, tabl,{addx,addy,addz},id,getElementData(localPlayer,'weapon_Slot') )
	end
end

sniperTrailTime = 200

coolDown2 = 0

tickCount = getTickCount()

wepCool = {}
function positionBullet()
	
	Tchange = (getTickCount()-tickCount)/10
	tickCount = getTickCount()

	limit = tonumber(getElementData(localPlayer,'Bullet Hole Limit')) or limit
	
	local fpsMult = math.min(60/(tonumber(getElementData(localPlayer,'FPS') or 60)),1)
	
	coolDown = coolDown - Tchange
	coolDown2 = coolDown2 - Tchange
	local chart = weaponChart[getElementData(localPlayer,'weapon_Slot')] or weaponChart['AR']
	
	local ped = getElementData(localPlayer,'Ped')
	


	
	if getElementData(localPlayer,'weapon_Slot') then 
		if getKeyState('mouse1') and ((tonumber(getElementData(localPlayer,'State.Weapon_Aim')) or 0) > 3) and (coolDown < 0) and (coolDown2<0) and (not isMTAWindowActive ()) and (not isCursorShowing()) and (not getElementData(localPlayer,'Reload')) then
			if ((tonumber(getElementData(localPlayer,'Ammo.'..getElementData(localPlayer,'weapon_Slot'))) or 0) > 0) then
				coolDown = chart[1]
				coolDown2 = chart[5]*chart[8]
				
				
				
				wepCool[getElementData(localPlayer,'weapon_Slot')] = (wepCool[getElementData(localPlayer,'weapon_Slot')] or 0) + 1

				if chart[10] then
					if wepCool[getElementData(localPlayer,'weapon_Slot')] > chart[10] then
						coolDown = coolDown * chart[11]
						coolDown2 = coolDown
						wepCool = {}
					end
				end
				
				if (getElementData(localPlayer,'weapon_Slot') == 'Shotgun') then
					for i = 1,15 do
						createBullet(chart,math.random(-50,50)/1000,math.random(-50,50)/1000,math.random(-50,50)/1000,0.8,i)
					end
				else
					createBullet(chart)
				end
				
				lastFire = 0
			else
				coolDown = 50
				coolDown2 = 50
				local x,y,z = getElementPosition(localPlayer)
				playDryFire(x,y,z)
			end
			
		else
			lastFire = lastFire + Tchange
			
			if (not getKeyState('mouse1')) then
				coolDown = (coolDown > 20) and 10 or coolDown
				coolDown = coolDown - 2
			end
			
			if (not isCursorShowing()) then
				if (lastFire <= chart[5]) then
					local progress = (lastFire/chart[5])

					if (progress > 0.5) then
						local pro = (1-(progress))*2
						setElementData(ped,'rotAddition',chart[4]*pro)
						setElementData(localPlayer,'chSize',chart[4]*pro)
					else
						local pro = ((progress)/0.5)
						setElementData(ped,'rotAddition',chart[4]*pro)
						setElementData(localPlayer,'chSize',chart[4]*pro)
					end
				end
			end
		end
	end
	
	
	for i = 1,#Bullets do
		if Bullets[i] then
			local weapon,sx,sy,sz,tx,ty,tz,t,color,sizea,sxF,syF,szF,id,creator,model,mType,sox,soy,soz,flyBy = unpack(Bullets[i])
			
			local chart = weaponChart[weapon] or weaponChart['AR']
			
			local t = t - (0.1*Tchange)
			
			local size = math.min((t/chart[6]),1)
			
			if model then
				local mxr,myr,mzr = findRotation3D( sx,sy,sz,tx,ty,tz ) 
				setElementRotation(model,mxr,myr,mzr)
				setElementPosition(model,sx,sy,sz)
			else
				if getScreenFromWorldPosition(sx,sy,sz,0.1) then
					dxDrawLine3D (sx,sy,sz,tx,ty,tz, tocolor ( color, 155, 0, 50*size ), size*sizea)
				end
			end
			local flyBy = flyBy or createFlyBy(sx,sy,sz,weapon) 
			setElementPosition(flyBy,sx,sy,sz)
			
			if not (weapon == 'Rocket Launcher') then
				local xa,ya,za = getCameraMatrix()
				local distance = (10-math.min(getDistanceBetweenPoints3D ( sx,sy,sz,xa,ya,za ),10))/8
				setSoundVolume (flyBy,distance)
			end
			
			if sox then
				if sniperTrails[sox] then
					local sTime = sniperTrails[sox][7] or sniperTrailTime
					sniperTrails[sox] = {sox,soy,soz,tx,ty,tz,sTime}
				else
					sniperTrails[sox] = {sox,soy,soz,tx,ty,tz,sniperTrailTime}
				end
			end
			
			local sTime = sox and (tonumber((sniperTrails[sox] or {})[7]) or 0) or 0

			
			local additionx,additiony,additionz = (sx-tx),(sy-ty),(sz-tz)
			
			local additionx = -(additionx*(chart[2]*Tchange)) / 2
			local additiony = -(additiony*(chart[2]*Tchange)) / 2
			
			local mult = mType and 1 or ((t>(chart[6]/2)) and -1 or 1)
			local additionz = ((-additionz*(chart[2]*Tchange)) / 2) - ((chart[3]*mult)*Tchange)

			local hit,x,y,z, elementHit,nx,ny,nz,mat,_,bone = processLineOfSight ( sxF,syF,szF,tx,ty,tz )
			
			Bullets[i] = {weapon,sx+additionx,sy+additiony,sz+additionz, tx+additionx,ty+additiony,tz+additionz,t,color,sizea or false,sx or false,sy or false,sz or false,id or false,creator or false,model or false,mType or false,(sTime > 5) and sox or false,soy or false,soz or false,flyBy}
			
			
			if (t < 0) or hit then
				
				if model then
					destroyElement(model)
				end
				
				if flyBy then
					clearSound(flyBy)
				end
				
				
				if hit then
					
					if elementHit and not (elementHit == creator) then
						if (getElementType(elementHit) == 'vehicle') or (getElementType(elementHit) == 'player') then
						
							
							if getElementType(elementHit) == 'player' then
								fxAddBlood ( x,y,z,nx,ny,nz,2,t)
								playImpactSound(x,y,z,mat,true)
							else
								playImpactSound(x,y,z,mat)
								fxAddBulletImpact ( x,y,z,nx,ny,nz,t)
							end

							if (mType == 'Rocket') then
								playExplosion(x,y,z)
								createEffect ( 'explosion_medium',x,y,z,nx,ny,nz)
								triggerServerEvent ( "triggerDamage", resourceRoot,elementHit,id,bone,chart[7],creator,mType,x,y,z )
							else
								triggerServerEvent ( "triggerDamage", resourceRoot,elementHit,id,bone,chart[7],creator,mType,x,y,z )
							end
						else
							
							if (mType == 'Rocket') then
								playExplosion(x,y,z)
								triggerServerEvent ( "triggerDamage", resourceRoot,elementHit,id,bone,chart[7],creator,mType,x,y,z )
								createEffect ( 'explosion_medium',x,y,z,nx,ny,nz)
							else
								playImpactSound(x,y,z,mat)
								if mat == 10 then
									fxAddBulletImpact( x,y,z,nx,ny,nz,size*10,0,1)
									fxAddBulletImpact( x,y,z,nx,ny,nz,size*10,0,1)
								elseif mat == 43 then
									fxAddBulletImpact( x,y,z,nx,ny,nz,size*5,0,1)
									fxAddWood( x,y,z,nx,ny,nz,size*5,0,1)
								else
									fxAddBulletImpact ( x,y,z,nx,ny,nz,size)
								end
							end
						end
					end

					
					local hx = ((x*50)+sxF)/51
					local hy = ((y*50)+syF)/51
					local hz = ((z*50)+szF)/51
					
					if (getElementType(elementHit) == 'vehicle') or (getElementType(elementHit) == 'player') then
						local x,y,z = getOffsetFromXYZ( getElementMatrix(elementHit), {hx,hy,hz} )
						local xa,ya,za = getOffsetFromXYZ( getElementMatrix(elementHit), {hx+nx,hy+ny,hz+nz} )
						table.insert(Holes,{x,y,z,xa,ya,za,100,math.random(1,8),math.random(5,9)/((mType == 'Rocket') and 35 or 150),elementHit})
					else
					
						
						local marker = createBulletMarker(x)
						local scale = math.random(5,9)/((mType == 'Rocket') and 35 or 150)
						local xr,yr,zr = findRotation3D( x,y,z,x+(nx*5),y+(ny*5),z+(nz*5) ) 
						setElementRotation(marker,xr,yr,zr)
						setElementPosition(marker,hx,hy,hz)
						
						local matrix = marker.matrix
						local newPosition1 = matrix:transformPosition(Vector3(0,0,scale))
						local newPosition2 = matrix:transformPosition(Vector3(0,0,-scale))
						local newPosition3 = matrix:transformPosition(Vector3(0,scale,0))
						
						local vectors = {newPosition1.x,newPosition1.y,newPosition1.z,newPosition2.x,newPosition2.y,newPosition2.z,newPosition3.x,newPosition3.y,newPosition3.z}
						
						removeBulletMarker(x)
						
						table.insert(Holes,{hx,hy,hz,nx,ny,nz,5000,math.random(1,8),scale,nil,vectors})
					end
				end

				table.remove(Bullets,i)
			end
		end
	end
end

function render2 ()
	local overLimit = (#Holes-(limit*2))
	
	if (#Holes > limit) then
		Holes[1][7] = math.max(20,Holes[1][7])
	end
					
	for i = 1,#Holes do
	
		if overLimit > 0 then
			if (i <= overLimit) then
				table.remove(Holes,i)
			end
		end
		
		if Holes[i] then
			local x,y,z,xr,yr,zr,t,hole,scale,elementHit,vectors = unpack(Holes[i])

			bulletHoles[hole] = bulletHoles[hole] or dxCreateTexture("Textures/bullet_hole["..hole.."].png",'dxt5',true)


			local alpha = math.max(math.min((t/20),1),0)

			if getScreenFromWorldPosition (x,y,z,0.1) then
				if elementHit then
					
					local desiredRelativePosition = Vector3(x,y+scale,z)
					local matrix = elementHit.matrix
					local newPosition = matrix:transformPosition(desiredRelativePosition)
					local xa,ya,za = newPosition.x,newPosition.y,newPosition.z

					local desiredRelativePosition = Vector3(x,y-scale,z)
					local matrix = elementHit.matrix
					local newPosition = matrix:transformPosition(desiredRelativePosition)
					local x,y,z = newPosition.x,newPosition.y,newPosition.z

					local desiredRelativePosition = Vector3(xr,yr,zr)
					local matrix = elementHit.matrix
					local newPosition = matrix:transformPosition(desiredRelativePosition)
					local xra,yra,zra = newPosition.x,newPosition.y,newPosition.z

					if (math.floor((zrc or 0)*10) == 0) then
						dxDrawMaterialLine3D(x,y,z,xa,ya,za, bulletHoles[hole], scale*2,tocolor(75, 75, 75, 150*alpha),xra,yra,zra)
					else
						dxDrawMaterialLine3D(x,y,z,xa,ya,za, bulletHoles[hole], scale*2,tocolor(75, 75, 75, 150*alpha),xra,yra,zra)
					end
				else
					if getScreenFromWorldPosition(x,y,z,0.1) then
						local x,y,z,xa,ya,za,xb,yb,zb = unpack(vectors)
						dxDrawMaterialLine3D(x,y,z,xa,ya,za, bulletHoles[hole], scale*2,tocolor(75, 75, 75, 150*alpha),false,xb,yb,zb)
					end
				end
			end
			
			Holes[i] = {x,y,z,xr,yr,zr,t-1,hole,scale,elementHit,vectors}
			if (t < 0) then
				table.remove(Holes,i)
			end
		end
	end
	
	sTCount = 0
	
	for i,v in pairs(sniperTrails) do
		if v then
			sTCount = sTCount + 1
			local x,y,z,tx,ty,tz,t = unpack(v)
			local distance = getDistanceBetweenPoints3D (x,y,z,tx,ty,tz)
			local t = t - 1
			local halfTime = (sniperTrailTime/2)
			local alpha = ((t>halfTime) and (halfTime-(t-halfTime))/halfTime or t/halfTime)*3
			local size = ((sniperTrailTime-t)/sniperTrailTime)*6
			dxDrawLine3D (x,y,z,tx,ty,tz, tocolor ( 75, 75, 75, 40*math.max(math.min(alpha,1) ),0), size )
			sniperTrails[i][7] = t
			if t < 2 then
				sniperTrails[i] = nil
			end
		end
	end
	if sTCount < 0 then
		sniperTrails = {}
	end
end

function findRotation3D( x1, y1, z1, x2, y2, z2 ) 
	local rotx = math.atan2 ( z2 - z1, getDistanceBetweenPoints2D ( x2,y2, x1,y1 ) )
	rotx = math.deg(rotx)
	local rotz = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
	rotz = rotz < 0 and rotz + 360 or rotz
	return rotx, 0,rotz
end

function createBulletMarker(ID)
	if not BulletMarkers[ID] then
		local bulletMarker = createObject(2996,0,0,0,0,0,0)
		setElementCollisionsEnabled(bulletMarker,false)
		setElementAlpha(bulletMarker,0)
		BulletMarkers[ID] = bulletMarker
	end
	return BulletMarkers[ID]
end

function removeBulletMarker(ID)
	if isElement(BulletMarkers[ID]) then
		destroyElement(BulletMarkers[ID])
		BulletMarkers[ID] = nil
	end
end

addEventHandler ( "onClientRender", root, render2 )
addEventHandler ( "onClientPreRender", root, positionBullet )