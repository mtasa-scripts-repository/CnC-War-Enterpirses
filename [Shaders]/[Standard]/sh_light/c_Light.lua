lightShader = {}
light = {}
Sun = {}

lightShader.debug = false

function light.Update()
	light.x, light.y, light.z = exports.base_env:getSunPosition ()
	Sun.r, Sun.g, Sun.b = exports.base_env:getSunColor ()
	Sun.limit = exports.base_env:getNightLimit ()
end

function light.getSunPosition()
	return light.x, light.y, light.z
end

function getSunColor()
	return lightColorOuter,lightColorInner
end

function blend (input,output)
	local change = (math.max(output-input,input-output))/3
	local change = math.max(math.min(change,5),1)

	if input > output then
		return input - change
	elseif input < output then
		return input + change
	else
		return input
	end
end

lightShader.Global = {}
lightShader.Entity = {}
lightShader.Properties = {}

lightShader.Global.Vehicle = {}
lightShader.Global.Vehicle.Property = {}
lightShader.Global.Vehicle.Property = {}
lightShader.Global.Vehicle.Property.lightIntensity = 1
lightShader.Global.Vehicle.Property.ambientIntensity = 0.7
lightShader.Global.Vehicle.Property.shadowStrength = 5
lightShader.Global.Vehicle.Property.specularSize = 10
lightShader.Global.Vehicle.Property.lightShiningPower = 5
lightShader.Global.Vehicle.Property.bumpMapFactor = 5
lightShader.Global.Vehicle.applyType = 'vehicle'
lightShader.Global.Vehicle.Apply = {'*warthog*','*rocket*','*00838488*'}
lightShader.Global.Vehicle.Remove = {}


lightShader.Global.Pelican = {}
lightShader.Global.Pelican.Property = {}
lightShader.Global.Pelican.Property = {}
lightShader.Global.Pelican.Property.lightIntensity = 1
lightShader.Global.Pelican.Property.ambientIntensity = 0.7
lightShader.Global.Pelican.Property.shadowStrength = 5
lightShader.Global.Pelican.Property.specularSize = 10
lightShader.Global.Pelican.Property.lightShiningPower = 5
lightShader.Global.Pelican.Property.bumpMapFactor = 5
lightShader.Global.Pelican.applyType = 'object'
lightShader.Global.Pelican.Apply = {'*pelican*'}
lightShader.Global.Pelican.Remove = {}

lightShader.Global.Flag = {}
lightShader.Global.Flag.Property = {}
lightShader.Global.Flag.Property = {}
lightShader.Global.Flag.Property.lightIntensity = 1
lightShader.Global.Flag.Property.ambientIntensity = 0.5
lightShader.Global.Flag.Property.shadowStrength = 7
lightShader.Global.Flag.Property.specularSize = 4
lightShader.Global.Flag.Property.lightShiningPower = 1
lightShader.Global.Flag.Property.bumpMapFactor = 2
lightShader.Global.Flag.applyType = 'object'
lightShader.Global.Flag.Apply = {'*LightC*'}
lightShader.Global.Flag.Remove = {}

lightShader.Global.Weapon = {}
lightShader.Global.Weapon.Property = {}
lightShader.Global.Weapon.Property = {}
lightShader.Global.Weapon.Property.lightIntensity = 1
lightShader.Global.Weapon.Property.ambientIntensity = 0.6
lightShader.Global.Weapon.Property.shadowStrength = 6
lightShader.Global.Weapon.Property.specularSize = 3
lightShader.Global.Weapon.Property.lightShiningPower = 0.3
lightShader.Global.Weapon.Property.bumpMapFactor = 5
lightShader.Global.Weapon.applyType = 'object'
lightShader.Global.Weapon.Apply = {'*assault*','*Bolt*','*pistol*','*shotgun*','rocket','*eject*'}
lightShader.Global.Weapon.Remove = {}

lightShader.Global['Rocket Launcher'] = {}
lightShader.Global['Rocket Launcher'].Property = {}
lightShader.Global['Rocket Launcher'].Property = {}
lightShader.Global['Rocket Launcher'].Property.lightIntensity = 1
lightShader.Global['Rocket Launcher'].Property.ambientIntensity = 2
lightShader.Global['Rocket Launcher'].Property.shadowStrength = 7
lightShader.Global['Rocket Launcher'].Property.specularSize = 3
lightShader.Global['Rocket Launcher'].Property.lightShiningPower = 2
lightShader.Global['Rocket Launcher'].Property.bumpMapFactor = 10
lightShader.Global['Rocket Launcher'].applyType = 'object'
lightShader.Global['Rocket Launcher'].Apply = {'*rocket*'}
lightShader.Global['Rocket Launcher'].Remove = {}

lightShader.Global.BR = {}
lightShader.Global.BR.Property = {}
lightShader.Global.BR.Property = {}
lightShader.Global.BR.Property.lightIntensity = 1.3
lightShader.Global.BR.Property.ambientIntensity = 1.3
lightShader.Global.BR.Property.shadowStrength = 6
lightShader.Global.BR.Property.specularSize = 4
lightShader.Global.BR.Property.lightShiningPower = 4
lightShader.Global.BR.Property.bumpMapFactor = 5
lightShader.Global.BR.applyType = 'object'
lightShader.Global.BR.Apply = {'*battle*'}
lightShader.Global.BR.Remove = {}

lightShader.Global.Sniper = {}
lightShader.Global.Sniper.Property = {}
lightShader.Global.Sniper.Property = {}
lightShader.Global.Sniper.Property.lightIntensity = 1
lightShader.Global.Sniper.Property.ambientIntensity = 0.9
lightShader.Global.Sniper.Property.shadowStrength = 6
lightShader.Global.Sniper.Property.specularSize = 4
lightShader.Global.Sniper.Property.lightShiningPower = 3
lightShader.Global.Sniper.Property.bumpMapFactor = 3
lightShader.Global.Sniper.applyType = 'object'
lightShader.Global.Sniper.Apply = {'sniper_rifle'}
lightShader.Global.Sniper.Remove = {}

lightShader.Global.DummyPed = {}
lightShader.Global.DummyPed.Property = {}
lightShader.Global.DummyPed.Property.lightIntensity = 1
lightShader.Global.DummyPed.Property.ambientIntensity = 0.6
lightShader.Global.DummyPed.Property.shadowStrength = 6
lightShader.Global.DummyPed.Property.specularSize = 3
lightShader.Global.DummyPed.Property.lightShiningPower = 0.3
lightShader.Global.DummyPed.Property.bumpMapFactor = 5
lightShader.Global.DummyPed.Apply = {'*'}
lightShader.Global.DummyPed.applyType = 'ped'
lightShader.Global.DummyPed.Remove = {'*legs*'}

lightShader.Global.Ped = {}
lightShader.Global.Ped.Property = {}
lightShader.Global.Ped.Property.lightIntensity = 1
lightShader.Global.Ped.Property.ambientIntensity = 0.4
lightShader.Global.Ped.Property.shadowStrength = 7
lightShader.Global.Ped.Property.specularSize = 3
lightShader.Global.Ped.Property.lightShiningPower = 0.3
lightShader.Global.Ped.Property.bumpMapFactor = 5
lightShader.Global.Ped.Apply = {'*'}
lightShader.Global.Ped.applyType = 'ped'
lightShader.Global.Ped.FirstPerson = {'*marine_torso*','*face*','*hats*','*helmet*'}
lightShader.Global.Ped.Remove = {}


lightShader.Global.Color = {}
lightShader.Global.Fading = {}

function lightShader.shouldDraw(element)
	if isElement(element) then
		if (isElementStreamedIn(element) and isElementOnScreen(element)) then
			return true
		else
			local legs = getElementData(element,'Legs')
			if isElement(legs) then
				if ((isElementStreamedIn(legs) and isElementOnScreen(legs)) and getElementData(legs,'Aim')) then
					return true
				end
			end
		end
	end
end

function lightShader.createShader(sType,element) -- Generate shader for specific element type
	local v = lightShader.Global[sType]
	if v and (lightShader.Global[sType].Apply) then
		local shader = lowLevel and dxCreateShader("Shaders/shader_low.fx", 10, 500, false,v.applyType) or dxCreateShader("Shaders/shader.fx", 10, 500, false,v.applyType)

		if not shader then
			 outputChatBox( sType..' Shader : Failed',255,0,0 )
		end
		
		if element then
			for index,texture in pairs(v.Apply) do
				engineApplyShaderToWorldTexture(shader,texture,element)
			end	
		end
		
		for index,texture in pairs(v.Remove) do
			engineRemoveShaderFromWorldTexture(shader,texture,element)
		end
		for name,property in pairs(v.Property) do
			dxSetShaderValue(shader, name, property)
		end
		return shader
	end
end


function lightShader.addElement(element) -- Prep shader for element
	if not lightShader.Entity[element] then
		local eType = getElementType(element)
		lightShader.Properties[element] = {}
		lightShader.Entity[element] = {}
		if eType == 'vehicle' then
			lightShader.Entity[element]['Vehicle'] = lightShader.createShader('Vehicle',element)
		elseif eType == 'ped' then
			if getElementData(element,'Legs') then
				lightShader.Entity[element]['DummyPed'] = lightShader.createShader('DummyPed',element)
			else
				lightShader.Entity[element]['Ped'] = lightShader.createShader('Ped',element)
			end
		elseif eType == 'player' then
			lightShader.Entity[element]['Ped'] = lightShader.createShader('Ped',element)
		elseif eType == 'object' then
			if (getElementData(element,'Weapon')) then
				local wType = getElementData(element,'wType')
				if lightShader.Global[wType] then
					lightShader.Entity[element][wType] = lightShader.createShader(wType,element)
				else
					lightShader.Entity[element]['Weapon'] = lightShader.createShader('Weapon',element)
				end
			else
				if getElementID(element) == 'Pelican' then
					lightShader.Entity[element]['Pelican'] = lightShader.createShader('Pelican',element)
				else
					lightShader.Entity[element]['Flag'] = lightShader.createShader('Flag',element)
				end
			end
		end
	end
end

function removeElements ()
	for i,v in pairs(lightShader.Entity) do
		lightShader.removeElement(i)
	end
end

function lightShader.removeElement(element,ignoreGlobal) -- Remove shader from element
	if lightShader.Entity[element] then
		for i,v in pairs(lightShader.Entity[element]) do
			if isElement(v) then
				destroyElement(v)
			end
		end
		lightShader.Properties[element] = nil
		lightShader.Entity[element] = nil
	end
end

aimingApplied = {}
aimingApplied2 = {}
function lightShader.refreshElements() 
	if lightShader.Entity[localPlayer] then
		if isElement(lightShader.Entity[localPlayer]['Ped']) then
			if getElementData(localPlayer,'Firstperson') then
				if not aimingApplied[localPlayer] then
				aimingApplied[localPlayer] = true
					for i,v in pairs(lightShader.Global.Ped.FirstPerson) do
						engineRemoveShaderFromWorldTexture(lightShader.Entity[localPlayer]['Ped'], v,localPlayer )
					end
				end
			else
				aimingApplied[localPlayer] = nil
				for i,v in pairs(lightShader.Global.Ped.FirstPerson) do
					engineApplyShaderToWorldTexture(lightShader.Entity[localPlayer]['Ped'], v,localPlayer )
				end
			end
		end
	end
		
		
	for _,v in pairs(getElementsByType('player')) do
		if isElementStreamedIn(v) then
			lightShader.addElement(v)
		else
			lightShader.removeElement(v)
		end
	end
		
	for _,v in pairs(getElementsByType('vehicle')) do
		if isElementStreamedIn(v) then
			lightShader.addElement(v)
		else
			lightShader.removeElement(v)
		end
	end

	for _,v in pairs(getElementsByType('ped')) do
		if (isElementStreamedIn(v) or getElementData(v,'Legs')) then
			lightShader.addElement(v)
		else
			lightShader.removeElement(v)
		end
	end
	for _,v in pairs(getElementsByType('object')) do
		if isElementStreamedIn(v) then
			if ((getElementID(v) == 'Flag_Bottom_Blue') or (getElementID(v) == 'Flag_Bottom_FP_Blue') or (getElementID(v) == 'Flag_Bottom_Red') or (getElementID(v) == 'Flag_Bottom_FP_Red') or (getElementData(v,'Weapon')) or (getElementID(v) == 'Pelican')) then
				lightShader.addElement(v)
			end
		else
			lightShader.removeElement(v)
		end
	end
end
setTimer ( lightShader.refreshElements, 150, 0 )


function lightShader.updateMain()

	for _,v in pairs(getElementsByType('player')) do
		if isElementStreamedIn(v) then
			if lightShader.Entity[v] then
				if (getElementData(v,'State.Light.Fade')) then
					if not aimingApplied2[v] then
						aimingApplied2[v] = true
						if (lightShader.Entity[v]['Ped']) then
							engineRemoveShaderFromWorldTexture(lightShader.Entity[v]['Ped'], '*',v )
							engineApplyShaderToWorldTexture(lightShader.Entity[v]['Ped'], '*legs*',v )
						end
					end
				else
					if aimingApplied2[v] then
						aimingApplied2[v] = nil
						if (lightShader.Entity[v]['Ped']) then
							engineApplyShaderToWorldTexture(lightShader.Entity[v]['Ped'], '*',v )
						end
					end
				end
			end
		end
	end
		

	light.Update()
		
	if (light) then

		local hour, minute = getTime ()
					
		if hour >= 19 then
			lightShader.Skyalpha = math.min(((27-hour)-(minute/60))/7.4,1)
		elseif hour <= 6 then
			lightShader.Skyalpha = math.max(((hour-1)+(minute/60))/7,0.7)
		else
			lightShader.Skyalpha = 1
		end
					
		local Skyalpha = (lightShader.Skyalpha < 1) and lightShader.Skyalpha^7 or lightShader.Skyalpha
			
		local Skyalpha = math.max((tonumber(Sun.limit) or 0),Skyalpha)

		local darkness = math.max((1-Skyalpha),0)
				
		lightColorInner = {Skyalpha*(Sun.r)*255,Skyalpha*(Sun.g)*255,Skyalpha*(Sun.b)*255, 1}
			
		return lightColorInner,darkness,Skyalpha
	end
end

function fetchLight(enabled,input,sun)
	if enabled then
		return input or sun
	else
		return sun
	end
end

function lightShader.updateElements()
	if (light) then
		local lightColorInner,darkness,Skyalpha = lightShader.updateMain()
			
		local lightX, lightY, lightZ = light.getSunPosition()
		
		if lightShader.debug then
			local x,y,z = getElementPosition(localPlayer)
			local ra,ga,ba = unpack(lightColorInner)
			dxDrawLine3D(x,y,z,lightX,lightY,lightZ,tocolor(ra,ga,ba,255))
		end
		
		for element,entityList in pairs(lightShader.Entity) do
		
			if not isElement(element) then
				lightShader.Entity[element] = nil
				lightShader.Properties[element] = nil
			else
				
				local isLegs = getElementData(element,'Legs') and getElementData(element,'Legs')
				local isParent = (getElementType(element) == 'object') and (getElementData(element,'Weapon') or getElementData(element,'Holder'))

				local element = isLegs or isParent or element
				
				
				if lightShader.shouldDraw(element) then
					local properties = lightShader.Properties[element]
					if properties then
						if getElementData(element,'Darkness M') then
							properties.dEnable = getElementData(element,'Day Enabled')
							properties.nEnable = getElementData(element,'Night Enabled')
						else
							properties.dEnable = nil
							properties.nEnable = nil
						end

						local day = fetchLight(properties.dEnable,getElementData(element,'lightColor_D'),lightColorInner)
						local night = fetchLight(properties.nEnable,getElementData(element,'lightColor_N'),lightColorInner)
						
						local r_D,g_D,b_D = unpack(day)
						local r_N,g_N,b_N = unpack(night)
									
						local r,g,b = (r_D*Skyalpha)+(r_N*(1-Skyalpha)),(g_D*Skyalpha)+(g_N*(1-Skyalpha)),(b_D*Skyalpha)+(b_N*(1-Skyalpha))

						lightShader.Global.Color[element] = lightShader.Global.Color[element] or {r,g,b}

						local Rb,Gb,Bb,equal = unpack(lightShader.Global.Color[element])
						
						if (Rb == r) and (Gb == g) and (Bb == b) then
							lightShader.Global.Fading[element] = true
						else
							lightShader.Global.Fading[element] = false
						end
							
							
						local r,g,b = blend (Rb,r),blend (Gb,g),blend (Bb,b)
						lightShader.Global.Color[element] = {r,g,b,Equal}
							
						if lowLevel then
							for _,shader in pairs(entityList) do
								dxSetShaderValue(shader, "lightColor", {r/255,g/255,b/255})
								dxSetShaderValue(shader, "ambientColor", {r/255,g/255,b/255})
								dxSetShaderValue(shader, "lightPosition", getElementData(element,'lightPos') or {lightX, lightY, lightZ})
								dxSetShaderValue(shader, "darkness", darkness * (tonumber(getElementData(element,'Darkness M')) or 1))
							end
						else						
							for _,shader in pairs(entityList) do
								dxSetShaderValue(shader, "lightColor", {r/255,g/255,b/255})
								dxSetShaderValue(shader, "ambientColor", {r/255,g/255,b/255})
								dxSetShaderValue(shader, "darkness", darkness * (tonumber(getElementData(element,'Darkness M')) or 1))
								dxSetShaderValue(shader, "lightPosition", getElementData(element,'lightPos') or {lightX, lightY, lightZ})
							end
						end
					else
						lightShader.Entity[element] = nil
						lightShader.Properties[element] = nil
					end
				end
			end
		end
	end
end
addEventHandler("onClientRender", root, lightShader.updateElements)

function changeSetting(setting)
	if (setting == 'Basic') or (setting == 'Off') then
		if not lowLevel then
			lowLevel = true
			removeElements()
		end
	elseif setting == 'Advanced' then
		if lowLevel then
			lowLevel = nil
			removeElements()
		end
	end
end

addEvent ( "Dynamic Vertex Lighting", true )
addEventHandler ( "Dynamic Vertex Lighting", root, changeSetting )

