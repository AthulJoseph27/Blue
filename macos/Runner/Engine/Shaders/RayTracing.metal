#include <metal_stdlib>
#include <simd/simd.h>

#include "Lighting.metal"
#import "Runner-Bridging-Header.h"

using namespace metal;
using namespace raytracing;

#define PI 3.14159265359
#define FRENEL_ANGLE 7*PI/8

#define RAY_HIT_LIGHT -4
#define RAY_HIT_SKYBOX -3
#define RAY_HIT_TRANSPARENT -2

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
    texture2d<float, access::sample> texture        [[ id(0) ]];
    texture2d<float, access::sample> normalMap      [[ id(1) ]];
    texture2d<float, access::sample> metallicMap    [[ id(2) ]];
    texture2d<float, access::sample> roughnessMap   [[ id(3) ]];
};

struct Ray {
    packed_float3 origin;
    uint mask;
    packed_float3 direction;
    float maxDistance;
    float3 color;
};

struct Intersection {
    float distance;
    int primitiveIndex;
    int instanceIndex;
    float2 coordinates;
};

struct Vertex {
    float3 position        [[ attribute(0) ]];
    float2 uvCoordinate    [[ attribute(1) ]];
    float3 normal          [[ attribute(2) ]];
    float3 tangent         [[ attribute(3) ]];
    float3 bitangent       [[ attribute(4) ]];
};

struct VertexIndex {
    uint index        [[ attribute(0) ]];
    uint submeshId    [[ attribute(1) ]];
};

struct AlphaTestingPrimitiveData {
    texture2d<float, access::sample> texture;
    vector_float2 uvCoordinates[3];
};

constant unsigned int primes[] = {
    2,   3,  5,  7,
    11, 13, 17, 19,
    23, 29, 31, 37,
    41, 43, 47, 53,
};

float halton(unsigned int i, unsigned int d) {
    unsigned int b = primes[d];
    
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

kernel void rayKernel(uint2 tid                     [[thread_position_in_grid]],
                      constant Uniforms & uniforms  [[buffer(0)]],
                      device Ray *rays              [[buffer(1)]],
                      texture2d<unsigned int> randomTex [[texture(0)]],
                      texture2d<float, access::write> dstTex [[texture(1)]])
{
    if (tid.x < uniforms.width && tid.y < uniforms.height) {
        unsigned int rayIdx = tid.y * uniforms.width + tid.x;

        device Ray & ray = rays[rayIdx];
        
        unsigned int offset = randomTex.read(tid).x;
        float2 r = float2(halton(offset + uniforms.frameIndex, 0),
                          halton(offset + uniforms.frameIndex, 1));
        
        float2 pixel = (float2)tid;
        pixel+=r; // Adding a small offset to pixel for anti-aliasing

        float2 uv = (float2)pixel / float2(uniforms.width, uniforms.height);
        uv = uv * 2.0f - 1.0f;
        
        constant Camera & camera = uniforms.camera;
        
        ray.origin = camera.position;
        
        float3 direction = normalize(uv.x * camera.right +
                                       uv.y * camera.up +
                                       camera.forward);
        
        ray.direction = direction;
        
        ray.mask = RAY_MASK_PRIMARY;
        
        ray.maxDistance = INFINITY;
        
        ray.color = float3(1.0f, 1.0f, 1.0f);
        
        dstTex.write(float4(0.0f, 0.0f, 0.0f, 0.0f), tid);
    }
}


inline float3 interpolateVertexPosition(device Vertex *vertices, device uint* indicies, device uint *indicesCount, Intersection intersection) {
    float3 uvw;
    uvw.xy = intersection.coordinates;
    uvw.z = 1.0f - uvw.x - uvw.y;
    
    unsigned int offset = indicesCount[intersection.instanceIndex];
    unsigned int triangleIndex = intersection.primitiveIndex;
    
    float3 T0 = vertices[indicies[offset + triangleIndex * 3 + 0]].position;
    float3 T1 = vertices[indicies[offset + triangleIndex * 3 + 1]].position;
    float3 T2 = vertices[indicies[offset + triangleIndex * 3 + 2]].position;
    
    return uvw.x * T0 + uvw.y * T1 + uvw.z * T2;
}

inline float2 interpolateVertexUVCoord(device Vertex *vertices, device VertexIndex *indicies, uint vertexOffset, uint indiciesOffset, Intersection intersection) {
    float3 uvw;
    uvw.xy = intersection.coordinates;
    uvw.z = 1.0f - uvw.x - uvw.y;
    
    unsigned int triangleIndex = intersection.primitiveIndex;
    float2 T0 = vertices[vertexOffset + indicies[indiciesOffset + triangleIndex * 3 + 0].index].uvCoordinate;
    float2 T1 = vertices[vertexOffset + indicies[indiciesOffset + triangleIndex * 3 + 1].index].uvCoordinate;
    float2 T2 = vertices[vertexOffset + indicies[indiciesOffset + triangleIndex * 3 + 2].index].uvCoordinate;
    
    float2 uv = uvw.x * T0 + uvw.y * T1 + uvw.z * T2;
    return uv - floor(uv);
}

inline float3 interpolateVertexNormal(device Vertex *vertices, device VertexIndex *indicies, uint vertexOffset, uint indiciesOffset, Intersection intersection) {
    float3 uvw;
    uvw.xy = intersection.coordinates;
    uvw.z = 1.0f - uvw.x - uvw.y;
    
    unsigned int triangleIndex = intersection.primitiveIndex;
    
    float3 T0 = vertices[vertexOffset + indicies[indiciesOffset + triangleIndex * 3 + 0].index].normal;
    float3 T1 = vertices[vertexOffset + indicies[indiciesOffset + triangleIndex * 3 + 1].index].normal;
    float3 T2 = vertices[vertexOffset + indicies[indiciesOffset + triangleIndex * 3 + 2].index].normal;
    
    return uvw.x * T0 + uvw.y * T1 + uvw.z * T2;
}

inline float3 interpolateVertexTangent(device Vertex *vertices, device VertexIndex *indicies, uint vertexOffset,  uint indiciesOffset,  Intersection intersection) {
    float3 uvw;
    uvw.xy = intersection.coordinates;
    uvw.z = 1.0f - uvw.x - uvw.y;
    
    unsigned int triangleIndex = intersection.primitiveIndex;
    
    float3 T0 = vertices[vertexOffset + indicies[indiciesOffset + triangleIndex * 3 + 0].index].tangent;
    float3 T1 = vertices[vertexOffset + indicies[indiciesOffset + triangleIndex * 3 + 1].index].tangent;
    float3 T2 = vertices[vertexOffset + indicies[indiciesOffset + triangleIndex * 3 + 2].index].tangent;
    
    return uvw.x * T0 + uvw.y * T1 + uvw.z * T2;
}

inline float3 interpolateVertexBiTangent(device Vertex *vertices, device VertexIndex *indicies, uint vertexOffset,  uint indiciesOffset,  Intersection intersection) {
    float3 uvw;
    uvw.xy = intersection.coordinates;
    uvw.z = 1.0f - uvw.x - uvw.y;
    
    unsigned int triangleIndex = intersection.primitiveIndex;
    
    float3 T0 = vertices[vertexOffset + indicies[indiciesOffset + triangleIndex * 3 + 0].index].bitangent;
    float3 T1 = vertices[vertexOffset + indicies[indiciesOffset + triangleIndex * 3 + 1].index].bitangent;
    float3 T2 = vertices[vertexOffset + indicies[indiciesOffset + triangleIndex * 3 + 2].index].bitangent;
    
    return uvw.x * T0 + uvw.y * T1 + uvw.z * T2;
}

inline float3 alignHemisphereWithNormal(float3 sample, float3 normal) {
    float3 up = normal;
    float3 right = normalize(cross(normal, float3(0.0072f, 1.0f, 0.0034f)));
    float3 forward = cross(right, up);
    
    return sample.x * right + sample.y * up + sample.z * forward;
}

inline float3 sampleCosineWeightedHemisphere(float2 u) {
    float phi = 2.0f * M_PI_F * u.x;

    float cos_phi;
    float sin_phi = sincos(phi, cos_phi);

    float cos_theta = sqrt(u.y);
    float sin_theta = sqrt(1.0f - cos_theta * cos_theta);

    return float3(sin_theta * cos_phi, cos_theta, sin_theta * sin_phi);
}

inline float3 getSkyBoxColor(float3 u, texture2d<float, access::read> skyBox) {
    normalize(u);

    float w = max(skyBox.get_width(), skyBox.get_height());
    float h = min(skyBox.get_width(), skyBox.get_height());

    float _u = 0.5 + atan2(u.z, u.x) / (2.0 * PI);
    float _v = 0.5 - asin(u.y) / PI;

    _u *= w - 1;
    _v *= h - 1;

    if (skyBox.get_width() < skyBox.get_height()) {
        return float3(skyBox.read(uint2((int)_v, (int)_u)));
    }

    return float3(skyBox.read(uint2((int)_u, (int)_v)));
}

inline void trueReflection(device Ray & ray, float3 normal, float reflectivity, float3 color) {
    ray.direction = normalize(reflect(ray.direction, normal));
    ray.color = reflectivity * color;
    ray.mask = RAY_MASK_SECONDARY;
    ray.maxDistance = INFINITY;
}

inline float3 refract(float3 direction, float3 normal, float n1, float n2) {
    float n = n1 / n2;
    float cosI = -dot(normal, direction);
    float sinT2 = n * n * (1.0 - cosI * cosI);
    if(sinT2 > 1.0) {
        return reflect(direction, normal);
    }
    float cosT = sqrt(1.0 - sinT2);
    return n * direction + (n * cosI - cosT) * normal;
}

inline void fresnelEffect(device Ray & ray, float3 normal, float3 color, float n1, float n2, float reflectivity) {
    // Schlick's approximation
    float r0 = (n1 - n2) / (n1 + n2);
    r0 *= r0;
    
    float cosX = -dot(normal, ray.direction);
    if(n1 > n2) {
        float n = n1/n2;
        float sinT2 = n * n * (1.0 - cosX * cosX);
        if (sinT2 > 1.0) {
            return trueReflection(ray, normal, 1.0, color);
        }
        cosX = sqrt(1.0 - sinT2);
    }
    
    float x = 1.0 - cosX;
    float r = r0 + (1.0 - r0) * x * x * x * x * x; // r = r0 + (1 - r0) * (1 - cos0)^5
    
    r = reflectivity + (1.0 - reflectivity) * r;
    
    return trueReflection(ray, normal, r, color);
}

inline void refractRay(device Ray & ray, float3 normal, float refractiveIndex, float reflectivity, float3 color, unsigned int frameIndex) {
    normal = normalize(normal);
    float cosine = dot(ray.direction, normal);
    float n1 = 1.0;
    float n2 = refractiveIndex;
    bool inside = (cosine >= 0);
    
    if(inside) {
//         Invert normal
        normal *= -1;
        float t = n1;
        n1 = n2;
        n2 = t;
    } else if(frameIndex != 0 && frameIndex % 2 == 0) {
//        color /= 2.0; // Reducign the intensity of reflection
        return fresnelEffect(ray, normal, color, n1, n2, reflectivity);
    }
    
    float3 refractedRay = refract(normalize(ray.direction), normalize(normal), n1, n2);
    
    ray.direction = refractedRay;
    ray.color = color;
    ray.mask = RAY_MASK_SECONDARY;
    ray.maxDistance = INFINITY;
}


kernel void shadeKernel(uint2 tid [[thread_position_in_grid]],
                        constant Uniforms & uniforms,
                        device Light *lights,
                        device Ray *rays,
                        device Ray *shadowRays,
                        device Intersection *intersections,
                        device Vertex *vertices,
                        device VertexIndex *indices,
                        device uint *verticiesCount,
                        device uint *indiciesCount,
                        device uint *masks,
                        device Material *materials,
                        device PrimitiveData *primitiveData,
                        constant unsigned int & bounce,
                        texture2d<unsigned int> randomTex,
                        texture2d<float, access::write> dstTex,
                        texture2d<float, access::read> skyBox,
                        sampler sampler2d[[ sampler(0) ]])
{
    // TODO: randomize light index, else frensel effect may be dominating for some colors
    
    if (tid.x < uniforms.width && tid.y < uniforms.height) {
           unsigned int rayIdx = tid.y * uniforms.width + tid.x;
           device Ray & ray = rays[rayIdx];
           device Ray & shadowRay = shadowRays[rayIdx];
           device Intersection & intersection = intersections[rayIdx];
           
           float3 color = ray.color;
           
           if (ray.maxDistance >= 0.0f && intersection.distance >= 0.0f) {
               uint instanceIndex = intersection.instanceIndex;
               
               // Vertices for this solid starts after these many vertices
               uint verticesOffset = verticiesCount[instanceIndex];
               uint indiciesOffset = indiciesCount[instanceIndex];
               
               VertexIndex vertexIndex = indices[indiciesOffset + intersection.primitiveIndex * 3];
               
               uint submeshId = vertexIndex.submeshId;
               
               uint mask = masks[submeshId];
               Material material = materials[submeshId];
               
               if (mask == TRIANGLE_MASK_GEOMETRY) {
                   float3 intersectionPoint = ray.origin + ray.direction * intersection.distance;
                   
                   float2 uvCoord = interpolateVertexUVCoord(vertices, indices, verticesOffset, indiciesOffset, intersection);

                   float3 surfaceNormal = interpolateVertexNormal(vertices, indices, verticesOffset, indiciesOffset, intersection);

                   if(material.isNormalMapEnabled) {
                       float3 sampleNormal = primitiveData[submeshId].normalMap.sample(sampler2d, uvCoord).rgb * 2 - 1;
                       
                       float3 tangent = interpolateVertexTangent(vertices, indices, verticesOffset, indiciesOffset, intersection);
                       
                       float3 bitangent = interpolateVertexBiTangent(vertices, indices, verticesOffset, indiciesOffset, intersection);
                       
                       float3x3 TBN = {tangent, bitangent, sampleNormal};
                       
                       surfaceNormal = TBN * sampleNormal;
                   }

                   unsigned int offset = randomTex.read(tid).x;
                   float2 r = float2(halton(offset + uniforms.frameIndex, 0),
                                     halton(offset + uniforms.frameIndex, 1));

                   float3 lightDirection;
                   float3 lightColor;
                   float lightDistance;

                   float3 objectColor;
                   
                   Light light = lights[uniforms.lightIndex];
                   Lighting::sampleLight(light, r, intersectionPoint, lightDirection,
                                         lightColor, lightDistance);
                   lightColor *= saturate(dot(surfaceNormal, lightDirection));
                   
                   if(material.isTextureEnabled){
                       float4 sampledColor = primitiveData[submeshId].texture.sample(sampler2d, uvCoord);
                       if(sampledColor.a < 0.1) {
                           ray.origin = intersectionPoint + ray.direction * 1e-3f;
                           ray.mask = RAY_MASK_SECONDARY;
                           ray.maxDistance = INFINITY;
                           
                           shadowRay.color = float3(0);
                           shadowRay.maxDistance = RAY_HIT_TRANSPARENT;
                           return;
                       }
                       
                       objectColor = sampledColor.xyz;
                   } else {
                       objectColor = material.diffuse;
                   }
                   
                   color *= objectColor;

                   shadowRay.origin = intersectionPoint + surfaceNormal * 1e-3f;
                   shadowRay.direction = lightDirection;
                   shadowRay.mask = RAY_MASK_SHADOW;
                   shadowRay.maxDistance = lightDistance - 1e-3f;
                   
                   shadowRay.color = lightColor * color;

                   float refractiveIndex = 0.0;

                   if(material.opacity < 1.0) {
                       refractiveIndex = material.opticalDensity;
                   }

                   float reflectivity = (material.specular.x + material.specular.y + material.specular.z) / 3.0f;
                   
                   if(material.isMetallicMapEnabled) {
                       reflectivity = primitiveData[submeshId].metallicMap.sample(sampler2d, uvCoord).x;
                   }
  
                   if(refractiveIndex >= 1.0f){
                        // Refract ray
                       refractRay(ray, surfaceNormal, refractiveIndex, reflectivity, color, uniforms.frameIndex);
                   }else if(reflectivity > 0.1f){
                       // Reflect ray
                       trueReflection(ray, surfaceNormal, reflectivity, color);
                   }else{
                       float roughness = 0;

                       r = float2(halton(offset + uniforms.frameIndex, bounce + 1),
                                  halton(offset + uniforms.frameIndex, bounce + 3));
                       
                       if(material.isRoughnessMapEnabled) {
                           roughness = primitiveData[submeshId].roughnessMap.sample(sampler2d, uvCoord).x;
                       }
                       
                       float3 sampleDirection = sampleCosineWeightedHemisphere(r);
                       sampleDirection = alignHemisphereWithNormal(sampleDirection, surfaceNormal);

                       ray.direction = sampleDirection;
                       ray.color = color * (1.0f - roughness);
                       ray.mask = RAY_MASK_SECONDARY;
                   }
                   
                   ray.origin = intersectionPoint + ray.direction * 1e-3f;
               }
               else {
                   dstTex.write(float4(material.emissive, 1.0f), tid);
                   
                   ray.maxDistance = RAY_HIT_LIGHT;
                   shadowRay.maxDistance = RAY_HIT_LIGHT;
               }
           }
           else {
               float3 skyColor = getSkyBoxColor(ray.direction, skyBox);
               if(ray.maxDistance >= 0.0f && ray.mask == RAY_MASK_PRIMARY){
                   dstTex.write(float4(skyColor, 1), tid);
               }
               ray.color = color * skyColor;
               shadowRay.color = ray.color;
               ray.maxDistance = RAY_HIT_SKYBOX;
               shadowRay.maxDistance = RAY_HIT_SKYBOX;
           }
       }
}

bool alphaTest(uint instanceIndex, uint primitiveIndex, float2 barycentricCoord, device Vertex * vertices, device VertexIndex * indicies, device uint *verticiesCount, device uint *indiciesCount, device Material *materials, device PrimitiveData *primitiveDatas) {
    
    uint verticesOffset = verticiesCount[instanceIndex];
    uint indiciesOffset = indiciesCount[instanceIndex];
    
    VertexIndex vertexIndex = indicies[indiciesOffset + primitiveIndex * 3];
    
    uint submeshId = vertexIndex.submeshId;
    
    Material material = materials[submeshId];
    
    if(!material.isTextureEnabled) {
        return true;
    }
    
    constexpr sampler sam(min_filter::nearest, mag_filter::nearest, mip_filter::none);
    
    texture2d<float, access::sample> alphaTexture = primitiveDatas[submeshId].texture;
    
    Intersection intersection;
    intersection.primitiveIndex = primitiveIndex;
    intersection.coordinates = barycentricCoord;
    float2 uvCoords = interpolateVertexUVCoord(vertices, indicies, verticesOffset, indiciesOffset, intersection);
    
    float alpha = alphaTexture.sample(sam, uvCoords).x;
    
    return alpha >= 0.2;
}

kernel void shadowKernelWithAlphaTesting(uint2 tid [[thread_position_in_grid]],
                         primitive_acceleration_structure accelerationStructure,
                         constant Uniforms & uniforms,
                         device Ray *shadowRays,
                         device Vertex *vertices,
                         device VertexIndex *indicies,
                         device uint *verticiesCount,
                         device uint *indiciesCount,
                         device Material *materials,
                         device PrimitiveData *primitiveDatas,
                         texture2d<float, access::read_write> dstTex)
{
    if (tid.x < uniforms.width && tid.y < uniforms.height) {
        unsigned int rayIdx = tid.y * uniforms.width + tid.x;
        device Ray & shadowRay = shadowRays[rayIdx];
        
        float3 color = dstTex.read(tid).xyz;
        
        if(shadowRay.maxDistance >= 0.0f) {
            ray _ray;
            _ray.direction = shadowRay.direction;
            _ray.origin = shadowRay.origin;
            _ray.max_distance = shadowRay.maxDistance;
            _ray.min_distance = 1e-6f;
            
            intersection_params params;
            params.force_opacity(forced_opacity::none);
            params.assume_geometry_type(geometry_type::triangle);
            params.accept_any_intersection(true);
            
            intersection_query<triangle_data> intersector(_ray, accelerationStructure, params);
            
            while(intersector.next()) {
                bool accept = alphaTest(0, intersector.get_candidate_primitive_id(), intersector.get_candidate_triangle_barycentric_coord(), vertices, indicies, verticiesCount, indiciesCount, materials, primitiveDatas);
                
                if(accept) {
                    intersector.commit_triangle_intersection();
                }
            }
            
            float intersectionDistance = intersector.get_committed_distance();
            
            if(intersectionDistance >= shadowRay.maxDistance) {
                intersectionDistance = -1.0f;
            }
            
            if(intersectionDistance <= 0.0f) {
                color += shadowRay.color;
            } else{
                color += shadowRay.color * uniforms.ambient;
            }
        } else if(shadowRay.maxDistance == RAY_HIT_SKYBOX) {
            color += shadowRay.color;
        }
        
        dstTex.write(float4(color, 1.0f), tid);
    }
}

kernel void shadowKernel(uint2 tid [[thread_position_in_grid]],
                         constant Uniforms & uniforms,
                         device Ray *shadowRays,
                         device float *intersections,
                         texture2d<float, access::read_write> dstTex)
{
    if (tid.x < uniforms.width && tid.y < uniforms.height) {
        unsigned int rayIdx = tid.y * uniforms.width + tid.x;
        device Ray & shadowRay = shadowRays[rayIdx];

        float intersectionDistance = intersections[rayIdx];
        
        float3 color = dstTex.read(tid).xyz;
        
        if(shadowRay.maxDistance >= 0.0f) {
            if(intersectionDistance < 0.0f) {
                color += shadowRay.color;
            } else{
                color += shadowRay.color * uniforms.ambient;
            }
        }
        
        if(shadowRay.maxDistance == RAY_HIT_SKYBOX) {
            color += shadowRay.color;
        }
        
        dstTex.write(float4(color, 1.0f), tid);
    }
}

kernel void accumulateKernel(uint2 tid [[thread_position_in_grid]],
                             constant Uniforms & uniforms,
                             texture2d<float> renderTex,
                             texture2d<float, access::read_write> accumTex)
{
    if (tid.x < uniforms.width && tid.y < uniforms.height) {
        float3 color = renderTex.read(tid).xyz;

        if (uniforms.frameIndex > 0) {
            float3 prevColor = accumTex.read(tid).xyz;
            prevColor *= uniforms.frameIndex;

            color += prevColor;
            color /= (uniforms.frameIndex + 1);
        }
        
        accumTex.write(float4(color, 1.0f), tid);
    }
}

constant float2 quadVertices[] = {
    float2(-1, -1),
    float2(-1,  1),
    float2( 1,  1),
    float2(-1, -1),
    float2( 1,  1),
    float2( 1, -1)
};

struct CopyVertexOut {
    float4 position [[position]];
    float2 uv;
};

vertex CopyVertexOut copyVertex(unsigned short vid [[vertex_id]]) {
    float2 position = quadVertices[vid];
    
    CopyVertexOut out;
    
    out.position = float4(position, 0, 1);
    out.uv = position * 0.5f + 0.5f;
    
    return out;
}

fragment float4 copyFragment(CopyVertexOut in [[stage_in]],
                             texture2d<float> tex)
{
    constexpr sampler sam(min_filter::nearest, mag_filter::nearest, mip_filter::none);
    
    float3 color = tex.sample(sam, in.uv).xyz;
    
//    color = color / (1.0f + color);
    
    return float4(color, 1.0f);
}

inline float2 calculateSamplingCoordinate(float2 coordinates, float2 T0, float2 T1, float2 T2) {
    float3 uvw;
    uvw.xy = coordinates;
    uvw.z = 1.0f - uvw.x - uvw.y;
    
    return uvw.x * T0 + uvw.y * T1 + uvw.z * T2;
}
