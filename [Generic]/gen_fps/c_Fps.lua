FPSMax = 0
FPSCalcA = 0
FPSMin = 100

local screenWidth, screenHeight = guiGetScreenSize ( ) 


function onClientResourceStart ( resource )
	if ( guiFPSLabel == nil ) then
		FPSCalc = 0
		FPSTime = getTickCount() + 1000
		addEventHandler ( "onClientRender", getRootElement (), onClientRender )
	end
end
addEventHandler ( "onClientResourceStart", resourceRoot, onClientResourceStart )

function onClientRender ( )
	if ( getTickCount() < FPSTime ) then
		FPSCalc = FPSCalc + 1
	else
		FPSCalcA = FPSCalc
		FPSMax = math.max(FPSMax,FPSCalcA)
		FPSMin = math.min(FPSMin,FPSCalcA)
		FPSCalc = 0
		FPSTime = getTickCount() + 1000
		FPSAvg = ((FPSAvg or FPSCalcA)+FPSCalcA)/2
	end
	dxDrawText ( "FPS: "..FPSCalcA.." Max: "..FPSMax.." Min: "..FPSMin.." Avg: "..(math.floor((FPSAvg or 0)*10)/10), screenWidth/2, 43, screenWidth/2, 43, tocolor ( 255, 255, 255, 255 ), 2, "default-bold",'center','center' )
end
