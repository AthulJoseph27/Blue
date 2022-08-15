import MetalKit

enum RenderPipelineDescriptorTypes {
    case Basic
    case Instanced
}

class RenderPipelineDescriptorLibrary {
    private static var renderPipelineDescriptors: [RenderPipelineDescriptorTypes : RenderPipelineDescriptor] = [:]
    
    public static func initialize() {
        createRenderPipelineDescriptor()
    }
    
    public static func createRenderPipelineDescriptor() {
        renderPipelineDescriptors.updateValue(Basic_RenderPipelineDescriptor(), forKey: .Basic)
        renderPipelineDescriptors.updateValue(Instanced_RenderPipelineDescriptor(), forKey: .Instanced)
    }
    
    public static func descriptor(_ renderPipelineDescriptorTypes: RenderPipelineDescriptorTypes)->MTLRenderPipelineDescriptor {
        return renderPipelineDescriptors[renderPipelineDescriptorTypes]!.renderPipelineDescriptor
    }
}

protocol RenderPipelineDescriptor {
    var name: String { get }
    var renderPipelineDescriptor: MTLRenderPipelineDescriptor! { get }
}

public struct Basic_RenderPipelineDescriptor: RenderPipelineDescriptor {
    var name: String = "Baisc Render Pipeline Descriptor"
    var renderPipelineDescriptor: MTLRenderPipelineDescriptor!
    
    init() {
        renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.MainPixelFormat
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.MainDepthPixelFormat
        renderPipelineDescriptor.vertexFunction = ShaderLibrary.Vertex(.Basic)
        renderPipelineDescriptor.fragmentFunction = ShaderLibrary.Fragment(.Basic)
        renderPipelineDescriptor.vertexDescriptor = VertexDescriptorLibrary.descriptor(.Basic)
    }
}

public struct Instanced_RenderPipelineDescriptor: RenderPipelineDescriptor {
    var name: String = "Instanced Render Pipeline Descriptor"
    var renderPipelineDescriptor: MTLRenderPipelineDescriptor!
    
    init() {
        renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = Preferences.MainPixelFormat
        renderPipelineDescriptor.depthAttachmentPixelFormat = Preferences.MainDepthPixelFormat
        renderPipelineDescriptor.vertexFunction = ShaderLibrary.Vertex(.Instanced)
        renderPipelineDescriptor.fragmentFunction = ShaderLibrary.Fragment(.Basic)
        renderPipelineDescriptor.vertexDescriptor = VertexDescriptorLibrary.descriptor(.Basic)
    }
}
