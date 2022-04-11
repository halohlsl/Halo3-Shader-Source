#line 2 "source\rasterizer\hlsl\sniper_scope.hlsl"

#include "global.fx"
#include "hlsl_vertex_types.fx"
#include "utilities.fx"
#include "postprocess.fx"
#include "sniper_scope_registers.fx"

//@generate screen

#define ZBUFFER_SCALE (texture_params.r)
#define ZBUFFER_BIAS (texture_params.g)
#define TEXEL_SIZE_X (texture_params.b)
#define TEXEL_SIZE_Y (texture_params.a)
#define READ_TEXEL(xOffset, yOffset) sample2Doffset(source_sampler, texcoord, int2(xOffset, yOffset)).r


LOCAL_SAMPLER_2D_IN_VIEWPORT_MAYBE(source_sampler, 0);
texture2D<uint2> stencil_texture : register(t1);

float4 default_ps(screen_output IN) : SV_Target
{
	float4 line0_x, line0_y, line0_z;
	float4 line1_x, line1_y, line1_z;
	float4 line2_x, line2_y;
	float2 texcoord= IN.texcoord;

	line0_x = READ_TEXEL(-1, -1);
	line0_y = READ_TEXEL(0, -1);
	line0_z = READ_TEXEL(1, -1);

	line1_x = READ_TEXEL(-1, 0);
	line1_y = READ_TEXEL(0, 0);
	line1_z = READ_TEXEL(1, 0);

	line2_x = READ_TEXEL(-1, 1);
	line2_y = READ_TEXEL(0, 1);
	float3 line0= float3(line0_x.x, line0_y.x, line0_z.x);
	float3 line1= float3(line1_x.x, line1_y.x, line1_z.x);
	float2 line2= float2(line2_x.x, line2_y.x);
	
	float4 gradients_x;
	gradients_x.xy= (line0.yz - line0.xy);
	gradients_x.zw= (line1.yz - line1.xy);
	gradients_x *= gradients_x;
	
	float4 gradients_y;
	gradients_y.xy= line1.xy - line0.xy;
	gradients_y.zw= line2.xy - line1.xy;
	gradients_y *= gradients_y;
	
	float4 gradient_magnitudes= saturate(sqrt(gradients_x + gradients_y));

	float average_magnitude= dot(gradient_magnitudes, float4(1.0f, 1.0f, 1.0f, 1.0f));

	float4 result= 0.0f;
	result.r= average_magnitude;
	
#ifdef durango
	// G8 SRVs are broken on Durango - components are swapped
	uint raw_stencil = stencil_texture.Load(int3(calc_viewport_pixel_coords_from_uv(texcoord), 0)).r;
#else
	uint raw_stencil = stencil_texture.Load(int3(calc_viewport_pixel_coords_from_uv(texcoord), 0)).g;
#endif
	float stencil =  raw_stencil / 255.0f;  
   
   result.g= step(64.0f / 255.0f, stencil);

   return ps_postprocess_scale * result;
}
