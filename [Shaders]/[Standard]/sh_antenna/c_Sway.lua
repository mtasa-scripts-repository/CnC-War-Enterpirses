VehicleShader = {}

VehicleShader.shader = dxCreateShader("Shaders/Antenna.fx", 15, 150, false, "vehicle")

engineApplyShaderToWorldTexture(VehicleShader.shader, "*antenna*")

local randomamounta = 0.5
local randomamountb = 1

PI_MUL_2 = 3.2831853071795864769252867665590

function VehicleShader.update()
		local time = getTickCount ( ) / 900
		
		local wave = (Vector4 ( (1/5), (1/3), (1/3), time ) / PI_MUL_2)*2
		local wave2 = wave/8
		
		dxSetShaderValue ( VehicleShader.shader, "dir2D", wave2.x,wave2.y,wave2.z,wave2.w )
		dxSetShaderValue ( VehicleShader.shader, "wave", wave.x,wave.y,wave.z,wave.w )
end
addEventHandler("onClientRender", root, VehicleShader.update)