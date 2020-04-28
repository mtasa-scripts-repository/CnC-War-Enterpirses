//
// blur1.fx
//

//--------------------------------------------------------------------------------------
// Variables
//--------------------------------------------------------------------------------------
float2 sTexSize = float2(800, 600);
float2 sPixelSize = float2(0.00125, 0.00166);
float sAspectRatio = 800 / 600;

#define fMXAOBlurSteps  3  // Blur Steps. Offset count for AO bilateral blur filter. Higher means smoother but also blurrier AO. (int 2 - 5)
#define fMXAOBlurSharpness 3.00 // 2 Blur Sharpness. AO sharpness, higher means sharper geometry edges but noisier AO, less means smoother AO but blurry in the distance. (0 - 5)

//--------------------------------------------------------------------------------------
// Variables set by MTA
//--------------------------------------------------------------------------------------
float4x4 gProjectionMainScene : PROJECTION_MAIN_SCENE;
float4x4 gViewMainScene : VIEW_MAIN_SCENE;
float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;
int gCapsMaxAnisotropy < string deviceCaps="MaxAnisotropy"; >;
texture gDepthBuffer: DEPTHBUFFER;
texture sAOTex;
texture sNormalTex;

//--------------------------------------------------------------------------------------
// Samplers 
//--------------------------------------------------------------------------------------
sampler AOSampler = sampler_state 
{
    Texture = (sAOTex);
    AddressU = Clamp;
    AddressV = Clamp;
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = None;
};

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
    PS.PixPos = PS.Position.xy;
	
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

//--------------------------------------------------------------------------------------
// Use the last scene projecion matrix to linearize the depth value a bit more
//--------------------------------------------------------------------------------------
float Linearize(float posZ)
{
    return gProjectionMainScene[3][2] / (posZ - gProjectionMainScene[2][2]);
}

float GetLinearized(float depth)
{
    return (1 - gProjectionMainScene[2][2]) * (depth - gProjectionMainScene[2][2]);	
}

/* Calculates weights for bilateral AO blur. Using only
   depth is surely faster but it doesn't really cut it, also
   areas with a flat angle to the camera will have high depth
   differences, hence blur will cause stripes as seen in many
   AO implementations, even HBAO+. Taking view angle into
   account greatly helps to reduce these problems. */
float GetBlurWeight(float4 tempKey, float4 centerKey, float surfacealignment)
{
	float depthdiff = abs(tempKey.w-centerKey.w) * Linearize(1);
	float normaldiff = 1 - saturate(dot(normalize(tempKey.xyz),normalize(centerKey.xyz)));

	float depthweight = saturate(rcp(fMXAOBlurSharpness*depthdiff*5.0*surfacealignment));
	float normalweight = saturate(rcp(fMXAOBlurSharpness*normaldiff*10.0));
	
	return min(normalweight,depthweight);
}

/* Bilateral blur, exploiting bilinear filter
   for additional blurring. Intel paper covered
   faster gaussian blur with similar offset and
   weight development of discrete gaussian, this
   here is basically the same, only applied on
   box blur. This function only blurs AO and reads
   the normals from RGB channel of backbuffer.*/
//-----------------------------------------------------------------------------
//-- Pixel Shader
//-----------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR
{
    float2 texcoord = PS.TexCoord;

	float4 tempsample;
	float4 centerkey , tempkey;
	float  centerweight, tempweight;
	float surfacealignment;
	float4 blurcoord = 0.0;
	float AO  = 0.0;
	
	float3 ScreenSpaceNormals = (tex2D(SamplerNormal, texcoord).xyz - 0.5) * 2;

    float LinearDepth =  Linearize(FetchDepthBufferValue(texcoord.xy)) / Linearize(1);

	centerkey = float4(ScreenSpaceNormals,LinearDepth);
	centerweight  = 0.5;
	AO = tex2D(AOSampler,texcoord.xy).x * 0.5;
	surfacealignment = saturate(-dot(centerkey.xyz,normalize(float3(texcoord.xy*2.0-1.0,1.0)*centerkey.w)));

	for(int orientation=-1;orientation<=1; orientation+=2)
	{
		for(float iStep = 1.0; iStep <= fMXAOBlurSteps; iStep++)
		{
			blurcoord.xy = (2.0 * iStep - 0.5) * orientation * float2(1.0,0.0) * sPixelSize + texcoord.xy;
					
			tempsample.xyz = (tex2D(SamplerNormal, blurcoord.xy).xyz - 0.5) * 2;

			tempsample.w = tex2D(AOSampler,blurcoord.xy).x;
			float blurDepth = Linearize(FetchDepthBufferValue(blurcoord.xy)) / Linearize(1);
			tempkey = float4(tempsample.xyz,blurDepth);
			tempweight = GetBlurWeight(tempkey, centerkey, surfacealignment);
			AO += tempsample.w * tempweight;
			centerweight   += tempweight;
		}
	}

	return float4(AO / centerweight,0, 0, 1);	

}


//-----------------------------------------------------------------------------
//-- Techniques
//-----------------------------------------------------------------------------
technique blur1
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
