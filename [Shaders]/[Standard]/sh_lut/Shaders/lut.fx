//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ReShade effect file
// visit facebook.com/MartyMcModding for news/updates
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// Marty's LUT shader 1.0 for ReShade 3.0
// Copyright © 2008-2016 Marty McFly
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// https://reshade.me/forum/shader-discussion/3179-lut-s-powerful-color-correction-the-guide

//------------------------------------------------------------------------------------------
// Variables
//------------------------------------------------------------------------------------------	
texture sColorTex;
texture sLutTex;


#define fLUT_TileSizeXY 32
#define fLUT_TileAmount 32

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

uniform float fLUT_AmountChroma = 1.00; // Intensity of color/chroma change of the LUT.

uniform float fLUT_AmountLuma = 1.00; // Intensity of luma change of the LUT.


//------------------------------------------------------------------------------------------
// Include some common stuff
//------------------------------------------------------------------------------------------
float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;
int gCapsMaxAnisotropy < string deviceCaps="MaxAnisotropy"; >;

//------------------------------------------------------------------------------------------
// Samplers
//------------------------------------------------------------------------------------------
sampler SamplerColor = sampler_state 
{
    Texture = (sColorTex);
    AddressU = Mirror;
    AddressV = Mirror;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
};

sampler SamplerLUT = sampler_state 
{
    Texture = (sLutTex);
    AddressU = Mirror;
    AddressV = Mirror;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = None;
};

//------------------------------------------------------------------------------------------
// Structure of data sent to the vertex shader
//------------------------------------------------------------------------------------------
struct VSInput
{
    float3 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

//------------------------------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//------------------------------------------------------------------------------------------
struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

//------------------------------------------------------------------------------------------
// VertexShaderFunction
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    // calculate screen position of the vertex
    PS.Position = mul(float4(VS.Position.xyz, 1), gWorldViewProjection);
	
    // pass texCoords and vertex color to PS
    PS.TexCoord = VS.TexCoord;
    PS.Diffuse = VS.Diffuse;

    return PS;
}


//------------------------------------------------------------------------------------------
//-- Pixel Shader
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR
{
    float4 color = tex2D(SamplerColor, PS.TexCoord.xy);
    float2 texelsize = 1.0 / fLUT_TileSizeXY;
    texelsize.x /= fLUT_TileAmount;

    float3 lutcoord = float3((color.xy*fLUT_TileSizeXY-color.xy+0.5)*texelsize.xy,color.z*fLUT_TileSizeXY-color.z);
    float lerpfact = frac(lutcoord.z);
    lutcoord.x += (lutcoord.z-lerpfact)*texelsize.y;

    float3 lutcolor = lerp(tex2D(SamplerLUT, lutcoord.xy).xyz, tex2D(SamplerLUT, float2(lutcoord.x+texelsize.y,lutcoord.y)).xyz,lerpfact);

    color.xyz = lerp(normalize(color.xyz), normalize(lutcolor.xyz), fLUT_AmountChroma) * 
                lerp(length(color.xyz),    length(lutcolor.xyz),    fLUT_AmountLuma);

    return float4(color.xyz, 1);

}


//------------------------------------------------------------------------------------------
//-- Techniques
//------------------------------------------------------------------------------------------
technique lut_sm3
{
    pass P0
    {
        VertexShader = compile vs_3_0 VertexShaderFunction();
        PixelShader  = compile ps_3_0 PixelShaderFunction();
    }
}

technique lut_sm2
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader  = compile ps_2_0 PixelShaderFunction();
    }
}

technique lut_no_effect
{
    pass P0
    {
        // Just draw normally
    }
}
