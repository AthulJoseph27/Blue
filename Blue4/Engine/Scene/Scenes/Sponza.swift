import MetalKit
import MetalPerformanceShaders

class Sponza: GameScene {
    
    override func buildScene() {
        let sponza = Solid(.Sponza)
        sponza.position = SIMD3<Float>(-5.375, 0.5, -0.29)
        sponza.scale = SIMD3<Float>(0.008, 0.008, 0.008)
        solids.append(sponza)
        
        addLight(light: Light(type: UInt32(LIGHT_TYPE_AREA), position: SIMD3<Float>(0, 1.98, 0), forward: SIMD3<Float>(0, -1, 0), right: SIMD3<Float>(0.25, 0, 0), up: SIMD3<Float>(0, 0, 0.25), color: SIMD3<Float>(4, 4, 4)))
    }
}
    
