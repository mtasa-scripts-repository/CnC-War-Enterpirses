BranchShader = {}

enabled = false

function enableShader()
	if not enabled then
		BranchShader.shader = dxCreateShader("Shaders/branches.fx", 15, 200, false, "all")

		engineApplyShaderToWorldTexture(BranchShader.shader, "*pine_tree*")
		engineApplyShaderToWorldTexture(BranchShader.shader, "*tree_pine_bough*")

		engineApplyShaderToWorldTexture(BranchShader.shader, "*plant*")
		engineApplyShaderToWorldTexture(BranchShader.shader, "*leaf*")
		engineApplyShaderToWorldTexture(BranchShader.shader, "*leaves*")
		enabled = true
	end
end

function disableShader()
	if enabled then
		enabled = nil
		if isElement(BranchShader.shader) then
			destroyElement(BranchShader.shader)
			BranchShader.shader = nil
		end
	end
end

PI_MUL_2 = 6.2831853071795864769252867665590

function BranchShader.update()
	if enabled then
		local time = getTickCount ( ) / 700

		local wave = (Vector4 ( 1/5, 1/3, 1/3, time ) / PI_MUL_2)
		local wave2 = wave/2
		dxSetShaderValue ( BranchShader.shader, "dir2D", wave2.x,wave2.y,wave2.z,wave2.w )
		dxSetShaderValue ( BranchShader.shader, "wave", wave.x,wave.y,wave.z,wave.w )
	end
end
addEventHandler("onClientRender", root, BranchShader.update)

function changeSetting(setting)
	if setting == 'Off' then
		disableShader()
	else
		enableShader()
	end
end

addEvent ( "Vegitation Sway", true )
addEventHandler ( "Vegitation Sway", root, changeSetting )