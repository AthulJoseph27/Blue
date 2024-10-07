import simd

enum CameraTypes {
    case Debug
    case Animation
}

protocol SceneCamera {
    var cameraType: CameraTypes                 { get }
    var focalLength: Float                      { get set }
    var dofBlurStrength: Float                  { get set }
    var position: SIMD3<Float>                  { get set }
    var deltaPosition: SIMD3<Float>             { get set }
    var rotation: SIMD3<Float>                  { get set }
    var deltaRotation: SIMD3<Float>             { get set }
    var projectionMatrix: matrix_float4x4       { get }
    var controllSensitivity: ControllSensitivity { get set }
    func update(deltaTime: Float)
    func reset()
}

extension SceneCamera {
    var viewMatrix: matrix_float4x4 {
        var viewMatrix = matrix_identity_float4x4
        viewMatrix.rotate(angle: (rotation.x + deltaRotation.x), axis: SIMD3<Float>(1, 0, 0))
        viewMatrix.rotate(angle: (rotation.y + deltaRotation.y), axis: SIMD3<Float>(0, 1, 0))
        viewMatrix.rotate(angle: (rotation.z + deltaRotation.z), axis: SIMD3<Float>(0, 0, 1))
        viewMatrix.translate(direction: -(position + deltaPosition))
        return viewMatrix
    }
}

class ControllSensitivity {
    var trackpadRotation: Float = 1
    var trackpadZoom: Float = 1
    
    var keyboardTranslation: Float = 1
    var keyboardRotation: Float = 1
    
    static func fromJson(json: [String: Any]) -> ControllSensitivity {
        let controllSensitivity = ControllSensitivity()
        if let trackpadSettings = json["trackpadSensitivity"] as? [String: Any] {
            controllSensitivity.trackpadZoom = trackpadSettings["zoom"] as? Float ?? controllSensitivity.trackpadZoom
            controllSensitivity.trackpadRotation = trackpadSettings["rotation"] as? Float ?? controllSensitivity.trackpadRotation
        }
        
        if let keyboardSettings = json["keyboardSensitivity"] as? [String: Any] {
            controllSensitivity.keyboardTranslation = (keyboardSettings["translation"] as? Float ?? controllSensitivity.keyboardTranslation)
            controllSensitivity.keyboardRotation = keyboardSettings["rotation"] as? Float ?? controllSensitivity.keyboardRotation
        }
        
        return controllSensitivity
    }
}
