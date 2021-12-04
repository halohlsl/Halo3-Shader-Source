#include "entry.fx"
#include "common.fx"

PARAM_SAMPLER_2D(alpha_test_map);
PARAM(float4, alpha_test_map_xform);

void calc_alpha_test_off_ps(
	in float2 texcoord,
	in float2 fragment_position,
	out float output_alpha)
{
	output_alpha = 1.0;
}

void perform_alpha_clip(float alpha)
{
#if ENTRY_POINT(entry_point) == ENTRY_POINT_shadow_generate

	clip(alpha-0.5f);			// always on for shadow

#else

#ifdef NO_ALPHA_TO_COVERAGE
	clip(alpha-0.5f);			// have to clip pixels ourselves
#elif (DX_VERSION == 11)
	
	// we don't use alpha to coverage in D3D11, so we need to clip when alpha to coverage would have been enabled on Xenon
	// - this does the same test that is done in c_render_method_shader::postprocess_shader
	
	#define IS_NOT_ATOC_MATERIAL(material) IS_NOT_ATOC_MATERIAL_##material
	#define IS_NOT_ATOC_MATERIAL_cook_torrance 1
	#define IS_NOT_ATOC_MATERIAL_two_lobe_phong 1
	#define IS_NOT_ATOC_MATERIAL_default_skin 1
	#define IS_NOT_ATOC_MATERIAL_glass 1
	#define IS_NOT_ATOC_MATERIAL_organism 1
	
	#if IS_NOT_ATOC_MATERIAL(material_type)	!= 1
		clip(alpha-0.5f);
	#endif
#endif

#endif
}


void calc_alpha_test_on_ps(
	in float2 texcoord,
	in float2 fragment_position,
	out float output_alpha)
{
	float alpha= sample2D(alpha_test_map, transform_texcoord(texcoord, alpha_test_map_xform)).a;
	output_alpha= alpha;
	perform_alpha_clip(alpha);
}

void calc_alpha_test_fuzzy_ps(
	in float2 texcoord,
	in float2 fragment_position,
	out float output_alpha)
{
	float alpha= sample2D(alpha_test_map, transform_texcoord(texcoord, alpha_test_map_xform)).a;
	alpha-= rand2(fragment_position) * (1 - alpha);
	output_alpha= alpha;
	perform_alpha_clip(alpha);
}
