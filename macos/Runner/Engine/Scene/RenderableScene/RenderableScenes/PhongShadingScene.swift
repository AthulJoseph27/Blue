import MetalKit
import MetalPerformanceShaders

class PhongShadingScene: RenderableScene {
    
    var renderOptions: PSRenderOptions = PSRenderOptions()
    
    var heap = Heap()
    var textures: [TextureIds] = []
    var materials: [Material] = []
    var objects: [Solid] = []
    var lights: [Light] = []
    var ambient: Float = 0
    var sceneTime: Float = 0
    var PSLights: [PSLight] = []
    var randomValues: [UInt32] = []
    
    var materialBuffer: MTLBuffer!
    var textureBuffer:  MTLBuffer!
    var lightBuffer:    MTLBuffer!
    
    var skyBox: MTLTexture!
    
    var frameIndex: uint = 0
    
    var sceneConstants = SceneConstants()
    
    var sampler: MTLSamplerState?
    
    var uniforms: Uniforms?
    var prevUniforms: Uniforms?
    
    init(scene: GameScene) {
        skyBox = Skyboxibrary.skybox(.Sky)
        createSampler()
        buildScene(scene: scene)
        createBuffers()
        heap.initialize(sourceTextureBuffer: &textureBuffer)
        fillRandomValues()
    }
    
    func updateScene(time: Float?) {}
    
    func postSceneLightSet() {}
    
    func advanceFrame() {}
    
    func updateSceneSettings(sceneSettings: SceneSettings) {
        skyBox = Skyboxibrary.skybox(sceneSettings.skybox)
        ambient = sceneSettings.ambientLighting
    }
    
    func drawSolids(renderEncoder: MTLRenderCommandEncoder) {
        var currentCamera = CameraManager.currentCamera!
        
        // Inverting Camera Axis
        currentCamera.rotation *= -1
        
        sceneConstants.viewMatrix = currentCamera.viewMatrix
        sceneConstants.projectionMatrix = currentCamera.projectionMatrix
        sceneConstants.cameraPosition = currentCamera.position * -1
        
        // Resetting Camera Axis
        currentCamera.rotation *= -1
        
        renderEncoder.setVertexBytes(&sceneConstants, length: SceneConstants.stride, index: 1)
        
        currentCamera.deltaRotation = SIMD3<Float>(repeating: 0)
        currentCamera.deltaPosition = SIMD3<Float>(repeating: 0)
        
        renderEncoder.setDepthStencilState(DepthStencilLibrary.depthStencilState(.Less))
        
        renderEncoder.setFragmentSamplerState(sampler, index: 0)
        
        var lightCount = UInt32(lights.count)
        renderEncoder.setFragmentBytes(&lightCount, length: UInt32.stride, index: 3)
        renderEncoder.setFragmentBuffer(lightBuffer, offset: 0, index: 4)
        
        
        renderEncoder.useHeap(heap.heap, stages: .fragment)
        renderEncoder.setFragmentBuffer(textureBuffer, offset: 0, index: 1)
        
        var textureId: UInt32 = 0
        var id = 0
        
        for solid in objects {
            renderEncoder.setVertexBuffer(solid.mesh.vertexBuffer, offset: 0, index: 0)
            
            var modelConstants = ModelConstants(modelMatrix: solid.modelMatrix)
            renderEncoder.setVertexBytes(&modelConstants, length: ModelConstants.stride, index: 2)
            
            
            for i in 0..<solid.mesh.indexBuffers.count {
                
                let indexBuffer = solid.mesh.indexBuffers[i]
                let indexCount = indexBuffer.length / UInt32.stride
                
                renderEncoder.setFragmentBytes(&solid.mesh.materials[i], length: Material.stride, index: 0)
                // TODO: Set buffer at index 1.
                renderEncoder.setFragmentBytes(&textures[i], length: Texture.stride, index: 2)
                renderEncoder.setFragmentBytes(&textureId, length: UInt32.stride, index: 3)
                
                
                var randomOffset = randomValues[id % 1024]
                renderEncoder.setFragmentBytes(&randomOffset, length: UInt32.stride, index: 6)
                renderEncoder.drawIndexedPrimitives(type: .triangle, indexCount: indexCount, indexType: .uint32, indexBuffer: indexBuffer, indexBufferOffset: 0)
                
                textureId += 1
                id += 1
            }
        }

    }
    
    private func fillRandomValues() {
        for _ in 0..<1024 {
            randomValues.append(arc4random() % 1024)
        }
    }
    
    private func createSampler() {
        let sampleDescriptor = MTLSamplerDescriptor()
        sampleDescriptor.minFilter = .linear
        sampleDescriptor.magFilter = .linear
        
        sampler = Engine.device.makeSamplerState(descriptor: sampleDescriptor)
    }
    
    internal func createBuffers() {
        let storageOptions: MTLResourceOptions
        storageOptions = .storageModeShared
        
        self.materialBuffer = Engine.device.makeBuffer(bytes: &materials, length: Material.stride(materials.count), options: storageOptions)
        
        self.lightBuffer = Engine.device.makeBuffer(bytes: &PSLights, length: MemoryLayout<PSLight>.stride * lights.count, options: storageOptions)
    }
    
    func addSolid(solid: Solid) {
        for i in 0..<solid.mesh.submeshCount {
            materials.append(solid.mesh.materials[i])
            textures.append(TextureIds(baseColor: solid.mesh.textures[.baseColor]![i], normalMap: solid.mesh.textures[.objectSpaceNormal]![i], metallic: solid.mesh.textures[.metallic]![i], roughness: solid.mesh.textures[.roughness]![i], emission: solid.mesh.textures[.emission]![i]))
            if solid.mesh.materials[i].isLit {
                let light = Light(type: UInt32(LIGHT_TYPE_AREA), position: solid.position, forward: SIMD3<Float>(repeating: 1), right: SIMD3<Float>(repeating: 1), up: SIMD3<Float>(repeating: 1), color: solid.mesh.materials[i].emissive)
                lights.append(light)
                PSLights.append(PSLight(light: light, ambient: 0.1, diffuse: 0.1, specular: 0.1, brightness: 1.0))
            }
        }
        
        objects.append(solid)
    }
    
    internal func addLight(light: Light) {
        lights.append(light)
        PSLights.append(PSLight(light: light, ambient: 0.1, diffuse: 0.1, specular: 0.1, brightness: 1.0))
    }
}
