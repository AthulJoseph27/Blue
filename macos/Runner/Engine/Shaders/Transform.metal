#include <metal_stdlib>
using namespace metal;

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

kernel void transformKernel(uint2 tid [[thread_position_in_grid]],
                        device Vertex *vertices,
                        device uint *indices,
                        device Vertex *transformedVertices,
                        constant float4x4 & transform,
                        constant unsigned int & vertexCount,
                        constant unsigned int & width) {
    
    unsigned int idx = tid.y * width + tid.x;
    
    if (idx >= vertexCount) {
        return;
    }
    
    Vertex v = vertices[indices[idx]];
    
    float3 position = (transform * float4(v.position, 1.0)).xyz;
    float3 normal = (transform * float4(v.normal, 0.0)).xyz;
    float3 tangent = (transform * float4(v.tangent, 0.0)).xyz;
    float3 bitangent = (transform * float4(v.bitangent, 0.0)).xyz;
    
    Vertex nv = Vertex();
    nv.position = position;
    nv.normal = normalize(normal);
    nv.tangent = normalize(tangent);
    nv.bitangent = normalize(bitangent);
    nv.uvCoordinate = v.uvCoordinate;
    
    transformedVertices[idx] = nv;
}

kernel void indexWrapperKernel(uint2 tid [[thread_position_in_grid]],
                               device uint* indicies,
                               device VertexIndex *wrappedIndices,
                               constant unsigned int & submeshId,
                               constant unsigned int & indicesCount,
                               constant unsigned int & width) {
           
    unsigned int idx = tid.y * width + tid.x;
    
    if (idx >= indicesCount) {
        return;
    }

       
    VertexIndex index = VertexIndex();
    index.index = indicies[idx];
    index.submeshId = submeshId;

    wrappedIndices[idx] = index;
}

kernel void indexGeneratorKernel(uint2 tid [[thread_position_in_grid]],
                               device VertexIndex *wrappedIndices,
                               constant unsigned int & indexOffset,
                               constant unsigned int & submeshId,
                               constant unsigned int & indiciesCount,
                               constant unsigned int & width) {
           
    unsigned int idx = tid.y * width + tid.x;
    
    if (idx >= indiciesCount) {
        return;
    }

       
    VertexIndex index = VertexIndex();
    index.index = indexOffset + idx;
    index.submeshId = submeshId;

    wrappedIndices[idx] = index;
}

