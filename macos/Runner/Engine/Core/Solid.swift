import MetalKit

class Solid: Node {
    var meshType: MeshTypes
    var mesh: Mesh
    var isLightSource = false
    var animated = false
    
    init(_ meshType: MeshTypes, isLightSource: Bool = false) {
        self.meshType = meshType
        self.isLightSource = isLightSource
        if meshType == .None {
            self.mesh = Mesh(modelName: "None")
        } else {
            self.mesh = MeshLibrary.mesh(meshType)
        }
        super.init()
    }
    
    override func update(deltaTime: Float) {
    }
}

extension Solid {
    public func setColor(_ color: SIMD3<Float>) {

        mesh.materials[0].diffuse = color
    }
    
    public func setEmissionColor(_ color: SIMD3<Float>) {
        mesh.materials[0].emissive = color
    }
    
    public func setRoughness(_ roughness: Float) {
        mesh.materials[0].roughness = roughness
        mesh.materials[0].specular = SIMD3<Float>(repeating: (1.0 - roughness))
        
    }
    
    public func setOpticalDensity(_ opticalDensity: Float) {
        mesh.materials[0].opticalDensity = opticalDensity
        mesh.materials[0].opacity = 0.9
    }
    
    public func enableTexture(_ enable: Bool) {
        mesh.materials[0].isTextureEnabled = enable
    }
    
    public func enableNormalTexture(_ enable: Bool) {
        mesh.materials[0].isNormalMapEnabled = enable
    }
    
    public func enableEmissionTexture(_ enable: Bool) {
        mesh.materials[0].isEmissionTextureEnabled = enable
    }
    
    public func enableProceduralTexture(_ enable: Bool) {
        mesh.materials[0].isProceduralTextureEnabled = enable
    }
    
    public func enableEmission(_ enable: Bool) {
        mesh.materials[0].isLit = enable
    }
    
    public func updateBaseTexture(_ texture: MTLTexture) {
        // Basic solids have no submeshes
//        mesh.textures[.baseColor]?.removeAll()
//        mesh.textures[.baseColor] = [texture]
    }
    
    public func updateNormalTexture(_ texture: MTLTexture) {
        // Basic solids have no submeshes
//        mesh.normalMapTextures.removeAll()
//        mesh.normalMapTextures.append(texture)
    }
    
    public func updateEmissionTexture(_ texture: MTLTexture) {
//        mesh.emissionMapTextures.removeAll()
//        mesh.emissionMapTextures.append(texture)
    }
}
