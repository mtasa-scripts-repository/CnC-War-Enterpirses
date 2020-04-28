
texture sReflectionTexture;
texture sRandomTexture;
texture sFringeMap;

float2 uvMul = float2(1,1);
float2 uvMov = float2(0,0);

float sNorFac = 1;
float bumpSize = 1;
float envIntensity = 1;
float bumpIntensity = 0.25;

float sAdd = 0.1;  
float sMul = 1.1; 
float sPower = 2;  

int gFogEnable  < string renderState="FOGENABLE"; >;
float4 gFogColor < string renderState="FOGCOLOR"; >;
float gFogStart  < string renderState="FOGSTART"; >;
float gFogEnd < string renderState="FOGEND"; >;
#include "mta-helper.fx"

sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
};

sampler2D gFringeMapSampler = sampler_state 
{
   Texture = (sFringeMap);
   MinFilter = Linear;
   MipFilter = Linear;
   MagFilter = Linear;
   AddressU  = Clamp;
   AddressV  = Clamp;
};

sampler3D RandomSampler = sampler_state
{
   Texture = (sRandomTexture);
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Point;
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
};

struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse : COLOR0;
    float2 TexCoord : TEXCOORD0;
    float3 Tangent : TEXCOORD1;
    float3 Binormal : TEXCOORD2;
    float3 Normal : TEXCOORD3;
    float4 WorldPos : TEXCOORD4;
    float3 View : TEXCOORD5;
    float3 SparkleTex : TEXCOORD6;
    float4 Diffuse2 : COLOR1;
};

PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    float3 worldPosition = MTACalcWorldPosition( VS.Position );
    PS.View = (gCameraPosition - worldPosition);
	
    float3 Tangent = VS.Normal.yxz;
    Tangent.xz = VS.TexCoord.xy;
    float3 Binormal = normalize( cross(Tangent, VS.Normal) );
    Tangent = normalize( cross(Binormal, VS.Normal) );
	
    PS.TexCoord.xy = VS.TexCoord.xy;
    PS.Tangent = normalize(mul(Tangent, (float3x3)gWorldInverseTranspose).xyz);
    PS.Binormal = normalize(mul(Binormal, (float3x3)gWorldInverseTranspose).xyz);
    PS.Normal = normalize(mul(VS.Normal, (float3x3)gWorld));

    float4 worldPos = mul( float4(VS.Position.xyz,1) , gWorld);	
    float4 viewPos = mul( worldPos , gView );
    PS.WorldPos = float4(worldPos.xyz, viewPos.z / viewPos.w);
    float4 projPos = mul( viewPos, gProjection);
    PS.Position = projPos;
	
    PS.SparkleTex.x = fmod( VS.Position.x, 10 ) * 16 * bumpSize;
    PS.SparkleTex.y = fmod( VS.Position.y, 10 ) * 16 * bumpSize;
    PS.SparkleTex.z = fmod( VS.Position.z, 10 ) * 16 * bumpSize;

    float NormalZ = pow( mul( VS.Normal, (float3x3)gWorld ).z ,2 ); 
    float3 h = normalize(normalize(gCameraPosition - worldPosition.xyz) - normalize(gCameraDirection));
    PS.Diffuse2.a =  NormalZ * (1 - saturate(pow(saturate(dot(PS.Normal,h)), 2))) * saturate(1 + gCameraDirection.z);
	
    PS.Diffuse2.rgb = gMaterialSpecular.rgb * MTACalculateSpecular( gCameraDirection, gLight1Direction, PS.Normal, gMaterialSpecPower ) * 0.5;
    PS.Diffuse2.rgb += MTACalcGTADynamicDiffuse( PS.Normal ).rgb * saturate(gMaterialDiffuse.rgb/2 + 0.2);
    PS.Diffuse2.rgb = saturate(PS.Diffuse2.rgb);
    PS.Diffuse = MTACalcGTABuildingDiffuse( VS.Diffuse );
    return PS;
}

float3x3 cotangent_frame(float3 N, float3 p, float2 uv)
{
    float3 dp1 = ddx( p );
    float3 dp2 = ddy( p );
    float2 duv1 = ddx( uv );
    float2 duv2 = ddy( uv );
 
    float3 dp2perp = cross( dp2, N );
    float3 dp1perp = cross( N, dp1 );
    float3 T = dp2perp * duv1.x + dp1perp * duv2.x;
    float3 B = dp2perp * duv1.y + dp1perp * duv2.y;
 
    float invmax = rsqrt( max( dot(T,T), dot(B,B) ) );
    return float3x3( -T * invmax, -B * invmax, N );
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
    float4 OutColor = 1;

    float microflakePerturbation = 1.00;
    float normalPerturbation = 1.00;
    float microflakePerturbationA = 0.10;

    float4 base = gMaterialAmbient;

    float4 paintColorMid;
    float4 paintColor2;
    float4 paintColor0;
    float4 flakeLayerColor;

    paintColorMid = base;
    paintColor2.r = base.g / 2 + base.b / 2;
    paintColor2.g = (base.r / 2 + base.b / 2);
    paintColor2.b = base.r / 2 + base.g / 2;

    paintColor0.r = base.r / 2 + base.g / 2;
    paintColor0.g = (base.g / 2 + base.b / 2);
    paintColor0.b = base.b / 2 + base.r / 2;

    flakeLayerColor.r = base.r / 2 + base.b / 2;
    flakeLayerColor.g = (base.g / 2 + base.r / 2);
    flakeLayerColor.b = base.b / 2 + base.g / 2;

    float3 vNormal = normalize(PS.Normal);
    float3 vFlakesNormal = tex3D(RandomSampler, PS.SparkleTex).rgb;
    vFlakesNormal = 2 * vFlakesNormal - 1.0;
    float3 vNp1 = microflakePerturbationA * vFlakesNormal + normalPerturbation * vNormal ;
    float3 vNp2 = microflakePerturbation * ( vFlakesNormal + vNormal ) ;
    float3 vView = normalize( PS.View );	
	
    float3x3 mTangentToWorld = transpose( float3x3( PS.Tangent, PS.Binormal, PS.Normal ) );
    float3 vNormalWorld = normalize( mul( mTangentToWorld, vNormal ));

    float fNdotV = saturate(dot(vNormalWorld, vView));

    vFlakesNormal = bumpIntensity * vFlakesNormal;
    float3 worldNormal = normalize(refract(PS.Normal, vFlakesNormal, 1));
	
    float3 reflectDir = normalize(reflect(-vView, worldNormal));
    float3 currentRay = PS.WorldPos.xyz + reflectDir * sNorFac;
    float farClip = gProjection[3][2] / (1 - gProjection[2][2]);
	
    currentRay += 2 * gWorld[2].xyz * (1.0 + (PS.WorldPos.w / farClip));
    float3 nuv = GetUV(currentRay , gViewProjection);

    float4 envMap = tex2D(ReflectionSampler, nuv.xy);

    envMap += sAdd;
    envMap = pow(envMap, sPower); 
    envMap *= sMul;
    envMap.rgb = saturate(envMap.rgb);

    envMap.rgb += gMaterialDiffuse * 0.4;
    envMap.rgb = saturate(envMap.rgb * envIntensity);
    envMap.rgb *= PS.Diffuse2.a;
	
    float4 maptex = tex2D(Sampler0,PS.TexCoord.xy);
    
    float3 vNp1World = normalize( mul( mTangentToWorld, vNp1) );
    float fFresnel1 = saturate( dot( vNp1World, vView ));

    float3 vNp2World = normalize( mul( mTangentToWorld, vNp2 ));
    float fFresnel2 = saturate( dot( vNp2World, vView ));

    float fFresnel1Sq = fFresnel1 * (fFresnel2);

    float4 paintColor = fFresnel1 * paintColor0 +
        fFresnel1Sq * paintColorMid +
        fFresnel1Sq * fFresnel1Sq * paintColor2 +
        pow( fFresnel2, 32 ) * flakeLayerColor;

    float fEnvContribution = 1.0 - 0.5 * fNdotV;
    float4 finalColor = envMap * fEnvContribution + paintColor * 0.8;
    finalColor.rgb += PS.Diffuse2.rgb  * (1 + fFresnel2 * 0.3);
    finalColor.a = 1.0;

    float4 Color = 0.017 + finalColor / 1 + PS.Diffuse * 0.8;
    Color.rgb += finalColor * PS.Diffuse;
    Color *= maptex; 
	
    Color.rgb = MTAApplyFog(Color.rgb, PS.WorldPos.xyz);
	
    Color.a = PS.Diffuse.a;
    return Color;
}


technique carpaint_reflect
{
    pass P0
    {
        VertexShader = compile vs_3_0 VertexShaderFunction();
        PixelShader  = compile ps_3_0 PixelShaderFunction();
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
