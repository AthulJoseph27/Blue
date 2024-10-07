import MetalKit
import MetalPerformanceShaders

class Sandbox: GameScene {
    
    override func buildScene() {
        
        var transform = matrix_identity_float4x4
        transform.translate(direction: SIMD3<Float>(0, 1, 0))
        transform.scale(axis: SIMD3<Float>(0.5, 1.98, 0.5))
        
        createCube(faceMask: Masks.FACE_MASK_POSITIVE_Y, color: SIMD3<Float>([1, 1, 1]), reflectivity: 0.0, transform: transform, inwardNormals: true, triangleMask: UInt32(TRIANGLE_MASK_LIGHT))
        addLight(light: Light(type: UInt32(LIGHT_TYPE_AREA), position: SIMD3<Float>(0, 1.98, 0), forward: SIMD3<Float>(0, -1, 0), right: SIMD3<Float>(0.25, 0, 0), up: SIMD3<Float>(0, 0, 0.25), color: SIMD3<Float>(4, 4, 4)))
        
        //         Top, bottom, back
        transform = matrix_identity_float4x4
        transform.translate(direction: SIMD3<Float>(0, 1, 0))
        transform.scale(axis: SIMD3<Float>(2, 2, 2))
        createCube(faceMask: Masks.FACE_MASK_NEGATIVE_Y | Masks.FACE_MASK_POSITIVE_Y | Masks.FACE_MASK_NEGATIVE_Z, color: SIMD3<Float>([0.725, 0.71, 0.68]), reflectivity: 0.0, transform: transform, inwardNormals: true, triangleMask: uint(TRIANGLE_MASK_GEOMETRY))
        
        // Left wall
        createCube(faceMask: Masks.FACE_MASK_NEGATIVE_X, color: SIMD3<Float>([0.63, 0.065, 0.05]), reflectivity: 0.0, transform: transform, inwardNormals: true, triangleMask: uint(TRIANGLE_MASK_GEOMETRY))
        
        // Right wall
        createCube(faceMask: Masks.FACE_MASK_POSITIVE_X, color: SIMD3<Float>([0.14, 0.45, 0.091]), reflectivity: 0.0, transform: transform, inwardNormals: true, triangleMask: uint(TRIANGLE_MASK_GEOMETRY))
        
        // Short box
        let monkey = Solid(.Cube)
        monkey.position = SIMD3<Float>(0.3275, 0.4, 0.3725)
        monkey.rotation = SIMD3<Float>(0, -0.3, 0)
        monkey.scale = SIMD3<Float>(0.3, 0.3, 0.3)
        monkey.setColor(SIMD3<Float>(0.2, 0.2, 0.8))
//        monkey.setRoughness(1.0)
        monkey.setRoughness(0.0)
        monkey.enableTexture(false)
        
        solids.append(monkey)
        
        // Tall box
        let chest = Solid(.Chest)
        chest.position = SIMD3<Float>(-0.375, 0.5, -0.29)
        chest.rotation = SIMD3<Float>(0, 0.3, 0)
        chest.scale = SIMD3<Float>(0.008, 0.008, 0.008)
        solids.append(chest)
        
        updateSolids = animate
    }
    
    override func animate(solids: [Solid], time: Float) {
        solids[solids.count-1].rotation.y = time
        solids[solids.count-2].position.y = 0.4 + 0.1 * sin(time)
    }
    
}
    
