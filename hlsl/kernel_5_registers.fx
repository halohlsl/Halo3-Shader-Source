#ifndef _KERNEL_5_REGISTERS_FX_
#ifndef DEFINE_CPP_CONSTANTS
#define _KERNEL_5_REGISTERS_FX_
#endif

CBUFFER_BEGIN(Kernel5PS)
	CBUFFER_CONST_ARRAY(Kernel5PS,	float4,		kernel, [5],	k_ps_kernel_5_kernel)
CBUFFER_END

#endif
