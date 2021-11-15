# Halo3-Shader-Source
The only change is the addition of shader.hlsl.

## How to compile shaders using this
These source files are needed to compile shaders using tool. Clone the repo into source\rasterizer (that makes source\rasterizer\hlsl) relative to your H3EK install, then apply num0005's shader compiler fixes from https://github.com/num0005/h3-shader-compiler-fix.

Use the compile-shaders verb with tool by supplying it with a .shader file path relative to your tags directory, without an extension.
Don't use tool_fast! It links the shader compiler library statically, ruining everything. Please go nag num about it.
