#ifdef TEST_CATEGORY_OPTION

	#define BLEND_MODE(mode) TEST_CATEGORY_OPTION(blend_mode, mode)

#else

	#define BLEND_TYPE(blend_type) BLEND_TYPE_##blend_type
	#define BLEND_TYPE_opaque 0
	#define BLEND_TYPE_additive 1
	#define BLEND_TYPE_multiply 2
	#define BLEND_TYPE_alpha_blend 3
	#define BLEND_TYPE_double_multiply 4
	#define BLEND_TYPE_pre_multiplied_alpha 5

	#define BLEND_MODE(mode) BLEND_TYPE(blend_type) == BLEND_TYPE_##mode

#endif

//default
#define CONVERT_TO_RENDER_TARGET_FOR_BLEND convert_to_render_target

#if BLEND_MODE(opaque)
#undef CONVERT_TO_RENDER_TARGET_FOR_BLEND
#define CONVERT_TO_RENDER_TARGET_FOR_BLEND convert_to_render_target
#define ALPHA_CHANNEL_OUTPUT output_alpha
#define BLEND_FOG_INSCATTER_SCALE 1.0
#endif

#if BLEND_MODE(additive)
#undef CONVERT_TO_RENDER_TARGET_FOR_BLEND
#define CONVERT_TO_RENDER_TARGET_FOR_BLEND convert_to_render_target
#define ALPHA_CHANNEL_OUTPUT 0.0
#define BLEND_FOG_INSCATTER_SCALE 0.0
#define NO_ALPHA_TO_COVERAGE
#endif

#if BLEND_MODE(multiply)
#undef CONVERT_TO_RENDER_TARGET_FOR_BLEND
#define CONVERT_TO_RENDER_TARGET_FOR_BLEND convert_to_render_target_multiplicative
#define BLEND_MULTIPLICATIVE 1.0
#define ALPHA_CHANNEL_OUTPUT 1.0
#define NO_ALPHA_TO_COVERAGE
#endif

#if BLEND_MODE(alpha_blend)
#undef CONVERT_TO_RENDER_TARGET_FOR_BLEND
#define CONVERT_TO_RENDER_TARGET_FOR_BLEND convert_to_render_target
#define ALPHA_CHANNEL_OUTPUT albedo.w
#define BLEND_FOG_INSCATTER_SCALE 1.0
#define NO_ALPHA_TO_COVERAGE
#endif

#if BLEND_MODE(double_multiply)
#undef CONVERT_TO_RENDER_TARGET_FOR_BLEND
#define CONVERT_TO_RENDER_TARGET_FOR_BLEND convert_to_render_target_multiplicative
#define BLEND_MULTIPLICATIVE 2.0
#define ALPHA_CHANNEL_OUTPUT 1.0
#define NO_ALPHA_TO_COVERAGE
#endif

#if BLEND_MODE(pre_multiplied_alpha)
#undef CONVERT_TO_RENDER_TARGET_FOR_BLEND
#define CONVERT_TO_RENDER_TARGET_FOR_BLEND convert_to_render_target_premultiplied_alpha
#define ALPHA_CHANNEL_OUTPUT albedo.w
#define BLEND_FOG_INSCATTER_SCALE 1.0
#define NO_ALPHA_TO_COVERAGE
#endif

