#line 2 "source\rasterizer\hlsl\copy_target.hlsl"

//#define USE_CUSTOM_POSTPROCESS_CONSTANTS

#include "global.fx"
#include "hlsl_vertex_types.fx"
#include "utilities.fx"
#include "postprocess.fx"
#include "copy_target_registers.fx"
//@generate screen

LOCAL_SAMPLER_2D_IN_VIEWPORT_MAYBE(surface_sampler, 0);
LOCAL_SAMPLER_2D_IN_VIEWPORT_MAYBE(dark_surface_sampler, 1);

LOCAL_SAMPLER_2D_IN_VIEWPORT_MAYBE(bloom_sampler, 2);
LOCAL_SAMPLER_2D_IN_VIEWPORT_MAYBE(bling_sampler, 3);
LOCAL_SAMPLER_2D_IN_VIEWPORT_MAYBE(persist_sampler, 4);

//sampler3D test_sampler : register(s5);			// ###ctchou $REMOVE $DEBUG


float3 get_pixel_bilinear_bloom(float2 tex_coord)
{
	return tex2D_offset(bloom_sampler, tex_coord, 0, 0);
}

float3 get_pixel_bilinear_bling(float2 tex_coord)
{
	return tex2D_offset(bling_sampler, tex_coord, 0, 0);
}

float3 get_pixel_bilinear_persist(float2 tex_coord)
{
	return tex2D_offset(persist_sampler, tex_coord, 0, 0);
}

 
// pixel fragment entry points
float4 default_ps(screen_output IN) : SV_Target
{
	float4 accum=		sample2D(surface_sampler, IN.texcoord);
	float4 accum_dark=	sample2D(dark_surface_sampler, IN.texcoord);
	
	float3 combined= max(accum, accum_dark);			// convert_from_render_targets <-- for some reason this isn't optimized very well

	float3 bloom= get_pixel_bilinear_bloom(IN.texcoord);
	float3 bling= get_pixel_bilinear_bling(IN.texcoord);
	float3 persist= get_pixel_bilinear_persist(IN.texcoord);

	float3 blend=	intensity.x * combined +
					intensity.y * bloom +
					intensity.z * bling +
					intensity.w * persist;


/*	sample0= sample0*2 - 1;
	sample0.y = sample0.y * (720.0/1280.0);
	sample0 *= sample0;
	
	float radius= sqrt(sample0.x + sample0.y);		// vignetting
	radius= max(0.0, radius-0.7);
	radius *= radius;
	radius = 1+15*radius;
	color= color / radius;
*/

// float d= 0.15
// float c= cuberoot(d * 27 / 4) = 1.0041494251232542828239889869599
// float xmax = sqrt(c / (3 * d)) = 1.4938015821857215695824940046795

	float3 clamped  = min(blend, tone_curve_constants.xxx);		// default= 1.4938015821857215695824940046795
	clamped= max(clamped, 0.000000001f);
	float3 clamped2 = clamped * clamped;
	float3 clamped3 = clamped2 * clamped;
	
	float4 result;
	result.rgb= clamped.rgb * tone_curve_constants.y + clamped2.rgb * tone_curve_constants.z + clamped3.rgb * tone_curve_constants.w;		// default linear = 1.0041494251232542828239889869599, quadratic= 0, cubic= - 0.15;
	result.a= 1.0f;

	return result;
}
