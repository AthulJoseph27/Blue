import MetalKit

enum ComputePipelineStateTypes {
    case Transform
    case IndexGenerator
    case IndexWrapper
    case GenerateRay
    case Shade
    case Shadow
    case ShadowWithAlphaTesting
    case Accumulate
}

class ComputePipelineStateLibrary {
    private static var computePipelineStates: [ComputePipelineStateTypes : ComputePipelineState] = [:]
    private static var functions: [MTLFunction] = []

    public static func initialize() {
        createComputePipelineState()
    }

    public static func createComputePipelineState() {
        computePipelineStates.updateValue(Transform_ComputePipelineState(), forKey: .Transform)
        computePipelineStates.updateValue(IndexGenerator_ComputePipelineState(), forKey: .IndexGenerator)
        computePipelineStates.updateValue(IndexWrapper_ComputePipelineState(), forKey: .IndexWrapper)
        computePipelineStates.updateValue(RayTracing_ComputePipelineState(), forKey: .GenerateRay)
        computePipelineStates.updateValue(Shade_ComputePipelineState(), forKey: .Shade)
        computePipelineStates.updateValue(Shadow_ComputePipelineState(), forKey: .Shadow)
        computePipelineStates.updateValue(ShadowWithAlphaTesting_ComputePipelineState(), forKey: .ShadowWithAlphaTesting)
        computePipelineStates.updateValue(Accumulate_ComputePipelineState(), forKey: .Accumulate)
    }

    public static func pipelineState(_ computePipelineStateTypes: ComputePipelineStateTypes)->ComputePipelineState {
        return computePipelineStates[computePipelineStateTypes]!
    }
    
    public static func getIntersectionFunctions() -> [MTLFunction] {
        return functions
    }
    
    public static func addIntersectionFunction(function: MTLFunction) {
        functions.append(function)
    }
}

protocol ComputePipelineState {
    var name: String { get }
    var computePipelineState: MTLComputePipelineState! { get }
}

public struct Transform_ComputePipelineState: ComputePipelineState {
    var name: String = "Transform Compute Pipeline State"
    var computePipelineState: MTLComputePipelineState!
    
    init() {
        do{
            ComputePipelineDescriptorLibrary.descriptor(.Transform).computeFunction = Engine.defaultLibrary.makeFunction(name: "transformKernel")
            computePipelineState = try Engine.device.makeComputePipelineState(descriptor: ComputePipelineDescriptorLibrary.descriptor(.Transform), options: [], reflection: nil)
        }catch let error as NSError{
            print("ERROR::CREATE::COMPUTE_PIPELINE_STATE::__\(name)__::\(error)")
            return;
        }
    }
}

public struct IndexGenerator_ComputePipelineState: ComputePipelineState {
    var name: String = "IndexGenerator Compute Pipeline State"
    var computePipelineState: MTLComputePipelineState!
    
    init() {
        do{
            ComputePipelineDescriptorLibrary.descriptor(.IndexGenerator).computeFunction = Engine.defaultLibrary.makeFunction(name: "indexGeneratorKernel")
            computePipelineState = try Engine.device.makeComputePipelineState(descriptor: ComputePipelineDescriptorLibrary.descriptor(.IndexGenerator), options: [], reflection: nil)
        }catch let error as NSError{
            print("ERROR::CREATE::COMPUTE_PIPELINE_STATE::__\(name)__::\(error)")
            return;
        }
    }
}

public struct IndexWrapper_ComputePipelineState: ComputePipelineState {
    var name: String = "IndexWrapper Compute Pipeline State"
    var computePipelineState: MTLComputePipelineState!
    
    init() {
        do{
            ComputePipelineDescriptorLibrary.descriptor(.IndexWrapper).computeFunction = Engine.defaultLibrary.makeFunction(name: "indexWrapperKernel")
            computePipelineState = try Engine.device.makeComputePipelineState(descriptor: ComputePipelineDescriptorLibrary.descriptor(.IndexWrapper), options: [], reflection: nil)
        }catch let error as NSError{
            print("ERROR::CREATE::COMPUTE_PIPELINE_STATE::__\(name)__::\(error)")
            return;
        }
    }
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

public struct ShadowWithAlphaTesting_ComputePipelineState: ComputePipelineState {
    var name: String = "Shadow Tracing With Alpha Testing Compute Pipeline State"
    var computePipelineState: MTLComputePipelineState!
    
    init() {
        do{
            ComputePipelineDescriptorLibrary.descriptor(.RayTracing).computeFunction = Engine.defaultLibrary.makeFunction(name: "shadowKernelWithAlphaTesting")
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
