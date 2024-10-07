import MetalKit

class SceneManager {
    public static var currentRendererType: RendererType = .StaticRT
    
    private static var _sceneSettings = SceneSettings(currentScene: .CornellBox, skybox: .Sky, ambientLighting: 0.1)
    private static var _currentSceneName: GameScenes = .CornellBox
    private static var _currentScene: GameScene!
    private static var _currentRenderableScene: RenderableScene!
    static var currentRenderableScene: RenderableScene {
        get {
            return SceneManager._currentRenderableScene
        }
    }
    static var currentScene: GameScene {
        get {
            return SceneManager._currentScene
        }
    }
    static var currentSceneTime: Float {
        get {
            return SceneManager._currentRenderableScene.sceneTime
        }
    }
    
    public static func initialize(scene: GameScenes, rendererType: RendererType) {
        currentRendererType = rendererType
        setScene(scene)
    }
    
    public static func setScene(_ scene: GameScenes){
        switch scene {
        case .CornellBox:
            _currentScene = Sandbox(skybox: _sceneSettings.skybox, ambient: _sceneSettings.ambientLighting)
            break
        case .HarmonicCubes:
            _currentScene = HarmonicCubes(skybox: _sceneSettings.skybox, ambient: _sceneSettings.ambientLighting)
            break
        case .EnchantingGlow:
            _currentScene = EnchantingGlow(skybox: _sceneSettings.skybox, ambient: _sceneSettings.ambientLighting)
            break
        case .Ocean:
            _currentScene = Ocean(skybox: _sceneSettings.skybox, ambient: _sceneSettings.ambientLighting)
            break
        case .Custom:
            _currentScene = Custom(skybox: _sceneSettings.skybox, ambient: _sceneSettings.ambientLighting, lights: _sceneSettings.sceneLights)
        }
        _currentSceneName = scene
        updateRenderableScene(currentRendererType)
    }
    
    public static func updateSceneSettings(arguments: [String: Any]) {
        let newSettings = _sceneSettings.fromJson(arguments)
        
        if newSettings.currentScene != _sceneSettings.currentScene {
            SceneManager.setScene(newSettings.currentScene)
            RendererManager.updateCurrentScene(scene: newSettings.currentScene)
        }
        
        if newSettings.skybox != _sceneSettings.skybox {
            _currentScene.updateSkybox(skybox: newSettings.skybox)
            
        }
        
        if newSettings.ambientLighting != _sceneSettings.ambientLighting {
            _currentScene.updateAmbient(ambient: newSettings.ambientLighting)
        }
        
        if arguments["sceneLights"] != nil {
            _currentScene.updateSceneLights(lights: newSettings.sceneLights)
            _currentRenderableScene.updateSceneLights(lights: newSettings.sceneLights)
        }
        
        _sceneSettings = newSettings
        _currentRenderableScene.updateSceneSettings(sceneSettings: newSettings)
    }
    
    public static func updateRenderableScene(_ rendererType: RendererType) {
        currentRendererType = rendererType
        switch rendererType {
        case .StaticRT:
            _currentRenderableScene = StaticRTScene(scene: _currentScene)
        case .DynamicRT:
            _currentRenderableScene = DynamicRTScene(scene: _currentScene)
        case .PhongShader:
            _currentRenderableScene = PhongShadingScene(scene: _currentScene)
        }
    }
    
    public static func tickScene(deltaTime: Float) {
        _currentRenderableScene.tickScene(deltaTime: _currentScene.sceneTick ?? deltaTime)
        _currentRenderableScene.updateCameras(deltaTime: deltaTime)
        _currentRenderableScene.updateScene(time: nil)
    }
    
    public static func setSceneToTick(time: Float) {
        _currentRenderableScene.updateScene(time: time)
    }
}
