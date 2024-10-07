import MetalKit
import MetalPerformanceShaders

class EnchantingGlow: GameScene {
    
    override func buildScene() {
        
        var transform = matrix_identity_float4x4
        transform.translate(direction: SIMD3<Float>(0, 1, 0))
        transform.scale(axis: SIMD3<Float>(0.5, 1.98, 0.5))
        
        createCube(faceMask: Masks.FACE_MASK_POSITIVE_Y, color: SIMD3<Float>([1, 1, 1]), reflectivity: 0.0, transform: transform, inwardNormals: true, triangleMask: UInt32(TRIANGLE_MASK_LIGHT))
        addLight(light: Light(type: UInt32(LIGHT_TYPE_AREA), position: SIMD3<Float>(0, 1.98, 0), forward: SIMD3<Float>(0, -1, 0), right: SIMD3<Float>(0.25, 0, 0), up: SIMD3<Float>(0, 0, 0.25), color: SIMD3<Float>(4, 4, 4)))
        
        //         Top, bottom
//        let wallMaterial = Material(isLit: false, diffuse: SIMD3<Float>([0.725, 0.71, 0.68]), emissive: SIMD3<Float>([14.5, 14.2, 13.6]), opacity: 0.0, opticalDensity: 0.0, roughness: 0.0, isTextureEnabled: false, isNormalMapEnabled: false, isMetallicMapEnabled: false, isRoughnessMapEnabled: false, isProceduralTextureEnabled: false)
        
        transform = matrix_identity_float4x4
        transform.translate(direction: SIMD3<Float>(0, 1, 0))
        transform.scale(axis: SIMD3<Float>(2, 2, 2))
        
        // Top wall
        createCube(faceMask: Masks.FACE_MASK_POSITIVE_Y, color: SIMD3<Float>([0.725, 0.71, 0.68]), reflectivity: 0.0, transform: transform, inwardNormals: true, triangleMask: uint(TRIANGLE_MASK_GEOMETRY))
        
        // Bottom wall
        createCube(faceMask: Masks.FACE_MASK_NEGATIVE_Y, color: SIMD3<Float>([0.725, 0.71, 0.68]), reflectivity: 0.0, transform: transform, inwardNormals: true, triangleMask: uint(TRIANGLE_MASK_GEOMETRY))
        
//        solids[solids.count - 1].setRoughness(0.0)
//        solids[solids.count - 2].setRoughness(0.0)
        
        // Back wall
        createCube(faceMask: Masks.FACE_MASK_NEGATIVE_Z, color: SIMD3<Float>([0.725, 0.71, 0.68]), reflectivity: 1.0, transform: transform, inwardNormals: true, triangleMask: uint(TRIANGLE_MASK_GEOMETRY))
        
        // Front wall
//        createCube(faceMask: Masks.FACE_MASK_POSITIVE_Z, color: SIMD3<Float>([0.725, 0.71, 0.68]), reflectivity: 1.0, transform: transform, inwardNormals: true, triangleMask: uint(TRIANGLE_MASK_GEOMETRY))
//        
//        solids[solids.count - 1].setOpticalDensity(1.01)
//        solids[solids.count - 2].setOpticalDensity(1.01)
        
//        solids[solids.count - 1].setColor(SIMD3<Float>([0.725, 0.71, 0.68]))
//        solids[solids.count - 1].setEmissionColor(SIMD3<Float>([0.725, 0.71, 0.68]))
//        solids[solids.count - 2].setColor(SIMD3<Float>([0.725, 0.71, 0.68]))
//        solids[solids.count - 2].setEmissionColor(SIMD3<Float>([0.725, 0.71, 0.68]))
        
        let leftWallMaterial = Material(isLit: false, diffuse: SIMD3<Float>([0.63, 0.065, 0.05]), emissive: SIMD3<Float>(12.6, 1.3, 1.0), opacity: 0.0, opticalDensity: 0.0, roughness: 0.0, isTextureEnabled: false, isNormalMapEnabled: false, isMetallicMapEnabled: false, isRoughnessMapEnabled: false, isProceduralTextureEnabled: false)
        // Left wall
        createCube(faceMask: Masks.FACE_MASK_NEGATIVE_X, color: SIMD3<Float>([0.63, 0.065, 0.05]), reflectivity: 0.0, transform: transform, inwardNormals: true, triangleMask: uint(TRIANGLE_MASK_GEOMETRY), material: leftWallMaterial)
        
        solids[solids.count - 1].setRoughness(0.0)
        solids[solids.count - 2].setRoughness(0.0)
        
        let rightWallMaterial = Material(isLit: false, diffuse: SIMD3<Float>([0.14, 0.45, 0.091]), emissive: SIMD3<Float>(2.8, 9.0, 1.82), opacity: 0.0, opticalDensity: 0.0, roughness: 0.0, isTextureEnabled: false, isNormalMapEnabled: false, isMetallicMapEnabled: false, isRoughnessMapEnabled: false, isProceduralTextureEnabled: false)
        //        // Right wall
        createCube(faceMask: Masks.FACE_MASK_POSITIVE_X, color: SIMD3<Float>([0.14, 0.45, 0.091]), reflectivity: 0.0, transform: transform, inwardNormals: true, triangleMask: uint(TRIANGLE_MASK_GEOMETRY), material: rightWallMaterial)
        
        solids[solids.count - 1].setRoughness(0.0)
        solids[solids.count - 2].setRoughness(0.0)
        
        //         Short box
        let monkey = Solid(.Cube)
        monkey.enableEmission(true)
        monkey.setEmissionColor(SIMD3<Float>(4, 4, 16))
        monkey.position = SIMD3<Float>(0.3275, 0.4, 0.3725)
        monkey.rotation = SIMD3<Float>(0, -0.3, 0)
        monkey.scale = SIMD3<Float>(0.3, 0.3, 0.3)
        monkey.setColor(SIMD3<Float>(0.2, 0.2, 0.8))
        monkey.setRoughness(1.0)
        monkey.setOpticalDensity(1.01)
        monkey.enableTexture(false)
        
        solids.append(monkey)
        
        //         Tall box
        let sphere = Solid(.Icosphere)
        sphere.position = SIMD3<Float>(-0.375, 0.5, -0.29)
        sphere.rotation = SIMD3<Float>(0, 0.3, 0)
        sphere.scale = SIMD3<Float>(0.4, 0.4, 0.4)
        sphere.enableEmission(false)
        sphere.setRoughness(1.0)
        sphere.setEmissionColor(SIMD3<Float>(10, 8.75, 0))
        sphere.setColor(SIMD3<Float>(0.9882, 0.8196, 0.0863))
        solids.append(sphere)
        
        updateSolids = animate
    }
    
    override func animate(solids: [Solid], time: Float) {
        solids[solids.count-1].rotation.y = time
        solids[solids.count-2].position.y = 0.4 + 0.1 * sin(time)
    }
    
}
    
