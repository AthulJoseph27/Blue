import MetalKit
import MetalPerformanceShaders

class StaticRTScene: RTScene {
    
    var heap = Heap()
    
    var renderOptions: RTRenderOptions = RTRenderOptions()
    
    var masks:     [UInt32]   = []
    var rayMasks:  [UInt32]   = []
    var materials: [Material] = []
    var textures:  [TextureIds] = []
    
    var objects: [Solid] = []
    var lights:  [Light] = []
    
    var ambient: Float = 0
    var sceneTime: Float = 0
    
    var vertexBuffer:        MTLBuffer!
    var indexBuffer:         MTLBuffer!
    var customIndexBuffer:   MTLBuffer!
    var textureBuffer:       MTLBuffer!
    var textureIdBuffer:     MTLBuffer!
    var materialBuffer:      MTLBuffer!
    var lightBuffer:         MTLBuffer!
    var verticesCountBuffer: MTLBuffer!
    var indiciesCountBuffer: MTLBuffer!
    var maskBuffer:          MTLBuffer!
    var rayMaskBuffer:       MTLBuffer!
    var transformBuffer:     MTLBuffer!
    var uniformBuffer:       MTLBuffer!
    
    var skyBox: MTLTexture!
    
    var accelerationStructure:      MPSTriangleAccelerationStructure!
    var mtlAccelerationStrucutre:   MTLAccelerationStructure!
    var transformPipeline:          MTLComputePipelineState!
    var indexWrapperPipeline:       MTLComputePipelineState!
    
    var frameIndex: UInt32 = 0
    var lightIndex: UInt32 = 0
    
    var uniformBufferOffset: Int!
    var uniformBufferIndex: Int = 0
    
    var uniforms: Uniforms?
    var prevUniforms: Uniforms?
    
//    // Dynamic Scene Animation frames is rendered using StaticRTScene
//    var updateSceneSolids: (_ solids: [Solid], _ time: Float) -> Void
    
    init(scene: GameScene) {
        skyBox = Skyboxibrary.skybox(scene.skybox)
        ambient = scene.ambient
        transformPipeline = ComputePipelineStateLibrary.pipelineState(.Transform).computePipelineState
        indexWrapperPipeline = ComputePipelineStateLibrary.pipelineState(.IndexGenerator).computePipelineState
        buildScene(scene: scene)
        postBuildScene()
    }
    
    func getAccelerationStructure()->MPSAccelerationStructure {
        return accelerationStructure
    }
    
    func getMTLAccelerationStructure() -> MTLAccelerationStructure {
        return mtlAccelerationStrucutre
    }
    
    func updateScene(time: Float?) {
        
    }
    
    func advanceFrame() {}
    
    func updateSceneSettings(sceneSettings: SceneSettings) {
        skyBox = Skyboxibrary.skybox(sceneSettings.skybox)
        ambient = sceneSettings.ambientLighting
    }
    
    func postSceneLightSet() {
        lightBuffer = Engine.device.makeBuffer(bytes: &self.lights, length: MemoryLayout<Light>.stride * lights.count, options: .storageModeShared)
    }
    
    private func postBuildScene() {
        createBuffers()
        createAccelerationStructure()
        createMTLAccelerationStructure()
        heap.initialize(sourceTextureBuffer: &textureBuffer)
    }
    
    internal func addSolid(solid: Solid) {
        objects.append(solid)
        
        for i in 0..<solid.mesh.submeshCount {
            materials.append(solid.mesh.materials[i])
            textures.append(TextureIds(baseColor: solid.mesh.textures[.baseColor]![i], normalMap: solid.mesh.textures[.objectSpaceNormal]![i], metallic: solid.mesh.textures[.metallic]![i], roughness: solid.mesh.textures[.roughness]![i], emission: solid.mesh.textures[.emission]![i]))
            print(textures.last)
            
            for _ in 0..<solid.mesh.indexBuffers[i].length / (3 * UInt32.stride) {
                if solid.isLightSource {
                    rayMasks.append(UInt32(TRIANGLE_MASK_LIGHT))
                } else {
                    rayMasks.append(UInt32(TRIANGLE_MASK_GEOMETRY))
                }
            }
            
            if solid.isLightSource {
                masks.append(UInt32(TRIANGLE_MASK_LIGHT))
            } else {
                masks.append(UInt32(TRIANGLE_MASK_GEOMETRY))
            }
        }
    }
    
    internal func addLight(light: Light) {
        lights.append(light)
    }
    
    private func transformSolid(vertexBuffer: inout MTLBuffer, indexBuffer: inout MTLBuffer, transform: matrix_float4x4)->MTLBuffer {
        
        var vertexCount = indexBuffer.length / UInt32.stride
        var transformMatrix = transform
        let transformedVertexBuffer = Engine.device.makeBuffer(length: VertexIn.stride(vertexCount), options: .storageModeShared)
        
        let commandBuffer = Engine.commandQueue.makeCommandBuffer()!
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()!
        computeEncoder.setBuffer(vertexBuffer, offset: 0, index: 0)
        computeEncoder.setBuffer(indexBuffer, offset: 0, index: 1)
        computeEncoder.setBuffer(transformedVertexBuffer, offset: 0, index: 2)
        computeEncoder.setBytes(&transformMatrix, length: matrix_float4x4.stride, index: 3)
        
        computeEncoder.setBytes(&vertexCount, length: uint.size, index: 4)
        
        var w = transformPipeline.threadExecutionWidth
        computeEncoder.setBytes(&w, length: uint.size, index: 5)
        
        computeEncoder.setComputePipelineState(transformPipeline)
        
        let threadsPerThreadgroup = MTLSizeMake(w, 1, 1)
        let threadsPerGrid = MTLSizeMake(vertexCount, 1, 1)
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        computeEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        return transformedVertexBuffer!
    }
    
    internal func createBuffers() {
        // Vertex Buffers
        let commandBuffer = Engine.device.makeCommandQueue()?.makeCommandBuffer()
        commandBuffer?.label = "Buffer merge Command Buffer"
        let blitEncoder = commandBuffer?.makeBlitCommandEncoder()
        blitEncoder?.label = "Buffer merge Blit Encoder";
        
        var indexBuffers:        [MTLBuffer] = []
        var wrappedIndexBuffers: [MTLBuffer] = []
        var transformedBuffers:  [MTLBuffer] = []
        
        var submeshId: UInt32 = 0
        var indexOffset = 0
        
        for i in 0..<objects.count {
            let solid = objects[i]
            indexBuffers.append(contentsOf: solid.mesh.indexBuffers)
            for j in 0..<solid.mesh.submeshCount {
                transformedBuffers.append(transformSolid(vertexBuffer: &solid.mesh.vertexBuffer, indexBuffer: &solid.mesh.indexBuffers[j], transform: solid.modelMatrix))
                wrappedIndexBuffers.append(wrapIndexBuffer(indexBuffer: &solid.mesh.indexBuffers[j], indexOffset: UInt32(indexOffset), submeshId: submeshId))
                
                submeshId += 1
                indexOffset += (solid.mesh.indexBuffers[j].length / UInt32.stride)
            }
        }
        
        self.vertexBuffer = mergeBuffers(buffers: transformedBuffers, blitEncoder: blitEncoder)
        self.customIndexBuffer = mergeBuffers(buffers: wrappedIndexBuffers, blitEncoder: blitEncoder)
        
        blitEncoder?.endEncoding()
        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted()
        
        let storageOptions: MTLResourceOptions
        storageOptions = .storageModeShared
        
        let vertexCount = vertexBuffer.length / VertexIn.stride
        var indicies: [uint] = []
        for i in 0..<vertexCount {
            indicies.append(uint(i))
        }
        self.indexBuffer = Engine.device.makeBuffer(bytes: &indicies, length: uint.stride(indicies.count), options: storageOptions)
        
        // Other buffers
        var verticesCount = [0]
        verticesCountBuffer = Engine.device.makeBuffer(bytes: &verticesCount, length: uint.stride(1), options: storageOptions)
        var indiciesCount = [0]
        indiciesCountBuffer = Engine.device.makeBuffer(bytes: &indiciesCount, length: uint.stride(1), options: storageOptions)
        
        let uniformBufferSize = renderOptions.alignedUniformsSize * renderOptions.maxFramesInFlight
        self.uniformBuffer = Engine.device.makeBuffer(length: uniformBufferSize, options: storageOptions)
        self.lightBuffer = Engine.device.makeBuffer(bytes: &lights, length: MemoryLayout<Light>.stride * lights.count, options: storageOptions)
        self.materialBuffer = Engine.device.makeBuffer(bytes: &materials, length: Material.stride(materials.count), options: storageOptions)
        self.textureIdBuffer = Engine.device.makeBuffer(bytes: &textures, length: TextureIds.stride(textures.count), options: storageOptions)
        self.maskBuffer = Engine.device.makeBuffer(bytes: &masks, length: UInt32.stride(masks.count), options: storageOptions)
        self.rayMaskBuffer = Engine.device.makeBuffer(bytes: &rayMasks, length: UInt32.stride(rayMasks.count), options: storageOptions)
    }
    
    private func createAccelerationStructure() {
        accelerationStructure = MPSTriangleAccelerationStructure(device: Engine.device)
        accelerationStructure.vertexBuffer = vertexBuffer
        accelerationStructure.vertexStride = VertexIn.stride
        accelerationStructure.indexBuffer = indexBuffer
        accelerationStructure.maskBuffer = rayMaskBuffer
        accelerationStructure.triangleCount = indexBuffer.length / (3 * UInt32.stride)
        accelerationStructure.rebuild()
    }
    
    private func createMTLAccelerationStructure() {
        let accelerationStructureDescriptor = MTLPrimitiveAccelerationStructureDescriptor()
        
        let geometryDescriptor = MTLAccelerationStructureTriangleGeometryDescriptor()
        
        geometryDescriptor.vertexBuffer = vertexBuffer
        geometryDescriptor.vertexStride = VertexIn.stride
        geometryDescriptor.indexBuffer = indexBuffer
        geometryDescriptor.indexType = .uint32
        geometryDescriptor.triangleCount = indexBuffer.length / (3 * UInt32.stride)
        
        accelerationStructureDescriptor.geometryDescriptors = [geometryDescriptor]
        
        let sizes = Engine.device.accelerationStructureSizes(descriptor: accelerationStructureDescriptor)
        
        mtlAccelerationStrucutre = Engine.device.makeAccelerationStructure(size: sizes.accelerationStructureSize)!
        
        let scratchBuffer = Engine.device.makeBuffer(length: sizes.buildScratchBufferSize, options: .storageModePrivate)!
        
        let commandBuffer = Engine.commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeAccelerationStructureCommandEncoder()!
        
        commandEncoder.build(accelerationStructure: mtlAccelerationStrucutre, descriptor: accelerationStructureDescriptor, scratchBuffer: scratchBuffer, scratchBufferOffset: 0)
        
        commandEncoder.endEncoding()
        commandBuffer.commit()
    }
}
