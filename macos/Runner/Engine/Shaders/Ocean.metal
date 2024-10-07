#include <metal_stdlib>
using namespace metal;

class Ocean {
public:
    static float3 sampleColor(float3 position) {
        const float e = 2.71828;
        
        float3 base = float3(0, 0.5, 0);
        
        float3 color1 = float3(0.0118, 0.4784, 0.8706);
        float3 color2 = float3(0.0118, 0.8980, 0.4760);
        
        float distance = length((position - base));
//        distance /= maxDistance;
        float x = distance;
        
        x = 1 - (pow(x + e, e)/pow(e, 4*x+e));
        
        return mix(color1, color2, x);
    }
};
