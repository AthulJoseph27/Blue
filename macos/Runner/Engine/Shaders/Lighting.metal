#include <metal_stdlib>
#import "Runner-Bridging-Header.h"

using namespace metal;

class Lighting {
public:
    static void sampleLight(thread Light & light,
                            float2 u,
                            float3 position,
                            thread float3 & lightDirection,
                            thread float3 & lightColor,
                            thread float & lightDistance) {
        switch (light.type) {
            case LIGHT_TYPE_AREA:
                sampleAreaLight(light, u, position, lightDirection, lightColor, lightDistance);
                break;
            case LIGHT_TYPE_SPOT:
                sampleSpotLight(light, u, position, lightDirection, lightColor, lightDistance);
                break;
            case LIGHT_TYPE_SUN:
                sampleSunLight(light, u, position, lightDirection, lightColor, lightDistance);
                break;
            default:
                break;
        }
    }
    
private:
    static void sampleAreaLight(thread Light & light,
                                  float2 u,
                                  float3 position,
                                  thread float3 & lightDirection,
                                  thread float3 & lightColor,
                                  thread float & lightDistance) {
        u = u * 2.0f - 1.0f;

        float3 samplePosition = light.position +
                                light.right * u.x +
                                light.up * u.y;

        lightDirection = samplePosition - position;

        lightDistance = length(lightDirection);

        float inverseLightDistance = 1.0f / max(lightDistance, 1e-3f);

        lightDirection *= inverseLightDistance;
        lightColor = light.color;
        lightColor *= (inverseLightDistance * inverseLightDistance);
        lightColor *= saturate(dot(-lightDirection, light.forward));
    }
    
    static void sampleSpotLight(thread Light & light,
                                 float2 u,
                                 float3 position,
                                 thread float3 & lightDirection,
                                 thread float3 & lightColor,
                                 thread float & lightDistance) {
        
        u = u * 2.0f - 1.0f;
        
        lightDirection = light.position - position;
        lightDistance = length(lightDirection);
        
        float inverseLightDistance = 1.0f / max(lightDistance, 1e-3f);

        lightDirection *= inverseLightDistance;
        lightColor = light.color;
        lightColor *= (inverseLightDistance * inverseLightDistance);
    }
    
    static void sampleSunLight(thread Light & light,
                                 float2 u,
                                 float3 position,
                                 thread float3 & lightDirection,
                                 thread float3 & lightColor,
                                 thread float & lightDistance) {
        
        u = u * 2.0f - 1.0f;
        
        lightDirection = normalize(light.position - position);
        lightDistance = INFINITY;
        lightColor = light.color;
    }
};
