#define GENERATE_NORMALS
#include "mta-helper.fx"

float3 lightPosition = float3(1, 0, 0);
float4 lightColor = float4(1, 1, 1, 1);
float4 ambientColor = float4(1, 1, 1, 1);

float lightIntensity = 1;
float ambientIntensity = 1;
float shadowStrength = 0.1;

sampler MainSampler = sampler_state
{
    Texture = (gTexture0);
};

struct VertexShaderInput
{
	float3 Position : POSITION0;
	float4 Color : COLOR0;
	float3 Normal : NORMAL0;
	float2 TexCoord : TEXCOORD0;
};

struct VertexShaderOutput
{
	float4 Position : POSITION0;
	float4 Color : COLOR0;
	float2 TexCoord : TEXCOORD0;
	float3 worldPosition : TEXCOORD1;
	float3 worldNormal : TEXCOORD2;
	float3 lightDirection : TEXCOORD3;
	float ligtIntensity : TEXCOORD6;
};

VertexShaderOutput VertexShaderFunction(VertexShaderInput input)
{
    VertexShaderOutput output;
	
    output.Position = MTACalcScreenPosition(input.Position);
	output.worldNormal = MTACalcWorldNormal(input.Normal);
	output.worldPosition = MTACalcWorldPosition(input.Position);
	
	output.lightDirection = normalize(gCameraPosition-lightPosition);

    output.ligtIntensity = dot(output.worldNormal, -output.lightDirection);
	
	output.TexCoord = input.TexCoord;
	float4 originalColor = float4(input.Color.rgb, 1);
	float4 sunColor = float4(lightColor.rgb * output.ligtIntensity, 1)*lightIntensity;
	
	output.Color = saturate((sunColor+((originalColor/shadowStrength)/0.5)));

    return output;
}

float4 PixelShaderFunction(VertexShaderOutput input) : COLOR0
{
	float4 mainColor = tex2D(MainSampler, input.TexCoord);
	float4 shadowBrightness = saturate(input.Color);
	
	float4 dynamicLightColor = mainColor * shadowBrightness;

	dynamicLightColor.rgb *= ambientColor.rgb * (ambientIntensity);
	
	dynamicLightColor.rgb *= 2;
	
    return dynamicLightColor;
}


technique DynamicLightVehicle
{
    pass Pass0
    {
		AlphaBlendEnable = TRUE;
        AlphaRef = 1;
        VertexShader = compile vs_3_0 VertexShaderFunction();
        PixelShader = compile ps_3_0 PixelShaderFunction();
    }
}

technique Fallback
{
    pass P0
    {
        // Just draw normally
    }
}