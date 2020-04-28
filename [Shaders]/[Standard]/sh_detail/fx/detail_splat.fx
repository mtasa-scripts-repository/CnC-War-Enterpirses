//
// Example shader - detail_splat.fx
//


//---------------------------------------------------------------------
// Detail settings
//---------------------------------------------------------------------
texture sDetailTexture1;
texture sDetailTexture2;
float sDetailScale1 = 8;         // Repeat interval of the texture
float sDetailScale2 = 8;         // Repeat interval of the texture
float sDetailMult1 = 1;
float sDetailMult2 = 1;
float sFadeStart = 10;          // Near point where distance fading will start
float sFadeEnd = 80;            // Far point where distance fading will complete (i.e. effect will not be visible past this point)
float sStrength = 0.5;          // 0 to 1 for the strength of the effect
float sAnisotropy = 0.0;        // 0 to 1 for the amount anisotropy of the effect - Higher looks better but can be slower


//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
#include "mta-helper.fx"


//---------------------------------------------------------------------
// Extra renderstates which we use
//---------------------------------------------------------------------
int gCapsMaxAnisotropy                      < string deviceCaps="MaxAnisotropy"; >; 


//---------------------------------------------------------------------
// Sampler for the main texture
//---------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
    MipFilter = Linear;
    MaxAnisotropy = gCapsMaxAnisotropy * sAnisotropy;
    MinFilter = Anisotropic;
};

//---------------------------------------------------------------------
// Sampler for the detail texture
//---------------------------------------------------------------------
sampler SamplerDetail1 = sampler_state
{
    Texture = (sDetailTexture1);
    MipFilter = Linear;
    MaxAnisotropy = gCapsMaxAnisotropy * sAnisotropy;
    MinFilter = Anisotropic;
};

sampler SamplerDetail2 = sampler_state
{
    Texture = (sDetailTexture2);
    MipFilter = Linear;
    MaxAnisotropy = gCapsMaxAnisotropy * sAnisotropy;
    MinFilter = Anisotropic;
};

//---------------------------------------------------------------------
// Structure of data sent to the vertex shader
//---------------------------------------------------------------------
struct VertexShaderInput
{
  float3 Position : POSITION0;
  float3 Normal : NORMAL0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PixelShaderInput
{
  float4 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
  float2 DistFade : TEXCOORD1;
};


//------------------------------------------------------------------------------------------
// VertexShaderFunction
//  1. Read from VS structure
//  2. Process
//  3. Write to PS structure
//------------------------------------------------------------------------------------------
PixelShaderInput VertexShaderFunction(VertexShaderInput VS)
{
    // Initialize result
    PixelShaderInput PS = (PixelShaderInput)0;

    // Calculate screen pos of vertex
    PS.Position = MTACalcScreenPosition( VS.Position );

    // Pass through tex coord
    PS.TexCoord = VS.TexCoord;

    // Calculate GTA lighting for buildings
    PS.Diffuse = MTACalcGTABuildingDiffuse( VS.Diffuse );

    // Distance fade calculation
    float DistanceFromCamera = MTACalcCameraDistance( gCameraPosition, MTACalcWorldPosition( VS.Position ) );
    PS.DistFade.x = 1 - ( ( DistanceFromCamera - sFadeStart ) / ( sFadeEnd - sFadeStart ) );

    // Return result
    return PS;
}

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Read from PS structure
//  2. Process
//  3. Return pixel color
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PixelShaderInput PS) : COLOR0
{
    // Get texture pixel
    float4 texel = tex2D(Sampler0, PS.TexCoord);

    // Get detail pixel
    float4 texelDetail11 = tex2D(SamplerDetail1, PS.TexCoord * sDetailScale1 );
 
    float4 texelDetail1 = texelDetail11  * texelDetail11 * 1.9 * sDetailMult1;
	
    // Get detail pixel
    float4 texelDetail21 = tex2D(SamplerDetail2, PS.TexCoord * sDetailScale2 );
    float4 texelDetail22 = tex2D(SamplerDetail2, PS.TexCoord * sDetailScale2 * 1.9 );
    float4 texelDetail23 = tex2D(SamplerDetail2, PS.TexCoord * sDetailScale2 * 3.6 );
    float4 texelDetail24 = tex2D(SamplerDetail2, PS.TexCoord * sDetailScale2 * 7.4 );

    float4 texelDetail2 = texelDetail21 * texelDetail22 * 2 * texelDetail23 * 2 * texelDetail24 * 2 * sDetailMult2;
	
    float4 texelDetail = lerp(texelDetail1, texelDetail2, texel.a);

    // Apply diffuse lighting
    float4 Color = float4(texel.rgb, 1) * PS.Diffuse;

    // Attenuate detail depending on pixel distance and user setting
    float detailAmount = saturate( PS.DistFade.x ) * sStrength;
    float4 texelDetailToUse = lerp ( 0.4, texelDetail, detailAmount );

    // Add detail
    float4 finalColor = Color * texelDetailToUse;
	
    finalColor.a = Color.a;
	
    // Return result
    return finalColor;
}


//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------

technique detail
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}

technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
