
xSize, ySize = guiGetScreenSize()
s = (1/1920)*xSize


function cannon()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	setElementData(vehicle,'vVarient','M12A1')
end 

addCommandHandler('cannon',cannon)

function machinegun()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	setElementData(vehicle,'vVarient','M12')
end 

addCommandHandler('machinegun',machinegun)


tirePairs = {}

tirePairs['rf'] = {0,1,-1,'rf'}
tirePairs['lf'] = {180,-1,-1,'lf'}

tirePairs['lb'] = {180,-1,1,'lf'}
tirePairs['rb'] = {0,1,1,'rf'}

vehicle = {}

toggle = nil
function controlSuspension ()
	for index,vehicle in pairs(getElementsByType('vehicle',root,true)) do
		if isElementStreamedIn(vehicle) and isElementOnScreen (vehicle) then
			if getElementModel(vehicle) == 573 then
			
			
				local x,y,z = getElementPosition(localPlayer)
				local xa,ya,za = getVehicleComponentPosition(vehicle,'Turrent_Stand','world')
				if xa then
					if not getPedOccupiedVehicle(localPlayer) then
						local distance =  getDistanceBetweenPoints3D (x,y,z,xa,ya,za)
						if distance < 5 then
							dxDrawText ('Hit ['..(getElementData(localPlayer,'Interact') or 'e')..'] to mount turrent.',xSize/2,ySize/2,xSize/2,ySize/2,tocolor(255,255,255,80), 1, 2, "clear",'center','center',false,false,false,true )
							if getKeyState((getElementData(localPlayer,'Interact') or 'e')) then
								if not toggle then
									if not isMTAWindowActive() or isCursorShowing() then
										if not getElementData(localPlayer,'turrent') then
											toggle = true
											setElementData(localPlayer,'turrent',vehicle)
										else
											setElementData(localPlayer,'turrent',nil)
											toggle = true
										end
									end
								end
							else
								toggle = nil
							end
						end
					end
				end
			
	
				for i,v in pairs(tirePairs) do
					local x,y,z = getVehicleComponentPosition ( vehicle,'wheel_'..i..'_dummy','parent' )
					local z = z+0.05
					local xA,yA,zA = getVehicleComponentPosition ( vehicle,'Tire_'..i,'parent' )
					
					
					local _,_,zrA = getVehicleComponentRotation ( vehicle,'wheel_'..v[4]..'_dummy','parent' )
					local xr,yr,zr = getVehicleComponentRotation ( vehicle,'wheel_'..i..'_dummy','parent' )

					zr = ((v[3] == 1) and -zrA or zr)+v[1]
					
					setVehicleComponentPosition(vehicle,'Tire_'..i,xA,y,z)
					
					setVehicleComponentPosition(vehicle,'Steering_'..i,xA,y,z)
					setVehicleComponentRotation(vehicle,'Tire_'..i,xr*v[2],yr,zr)-- Tire
					setVehicleComponentPosition(vehicle,'Suspension_'..i,xA,y,z)
					
					local sx,sy,sz = getVehicleComponentRotation ( vehicle,'Steering_'..i,'parent' )
					setVehicleComponentRotation(vehicle,'Steering_'..i,sx,sy,zr)-- Steering
					
					local sax,say,asz = getVehicleComponentRotation ( vehicle,'Suspension_'..i,'parent' )

					setVehicleComponentRotation(vehicle,'Suspension_'..i,sax,zA*10*v[3],asz) -- Suspension
				end
				
				
				local xr,yr,zr = getVehicleComponentRotation ( vehicle,'wheel_rf_dummy','parent' )
				setVehicleComponentRotation(vehicle,'Interior_Steering',-zr*2,0,90,'parent')
			end
		end
	end
	controlTurrent()
end


function findRotation3D( x1, y1, z1, x2, y2, z2 ) 
	local rotx = math.atan2 ( z2 - z1, getDistanceBetweenPoints2D ( x2,y2, x1,y1 ) )
	rotx = math.deg(rotx)
	local rotz = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
	rotz = rotz < 0 and rotz + 360 or rotz
	return rotx, 0,rotz
end

function setTurrent()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if getElementData(vehicle,'controller') then
		setElementData(getElementData(vehicle,'controller'),'controller',nil)
		setElementData(vehicle,'controller',nil)
		return
	end
	setElementData(localPlayer,'warthog',vehicle)
	setElementData(vehicle,'controller',localPlayer)
end


--addCommandHandler ( "turrent", setTurrent )


--M12,Turrent_Machine,Machine_Ammo,Machine_Barrel,M_Barrel_1,M_Barrel_2,M_Barrel_3
--M12A1,Turrent_Rocket,Rocket_Ammo,R_Barrel_1,R_Barrel_2,R_Barrel_3


turrentRot = 0

TurrentParts = {'M_Barrel_1','M_Barrel_2','M_Barrel_3'}
TurrentShots = {}

attached = nil
function controlTurrent ()
	
	if isElement(getElementData(localPlayer,'turrent')) then
		local xa,ya,za = getVehicleComponentPosition(getElementData(localPlayer,'turrent'),'Turrent_Stand','root')
		setElementData(localPlayer,'turrentPos',{xa,ya,za})
		if not attached then
			attached = true
			attachElements(localPlayer,getElementData(localPlayer,'turrent'),xa,ya-0.5,za+1)
		end
	else
		if attached then
			attached = nil
			detachElements(localPlayer)
		end
	end
	
	
	if getElementData(localPlayer,'warthog') then
		local hog = getElementData(localPlayer,'warthog')
		
		local w, h = guiGetScreenSize ()
		local x, y, z = getWorldFromScreenPosition ( w/2, h/2, 100 )
		setElementData(hog,'WarthogAim',{x,y,z})
	end
	
	turrentRot = turrentRot + 12
	
	for index,vehicle in pairs(getElementsByType('vehicle',root,true)) do
		if getElementModel(vehicle) == 573 then
			if getElementData(vehicle,'controller') then
				local aim = getElementData(vehicle,'WarthogAim')
				if aim then
					local vx,vy,vz = getElementRotation(vehicle)
					local x,y,z = unpack(aim)
					local xa,ya,za = getVehicleComponentPosition(vehicle,'Turrent_Stand','world')
					--print(x,y,z,xa,ya,za)
					if x and y and z then
		
						local xr,yr,zr = findRotation3D(xa,ya,za,x,y,z)
						setVehicleComponentRotation(vehicle,'Turrent_Stand',0,0,(-vz+zr-90)+180)
						
					
						
						local xrA,yrA,zrA = getVehicleComponentRotation(vehicle,'Turrent_Stand')
						
						local yr = (z-za)+5
						
						setVehicleComponentRotation(vehicle,'Turrent_Machine',0,-yr-(yrA),0)
						setVehicleComponentRotation(vehicle,'Turrent_Rocket',0,-yr-(yrA),0)

						setVehicleComponentRotation(vehicle,'Machine_Barrel',turrentRot,0,0)
						
						local tUpper = {-100,nil}
						for i,v in pairs(TurrentParts) do
							resetVehicleComponentPosition ( vehicle,v )
							local x1,y1,z1 = getVehicleComponentPosition(vehicle,v,'parent')
							local _,_,z2 = getVehicleComponentPosition(vehicle,v)

							if z2 > tUpper[1] then
								tUpper[1] = z2
								tUpper[2] = {v,x1,y1,z1}
							end
						end				
						local v,x1,y1,z1 = unpack(tUpper[2])
						TurrentShots[v] = TurrentShots[v] or {x1,y1,z1,0.5}
						
						for i,v in pairs(TurrentShots) do
							local x,y,z,t = unpack(v)
							if x then
								if t > 0.26 then
									local tA = (t-0.25)/2
									setVehicleComponentPosition(vehicle,i,0.475+tA,y,z,'parent')
								elseif t < 0.24 then
									local tA = (0.25-t)/2
									setVehicleComponentPosition(vehicle,i,0.475+tA,y,z,'parent')
								else
									setVehicleComponentPosition(vehicle,i,0.475,y,z,'parent')
								end
								local t = t-0.05
								TurrentShots[i] = {x,y,z,t}
								if t < 0 then
									TurrentShots[i] = {nil,nil,nil,t}
								end
							else
								local t = t-0.1
								TurrentShots[i] = {nil,nil,nil,t}
								if t < -1 then
									TurrentShots[i] = nil
								end
							end
						end
					end
				end
			end
		end
	end
end

addEventHandler ( "onClientPreRender", root, controlSuspension )


