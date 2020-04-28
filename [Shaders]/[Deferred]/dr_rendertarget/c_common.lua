-- 
-- c_common.lua
--

---------------------------------------------------------------------------------------------------
-- shader lists
---------------------------------------------------------------------------------------------------
shaderParams = { 
	SHWorld = {"fx/RTinput_world.fx", 0, shaderSettings.distFade[1], false, "world,object"}, -- world
	SHGrass = {"fx/RTinput_grass.fx", 0, shaderSettings.distFade[1], true, "world"}, -- world (grass)
	SHWorldNoZWrite = {"fx/RTinput_world_noZWrite.fx", 0, shaderSettings.distFade[1], false, "world,object,vehicle"}, -- world
	SHWorldNor = {"fx/RTinput_world_nor.fx", 1, shaderSettings.distFade[1], false, "world,object"}, -- world normal
	SHWorldNorSob = {"fx/RTinput_world_norSob.fx", 0, shaderSettings.distFade[1], false, "world,object"}, -- world normal
	SHWater = {"fx/RTinput_water.fx", 0, shaderSettings.distFade[1], false, "world,object"}, -- world (water)
	SHPed = {"fx/RTinput_ped.fx", 0, shaderSettings.distFade[1], false, "ped"}, -- ped
	SHVehPaint = {"fx/RTinput_car_paint.fx", 0, shaderSettings.distFade[1], false, "vehicle"} -- vehicle paint
				}
				
---------------------------------------------------------------------------------------------------
-- texture lists
---------------------------------------------------------------------------------------------------
textureListTable = { }

textureListTable.RemoveList = {
						"",	"unnamed", "fire*",                                    -- unnamed
						"basketball2","skybox_tex*",                               -- other
						"font*","radar*","sitem16","snipercrosshair",              -- hud
						"siterocket","cameracrosshair",                            -- hud
						"*shad*",                                                  -- shadows
						"coronastar","coronamoon","coronaringa",
						"coronaheadlightline",                                     -- coronas
						"lunar",                                                   -- moon
						"tx*",                                                     -- grass effect
						"cj_w_grad",                                               -- checkpoint texture
						"*cloud*",                                                 -- clouds
						"*smoke*",                                                 -- smoke
						"sphere_cj",                                               -- nitro heat haze mask
						"water*","newaterfal1_256",
						"boatwake*","splash_up","carsplash_*",
						"fist","*icon","headlight*",
						"unnamed","sphere","plaintarmac*",
						"vehiclegrunge256","?emap*","vehiclegeneric*"
					}
					
textureListTable.ApplyList = {
						"ws_tunnelwall2smoked","shadover_law",
						"greenshade_64","greenshade2_64","venshade*", 
						"blueshade2_64","blueshade4_64","greenshade4_64",
						"metpat64shadow","bloodpool_*","plaintarmac1"
					}
					
textureListTable.ZDisable = { -- disable from SHWorld
						"roucghstonebrtb", "shad_exp", "shad_ped","shad_car", "headlight", 
						"headlight1" , "shad_bike", "shad_heli", "shad_rcbaron" , 
						"vehiclescratch64" , "lamp_shad_64", "particleskid"							
					}
					
textureListTable.ZDisableApply = { -- apply to shader SHWorldNoZWrite
						"roucghstonebrtb", "vehiclescratch64" , "lamp_shad_64", "particleskid"							
					}
					

textureListTable.TextureGrun = {
						"vehiclegrunge256", "?emap*", "vehicleshatter128", 
						"predator92body128", "monsterb92body256a", "monstera92body256a", "andromeda92wing","fcr90092body128",
						"hotknifebody128b", "hotknifebody128a", "rcbaron92texpage64", "rcgoblin92texpage128", "rcraider92texpage128",
						"rctiger92body128","rhino92texpage256", "petrotr92interior128","artict1logos","rumpo92adverts256","dash92interior128",
						"coach92interior128","combinetexpage128","policemiami86body128", "policemiami868bit128","hotdog92body256",
						"raindance92body128", "cargobob92body256", "andromeda92body", "at400_92_256", "nevada92body256",
						"polmavbody128a" , "sparrow92body128" , "hunterbody8bit256a" , "seasparrow92floats64" ,
						"dodo92body8bit256" , "cropdustbody256", "beagle256", "hydrabody256", "rustler92body256",
						"shamalbody256", "skimmer92body128", "stunt256", "maverick92body128", "leviathnbody8bit256" 
					}	
	
-- flmngo11_128, royaleroof01_64 (shinemap)

-- newaterfal1_256, casinolights6lit3_256, casinolit2_128 (uv anim)

---------------------------------------------------------------------------------------------------
-- prevent memory leaks
---------------------------------------------------------------------------------------------------
addEventHandler( "onClientResourceStart", resourceRoot, function()
	collectgarbage( "setpause", 100 )
end
)

---------------------------------------------------------------------------------------------------
-- material primitive functions
---------------------------------------------------------------------------------------------------
function createPrimitiveQuadDetailsUV(position, size, color, tes)
	local currentTable = {}
	col = tocolor(color.x * 0.6, color.y * 0.6, color.z * 0.6, color.w)
	local pos = Vector3(position.x - 0.5 * size.x, position.y - 0.5 * size.y, position.z)
	for tY = 1, tes.y do
		for tX = 0, tes.x do
			if (tX == 0) then
				table.insert(currentTable, {(tX / tes.x) * size.x + pos.x, ((tY - 1) / tes.y) * size.y + pos.y, pos.z, col, tX / tes.x, (tY - 1) / tes.y})
			end
			table.insert(currentTable, {(tX / tes.x) * size.x + pos.x, ((tY - 1) / tes.y) * size.y + pos.y, pos.z, col, tX / tes.x, (tY - 1) / tes.y})
			table.insert(currentTable, {(tX / tes.x) * size.x + pos.x, (tY / tes.y) * size.y + pos.y, pos.z, col, tX / tes.x, tY / tes.y})
			if (tX == tes.x) then
				table.insert(currentTable, {(tX / tes.x) * size.x + pos.x, (tY / tes.y) * size.y + pos.y, pos.z, col, tX / tes.x, tY / tes.y})
			end
		end
	end
	return currentTable
end

tesList = {}
local colorMultiplier = 1
function createPrimitiveQuadUV(tes)
local thisMat = tostring(tes.x)..'_'..tostring(tes.y)
if tesList[thisMat] then return tesList[thisMat] end
	local currentTable = {}
	local color = tocolor(255 * colorMultiplier, 255 * colorMultiplier, 255 * colorMultiplier, 255)
	local position = Vector3(0, 0, 0)
	local size = Vector2(1, 1)
	local pos = Vector3(position.x - 0.5 * size.x, position.y - 0.5 * size.y, position.z)
	for tY = 1, tes.y do
		for tX = 0, tes.x do
			if (tX == 0) then
				table.insert(currentTable, {(tX / tes.x) * size.x + pos.x, ((tY - 1) / tes.y) * size.y + pos.y, pos.z, color, tX / tes.x, (tY - 1) / tes.y})
			end
			table.insert(currentTable, {(tX / tes.x) * size.x + pos.x, ((tY - 1) / tes.y) * size.y + pos.y, pos.z, color, tX / tes.x, (tY - 1) / tes.y})
			table.insert(currentTable, {(tX / tes.x) * size.x + pos.x, (tY / tes.y) * size.y + pos.y, pos.z, color, tX / tes.x, tY / tes.y})
			if (tX == tes.x) then
				table.insert(currentTable, {(tX / tes.x) * size.x + pos.x, (tY / tes.y) * size.y + pos.y, pos.z, color, tX / tes.x, tY / tes.y})
			end
		end
	end
	tesList[thisMat] = currentTable
	return tesList[thisMat]
end

---------------------------------------------------------------------------------------------------
-- check if element is drawn in front of cam plane
---------------------------------------------------------------------------------------------------
function isEntityVisible(pos, rads)
	if (getCamera().matrix:getForward()):dot(pos - getCamera().matrix:getPosition()) > - (rads / 2) then
		return true
	else
		return false
	end
end

---------------------------------------------------------------------------------------------------
-- manage after effect zBuffer recovery
---------------------------------------------------------------------------------------------------
CPrmFixZ = { }
function CPrmFixZ.create()
	if CPrmFixZ.shader then return true end
	CPrmFixZ.shader = DxShader( "fx/primitive3D_fixZBuffer.fx" )
	if CPrmFixZ.shader then
		CPrmFixZ.shader:setValue( "fViewportSize", guiGetScreenSize() )
		CPrmFixZ.trianglestrip = createPrimitiveQuadUV( Vector2(1, 1) )
		return true
	end
	return false
end

function CPrmFixZ.draw()
	if CPrmFixZ.shader then
		-- draw the outcome
		dxDrawMaterialPrimitive3D( "trianglestrip", CPrmFixZ.shader, false, unpack( CPrmFixZ.trianglestrip ) )
	end
end

function CPrmFixZ.destroy()
	if CPrmFixZ.shader then
		CPrmFixZ.shader:destroy()
		CPrmFixZ.trianglestrip = nil
	end
end

---------------------------------------------------------------------------------------------------
-- the interval between this frame and the previous one in milliseconds (delta time).
---------------------------------------------------------------------------------------------------
addEventHandler("onClientPreRender", root, function(msSinceLastFrame)
    lastFrameTickCount = msSinceLastFrame
end
)
