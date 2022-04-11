#line 2 "source\rasterizer\hlsl\FSR_bilinear.hlsl"

//@generate screen

#include "global.fx"
#include "fidelityFX_super_resolution_registers.fx"

struct s_vsout
{
	float4 pos : SV_POSITION;
	float2 texcoord : TEXCOORD0;
};

s_vsout default_vs(uint vI : SV_VERTEXID)
{
	s_vsout vsout;
	vsout.texcoord = float2(vI & 1,(vI >> 1) & 1);
	vsout.pos = float4(vsout.texcoord.x * 2.0 - 1.0f, vsout.texcoord.y * (-2.0) + 1.0f, 0.0f, 1.0f);
	return vsout;
}

float4 default_ps(s_vsout vsout) :SV_TARGET
{
	return source_image.t.Sample(source_image.s,
		clamp(
			vsout.texcoord * resolution_multiplicator,
			viewport_normalized_bounds.xy,
			viewport_normalized_bounds.zw));
}
