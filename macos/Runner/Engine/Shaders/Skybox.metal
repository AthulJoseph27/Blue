#import "Runner-Bridging-Header.h"

#include <metal_stdlib>
using namespace metal;

class Skybox {
public:
    static float3 nightSky(float3 ray, uint2 r) {
        float3 color1 = float3(0);
        float3 color2 = float3(0.002824, 0.002039, 0.008314);
        
        return mix(color1, color2, length(getUVCoordinate(ray)));
    }
    static float3 nightSkyWithAurora(float3 ray) {
        return float3(0);
    }
private:
    static float2 getUVCoordinate(float3 ray) {
        float3 u = normalize(ray);
        
        return float2(0.5 + atan2(u.z, u.x) / (2.0 * PI), 0.5 - asin(u.y) / PI);
    }
};

