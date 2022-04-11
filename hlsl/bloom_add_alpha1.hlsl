#line 2 "source\rasterizer\hlsl\bloom_add_alpha1.hlsl"


#include "global.fx"
#include "hlsl_vertex_types.fx"
#include "utilities.fx"
#include "postprocess.fx"
//@generate screen


LOCAL_SAMPLER_2D_IN_VIEWPORT_MAYBE(original_sampler, 0);
LOCAL_SAMPLER_2D_IN_VIEWPORT_MAYBE(add_sampler, 1);


float4 default_ps(screen_output IN) : SV_Target
{
	float4 original= sample2D(original_sampler, IN.texcoord);
	float4 add= sample2D(add_sampler, IN.texcoord);

	float4 color;
	color.rgb= ps_postprocess_scale.rgb * original.rgb + add.rgb;
	color.a= 1.0f;
	
	return color;
}
