#define DETAIL_MULTIPLIER 4.59479f
// 4.59479f == 2 ^ 2.2  (sRGB gamma)

PARAM(float4, albedo_color);
PARAM(float4, albedo_color2);		// used for color-mask
PARAM(float4, albedo_color3);

PARAM_SAMPLER_2D(base_map);
PARAM(float4, base_map_xform);
PARAM_SAMPLER_2D(detail_map);
PARAM(float4, detail_map_xform);

#ifdef pc
PARAM(float4, debug_tint);
#endif // pc

float3 calc_pc_albedo_lighting(
	in float3 albedo,
	in float3 normal)
{
	float3 light_direction1= float3(0.68f, 0.48f, -0.6f);
	float3 light_direction2= float3(-0.3f, -0.7f, -0.6f);
	
	float3 light_color1= float3(1.2f, 1.2f, 1.2f);
	float3 light_color2= float3(0.5f, 0.5f, 0.5f);
	float3 light_color3= float3(0.7f, 0.7f, 0.7f);
	float3 light_color4= float3(0.4f, 0.4f, 0.4f);
	
	float3 n_dot_l;
	
	n_dot_l= saturate(dot(normal, light_direction1))*light_color1;
	n_dot_l+= saturate(dot(normal, -light_direction1))*light_color2;
	n_dot_l+= saturate(dot(normal, light_direction2))*light_color3;
	n_dot_l+= saturate(dot(normal, -light_direction2))*light_color4;

	return(n_dot_l*albedo);
}

float3 srgb_de_gamma (float3 Csrgb)
{
   return (Csrgb<=0.04045f) ? (Csrgb/12.92f) : pow((Csrgb + 0.055f)/1.055f, 2.4f);
}
float3 srgb_gamma  (float3 Clinear)
{
   return (Clinear<=.0031308f) ? (12.92f * Clinear) : (1.055f * pow(Clinear,1.f/2.4f)) - 0.055f;
}


void apply_pc_albedo_modifier(
	inout float4 albedo,
	in float3 normal)
{
#ifdef pc
	albedo.rgb= lerp(albedo.rgb, debug_tint.rgb, debug_tint.a);
	
	if (p_shader_pc_albedo_lighting!=0.f)
	{
		albedo.xyz= calc_pc_albedo_lighting(albedo.xyz, normal);
	}
	// apply gamma correction by hand on PC to color target only
//	albedo.rgb= srgb_gamma(albedo.rgb);
#endif // pc
}

void calc_albedo_constant_color_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc)
{
	albedo= albedo_color;
	
	apply_pc_albedo_modifier(albedo, normal);
}

void calc_albedo_default_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc)
{
	float4	base=	sampleBiasGlobal2D(base_map,   transform_texcoord(texcoord, base_map_xform));
	float4	detail=	sampleBiasGlobal2D(detail_map, transform_texcoord(texcoord, detail_map_xform));

	albedo.rgb= base.rgb * (detail.rgb * DETAIL_MULTIPLIER) * albedo_color.rgb;
	albedo.w= base.w*detail.w*albedo_color.w;

	apply_pc_albedo_modifier(albedo, normal);
}

PARAM_SAMPLER_2D(detail_map2);
PARAM(float4, detail_map2_xform);

void calc_albedo_detail_blend_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc)
{
	float4	base=	sampleBiasGlobal2D(base_map,		transform_texcoord(texcoord, base_map_xform));
	float4	detail=	sampleBiasGlobal2D(detail_map,	transform_texcoord(texcoord, detail_map_xform));	
	float4	detail2= sampleBiasGlobal2D(detail_map2,	transform_texcoord(texcoord, detail_map2_xform));

	albedo.xyz= (1.0f-base.w)*detail.xyz + base.w*detail2.xyz;
	albedo.xyz= DETAIL_MULTIPLIER * base.xyz*albedo.xyz;
	albedo.w= (1.0f-base.w)*detail.w + base.w*detail2.w;

	apply_pc_albedo_modifier(albedo, normal);
}

PARAM_SAMPLER_2D(detail_map3);
PARAM(float4, detail_map3_xform);

void calc_albedo_three_detail_blend_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc)
{
	float4 base=	sampleBiasGlobal2D(base_map,		transform_texcoord(texcoord, base_map_xform));
	float4 detail1= sampleBiasGlobal2D(detail_map,	transform_texcoord(texcoord, detail_map_xform));
	float4 detail2= sampleBiasGlobal2D(detail_map2,	transform_texcoord(texcoord, detail_map2_xform));
	float4 detail3= sampleBiasGlobal2D(detail_map3,	transform_texcoord(texcoord, detail_map3_xform));

	float blend1= saturate(2.0f*base.w);
	float blend2= saturate(2.0f*base.w - 1.0f);

	float4 first_blend=  (1.0f-blend1)*detail1		+ blend1*detail2;
	float4 second_blend= (1.0f-blend2)*first_blend	+ blend2*detail3;

	albedo.rgb= DETAIL_MULTIPLIER * base.rgb * second_blend.rgb;
	albedo.a= second_blend.a;

	apply_pc_albedo_modifier(albedo, normal);
}

PARAM_SAMPLER_2D(change_color_map);
PARAM(float4, change_color_map_xform);
PARAM(float3, primary_change_color);
PARAM(float3, secondary_change_color);
PARAM(float3, tertiary_change_color);
PARAM(float3, quaternary_change_color);

void calc_albedo_two_change_color_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc)
{
	float4 base=			sampleBiasGlobal2D(base_map,			transform_texcoord(texcoord, base_map_xform));
	float4 detail=			sampleBiasGlobal2D(detail_map,		transform_texcoord(texcoord, detail_map_xform));
	float4 change_color=	sampleBiasGlobal2D(change_color_map, 	transform_texcoord(texcoord, change_color_map_xform));

	change_color.xyz=	((1.0f-change_color.x) + change_color.x*primary_change_color.xyz)*
						((1.0f-change_color.y) + change_color.y*secondary_change_color.xyz);

	albedo.xyz= DETAIL_MULTIPLIER * base.xyz*detail.xyz*change_color.xyz;
	albedo.w= base.w*detail.w;
	
	apply_pc_albedo_modifier(albedo, normal);
}

void calc_albedo_four_change_color_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc)
{
	float4 base=			sampleBiasGlobal2D(base_map,			transform_texcoord(texcoord, base_map_xform));
	float4 detail=			sampleBiasGlobal2D(detail_map,		transform_texcoord(texcoord, detail_map_xform));
	float4 change_color=	sampleBiasGlobal2D(change_color_map,	transform_texcoord(texcoord, change_color_map_xform));

	change_color.xyz=	((1.0f-change_color.x) + change_color.x*primary_change_color.xyz)	*
						((1.0f-change_color.y) + change_color.y*secondary_change_color.xyz)	*
						((1.0f-change_color.z) + change_color.z*tertiary_change_color.xyz)	*
						((1.0f-change_color.w) + change_color.w*quaternary_change_color.xyz);

	albedo.xyz= DETAIL_MULTIPLIER * base.xyz*detail.xyz*change_color.xyz;
	albedo.w= base.w*detail.w;
	
	apply_pc_albedo_modifier(albedo, normal);
}


PARAM_SAMPLER_2D(detail_map_overlay);
PARAM(float4, detail_map_overlay_xform);

void calc_albedo_two_detail_overlay_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc)
{
	float4	base=				sampleBiasGlobal2D(base_map,				transform_texcoord(texcoord, base_map_xform));
	float4	detail=				sampleBiasGlobal2D(detail_map,			transform_texcoord(texcoord, detail_map_xform));	
	float4	detail2=			sampleBiasGlobal2D(detail_map2,			transform_texcoord(texcoord, detail_map2_xform));
	float4	detail_overlay=		sampleBiasGlobal2D(detail_map_overlay,	transform_texcoord(texcoord, detail_map_overlay_xform));

	float4 detail_blend= (1.0f-base.w)*detail + base.w*detail2;
	
	albedo.xyz= base.xyz * (DETAIL_MULTIPLIER * DETAIL_MULTIPLIER) * detail_blend.xyz * detail_overlay.xyz;
	albedo.w= detail_blend.w * detail_overlay.w;

	apply_pc_albedo_modifier(albedo, normal);
}


void calc_albedo_two_detail_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc)
{
	float4	base=				sampleBiasGlobal2D(base_map,				transform_texcoord(texcoord, base_map_xform));
	float4	detail=				sampleBiasGlobal2D(detail_map,			transform_texcoord(texcoord, detail_map_xform));	
	float4	detail2=			sampleBiasGlobal2D(detail_map2,			transform_texcoord(texcoord, detail_map2_xform));
	
	albedo.xyz= base.xyz * (DETAIL_MULTIPLIER * DETAIL_MULTIPLIER) * detail.xyz * detail2.xyz;
	albedo.w= base.w * detail.w * detail2.w;

	apply_pc_albedo_modifier(albedo, normal);
}


PARAM_SAMPLER_2D(color_mask_map);
PARAM(float4, color_mask_map_xform);
PARAM(float4, neutral_gray);

void calc_albedo_color_mask_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc)
{
	float4	base=	sampleBiasGlobal2D(base_map,   transform_texcoord(texcoord, base_map_xform));
	float4	detail=	sampleBiasGlobal2D(detail_map, transform_texcoord(texcoord, detail_map_xform));
	float4  color_mask=	sampleBiasGlobal2D(color_mask_map,	transform_texcoord(texcoord, color_mask_map_xform));

	float4 tint_color=	((1.0f-color_mask.x) + color_mask.x * albedo_color.xyzw / float4(neutral_gray.xyz, 1.0f))		*		// ###ctchou $PERF do this divide in the pre-process
						((1.0f-color_mask.y) + color_mask.y * albedo_color2.xyzw / float4(neutral_gray.xyz, 1.0f))		*
						((1.0f-color_mask.z) + color_mask.z * albedo_color3.xyzw / float4(neutral_gray.xyz, 1.0f));

	albedo.rgb= base.rgb * (detail.rgb * DETAIL_MULTIPLIER) * tint_color.rgb;
	albedo.w= base.w * detail.w * tint_color.w;

	apply_pc_albedo_modifier(albedo, normal);
}

void calc_albedo_two_detail_black_point_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc)
{
	float4	base=				sampleBiasGlobal2D(base_map,				transform_texcoord(texcoord, base_map_xform));
	float4	detail=				sampleBiasGlobal2D(detail_map,			transform_texcoord(texcoord, detail_map_xform));	
	float4	detail2=			sampleBiasGlobal2D(detail_map2,			transform_texcoord(texcoord, detail_map2_xform));
	
	albedo.xyz= base.xyz * (DETAIL_MULTIPLIER * DETAIL_MULTIPLIER) * detail.xyz * detail2.xyz;
	albedo.w= apply_black_point(base.w, detail.w * detail2.w);

	apply_pc_albedo_modifier(albedo, normal);
}

PARAM_SAMPLER_CUBE(custom_cube);

void calc_albedo_custom_cube_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc)
{
	float4 base = sampleBiasGlobal2D(base_map,   transform_texcoord(texcoord, base_map_xform));
	float4 custom_color = sampleBiasGlobalCUBE(custom_cube, normal);

	albedo.rgb= base.rgb * custom_color.xyz;
	albedo.w= base.w * albedo_color.w;

	apply_pc_albedo_modifier(albedo, normal);
}

PARAM_SAMPLER_CUBE(blend_map);
PARAM(float4, albedo_second_color);

void calc_albedo_two_color_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc)
{
	float4 base = sampleBiasGlobal2D(base_map, transform_texcoord(texcoord, base_map_xform));

	float4 blend_factor = sampleBiasGlobalCUBE(blend_map, normal);

	float4 color = blend_factor.y * albedo_color * 2 + blend_factor.z * albedo_second_color * 2;

	albedo.rgb= base.rgb * color.xyz;
	albedo.w= base.w * color.w;

	apply_pc_albedo_modifier(albedo, normal);
}

PARAM(float3, chameleon_color0);
PARAM(float3, chameleon_color1);
PARAM(float3, chameleon_color2);
PARAM(float3, chameleon_color3);
PARAM(float, chameleon_color_offset1);
PARAM(float, chameleon_color_offset2);
PARAM(float, chameleon_fresnel_power);

float3 calc_chameleon(in float3 normal, in float3 view_dir)
{
	float dp = pow(max(dot(normal, view_dir), 0.0f), chameleon_fresnel_power);

	float3 col0 = chameleon_color0;
	float3 col1 = chameleon_color1;
	float lrp = dp * (1.0f / chameleon_color_offset1);

	if (dp > chameleon_color_offset1) {
		col0 = chameleon_color1;
		col1 = chameleon_color2;
		lrp = (dp - chameleon_color_offset1) * (1.0f / (chameleon_color_offset2 - chameleon_color_offset1));
	}
	if (dp > chameleon_color_offset2) {
		col0 = chameleon_color2;
		col1 = chameleon_color3;
		lrp = (dp - chameleon_color_offset2) * (1.0f / (1.0f - chameleon_color_offset2));
	}

	return lerp(col0, col1, lrp);
}

void calc_albedo_chameleon_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc,
	in float3 view_dir = float3(0.0f, 0.0f, 0.0f),
	in float2 vPos = float2(0.0f, 0.0f))
{
	float3 color = calc_chameleon(normal, view_dir);
	float4	base = sampleBiasGlobal2D(base_map, transform_texcoord(texcoord, base_map_xform));

	float4	detail = sampleBiasGlobal2D(detail_map, transform_texcoord(texcoord, detail_map_xform));
	albedo.rgb = base.rgb * (detail.rgb * DETAIL_MULTIPLIER) * color.rgb;
	albedo.w = base.w*detail.w;

	apply_pc_albedo_modifier(albedo, normal);
}

PARAM_SAMPLER_2D(chameleon_mask_map);
PARAM(float4, chameleon_mask_map_xform);

void calc_albedo_chameleon_masked_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc,
	in float3 view_dir = float3(0.0f, 0.0f, 0.0f),
	in float2 vPos = float2(0.0f, 0.0f))
{
	float4 base = sampleBiasGlobal2D(base_map, transform_texcoord(texcoord, base_map_xform));
	float mask = sampleBiasGlobal2D(chameleon_mask_map, transform_texcoord(texcoord, chameleon_mask_map_xform)).r;
	float3 color = lerp(1.0f, calc_chameleon(normal, view_dir), mask);
	float4 detail = sampleBiasGlobal2D(detail_map, transform_texcoord(texcoord, detail_map_xform));
	albedo.rgb = base.rgb * (detail.rgb * DETAIL_MULTIPLIER) * color.rgb;
	albedo.w = base.w*detail.w;

	apply_pc_albedo_modifier(albedo, normal);
}

PARAM_SAMPLER_2D(base_masked_map);
PARAM(float4, base_masked_map_xform);
PARAM(float4, albedo_masked_color);

void calc_albedo_chameleon_albedo_masked_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc,
	in float3 view_dir = float3(0.0f, 0.0f, 0.0f),
	in float2 vPos = float2(0.0f, 0.0f))
{
	float4 base = sampleBiasGlobal2D(base_map, transform_texcoord(texcoord, base_map_xform)) * albedo_color;
	float4 base_masked = sampleBiasGlobal2D(base_masked_map, transform_texcoord(texcoord, base_masked_map_xform)) * albedo_masked_color;
	float  mask = sampleBiasGlobal2D(chameleon_mask_map, transform_texcoord(texcoord, chameleon_mask_map_xform)).r;

	base_masked.rgb *= calc_chameleon(normal, view_dir);

	albedo = lerp(base, base_masked, mask);

	apply_pc_albedo_modifier(albedo, normal);
}

void calc_albedo_two_change_color_chameleon_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc,
	in float3 view_dir = float3(0.0f, 0.0f, 0.0f),
	in float2 vPos = float2(0.0f, 0.0f))
{
	float4 base = sampleBiasGlobal2D(base_map, transform_texcoord(texcoord, base_map_xform));
	float4 detail = sampleBiasGlobal2D(detail_map, transform_texcoord(texcoord, detail_map_xform));
	float4 change_color = sampleBiasGlobal2D(change_color_map, transform_texcoord(texcoord, change_color_map_xform));

	float3 cur_primary_change_color = primary_change_color.rgb;
	float3 cur_secondary_change_color = secondary_change_color.rgb;

	// chameleon
	float3 color = calc_chameleon(normal, view_dir);

	albedo.rgb = base.rgb * (detail.rgb * DETAIL_MULTIPLIER) * color.rgb;

	float3 cc = cur_primary_change_color.xyz*change_color.x + cur_secondary_change_color.xyz*change_color.y;
	cc = lerp(0.5f, min(cc, 1.0f), min(change_color.x + change_color.y, 1.0f));

	albedo.xyz = albedo.xyz < 0.5f ? (2.0f * albedo.xyz * cc)
		: 1.0f - (2.0f * (1.0f - albedo.xyz) * (1.0f - cc));

	albedo.w = base.w*detail.w;

	apply_pc_albedo_modifier(albedo, normal);
}

void calc_albedo_two_change_color_anim_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc,
	in float3 view_dir = float3(0.0f, 0.0f, 0.0f),
	in float2 vPos = float2(0.0f, 0.0f))
{
	float4 base = sampleBiasGlobal2D(base_map, transform_texcoord(texcoord, base_map_xform));
	float4 detail = sampleBiasGlobal2D(detail_map, transform_texcoord(texcoord, detail_map_xform));
	float4 change_color = sampleBiasGlobal2D(change_color_map, transform_texcoord(texcoord, change_color_map_xform));

	float3 cur_primary_change_color = primary_change_color.rgb;
	float3 cur_secondary_change_color = secondary_change_color.rgb;

	albedo.xyz = DETAIL_MULTIPLIER * base.xyz * detail.xyz;

	cur_primary_change_color *= albedo.xyz;
	cur_secondary_change_color *= albedo.xyz;

	albedo.xyz = lerp(albedo.xyz, cur_primary_change_color, change_color.x);
	albedo.xyz = lerp(albedo.xyz, cur_secondary_change_color, change_color.y);
	albedo.w = base.w*detail.w;

	apply_pc_albedo_modifier(albedo, normal);
}

PARAM_SAMPLER_CUBE(color_blend_mask_cubemap);
void calc_albedo_scrolling_cube_mask_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc)
{
	float4 base = sampleBiasGlobal2D(base_map, transform_texcoord(texcoord, base_map_xform));

	float4 blend_factor = sampleBiasGlobalCUBE(color_blend_mask_cubemap, misc.xyz);

	float4 color = blend_factor.y * albedo_color * 2 + blend_factor.z * albedo_second_color * 2;

	albedo.rgb = base.rgb * color.xyz;
	albedo.w = base.w * color.w;

	apply_pc_albedo_modifier(albedo, normal);
}

PARAM_SAMPLER_CUBE(color_cubemap);
void calc_albedo_scrolling_cube_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc)
{
	float4 base = sampleBiasGlobal2D(base_map, transform_texcoord(texcoord, base_map_xform));

	float4 color = sampleBiasGlobalCUBE(color_cubemap, misc.xyz);

	albedo.rgb = base.rgb * color.xyz;
	albedo.w = base.w * color.w;

	apply_pc_albedo_modifier(albedo, normal);
}

PARAM_SAMPLER_2D(color_texture);
PARAM(float, u_speed);
PARAM(float, v_speed);
void calc_albedo_scrolling_texture_uv_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc)
{
	float2 transformed_texcoord = transform_texcoord(texcoord, base_map_xform);
	float4 base = sampleBiasGlobal2D(base_map, transformed_texcoord);
	
	static float2 scrolling_speed = float2(u_speed, v_speed);
	float4 color = sampleBiasGlobal2D(color_texture, transformed_texcoord + ps_total_time * scrolling_speed);

	albedo.rgb = base.rgb * color.xyz;
	albedo.w = base.w * color.w;

	apply_pc_albedo_modifier(albedo, normal);
}

void calc_albedo_texture_from_misc_ps(
	in float2 texcoord,
	out float4 albedo,
	in float3 normal,
	in float4 misc)
{
	float2 transformed_texcoord = transform_texcoord(texcoord, base_map_xform);
	float4 base = sampleBiasGlobal2D(base_map, transformed_texcoord);
	
	float4 color = sampleBiasGlobal2D(color_texture, misc.xy);

	albedo.rgb = base.rgb * color.xyz;
	albedo.w = base.w * color.w;

	apply_pc_albedo_modifier(albedo, normal);
}
