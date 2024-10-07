import MetalKit
import MetalPerformanceShaders

enum ComputePipelineDescriptorTypes {
    case Transform
    case IndexGenerator
    case IndexWrapper
    case RayTracing
}

class ComputePipelineDescriptorLibrary {
    private static var computePipelineDescriptors: [ComputePipelineDescriptorTypes : ComputePipelineDescriptor] = [:]
    
    public static func initialize() {
        createComputePipelineDescriptor()
    }
    
    public static func createComputePipelineDescriptor() {
        computePipelineDescriptors.updateValue(Transform_ComputePipelineDescriptor(), forKey: .Transform)
        computePipelineDescriptors.updateValue(IndexGenerator_ComputePipelineDescriptor(), forKey: .IndexGenerator)
        computePipelineDescriptors.updateValue(IndexWrapper_ComputePipelineDescriptor(), forKey: .IndexWrapper)
        computePipelineDescriptors.updateValue(RayTracing_ComputePipelineDescriptor(), forKey: .RayTracing)
    }
    
    public static func descriptor(_ computePipelineDescriptorTypes: ComputePipelineDescriptorTypes)->MTLComputePipelineDescriptor {
        return computePipelineDescriptors[computePipelineDescriptorTypes]!.computePipelineDescriptor
    }
}

protocol ComputePipelineDescriptor {
    var name: String { get }
    var computePipelineDescriptor: MTLComputePipelineDescriptor! { get }
}

public struct Transform_ComputePipelineDescriptor: ComputePipelineDescriptor {
    var name: String = "Transform Pipeline Descriptor"
    var computePipelineDescriptor: MTLComputePipelineDescriptor!
    
    init() {
        computePipelineDescriptor = MTLComputePipelineDescriptor()
        computePipelineDescriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
    }
}

public struct IndexGenerator_ComputePipelineDescriptor: ComputePipelineDescriptor {
    var name: String = "Index Generator Pipeline Descriptor"
    var computePipelineDescriptor: MTLComputePipelineDescriptor!
    
    init() {
        computePipelineDescriptor = MTLComputePipelineDescriptor()
        computePipelineDescriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
    }
}

public struct IndexWrapper_ComputePipelineDescriptor: ComputePipelineDescriptor {
    var name: String = "Index Wrapper Pipeline Descriptor"
    var computePipelineDescriptor: MTLComputePipelineDescriptor!
    
    init() {
        computePipelineDescriptor = MTLComputePipelineDescriptor()
        computePipelineDescriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
    }
}

public struct RayTracing_ComputePipelineDescriptor: ComputePipelineDescriptor {
    var name: String = "RayTracing Compute Pipeline Descriptor"
    var computePipelineDescriptor: MTLComputePipelineDescriptor!
    
    init() {
        computePipelineDescriptor = MTLComputePipelineDescriptor()
        computePipelineDescriptor.threadGroupSizeIsMultipleOfThreadExecutionWidth = true
    }
}
