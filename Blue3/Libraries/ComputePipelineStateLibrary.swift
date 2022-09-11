import MetalKit

enum ComputePipelineStateTypes {
    case GenerateRay
    case Shade
    case Shadow
    case Accumulate
}

class ComputePipelineStateLibrary {
    private static var computePipelineStates: [ComputePipelineStateTypes : ComputePipelineState] = [:]

    public static func initialize() {
        createComputePipelineState()
    }

    public static func createComputePipelineState() {
        computePipelineStates.updateValue(RayTracing_ComputePipelineState(), forKey: .GenerateRay)
        computePipelineStates.updateValue(Shade_ComputePipelineState(), forKey: .Shade)
        computePipelineStates.updateValue(Shadow_ComputePipelineState(), forKey: .Shadow)
        computePipelineStates.updateValue(Accumulate_ComputePipelineState(), forKey: .Accumulate)
    }

    public static func pipelineState(_ computePipelineStateTypes: ComputePipelineStateTypes)->ComputePipelineState {
        return computePipelineStates[computePipelineStateTypes]!
    }
}

protocol ComputePipelineState {
    var name: String { get }
    var computePipelineState: MTLComputePipelineState! { get }
}


public struct RayTracing_ComputePipelineState: ComputePipelineState {
    var name: String = "Ray Tracing Compute Pipeline State"
    var computePipelineState: MTLComputePipelineState!
    
    init() {
        do{
            ComputePipelineDescriptorLibrary.descriptor(.RayTracing).computeFunction = Engine.defaultLibrary.makeFunction(name: "rayKernel")
            computePipelineState = try Engine.device.makeComputePipelineState(descriptor: ComputePipelineDescriptorLibrary.descriptor(.RayTracing), options: [], reflection: nil)
        }catch let error as NSError{
            print("ERROR::CREATE::COMPUTE_PIPELINE_STATE::__\(name)__::\(error)")
            return;
        }
    }
}

public struct Shade_ComputePipelineState: ComputePipelineState {
    var name: String = "Shade Compute Pipeline State"
    var computePipelineState: MTLComputePipelineState!
    
    init() {
        do{
            ComputePipelineDescriptorLibrary.descriptor(.RayTracing).computeFunction = Engine.defaultLibrary.makeFunction(name: "shadeKernel")
            computePipelineState = try Engine.device.makeComputePipelineState(descriptor: ComputePipelineDescriptorLibrary.descriptor(.RayTracing), options: [], reflection: nil)
        }catch let error as NSError{
            print("ERROR::CREATE::COMPUTE_PIPELINE_STATE::__\(name)__::\(error)")
            return;
        }
    }
}

public struct Shadow_ComputePipelineState: ComputePipelineState {
    var name: String = "Shadow Tracing Compute Pipeline State"
    var computePipelineState: MTLComputePipelineState!
    
    init() {
        do{
            ComputePipelineDescriptorLibrary.descriptor(.RayTracing).computeFunction = Engine.defaultLibrary.makeFunction(name: "shadowKernel")
            computePipelineState = try Engine.device.makeComputePipelineState(descriptor: ComputePipelineDescriptorLibrary.descriptor(.RayTracing), options: [], reflection: nil)
        }catch let error as NSError{
            print("ERROR::CREATE::COMPUTE_PIPELINE_STATE::__\(name)__::\(error)")
            return;
        }
    }
}

public struct Accumulate_ComputePipelineState: ComputePipelineState {
    var name: String = "Accumulate Tracing Compute Pipeline State"
    var computePipelineState: MTLComputePipelineState!
    
    init() {
        do{
            ComputePipelineDescriptorLibrary.descriptor(.RayTracing).computeFunction = Engine.defaultLibrary.makeFunction(name: "accumulateKernel")
            computePipelineState = try Engine.device.makeComputePipelineState(descriptor: ComputePipelineDescriptorLibrary.descriptor(.RayTracing), options: [], reflection: nil)
        }catch let error as NSError{
            print("ERROR::CREATE::COMPUTE_PIPELINE_STATE::__\(name)__::\(error)")
            return;
        }
    }
}
