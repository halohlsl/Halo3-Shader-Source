#ifndef _POSTPROCESS_REGISTERS_FX_
#ifndef DEFINE_CPP_CONSTANTS
#define _POSTPROCESS_REGISTERS_FX_
#endif

#ifndef DEFINE_CPP_CONSTANTS
#include "hlsl_constant_persist.fx"
#endif

CBUFFER_BEGIN(PostProcessPS)
	CBUFFER_CONST(PostProcessPS,	float4,		ps_postprocess_pixel_size,				k_ps_postprocess_pixel_size)
	CBUFFER_CONST(PostProcessPS,	float4, 	ps_postprocess_scale,					k_ps_postprocess_scale)
	CBUFFER_CONST(PostProcessPS,	float4x3,	ps_postprocess_hue_saturation_matrix,	k_ps_postprocess_hue_saturation_matrix)
	CBUFFER_CONST(PostProcessPS,	float4,		ps_postprocess_contrast,				k_ps_postprocess_contrast)
CBUFFER_END


#endif
