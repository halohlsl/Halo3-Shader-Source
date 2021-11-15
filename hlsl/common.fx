#if !defined(COMMON_FX)
#define COMMON_FX
#include "blend.fx"
#include "utilities.fx"
PARAM_SAMPLER_2D(depth_map); // for soft - Z
PARAM(bool, use_soft_fresnel);
PARAM(float, soft_fresnel_power);
PARAM(bool, use_soft_z);
PARAM(float, soft_z_range);
PARAM(float4, screen_params);

float2 z_to_w_coeffs()
{
	const float zf = 0.007812500f;
	const float zn = 10240.00000f;

	const float2 k = float2(
		zf / (zf - zn),
		-zn * zf / (zf - zn));
	return k;
}

float z_to_w(float z)
{
	float2 k = z_to_w_coeffs();
	return k.y / (z - k.x);
}

// Flip binormal if mirrored UV
float3 checkBinormal(in float3 tangent, in float3 binormal, in float3 normal)
{
	float3 res = binormal;
	//// check for mirrored UV
	//// TBN invariants
	//// dot(cross(n, t), b)
	//// dot(cross(b, n), t)
	//// dot(cross(t, b), n)
	//// Do not flip normal if it is already flipped (maya uv winding order)
	//if (!IS_VERTEX_TYPE(s_skinned_vertex) && !IS_VERTEX_TYPE(s_flat_skinned_vertex)) {
	//   res *= sign(dot(cross(tangent, normal), binormal));
	//}
	return res;
}

float SmoothStep(float x)
{
	return x * x * (3 - 2 * x);
}

float calc_fresnel_dp(in float3 wnorm, in float3 wview)
{
	//   float3 V = normalize(wpos - camPos);
	float NdotV = saturate(abs(dot(wnorm, wview)));
	NdotV = SmoothStep(NdotV);

	return NdotV;
}

float get_softness(float z1, float z2, float range)
{
	return saturate((z1 - z2) * range);
}

void apply_soft_fade_off(inout float4 value, in float3 wnorm, in float3 wview,
	in float linearDepth, in float2 vPos)
{
}

void apply_soft_fade_on(inout float4 albedo, in float3 wnorm, in float3 wview,
	in float linearDepth, in float2 vPos)
{
	float val = 1;
	if (use_soft_fresnel) {
		float fresnel_dp = calc_fresnel_dp(wnorm, wview);
		val *= pow(fresnel_dp, soft_fresnel_power);
	}
	if (use_soft_z) {
		float2 sampler_size;
		depth_map.t.GetDimensions(sampler_size.x, sampler_size.y);
		float2 frag_coord = (vPos.xy + float2(0.5, 0.5)) / sampler_size.xy;
		val *= get_softness(z_to_w(sample2D(depth_map, frag_coord).r), linearDepth, soft_z_range);
	}
#if BLEND_MODE(alpha_blend)
	albedo.w *= val;
#else
	albedo.rgb *= val;
#endif
}


#endif
