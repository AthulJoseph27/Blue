import MetalKit
import MetalPerformanceShaders
import simd
import os

class RayTracingRenderer: Renderer {
    var intersector: MPSRayIntersector!
    
    var rayBuffer:          MTLBuffer!
    var shadowRayBuffer:    MTLBuffer!
    var intersectionBuffer: MTLBuffer!
    
    var textureSampler : MTLSamplerState!
    
    var rayPipeline:        MTLComputePipelineState!
    var shadePipeline:      MTLComputePipelineState!
    var shadowPipeline:     MTLComputePipelineState!
    var accumulatePipeline: MTLComputePipelineState!
    var copyPipeline:       MTLRenderPipelineState!
    var renderPipeline:     MTLRenderPipelineState!
        
    var shadowWithAlphaTestingPipeline:     MTLComputePipelineState!
    
    var renderTarget:               MTLTexture!
    var accumulationTarget:         MTLTexture!
    var previousTexture:            MTLTexture!
    var previousDepthNormalTexture: MTLTexture!
    var shadowRayTexture:           MTLTexture!
    var shadowTexture:              MTLTexture!
    var intersectionTexture:        MTLTexture!
    var randomTexture:              MTLTexture!
    
    var semaphore: DispatchSemaphore!
    var size: CGSize!
    var threadsPerThreadgroup = MTLSizeMake(16, 16, 1)
    
    var lastCheckPoint = Date()
    var timeIntervals: [CFTimeInterval] = []
    
    var iterationCount = 0
    
    var scene: RTScene!
    
    private var _renderSettings: RayTracingSettings = RayTracingSettings(quality: .high, samples: 400, maxBounce: 6, alphaTesting: false, tileSize: MTLSize(width: 16, height: 16, depth: 1))
    
    override func initialize() {
        
        self.updateViewPort()
        self.createPipelines()
        self.createIntersector()
        
        semaphore = DispatchSemaphore(value: scene.renderOptions.maxFramesInFlight)
        
        let sampleDescriptor = MTLSamplerDescriptor()
        sampleDescriptor.minFilter = .linear
        sampleDescriptor.magFilter = .linear
        
        self.textureSampler = device.makeSamplerState(descriptor: sampleDescriptor)
    }
    
    override func onResume() {
        scene.frameIndex = 0
    }
    
    override func updateRenderSettings(settings: RenderingSettings) {
        scene.frameIndex = 0
        _renderSettings = (settings as? RayTracingSettings) ?? _renderSettings
    }
    
    override func updateViewPort() {
        if !(SceneManager.currentRenderableScene is RTScene) {
            fatalError("Renderer and ViewPort mismatch!")
        }
        
        scene = (SceneManager.currentRenderableScene as! RTScene)
    }
    
    override func renderModeInitialize() {
        iterationCount = 0
    }
    
    private func createPipelines() {
        rayPipeline = ComputePipelineStateLibrary.pipelineState(.GenerateRay).computePipelineState
        shadePipeline = ComputePipelineStateLibrary.pipelineState(.Shade).computePipelineState
        shadowPipeline = ComputePipelineStateLibrary.pipelineState(.Shadow).computePipelineState
        shadowWithAlphaTestingPipeline = ComputePipelineStateLibrary.pipelineState(.ShadowWithAlphaTesting).computePipelineState
        accumulatePipeline = ComputePipelineStateLibrary.pipelineState(.Accumulate).computePipelineState
        
        copyPipeline = RenderPipelineStateLibrary.pipelineState(.RayTracing)
        renderPipeline = RenderPipelineStateLibrary.pipelineState(.Rendering)
    }
    
    private func createIntersector() {
        intersector = MPSRayIntersector(device: device)
        intersector.rayDataType = .originMaskDirectionMaxDistance
        intersector.rayStride = scene.renderOptions.rayStride
        intersector.rayMaskOptions = scene.renderOptions.rayMaskOptions
    }
    
    override func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.size = size
        
        if size.width == 0 || size.height == 0 {
            return
        }
        
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.pixelFormat = .r16Float
        textureDescriptor.textureType = .type2D
        textureDescriptor.width =  Int(size.width)
        textureDescriptor.height = Int(size.height)
        textureDescriptor.usage = .shaderWrite
        shadowTexture = Engine.device.makeTexture(descriptor: textureDescriptor)

        lastCheckPoint = Date()
        timeIntervals.removeAll()


        let rayCount = Int(size.width * size.height)

        rayBuffer = device.makeBuffer(length: scene.renderOptions.rayStride * rayCount, options: .storageModePrivate)
        shadowRayBuffer = device.makeBuffer(length: scene.renderOptions.rayStride * rayCount, options: .storageModePrivate)
        intersectionBuffer = device.makeBuffer(length: scene.renderOptions.intersectionStride * rayCount, options: .storageModePrivate)

        let renderTargetDescriptor = MTLTextureDescriptor()
        renderTargetDescriptor.pixelFormat = .rgba32Float
        renderTargetDescriptor.textureType = .type2D
        renderTargetDescriptor.width =  Int(size.width)
        renderTargetDescriptor.height = Int(size.height)
        renderTargetDescriptor.storageMode = .shared
        renderTargetDescriptor.usage = [.shaderRead, .shaderWrite, .renderTarget]
        
        renderTarget = device.makeTexture(descriptor: renderTargetDescriptor)!
        accumulationTarget = device.makeTexture(descriptor: renderTargetDescriptor)!
        
        let randomTextureDescriptor = MTLTextureDescriptor()
        randomTextureDescriptor.pixelFormat = .r32Uint
        randomTextureDescriptor.textureType = .type2D
        randomTextureDescriptor.width =  Int(size.width)
        randomTextureDescriptor.height = Int(size.height)
        randomTextureDescriptor.usage = .shaderRead
        
        randomTexture = device.makeTexture(descriptor: randomTextureDescriptor)!
        
        var randomValues: [__uint32_t] = []
        
        for _ in 0..<(Int(size.width) * Int(size.height)) {
            randomValues.append(arc4random() % (1024 * 1024))
        }
        
        randomTexture.replace(region: MTLRegionMake2D(0, 0, Int(size.width), Int(size.height)), mipmapLevel: 0, withBytes: randomValues, bytesPerRow: MemoryLayout<__uint32_t>.size * Int(size.width))
        
        scene.frameIndex = 0
    }

    override func draw(in view: MTKView) {
        if size.width == 0 || size.height == 0 {
            return
        }
        
        semaphore.wait()
        
        // Rendering performance report
        if renderMode == .display {
            let now = Date()
            let timePassed = now.timeIntervalSince(lastCheckPoint)
            if timePassed > 1 {
                let totalPixels = Int(size.width * size.height) * timeIntervals.count
                let totalTime = timeIntervals.reduce(0, +)
                DispatchQueue.main.async { [unowned self] in
                    self.display(Double(totalPixels) / totalTime)
                }
                timeIntervals.removeAll()
                lastCheckPoint = now
            }
        } else {
            iterationCount += 1
            
            if iterationCount == 4 {
                // Textures initially are not loaded properly so skipping first few frames
                // else final image may have a tint of purple
                scene.frameIndex = 0
            }
            
            if iterationCount > (_renderSettings.samples + 6) {
                renderMode = .display
                RendererManager.onRenderingComplete()
            }
        }
        
        let desc = MTLCommandBufferDescriptor()
        desc.errorOptions = .encoderExecutionStatus

        let commandBuffer = Engine.commandQueue.makeCommandBuffer(descriptor: desc)!
        
        commandBuffer.addCompletedHandler { [unowned self] cb in
            let executionDuration = cb.gpuEndTime - cb.gpuStartTime
            self.timeIntervals.append(executionDuration)
            self.semaphore.signal()
        }
        
        
        if !(renderMode == .render && scene is DynamicRTScene) {
            SceneManager.tickScene(deltaTime: 1.0/Float(view.preferredFramesPerSecond))
        }
        
        scene.updateUniforms(size: view.drawableSize, renderQuality: _renderSettings.quality)
        
        let width = Int(size.width)
        let height = Int(size.height)
        let threadsPerGrid = MTLSizeMake(width, height, 1)

        generateRays(commandBuffer: commandBuffer, threadsPerGrid: threadsPerGrid)
        
        let maxBounce = _renderSettings.maxBounce
        
        for i in 0..<maxBounce {
            reflectRays(bounce: i, commandBuffer: commandBuffer, threadsPerGrid: threadsPerGrid)
            
            if !(scene is DynamicRTScene) && _renderSettings.alphaTesting {
                traceShadowsWithAlphaTesting(commandBuffer: commandBuffer, threadsPerGrid: threadsPerGrid)
            } else {
                traceShadows(commandBuffer: commandBuffer, threadsPerGrid: threadsPerGrid)
            }
        }
        
        denoiseFrame(commandBuffer: commandBuffer, threadsPerGrid: threadsPerGrid)
        
        if let renderPassDescriptor = view.currentRenderPassDescriptor {
            guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
            renderEncoder.setRenderPipelineState(copyPipeline)
            renderEncoder.setFragmentTexture(accumulationTarget, index: 0)
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
            renderEncoder.endEncoding()
            guard let drawable = view.currentDrawable else { return }
            if renderMode == .render {
                self.renderedTexture = view.currentDrawable?.texture
            }
            commandBuffer.present(drawable)
        }
        
        
        commandBuffer.commit()
        
        if let error = commandBuffer.error as NSError? {
            
            if let encoderInfos = error.userInfo[MTLCommandBufferEncoderInfoErrorKey] as? [MTLCommandBufferEncoderInfo] {
                
                for info in encoderInfos {
                    print(info.label + info.debugSignposts.joined())
                    if info.errorState == .faulted {
                        print(info.label + "faulted!")
                    }
                }
            }
        }
    }
    
    private func generateRays(commandBuffer: MTLCommandBuffer, threadsPerGrid: MTLSize) {
        let computeEncoder = commandBuffer.makeComputeCommandEncoder()!

        computeEncoder.setBuffer(scene.uniformBuffer, offset: scene.uniformBufferOffset, index: 0)
        computeEncoder.setBuffer(rayBuffer, offset: 0, index: 1)

        computeEncoder.setTexture(randomTexture, index: 0)
        computeEncoder.setTexture(renderTarget, index: 1)

        computeEncoder.setComputePipelineState(rayPipeline)

        
        computeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: _renderSettings.tileSize)

        computeEncoder.endEncoding()
    }
    
    private func reflectRays(bounce: Int, commandBuffer: MTLCommandBuffer, threadsPerGrid: MTLSize) {
        intersector.intersectionDataType = scene.renderOptions.intersectionDataType

        intersector.encodeIntersection(commandBuffer: commandBuffer,
                                       intersectionType: .nearest,
                                       rayBuffer: rayBuffer,
                                       rayBufferOffset: 0,
                                       intersectionBuffer: intersectionBuffer,
                                       intersectionBufferOffset: 0,
                                       rayCount: Int(size.width * size.height),
                                       accelerationStructure: scene.getAccelerationStructure())
        guard let shadeEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
        
        let buffers = [scene.uniformBuffer, scene.lightBuffer, rayBuffer, shadowRayBuffer, intersectionBuffer, scene.vertexBuffer, scene.customIndexBuffer, scene.verticesCountBuffer, scene.indiciesCountBuffer, scene.maskBuffer, scene.materialBuffer, scene.textureIdBuffer, scene.textureBuffer]
        let offsets: [Int] = [scene.uniformBufferOffset, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        
        shadeEncoder.useHeap(scene.heap.heap)
        shadeEncoder.setBuffers(buffers, offsets: offsets, range: 0..<buffers.count)
    
        var _bounce = UInt32(bounce)
        shadeEncoder.setBytes(&_bounce, length: UInt32.size, index: buffers.count)
        
        shadeEncoder.setTexture(randomTexture, index: 0)
        shadeEncoder.setTexture(renderTarget, index: 1)
        shadeEncoder.setTexture(scene.skyBox, index: 2)
        
        shadeEncoder.setSamplerState(textureSampler, index: 0)
        shadeEncoder.setComputePipelineState(shadePipeline)
        shadeEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: _renderSettings.tileSize)
        shadeEncoder.endEncoding()
    }
    
    private func traceShadows(commandBuffer: MTLCommandBuffer, threadsPerGrid: MTLSize) {
        intersector.intersectionDataType = .distance
        intersector.encodeIntersection(commandBuffer: commandBuffer,
                                       intersectionType: .any,
                                       rayBuffer: shadowRayBuffer,
                                       rayBufferOffset: 0,
                                       intersectionBuffer: intersectionBuffer,
                                       intersectionBufferOffset: 0,
                                       rayCount: Int(size.width * size.height),
                                       accelerationStructure: scene.getAccelerationStructure())

        guard let colorEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
        colorEncoder.setBuffer(scene.uniformBuffer, offset: scene.uniformBufferOffset, index: 0)
        colorEncoder.setBuffer(shadowRayBuffer, offset: 0, index: 1)
        colorEncoder.setBuffer(intersectionBuffer, offset: 0, index: 2)

        colorEncoder.setTexture(renderTarget, index: 0)
        colorEncoder.setTexture(shadowTexture, index: 1)
        colorEncoder.setComputePipelineState(shadowPipeline)
        
        colorEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: _renderSettings.tileSize)
        colorEncoder.endEncoding()
    }
    
    private func traceShadowsWithAlphaTesting(commandBuffer: MTLCommandBuffer, threadsPerGrid: MTLSize) {
        
        guard let colorEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
        colorEncoder.setAccelerationStructure(scene.getMTLAccelerationStructure(), bufferIndex: 0)
        colorEncoder.setBuffer(scene.uniformBuffer, offset: scene.uniformBufferOffset, index: 1)
        colorEncoder.setBuffer(shadowRayBuffer, offset: 0, index: 2)
        colorEncoder.setBuffer(scene.vertexBuffer, offset: 0, index: 3)
        colorEncoder.setBuffer(scene.customIndexBuffer, offset: 0, index: 4)
        colorEncoder.setBuffer(scene.verticesCountBuffer, offset: 0, index: 5)
        colorEncoder.setBuffer(scene.indiciesCountBuffer, offset: 0, index: 6)
        colorEncoder.setBuffer(scene.materialBuffer, offset: 0, index: 7)
        colorEncoder.setBuffer(scene.textureIdBuffer, offset: 0, index: 8)
        colorEncoder.setBuffer(scene.textureBuffer, offset: 0, index: 9)

        colorEncoder.setTexture(renderTarget, index: 0)
        colorEncoder.setTexture(shadowTexture, index: 1)
        colorEncoder.setComputePipelineState(shadowWithAlphaTestingPipeline)
        
        colorEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: _renderSettings.tileSize)
        colorEncoder.endEncoding()
    }
    
    private func denoiseFrame(commandBuffer: MTLCommandBuffer, threadsPerGrid: MTLSize) {
        if (renderMode != .render) && (scene is DynamicRTScene) {
            accumulationTarget = renderTarget
            return
        }
        
        guard let denoiseEncoder = commandBuffer.makeComputeCommandEncoder() else { return }
        denoiseEncoder.setBuffer(scene.uniformBuffer, offset: scene.uniformBufferOffset, index: 0)

        denoiseEncoder.setTexture(renderTarget, index: 0)
        denoiseEncoder.setTexture(accumulationTarget, index: 1)
        
        denoiseEncoder.setComputePipelineState(accumulatePipeline)
        denoiseEncoder.dispatchThreads(threadsPerGrid, threadsPerThreadgroup: _renderSettings.tileSize)
        denoiseEncoder.endEncoding()
    }
}
