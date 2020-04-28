
float2 uvMul = float2(1,1);
float2 uvMov = float2(0,0);
float sNorFac = 1;
float bumpSize = 1;
float envIntensity = 1;
float specularValue = 1;
float refTexValue = 0.2;

float sAdd = 0.1;  
float sMul = 1.1; 
float sPower = 2; 

bool isShatter = false;
texture sReflectionTexture;

int gFogEnable  < string renderState="FOGENABLE"; >;
float4 gFogColor < string renderState="FOGCOLOR"; >;
float gFogStart  < string renderState="FOGSTART"; >;
float gFogEnd < string renderState="FOGEND"; >;
#define GENERATE_NORMALS // Uncomment for normals to be generated
#include "mta-helper.fx"

sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
};

sampler2D ReflectionSampler = sampler_state
{
    Texture = (sReflectionTexture);	
    AddressU = Mirror;
    AddressV = Mirror;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Linear;
};

struct VSInput
{
  float3 Position : POSITION0;
  float3 Normal : NORMAL0;
  float4 Diffuse : COLOR0;
  float2 TexCoord : TEXCOORD0;
  float2 TexCoord1 : TEXCOORD1;
};

struct PSInput
{
  float4 Position : POSITION0;
  float4 Diffuse : COLOR0;
  float4 Specular : COLOR1;
  float2 TexCoord : TEXCOORD0;
  float3 Normal : TEXCOORD1;
  float4 WorldPos : TEXCOORD2;
};


PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    MTAFixUpNormal( VS.Normal );

    PS.TexCoord = VS.TexCoord;
	
    float4 worldPos = mul(float4(VS.Position.xyz,1) , gWorld);
    PS.WorldPos.xyz = worldPos.xyz;
    float4 viewPos = mul( worldPos , gView );
    PS.WorldPos.w = viewPos.z / viewPos.w;
    PS.Position = mul( viewPos, gProjection);
	
    PS.Normal = normalize(mul(VS.Normal, (float3x3)gWorld));
	
    PS.Diffuse = MTACalcGTACompleteDiffuse( PS.Normal, VS.Diffuse );
    PS.Specular.rgb = MTACalculateSpecular( gCameraDirection, gLight1Direction, PS.Normal, gMaterialSpecPower );
 
    PS.Specular.a = pow( mul( VS.Normal, (float3x3)gWorld ).z ,2 ); 
    float3 h = normalize(normalize(gCameraPosition - worldPos.xyz) - normalize(gCameraDirection));
    PS.Specular.a *=  1 - saturate(pow(saturate(dot(PS.Normal,h)), 2));
    PS.Specular.a *= saturate(1 + gCameraDirection.z);
	
    return PS;
}

float3 GetUV(float3 position, float4x4 ViewProjection)
{
    float4 pVP = mul(float4(position, 1.0f), ViewProjection);
    pVP.xy = float2(0.5f, 0.5f) + float2(0.5f, -0.5f) * ((pVP.xy / pVP.w) * uvMul) + uvMov;
    return float3(pVP.xy, pVP.z / pVP.w);
}

float3 MTAApplyFog( float3 texel, float3 worldPos )
{
    if ( !gFogEnable )
        return texel;
 
    float DistanceFromCamera = distance( gCameraPosition, worldPos );
    float FogAmount = ( DistanceFromCamera - gFogStart )/( gFogEnd - gFogStart );
    texel.rgb = lerp(texel.rgb, gFogColor.rgb, saturate( FogAmount ) );
    return texel;
}

float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    float microflakePerturbation = 1.00;
	
    float4 texel = tex2D(Sampler0, PS.TexCoord);
	
    float3 worldNormal = normalize(PS.Normal);
	
    float3 view = normalize(PS.WorldPos.xyz - gCameraPosition);
    float3 reflectDir = normalize(reflect(view, worldNormal));
    float3 currentRay = PS.WorldPos.xyz + reflectDir * sNorFac;
    float farClip = gProjection[3][2] / (1 - gProjection[2][2]);
	
    currentRay += 2 * gWorld[2].xyz * (1.0 + (PS.WorldPos.w / farClip));
    float3 nuv = GetUV(currentRay , gViewProjection);

    float4 envMap = tex2D(ReflectionSampler, nuv.xy);
	
    envMap += sAdd; 
    envMap = pow(envMap, sPower); 
    envMap *= sMul;
    envMap = saturate(envMap * envIntensity);
	
    float4 finalColor = texel * PS.Diffuse;
	
    finalColor.rgb += envMap.rgb;
    finalColor.a *= max(0, texel.a);
    finalColor.rgb += saturate(0.5 * gMaterialSpecular.rgb * refTexValue);
    finalColor.rgb = saturate(finalColor.rgb);
	
    finalColor.rgb = MTAApplyFog(finalColor.rgb, PS.WorldPos.xyz);

    return finalColor;
}


technique car_paint_reflect_shatt
{
    pass P0
    {
        VertexShader = compile vs_3_0 VertexShaderFunction();
        PixelShader = compile ps_3_0 PixelShaderFunction();
    }
}

technique fallback
{
    pass P0
    {
    }
}
