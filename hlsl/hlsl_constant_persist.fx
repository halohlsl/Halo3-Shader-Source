#ifndef _HLSL_CONSTANT_PERSIST_FX_
#ifndef DEFINE_CPP_CONSTANTS
#define _HLSL_CONSTANT_PERSIST_FX_
#endif

//NOTE: if you modify any of this, than you need to modify hlsl_constant_persist.h 

#if defined(pc) || defined(PC)
#define k_maximum_simple_light_count			8
#else
#define k_maximum_simple_light_count			16
#endif

#ifndef DEFINE_CPP_CONSTANTS
#define always_true true
#endif

CBUFFER_BEGIN(ViewVS)
	CBUFFER_CONST(ViewVS, 		float4x4,	View_Projection,			k_viewproj_xform)
	CBUFFER_CONST(ViewVS,		float4x4,	View,						k_view_xform)
	CBUFFER_CONST(ViewVS,		float4x2,	Screen,						k_screen_xform)
	CBUFFER_CONST(ViewVS,		float4,		v_clip_plane,				k_clip_plane)
	CBUFFER_CONST(ViewVS,		float,		vs_total_time,				k_vs_total_time)
	CBUFFER_CONST(ViewVS,		float3,		vs_total_time_pad,			k_vs_total_time_pad)
	CBUFFER_CONST(ViewVS,		bool,		v_always_true,				k_vs_always_true)
CBUFFER_END	
	
SHADER_CONST_ALIAS(ViewVS,		float4,		View_Projection_X,			View_Projection._m00_m10_m20_m30,	k_viewproj_xform_x,		k_viewproj_xform, 	0)
SHADER_CONST_ALIAS(ViewVS,		float4,		View_Projection_Y,			View_Projection._m01_m11_m21_m31,	k_viewproj_xform_y,		k_viewproj_xform, 	16)
SHADER_CONST_ALIAS(ViewVS,		float4,		View_Projection_Z,			View_Projection._m02_m12_m22_m32,	k_viewproj_xform_z,		k_viewproj_xform, 	32)
SHADER_CONST_ALIAS(ViewVS,		float4,		View_Projection_W,			View_Projection._m03_m13_m23_m33,	k_viewproj_xform_w,		k_viewproj_xform, 	48)
			
SHADER_CONST_ALIAS(ViewVS,		float3,		Camera_Forward,				View._m00_m10_m20,					k_camera_forward,		k_view_xform,		0)
SHADER_CONST_ALIAS(ViewVS,		float3,		Camera_Left,				View._m01_m11_m21,					k_camera_left,			k_view_xform,		16)
SHADER_CONST_ALIAS(ViewVS,		float3,		Camera_Up,					View._m02_m12_m22,					k_camera_up,			k_view_xform,		32)
SHADER_CONST_ALIAS(ViewVS,		float3,		Camera_Position,			View._m03_m13_m23,					k_camera_position,		k_view_xform,		48)
			
SHADER_CONST_ALIAS(ViewVS,		float4,		Screen_X,					Screen._m00_m10_m20_m30,			k_screen_xform_x,		k_screen_xform,		0)
SHADER_CONST_ALIAS(ViewVS,		float4,		Screen_Y,					Screen._m01_m11_m21_m31,			k_screen_xform_y,		k_screen_xform,		16)
	
CBUFFER_BEGIN(ExposureVS)	
	CBUFFER_CONST(ExposureVS,	float4,		v_exposure,					k_vs_exposure)
	CBUFFER_CONST(ExposureVS,	float4,		v_alt_exposure,				k_vs_alt_exposure)
CBUFFER_END

CBUFFER_BEGIN(AtmosphereVS)
	CBUFFER_CONST(AtmosphereVS,	float4,		v_atmosphere_constant_0,		k_vs_atmosphere_constant_0)
	CBUFFER_CONST(AtmosphereVS,	float4,		v_atmosphere_constant_1,		k_vs_atmosphere_constant_1)
	CBUFFER_CONST(AtmosphereVS,	float4,		v_atmosphere_constant_2,		k_vs_atmosphere_constant_2)
	CBUFFER_CONST(AtmosphereVS,	float4,		v_atmosphere_constant_3,		k_vs_atmosphere_constant_3)
	CBUFFER_CONST(AtmosphereVS,	float4,		v_atmosphere_constant_4,		k_vs_atmosphere_constant_4)
	CBUFFER_CONST(AtmosphereVS,	float4,		v_atmosphere_constant_5,		k_vs_atmosphere_constant_5)
	CBUFFER_CONST(AtmosphereVS,	float4,		v_atmosphere_constant_extra,	k_vs_atmosphere_constant_extra)
CBUFFER_END

CBUFFER_BEGIN(LightingVS)
	CBUFFER_CONST(LightingVS,	float4,		v_lighting_constant_0,			k_vs_lighting_constant_0)
	CBUFFER_CONST(LightingVS,	float4,		v_lighting_constant_1,			k_vs_lighting_constant_1)
	CBUFFER_CONST(LightingVS,	float4,		v_lighting_constant_2,			k_vs_lighting_constant_2)
	CBUFFER_CONST(LightingVS,	float4,		v_lighting_constant_3,			k_vs_lighting_constant_3)
	CBUFFER_CONST(LightingVS,	float4,		v_lighting_constant_4,			k_vs_lighting_constant_4)
	CBUFFER_CONST(LightingVS,	float4,		v_lighting_constant_5,			k_vs_lighting_constant_5)
	CBUFFER_CONST(LightingVS,	float4,		v_lighting_constant_6,			k_vs_lighting_constant_6)
	CBUFFER_CONST(LightingVS,	float4,		v_lighting_constant_7,			k_vs_lighting_constant_7)
	CBUFFER_CONST(LightingVS,	float4,		v_lighting_constant_8,			k_vs_lighting_constant_8)
	CBUFFER_CONST(LightingVS,	float4,		v_lighting_constant_9,			k_vs_lighting_constant_9)
CBUFFER_END

CBUFFER_BEGIN(DynamicLightClipVS)
	CBUFFER_CONST_ARRAY(DynamicLightClipVS,		float4,		v_dynamic_light_clip_plane, [6],	k_vs_dynamic_light_clip_planes)
CBUFFER_END

CBUFFER_BEGIN(ShadowProjVS)
	CBUFFER_CONST(ShadowProjVS,	float4x4,	Shadow_Projection,				k_vs_shadow_projection)
CBUFFER_END

CBUFFER_BEGIN(ViewPS)
   CBUFFER_CONST(ViewPS,		float3, 	Camera_Position_PS, 			k_register_camera_position_ps)
CBUFFER_END

CBUFFER_BEGIN(ExposurePS)
	CBUFFER_CONST(ExposurePS,	float4,		g_exposure,						k_ps_exposure)
	CBUFFER_CONST(ExposurePS,	float4,		g_alt_exposure,					k_ps_alt_exposure)
CBUFFER_END

CBUFFER_BEGIN(LightingPS)
	CBUFFER_CONST(LightingPS,	float4,		p_lighting_constant_0,			k_ps_lighting_constant_0)
	CBUFFER_CONST(LightingPS,	float4,		p_lighting_constant_1,			k_ps_lighting_constant_1)
	CBUFFER_CONST(LightingPS,	float4,		p_lighting_constant_2,			k_ps_lighting_constant_2)
	CBUFFER_CONST(LightingPS,	float4,		p_lighting_constant_3,			k_ps_lighting_constant_3)
	CBUFFER_CONST(LightingPS,	float4,		p_lighting_constant_4,			k_ps_lighting_constant_4)
	CBUFFER_CONST(LightingPS,	float4,		p_lighting_constant_5,			k_ps_lighting_constant_5)
	CBUFFER_CONST(LightingPS,	float4,		p_lighting_constant_6,			k_ps_lighting_constant_6)
	CBUFFER_CONST(LightingPS,	float4,		p_lighting_constant_7,			k_ps_lighting_constant_7)
	CBUFFER_CONST(LightingPS,	float4,		p_lighting_constant_8,			k_ps_lighting_constant_8)
	CBUFFER_CONST(LightingPS,	float4,		p_lighting_constant_9,			k_ps_lighting_constant_9)
CBUFFER_END

SHADER_CONST_ALIAS(LightingPS,	float4,		p_dynamic_light_gel_xform,		p_lighting_constant_4,			k_ps_dynamic_light_gel_xform,	k_ps_lighting_constant_0,	0)

CBUFFER_BEGIN(MiscPS)
	CBUFFER_CONST(MiscPS,		float2,		texture_size,							k_ps_texture_size)
	CBUFFER_CONST(MiscPS,		float2,		texture_size_pad,						k_ps_texture_size_pad)
	CBUFFER_CONST(MiscPS,		float4,		dynamic_environment_blend,				k_ps_dynamic_environment_blend)
	CBUFFER_CONST(MiscPS,		float4,		p_render_debug_mode,					k_ps_render_debug_mode)
	CBUFFER_CONST(MiscPS,		float,		p_shader_pc_specular_enabled,			k_shader_pc_specular_enabled)
	CBUFFER_CONST(MiscPS,		float3,		p_shader_pc_specular_enabled_pad,		k_shader_pc_specular_enabled_pad)
	CBUFFER_CONST(MiscPS,		float,		p_shader_pc_albedo_lighting,			k_shader_pc_albedo_lighting)
	CBUFFER_CONST(MiscPS,		float3,		p_shader_pc_albedo_lighting_pad,		k_shader_pc_albedo_lighting_pad)
	CBUFFER_CONST(MiscPS,		bool,		LDR_gamma2,								k_ps_ldr_gamma2)
	CBUFFER_CONST(MiscPS,		bool,		HDR_gamma2,								k_ps_hdr_gamma2)
	CBUFFER_CONST(MiscPS,		bool,	 	actually_calc_albedo,					k_ps_actually_calc_albedo)
	CBUFFER_CONST(MiscPS,		bool,		p_lightmap_compress_constant_using_dxt,	k_ps_lightmap_compress_constant_using_dxt)
	CBUFFER_CONST(MiscPS,		float,		ps_total_time,							k_ps_total_time)
	CBUFFER_CONST(MiscPS,		float3,		ps_total_time_pad,						k_ps_total_time_pad)
CBUFFER_END

CBUFFER_BEGIN(LightmapCompressPS)
	CBUFFER_CONST(LightmapCompressPS,	float4,		p_lightmap_compress_constant_0,		k_ps_lightmap_compress_constant_0)
	CBUFFER_CONST(LightmapCompressPS,	float4,		p_lightmap_compress_constant_1,		k_ps_lightmap_compress_constant_1)
	CBUFFER_CONST(LightmapCompressPS,	float4,		p_lightmap_compress_constant_2,		k_ps_lightmap_compress_constant_2)
CBUFFER_END

CBUFFER_BEGIN(SimpleLightsPS)
	CBUFFER_CONST(SimpleLightsPS,		float,		simple_light_count,									k_register_simple_light_count)
	CBUFFER_CONST(SimpleLightsPS,		float3,		simple_light_count_pad,								k_register_simple_light_count_pad)
	CBUFFER_CONST_ARRAY(SimpleLightsPS,	float4,		simple_lights, [k_maximum_simple_light_count][5],	k_register_simple_light_start)
CBUFFER_END

#define dynamic_lights_use_array_notation 1

VERTEX_TEXTURE_AND_SAMPLER(_2D,			sampler_atmosphere_neta_table,	k_vs_sampler_atmosphere_neta_table,		0)
#ifndef COMPUTE_SHADER
VERTEX_TEXTURE_AND_SAMPLER(_2D,			sampler_weather_occlusion,		k_vs_sampler_weather_occlusion,			1)
#endif

PIXEL_TEXTURE_AND_SAMPLER(_2D_ARRAY,	lightprobe_texture_array,		k_sampler_lightprobe_texture_array,		13)
PIXEL_TEXTURE_AND_SAMPLER(_2D_ARRAY,	dominant_light_intensity_map,	k_sampler_dominant_light_intensity_map,	14)

PIXEL_TEXTURE_AND_SAMPLER_IN_VIEWPORT_ALWAYS(_2D_VIEWPORT,	scene_ldr_texture,				k_sampler_scene_ldr_texture,			15)

PIXEL_TEXTURE(_2D,		albedo_texture,					k_sampler_albedo_texture,				16)
PIXEL_TEXTURE(_2D,		normal_texture,					k_sampler_normal_texture,				17)
PIXEL_TEXTURE(_2D,		depth_buffer,					k_sampler_depth_buffer,					18)


#define V_ILLUM_SCALE (v_alt_exposure.r)
#define V_ILLUM_EXPOSURE (v_alt_exposure.g)
#define ILLUM_SCALE (g_alt_exposure.r)
#define ILLUM_EXPOSURE (g_alt_exposure.g)

#endif //ifndef _HLSL_CONSTANT_PERSIST_FX_

