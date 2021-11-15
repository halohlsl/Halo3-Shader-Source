#ifndef _FINAL_COMPOSITE_REGISTERS_FX_
#ifndef DEFINE_CPP_CONSTANTS
#define _FINAL_COMPOSITE_REGISTERS_FX_
#endif

#if DX_VERSION == 9

#include "final_composite_registers.h"

PIXEL_CONSTANT(float4, intensity,				k_ps_final_composite_intensity);				// unused:			natural, bloom, bling, persist
PIXEL_CONSTANT(float4, tone_curve_constants,	k_ps_final_composite_tone_curve_constants);		// tone curve:		max, linear, quadratic, cubic terms
PIXEL_CONSTANT(float4, player_window_constants, k_ps_final_composite_player_window_constants);	// weapon zoom:		x, y, (left top corner), z,w (width, height);
PIXEL_CONSTANT(float4, bloom_sampler_xform,		k_ps_final_composite_bloom_sampler_xform);		// 
PIXEL_CONSTANT(float4, cg_blend_factor,			k_ps_final_composite_cg_blend_factor);

PIXEL_CONSTANT(float4, depth_constants,			POSTPROCESS_EXTRA_PIXEL_CONSTANT_3);			// depth of field:	1/near,  -(far-near)/(far*near), focus distance, aperture
PIXEL_CONSTANT(float4, depth_constants2,		POSTPROCESS_EXTRA_PIXEL_CONSTANT_4);			// depth of field:	focus half width


#elif DX_VERSION == 11

CBUFFER_BEGIN(FinalCompositePS)
	CBUFFER_CONST(FinalCompositePS,		float4, 	intensity,					k_ps_final_composite_intensity)
	CBUFFER_CONST(FinalCompositePS,		float4, 	tone_curve_constants,		k_ps_final_composite_tone_curve_constants)
	CBUFFER_CONST(FinalCompositePS,		float4, 	player_window_constants, 	k_ps_final_composite_player_window_constants)
	CBUFFER_CONST(FinalCompositePS,		float4, 	bloom_sampler_xform,		k_ps_final_composite_bloom_sampler_xform)
	CBUFFER_CONST(FinalCompositePS,		float4, 	cg_blend_factor,			k_ps_final_composite_cg_blend_factor)	
CBUFFER_END

CBUFFER_BEGIN(FinalCompositeDOFPS)
	CBUFFER_CONST(FinalCompositeDOFPS,	float4,		depth_constants,			k_ps_final_composite_depth_constants)
	CBUFFER_CONST(FinalCompositeDOFPS,	float4,		depth_constants2,			k_ps_final_composite_depth_constants2)
CBUFFER_END

#endif

#endif
