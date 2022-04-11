#ifndef _GLOBAL_TEXTURE_FX_
#define _GLOBAL_TEXTURE_FX_

// Texture sampling and struct functions so that texture/sampler pairs can be treated the same for D3D9 and D3D11

struct texture_sampler_2d
{
	sampler s;
	texture2D t;
};

struct texture_sampler_2d_half
{
	sampler s;
	texture2D<min16float4> t;
};


struct texture_sampler_comparison_2d 
{
	SamplerComparisonState s;
	texture2D t;
};

struct texture_sampler_3d
{
	sampler s;
	texture3D t;
};

struct texture_sampler_cube
{
	sampler s;
	TextureCube t;
};

struct texture_sampler_2d_array
{
	sampler s;
	Texture2DArray t;
};

struct viewport_texture_sampler_2d
{
	sampler s;
	texture2D t;
	bool with_viewport;
};

struct viewport_texture_sampler_comparison_2d
{
	SamplerComparisonState s;
	texture2D t;
	bool with_viewport;
};


#endif
