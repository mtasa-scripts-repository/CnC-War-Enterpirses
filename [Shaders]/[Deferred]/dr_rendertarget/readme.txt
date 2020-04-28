Resource: dr_rendertarget v0.1.0 
Author: Ren712
Contact: knoblauch700@o2.pl

Description:
This resource provides render targets for deferred lighting resources
and some exported functions for it's management.
The purpose of this resource is to give an efficient alternative to
dynamic lighting resource and introduce deferred rendering
approach. Light (or any other effect) is produced after world is rendered
based on information (scene depth, world normals, texture color) generated before. 

Exported functions:
RTColor, RTDepth, RTNormal = getRenderTargets()
fadeEnd, fadeStart = getShaderDistanceFade()
applyNormalMappingToTextureList(texList) -- provided normal maps in second texture state
applyNormalMappingToTexture(texName)
applyNormalMappingToObject(myObject)

More detailed description is presented here:
https://gamedevelopment.tutsplus.com/articles/forward-rendering-vs-deferred-rendering--gamedev-12342

Requirements:
Shader model 3.0 GFX, MRT and readable depth buffer in PS access. 
