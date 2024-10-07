#include <metal_stdlib>
#include "Lighting.metal"

#import "Runner-Bridging-Header.h"

using namespace metal;

struct VertexIn {
    float3 position        [[ attribute(0) ]];
    float2 uvCoordinate    [[ attribute(1) ]];
    float3 normal          [[ attribute(2) ]];
    float3 tangent         [[ attribute(3) ]];
    float3 bitangent       [[ attribute(4) ]];
};

struct RasterizerData {
    float4 position [[ position ]];
    float2 uvCoordinate;
    
    float3 worldPosition;
    float3 surfaceNormal;
    float3 toCameraVector;
};

struct ModelConstants {
    float4x4 modelMatrix [[ id(0) ]];
};

struct SceneConstants {
    float4x4 viewMatrix;
    float4x4 projectionMatrix;
    float3 cameraPosition;
};

struct Material {
    bool isLit                 [[ attribute(0)  ]];
    float3 ambient             [[ attribute(1)  ]];
    float3 diffuse             [[ attribute(2)  ]];
    float3 specular            [[ attribute(3)  ]];
    float3 emissive            [[ attribute(4)  ]];
    float shininess            [[ attribute(5)  ]];
    float opacity              [[ attribute(6)  ]];
    float opticalDensity       [[ attribute(7)  ]];
    float roughness            [[ attribute(8)  ]];
    bool isTextureEnabled      [[ attribute(9)  ]];
    bool isNormalMapEnabled    [[ attribute(10) ]];
    bool isMetallicMapEnabled  [[ attribute(11) ]];
    bool isRoughnessMapEnabled [[ attribute(12) ]];
};

struct PrimitiveData {
    int textureId        [[ id(0) ]];
    int normalMapId      [[ id(1) ]];
    int metallicMapId    [[ id(2) ]];
    int roughnessMapId   [[ id(3) ]];
    int emissionMapId    [[ id(4) ]];
};

struct Textures {
    texture2d<float, access::sample> texture        [[ id(0) ]];
};

constant unsigned int primes2[] = {
    2,   3,  5,  7,
    11, 13, 17, 19,
    23, 29, 31, 37,
    41, 43, 47, 53,
};

float halton2(unsigned int i, unsigned int d) {
    unsigned int b = primes2[d];
    
    float f = 1.0f;
    float invB = 1.0f / b;
    
    float r = 0;
    
    while (i > 0) {
        f = f * invB;
        r = r + f * (i % b);
        i = i / b;
    }
    
    return r;
}

vertex RasterizerData basic_vertex_shader(const VertexIn vertexIn[[ stage_in ]], constant SceneConstants &sceneConstants [[ buffer(1) ]], constant ModelConstants &modelConstants [[ buffer(2) ]]) {
    
    RasterizerData rd;
    
    float4 worldPosition = modelConstants.modelMatrix * float4(vertexIn.position, 1);
    
    rd.position = sceneConstants.projectionMatrix * sceneConstants.viewMatrix * worldPosition;
    rd.uvCoordinate = vertexIn.uvCoordinate;
    
    
    rd.worldPosition = worldPosition.xyz;
    rd.surfaceNormal = normalize((modelConstants.modelMatrix * float4(vertexIn.normal, 1)).xyz);

    rd.toCameraVector = normalize(sceneConstants.cameraPosition - worldPosition.xyz);
    
    return rd;
}

fragment half4 basic_fragment_shader(RasterizerData rd [[ stage_in ]], sampler sampler2d[[ sampler(0) ]],
                                     constant Material &material [[ buffer(0) ]],
                                     const device PrimitiveData *primitiveData [[ buffer(1) ]],
                                     const device Textures *textures [[ buffer(2) ]],
                                     constant unsigned int &textureId [[ buffer(3) ]],
                                     constant unsigned int &lightCount [[ buffer(4) ]],
                                     device PSLight *psLights [[ buffer(5) ]],
                                     constant unsigned int &randomOffset [[ buffer(6) ]]){
    
    float4 color = float4(material.diffuse, 1.0);

    if(material.isTextureEnabled){
        float2 uvCoords = rd.uvCoordinate - floor(rd.uvCoordinate);
//        color = primitiveData[textureId].texture.sample(sampler2d, uvCoords);
    }

    if(material.isLit) {
        color = float4(material.diffuse, 1.0);
        return half4(color.r, color.g, color.b, color.a);
    }
    
    float3 totalAmbient = float3(0, 0, 0);
    float3 totalDiffuse = float3(0, 0, 0);
    float3 totalSpecular = float3(0, 0, 0);
    
    float2 r = float2(halton2(randomOffset, 0),
                      halton2(randomOffset, 1));

    for(int i = 0; i < (int)lightCount; i++) {
        PSLight psLight = psLights[i];
        Light light = psLights[i].light;
        
        // Ambinet
        totalAmbient += material.ambient * psLight.ambient;
        
        // Diffuse
        float3 lightDirection, lightColor;
        float lightDistance;
        Lighting::sampleLight(light, r, rd.worldPosition, lightDirection, lightColor, lightDistance);
        lightColor *= saturate(dot(rd.surfaceNormal, lightDirection));
        totalDiffuse += lightColor;
        
        // Specular
        float3 specular = material.specular;
        float3 reflectedRay = normalize(reflect(-lightDirection, rd.surfaceNormal));
        float rDotV = max(dot(reflectedRay, rd.toCameraVector), 0.0);
        float specularExp = pow(rDotV, material.shininess);
        float3 specularColor = saturate(specular * specularExp * light.color * psLight.brightness);
        totalSpecular += specularColor;
    }

    float3 phongIntensity = totalAmbient + totalDiffuse + totalSpecular;

    color *= float4(phongIntensity, 1.0);
    
    if(color.a < 0.1) {
        discard_fragment(); // Find a better way, because this has performance hit.
    }
    
    return half4(color.r, color.g, color.b, color.a);
}
