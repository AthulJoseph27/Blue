import MetalKit

enum RenderPipelineStateTypes {
    case Basic
    case RayTracing
    case Rendering
}

class RenderPipelineStateLibrary {
    private static var renderPipelineStates: [RenderPipelineStateTypes : RenderPipelineState] = [:]
    
    public static func initialize() {
        createRenderPipelineState()
    }
    
    public static func createRenderPipelineState() {
        renderPipelineStates.updateValue(Basic_RenderPipelineState(), forKey: .Basic)
        renderPipelineStates.updateValue(RayTracing_RenderPipelineState(), forKey: .RayTracing)
        renderPipelineStates.updateValue(OffScreen_RenderPipelineState(), forKey: .Rendering)
    }
    
    public static func addRenderPipelineState(_ renderPipeLineState: RenderPipelineState, renderPipelineStateType: RenderPipelineStateTypes) {
        renderPipelineStates.updateValue(renderPipeLineState, forKey: renderPipelineStateType)
    }
    
    public static func pipelineState(_ renderPipelineStateTypes: RenderPipelineStateTypes)->MTLRenderPipelineState {
        return renderPipelineStates[renderPipelineStateTypes]!.renderPipelineState
    }
}

protocol RenderPipelineState {
    var name: String { get }
    var renderPipelineState: MTLRenderPipelineState! { get }
}

public struct Basic_RenderPipelineState: RenderPipelineState {
    var name: String = "Baisc Render Pipeline State"
    var renderPipelineState: MTLRenderPipelineState!
    
    init() {
        do{
            renderPipelineState = try Engine.device.makeRenderPipelineState(descriptor: RenderPipelineDescriptorLibrary.descriptor(.Basic))
        }catch let error as NSError{
            print("ERROR::CREATE::RENDER_PIPELINE_STATE::__\(name)__::\(error)")
        }
    }
}

public struct RayTracing_RenderPipelineState: RenderPipelineState {
    var name: String = "Ray Tracing Render Pipeline State"
    var renderPipelineState: MTLRenderPipelineState!
    
    init() {
        do{
            renderPipelineState = try Engine.device.makeRenderPipelineState(descriptor: RenderPipelineDescriptorLibrary.descriptor(.RayTracing))
        }catch let error as NSError{
            print("ERROR::CREATE::RENDER_PIPELINE_STATE::__\(name)__::\(error)")
        }
    }
}

public struct OffScreen_RenderPipelineState: RenderPipelineState {
    var name: String = "OffScreen Render Pipeline State"
    var renderPipelineState: MTLRenderPipelineState!
    
    init() {
        do{
            renderPipelineState = try Engine.device.makeRenderPipelineState(descriptor: RenderPipelineDescriptorLibrary.descriptor(.Rendering))
        }catch let error as NSError{
            print("ERROR::CREATE::RENDER_PIPELINE_STATE::__\(name)__::\(error)")
        }
    }
}
