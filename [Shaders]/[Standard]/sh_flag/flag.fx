//
// flag_world.fx
//


//---------------------------------------------------------------------
// flag settings
//---------------------------------------------------------------------

float sWaveFreq = 5;
float sWaveSpeed = 0.2;
float sWaveSize = 0.2;
float sHighlightOffset = 0;
float sHighlightAmount = 0.5;
float brightness = 0.5;

static const float PI = 3.14159265f;

//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
#include "mta-helper.fx"


//---------------------------------------------------------------------
// Sampler for the main texture
//---------------------------------------------------------------------
sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
};


//---------------------------------------------------------------------
// Structure of data sent to the vertex shader
//---------------------------------------------------------------------
struct VSInput
{
  float3 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
};

//---------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//---------------------------------------------------------------------
struct PSInput
{
  float4 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
};


//------------------------------------------------------------------------------------------
// VertexShaderFunction
//  1. Read from VS structure
//  2. Process
//  3. Write to PS structure
//------------------------------------------------------------------------------------------
PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    // Get position on wave
    float waveOffset = (gTime * sWaveSpeed) + (VS.TexCoord.x * sWaveFreq);
    float waveBright = (gTime * sWaveSpeed) + (VS.TexCoord.x * sWaveFreq);

    // Add it to the vertex z coord
    float waveAmplitude = sin( waveOffset * 6.28 );
	
    // The left side should not move
	
	waveAmplitude *= sin(VS.TexCoord.x * PI/2); 
	
    VS.Position.z += waveAmplitude * sWaveSize * 100;
	VS.Position.x += waveAmplitude * sWaveSize * 100;
	
    // Also use the wave position for the highlight effect
    waveBright = waveBright + sHighlightOffset;
    float highlight = sin( waveBright * 6.28 ) * 0.5 + 0.5;

    // Do standard things
    PS.Position = MTACalcScreenPosition ( VS.Position );
    PS.TexCoord = VS.TexCoord;
    PS.Diffuse = MTACalcGTABuildingDiffuse( VS.Diffuse );
	
    PS.Diffuse.rgb *= lerp ( brightness, highlight, sHighlightAmount * 0.8* brightness );

    return PS;
}


//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Read from PS structure
//  2. Process
//  3. Return pixel color
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    // Get texture pixel

	float4 texel = tex2D(Sampler0, PS.TexCoord);
	float4 finalColor = (PS.Diffuse*texel);
	return finalColor;
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique tec0
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
        CullMode = 1;
    }
}

// Fallback
technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
