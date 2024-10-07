import simd

class DebugCamera: SceneCamera {
    var focalLength: Float = 1.0
    var dofBlurStrength: Float = 0.0
    
    var cameraType: CameraTypes = .Debug
    var controllSensitivity = ControllSensitivity()
    
    var position = SIMD3<Float>(0, 70, 405)
    var deltaPosition = SIMD3<Float>(0, 0, 0)
    var rotation = SIMD3<Float>(0, 0, 0)
    var deltaRotation = SIMD3<Float>(0, 0, 0)
    var rotationAboutOrigin = SIMD3<Float>(0, 0, 0)
    var deltaRotationAboutOrigin = SIMD3<Float>(0, 0, 0)
    var projectionMatrix: matrix_float4x4 {
        return matrix_float4x4.prespective(degreeFov: 45, aspectRatio: 1.6, near: 0.1, far: 1000)
    }
    
    func reset() {}
    
    func update(deltaTime: Float) {
        
        var _deltaPosition = SIMD3<Float>(0, 0, 0)
        
        if(Keyboard.isKeyPressed(.leftArrow)) {
            _deltaPosition.x -= deltaTime * controllSensitivity.keyboardTranslation
        }
        
        if(Keyboard.isKeyPressed(.rightArrow)) {
            _deltaPosition.x += deltaTime * controllSensitivity.keyboardTranslation
        }
        
        if(Keyboard.isKeyPressed(.downArrow)) {
            _deltaPosition.y -= deltaTime * controllSensitivity.keyboardTranslation
        }
        
        if(Keyboard.isKeyPressed(.upArrow)) {
            _deltaPosition.y  += deltaTime * controllSensitivity.keyboardTranslation
        }
        
        if(Keyboard.isKeyPressed(.w)) {
            _deltaPosition.z -= deltaTime * controllSensitivity.keyboardTranslation
        }
        
        if(Keyboard.isKeyPressed(.s)) {
            _deltaPosition.z += deltaTime * controllSensitivity.keyboardTranslation
        }
        
        if(Keyboard.isKeyPressed(.a)) {
            self.deltaRotation.y += deltaTime * controllSensitivity.keyboardRotation
        }
        
        if(Keyboard.isKeyPressed(.d)) {
            self.deltaRotation.y -= deltaTime * controllSensitivity.keyboardRotation
        }
        
        if(Keyboard.isKeyPressed(.z)) {
            self.deltaRotation.x -= deltaTime * controllSensitivity.keyboardRotation
        }
        
        if(Keyboard.isKeyPressed(.x)) {
            self.deltaRotation.x += deltaTime * controllSensitivity.keyboardRotation
        }
        
        if(Keyboard.isKeyPressed(.c)) {
            self.deltaRotation.z -= deltaTime * controllSensitivity.keyboardRotation
        }
        
        if(Keyboard.isKeyPressed(.v)) {
            self.deltaRotation.z += deltaTime * controllSensitivity.keyboardRotation
        }
        
        self.deltaRotation.y += Mouse.getDWheelX() / -1 * controllSensitivity.trackpadRotation
        self.deltaRotation.x += Mouse.getDWheelY() / -1 *  controllSensitivity.trackpadRotation
        
        rotation += deltaRotation
        
        var transform = matrix_identity_float4x4
        transform.rotate(angle: rotation.x, axis: X_AXIS)
        transform.rotate(angle: rotation.y, axis: Y_AXIS)
        transform.rotate(angle: rotation.z, axis: Z_AXIS)
        
        deltaPosition = (transform * _deltaPosition.simd4(w: 1)).xyz
        position += deltaPosition
    }
    
    
}
