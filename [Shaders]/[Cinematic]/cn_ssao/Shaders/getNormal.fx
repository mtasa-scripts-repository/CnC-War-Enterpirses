//
// getNormal.fx
//

//--------------------------------------------------------------------------------------
// Variables
//--------------------------------------------------------------------------------------
float2 sTexSize = float2(800, 600);
float2 sPixelSize = float2(0.00125, 0.00166);
float sAspectRatio = 800 / 600;

//--------------------------------------------------------------------------------------
// Variables set by MTA
//--------------------------------------------------------------------------------------
texture gDepthBuffer : DEPTHBUFFER;
float4x4 gProjectionMainScene : PROJECTION_MAIN_SCENE;
float4x4 gViewMainScene : VIEW_MAIN_SCENE;
float4x4 gWorldViewProjection : WORLDVIEWPROJECTION;
int gCapsMaxAnisotropy < string deviceCaps="MaxAnisotropy"; >;

//--------------------------------------------------------------------------------------
// Samplers 
//--------------------------------------------------------------------------------------
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
//-- Use the last scene projecion matrix to linearize the depth value a bit more
//--------------------------------------------------------------------------------------
float Linearize(float posZ)
{
    return gProjectionMainScene[3][2] / (posZ - gProjectionMainScene[2][2]);
}

//-----------------------------------------------------------------------------
// Fetches position relative to camera. This is somewhat inaccurate
// as it assumes FoV == 90 degrees but yields good enough results.
//-----------------------------------------------------------------------------
float3 GetPosition(float2 coords)
{
	return float3(coords.xy * 2 - 1,1.0) * Linearize(FetchDepthBufferValue(coords.xy));
}

//-----------------------------------------------------------------------------
//  Calculates normals based on partial depth buffer derivatives.
//  Does a similar job to ddx/ddy but this is higher quality and
//  it also takes care for object borders where usual ddx/ddy produce
//  inaccurate normals.
//-----------------------------------------------------------------------------
float3 GetNormalFromDepth(float2 coords)
{
    float3 offs = float3(sPixelSize.xy, 0);

    float3 f = GetPosition(coords.xy);
    float3 d_dx1 = - f + GetPosition(coords.xy + offs.xz);
    float3 d_dx2 =   f - GetPosition(coords.xy - offs.xz);
    float3 d_dy1 = - f + GetPosition(coords.xy + offs.zy);
    float3 d_dy2 =   f - GetPosition(coords.xy - offs.zy);

    d_dx1 = lerp(d_dx1, d_dx2, abs(d_dx1.z) > abs(d_dx2.z));
    d_dy1 = lerp(d_dy1, d_dy2, abs(d_dy1.z) > abs(d_dy2.z));

    float3 ddxDdy = normalize(cross(d_dy1, d_dx1));
    return  float3(ddxDdy.x, -ddxDdy.y, ddxDdy.z);
}

//-----------------------------------------------------------------------------
//-- Pixel Shader
//-----------------------------------------------------------------------------
float4 PixelShaderFunction(PSInput PS) : COLOR
{
	float3 ScreenSpaceNormals = GetNormalFromDepth(PS.TexCoord.xy);
    ScreenSpaceNormals.y = - ScreenSpaceNormals.y;
	
	float3 normal = (ScreenSpaceNormals * 0.5) + 0.5;	

    return float4(normal, 1);
}


//-----------------------------------------------------------------------------
//-- Techniques
//-----------------------------------------------------------------------------
technique normal_gen
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
