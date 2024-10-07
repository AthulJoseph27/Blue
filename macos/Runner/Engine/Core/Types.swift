import simd
import CoreImage
import MetalPerformanceShaders

protocol sizeable {}
extension sizeable {
    static var size: Int{
        return MemoryLayout<Self>.size
    }
    
    static var stride: Int {
        return MemoryLayout<Self>.stride
    }
    
    static func size(_ count: Int)->Int {
        return MemoryLayout<Self>.size * count
    }
    
    static func stride(_ count: Int)->Int {
        return MemoryLayout<Self>.stride * count
    }
}

extension uint:  sizeable {}
extension Int32: sizeable {}
extension Float: sizeable {}
extension SIMD2: sizeable {}
extension SIMD3: sizeable {}
extension SIMD4: sizeable {}
extension matrix_float4x4: sizeable {}
extension matrix_float3x3: sizeable {}
extension MPSIntersectionDistancePrimitiveIndexCoordinates: sizeable {}

struct Vertex: sizeable{
    var position: SIMD3<Float>
    var color: SIMD4<Float>
    var uvCoordinate: SIMD2<Float>
}

struct VertexIn: sizeable{
    var position: SIMD3<Float>
    var uvCoordinate: SIMD2<Float>
    var normal: SIMD3<Float>
    var tangent: SIMD3<Float>
    var bitangent: SIMD3<Float>
}

let haltonSamples: [SIMD2<Float>] = [
    SIMD2<Float>(0.5, 0.333333333333),
    SIMD2<Float>(0.25, 0.666666666667),
    SIMD2<Float>(0.75, 0.111111111111),
    SIMD2<Float>(0.125, 0.444444444444),
    SIMD2<Float>(0.625, 0.777777777778),
    SIMD2<Float>(0.375, 0.222222222222),
    SIMD2<Float>(0.875, 0.555555555556),
    SIMD2<Float>(0.0625, 0.888888888889),
    SIMD2<Float>(0.5625, 0.037037037037),
    SIMD2<Float>(0.3125, 0.37037037037),
    SIMD2<Float>(0.8125, 0.703703703704),
    SIMD2<Float>(0.1875, 0.148148148148),
    SIMD2<Float>(0.6875, 0.481481481481),
    SIMD2<Float>(0.4375, 0.814814814815),
    SIMD2<Float>(0.9375, 0.259259259259),
    SIMD2<Float>(0.03125, 0.592592592593),
]

struct PrimitiveData: sizeable {
    var texture: MTLTexture?
}

struct AlphaTestingPrimitiveData: sizeable {
    var texture: MTLTexture?
    var uvCoordinates: [SIMD2<Float>] = Array(repeating: SIMD2(repeating: 0), count: 3)
}

struct LightData: sizeable {
    var position = SIMD3<Float>(repeating: 0)
    var color = SIMD3<Float>(repeating: 1)
    
    var brightness: Float = 1.0
    var ambientIntensity: Float = 1.0
    var diffuseIntensity: Float = 1.0
    var specularIntensity: Float = 1.0
    
}

struct Material: sizeable {
    var isLit: Bool = false
    
    var ambient = SIMD3<Float>(0.1, 0.1, 0.1)
    var diffuse = SIMD3<Float>(0.6, 0.6, 0.6)
    var specular = SIMD3<Float>(0, 0, 0)
    var emissive = SIMD3<Float>(0, 0, 0)
    var shininess: Float = 2.0
    var opacity: Float = 0.0
    var opticalDensity: Float = 0.0
    var roughness: Float = 1.0
    var isTextureEnabled: Bool = true
    var isNormalMapEnabled: Bool = true
    var isMetallicMapEnabled: Bool = true
    var isRoughnessMapEnabled: Bool = true
    var isEmissionTextureEnabled: Bool = true
    var isProceduralTextureEnabled: Bool = false
}

struct RotationMatrix: sizeable {
    var rotationMatrix: matrix_float4x4
}

struct CameraOut: sizeable {
    var position: SIMD3<Float>
    var forward: SIMD3<Float>
    var right: SIMD3<Float>
    var up: SIMD3<Float>
//    var rotationMatrix: matrix_float4x4
}

struct ModelConstants: sizeable {
    var modelMatrix = matrix_identity_float4x4
}

struct SceneConstants: sizeable {
    var viewMatrix = matrix_identity_float4x4
    var projectionMatrix = matrix_identity_float4x4
    var cameraPosition = SIMD3<Float>(repeating: 0)
}

struct TextureIds: sizeable {
    var baseColor: Int32
    var normalMap: Int32
    var metallic:  Int32
    var roughness: Int32
    var emission:  Int32
}

struct Texture: Hashable, sizeable {
    static func == (lhs: Texture, rhs: Texture) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: Int
    var texture: MTLTexture?
}

struct VertexIndex: sizeable {
    var index: UInt32
    var submeshId: UInt32
}

struct DenoiserVertexData: sizeable {
    var position: SIMD3<Float>
    var normal: SIMD3<Float>
    var prevPosition: SIMD3<Float>
}

class Masks {
    public static let FACE_MASK_NONE: uint = 0
    public static let FACE_MASK_NEGATIVE_X: uint = (1 << 0)
    public static let FACE_MASK_POSITIVE_X: uint = (1 << 1)
    public static let FACE_MASK_NEGATIVE_Y: uint = (1 << 2)
    public static let FACE_MASK_POSITIVE_Y: uint = (1 << 3)
    public static let FACE_MASK_NEGATIVE_Z: uint = (1 << 4)
    public static let FACE_MASK_POSITIVE_Z: uint = (1 << 5)
    public static let FACE_MASK_ALL: uint = ((1 << 6) - 1)
    
    public static let TRIANGLE_MASK_GEOMETRY: uint = 1
    public static let TRIANGLE_MASK_LIGHT: uint = 2
}

struct RTRenderOptions {
    var intersectionStride = MemoryLayout<MPSIntersectionDistancePrimitiveIndexInstanceIndexCoordinates>.size
    var intersectionDataType = MPSIntersectionDataType.distancePrimitiveIndexInstanceIndexCoordinates
    var maxFramesInFlight = 3
    var alignedUniformsSize = (MemoryLayout<Uniforms>.stride + 255) & ~255
    var rayStride = 48
    var rayMaskOptions = MPSRayMaskOptions.primitive
}

struct PSRenderOptions {
    
}

extension MTLTexture {
    func toCGImage() -> CGImage? {
        guard let ciImage = CIImage(mtlTexture: self, options: nil) else { return nil }
        let flippedImage = ciImage.oriented(.left).oriented(.left).oriented(.upMirrored)
        let context = CIContext(options: nil)
        return context.createCGImage(flippedImage, from: CGRect(x: 0, y: 0, width: width, height: height))
     }
}

protocol RenderingSettings {
    
}

struct RayTracingSettings: RenderingSettings {
    var quality: RenderQuality
    var samples: Int
    var maxBounce: Int
    var alphaTesting: Bool
    var tileSize: MTLSize
}

struct VertexShadingSettings: RenderingSettings {
    
}

struct KeyFrame {
    var time: Double
    var sceneTime: Float
    var position: SIMD3<Float>
    var rotation: SIMD3<Float>
}

enum RenderMode {
    case display
    case render
}

enum RenderQuality : String {
    case low = "low"
    case medium = "medium"
    case high = "high"
}

enum RendererType : CaseIterable {
    case StaticRT
    case DynamicRT
    case PhongShader
}

enum GameScenes: String, CaseIterable {
    case CornellBox = "Cornell Box"
    case HarmonicCubes = "Harmonic Cubes"
    case EnchantingGlow = "Enchanting Glow"
    case Ocean = "Ocean"
    case Custom = "Custom"
}

enum RenderViewPortType : String, CaseIterable {
    case StaticRT
    case DynamicRT
    case PhongShader
    case Render
}

