#ifndef ShaderTypes_h
#define ShaderTypes_h

#include <simd/simd.h>

#define TRIANGLE_MASK_GEOMETRY 1
#define TRIANGLE_MASK_LIGHT    2

#define RAY_MASK_PRIMARY   3
#define RAY_MASK_SHADOW    1
#define RAY_MASK_SECONDARY 1

#define LIGHT_TYPE_AREA   0
#define LIGHT_TYPE_SPOT   1
#define LIGHT_TYPE_SUN    2

#define PI 3.14159265359

struct Camera {
    vector_float3 position;
    vector_float3 right;
    vector_float3 up;
    vector_float3 forward;
    float focalLength;
    float dofBlurStrength;
};

struct Light {
    unsigned int type;
    vector_float3 position;
    vector_float3 forward;
    vector_float3 right;
    vector_float3 up;
    vector_float3 color;
};

struct PSLight {
    struct Light light;
    float ambient;
    float diffuse;
    float specular;
    float brightness;
};

struct Uniforms
{
    unsigned int width;
    unsigned int height;
    unsigned int blocksWide;
    unsigned int frameIndex;
    unsigned int lightCount;
    unsigned int lightIndex;
    unsigned int qualityControll;
    float ambient;
    struct Camera camera;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 viewProjectionMatrix;
    vector_float2 jitter;
};

#ifdef __METAL_VERSION__
#define CONSTANT constant
#define vector2 float2
#else
#define CONSTANT static
#endif

CONSTANT vector_float2 haltonSamples[] = {
    {0.5f, 0.333333333333f},
    {0.25f, 0.666666666667f},
    {0.75f, 0.111111111111f},
    {0.125f, 0.444444444444f},
    {0.625f, 0.777777777778f},
    {0.375f, 0.222222222222f},
    {0.875f, 0.555555555556f},
    {0.0625f, 0.888888888889f},
    {0.5625f, 0.037037037037f},
    {0.3125f, 0.37037037037f},
    {0.8125f, 0.703703703704f},
    {0.1875f, 0.148148148148f},
    {0.6875f, 0.481481481481f},
    {0.4375f, 0.814814814815f},
    {0.9375f, 0.259259259259f},
    {0.03125f, 0.592592592593f},
};

#endif /* ShaderTypes_h */

