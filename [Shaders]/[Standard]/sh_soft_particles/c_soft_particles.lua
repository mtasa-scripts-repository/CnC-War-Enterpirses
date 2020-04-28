
local particleList = {
	"rainfx", "Sky", "Sky2", "Sky3",
	"collisionsmoke",
	"drift1", "drift2", "drift3", "drift4", "driftb1", "driftb2", "driftb3", "driftb4",
	"dsmoke1", "dsmoke2", "dsmoke3", "dsmoke4",
	"bullethitsmoke", 
	"fireball1", "fireball2", "fireball3", "fireball4", "fireball5", "fireball6", "fireball7", "fireball8", "fireball9", "fireball10", 
	"FireEX", "FireFlame3", "FireFlame1", "flame1", "flame2", "flame3", "flame4", "flamethrower",
	"inferno1", "inferno2", "inferno3", "inferno4", "inferno5",
	"inflame1", "inflame2", "inflame3", "inflame4", 
	"inflamed1", "inflamed2", "inflamed3", "inflamed4",
	"molotov1", "molotov2", "molotov3", "molotov4",
	"muzzle1", "muzzle2", "muzzle3", "muzzle4", 
	"NewFx1", "NewFx2", "NewFx3", "NewFx4", 
	"realex1", "realex2", "realex3", "realex4", 
	"realexb1", "realexb2", "realexb3", "realexb4", 
	"realfire1", "realfire2", "realfire3", "realfire4", 
	"sewersmoke", 
	"smoke", "smoke1", "smoke2", "smoke3", "smoke4", "smoke5", "smoke6", "smoke7", 
	"smoke8", "smoke9", "smoke10", "smoke11", "smoke12", "smoke13", "smoke14",
	"SmokeBlast", "SmokeBlast2", "SmokeBlast3",
	"smoked1", "smoked2", "smoked3", "smoked4", 
	"SmokeEX", "SmokeEX2", "SmokeEX3", "SmokeEX4", "SmokeEX5", "SmokeEX6", "SmokeEX7", "SmokeEX8", "SmokeEX9", 
	"SmokeEXPand", "smokeII_3", "SmokeSand", "SmokeSand2", "Smokethrower", 
	"GunFlash", "GunFlash1", "GunFlash2", "GunFlash3", "GunFlash4", "gunsmoke", 
	"Fnitro", "Pnitro", 
	"afterburner", "Bnitro", "bullethitsmoke", "bullethitsmoke1", "burn1", "burn2", "burn3", "burn4", 
	"wjet2", "wjet4", "wjet6", 
	"sfnite*"
							}

local scX,scY = guiGetScreenSize()

local shader = dxCreateShader ( "fx/soft_particles.fx", 1, 0, false, "world,object" )
dxSetShaderValue( shader, "sPixelSize", 1/scX, 1/scY )



function enableShader()
	if not enabled then
		enabled = true
		shader = dxCreateShader ( "fx/soft_particles.fx", 1, 0, false, "world,object" )
		dxSetShaderValue( shader, "sPixelSize", 1/scX, 1/scY )
		for _,v in pairs(particleList) do
			engineApplyShaderToWorldTexture ( shader, v )	
		end
	end
end

function disableShader()
	if enabled then
		if isElement(shader) then
			destroyElement(shader)
		end
	end
	enabled = nil
end


function changeSetting(setting)
	if setting == 'Off' then
		disableShader()
	else
		enableShader()
	end
end

addEvent ( "Soft Particles", true )
addEventHandler ( "Soft Particles", root, changeSetting )


