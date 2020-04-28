--
-- c_main.lua
--

funcTable = {}
lightTable = { inputLights = {}, entity = {}, isInNrChanged = false, thisLight = 0, maxLights = 140 }

lightEntity = {}
lightEntity[1] = { start = function(var) local this = CMatLightPoint: create(var[1], var[2], var[3] ) return this end }
lightEntity[2] = { start = function(var) local this = CMatLightSpot: create(var[1], var[2], var[3] ) return this end }

local farClip = getFarClipDistance()
local lastFarClip = 0
local isMaxReached = false
---------------------------------------------------------------------------------------------------
-- main light functions
---------------------------------------------------------------------------------------------------
function funcTable.create(lType,posX,posY,posZ,colorR,colorG,colorB,colorA,dirX,dirY,dirZ,falloff,theta,phi,attenuation,dimension,interior)
	local w = findEmptyEntry(lightTable.inputLights)
	if not lightTable.inputLights[w] then lightTable.inputLights[w] = {} end
	if not lightTable.entity[w] then lightTable.entity[w] = {} end
	lightTable.entity[w] = lightEntity[lType].start({Vector3(posX,posY,posZ), attenuation, Vector4(colorR,colorG,colorB,colorA)})
	lightTable.inputLights[w].enabled = true
	lightTable.inputLights[w].id = w
	lightTable.inputLights[w].lType = lType
	lightTable.inputLights[w].pos = {posX,posY,posZ}
	lightTable.inputLights[w].color = {colorR,colorG,colorB,colorA}	
	lightTable.inputLights[w].attenuation = attenuation
	lightTable.inputLights[w].attenuationPower = 1
	lightTable.inputLights[w].dimension = dimension
	lightTable.inputLights[w].interior = interior
	lightTable.entity[w]:setDistFade(Vector2(farClip, farClip * 0.95))
	if (lType == 2) then 
		lightTable.inputLights[w].dir = {dirX,dirY,dirZ}
		lightTable.inputLights[w].falloff = falloff
		lightTable.inputLights[w].theta = theta
		lightTable.inputLights[w].phi = phi
	
		lightTable.entity[w]:setDirection( Vector3(dirX,dirY,dirZ) )	
		lightTable.entity[w]:setTheta( theta )
		lightTable.entity[w]:setPhi( phi )
		lightTable.entity[w]:setFalloff( falloff )
	end
	outputDebugString('Created Light TYPE: '..lType..' ID:'..w)
	lightTable.isInNrChanged = true
	return w
end

function funcTable.destroy(w)
	if lightTable.inputLights[w] then
		lightTable.inputLights[w].enabled = false
		lightTable.isInNrChanged = true
		lightTable.entity[w]:destroy()
		outputDebugString('Destroyed Light ID:'..w)
		return true
	else
		outputDebugString('Have Not Destroyed Light ID:'..w)
		return false 
	end
end

function findEmptyEntry(inTable)
	for index,value in ipairs(inTable) do
		if not value.enabled then
			return index
		end
	end
	return #inTable + 1
end

---------------------------------------------------------------------------------------------------
-- draw lights
---------------------------------------------------------------------------------------------------
addEventHandler("onClientPreRender", root, function()
	if #lightTable.inputLights == 0 then return end
	lightTable.thisLight = 0
	local camMat = getCamera().matrix
	local camPos = camMat.position
	local dCam = camMat:getForward()
	farClip = math.min(math.floor(getFarClipDistance()), farClip)
	for index,this in ipairs(lightTable.inputLights) do
		if this.enabled then
			local dPos = Vector3(this.pos[1] - camPos.x, this.pos[2] - camPos.y, this.pos[3] - camPos.z)
			if (dPos.length < ( farClip + this.attenuation)) then			
				if dCam:dot(dPos) > - this.attenuation / 2 then   
					if lightTable.thisLight <= lightTable.maxLights then
						isMaxReached = false
					else
						isMaxReached = true
					end
					if math.abs(lastFarClip - farClip) > 2 then
						lightTable.entity[this.id]:setDistFade(Vector2(farClip, farClip * 0.95))
					end
					lightTable.entity[this.id]:draw()
					lightTable.thisLight = lightTable.thisLight + 1
				end	
			end
		end
	end
	lastFarClip = farClip
    if lightTable.thisLight < 1 then farClip = getFarClipDistance() return end
	local lightFac = (lightTable.maxLights / lightTable.thisLight)
	if isMaxReached then
		farClip = math.floor(lightFac * farClip)
	else if (lightFac > 1) and farClip < getFarClipDistance() then
			farClip = farClip + 1
		end
	end
	farClip = math.floor(farClip)
end
,true ,"high+5")


---------------------------------------------------------------------------------------------------
-- debug
---------------------------------------------------------------------------------------------------
local lightDebugSwitch = false

addCommandHandler( "debuglights",
function()
	if isDebugViewActive() then 
		lightDebugSwitch = switchDebugLights(not lightDebugSwitch)
	end
end
)

function switchDebugLights(switch)
	if switch then
		addEventHandler("onClientRender", root, renderDebugLights)
	else
		outputDebugString('LightDebug mode: OFF')
		removeEventHandler("onClientRender", root, renderDebugLights)
	end
	return switch
end

local scx, scy = guiGetScreenSize()
local vcRam, vcRenTar = dxGetStatus().VideoCardRAM, dxGetStatus().VideoMemoryUsedByRenderTargets 
function renderDebugLights()
	if renderTarget.isOn then
		if renderTarget.RTColor then
			dxDrawImage(0,0,scx/2,scy/2,renderTarget.RTColor)
		end
	end
    dxDrawText ("Light sources: "..lightTable.thisLight.."/"..lightTable.maxLights.." MaxReached: "..tostring(isMaxReached), 4, scy * 0.5 - 100)
    dxDrawText ("Light clip distance: "..math.floor(farClip).."/"..math.floor(getFarClipDistance()), 4, scy * 0.5 - 85)
    dxDrawText ("VideoCardRAM: "..vcRam.." MB VideoMemoryFreeForMTA: "..dxGetStatus().VideoMemoryFreeForMTA.." MB", 4, scy * 0.5 - 70)
    dxDrawText ("VideoMemoryUsedByRenderTargets: "..vcRenTar.." MB FramesPerSecond: "..math.floor(currentFPS), 4, scy * 0.5 - 55)
	
	if lightTable.thisLight == 0 then return end
	local camPos = getCamera().position
	for index,this in ipairs(lightTable.inputLights) do
		if this.enabled then
			local dPos = Vector3(this.pos[1] - camPos.x, this.pos[2] - camPos.y, this.pos[3] - camPos.z)
			if (dPos.length < ( math.min(80, farClip + this.attenuation))) then
				local scPosX, scPosY  = getScreenFromWorldPosition(this.pos[1], this.pos[2], this.pos[3])
				if scPosX and scPosY then
					dxDrawText ("Light TYPE: "..this.lType.." ID: "..this.id, scPosX, scPosY, 0, 0, tocolor(0,0,0))
					dxDrawText ("Light TYPE: "..this.lType.." ID: "..this.id, scPosX + 1, scPosY + 1, 0, 0, tocolor(this.color[1],this.color[2],this.color[3]))
				end
			end
		end
	end
end
