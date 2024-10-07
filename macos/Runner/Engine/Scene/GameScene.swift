import MetalKit

class GameScene {
    var sceneTick: Float? = nil
    var ambient : Float = 0
    var skybox: SkyboxTypes = .Sky
    
    var solids: [Solid] = []
    var lights: [Light] = []
    var cameraManager = CameraManager()
    
    var updateSolids : (_ solids: [Solid], _ time: Float) -> Void
        
    init(skybox: SkyboxTypes = .Sky, ambient: Float = 0, lights: [Light] = []) {
        self.ambient = ambient
        self.skybox = skybox
        self.lights = lights
        self.updateSolids = {(solids: [Solid], time: Float) -> Void in }
        buildScene()
    }
    
    func buildScene() {}
    
    func addSolid(solid: Solid) {
        solids.append(solid)
    }
    
    func addLight(light: Light) {
        lights.append(light)
    }
    
    func updateSkybox(skybox: SkyboxTypes) {
        self.skybox = skybox
    }
    
    func updateAmbient(ambient: Float) {
        self.ambient = ambient
    }
    
    func updateSceneLights(lights: [Light]) {
        self.lights = lights
    }
    
    internal func animate(solids: [Solid], time: Float) {}
    
    func createCube(faceMask: uint32, color: SIMD3<Float>, reflectivity: Float, refractiveIndex: Float = -1, transform: matrix_float4x4, inwardNormals: Bool, triangleMask: uint32, material: Material? = nil) {
        
        var cubeVertices = [
            SIMD3<Float>(-0.5, -0.5, -0.5),
            SIMD3<Float>( 0.5, -0.5, -0.5),
            SIMD3<Float>(-0.5,  0.5, -0.5),
            SIMD3<Float>( 0.5,  0.5, -0.5),
            SIMD3<Float>(-0.5, -0.5,  0.5),
            SIMD3<Float>( 0.5, -0.5,  0.5),
            SIMD3<Float>(-0.5,  0.5,  0.5),
            SIMD3<Float>( 0.5,  0.5,  0.5),
        ]
        
        for i in 0..<8 {
            let vertex = cubeVertices[i];
            
            var transformedVertex = vector4(vertex.x, vertex.y, vertex.z, 1.0)
            transformedVertex = transform * transformedVertex;
            
            cubeVertices[i] = SIMD3<Float>(transformedVertex.x, transformedVertex.y, transformedVertex.z);
        }
        
        if ((faceMask & Masks.FACE_MASK_NEGATIVE_X) != 0) {
            createCubeFace(cubeVertices, color, reflectivity, refractiveIndex, 0, 4, 6, 2, inwardNormals, triangleMask, material: material)
        }
        
        if ((faceMask & Masks.FACE_MASK_POSITIVE_X) != 0) {
            createCubeFace(cubeVertices, color, reflectivity, refractiveIndex, 1, 3, 7, 5, inwardNormals, triangleMask, material: material)
        }
        
        if ((faceMask & Masks.FACE_MASK_NEGATIVE_Y) != 0) {
            createCubeFace(cubeVertices, color, reflectivity, refractiveIndex, 0, 1, 5, 4, inwardNormals, triangleMask, material: material)
        }
        
        if ((faceMask & Masks.FACE_MASK_POSITIVE_Y) != 0) {
            createCubeFace(cubeVertices, color, reflectivity, refractiveIndex, 2, 6, 7, 3, inwardNormals, triangleMask, material: material)
        }
        
        if ((faceMask & Masks.FACE_MASK_NEGATIVE_Z) != 0) {
            createCubeFace(cubeVertices, color, reflectivity, refractiveIndex, 0, 2, 3, 1, inwardNormals, triangleMask, material: material)
        }
        
        if ((faceMask & Masks.FACE_MASK_POSITIVE_Z) != 0) {
            createCubeFace(cubeVertices, color, reflectivity, refractiveIndex, 4, 5, 7, 6, inwardNormals, triangleMask, material: material)
        }
    }
    
    private func createCubeFace(_ cubeVertices: [SIMD3<Float>],_ color: SIMD3<Float>,_ reflectivity: Float, _ refractiveIndex: Float, _ i0: Int,_ i1: Int,_ i2: Int,_ i3: Int,_ inwardNormals: Bool,_ triangleMask: uint32, material: Material? = nil) {
        
        let v0 = cubeVertices[i0]
        let v1 = cubeVertices[i1]
        let v2 = cubeVertices[i2]
        let v3 = cubeVertices[i3]
        
        var n0 = getTriangleNormal(v0: v0, v1: v1, S: v2)
        var n1 = getTriangleNormal(v0: v0, v1: v2, S: v3)
        
        if (inwardNormals) {
            n0 = -n0;
            n1 = -n1;
        }
        
        var opacity = 1.0
        if refractiveIndex >= 1.0 {
            opacity = 0
        }
        var _material = material ?? Material(isLit: false, diffuse: color, opacity: Float(opacity), opticalDensity: refractiveIndex,  roughness: 1.0 - reflectivity, isTextureEnabled: false, isNormalMapEnabled: false, isMetallicMapEnabled: false, isRoughnessMapEnabled: false)
            
        if triangleMask == TRIANGLE_MASK_LIGHT {
            _material.isLit = true
            _material.emissive = color
            _material.opacity = 1.0
        }
        
        addTriangle(v0: v0, v1: v1, v2: v2, n0: n0, material: &_material, triangleMaks: triangleMask)
        addTriangle(v0: v0, v1: v2, v2: v3, n0: n1, material: &_material, triangleMaks: triangleMask)
    }
    
    private func addTriangle(v0: SIMD3<Float>, v1: SIMD3<Float>, v2: SIMD3<Float>, n0: SIMD3<Float>, material: inout Material, triangleMaks: UInt32) {
        let solid = Solid(.None)
        
        solid.mesh.submeshCount = 1
        let mdlMaterialSemantics: [MDLMaterialSemantic] = [.baseColor, .objectSpaceNormal, .metallic, .roughness, .emission]
        mdlMaterialSemantics.forEach { semantic in
            solid.mesh.textures[semantic]?.append(-1)
        }
        
        if triangleMaks == TRIANGLE_MASK_LIGHT {
            solid.isLightSource = true
        }
        
        var vertices: [VertexIn] = []
        vertices.append(VertexIn(position: v0, uvCoordinate: SIMD2<Float>(0, 1), normal: n0, tangent: SIMD3<Float>(repeating: 1), bitangent: SIMD3<Float>(repeating: 1)))
        vertices.append(VertexIn(position: v1, uvCoordinate: SIMD2<Float>(-1, -1), normal: n0, tangent: SIMD3<Float>(repeating: 1), bitangent: SIMD3<Float>(repeating: 1)))
        vertices.append(VertexIn(position: v2, uvCoordinate: SIMD2<Float>(1, -1), normal: n0, tangent: SIMD3<Float>(repeating: 1), bitangent: SIMD3<Float>(repeating: 1)))
        
        var indicies: [UInt32] = [0, 1, 2]
        
        solid.mesh.vertexBuffer = Engine.device.makeBuffer(bytes: &vertices, length: VertexIn.stride(vertices.count), options: .storageModeShared)
        
        let indexBuffer: MTLBuffer = Engine.device.makeBuffer(bytes: &indicies, length: UInt32.stride(indicies.count), options: .storageModeShared)!
        solid.mesh.indexBuffers = [indexBuffer]
        
        solid.mesh.materials = [material]
        
        solids.append(solid)
    }
    
    private func getTriangleNormal(v0: SIMD3<Float>, v1: SIMD3<Float>, S v2: SIMD3<Float>) -> SIMD3<Float> {
        let e1: SIMD3<Float> = normalize(v1 - v0);
        let e2: SIMD3<Float> = normalize(v2 - v0);
        
        return cross(e1, e2);
    }
}
