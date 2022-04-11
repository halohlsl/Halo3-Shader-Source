#line 2 "source\rasterizer\hlsl\double_gradient.hlsl"

#include "global.fx"
#include "hlsl_vertex_types.fx"
#include "utilities.fx"
#include "postprocess.fx"
//@generate screen

LOCAL_SAMPLER_2D_IN_VIEWPORT_MAYBE(source_sampler, 0);

float4 default_ps(screen_output IN) : SV_Target
{
	float4 color_o, color_px, color_nx, color_py, color_ny;
	float2 texcoord= IN.texcoord;
	color_o = sample2Doffset(source_sampler, texcoord, int2(0, 0));
	color_px = sample2Doffset(source_sampler, texcoord, int2(1, 0));
	color_py = sample2Doffset(source_sampler, texcoord, int2(0, 1));
	color_nx = sample2Doffset(source_sampler, texcoord, int2(-1, 0));
	color_ny = sample2Doffset(source_sampler, texcoord, int2(0, -1));
	float4 laplacian_x= (color_px + color_nx - 2 * color_o);
	float4 laplacian_y= (color_py + color_ny - 2 * color_o);
	
	float4 gradient_magnitude= sqrt(laplacian_x * laplacian_x + laplacian_y * laplacian_y);
	float4 color= gradient_magnitude;

	return color*ps_postprocess_scale;
}
