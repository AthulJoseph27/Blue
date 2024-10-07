class CameraManager {
    private static var _cameras: [CameraTypes : SceneCamera] = [:]
    private static var locked = false
    public static var currentCamera: SceneCamera!
    
    public static func initialize() {
        let debugCamera = DebugCamera()
        debugCamera.position = SIMD3<Float>(0, 1, 3.38)
        CameraManager.registerCamera(camera: debugCamera)
        
        
        let animCamera = AnimationCamera()
        animCamera.position = SIMD3<Float>(0, 1, 3.38)
        CameraManager.registerCamera(camera: animCamera)
    }
    
    public static func registerCamera(camera: SceneCamera) {
        _cameras.updateValue(camera, forKey: camera.cameraType)
    }
    
    public static func setCamera(_ cameraType: CameraTypes) {
        currentCamera = _cameras[cameraType]
        currentCamera.reset()
    }
    
    public static func setCameraControllSensitivity(_ settings: ControllSensitivity) {
        currentCamera.controllSensitivity = settings
    }
    
    public static func lockCamera() {
        locked = true
    }
    
    public static func unlockCamera() {
        locked = false
    }
    
    internal static func update(deltaTime: Float) {
        if !locked {
            currentCamera.update(deltaTime: deltaTime)
        }
    }
}
