#ifndef _FIDELITYFX_SUPER_RESOLUTION_REGISTERS_FX_
#ifndef DEFINE_CPP_CONSTANTS
#define _FIDELITYFX_SUPER_RESOLUTION_REGISTERS_FX_
#endif

CBUFFER_BEGIN(FSRCS)
	CBUFFER_CONST(FSRCS,		uint4,		rcas_const0,							k_cs_fsr_rcas_const0)
	CBUFFER_CONST(FSRCS,		uint4,		easu_const0,							k_cs_fsr_easu_const0)
	CBUFFER_CONST(FSRCS,		uint4,		easu_const1,							k_cs_fsr_easu_const1)
	CBUFFER_CONST(FSRCS,		uint4,		easu_const2,							k_cs_fsr_easu_const2)
	CBUFFER_CONST(FSRCS,		uint4,		easu_const3,							k_cs_fsr_easu_const3)
	CBUFFER_CONST(FSRCS,		float4,		viewport_normalized_bounds,				k_cs_fsr_viewport_bounds)
	CBUFFER_CONST(FSRCS,		float2,		resolution_multiplicator,				k_cs_fsr_resolution_multiplicator)
	CBUFFER_CONST(FSRCS,		float2,		resolution_multiplicator_pad,			k_cs_fsr_resolution_multiplicator_pad)
CBUFFER_END

#ifdef A_HALF
COMPUTE_TEXTURE_AND_SAMPLER(_2D_HALF, source_image, k_cs_sampler_fsr_source_image, 0)
COMPUTE_TEXTURE_UAV(_2D_RW_HALF, EASU_result_image, k_cs_sampler_fsr_easu_result_image, 0)
COMPUTE_TEXTURE_UAV(_2D_RW_HALF, RCAS_result_image, k_cs_sampler_fsr_rcas_result_image, 1)
#else
COMPUTE_TEXTURE_AND_SAMPLER(_2D, source_image, k_cs_sampler_fsr_source_image, 0)
COMPUTE_TEXTURE_UAV(_2D_RW, EASU_result_image, k_cs_sampler_fsr_easu_result_image, 0)
COMPUTE_TEXTURE_UAV(_2D_RW, RCAS_result_image, k_cs_sampler_fsr_rcas_result_image, 1)
#endif

#endif
