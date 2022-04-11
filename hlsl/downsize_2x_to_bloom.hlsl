#line 2 "source\rasterizer\hlsl\downsize_2x_to_bloom.hlsl"

#include "global.fx"
#include "hlsl_vertex_types.fx"
#include "utilities.fx"
#include "postprocess.fx"
//@generate screen

LOCAL_SAMPLER_2D_IN_VIEWPORT_MAYBE(source_sampler, 0);
LOCAL_SAMPLER_2D_IN_VIEWPORT_MAYBE(dark_source_sampler, 1);


float4 default_ps(screen_output IN) : SV_Target
{
	float3 color= 0.00000001f;			// hack to keep divide by zero from happening on the nVidia cards

	color += convert_from_render_targets(
				tex2D_offset(source_sampler, IN.texcoord, -1, -1), 
				tex2D_offset(dark_source_sampler, IN.texcoord, -1, -1));
	color += convert_from_render_targets(
				tex2D_offset(source_sampler, IN.texcoord, +1, -1), 
				tex2D_offset(dark_source_sampler, IN.texcoord, +1, -1));
	color += convert_from_render_targets(
				tex2D_offset(source_sampler, IN.texcoord, -1, +1), 
				tex2D_offset(dark_source_sampler, IN.texcoord, -1, +1));
	color += convert_from_render_targets(
				tex2D_offset(source_sampler, IN.texcoord, +1, +1), 
				tex2D_offset(dark_source_sampler, IN.texcoord, +1, +1));

	color= color / 4.0f;
	
	float3 base_color = color;

	float maximum= max(max(color.r, color.g), color.b);
	float overwhite= max(maximum*ps_postprocess_scale.y, maximum-ps_postprocess_scale.x);		// ###ctchou $PERF could compute both paramters with a single mad followed by max
	color *= (overwhite/maximum);

	float4 res = convert_to_bloom_buffer(color);
	return float4(res.rgb, color_to_intensity(base_color));
}
