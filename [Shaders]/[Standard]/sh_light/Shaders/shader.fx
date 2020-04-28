#define GENERATE_NORMALS
#include "mta-helper.fx"

float3 lightPosition = float3(1, 0, 0);
float4 lightColor = float4(1, 1, 1, 1);
float4 ambientColor = float4(1, 1, 1, 1);
float bias = -0.0002;

float lightIntensity = 1;
float ambientIntensity = 1;
float shadowStrength = 0.1;
float bumpMapFactor = 15;
float specularSize = 1;
float lightShiningPower = 5;

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
	float3 Binormal : TEXCOORD4;
	float3 Tangent : TEXCOORD5;
	float ligtIntensity : TEXCOORD6;
};

VertexShaderOutput VertexShaderFunction(VertexShaderInput input)
{
    VertexShaderOutput output;
	
    MTAFixUpNormal2(input.Normal);

    output.Position = MTACalcScreenPosition(input.Position);
	output.worldNormal = MTACalcWorldNormal(input.Normal);
	output.worldPosition = MTACalcWorldPosition(input.Position);
	
	output.lightDirection = normalize(gCameraPosition-lightPosition);

    output.ligtIntensity = dot(output.worldNormal, -output.lightDirection);
	
    float3 Tangent = input.Normal.yxz;
    Tangent.xz = input.TexCoord.xy;
    float3 Binormal = normalize(cross(Tangent, input.Normal));
    Tangent = normalize(cross(Binormal, input.Normal));

	output.Tangent = normalize(mul(Tangent, gWorldInverseTranspose).xyz);
    output.Binormal = normalize(mul(Binormal, gWorldInverseTranspose).xyz);
	
	output.TexCoord = input.TexCoord;
	float4 originalColor = float4(input.Color.rgb, 1);
	float4 sunColor = float4(lightColor.rgb * output.ligtIntensity, 1)*lightIntensity; // Calculates how bright the light color should be
	float4 carColor = MTACalcGTADynamicDiffuse(output.worldNormal, sunColor, output.lightDirection); // Calculate the light color on the element
	
	output.Color = saturate((carColor+(originalColor/shadowStrength)));

    return output;
}

float4 PixelShaderFunction(VertexShaderOutput input) : COLOR0
{
	
	float4 mainColor = tex2D(MainSampler, input.TexCoord);
	float4 shadowBrightness = saturate(input.Color);
	
	float3 normalMap = bumpMapFactor * MTACalcNormalMap(MainSampler, input.TexCoord.xy, mainColor, 128) - bumpMapFactor / 2;    
    normalMap = normalize(normalMap.x * input.Tangent + normalMap.y * input.Binormal + input.worldNormal);
	
	float4 specularLight1 = MTACalculateSpecular(gCameraPosition-lightPosition, input.lightDirection, normalMap, specularSize);
	specularLight1 *= mainColor;
	float4 specularLight2 = specularLight1 * mainColor.g * mainColor.g;
	float4 finalSpecular = (specularLight1 / 2 + specularLight2 * 2) / 2;
	finalSpecular.rgb *= lightColor.rgb;

	float4 dynamicLightColor = mainColor * shadowBrightness;

	dynamicLightColor.rgb *= ambientColor.rgb * (ambientIntensity);
	dynamicLightColor.rgb += finalSpecular.rgb * lightShiningPower;
	
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

// Fallback
technique Fallback
{
    pass P0
    {
        // Just draw normally
    }
}