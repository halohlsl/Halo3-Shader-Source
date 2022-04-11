#line 1 "source\rasterizer\hlsl\displacement.hlsl"

#include "global.fx"
#include "hlsl_constant_mapping.fx"
#include "hlsl_vertex_types.fx"
#include "utilities.fx"

#define DISTORTION_MULTISAMPLED 1
#define LDR_ONLY 1

#define LDR_ALPHA_ADJUST g_exposure.w
#define HDR_ALPHA_ADJUST g_exposure.b
#define DARK_COLOR_MULTIPLIER g_exposure.g
#include "render_target.fx"

#include "displacement_registers.fx"

//@generate screen
LOCAL_SAMPLER_2D(displacement_sampler, 0);
LOCAL_SAMPLER_2D_IN_VIEWPORT_ALLWAYS(ldr_buffer, 1);
#ifndef LDR_ONLY
LOCAL_SAMPLER_2D_IN_VIEWPORT_ALLWAYS(hdr_buffer, 2);
#endif

struct displacement_output
{
	float4 HPosition	:SV_Position;
	float2 Texcoord		:TEXCOORD0;
};

displacement_output default_vs(vertex_type IN)
{
    displacement_output OUT;

    OUT.HPosition.xy= IN.position;
    OUT.HPosition.zw= 1.0f;
	OUT.Texcoord= IN.texcoord;
	
    return OUT;
}

accum_pixel default_ps(displacement_output IN, SCREEN_POSITION_INPUT(screen_coords)) : SV_Target0
{
	// This is the exact 0 displacement for 16-bit.  Need to get it exact for the "clip" to work.
	static float distortion_offset= 0x80/(float)0xff;
	static float max_displacement= 1.0f;	// if used, keep in sync with particle_render.hlsl
#ifdef DISTORTION_MULTISAMPLED
	// Displacement is accumulated in pixel unit on 1/4-size buffer, applied on full-size buffer.
	float2 displacement= 0.5f * 2.0f * max_displacement * ps_displacement_screen_constants.zw * (sample2D(displacement_sampler, IN.Texcoord).xy - distortion_offset);		// ps_displacement_screen_constants.zw is distortion scale in x and y directions
#else
	float2 displacement= 2.0f * max_displacement * ps_displacement_screen_constants.zw * (sample2D(displacement_sampler, IN.Texcoord).xy - distortips_displacement_screen_constantsscreen_constants.zw is distortion scale in x and y directions
#endif
	float change= dot(displacement, displacement);
	clip(change> 0.0f ? 1.0f : -1.0f);	// save the texture fetches and the frame buffer write
	accum_pixel displaced_pixel;
	float2 frame_texcoords= IN.Texcoord + displacement;
	displaced_pixel.color= sample2D(ldr_buffer, frame_texcoords);
#ifndef LDR_ONLY
	displaced_pixel.dark_color= sample2D(hdr_buffer, frame_texcoords);
#endif
	return displaced_pixel;
}
