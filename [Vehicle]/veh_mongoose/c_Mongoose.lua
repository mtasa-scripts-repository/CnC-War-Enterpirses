
tirePairs = {}

tirePairs['rf'] = {0,1,5}
tirePairs['lf'] = {180,-1,5}

tirePairs['lb'] = {180,-1,-5}
tirePairs['rb'] = {0,1,-5}


function findRotation3D( x1, y1, z1, x2, y2, z2 ) 
	local rotx = math.atan2 ( z2 - z1, getDistanceBetweenPoints2D ( x2,y2, x1,y1 ) )
	rotx = math.deg(rotx)
	local rotz = -math.deg( math.atan2( x2 - x1, y2 - y1 ) )
	rotz = rotz < 0 and rotz + 360 or rotz
	return rotx, 0,rotz
end


function controlSuspension ()
	for index,vehicle in pairs(getElementsByType('vehicle',root,true)) do
		if isElementStreamedIn(vehicle) and isElementOnScreen (vehicle) then
			if getElementModel(vehicle) == 471 then
				for i,v in pairs(tirePairs) do
					local x,y,z = getVehicleComponentPosition ( vehicle,'wheel_'..i..'_dummy','parent' )
					local z = z+0.1
					local xA,yA,zA = getVehicleComponentPosition ( vehicle,'Tire_'..string.upper(i),'parent' )
					local xr,yr,zr = getVehicleComponentRotation ( vehicle,'wheel_'..i..'_dummy','parent' )
					setVehicleComponentPosition(vehicle,'Tire_'..string.upper(i),xA,y,z)
					setVehicleComponentRotation(vehicle,'Tire_'..string.upper(i),xr*v[2],yr,zr+v[1])
					
					setVehicleComponentPosition(vehicle,'Suspension_Axle_'..string.upper(i),xA,y,z)
					setVehicleComponentRotation(vehicle,'Tire_'..string.upper(i),xr*v[2],yr,zr+v[1])
					
					setVehicleComponentPosition(vehicle,'Suspension_'..string.upper(i)..'_A',xA,y,z)
					local sax,say,asz = getVehicleComponentRotation ( vehicle,'Suspension_'..string.upper(i)..'_A','parent' )

					setVehicleComponentRotation(vehicle,'Suspension_'..string.upper(i)..'_A',zA*10*v[3],say,asz)
					
					local change = (v[2]*(v[3]/5)) > 0 and 90 or 0
					setVehicleComponentRotation(vehicle,'DS_'..string.upper(i),0,(xr*-0.5)-change,0,'parent')
					
					
					setVehicleComponentRotation(vehicle,'DS_Joint_'..string.upper(i),0,xr*v[2]*(v[3]/10),0,'parent')
					
					setVehicleComponentRotation(vehicle,'DS_'..string.upper(i)..'_W_J',xr*0.5*v[2],0,0,'parent')
					setVehicleComponentPosition(vehicle,'DS_'..string.upper(i)..'_W_J',xA,y,z)
					
					local xB,yB,zB = getVehicleComponentPosition ( vehicle,'DS_'..string.upper(i)..'_Dummy','parent' )
					local xC,yC,zC = getVehicleComponentPosition ( vehicle,'DS_'..string.upper(i)..'_W_J','parent' )
					
					local rx,ry,rz = findRotation3D(xC-(0.113*v[2]),yC,zC,xB,yB,zB)

					setVehicleComponentRotation(vehicle,'DS_'..string.upper(i)..'_Dummy',rx,0,rz,'parent')
					
					
					local sx,sy,sz = getVehicleComponentRotation ( vehicle,'Suspension_Axle_'..string.upper(i),'parent' )
					setVehicleComponentRotation(vehicle,'Suspension_Axle_'..string.upper(i),sx,sy,zr+v[1])

				end
			end
		end
	end
end
addEventHandler ( "onClientPreRender", root, controlSuspension )


