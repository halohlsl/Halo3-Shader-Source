#ifndef _GLOBAL_TEXTURE_SAMPLING_FX_
#define _GLOBAL_TEXTURE_SAMPLING_FX_

#include "global_texture.fx"
#include "global_registers.fx"

#define DECLARE_IN_VIEWPORT_FLAG(_index) static bool ps_global_is_texture_##_index##_in_viewport = ps_global_is_texture_in_viewport_flags & (1 << _index)
DECLARE_IN_VIEWPORT_FLAG(0);
DECLARE_IN_VIEWPORT_FLAG(1);
DECLARE_IN_VIEWPORT_FLAG(2);
DECLARE_IN_VIEWPORT_FLAG(3);
DECLARE_IN_VIEWPORT_FLAG(4);
DECLARE_IN_VIEWPORT_FLAG(5);
DECLARE_IN_VIEWPORT_FLAG(6);
DECLARE_IN_VIEWPORT_FLAG(7);
DECLARE_IN_VIEWPORT_FLAG(8);
DECLARE_IN_VIEWPORT_FLAG(9);
DECLARE_IN_VIEWPORT_FLAG(10);
DECLARE_IN_VIEWPORT_FLAG(11);
DECLARE_IN_VIEWPORT_FLAG(12);
DECLARE_IN_VIEWPORT_FLAG(13);
DECLARE_IN_VIEWPORT_FLAG(14);
DECLARE_IN_VIEWPORT_FLAG(15);
DECLARE_IN_VIEWPORT_FLAG(16);
DECLARE_IN_VIEWPORT_FLAG(17);
DECLARE_IN_VIEWPORT_FLAG(18);
DECLARE_IN_VIEWPORT_FLAG(19);
DECLARE_IN_VIEWPORT_FLAG(20);
DECLARE_IN_VIEWPORT_FLAG(21);
DECLARE_IN_VIEWPORT_FLAG(22);
DECLARE_IN_VIEWPORT_FLAG(23);
DECLARE_IN_VIEWPORT_FLAG(24);
DECLARE_IN_VIEWPORT_FLAG(25);
DECLARE_IN_VIEWPORT_FLAG(26);
DECLARE_IN_VIEWPORT_FLAG(27);
DECLARE_IN_VIEWPORT_FLAG(28);
DECLARE_IN_VIEWPORT_FLAG(29);
DECLARE_IN_VIEWPORT_FLAG(30);
DECLARE_IN_VIEWPORT_FLAG(31);
#undef DECLARE_IN_VIEWPORT_FLAG
#define LOCAL_SAMPLER_2D_IN_VIEWPORT_MAYBE(_name, _slot) DECLARE_LOCAL_SAMPLER_VIEWPORT(_name, _slot, texture2D, viewport_texture_sampler_2d, ps_global_is_texture_##_slot##_in_viewport)

static float2 ps_global_viewport_top_left_uv = ps_global_viewport_top_left_pixel * ps_global_render_pixel_size;
static float4 ps_global_viewport_bounds_pixel = float4(ps_global_viewport_top_left_pixel + float2(0.5f, 0.5f), ps_global_viewport_top_left_pixel + ps_global_viewport_res - float2(0.5f, 0.5f));

float2 calc_global_uv(float2 global_pixel_coords)
{
	return global_pixel_coords * ps_global_render_pixel_size;
}

float2 calc_viewport_uv(float2 global_uv)
{
	return clamp(ps_global_viewport_top_left_uv + global_uv * ps_global_viewport_res_multipliers, ps_global_viewport_bounds_uv.xy, ps_global_viewport_bounds_uv.zw);
}

float2 calc_viewport_pixel_coords_from_uv(float2 global_uv)
{
	return clamp(ps_global_viewport_top_left_pixel + global_uv * ps_global_viewport_res, ps_global_viewport_bounds_pixel.xy, ps_global_viewport_bounds_pixel.zw);
}

float2 calc_viewport_pixel_coords_from_pixel_coords(float2 global_pixel_coords)
{
	return clamp(ps_global_viewport_top_left_pixel + global_pixel_coords * ps_global_viewport_res_multipliers, ps_global_viewport_bounds_pixel.xy, ps_global_viewport_bounds_pixel.zw);
}





float4 sample2D(in texture_sampler_2d s, in float2 uv)
{
	return s.t.Sample(s.s, uv);
}

min16float4 sample2D(in texture_sampler_2d_half s, in float2 uv)
{
	return s.t.Sample(s.s, uv);
}

float4 gatherRed(in texture_sampler_2d s, in float2 uv)
{
	return s.t.GatherRed(s.s, uv);
}

min16float4 gatherRed(in texture_sampler_2d_half s, in float2 uv)
{
	return s.t.GatherRed(s.s, uv);
}

float4 gatherGreen(in texture_sampler_2d s, in float2 uv)
{
	return s.t.GatherGreen(s.s, uv);
}

min16float4 gatherGreen(in texture_sampler_2d_half s, in float2 uv)
{
	return s.t.GatherGreen(s.s, uv);
}

float4 gatherBlue(in texture_sampler_2d s, in float2 uv)
{
	return s.t.GatherBlue(s.s, uv);
}

min16float4 gatherBlue(in texture_sampler_2d_half s, in float2 uv)
{
	return s.t.GatherBlue(s.s, uv);
}

float4 gatherAlpha(in texture_sampler_2d s, in float2 uv)
{
	return s.t.GatherAlpha(s.s, uv);
}

min16float4 gatherAlpha(in texture_sampler_2d_half s, in float2 uv)
{
	return s.t.GatherAlpha(s.s, uv);
}

float4 gatherRedOffset(in texture_sampler_2d s, in float2 uv, in int2 offset)
{
	return s.t.GatherRed(s.s, uv, offset);
}

min16float4 gatherRedOffset(in texture_sampler_2d_half s, in float2 uv, in int2 offset)
{
	return s.t.GatherRed(s.s, uv, offset);
}

float4 gatherGreenOffset(in texture_sampler_2d s, in float2 uv, in int2 offset)
{
	return s.t.GatherGreen(s.s, uv, offset);
}

min16float4 gatherGreenOffset(in texture_sampler_2d_half s, in float2 uv, in int2 offset)
{
	return s.t.GatherGreen(s.s, uv, offset);
}

float4 gatherBlueOffset(in texture_sampler_2d s, in float2 uv, in int2 offset)
{
	return s.t.GatherBlue(s.s, uv, offset);
}

min16float4 gatherBlueOffset(in texture_sampler_2d_half s, in float2 uv, in int2 offset)
{
	return s.t.GatherBlue(s.s, uv, offset);
}

float4 gatherAlphaOffset(in texture_sampler_2d s, in float2 uv, in int2 offset)
{
	return s.t.GatherAlpha(s.s, uv, offset);
}

min16float4 gatherAlphaOffset(in texture_sampler_2d_half s, in float2 uv, in int2 offset)
{
	return s.t.GatherAlpha(s.s, uv, offset);
}

float4 sampleBias2D(in texture_sampler_2d s, in float2 uv, in float mip_bias)
{
	return s.t.SampleBias(s.s, uv, mip_bias);
}

min16float4 sampleBias2D(in texture_sampler_2d_half s, in float2 uv, in float mip_bias)
{
	return s.t.SampleBias(s.s, uv, mip_bias);
}

float4 sampleBiasGlobal2D(in texture_sampler_2d s, in float2 uv)
{
	return sampleBias2D(s, uv, ps_global_mip_bias);
}

min16float4 sampleBiasGlobal2D(in texture_sampler_2d_half s, in float2 uv)
{
	return sampleBias2D(s, uv, ps_global_mip_bias);
}

float4 sampleCmp2D(in texture_sampler_comparison_2d s, in float2 uv, in float compareValue)
{
	return s.t.SampleCmp(s.s, uv, compareValue);
}

float4 sample2Dlod(in texture_sampler_2d s, in float2 uv, in float lod)
{
	return s.t.SampleLevel(s.s, uv, lod);
}

min16float4 sample2Dlod(in texture_sampler_2d_half s, in float2 uv, in float lod)
{
	return s.t.SampleLevel(s.s, uv, lod);
}

float4 sample2DlodOffset(in texture_sampler_2d s, in float2 uv, in float lod, in int2 offset)
{
	return s.t.SampleLevel(s.s, uv, lod, offset);
}

min16float4 sample2DlodOffset(in texture_sampler_2d_half s, in float2 uv, in float lod, in int2 offset)
{
	return s.t.SampleLevel(s.s, uv, lod, offset);
}

float4 sample2Doffset(in texture_sampler_2d s, in float2 uv, in int2 offset)
{
	return s.t.Sample(s.s, uv, offset);
}

min16float4 sample2Doffset(in texture_sampler_2d_half s, in float2 uv, in int2 offset)
{
	return s.t.Sample(s.s, uv, offset);
}

float4 sampleBias2Doffset(in texture_sampler_2d s, in float2 uv, in int2 offset, in float mip_bias)
{
	return s.t.SampleBias(s.s, uv, mip_bias, offset);
}

min16float4 sampleBias2Doffset(in texture_sampler_2d_half s, in float2 uv, in int2 offset, in float mip_bias)
{
	return s.t.SampleBias(s.s, uv, mip_bias, offset);
}

float4 sampleBiasGlobal2Doffset(in texture_sampler_2d s, in float2 uv, in int2 offset)
{
	return sampleBias2Doffset(s, uv, offset, ps_global_mip_bias);
}

min16float4 sampleBiasGlobal2Doffset(in texture_sampler_2d_half s, in float2 uv, in int2 offset)
{
	return sampleBias2Doffset(s, uv, offset, ps_global_mip_bias);
}

float4 sampleCmp2Doffset(in texture_sampler_comparison_2d s, in float2 uv, in float compareValue, in int2 offset)
{
	return s.t.SampleCmp(s.s, uv, compareValue, offset);
}

float4 sample3D(in texture_sampler_3d s, in float3 uvw)
{
	return s.t.Sample(s.s, uvw);
}

float4 sampleBias3D(in texture_sampler_3d s, in float3 uvw, in float mip_bias)
{
	return s.t.SampleBias(s.s, uvw, mip_bias);
}

float4 sampleBiasGlobal3D(in texture_sampler_3d s, in float3 uvw)
{
	return sampleBias3D(s, uvw, ps_global_mip_bias);
}

float4 sample3Dlod(in texture_sampler_3d s, in float3 uvw, in float lod)
{
	return s.t.SampleLevel(s.s, uvw, lod);
}

float4 sampleCUBE(in texture_sampler_cube s, in float3 v)
{
	return s.t.Sample(s.s, v);
}

float4 sampleBiasCUBE(in texture_sampler_cube s, in float3 v, in float mip_bias)
{
	return s.t.SampleBias(s.s, v, mip_bias);
}

float4 sampleBiasGlobalCUBE(in texture_sampler_cube s, in float3 v)
{
	return sampleBiasCUBE(s, v, ps_global_mip_bias);
}

float4 sampleCUBElod(in texture_sampler_cube s, in float3 v, in float lod)
{
	return s.t.SampleLevel(s.s, v, lod);
}

// convert normalized 3d texture z coordinate to texture array coordinate
float4 convert_3d_texture_coord_to_array_texture(in texture_sampler_2d_array t, in float3 uvw)
{
	uint width, height, elements;
	t.t.GetDimensions(width, height, elements);
	uvw.z = (frac(uvw.z) * elements);
	float next_z = (uvw.z >= (elements - 1)) ? 0 : (uvw.z + 1);
	return float4(uvw, next_z);
}





float4 sample2D(in viewport_texture_sampler_2d s, in float2 uv)
{
	texture_sampler_2d tmp = { s.s, s.t };
	float2 new_uv = uv;
	[branch]
	if (s.with_viewport)
		new_uv = calc_viewport_uv(new_uv);
	return sample2D(tmp, new_uv);

}

float4 gatherRed(in viewport_texture_sampler_2d s, in float2 uv)
{
	texture_sampler_2d tmp = { s.s, s.t };
	float2 new_uv = uv;
	[branch]
	if (s.with_viewport)
		new_uv = calc_viewport_uv(new_uv);
	return gatherRed(tmp, new_uv);
}

float4 gatherGreen(in viewport_texture_sampler_2d s, in float2 uv)
{
	texture_sampler_2d tmp = { s.s, s.t };
	float2 new_uv = uv;
	[branch]
	if (s.with_viewport)
		new_uv = calc_viewport_uv(new_uv);
	return gatherGreen(tmp, new_uv);
}

float4 gatherBlue(in viewport_texture_sampler_2d s, in float2 uv)
{
	texture_sampler_2d tmp = { s.s, s.t };
	float2 new_uv = uv;
	[branch]
	if (s.with_viewport)
		new_uv = calc_viewport_uv(new_uv);
	return gatherBlue(tmp, new_uv);
}

float4 gatherAlpha(in viewport_texture_sampler_2d s, in float2 uv)
{
	texture_sampler_2d tmp = { s.s, s.t };
	float2 new_uv = uv;
	[branch]
	if (s.with_viewport)
		new_uv = calc_viewport_uv(new_uv);
	return gatherAlpha(tmp, new_uv);
}

float4 gatherRedOffset(in viewport_texture_sampler_2d s, in float2 uv, in int2 offset)
{
	texture_sampler_2d tmp = { s.s, s.t };
	float2 new_uv = uv;
	[branch]
	if (s.with_viewport)
	{
		new_uv += float2(offset) * ps_global_render_pixel_size;
		new_uv = calc_viewport_uv(new_uv);
		return gatherRed(tmp, new_uv);
	}
	else
		return gatherRedOffset(tmp, new_uv, offset);
}

float4 gatherGreenOffset(in viewport_texture_sampler_2d s, in float2 uv, in int2 offset)
{
	texture_sampler_2d tmp = { s.s, s.t };
	float2 new_uv = uv;
	[branch]
	if (s.with_viewport)
	{
		new_uv += float2(offset) * ps_global_render_pixel_size;
		new_uv = calc_viewport_uv(new_uv);
		return gatherGreen(tmp, new_uv);
	}
	else
		return gatherGreenOffset(tmp, new_uv, offset);
}

float4 gatherBlueOffset(in viewport_texture_sampler_2d s, in float2 uv, in int2 offset)
{
	texture_sampler_2d tmp = { s.s, s.t };
	float2 new_uv = uv;
	[branch]
	if (s.with_viewport)
	{
		new_uv += float2(offset) * ps_global_render_pixel_size;
		new_uv = calc_viewport_uv(new_uv);
		return gatherBlue(tmp, new_uv);
	}
	else
		return gatherBlueOffset(tmp, new_uv, offset);
}

float4 gatherAlphaOffset(in viewport_texture_sampler_2d s, in float2 uv, in int2 offset)
{
	texture_sampler_2d tmp = { s.s, s.t };
	float2 new_uv = uv;
	[branch]
	if (s.with_viewport)
	{
		new_uv += float2(offset) * ps_global_render_pixel_size;
		new_uv = calc_viewport_uv(new_uv);
		return gatherAlpha(tmp, new_uv);
	}
	else
		return gatherAlphaOffset(tmp, new_uv, offset);
}

float4 sampleBias2D(in viewport_texture_sampler_2d s, in float2 uv, in float mip_bias)
{
	texture_sampler_2d tmp = { s.s, s.t };
	float2 new_uv = uv;
	[branch]
	if (s.with_viewport)
		new_uv = calc_viewport_uv(new_uv);
	return sampleBias2D(tmp, new_uv, mip_bias);
}

float4 sampleBiasGlobal2D(in viewport_texture_sampler_2d s, in float2 uv)
{
	return sampleBias2D(s, uv, ps_global_mip_bias);
}

float4 sampleCmp2D(in viewport_texture_sampler_comparison_2d s, in float2 uv, in float compareValue)
{
	texture_sampler_comparison_2d tmp = { s.s, s.t };
	float2 new_uv = uv;
	[branch]
	if (s.with_viewport)
		new_uv = calc_viewport_uv(new_uv);
	return sampleCmp2D(tmp, new_uv, compareValue);
}

float4 sample2Dlod(in viewport_texture_sampler_2d s, in float2 uv, in float lod)
{
	texture_sampler_2d tmp = { s.s, s.t };
	float2 new_uv = uv;
	[branch]
	if (s.with_viewport)
		new_uv = calc_viewport_uv(new_uv);
	return sample2Dlod(tmp, new_uv, lod);
}

float4 sample2DlodOffset(in viewport_texture_sampler_2d s, in float2 uv, in float lod, in int2 offset)
{
	texture_sampler_2d tmp = { s.s, s.t };
	float2 new_uv = uv;
	[branch]
	if (s.with_viewport)
	{
		new_uv += float2(offset) * ps_global_render_pixel_size;
		new_uv = calc_viewport_uv(new_uv);
		return sample2Dlod(tmp, new_uv, lod);
	}
	else
		return sample2DlodOffset(tmp, new_uv, lod, offset);
}

float4 sample2Doffset(in viewport_texture_sampler_2d s, in float2 uv, in int2 offset)
{
	texture_sampler_2d tmp = { s.s, s.t };
	float2 new_uv = uv;
	[branch]
	if (s.with_viewport)
	{
		new_uv += float2(offset) * ps_global_render_pixel_size;
		new_uv = calc_viewport_uv(new_uv);
		return sample2D(tmp, new_uv);
	}
	else
		return sample2Doffset(tmp, new_uv, offset);
}

float4 sampleBias2Doffset(in viewport_texture_sampler_2d s, in float2 uv, in int2 offset, in float mip_bias)
{
	texture_sampler_2d tmp = { s.s, s.t };
	float2 new_uv = uv;
	[branch]
	if (s.with_viewport)
		new_uv = calc_viewport_uv(new_uv);
	return sampleBias2Doffset(tmp, new_uv, offset, mip_bias);
}

float4 sampleBiasGlobal2Doffset(in viewport_texture_sampler_2d s, in float2 uv, in int2 offset)
{
	return sampleBias2Doffset(s, uv, offset, ps_global_mip_bias);
}

float4 sampleCmp2Doffset(in viewport_texture_sampler_comparison_2d s, in float2 uv, in float compareValue, in int2 offset)
{
	texture_sampler_comparison_2d tmp = { s.s, s.t };
	float2 new_uv = uv;
	[branch]
	if (s.with_viewport)
		new_uv = calc_viewport_uv(new_uv);
	return sampleCmp2Doffset(tmp, new_uv, compareValue, offset);
}
#endif
