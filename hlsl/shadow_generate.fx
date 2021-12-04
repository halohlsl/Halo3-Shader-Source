#line 2 "source\rasterizer\hlsl\shadow_generate.fx"


#ifndef shadow_depth_map_1
PARAM_SAMPLER_COMPARISON_2D(shadow_depth_map_1);
#endif


void shadow_generate_vs(
	in vertex_type vertex,
	out float4 screen_position : SV_Position,
//#ifdef pc	
//	out float4 screen_position_copy : TEXCOORD0,
//#endif // pc
	out float2 texcoord : TEXCOORD1)
{
	float4 local_to_world_transform[3];
	//output to pixel shader
	always_local_to_view(vertex, local_to_world_transform, screen_position);

//#ifdef pc
//	screen_position_copy= screen_position;	
//#endif // pc
   texcoord= vertex.texcoord;
}

#if DX_VERSION == 9
float4 shadow_generate_ps(
//#ifdef pc
//	in float4 screen_position : TEXCOORD0,
//#endif // pc
	SCREEN_POSITION_INPUT(screen_position),
	in float2 texcoord : TEXCOORD1) : SV_Target
{
	float output_alpha;
	// do alpha test
	calc_alpha_test_ps(texcoord, screen_position, output_alpha);

	float alpha= 1.0f;
#ifndef NO_ALPHA_TO_COVERAGE
	alpha= output_alpha;
#endif

//#ifdef pc
//	float buffer_depth= screen_position.z / screen_position.w;
//	return float4(buffer_depth, buffer_depth, buffer_depth, alpha);
//#else // xenon
	return float4(1.0f, 1.0f, 1.0f, alpha);
//#endif // xenon
}
#elif DX_VERSION == 11
void shadow_generate_ps(
	SCREEN_POSITION_INPUT(screen_position),
	in float2 texcoord : TEXCOORD1)
{
	float output_alpha;
	// do alpha test
	calc_alpha_test_ps(texcoord, screen_position, output_alpha);
	clip(output_alpha - 0.5);
}
#endif



#define PCF_WIDTH 4
#define PCF_HEIGHT 4

#ifdef pc
static const float2 pixel_size= float2(1.0/512.0f, 1.0/512.0f);		// ###ctchou $TODO THIS NEEDS TO BE PASSED IN!!!
#endif

#include "texture.fx"


float sample_PCF_hardware(float3 fragment_shadow_position)
{
	float color = sampleCmp2D(shadow_depth_map_1, fragment_shadow_position.xy, fragment_shadow_position.z);
	return color;
}

float sample_percentage_closer_PCF_3x3_block(float3 fragment_shadow_position, float /*unused*/ depth_bias)		
{
	const float row_0 = -0.5f;
	const float row_1 = 0.5f;
	const float col_0 = -0.5f;
	const float col_1 = 0.5f;
							
	float res = texCmp2D_offset(shadow_depth_map_1, fragment_shadow_position.xy, col_0, row_0, fragment_shadow_position.z);
	res += texCmp2D_offset(shadow_depth_map_1, fragment_shadow_position.xy, col_1, row_0, fragment_shadow_position.z);
							
	res += texCmp2D_offset(shadow_depth_map_1, fragment_shadow_position.xy, col_0, row_1, fragment_shadow_position.z);
	res += texCmp2D_offset(shadow_depth_map_1, fragment_shadow_position.xy, col_1, row_1, fragment_shadow_position.z);
	return res / 4.0f;
}


float sample_percentage_closer_PCF_3x3_block_predicated(float3 fragment_shadow_position, float depth_bias)	//Not actual anymore
{
	return sample_percentage_closer_PCF_3x3_block(fragment_shadow_position, depth_bias);
}

float sample_percentage_closer_PCF_3x3_diamond_predicated(float3 fragment_shadow_position, float depth_bias)	//Not actual anymore
{
	return sample_percentage_closer_PCF_3x3_block(fragment_shadow_position, depth_bias);
}

float sample_percentage_closer_PCF_5x5_block_predicated(float3 fragment_shadow_position, float depth_bias)
{
	const float row_0 = -1.5f;
	const float row_1 = -0.5f;
	const float row_2 = 0.5f;
	const float row_3 = 1.5f;
	const float col_0 = -1.5f;
	const float col_1 = -0.5f;
	const float col_2 = 0.5f;
	const float col_3 = 1.5f;
							
	float res = texCmp2D_offset(shadow_depth_map_1, fragment_shadow_position.xy, col_1, row_0, fragment_shadow_position.z);
	res += texCmp2D_offset(shadow_depth_map_1, fragment_shadow_position.xy, col_2, row_0, fragment_shadow_position.z);
							
	res += texCmp2D_offset(shadow_depth_map_1, fragment_shadow_position.xy, col_0, row_1, fragment_shadow_position.z);
	res += texCmp2D_offset(shadow_depth_map_1, fragment_shadow_position.xy, col_1, row_1, fragment_shadow_position.z);
	res += texCmp2D_offset(shadow_depth_map_1, fragment_shadow_position.xy, col_2, row_1, fragment_shadow_position.z);
	res += texCmp2D_offset(shadow_depth_map_1, fragment_shadow_position.xy, col_3, row_1, fragment_shadow_position.z);
							
	res += texCmp2D_offset(shadow_depth_map_1, fragment_shadow_position.xy, col_0, row_2, fragment_shadow_position.z);
	res += texCmp2D_offset(shadow_depth_map_1, fragment_shadow_position.xy, col_1, row_2, fragment_shadow_position.z);
	res += texCmp2D_offset(shadow_depth_map_1, fragment_shadow_position.xy, col_2, row_2, fragment_shadow_position.z);
	res += texCmp2D_offset(shadow_depth_map_1, fragment_shadow_position.xy, col_3, row_2, fragment_shadow_position.z);
							
	res += texCmp2D_offset(shadow_depth_map_1, fragment_shadow_position.xy, col_1, row_3, fragment_shadow_position.z);
	res += texCmp2D_offset(shadow_depth_map_1, fragment_shadow_position.xy, col_2, row_3, fragment_shadow_position.z);

	return res / 12.0f;
}


// #define DEBUG_CLIP

void shadow_apply_vs(
	in vertex_type vertex,
	out float4 screen_position : SV_Position,
	out float3 world_position : TEXCOORD0,
	out float2 texcoord : TEXCOORD1,
//	out float4 bump_texcoord : TEXCOORD2,		// UNUSED
	out float3 normal : TEXCOORD3,
	out float3 fragment_shadow_position : TEXCOORD4,
	out float3 extinction : COLOR0,
	out float3 inscatter : COLOR1)
{
	float4 local_to_world_transform[3];
	//output to pixel shader
	always_local_to_view(vertex, local_to_world_transform, screen_position);

	world_position= vertex.position;
	// project vertex
	   texcoord= vertex.texcoord;
	normal= vertex.normal;
	
	compute_scattering(Camera_Position, vertex.position, extinction, inscatter);
	
	fragment_shadow_position.x= dot(float4(world_position, 1.0), v_lighting_constant_0);
	fragment_shadow_position.y= dot(float4(world_position, 1.0), v_lighting_constant_1);
	fragment_shadow_position.z= dot(float4(world_position, 1.0), v_lighting_constant_2);
}

accum_pixel shadow_apply_ps(
	SCREEN_POSITION_INPUT(screen_position),
	in float3 world_position : TEXCOORD0,
	in float2 texcoord : TEXCOORD1,
//	in float4 bump_texcoord : TEXCOORD2,
	in float3 normal : TEXCOORD3,
	in float3 fragment_shadow_position : TEXCOORD4,
	in float3 extinction : COLOR0,
	in float3 inscatter : COLOR1)
{
	float output_alpha;
	// do alpha test
	calc_alpha_test_ps(texcoord, screen_position, output_alpha);

	// transform position by shadow projection
//	float3 fragment_shadow_position; // = transform_point(world_position, shadow_projection_1);
//	fragment_shadow_position.x= dot(float4(world_position, 1.0), p_lighting_constant_0);			// ###ctchou $TODO $PERF pass float4(world_position, 1.0) from vertex shader
//	fragment_shadow_position.y= dot(float4(world_position, 1.0), p_lighting_constant_1);			// ###ctchou $TODO $PERF or even better - do this transformation in the vertex shader
//	fragment_shadow_position.z= dot(float4(world_position, 1.0), p_lighting_constant_2);			// ###ctchou $TODO $PERF and pass the transformed point to the pixel shader

	// compute maximum slope given normal
	normal.xyz= normalize(normal.xyz);
	float3 light_dir= normalize(p_lighting_constant_2.xyz);											// ###ctchou $TODO $PERF pass additional normalized version of this into shader
	float cosine= -dot(normal.xyz, light_dir);														// transform normal into 'lighting' space (only Z component - equivalent to normal dot lighting direction)
	
	   // compute the bump normal in local tangent space												// shadows do not currently respect bump
//	float3 bump_normal_in_tangent_space;
//	calc_bumpmap_ps(texcoord, bump_texcoord, bump_normal_in_tangent_space);
	// rotate bump to world space (same space as lightprobe) and normalize
//	float3 bump_normal= normalize( mul(bump_normal_in_tangent_space, tangent_frame) );
	
	float shadow_darkness;																			// ###ctchou $TODO pass this in (based on ambientness of the lightprobe)
	
	// compute shadow falloff as a function of the z depth (distance from front shadow volume plane), and the incident angle from lightsource (cosine falloff)
	float shadow_falloff= max(0.0f, fragment_shadow_position.z*2-1);								// shift z-depth falloff to bottom half of the shadow volume (no depth falloff in top half)
	shadow_falloff *= shadow_falloff;																// square depth
	shadow_darkness= k_ps_constant_shadow_alpha.r * (1-shadow_falloff*shadow_falloff) * max(0.0f, cosine);		// z_depth_falloff= 1 - (shifted_depth)^4,	incident_falloff= cosine lobe

	float darken= 1.0f;
	if (shadow_darkness > 0.001)																	// if maximum shadow darkness is zero (or very very close), don't bother doing the expensive PCF sampling
	{
		// sample shadow depth
		float percentage_closer= sample_percentage_closer_PCF_3x3_block(fragment_shadow_position, /*unused*/ 0.0f);
	
		// compute darkening
		darken= 1-shadow_darkness + percentage_closer * shadow_darkness;
		darken*= darken;
	}
//	else
//	{
//		clip(-1.0f);		// DEBUG - to clip regions that aren't calculated						// ###ctchou $TODO $PERF - putting this clip in might improve performance if we're alpha-blend bound (unlikely)
//	}
	
	
	// the destination contains (pixel * extinction + inscatter) - we want to change it to (pixel * darken * extinction + inscatter)
	// so we multiply by darken (aka src alpha), and add inscatter * (1-darken)
	return convert_to_render_target(float4(inscatter*g_exposure.rrr, darken), true, false);
}
