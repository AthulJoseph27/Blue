import simd
import Foundation

class AnimationCamera: SceneCamera {
    var focalLength: Float = 1.0
    var dofBlurStrength: Float = 0.0

    var cameraType: CameraTypes = .Animation
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
    var record: Bool {
        return _record
    }
    
    private var keyframes: [KeyFrame] = []
    private var FPS: uint = 24
    private var _record: Bool = false
    
    func getKeyframes() -> [KeyFrame] {
        return keyframes
    }
    
    func clearKeyframes() {
        keyframes = []
    }
    
    func setFPS(fps: uint) {
        FPS = fps
    }
    
    func resumeRecording() {
        _record = true
        RendererManager.updateAnimCameraToolBar(recording: _record)
        if keyframes.isEmpty {
            keyframes.append(KeyFrame(time: Date().timeIntervalSince1970, sceneTime: SceneManager.currentSceneTime, position: position, rotation: rotation))
        }
    }
    
    func pauseRecording() {
        _record = false
        RendererManager.updateAnimCameraToolBar(recording: _record)
    }
    
    func reset() {
        keyframes = []
        FPS = 24
        _record = false
    }
    
    func update(deltaTime: Float) {
        
        if(Keyboard.isKeyPressed(.p)) {
            pauseRecording()
            return
        }
        
        if(Keyboard.isKeyPressed(.r)) {
            resumeRecording()
            return
        }
        
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
        
        self.deltaRotation.y += Mouse.getDWheelX() / -1 * controllSensitivity.trackpadRotation
        self.deltaRotation.x += Mouse.getDWheelY() / -1 *  controllSensitivity.trackpadRotation
        
        rotation += deltaRotation
        
        var transform = matrix_identity_float4x4
        transform.rotate(angle: rotation.x, axis: X_AXIS)
        transform.rotate(angle: rotation.y, axis: Y_AXIS)
        transform.rotate(angle: rotation.z, axis: Z_AXIS)
        
        deltaPosition = (transform * _deltaPosition.simd4(w: 1)).xyz
        position += deltaPosition
        
        if _record {
            if Keyboard.isKeyPressed(.k) {
                keyframes.append(KeyFrame(time: Date().timeIntervalSince1970, sceneTime: SceneManager.currentSceneTime, position: position, rotation: rotation))
                print(keyframes)
            }
            
            if !(!keyframes.isEmpty && keyframes.last!.rotation == rotation && keyframes.last!.position == position) {
                keyframes.append(KeyFrame(time: Date().timeIntervalSince1970, sceneTime: SceneManager.currentSceneTime, position: position, rotation: rotation))
            }
        }
    }
    
    
}
