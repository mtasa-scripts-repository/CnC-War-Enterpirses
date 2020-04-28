--  
-- file: c_primitive3D_projectedTexture.lua
-- version: v1.6
-- author: Ren712
--
-- include: fx/primitive3D_projectedTexture.fx, c_common.lua

local scx,scy = guiGetScreenSize ()

CPrmTextureProj = { }
CPrmTextureProj.__index = CPrmTextureProj
	 
-- texture, worldPosition Vector3(), elementRotation Vector3(), texSize Vector2(), color Vector4(0-255,0-255,0-255,0-255) 
function CPrmTextureProj: create(tex, pos, atten, rot, texSiz, col, isProjPos )
	local scX, scY = guiGetScreenSize()
	
	local cShader = {
		shader = DxShader( "fx/primitive3D_projectedTexture.fx" ),
		texture = tex,
		textureSize = texSiz,
		color = Vector4(col.x, col.y, col.z, col.w),
		position = Vector3(pos.x, pos.y, pos.z),
		setProjectionPosition = isProjPos,
		projectionPositionNormal = Vector3(0,0,1),
		projectionPositionSearchLength = 50,
		rotation = Vector3(rot.x, rot.y, rot.z),
		attenuation = atten,
		attenuationPower = 5,
		surAttenuation = 0.5,
		surAttenuationPower = 1,
		surOffset = 0.01,
		shapeTess = 8,
		tessSwitch = false,
		tickCount = 0,
		distFade = Vector2(450, 400),
		destBlend = 6 -- see D3DBLEND https://msdn.microsoft.com/en-us/library/windows/desktop/bb172508%28v=vs.85%29.aspx
	}

	if cShader.shader then
		cShader.shader:setValue( "sTexture", cShader.texture )
		cShader.shader:setValue( "sLightColor", col.x / 255, col.y / 255, col.z / 255, col.w/ 255 )
		cShader.shader:setValue( "sPicSize", cShader.textureSize.x, cShader.textureSize.y )
		
		cShader.shader:setValue( "sLightPosition", cShader.position.x, cShader.position.y, cShader.position.z )
		cShader.shader:setValue( "sLightRotation", math.rad(cShader.rotation.x), math.rad(cShader.rotation.y), math.rad(cShader.rotation.z) )
		
		cShader.shader:setValue( "sLightAttenuation", cShader.attenuation )
		cShader.shader:setValue( "sLightAttenuationPower", cShader.attenuationPower )
		
		cShader.shader:setValue( "sSurfaceAttenuation", cShader.surAttenuation )
		cShader.shader:setValue( "sSurfaceAttenuationPower", cShader.surAttenuationPower )
		
		cShader.shader:setValue( "sSurfaceOffset", cShader.surOffset )
		
		cShader.shader:setValue( "gDistFade", cShader.distFade.x, cShader.distFade.y )
		
		cShader.shader:setValue( "fDestBlend" ,cShader.destBlend )
		cShader.shader:setValue( "sPixelSize", 1 / scX, 1 / scY )
		cShader.shader:setValue( "sHalfPixel", 1/(scX * 2), 1/(scY * 2) )
		
		cShader.shader:setValue( "bProjectionPosition", cShader.setProjectionPosition )
		cShader.shader:setValue( "sSurfaceNormal", cShader.projectionPositionNormal.x, cShader.projectionPositionNormal.y, cShader.projectionPositionNormal.z )
		
		if isSm3MrtDBSupported then 
			local distFromCam = ( pos - getCamera().matrix.position ).length
			if ( distFromCam < 8 * atten ) then 	
				cShader.trianglestrip = createPrimitiveQuadUV(Vector2(cShader.shapeTess, cShader.shapeTess))
				cShader.shader:setValue( "sSubdivUnit", cShader.shapeTess )
				cShader.tessSwitch = true
			else
				cShader.trianglestrip = createPrimitiveQuadUV(Vector2(1, 1))
				cShader.shader:setValue( "sSubdivUnit", 1 )
				cShader.tessSwitch = false
			end	
			if renderTarget.isOn then
				cShader.shader:setValue( "ColorRT", renderTarget.RTColor )
				cShader.shader:setValue( "NormalRT", renderTarget.RTNormal )
			end
		end

		self.__index = self
		setmetatable( cShader, self )
		return cShader
	else
		return false
	end
end

function CPrmTextureProj: setTesselationByDistance()
	if self.shader and isSm3MrtDBSupported then
		local distFromCam = ( self.position - getCamera().matrix.position ).length
		if ( distFromCam < 8 * self.attenuation ) then 
			if not self.tessSwitch then
				self.trianglestrip = createPrimitiveQuadUV(Vector2(self.shapeTess, self.shapeTess))
				self.shader:setValue( "sSubdivUnit", self.shapeTess )
				self.tessSwitch = true
			end
		else
			if self.tessSwitch then
				self.trianglestrip = createPrimitiveQuadUV(Vector2(1, 1))
				self.shader:setValue( "sSubdivUnit", 1 )
				self.tessSwitch = false
			end
		end		
	end
end

function CPrmTextureProj: setTesselationSwitchDistance( tessDis )
	if self.shader then
		self.tessDist = tessDis
		self.angTessDist = ( self.attenuation / 2 ) / math.atan( self.tessTestAngle )
		self.currTessDist = math.max( tessDis, self.angTessDist )
		self:setTesselationByDistance()
	end
end

function CPrmTextureProj: setObjectTesselation( tess )
	if self.shader then
		self.shapeTess = tess
		self:setTesselationByDistance()
	end
end

function CPrmTextureProj: setBlendAdd( isAddBlend )
	if self.shader then
		if isAddBlend then
			self.destBlend = 2
			self.shader:setValue( "fDestBlend" ,2 )
		else
			self.destBlend = 6
			self.shader:setValue( "fDestBlend" ,6 )
		end		
	end
end

function CPrmTextureProj: setTexture( tex )
	if self.shader then
		self.texture = tex
		self.shader:setValue( "sTexture", tex )
	end
end

function CPrmTextureProj: setTextureSize( texSize )
	if self.shader then
		self.textureSize = Vector2(texSize.x, texSize.y )
		self.shader:setValue( "sPicSize", texSize.x, texSize.y )
	end
end

function CPrmTextureProj: setDistFade( distFade )
	if self.shader then
		self.distFade = distFade
		self.shader:setValue( "gDistFade", distFade.x, distFade.y )
	end
end

function CPrmTextureProj: setViewMatrix( inMat )
	if self.shader then
		rot = inMat:getRotationZXY()
		self.rotation = Vector3(rot.x, rot.y, rot.z),
		self.shader:setValue( "sLightRotation", math.rad(rot.x), math.rad(rot.y), math.rad(rot.z) )
		local pos = inMat.position
		if self.setProjectionPosition then
			local offPos = pos - inMat.up * self.projectionPositionSearchLength
			if not isLineOfSightClear(pos.x, pos.y, pos.z, offPos.x, offPos.y, offPos.z, true, false, false) then
				local isHit, hitX, hitY, hitZ, _, norX, norY, norZ = processLineOfSight(pos.x, pos.y, pos.z, offPos.x, offPos.y, offPos.z,
					true, false, false)
				self.position = Vector3( hitX, hitY, hitZ ),
				self.shader:setValue( "sLightPosition", hitX, hitY, hitZ )
				self.shader:setValue( "sSurfaceNormal", norX, norY, norZ )
			else
				return false
			end
		else
			self.position = Vector3(pos.x, pos.y, pos.z )
			self.shader:setValue( "sLightPosition", pos.x, pos.y, pos.z )
		end
	end
end

function CPrmTextureProj: setAutoProjectionSurfaceNormal( nor )
	if self.shader then
		self.projectionPositionNormal = Vector3(nor.x, nor.y, nor.z)
		self.shader:setValue( "sSurfaceNormal", nor.x, nor.y, nor.z )
	end
end

function CPrmTextureProj: setAutoProjectionEnabled( isAutoProj )
	if self.shader then
		self.setProjectionPosition = isAutoProj
		self.shader:setValue( "bProjectionPosition", self.setProjectionPosition )
	end
end

function CPrmTextureProj: setAutoProjectionSearchLength( serLen )
	if self.shader then
		self.projectionPositionSearchLength = serLen
	end
end

function CPrmTextureProj: setPosition( pos )
	if self.shader then
		self.position = Vector3(pos.x, pos.y, pos.z)
		self.shader:setValue( "sLightPosition", pos.x, pos.y, pos.z )
	end
end

function CPrmTextureProj: setAttenuation( atten )
	if self.shader then
		self.attenuation = atten
		self.shader:setValue( "sLightAttenuation", atten )
		self.angTessDist = ( self.attenuation / 2 ) / math.atan( self.tessTestAngle )
		self.currTessDist = math.max( self.tessDist, self.angTessDist )
		self:setTesselationByDistance()
	end
end

function CPrmTextureProj: setAttenuationPower( attenPow )
	if self.shader then
		self.attenuationPower = attenPow
		self.shader:setValue( "sLightAttenuationPower", attenPow )
	end
end

function CPrmTextureProj: setSurfaceAttenuation( atten )
	if self.shader then
		self.surAttenuation = atten
		self.shader:setValue( "sSurfaceAttenuation", atten )
	end
end

function CPrmTextureProj: setSurfaceAttenuationPower( attenPow )
	if self.shader then
		self.surAttenuationPower = attenPow
		self.shader:setValue( "sSurfaceAttenuationPower", attenPow )
	end
end

function CPrmTextureProj: setSurfaceOffset( surOffs )
	if self.shader then
		self.surOffset = surOffs
		self.shader:setValue( "sSurfaceOffset", surOffs )
	end
end

function CPrmTextureProj: setRotation( rot )
	if self.shader then
		self.rotation = Vector3(rot.x, rot.y, rot.z),
		self.shader:setValue( "sLightRotation", math.rad(rot.x), math.rad(rot.y), math.rad(rot.z) )
	end
end

function CPrmTextureProj: setColor( col )
	if self.shader then
		self.color = Vector4(col.x, col.y, col.z, col.w)
		self.shader:setValue( "sLightColor", col.x / 255, col.y / 255, col.z / 255, col.w/ 255 )
	end
end

function CPrmTextureProj: getObjectToCameraAngle()
	if self.position then
		local camMat = getCamera().matrix
		local camFw = camMat:getForward()
		local elementDir = ( self.position - camMat.position ):getNormalized()
		return math.acos( elementDir:dot( camFw ) / ( elementDir.length * camFw.length ))
	else
		return false
	end
end

function CPrmTextureProj: getDistanceFromViewAngle( inAngle )
	if self.shader then
		return ( self.attenuation / 2 ) / math.atan(inAngle)
	else
		return false
	end
end

function CPrmTextureProj: draw()
	if self.shader then
		local clipDist = math.min( self.distFade.x, getFarClipDistance() + self.attenuation )
		local distFromCam = ( self.position - getCamera().matrix.position ).length
		if ( distFromCam < clipDist ) then	
			self.tickCount = self.tickCount + lastFrameTickCount + math.random(500)
			if self.tickCount > tesselationSwitchDelta then            
				self:setTesselationByDistance()
				self.tickCount = 0
			end
			-- draw the outcome
			dxDrawMaterialPrimitive3D( "trianglestrip", self.shader, false, unpack( self.trianglestrip ) )	
		end
	end
end
        
function CPrmTextureProj: destroy()
	if self.shader then
		self.shader:destroy()
		self.shader = nil
	end
	self = nil
	return true
end
