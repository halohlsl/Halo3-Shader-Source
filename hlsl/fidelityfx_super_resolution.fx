#ifndef _FIDELITYFX_SUPER_RESOLUTION_FX_
#define _FIDELITYFX_SUPER_RESOLUTION_FX_

#include "global.fx"
#include "fidelityFX_super_resolution_registers.fx"

#define A_GPU
#define A_HLSL
#include "fidelityFX_super_resolution_definitions.h"
#undef A_GPU
#undef A_HLSL

#if !defined(FSR_EASU) && !defined (FSR_RCAS)
#error At least 1 of FSR_EASU and FSR_RCAS should be defined!
#endif

#ifdef FSR_EASU

#if defined(FSR_RCAS)
#error Only 1 of FSR_EASU and FSR_RCAS can be defined at the same time!
#endif

A4 FsrEasuR(in float2 p) { return source_image.t.GatherRed(source_image.s, p, int2(0, 0)); }
A4 FsrEasuG(in float2 p) { return source_image.t.GatherGreen(source_image.s, p, int2(0, 0)); }
A4 FsrEasuB(in float2 p) { return source_image.t.GatherBlue(source_image.s, p, int2(0, 0)); }

void calc_pixel(in AU2 pos)
{
	A3 result;
	FsrEasu(result, pos, easu_const0, easu_const1, easu_const2, easu_const3);
	EASU_result_image[pos] = A4(result, 1);
}
#endif

#ifdef FSR_RCAS

#if defined (FSR_EASU)
#error Only 1 of FSR_EASU and FSR_RCAS can be defined at the same time!
#endif

A4 FsrRcasLoad(in AS2 p) { return EASU_result_image.Load(int2(p)); }
void FsrRcasInput(inout A1 r, inout A1 g, inout A1 b) {}

void calc_pixel(in AU2 pos)
{
	A3 result;
	FsrRcas(result.r, result.g, result.b, pos, rcas_const0);
	RCAS_result_image[pos] = A4(result, 1);
}
#endif

[numthreads(64, 1, 1)]
void default_cs(in uint3 LocalThreadId : SV_GroupThreadID, in uint3 WorkGroupId : SV_GroupID, in uint3 Dtid : SV_DispatchThreadID)
{
	// Do remapping of local xy in workgroup for a more PS-like swizzle pattern.
	AU2 pos = ARmp8x8(LocalThreadId.x) + AU2(WorkGroupId.x << 4u, WorkGroupId.y << 4u);

	calc_pixel(pos);
	pos.x += 8u;
	calc_pixel(pos);
	pos.y += 8u;
	calc_pixel(pos);
	pos.x -= 8u;
	calc_pixel(pos);
}

#endif
