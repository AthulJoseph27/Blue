import MetalKit
import MetalPerformanceShaders

class HarmonicCubes: GameScene {
    var cubes: [[Int]] = []
    
    override func buildScene() {
        
        sceneTick = Float.pi / 8.0
        
        var transform = matrix_identity_float4x4
        transform.translate(direction: SIMD3<Float>(0, 1, 0))
        transform.scale(axis: SIMD3<Float>(0.5, 1.98, 0.5))
        
        createCube(faceMask: Masks.FACE_MASK_POSITIVE_Y, color: SIMD3<Float>([1, 1, 1]), reflectivity: 0.0, transform: transform, inwardNormals: true, triangleMask: UInt32(TRIANGLE_MASK_LIGHT))
        addLight(light: Light(type: UInt32(LIGHT_TYPE_AREA), position: SIMD3<Float>(0, 1.98, 0), forward: SIMD3<Float>(0, -1, 0), right: SIMD3<Float>(0.25, 0, 0), up: SIMD3<Float>(0, 0, 0.25), color: SIMD3<Float>(0.1, 0.1, 0.1)))
        
        // Top, bottom, back
        transform = matrix_identity_float4x4
        transform.translate(direction: SIMD3<Float>(0, 1, 0))

        transform.scale(axis: SIMD3<Float>(2, 2, 2))
        createCube(faceMask: Masks.FACE_MASK_NEGATIVE_Y | Masks.FACE_MASK_POSITIVE_Y | Masks.FACE_MASK_NEGATIVE_Z, color: SIMD3<Float>([0.725, 0.71, 0.68]), reflectivity: 0.0, transform: transform, inwardNormals: true, triangleMask: uint(TRIANGLE_MASK_GEOMETRY))
        
//        // Left wall
//        createCube(faceMask: Masks.FACE_MASK_NEGATIVE_X, color: SIMD3<Float>([0.63, 0.065, 0.05]), reflectivity: 0.0, transform: transform, inwardNormals: true, triangleMask: uint(TRIANGLE_MASK_GEOMETRY))
//        
//        // Right wall
//        createCube(faceMask: Masks.FACE_MASK_POSITIVE_X, color: SIMD3<Float>([0.14, 0.45, 0.091]), reflectivity: 0.0, transform: transform, inwardNormals: true, triangleMask: uint(TRIANGLE_MASK_GEOMETRY))
        
        let leftWallMaterial = Material(isLit: false, diffuse: SIMD3<Float>([0.63, 0.065, 0.05]), emissive: SIMD3<Float>(12.6, 1.3, 1.0), opacity: 0.0, opticalDensity: 0.0, roughness: 0.0, isTextureEnabled: false, isNormalMapEnabled: false, isMetallicMapEnabled: false, isRoughnessMapEnabled: false, isProceduralTextureEnabled: false)
        // Left wall
        createCube(faceMask: Masks.FACE_MASK_NEGATIVE_X, color: SIMD3<Float>([0.63, 0.065, 0.05]), reflectivity: 0.0, transform: transform, inwardNormals: true, triangleMask: uint(TRIANGLE_MASK_GEOMETRY), material: leftWallMaterial)
        
        solids[solids.count - 1].setRoughness(0.0)
        solids[solids.count - 2].setRoughness(0.0)
        
        let rightWallMaterial = Material(isLit: false, diffuse: SIMD3<Float>([0.14, 0.45, 0.091]), emissive: SIMD3<Float>(2.8, 9.0, 1.82), opacity: 0.0, opticalDensity: 0.0, roughness: 0.0, isTextureEnabled: false, isNormalMapEnabled: false, isMetallicMapEnabled: false, isRoughnessMapEnabled: false, isProceduralTextureEnabled: false)
        //        // Right wall
        createCube(faceMask: Masks.FACE_MASK_POSITIVE_X, color: SIMD3<Float>([0.14, 0.45, 0.091]), reflectivity: 0.0, transform: transform, inwardNormals: true, triangleMask: uint(TRIANGLE_MASK_GEOMETRY), material: rightWallMaterial)
        
        addLight(light: Light(type: UInt32(LIGHT_TYPE_AREA), position: SIMD3<Float>(0, 0.98, 0), forward: SIMD3<Float>(0, -1, 0), right: SIMD3<Float>(0.25, 0, 0), up: SIMD3<Float>(0, 0, 0.25), color: SIMD3<Float>(4, 4, 4)))
        
        
        for x in -8..<9 {
            var temp: [Int] = []
            for z in -8..<9 {
                let cube = Solid(.Cube)
                cube.position = SIMD3<Float>(Float(x) / 20 + 0.5, 0.5, Float(z) / 20 - 0.5)
                cube.setColor(SIMD3<Float>(0.0118, 0.8980, 0.9760))
                cube.scale = SIMD3<Float>(0.035, 0.035, 0.035)
                cube.setRoughness(1.0)
                cube.setOpticalDensity(1.05)
                cube.enableEmission(true)
//                cube.setEmissionColor(SIMD3<Float>(40, 40, 160))
                cube.enableTexture(false)
                cube.transformOrder = .RotateTranslateScale
                temp.append(solids.count)
                solids.append(cube)
            }
            cubes.append(temp)
        }
    
        updateSolids = animate
    }
    
    override internal func animate(solids: [Solid], time: Float) {
        let offSet = time / 5.0
                
        for r in 0..<17 {
            for i in 0..<17 {
                let x = Float(r - 8)
                let y = Float(i - 8)
                let dist = sqrt(x * x + y * y) / sqrt(64) * Float.pi + offSet
                solids[cubes[r][i]].scale = SIMD3<Float>(1, 4 + 2 * sin(Float(dist)), 1) * SIMD3<Float>(0.035, 0.035, 0.035)
                solids[cubes[r][i]].rotation = SIMD3<Float>(Float.pi/6, Float.pi/4, 0)
            }
        }
    }
}
    
