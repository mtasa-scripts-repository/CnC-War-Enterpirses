Resource: dr_lightManager v0.1.1 
Author: Ren712
Contact: knoblauch700@o2.pl

Description:
This resource adds an ability to create simple light sources.
The purpose of this resource is  to give an efficient alternative to
dynamic lighting resource and introduce new deferred rendering
approach. Instead of applying shaders to world textures, I have decided 
to recreate needed information from scene depth to apply effect post world
(drawn on materialLine3D billboard). You can add virtually 
limitless number of lights. In order to work the effects
require shader model 3 GFX with readable depth buffer support.

Effects:
CMatLightPoint - Creates a point light.
CMatLightSpot - Creates a spot light.

dependent resources:
projectile lighting: http://community.mtasa.com/?p=resources&s=details&id=15980
vehicle lighting: http://community.mtasa.com/?p=resources&s=details&id=15979
flashlight: http://community.mtasa.com/?p=resources&s=details&id=15981

required resource:
dr_rendertarget: http://community.mtasa.com/index.php?p=resources&s=details&id=15965

optional resources:
dr_blendShad: http://community.mtasa.com/index.php?p=resources&s=details&id=15970
dr_shader_detail: http://community.mtasa.com/index.php?p=resources&s=details&id=15968


Requirements:
Shader model 3.0 GFX, readable depth buffer in PS access.

Exports:
Exported functions have conforming input to the ones of dynamic_lighting
resurce, the main difference is that color is represented by int(0-255) instead 
float(0-1) https://wiki.multitheftauto.com/wiki/Resource:Dynamic_lighting 
Look into c_exports for details.

createPointLight
createSpotLight
destroyLight
setLightDimension
setLightInterior
setLightDirection
setLightRotation
setLightPosition
setLightColor
setLightAttenuation
setLightFalloff
setLightTheta
setLightPhi
getLightDimension
getLightInterior
getLightDirection
getLightRotation
getLightPosition
getLightColor
getLightAttenuation
getLightFalloff
getLightTheta
getLightPhi
