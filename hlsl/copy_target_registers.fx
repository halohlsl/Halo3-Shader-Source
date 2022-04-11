#ifndef _COPY_TARGET_REGISTERS_FX_
#ifndef DEFINE_CPP_CONSTANTS
#define _COPY_TARGET_REGISTERS_FX_
#endif

CBUFFER_BEGIN(CopyTargetPS)
	CBUFFER_CONST(CopyTargetPS,		float4,		intensity,				k_ps_copy_target_intensity)
	CBUFFER_CONST(CopyTargetPS,		float4,		tone_curve_constants,	k_ps_copy_target_tone_curve_constants)
CBUFFER_END

#endif
