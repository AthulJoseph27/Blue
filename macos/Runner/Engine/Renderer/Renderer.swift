import MetalKit
import os

class Renderer: NSObject, MTKViewDelegate {
    public static var screenSize = SIMD2<Float>(repeating: 0)
    public var renderedTexture: MTLTexture?
    public var renderMode: RenderMode
    public var renderQuality: RenderQuality
//    private var renderingSettings: RenderingSettings?
    private let view: MTKView
    private let queue: MTLCommandQueue
    private let library: MTLLibrary
    private var renderPassDescriptor: MTLRenderPassDescriptor!
    
    internal let display: (Double) -> Void
    internal let device: MTLDevice
    
    init(withMetalKitView view: MTKView, displayCounter: @escaping (Double) -> Void) throws {
        display = displayCounter
        self.view = view
        self.device = Engine.device
        os_log("Metal device name is %s", device.name)
        
        self.library = Engine.defaultLibrary
        self.queue = Engine.commandQueue
        self.renderMode = .display
        self.renderQuality = .medium
        super.init()
        initialize()
    }
    
    func initialize() {
        updateScreenSize(view: view)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {}
    
    func renderModeInitialize() {}
    
    func updateViewPort() {}
    
    func updateScene(sceneType: GameScenes) {
        updateViewPort()
    }
    
    func onResume() {}
    
    func switchToRenderMode(settings: RenderingSettings) {
        view.isPaused = true
        updateRenderSettings(settings: settings)
        renderMode = .render
        renderModeInitialize()
        view.isPaused = false
    }
    
    func switchToDisplayMode(settings: RenderingSettings) {
//        view.isPaused = true
        updateRenderSettings(settings: settings)
        renderMode = .display
        CameraManager.unlockCamera()
    }
    
    func updateRenderSettings(settings: RenderingSettings) {}
    
    func updateScreenSize(view: MTKView) {
        Renderer.screenSize = SIMD2<Float>(Float(view.bounds.width),Float(view.bounds.height))
    }
}
