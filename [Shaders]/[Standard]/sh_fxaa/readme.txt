Resource Name: Fast-Approximate Anti Aliasing (FXAA) v3
Converted by: Ren712
Source: Master Effect 1.3 shader plugin for ENBSeries
Contact: knoblauch700@o2.pl

Original description:

A non-optimized rendered image of a 3d application often has jaggy edges on borders of objects, 
which look like stairs and also like sh*t. Anti Aliasing tries to find a balance between blurring 
an image to cover these jaggy edges and keeping the sharpness. The FXAA here is more performance-friendly 
than the ingame Anti Aliasing.

Additional description: 
Toggle the effect with /sFxAA (nr: 0 to 4)
This might be useful when using depth buffer effects (like Depth of field etc)
This is a layered effect, which means you can run other post process effects.
You can set as many passes as you wish (the max limit is set to 4). Type /sFxAA (nr)
to do so. The effect requires Shader Model 3.0 to run.