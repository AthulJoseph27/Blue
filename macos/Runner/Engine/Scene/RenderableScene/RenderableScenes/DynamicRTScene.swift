import MetalKit
import MetalPerformanceShaders

class DynamicRTScene: RTScene {

    var heap = Heap()
    
    var renderOptions: RTRenderOptions
    
    var masks: [uint]         = []
    var materials: [Material] = []
    var textures: [TextureIds]  = []
    
    var objects: [Solid] = []
    var lights:  [Light] = []
    var ambient: Float = 0
    var sceneTime: Float = 0
    
    var accelerationStructures: [[MPSTriangleAccelerationStructure]] = []
    
    var vertexBuffer:         MTLBuffer!
    var indexBuffer:          MTLBuffer!
    var customIndexBuffer:    MTLBuffer!
    var lightBuffer:          MTLBuffer!
    var textureBuffer:        MTLBuffer!
    var textureIdBuffer:      MTLBuffer!
    var materialBuffer:       MTLBuffer!
    var verticesCountBuffer:  MTLBuffer!
    var indiciesCountBuffer:  MTLBuffer!
    var maskBuffer:           MTLBuffer!
    var transformBuffer:      MTLBuffer!
    var uniformBuffer:        MTLBuffer!
    
    var instanceBuffer:                MTLBuffer!
    var instanceTransformBuffer:       MTLBuffer!
    var instanceNormalTransformBuffer: MTLBuffer!

    
    var skyBox: MTLTexture!
    
    var instanceAccelerationStructures: [MPSInstanceAccelerationStructure]!
    
    var frameIndex: UInt32 = 0
    var lightIndex: UInt32 = 0
    
    var uniformBufferOffset: Int!
    var uniformBufferIndex: Int = 0
    
    var indexWrapperPipeline: MTLComputePipelineState!
    
    var uniforms: Uniforms?
    var prevUniforms: Uniforms?
    
    var updateSceneSolids: (_ solids: [Solid], _ time: Float) -> Void
    
    init(scene: GameScene) {
        renderOptions = RTRenderOptions()
        renderOptions.rayMaskOptions = .instance
        indexWrapperPipeline = ComputePipelineStateLibrary.pipelineState(.IndexWrapper).computePipelineState
        skyBox = Skyboxibrary.skybox(.Sky)
        ambient = scene.ambient
        self.updateSceneSolids = scene.updateSolids
        buildScene(scene: scene)
        postBuildScene()
    }
    
    func getAccelerationStructure()->MPSAccelerationStructure {
        return instanceAccelerationStructures[Int(frameIndex) % renderOptions.maxFramesInFlight]
    }
    
    func getMTLAccelerationStructure() -> MTLAccelerationStructure {
        fatalError("Function is not implemented!")
    }
    
    func updateSceneSettings(sceneSettings: SceneSettings) {
        skyBox = Skyboxibrary.skybox(sceneSettings.skybox)
        ambient = sceneSettings.ambientLighting
    }
    
    func updateScene(time: Float? = nil) {
        updateSceneSolids(objects, time ?? sceneTime)
        updateTransformBuffer()
        refitAccelerationStructures()
        updateInstanceAccelerationStructures()
    }
    
    func updateUniforms(size: CGSize) {}
    
    func postSceneLightSet() {
        lightBuffer = Engine.device.makeBuffer(bytes: &self.lights, length: MemoryLayout<Light>.stride * lights.count, options: .storageModeShared)
    }
    
    func getInstanceTransformsSize() -> Int {
        let instanceTransformsSize = objects.count * float4x4.size;
        
        return (instanceTransformsSize + 255) & ~255;
    }
    
    func getInstanceTransformsBufferSize() -> Int {
        return getInstanceTransformsSize() * (renderOptions.maxFramesInFlight + 1)
    }
    
    func getInstanceNormalTransformsSize() -> Int {
        let instanceTransformsSize = objects.count * float3x3.size;
        
        return (instanceTransformsSize + 255) & ~255;
    }
    
    func getInstanceNormalTransformsBufferSize() -> Int {
        return getInstanceNormalTransformsSize() * (renderOptions.maxFramesInFlight + 1)
    }
    
    func getInstanceBufferSize() -> Int {
        let instancesSize = objects.count * __uint32_t.size
        let alignedInstancesSize = (instancesSize + 255) & ~255;
        return alignedInstancesSize
    }
    
    func getInstanceTransformBufferOffset() -> Int {
        return getInstanceTransformsSize() * (Int(frameIndex) % (renderOptions.maxFramesInFlight + 1))
    }
    
    func getPreviousInstanceTransformBufferOffset() -> Int {
        let index = Int(frameIndex) % (renderOptions.maxFramesInFlight + 1)
        
        // Wrap around backwards if needed
        return getInstanceTransformsSize() * ((index != 0) ? index - 1 : renderOptions.maxFramesInFlight);
    }

    func getInstanceNormalTransformBufferOffset() -> Int {
        return getInstanceNormalTransformsSize() * (Int(frameIndex) % (renderOptions.maxFramesInFlight + 1));
    }
    
    internal func addSolid(solid: Solid) {
        objects.append(solid)
        
        for i in 0..<solid.mesh.submeshCount {
            materials.append(solid.mesh.materials[i])
            textures.append(TextureIds(baseColor: solid.mesh.textures[.baseColor]![i], normalMap: solid.mesh.textures[.objectSpaceNormal]![i], metallic: solid.mesh.textures[.metallic]![i], roughness: solid.mesh.textures[.roughness]![i], emission: solid.mesh.textures[.emission]![i]))
            
            if solid.isLightSource {
                masks.append(uint(TRIANGLE_MASK_LIGHT))
            } else {
                masks.append(uint(TRIANGLE_MASK_GEOMETRY))
            }
        }
    }
    
    internal func addLight(light: Light) {
        lights.append(light)
    }
    
    internal func createBuffers() {
        // Vertex Buffers
        let commandBuffer = Engine.device.makeCommandQueue()?.makeCommandBuffer()
        commandBuffer?.label = "Buffer merge Command Buffer"
        let blitEncoder = commandBuffer?.makeBlitCommandEncoder()
        blitEncoder?.label = "Buffer merge Blit Encoder"
        
        var vertexBuffers:       [MTLBuffer] = []
        var indexBuffers:        [MTLBuffer] = []
        var wrappedIndexBuffers: [MTLBuffer] = []
        
        var transforms: [matrix_float4x4] = []
        var instances:  [UInt32] = []
        var indiciesCount: [UInt32] = [0]
        var verticesCount: [UInt32]  = []
        var instanceId = 0
        
        var submeshId: UInt32 = 0
        var indexOffset = 0
        
        var cummulativeVertexCount: UInt32 = 0
        
        for i in 0..<objects.count {
            let solid = objects[i]
            vertexBuffers.append(solid.mesh.vertexBuffer)

            indexBuffers.append(contentsOf: solid.mesh.indexBuffers)
            for j in 0..<solid.mesh.submeshCount {
                transforms.append(solid.modelMatrix)
                wrappedIndexBuffers.append(wrapIndexBuffer(indexBuffer: &solid.mesh.indexBuffers[j], keepOriginalIndex: true, indexOffset: UInt32(indexOffset), submeshId: submeshId))
                verticesCount.append(UInt32(cummulativeVertexCount))
                indiciesCount.append(indiciesCount.last! + UInt32(solid.mesh.indexBuffers[j].length / UInt32.stride))
                
                submeshId += 1
                indexOffset += (solid.mesh.indexBuffers[j].length / UInt32.stride)
                instances.append(uint(instanceId))
                instanceId += 1
            }
            
            cummulativeVertexCount = verticesCount.last! + UInt32(solid.mesh.vertexBuffer.length / VertexIn.stride)
        }
        
        verticesCount.append(cummulativeVertexCount)
        
        self.vertexBuffer = mergeBuffers(buffers: vertexBuffers, blitEncoder: blitEncoder)
        self.indexBuffer = mergeBuffers(buffers: indexBuffers, blitEncoder: blitEncoder)
        self.customIndexBuffer = mergeBuffers(buffers: wrappedIndexBuffers, blitEncoder: blitEncoder)
        
        blitEncoder?.endEncoding()
        commandBuffer?.commit()
        commandBuffer?.waitUntilCompleted()
        
        let storageOptions: MTLResourceOptions
        storageOptions = .storageModeShared
        
        
        instanceTransformBuffer = Engine.device.makeBuffer(length: getInstanceTransformsBufferSize(), options: storageOptions)
        instanceNormalTransformBuffer = Engine.device.makeBuffer(length: getInstanceNormalTransformsBufferSize(), options: storageOptions)
        instanceBuffer = Engine.device.makeBuffer(length: getInstanceBufferSize(), options: storageOptions)
        
        // Other buffers
        verticesCountBuffer = Engine.device.makeBuffer(bytes: &verticesCount, length: UInt32.stride(verticesCount.count), options: storageOptions)
        indiciesCountBuffer = Engine.device.makeBuffer(bytes: &indiciesCount, length: UInt32.stride(indiciesCount.count), options: storageOptions)
        
        let uniformBufferSize = renderOptions.alignedUniformsSize * renderOptions.maxFramesInFlight
        self.uniformBuffer = Engine.device.makeBuffer(length: uniformBufferSize, options: storageOptions)
        self.lightBuffer = Engine.device.makeBuffer(bytes: &lights, length: MemoryLayout<Light>.stride * lights.count, options: storageOptions)
        self.instanceBuffer = Engine.device.makeBuffer(bytes: &instances, length: uint.stride(instances.count), options: storageOptions)
        self.transformBuffer = Engine.device.makeBuffer(bytes: &transforms, length: matrix_float4x4.stride(transforms.count), options: storageOptions)
        self.materialBuffer = Engine.device.makeBuffer(bytes: &materials, length: Material.stride(materials.count), options: storageOptions)
        self.textureIdBuffer = Engine.device.makeBuffer(bytes: &textures, length: Texture.stride(textures.count), options: storageOptions)
        self.maskBuffer = Engine.device.makeBuffer(bytes: &masks, length: uint.stride(masks.count), options: storageOptions)
    }
    
    func advanceFrame() {}
    
    func refitAccelerationStructures() {
        var vertexBufferOffset = 0
        var indexBufferOffset = 0
        
        let commandBuffer = Engine.device.makeCommandQueue()!.makeCommandBuffer()!
        commandBuffer.label = "Buffer update Command Buffer"
        
        for i in 0..<objects.count {
            let solid = objects[i]
            for j in 0..<solid.mesh.submeshCount {
                if solid.animated {
                    let blitEncoder = commandBuffer.makeBlitCommandEncoder()!
                    blitEncoder.label = "Buffer update Blit Encoder"
                    blitEncoder.copy(from: solid.mesh.vertexBuffer, sourceOffset: 0, to: vertexBuffer, destinationOffset: vertexBufferOffset, size: solid.mesh.vertexBuffer.length)
                    blitEncoder.endEncoding()
                    accelerationStructures[i][j].vertexBuffer = vertexBuffer
                    accelerationStructures[i][j].encodeRefit(commandBuffer: commandBuffer)
                }
                indexBufferOffset += solid.mesh.indexBuffers[j].length
            }
            vertexBufferOffset += solid.mesh.vertexBuffer.length
        }
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    private func createAccelerationStructures() {
        let group = MPSAccelerationStructureGroup(device: Engine.device)
        var acceleratedStructures: [MPSTriangleAccelerationStructure] = []
        
        var vertexBufferOffset = 0
        var indexBufferOffset = 0
        
        var instanceCount = 0
        
        for j in 0..<objects.count {
            let solid = objects[j]
            self.accelerationStructures.append([])
            for i in 0..<solid.mesh.submeshCount {
                let triangleAccelerationStructure = MPSTriangleAccelerationStructure(group: group)
                
                triangleAccelerationStructure.vertexBuffer = vertexBuffer
                triangleAccelerationStructure.vertexBufferOffset = vertexBufferOffset
                triangleAccelerationStructure.vertexStride = VertexIn.stride
                triangleAccelerationStructure.indexBuffer = indexBuffer
                triangleAccelerationStructure.indexBufferOffset = indexBufferOffset
                triangleAccelerationStructure.triangleCount = solid.mesh.indexBuffers[i].length / (3 * UInt32.stride)
                
                if solid.animated {
                    triangleAccelerationStructure.usage = .refit
                }
                
                triangleAccelerationStructure.rebuild()
                
                self.accelerationStructures[j].append(triangleAccelerationStructure)
                acceleratedStructures.append(triangleAccelerationStructure)
                indexBufferOffset += solid.mesh.indexBuffers[i].length
                instanceCount += 1
            }
            vertexBufferOffset += solid.mesh.vertexBuffer.length
        }
        
        instanceAccelerationStructures = []
        
        for _ in 0..<renderOptions.maxFramesInFlight {
            let instanceAcceleratedStructure = MPSInstanceAccelerationStructure(group: group)
            instanceAcceleratedStructure.accelerationStructures = acceleratedStructures

            instanceAcceleratedStructure.transformBuffer = transformBuffer
            instanceAcceleratedStructure.instanceBuffer = instanceBuffer
            instanceAcceleratedStructure.instanceCount = instanceCount
            instanceAcceleratedStructure.maskBuffer = maskBuffer
            instanceAcceleratedStructure.rebuild()
            
            instanceAccelerationStructures.append(instanceAcceleratedStructure)
        }
    }
    
    private func updateInstanceAccelerationStructures() {
        for i in 0..<renderOptions.maxFramesInFlight {
            instanceAccelerationStructures[i].transformBuffer = transformBuffer
            instanceAccelerationStructures[i].transformBufferOffset = 0
            instanceAccelerationStructures[i].rebuild()
        }
    }
    
    private func postBuildScene() {
        createBuffers()
        createAccelerationStructures()
        heap.initialize(sourceTextureBuffer: &textureBuffer)
    }
    
    private func updateTransformBuffer() {
        var transforms: [matrix_float4x4] = []
        for solid in objects {
            for _ in 0..<solid.mesh.submeshCount {
                transforms.append(solid.modelMatrix)
            }
        }
        
        self.transformBuffer = Engine.device.makeBuffer(bytes: &transforms, length: matrix_float4x4.stride(transforms.count), options: .storageModeShared)
        
        let instanceTransformsSize = getInstanceTransformsSize()
//        let instanceNormalTransformsSize = getInstanceNormalTransformsSize()
        
        let instanceTransformBufferOffset = instanceTransformsSize * (Int(frameIndex) % (renderOptions.maxFramesInFlight + 1))
        let instanceNormalTransformBufferOffset = getInstanceNormalTransformsSize() * (Int(frameIndex) % (renderOptions.maxFramesInFlight + 1))
        
        let accelerationStructure = instanceAccelerationStructures[Int(frameIndex) % renderOptions.maxFramesInFlight]
        
        accelerationStructure.transformBufferOffset = instanceTransformBufferOffset
        
        let transformsContent = instanceTransformBuffer.contents().advanced(by: instanceTransformBufferOffset)
        let count = transforms.count
        let transformPointer = transformsContent.bindMemory(to: float4x4.self, capacity: count)
        
        let normals = instanceNormalTransformBuffer.contents().advanced(by: instanceNormalTransformBufferOffset)
        let normalPointer = normals.bindMemory(to: float3x3.self, capacity: count)
        
        for i in 0..<count {
            transformPointer[i] = transforms[i]
            normalPointer[i] = getNormalMatrix(transforms[i])
        }
    }
    
    private func getNormalMatrix(_ transform: float4x4) -> float3x3 {
        // Get the inverse transpose of the transform matrix.
        let inverseTranspose = transform.inverse.transpose
        
        // Create a new matrix that is the same size as the transform matrix.
        var normalMatrix = float3x3()
        
        // For each row in the new matrix, multiply each component by the corresponding component in the inverse transpose of the transform matrix.
        for i in 0 ..< 3 {
            for j in 0 ..< 3 {
                normalMatrix[i][j] = inverseTranspose[i][j]
            }
        }
        
        return normalMatrix
    }
}
