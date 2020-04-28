//
// ssao.fx
//

//--------------------------------------------------------------------------------------
// Variables
//--------------------------------------------------------------------------------------
float2 sTexSize = float2(800, 600);
float2 sPixelSize = float2(0.00125, 0.00166);
float sAspectRatio = 800 / 600;

#define iMXAOBayerDitherLevel  5 // Dither Size (int 2 - 8)
uniform float fMXAOSampleRadius = 1.7; // 1.50 Sample radius of GI, higher means more large-scale occlusion with less fine-scale details.  (1 - 8)
#define iMXAOSampleCount 24 // Amount of MXAO samples. Higher means more accurate and less noisy AO at the cost of fps (int 8 - 255)
#define AO_BLUR_GAMMA 2
uniform float fMXAONormalBias = 0.2; // 0.2 Normal bias. Normals bias to reduce self-occlusion of surfaces that have a low angle to each other. (0 - 0.8)

//--------------------------------------------------------------------------------------
// Variables set by MTA
//--------------------------------------------------------------------------------------
float4x4 gProjectionMainScene : PROJECTION_MAIN_SCENE;
float4x4 gViewMainScene : VIEW_MAIN_SCENE;
float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;
int gCapsMaxAnisotropy < string deviceCaps="MaxAnisotropy"; >;
texture gDepthBuffer: DEPTHBUFFER;
texture sNormalTex;
texture sBayerTex;

//--------------------------------------------------------------------------------------
// Samplers 
//--------------------------------------------------------------------------------------
sampler SamplerNormal = sampler_state 
{
    Texture = (sNormalTex);
    AddressU = Clamp;
    AddressV = Clamp;
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = None;
};

sampler SamplerDepth = sampler_state
{
    Texture = (gDepthBuffer);
    AddressU = Clamp;
    AddressV = Clamp;
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = None;
};

sampler SamplerBayer = sampler_state
{
    Texture = (sBayerTex);
    AddressU = Clamp;
    AddressV = Clamp;
    MinFilter = Point;
    MagFilter = Point;
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
    float2 PixPos : TEXCOORD1;
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
	
    // pass screen position to be used in PS
    PS.PixPos = VS.Position.xy;
	
    return PS;
}

//-----------------------------------------------------------------------------
//-- Get value from the depth buffer
//-- Uses define set at compile time to handle RAWZ special case (which will use up a few more slots)
//-----------------------------------------------------------------------------
float FetchDepthBufferValue( float2 uv )
{
    float4 texel = tex2D(SamplerDepth, uv);
#if IS_DEPTHBUFFER_RAWZ
    float3 rawval = floor(255.0 * texel.arg + 0.5);
    float3 valueScaler = float3(0.996093809371817670572857294849, 0.0038909914428586627756752238080039, 1.5199185323666651467481343000015e-5);
    return dot(rawval, valueScaler / 255.0);
#else
    return texel.r;
#endif
}

//------------------------------------------------------------------------------------------
//-- Use the last scene projecion matrix to linearize the depth value a bit more
//------------------------------------------------------------------------------------------
float Linearize(float posZ)
{
    return gProjectionMainScene[3][2] / (posZ - gProjectionMainScene[2][2]);
}

//------------------------------------------------------------------------------------------
// Fetches position relative to camera. This is somewhat inaccurate
// as it assumes FoV == 90 degrees but yields good enough results.
//------------------------------------------------------------------------------------------
float3 GetPosition(float2 coords)
{
	return float3(coords.xy * 2 - 1, 1.0) * Linearize(FetchDepthBufferValue(coords));	
}

//------------------------------------------------------------------------------------------
//  Calculates the bayer dither pattern that's used to jitter
//  the direction of the AO samples per pixel.
//  Why this instead of precalculated texture? BECAUSE I CAN.
//  Using this ordered jitter instead of a pseudorandom one
//  has 3 advantages: it seems to be more cache-aware, the AO
//  is (given a fitting AO sample distribution pattern) a lot less
//  noisy (better variance, see Alchemy AO) and bilateral blur
//  needs a much smaller kernel: from my tests a blur kernel
//  of 5x5 is fine for most settings, but using a pseudorandom
//  distribution still has noticeable grain with 12x12++.
//  Smaller bayer matrix sizes have more obvious directional
//  AO artifacts but are easier to blur.
//------------------------------------------------------------------------------------------
float GetBayerFromCoordLevel(float2 pixelpos)
{
	float finalBayer = 0.0;

	for(float i = 1-iMXAOBayerDitherLevel; i<= 0; i++)
	{
		float bayerSize = exp2(i);
        float2 bayerCoord = floor(pixelpos * bayerSize) % 2.0;
		float bayer = 2.0 * bayerCoord.x - 4.0 * bayerCoord.x * bayerCoord.y + 3.0 * bayerCoord.y;
		finalBayer += exp2(2.0*(i+iMXAOBayerDitherLevel))* bayer;
	}

	float finalDivisor = 4.0 * exp2(2.0 * iMXAOBayerDitherLevel)- 4.0;
	//raising all values by increment is false but in AO pass it makes sense. Can you see it?
	return finalBayer/ finalDivisor + 1.0/exp2(2.0 * iMXAOBayerDitherLevel);
}


//-----------------------------------------------------------------------------
//-- Pixel Shader
//-----------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR
{
    float2 texcoord = PS.TexCoord;
	float3 normal = tex2D(SamplerNormal, texcoord).xyz;

	float radiusJitter	= GetBayerFromCoordLevel(PS.PixPos.xy);
	float3 ScreenSpaceNormals = (normal - 0.5) * 2;

	float3 ScreenSpacePosition = GetPosition(texcoord.xy);

	float scenedepth = ScreenSpacePosition.z / Linearize(1);
	ScreenSpacePosition += ScreenSpaceNormals * scenedepth;

	float SampleRadiusScaled  = 0.2 * fMXAOSampleRadius * fMXAOSampleRadius / (iMXAOSampleCount * ScreenSpacePosition.z);
	float mipFactor = SampleRadiusScaled * 3200.0;

	float2 currentVector;
	sincos(2.0*3.14159274*radiusJitter, currentVector.y, currentVector.x);
	static const float fNegInvR2 = -1.0 / (fMXAOSampleRadius * fMXAOSampleRadius);
	currentVector *= SampleRadiusScaled;			  
			  
	float AO = 0.0;
	float2 currentOffset;

	for(int iSample=0; iSample < iMXAOSampleCount; iSample++)
	{
		currentVector = mul(currentVector.xy, float2x2(0.575, 0.81815, -0.81815, 0.575));
		currentOffset = texcoord.xy + currentVector.xy * float2(1.0, sAspectRatio) * (iSample + radiusJitter);

		float mipLevel = saturate(log2(mipFactor * iSample) * 0.2 - 0.6) * 5.0;
		
		float3 posLod = GetPosition(currentOffset.xy);
		float3 occlVec = -ScreenSpacePosition + posLod;

		float  occlDistanceRcp 	= rsqrt(dot(occlVec, occlVec));
		float  occlAngle = dot(occlVec, ScreenSpaceNormals) * occlDistanceRcp;

		float fAO = saturate(1.0 + fNegInvR2 / occlDistanceRcp)  * saturate(occlAngle - fMXAONormalBias);

        AO += fAO;
	}

	float res = saturate(AO/(0.4 * (1.0 - fMXAONormalBias)*iMXAOSampleCount * sqrt(fMXAOSampleRadius)));			  
		  
	res = pow(abs(res), 1.0 / AO_BLUR_GAMMA);
    return float4(res, 0, 0, 1);
}


//-----------------------------------------------------------------------------
//-- Techniques
//-----------------------------------------------------------------------------
technique ssao_gen
{
    pass P0
    {
        VertexShader = compile vs_3_0 VertexShaderFunction();
        PixelShader  = compile ps_3_0 PixelShaderFunction();
    }
}


//
//-- If no depthbuffer support, do nothing
//
technique no_effect
{
    pass P0
    {
    }
}
