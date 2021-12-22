// https://www.theorangeduck.com/page/pure-depth-ssao
#line 1 "source\rasterizer\hlsl\ssao.hlsl"

#include "global.fx"
#include "common.fx"
#include "hlsl_vertex_types.fx"
#include "hlsl_constant_persist.fx"
#include "ssao_registers.fx"

//@generate screen

LOCAL_SAMPLER_2D(depth_sampler, 0);
LOCAL_SAMPLER_2D(normal_sampler, 1);
LOCAL_SAMPLER_2D(noise_sampler, 2);

#define SSAO_MASK

struct SSAO_VS_OUTPUT
{
	float4 hpos			: SV_Position;
	float4 texCoord		: TEXCOORD0;
	float3 viewVec		: TEXCOORD1;
};

SSAO_VS_OUTPUT default_vs(vertex_type IN)
{
	SSAO_VS_OUTPUT	res;
	
	res.hpos.xy = IN.position;
	res.hpos.z  = 0.5f;
	res.hpos.w  = 1.0f;
	
	res.viewVec = float3(IN.texcoord.xy, 1.0) - float3(0.5,0.5,0.0);
	res.viewVec *= float3(VS_FRUSTUM_SCALE.xy, 1.0);
	
	// texture coord for full-screen quad;
	res.texCoord.xy = IN.texcoord.xy;
	res.texCoord.zw = IN.texcoord.xy * TEXCOORD_SCALE.xy;
	
	return res;
}

float3 normal_from_depth(float depth, float2 texcoords)
{
	const float2 offset1 = float2(0.0,0.001);
	const float2 offset2 = float2(0.001,0.0);
	
	float depth1 = sample2D(depth_sampler, texcoords + offset1).r;
	float depth2 = sample2D(depth_sampler, texcoords + offset2).r;
	
	float3 p1 = float3(offset1, depth1 - depth);
	float3 p2 = float3(offset2, depth2 - depth);
	
	return normalize(-cross(p1, p2));
}

#define SSAO_INTENSITY SSAO_PARAMS.w
#define SSAO_RADIUS SSAO_PARAMS.r

float4 default_ps(SSAO_VS_OUTPUT input) : SV_Target
{
	float depth= sample2D(depth_sampler, input.texCoord.xy).r;
	float3 normal= normal_from_depth(depth, input.texCoord.xy);
	
	const float base= 0.0;
	const float area= 0.0075;
	const float falloff= 0.00000001;
	
	const int samples= 16;
	float3 sample_sphere[samples]=
	{
		float3( 0.5381, 0.1856,-0.4319), float3( 0.1379, 0.2486, 0.4430),
		float3( 0.3371, 0.5679,-0.0057), float3(-0.6999,-0.0451,-0.0019),
		float3( 0.0689,-0.1598,-0.8547), float3( 0.0560, 0.0069,-0.1843),
		float3(-0.0146, 0.1402, 0.0762), float3( 0.0100,-0.1924,-0.0344),
		float3(-0.3577,-0.5301,-0.4358), float3(-0.3169, 0.1063, 0.0158),
		float3( 0.0103,-0.5869, 0.0046), float3(-0.0897,-0.4940, 0.3287),
		float3( 0.7119,-0.0154,-0.0918), float3(-0.0533, 0.0596,-0.5411),
		float3( 0.0352,-0.0631, 0.5460), float3(-0.4776, 0.2847,-0.0271)
	};
	
	float3 random= normalize(sample2D(noise_sampler, input.texCoord.zw).rgb);
	float3 position= float3(input.texCoord.xy, depth);
	
	float occlusion= 0.0;
	for (int i=0; i < samples; i++)
	{
		float3 ray= (SSAO_RADIUS/depth) * reflect(sample_sphere[i], random);
		float3 hemi_ray= position + sign(dot(ray,normal)) * ray;
		
		float occ_depth= sample2D(depth_sampler, saturate(hemi_ray.xy)).r;
		float difference= depth - occ_depth;
		
		occlusion+= step(falloff, difference) * (1.0-smoothstep(falloff, area, difference));
	}
	
	return pow(saturate((occlusion * (1.0 / samples)) + base), SSAO_INTENSITY);
}
