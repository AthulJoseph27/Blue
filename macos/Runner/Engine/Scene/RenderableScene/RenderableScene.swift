import simd
import MetalKit
import MetalPerformanceShaders

protocol RenderableScene {
    
    var heap:          Heap         { get set }
    var objects:       [Solid]      { get set }
    var lights:        [Light]      { get set }
    var textureBuffer: MTLBuffer!   { get set }
    var skyBox:        MTLTexture!  { get set }
    var sceneTime:     Float        { get set }
    
    var ambient: Float { get set }
    
    func updateScene(time: Float?)
    
    func createBuffers()
    
    func addSolid(solid: Solid)
    
    func addLight(light: Light)
    
    func updateSceneSettings(sceneSettings: SceneSettings)
    
    func postSceneLightSet()
}

extension RenderableScene {
    func updateCameras(deltaTime: Float) {
        CameraManager.update(deltaTime: deltaTime)
    }
    
    func buildScene(scene: GameScene) {
        for solid in scene.solids {
            addSolid(solid: solid)
        }
        
        for light in scene.lights {
            addLight(light: light)
        }
    }
    
    mutating func tickScene(deltaTime: Float) {
        sceneTime += deltaTime
    }
    
    mutating func updateSceneLights(lights: [Light]) {
        self.lights = lights
        postSceneLightSet()
    }
}

protocol RTScene: RenderableScene {
    var renderOptions: RTRenderOptions { get set }
    
    var masks:        [uint]     { get set }
    var materials:    [Material] { get set }
    var textures:     [TextureIds] { get set }
    
    var vertexBuffer:        MTLBuffer! { get set }
    var indexBuffer:         MTLBuffer! { get set }
    var customIndexBuffer:   MTLBuffer! { get set }
    var verticesCountBuffer: MTLBuffer! { get set }
    var indiciesCountBuffer: MTLBuffer! { get set }
    var maskBuffer:          MTLBuffer! { get set }
    
    var lightBuffer:         MTLBuffer! { get set }
    var materialBuffer:      MTLBuffer! { get set }
    var textureIdBuffer:     MTLBuffer! { get set }
    var uniformBuffer:       MTLBuffer! { get set }
    var transformBuffer:     MTLBuffer! { get set }
    
    var uniformBufferOffset: Int!   { get set }
    var uniformBufferIndex: Int     { get set }
    
    var indexWrapperPipeline:       MTLComputePipelineState! { get set }
    
    func getAccelerationStructure() -> MPSAccelerationStructure
    func getMTLAccelerationStructure() -> MTLAccelerationStructure
    
    func advanceFrame() -> Void
    
    var frameIndex: UInt32          { get set }
    var lightIndex: UInt32          { get set }
    
    var uniforms: Uniforms?         { get set }
    var prevUniforms: Uniforms?     { get set }
}

extension RTScene {
    
    mutating func updateUniforms(size: CGSize, renderQuality: RenderQuality? = .high) {
        prevUniforms = uniforms
        
        uniformBufferOffset = renderOptions.alignedUniformsSize * uniformBufferIndex
        
        let uniformsPointer = uniformBuffer.contents().advanced(by: uniformBufferOffset)
        let _uniforms = uniformsPointer.bindMemory(to: Uniforms.self, capacity: 1)
        
        switch(renderQuality) {
            case .high:
                _uniforms.pointee.qualityControll = 1
                break
            case .medium:
                _uniforms.pointee.qualityControll = 19
                break
            case .low:
                _uniforms.pointee.qualityControll = 67
                break
            case .none:
                assert(false)
        }
        
        let currentCam = CameraManager.currentCamera!
        _uniforms.pointee.camera.position = currentCam.position + currentCam.deltaPosition
        _uniforms.pointee.camera.focalLength = currentCam.focalLength
        _uniforms.pointee.camera.dofBlurStrength = currentCam.dofBlurStrength
        
        if  abs(currentCam.deltaPosition.x) > 0 ||
            abs(currentCam.deltaPosition.y) > 0 ||
            abs(currentCam.deltaPosition.z) > 0 {
            CameraManager.currentCamera!.position += currentCam.deltaPosition
            CameraManager.currentCamera!.deltaPosition = SIMD3<Float>(repeating: 0)
            frameIndex = 0
        }
        
        // rotating camera x and z w.r.t y
        var transform = matrix_identity_float4x4
        transform.rotate(angle: currentCam.rotation.y + currentCam.deltaRotation.y, axis: SIMD3<Float>(0, 1, 0))
        transform.rotate(angle: currentCam.rotation.x + currentCam.deltaRotation.x, axis: SIMD3<Float>(1, 0, 0))
        transform.rotate(angle: currentCam.rotation.z + currentCam.deltaRotation.z, axis: SIMD3<Float>(0, 0, 1))
        
        if  abs(currentCam.deltaRotation.x) > 0 ||
            abs(currentCam.deltaRotation.y) > 0 ||
            abs(currentCam.deltaRotation.z) > 0 {
            CameraManager.currentCamera!.rotation += currentCam.deltaRotation
            CameraManager.currentCamera!.deltaRotation = SIMD3<Float>(repeating: 0)
            frameIndex = 0
        }
        
        
        let newForward = transform * SIMD4<Float>(0, 0, -1, 1)
        let newRigth = transform * SIMD4<Float>(1, 0, 0, 1)
        let newUp = transform * SIMD4<Float>(0, 1, 0, 1)
        
        _uniforms.pointee.camera.forward = SIMD3<Float>(newForward.x, newForward.y, newForward.z)
        _uniforms.pointee.camera.right = SIMD3<Float>(newRigth.x, newRigth.y, newRigth.z)
        _uniforms.pointee.camera.up = SIMD3<Float>(newUp.x, newUp.y, newUp.z)
        
        _uniforms.pointee.lightCount = UInt32(lights.count)
        _uniforms.pointee.lightIndex = lightIndex
        lightIndex = (lightIndex + 1) % UInt32(lights.count)
        
        _uniforms.pointee.ambient = ambient

        let fieldOfView = 45.0 * (Float.pi / 180.0)
        let aspectRatio = Float(size.width) / Float(size.height)
        let imagePlaneHeight = tanf(fieldOfView / 2.0)
        let imagePlaneWidth = aspectRatio * imagePlaneHeight

        _uniforms.pointee.camera.right *= imagePlaneWidth
        _uniforms.pointee.camera.up *= imagePlaneHeight

        _uniforms.pointee.width = UInt32(size.width)
        _uniforms.pointee.height = UInt32(size.height)

        _uniforms.pointee.blocksWide = (_uniforms.pointee.width + 15) / 16
        _uniforms.pointee.frameIndex = frameIndex
        
        let position = currentCam.position
//        let right = _uniforms.pointee.camera.right
        let up = _uniforms.pointee.camera.up

        let forward = _uniforms.pointee.camera.forward
        let target = normalize(forward - position)
                
        let viewMatrix = matrix_float4x4.lookAt(position: position, target: target, up: up)
        
        var projectionMatrix = matrix_float4x4.perspective(fieldOfView: fieldOfView, aspectRatio: aspectRatio, nearZ: 0.1, farZ: 1000.0)
        
        let jitter = (haltonSamples[Int(frameIndex) % 16] * 2.0 - 1.0) / SIMD2<Float>(Float(size.width), Float(size.height))
        
        _uniforms.pointee.jitter = jitter * vector2(0.5, -0.5)
        
        projectionMatrix.columns.2.x += jitter.x
        projectionMatrix.columns.2.y += jitter.y
        
        let viewProjectionMatrix = projectionMatrix * viewMatrix
        
        _uniforms.pointee.viewMatrix = viewMatrix
        _uniforms.pointee.viewProjectionMatrix = viewProjectionMatrix;
        
        frameIndex += 1
        
        uniforms = _uniforms.pointee
        
        advanceFrame()

        uniformBufferIndex = (uniformBufferIndex + 1) % renderOptions.maxFramesInFlight
    }
    
    mutating func setTexture(index: Int, texture: TextureIds) {
        textures[index] = texture
    }
    
    func wrapIndexBuffer(indexBuffer: inout MTLBuffer, keepOriginalIndex: Bool = false, indexOffset: UInt32, submeshId: UInt32)->MTLBuffer {
        let commandBuffer = Engine.commandQueue.makeCommandBuffer()!
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()!
        
        let storageOptions: MTLResourceOptions
        storageOptions = .storageModeShared
        
        var vertexCount = indexBuffer.length / UInt32.stride
        
        let newIndexBuffer = Engine.device.makeBuffer(length: VertexIndex.stride(vertexCount), options: storageOptions)
        
        var sId = submeshId
        var iOffset = indexOffset
        
        var w = indexWrapperPipeline.threadExecutionWidth
        
        if(keepOriginalIndex) {
            computeEncoder.setBuffer(indexBuffer, offset: 0, index: 0)
            computeEncoder.setBuffer(newIndexBuffer, offset: 0, index: 1)
            computeEncoder.setBytes(&sId, length: UInt32.stride, index: 2)
            computeEncoder.setBytes(&vertexCount, length: UInt32.stride, index: 3)
            computeEncoder.setBytes(&w, length: UInt32.size, index: 4)
        } else {
            computeEncoder.setBuffer(newIndexBuffer, offset: 0, index: 0)
            computeEncoder.setBytes(&iOffset, length: UInt32.stride, index: 1)
            computeEncoder.setBytes(&sId, length: UInt32.stride, index: 2)
            computeEncoder.setBytes(&vertexCount, length: UInt32.stride, index: 3)
            computeEncoder.setBytes(&w, length: UInt32.size, index: 4)
        }
        
        computeEncoder.setComputePipelineState(indexWrapperPipeline)
        
        let threadsPerThreadgroup = MTLSizeMake(w, 1, 1)
        let threadsPerGrid = MTLSizeMake(vertexCount, 1, 1)
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        
        computeEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        return newIndexBuffer!
    }
    
    func mergeBuffers(buffers: [MTLBuffer], blitEncoder: MTLBlitCommandEncoder?)->MTLBuffer? {
        
        var length = 0
        
        for buffer in buffers {
            length += buffer.length
        }
        
        let mergedBuffer = Engine.device.makeBuffer(length: length, options: .storageModeShared)
        
        if mergedBuffer == nil {
            print("Failed to create new buffer ⚠️⚠️⚠️")
            return nil
        }
        
        var destinationOffset = 0
        
        for buffer in buffers {
            blitEncoder?.copy(from: buffer, sourceOffset: 0, to: mergedBuffer!, destinationOffset: destinationOffset, size: buffer.length)
            destinationOffset += buffer.length
        }
        
        return mergedBuffer
    }
}
