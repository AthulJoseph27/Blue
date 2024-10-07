import MetalKit
import MetalPerformanceShaders

class Ocean: GameScene {
    var originalPositions: [SIMD3<Float>] = []
    
    let e: Float = 2.718281828459045
    let g : Float = 9.8

    override func buildScene() {
        
        sceneTick = Float.pi / 8.0
        
        addLight(light: Light(type: UInt32(LIGHT_TYPE_AREA), position: SIMD3<Float>(0, 1.98, 0), forward: SIMD3<Float>(0, -1, 0), right: SIMD3<Float>(0.25, 0, 0), up: SIMD3<Float>(0, 0, 0.25), color: SIMD3<Float>(0, 0, 0)))
        
        let plane = Solid(.Ocean)
        plane.setColor(SIMD3<Float>(0.2, 0.2, 0.8))
        plane.position = SIMD3<Float>(0, 0.5, 0)
        plane.enableProceduralTexture(true)
        plane.setRoughness(1.0)
        plane.setOpticalDensity(1.5)
        plane.enableTexture(false)
        plane.animated = true
        addSolid(solid: plane)
        
        let vertexCount = plane.mesh.vertexBuffer.length / MemoryLayout<VertexIn>.stride
        let vertices = plane.mesh.vertexBuffer.contents().bindMemory(to: VertexIn.self, capacity: vertexCount)
        
        for i in 0..<vertexCount {
            originalPositions.append(vertices[i].position)
        }
        
//        CameraManager.currentCamera.position = SIMD3<Float>(-0.11, 0.55, 0.93)
//        CameraManager.currentCamera.rotation = SIMD3<Float>(-5.71, -21.2, 0) * Float.pi / 180.0
        updateSolids = animate
    }
    
    override internal func animate(solids: [Solid], time: Float) {
        let solid = solids[solids.count - 1]
        let vertexCount = solid.mesh.vertexBuffer.length / MemoryLayout<VertexIn>.stride
            let vertices = solid.mesh.vertexBuffer.contents().bindMemory(to: VertexIn.self, capacity: vertexCount)

            for i in 0..<vertexCount {
                var vertex = vertices[i]
                
                var delta =
                TrochoidalWave(index: i, position: vertex.position, t: time / 100.0, direction: SIMD2<Float>(1, 1), λ: 0.67, steepness: 0.25)
//                +
//                TrochoidalWave(index: i, position: vertex.position, t: time / 100.0, direction: SIMD2<Float>(1, 0.6), λ: 0.31, steepness: 0.25)
//                +
//                TrochoidalWave(index: i, position: vertex.position, t: time / 100.0, direction: SIMD2<Float>(0.87, 1.3), λ: 0.25, steepness: 0.18)
//                +
//                TrochoidalWave(index: i, position: vertex.position, t: time / 100.0, direction: SIMD2<Float>(0.7, 0.2), λ: 0.2, steepness: 0.08)
//                +
//                TrochoidalWave(index: i, position: vertex.position, t: time / 100.0, direction: SIMD2<Float>(0.93, 0.3), λ: 0.05, steepness: 0.18)
//                +
//                TrochoidalWave(index: i, position: vertex.position, t: time / 100.0, direction: SIMD2<Float>(0.8, 0.3), λ: 0.1, steepness: 0.18)
//                +
//                TrochoidalWave(index: i, position: vertex.position, t: time / 100.0, direction: SIMD2<Float>(0.1, 0.36), λ: 0.15, steepness: 0.08)
                
                
                for l in 3..<delta.count {
                    delta[l%3] += delta[l]
                }
                
                vertex.position = originalPositions[i] + delta[0]
//                vertex.tangent = delta[1]
                vertex.normal = delta[2]
                
                vertices[i] = vertex
            }
    }
    
    private func TrochoidalWave(index: Int, position: SIMD3<Float>, t: Float, direction: SIMD2<Float>, λ: Float = 4.0, steepness: Float = 0.5) -> [SIMD3<Float>] {
    
        let k = 2 * Float.pi / λ
        let c = sqrtf(g / k)
        let d = normalize(direction)
        let a = steepness / k
        
        let f = k * (dot(d, SIMD2<Float>(originalPositions[index].x, originalPositions[index].z)) + c * t)
        
        
        let x = a * cos(f) * d.x
        let y = a * sin(f)
        let z = a * cos(f) * d.y
        
        let newPosition = SIMD3<Float>(x, y, z)
        
        let tangent = SIMD3<Float>(1 - d.x * d.x * steepness * sin(f), d.x * steepness * cos(f), -d.x * d.y * steepness * sin(f))
        
        let binormal = SIMD3<Float>(-d.x * d.y * steepness * sin(f), d.y * steepness * cos(f), -d.y * d.y * steepness * sin(f))
        
        let normal = normalize(cross(binormal, tangent))
        
        return [newPosition, tangent, normal]
    }
}
    
