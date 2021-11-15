#line 2 "source\rasterizer\hlsl\gradient.hlsl"

#include "global.fx"
#include "hlsl_vertex_types.fx"
#include "utilities.fx"
#include "postprocess.fx"
//@generate screen

LOCAL_SAMPLER_2D(source_sampler, 0);

float4 default_ps(screen_output IN) : SV_Target
{
#ifdef pc
 	float4 color= sample2D(source_sampler, IN.texcoord);
 #else
	float4 color_o, color_x, color_y;
	float2 texcoord= IN.texcoord;
	asm
	{
		tfetch2D color_o, texcoord, source_sampler, OffsetX= 0, OffsetY= 0
		tfetch2D color_x, texcoord, source_sampler, OffsetX= 1, OffsetY= 0
		tfetch2D color_y, texcoord, source_sampler, OffsetX= 0, OffsetY= 1
	};
	float4 gradient_x= (color_x - color_o);
	float4 gradient_y= (color_y - color_o);
	
	float4 gradient_magnitude= sqrt(gradient_x * gradient_x + gradient_y * gradient_y);
	float4 color= gradient_magnitude;
#endif
	return color*scale;
}
