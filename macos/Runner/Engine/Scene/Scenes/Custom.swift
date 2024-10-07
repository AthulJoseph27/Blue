import MetalKit
import MetalPerformanceShaders

class Custom: GameScene {
    
    override func buildScene() {
        let custom = Solid(.Custom)
        custom.position = SIMD3<Float>(0, 0, 0)
        solids.append(custom)
        
        addLight(light: Light(type: UInt32(LIGHT_TYPE_SUN), position: SIMD3<Float>(-1, 10, 0), forward: SIMD3<Float>(0, -1, 0), right: SIMD3<Float>(0.25, 0, 0), up: SIMD3<Float>(0, 0, 0.25), color: SIMD3<Float>(1, 1, 1)))
        
        ambient = 0.1
    }
}
    
