#ifndef _GLOBAL_REGISTERS_FX_
#ifndef DEFINE_CPP_CONSTANTS
#define _GLOBAL_REGISTERS_FX_
#endif

CBUFFER_BEGIN(GlobalPS)
	CBUFFER_CONST(GlobalPS,		float,		ps_global_mip_bias,						k_ps_global_mip_bias)
	CBUFFER_CONST(GlobalPS,		float3,		ps_global_mip_bias_pad,					k_ps_global_mip_bias_pad)
	CBUFFER_CONST(GlobalPS,		float2,		ps_global_viewport_res,					k_ps_global_viewport_res)
	CBUFFER_CONST(GlobalPS,		float2,		ps_global_viewport_res_pad,				k_ps_global_viewport_res_pad)
	CBUFFER_CONST(GlobalPS,		float2,		ps_global_viewport_top_left_pixel,		k_ps_global_viewport_top_left_pixel)
	CBUFFER_CONST(GlobalPS,		float2,		ps_global_viewport_top_left_pixel_pad,	k_ps_global_viewport_top_left_pixel_pad)
	CBUFFER_CONST(GlobalPS,		float2,		ps_global_viewport_res_multipliers,		k_ps_global_viewport_res_multipliers)
	CBUFFER_CONST(GlobalPS,		float2,		ps_global_viewport_res_multipliers_pad,	k_ps_global_viewport_res_multipliers_pad)
	CBUFFER_CONST(GlobalPS,		float4,		ps_global_viewport_bounds_uv,			k_ps_global_viewport_bounds_uv)
	CBUFFER_CONST(GlobalPS,		float2,		ps_global_render_resolution,			k_ps_global_render_resolution)
	CBUFFER_CONST(GlobalPS,		float2,		ps_global_render_resolution_pad,		k_ps_global_render_resolution_pad)
	CBUFFER_CONST(GlobalPS,		float2,		ps_global_render_pixel_size,			k_ps_global_render_pixel_size)
	CBUFFER_CONST(GlobalPS,		float2,		ps_global_render_pixel_size_pad,		k_ps_global_render_pixel_size_pad)
	CBUFFER_CONST(GlobalPS,		uint, 		ps_global_is_texture_in_viewport_flags,	k_ps_global_is_texture_in_viewport_flags)
CBUFFER_END

#endif //ifndef _HLSL_CONSTANT_PERSIST_FX_

