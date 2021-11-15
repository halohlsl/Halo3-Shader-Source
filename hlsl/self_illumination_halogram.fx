
PARAM(float, layer_depth);
PARAM(float, layer_contrast);
PARAM(float, texcoord_aspect_ratio);			// how stretched your texcoords are

PARAM(float, depth_darken);

#if DX_VERSION == 9
PARAM(int, layers_of_4);
#elif DX_VERSION == 11
PARAM(float, layers_of_4);
#endif

float3 calc_self_illumination_multilayer_ps(
	in float2 texcoord,
	inout float3 albedo_times_light,
	float3 view_dir)
{
	texcoord= transform_texcoord(texcoord, self_illum_map_xform);				// transform texcoord first
	
//	texcoord -= view_dir.xy * (layer_depth / 2.0f);
	float2 offset= view_dir.xy * self_illum_map_xform.xy * float2(texcoord_aspect_ratio, 1.0f) * layer_depth / (layers_of_4 * 4);
	
	float4 accum= float4(0.0f, 0.0f, 0.0f, 0.0f);
#ifndef pc
//	[unroll]
#endif
	float depth_intensity= 1.0f;
	for (int x= 0; x < layers_of_4; x++)
	{
		accum += depth_intensity * sample2D(self_illum_map, texcoord);
		texcoord -= offset;	depth_intensity *= depth_darken;
		accum += depth_intensity * sample2D(self_illum_map, texcoord);
		texcoord -= offset;	depth_intensity *= depth_darken;
		accum += depth_intensity * sample2D(self_illum_map, texcoord);
		texcoord -= offset;	depth_intensity *= depth_darken;
		accum += depth_intensity * sample2D(self_illum_map, texcoord);
		texcoord -= offset;	depth_intensity *= depth_darken;
	}
	
	accum.rgba /= (layers_of_4 * 4);
	
	float4 result;
	result.rgb= pow(accum.rgb, layer_contrast) * self_illum_color * self_illum_intensity;
	result.a= accum.a * self_illum_color.a;
	return result.rgb;
}


PARAM_SAMPLER_2D(illum_depth_map);
PARAM(float4, illum_depth_map_xform);


float3 calc_self_illumination_multilayer_depth_ps(
	in float2 texcoord,
	inout float3 albedo_times_light,
	float3 view_dir)
{
	float4 tex_depth= sample2D(illum_depth_map, transform_texcoord(texcoord, illum_depth_map_xform));

	texcoord= transform_texcoord(texcoord, self_illum_map_xform);				// transform texcoord first
	
//	texcoord -= view_dir.xy * (layer_depth / 2.0f);
	float2 offset= view_dir.xy * self_illum_map_xform.xy * float2(texcoord_aspect_ratio, 1.0f) * layer_depth / (layers_of_4 * 4);
	
	float4 accum= float4(0.0f, 0.0f, 0.0f, 0.0f);
#ifndef pc
//	[unroll]
#endif
	for (int x= 0; x < layers_of_4; x++)
	{
		accum += sample2D(self_illum_map, texcoord);
		texcoord -= offset;
		accum += sample2D(self_illum_map, texcoord);
		texcoord -= offset;
		accum += sample2D(self_illum_map, texcoord);
		texcoord -= offset;
		accum += sample2D(self_illum_map, texcoord);
		texcoord -= offset;
	}
	
	accum.rgba /= (layers_of_4 * 4);
	
	float4 result;
	result.rgb= pow(accum.rgb, layer_contrast) * self_illum_color.rgb * self_illum_intensity;
	result.a= accum.a * self_illum_color.a;
	return result.rgb;
}




float3 calc_self_illumination_multilayer_cheap_ps(
	in float2 texcoord,
	inout float3 albedo_times_light,
	float3 view_dir)
{
	texcoord= transform_texcoord(texcoord, self_illum_map_xform);				// transform texcoord first
	
	float2 offset= view_dir.xy * self_illum_map_xform.xy * float2(texcoord_aspect_ratio, 1.0f) * layer_depth / (layers_of_4 * 4);
	
	float4 accum= float4(0.0f, 0.0f, 0.0f, 0.0f);
#ifdef pc
	accum += sample2D(self_illum_map, texcoord);
#else // XENON

	float4 delta_h=	{offset.x, offset.y, 0.0f, 0.0f};
	float4 delta_v= {0.0f, 0.0f, 0.0f, 0.0f};

	float4 value= 0.0f;
	asm {
		setGradientH delta_h
		setGradientV delta_v
		tfetch2D value, texcoord, self_illum_map, MinFilter=point, MagFilter=point, MipFilter=point, AnisoFilter=max16to1, UseRegisterGradients=true, UseComputedLOD=false
	};

	accum += value;

#endif
	
	accum.rgba /= (layers_of_4 * 4);
	
	float4 result;
	result.rgb= pow(accum.rgb, layer_contrast) * self_illum_color.rgb * self_illum_intensity;
	result.a= accum.a * self_illum_color.a;
	return result.rgb;
}


PARAM(float3, self_illum_heat_color);

float3 calc_self_illumination_scope_blur_ps(
	in float2 texcoord,
	inout float3 albedo,
	in float3 view_dir)
{
	texcoord= transform_texcoord(texcoord, self_illum_map_xform);
	float4 color_0, color_1, color_2, color_3;
	
#ifdef pc
	float2 texStep= float2(0.001736 / 2.0, 0.003125 / 2.0);
 	color_0= sample2D(self_illum_map, float2(texcoord.x + texStep.x, texcoord.y + texStep.y));
	color_1= sample2D(self_illum_map, float2(texcoord.x - texStep.x, texcoord.y + texStep.y));
	color_2= sample2D(self_illum_map, float2(texcoord.x - texStep.x, texcoord.y - texStep.y));
	color_3= sample2D(self_illum_map, float2(texcoord.x + texStep.x, texcoord.y - texStep.y));
#else
 
	asm
	{
		tfetch2D color_0, texcoord, self_illum_map, OffsetX=  0.5f, OffsetY=  0.5f
		tfetch2D color_1, texcoord, self_illum_map, OffsetX= -0.5f, OffsetY=  0.5f
		tfetch2D color_2, texcoord, self_illum_map, OffsetX= -0.5f, OffsetY= -0.5f
		tfetch2D color_3, texcoord, self_illum_map, OffsetX=  0.5f, OffsetY= -0.5f
	};
#endif
	float2 average= (color_0 + color_1 + color_2 + color_3).xy * 0.25f;
	float3 color= average.r * self_illum_color.rgb + (1.0f - average.r) * average.g * self_illum_heat_color;
	return (color * self_illum_intensity);
}
