class SceneSettings {
    var currentScene: GameScenes
    var skybox: SkyboxTypes
    var ambientLighting: Float
    var sceneLights: [Light] = [
        Light(type: UInt32(LIGHT_TYPE_SUN), position: SIMD3<Float>(0, 0, 0), forward: SIMD3<Float>(0, -1, 0), right: SIMD3<Float>(0, 0, 0), up: SIMD3<Float>(0, 0, 0), color: SIMD3<Float>(1, 1, 1))
    ]
    
    init(currentScene: GameScenes, skybox: SkyboxTypes, ambientLighting: Float) {
        self.currentScene = currentScene
        self.skybox = skybox
        self.ambientLighting = ambientLighting
    }
    
    func fromJson(_ json: [String: Any]) -> SceneSettings {
        
        let sceneSettings = SceneSettings(currentScene: currentScene, skybox: skybox, ambientLighting: ambientLighting)
        
        if let scene = json["scene"] as? String, let gameScene = GameScenes(rawValue: scene) {
            sceneSettings.currentScene = gameScene
        }
        
        if let skyboxName = json["skybox"] as? String, let skybox = SkyboxTypes(rawValue: skyboxName) {
            sceneSettings.skybox = skybox
        }
        
        if let ambient = json["ambient"] as? Float {
            sceneSettings.ambientLighting = ambient
        }
        
        if let sceneLights = json["sceneLights"] as? [[String: Any]] {
            sceneSettings.sceneLights = []
            for sceneLight in sceneLights {
                sceneSettings.sceneLights.append(decodeSceneLight(sceneLight))
            }
            
        }
        
        return sceneSettings
    }
    
    private func decodeSceneLight(_ json: [String: Any]) -> Light {
        let colorValue = (json["color"] as? [String: Any]) ?? ["r" : 1, "g": 1, "b": 1]
        let directionMap = (json["direction"] as? [String: Any]) ?? ["x" : 0, "y": 0, "z": 0]
        let positionMap = (json["position"] as? [String: Any]) ?? ["x" : 0, "y": 0, "z": 0]
        let intensity = (json["intensity"] as? Float) ?? 1
        let type = (json["lightType"] as? String) ?? "sun"
        
        let color = SIMD3<Float>(colorValue["r"] as! Float, colorValue["g"] as! Float, colorValue["b"] as! Float) * intensity / 255.0
        let position = SIMD3<Float>(positionMap["x"] as! Float, positionMap["y"] as! Float, positionMap["z"] as! Float)
        let direction = SIMD3<Float>(directionMap["x"] as! Float, directionMap["y"] as! Float, directionMap["z"] as! Float)
        var lightType = LIGHT_TYPE_SUN
        
        switch (type) {
            case "spot":
                lightType = LIGHT_TYPE_SPOT
                break
            case "area":
                lightType = LIGHT_TYPE_AREA
                break
            default:
                lightType = LIGHT_TYPE_SUN
        }
        
        return Light(type: UInt32(lightType), position: position, forward: direction, right: SIMD3<Float>(0.25, 0, 0), up: SIMD3<Float>(0, 0, 0.25), color: color)
    }
    
}
