
PARAM(float, height_scale);
PARAM_SAMPLER_2D(height_map);
PARAM(float4, height_map_xform);


void calc_parallax_off_ps(
	in float2 texcoord,
	in float3x3 tangent_frame,
	in float3 view_dir_world_space,
	in float3 view_dir,					// direction towards camera
	out float2 parallax_texcoord)
{
	parallax_texcoord= texcoord;
}

void calc_parallax_simple_ps(
	in float2 texcoord,
	in float3x3 tangent_frame,
	in float3 view_dir_world_space,
	in float3 view_dir,					// direction towards camera
	out float2 parallax_texcoord)
{
	texcoord= transform_texcoord(texcoord, height_map_xform);
	float height= (sample2D(height_map, texcoord).g - 0.5f) * height_scale;		// ###ctchou $PERF can switch height maps to be signed and get rid of this -0.5 bias
	parallax_texcoord= texcoord + height * view_dir.xy;

	parallax_texcoord= (parallax_texcoord - height_map_xform.zw) / height_map_xform.xy;
}

void calc_parallax_two_sample_ps(
	in float2 texcoord,
	in float3x3 tangent_frame,
	in float3 view_dir_world_space,
	in float3 view_dir,					// direction towards camera
	out float2 parallax_texcoord)
{
	float height= 0.0f;
	
	texcoord= transform_texcoord(texcoord, height_map_xform);
	float height_difference= (sample2D(height_map, texcoord).g - 0.5f) * height_scale - height;
	parallax_texcoord= texcoord + height_difference * view_dir.xy;
	height= height + height_difference * view_dir.z;
	
	height_difference= (sample2D(height_map, parallax_texcoord).g - 0.5f) * height_scale - height;
	parallax_texcoord= parallax_texcoord + height_difference * view_dir.xy;
	
	/// height= height + height_difference * view_dir.z;
	parallax_texcoord= (parallax_texcoord - height_map_xform.zw) / height_map_xform.xy;
}

void calc_parallax_interpolated_ps(
	in float2 texcoord,
	in float3x3 tangent_frame,
	in float3 view_dir_world_space,
	in float3 view_dir,					// direction towards camera
	out float2 parallax_texcoord)
{
	texcoord= transform_texcoord(texcoord, height_map_xform);
	float cur_height= 0.0f;

	float height_1= (sample2D(height_map, texcoord).g - 0.5f) * height_scale;	
	float height_difference= height_1 - cur_height;
	float2 step_offset= height_difference * view_dir.xy;
	
	parallax_texcoord= texcoord + step_offset;
	cur_height= height_difference * view_dir.z;
	
	float height_2= (sample2D(height_map, parallax_texcoord).g - 0.5f) * height_scale;
	
	height_difference= height_2 - cur_height;
	if (sign(height_difference) != sign(height_1 - cur_height))
	{
		float pct= height_1 / (cur_height - height_2 + height_1);
		parallax_texcoord= texcoord + pct * step_offset;
	}
	else
	{
		parallax_texcoord= parallax_texcoord + height_difference * view_dir.xy;		// view_dir.xy
//		float height_2= height_1 + height_difference * view_dir.z;
	}

	parallax_texcoord= (parallax_texcoord - height_map_xform.zw) / height_map_xform.xy;
}

PARAM(int, height_linear_steps);
PARAM(int, height_binary_steps);
PARAM(bool, height_sample_halo3);

PARAM_SAMPLER_2D(height_scale_map);
PARAM(float4, height_scale_map_xform);

float gib_relief_sample(
	in texture_sampler_2d height_sampler,
	in float2 texcoord)
{
	if (height_sample_halo3)
		return min(sample2D(height_sampler, texcoord).g, 0.5) * 2;
	else
		return sample2D(height_sampler, texcoord).g;
}

float sample_relief(
	in float2 texcoord)
{
	return gib_relief_sample(height_map, transform_texcoord(texcoord, height_map_xform)) * gib_relief_sample(height_scale_map, transform_texcoord(texcoord, height_scale_map_xform));
}

void calc_parallax_relief_ps(
	in float2 texcoord,
	in float3x3 tangent_frame,
	in float3 view_dir_world_space,
	in float3 view_dir,					// direction towards camera
	out float2 parallax_texcoord)
{
	float glancing_scale= dot(view_dir_world_space, tangent_frame[2]);
	float2 ds= -view_dir.xy * (height_scale * glancing_scale) / view_dir.z;

	float size= 1.0 / height_linear_steps;
	float depth= 1.0;
	float best_depth= 1.0;
	
	for (int steps = 0; steps < height_linear_steps - 1; steps++)
	{
		depth -= size;
		if (depth >= 1.0 - sample_relief(texcoord + ds * depth))
			best_depth = depth;
	}
	depth = best_depth - size;
	for (int steps = 0; steps < height_binary_steps; steps++)
	{
		size *= 0.5;
		if (depth >= 1.0 - sample_relief(texcoord + ds * depth))
		{
			best_depth = depth;
			depth -= 2 * size;
		}
		depth += size;
	}

	parallax_texcoord= transform_texcoord(texcoord, height_map_xform) + best_depth * ds;
	parallax_texcoord= (parallax_texcoord - height_map_xform.zw) / height_map_xform.xy;
}

void calc_parallax_simple_detail_ps(
	in float2 texcoord,
	in float3x3 tangent_frame,
	in float3 view_dir_world_space,
	in float3 view_dir,					// direction towards camera
	out float2 parallax_texcoord)
{
	parallax_texcoord= transform_texcoord(texcoord, height_map_xform);
	float height= (sample2D(height_map, parallax_texcoord).g - 0.5f) * sample2D(height_scale_map, transform_texcoord(texcoord, height_scale_map_xform)).g * height_scale;
	parallax_texcoord= parallax_texcoord + height * view_dir.xy;

	parallax_texcoord= (parallax_texcoord - height_map_xform.zw) / height_map_xform.xy;
}

PARAM(int, interior_map_rows);
PARAM(int, interior_map_cols);

void calc_parallax_interior_mapping_ps(
	in float2 texcoord,
	in float3x3 tangent_frame,
	in float3 view_dir_world_space,
	in float3 view_dir,					// direction towards camera
	out float2 parallax_texcoord)
{
	// sorry nothing
	parallax_texcoord= texcoord;
}
