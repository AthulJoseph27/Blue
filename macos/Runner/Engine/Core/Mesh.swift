import MetalKit
import SceneKit

class Mesh {
    private var modelName:  String!
    private var modelExtension: String!
    private var materialMap: [String : MDLMaterial] = [:]
    private var submeshIds: [uint]
    
    var submeshCount:          Int
    var vertexBuffer:          MTLBuffer!
    var indexBuffers:          [MTLBuffer]
    var materials:             [Material]
    var textures: [MDLMaterialSemantic: [Int32]]
    // TODO: clear this at appropriate place.
    static var allTextures: [Texture] = []
    static var allTextureIds: [Int: Int32] = [:]
    
    init(modelName: String, modelExtension: String = "obj") {
        self.modelName = modelName
        self.modelExtension = modelExtension
        indexBuffers = []
        submeshIds = []
        materials = []
        submeshCount = 0
        textures = [
            .baseColor: [],
            .objectSpaceNormal: [],
            .metallic: [],
            .roughness: [],
            .emission: [],
        ]
        if modelName != "None" {
            try? loadModel()
        }
    }
    
    init(modelPath: String) throws {
        var baseUrl = URL(fileURLWithPath: modelPath)
        self.modelName = baseUrl.lastPathComponent
        self.modelExtension = baseUrl.pathExtension
        baseUrl.deleteLastPathComponent()
        let url = URL(fileURLWithPath: self.modelName, relativeTo: baseUrl)
        
        indexBuffers = []
        submeshIds = []
        materials = []
        textures = [
            .baseColor: [],
            .objectSpaceNormal: [],
            .metallic: [],
            .roughness: [],
            .emission: [],
        ]
        submeshCount = 0
        do {
            try loadModel(url: url)
        } catch let error {
            throw error
        }
    }
    
    private func getTexture(for semantic: MDLMaterialSemantic,
                             in material: MDLMaterial,
                             textureId: Int,
                             textureOrigin: MTKTextureLoader.Origin) -> Texture? {
            let textureLoader = MTKTextureLoader(device: Engine.device)
            guard let materialProperty = material.property(with: semantic) else { return nil }
            guard let sourceTexture = materialProperty.textureSamplerValue?.texture else { return nil }
        let options: [MTKTextureLoader.Option : Any] = [
                MTKTextureLoader.Option.origin : textureOrigin as Any,
                MTKTextureLoader.Option.generateMipmaps : true,
            ]
        
            let tex = try? textureLoader.newTexture(texture: sourceTexture, options: options)
        return Texture(id: textureId, texture: tex)
        }
    
    private func generateTextureId(name: String) -> Int {
        var hasher = Hasher()
        hasher.combine(name)
        
        return hasher.finalize()
    }
    
    private func getMaterial(_ mdlMaterial: MDLMaterial?)->Material {
        var _material = Material(isLit: false)
        
        guard let mdlMaterial else {
            print("MDL Material is nil.")
            return _material
        }
        
        if let ambient = mdlMaterial.property(with: .emission)?.float3Value  { _material.ambient = ambient }
        if let diffuse = mdlMaterial.property(with: .baseColor)?.float3Value { _material.diffuse = diffuse }
        if let specular = mdlMaterial.property(with: .specular)?.float3Value { _material.specular = specular }
        if let shininess = mdlMaterial.property(with: .specularExponent)?.floatValue { _material.shininess = shininess }
        if let opacity = mdlMaterial.property(with: .opacity)?.floatValue { _material.opacity = opacity }
        if let opticalDensity = mdlMaterial.property(with: .materialIndexOfRefraction)?.floatValue { _material.opticalDensity = opticalDensity }
        if let roughness = mdlMaterial.property(with: .roughness)?.floatValue { _material.roughness = roughness }
        if let emissive = mdlMaterial.property(with: .emission)?.float3Value { _material.emissive = emissive }
        
//        if let _mdlMaterial = materialMap[mdlMaterial.name] {
//            _material.emissive = _mdlMaterial.property(with: .emission)!.float3Value
//        }
        
        if (_material.emissive.x + _material.emissive.y + _material.emissive.z) > 0.03 {
            _material.isLit = true
        }
        
//        print("Material \(mdlMaterial.name)")
//        for i in 0..<20 {
//            guard let x = MDLMaterialSemantic(rawValue: UInt(i)) else { break }
//            let val =  mdlMaterial.property(with: x)
//            switch x {
//            case .baseColor:
//                print("Material baseColor \(val?.floatValue) \(val?.float3Value)")
//            case .subsurface:
//                print("Material subsurface \(val?.floatValue) \(val?.float3Value)")
//            case .metallic:
//                print("Material metallic \(val?.floatValue) \(val?.float3Value)")
//            case .specular:
//                print("Material specular \(val?.floatValue) \(val?.float3Value)")
//            case .specularExponent:
//                print("Material specularExponent \(val?.floatValue) \(val?.float3Value)")
//            case .specularTint:
//                print("Material specularTint  \(val?.floatValue) \(val?.float3Value)")
//            case .roughness:
//                print("Material roughness \(val?.floatValue) \(val?.float3Value)")
//            case .anisotropic:
//                print("Material anisotropic  \(val?.floatValue) \(val?.float3Value)")
//            case .anisotropicRotation:
//                print("Material  anisotropicRotation \(val?.floatValue) \(val?.float3Value)")
//            case .sheen:
//                print("Material sheen \(val?.floatValue) \(val?.float3Value)")
//            case .sheenTint:
//                print("Material sheenTint \(val?.floatValue) \(val?.float3Value)")
//            case .clearcoat:
//                print("Material clearcoat \(val?.floatValue) \(val?.float3Value)")
//            case .clearcoatGloss:
//                print("Material clearcoatGloss \(val?.floatValue) \(val?.float3Value)")
//            case .emission:
//                print("Material emission  \(val?.floatValue) \(val?.float3Value)")
//            case .bump:
//                print("Material bump \(val?.floatValue) \(val?.float3Value)")
//            case .opacity:
//                print("Material opacity \(val?.floatValue) \(val?.float3Value)")
//            case .interfaceIndexOfRefraction:
//                print("Material interfaceIndexOfRefraction \(val?.floatValue) \(val?.float3Value)")
//            case .materialIndexOfRefraction:
//                print("Material  materialIndexOfRefraction \(val?.floatValue) \(val?.float3Value)")
//            case .objectSpaceNormal:
//                print("Material objectSpaceNormal \(val?.floatValue) \(val?.float3Value)")
//            case .tangentSpaceNormal:
//                print("Material tangentSpaceNormal \(val?.floatValue) \(val?.float3Value)")
//            case .displacement:
//                print("Material displacement \(val?.floatValue) \(val?.float3Value)")
//            case .displacementScale:
//                print("Material displacementScale \(val?.floatValue) \(val?.float3Value)")
//            case .ambientOcclusion:
//                print("Material ambientOcclusion \(val?.floatValue) \(val?.float3Value)")
//            case .ambientOcclusionScale:
//                print("Material ambientOcclusionScale \(val?.floatValue) \(val?.float3Value)")
//            case .none:
//                print("Material none  \(val?.floatValue) \(val?.float3Value)")
//            case .userDefined:
//                print("Material  userDefined \(val?.floatValue) \(val?.float3Value)")
//            @unknown default:
//                print("Material  \(val?.floatValue) \(val?.float3Value)")
//            }
//            print("Material  \(val?.floatValue) \(val?.float3Value)")
//        }
        
        return _material
    }
    
    private func addMesh(mtkSubmesh: MTKSubmesh!, mdlMesh: MDLSubmesh, submeshId: Int) {
        if mtkSubmesh.mesh == nil {
            return
        }
        
        if submeshIds.isEmpty || submeshIds.last! != submeshId {
            // Add new Texture
            
            if let meshMaterial = mdlMesh.material {
                var material = getMaterial(mdlMesh.material)
                
                let mdlMaterialSemantics: [MDLMaterialSemantic] = [.baseColor, .objectSpaceNormal, .metallic, .roughness, .emission]
                
                mdlMaterialSemantics.forEach { semantic in
                    let textureId = generateTextureId(name: meshMaterial.name)
                    if let indexId = Self.allTextureIds[textureId] {
                        // Already in the cache.
                        textures[semantic]?.append(indexId)
                        return
                    }
                    print("Texture \(meshMaterial.name) \(textureId) \(Self.allTextureIds.count)")
                    let texture = getTexture(for: semantic, in: meshMaterial, textureId: textureId, textureOrigin: .bottomLeft)
                    
                    if let texture {
                        let indexId = Self.allTextureIds[texture.id] ?? Int32(Self.allTextures.count)
                        // The array will always be non-nil as all the semantics which are being used
                        // are initialized in the init.
                        self.textures[semantic]?.append(indexId)
                        if indexId == Self.allTextures.count {
                            Self.allTextures.append(texture)
                            Self.allTextureIds[textureId] = indexId
                        }
                        return
                    }
                    
                    textures[semantic]?.append(-1)
                    switch semantic {
                    case .baseColor:
                        material.isTextureEnabled = false
                    case .objectSpaceNormal:
                        material.isNormalMapEnabled = false
                    case .metallic:
                        material.isMetallicMapEnabled = false
                    case .roughness:
                        material.isRoughnessMapEnabled = false
                    case .emission:
                        material.isEmissionTextureEnabled = false
                    default:
                        break
                    }
                }
                
                materials.append(material)
            }
        }
        
        indexBuffers.append(mtkSubmesh.indexBuffer.buffer)
        submeshCount+=1
    }
    
    private func loadMaterials(url: URL? = nil) {
        let fileURL = url ?? Bundle.main.url(forResource: modelName, withExtension: "mtl")!
        let mtlString = try! String(contentsOf: fileURL)

        let scanner = Scanner(string: mtlString)
        var currentMaterial: MDLMaterial?
        
        var materialName = ""

        while !scanner.isAtEnd {
            var line: String?
            line = scanner.scanUpToString("\n")
            
            if let line = line {
                let components = line.components(separatedBy: .whitespaces)
                
                switch components[0] {
                case "newmtl":
                    materialName = components[1]
                    currentMaterial = MDLMaterial(name: materialName, scatteringFunction: MDLScatteringFunction())
                case "Ke":
                    let emission = SIMD3<Float>(Float(components[1])!, Float(components[2])!, Float(components[3])!)
                    currentMaterial!.setProperty(MDLMaterialProperty(name: "Ke", semantic: .emission, float3: emission))
                default:
                    break
                }
            }
        }
        
        if !materialName.isEmpty {
            materialMap[materialName] = currentMaterial
        }
    }
    
    private func loadModel(url: URL? = nil) throws {
        var _url: URL?
        
        if url != nil {
            _url = url
        } else {
            _url = Bundle.main.url(forResource: modelName, withExtension: modelExtension)
        }
        
        guard let assetURL = _url else {
            throw MeshError.loadFailed("Asset \(String(describing: modelName)) does not exist.")
        }
        
        do {
            if modelExtension == "obj" {
                if url != nil {
                    let mtlFileName = String(modelName).replacingOccurrences(of: ".obj", with: ".mtl")
                    let mtlURL = URL(fileURLWithPath: mtlFileName, relativeTo: url?.baseURL)
                    loadMaterials(url: mtlURL)
                } else {
                    loadMaterials()
                }
            }
            
            let descriptor = MTKModelIOVertexDescriptorFromMetal(VertexDescriptorLibrary.getDescriptor(.Read))
            (descriptor.attributes[0] as! MDLVertexAttribute).name = MDLVertexAttributePosition
            (descriptor.attributes[1] as! MDLVertexAttribute).name = MDLVertexAttributeTextureCoordinate
            (descriptor.attributes[2] as! MDLVertexAttribute).name = MDLVertexAttributeNormal
            (descriptor.attributes[3] as! MDLVertexAttribute).name = MDLVertexAttributeTangent
            (descriptor.attributes[4] as! MDLVertexAttribute).name = MDLVertexAttributeBitangent
            
            let bufferAllocator = MTKMeshBufferAllocator(device: Engine.device)
            let asset: MDLAsset = MDLAsset(url: assetURL,
                                           vertexDescriptor: descriptor,
                                           bufferAllocator: bufferAllocator,
                                           preserveTopology: true,
                                           error: nil)
            
            asset.loadTextures()
            
            var mdlMeshes: [MDLMesh] = []
            do{
                mdlMeshes = try MTKMesh.newMeshes(asset: asset,
                                                  device: Engine.device).modelIOMeshes
                
            } catch {
                throw MeshError.loadFailed("ERROR::LOADING_MESH::__\(String(describing: modelName))__::\(error)")
            }
            
            var mtkMeshes: [MTKMesh] = []
            
            for mdlMesh in mdlMeshes {
                mdlMesh.addTangentBasis(forTextureCoordinateAttributeNamed: MDLVertexAttributeTextureCoordinate, tangentAttributeNamed: MDLVertexAttributeBitangent, bitangentAttributeNamed: MDLVertexAttributeTangent)
                mdlMesh.vertexDescriptor = descriptor
                
                do {
                    let mtkMesh = try MTKMesh(mesh: mdlMesh, device: Engine.device)
                    mtkMeshes.append(mtkMesh)
                } catch {
                    throw MeshError.loadFailed("ERROR::LOADING_MESH::__\(String(describing: modelName))__::\(error)")
                }
            }
            
            if mtkMeshes.count == 0 {
                throw MeshError.loadFailed("ERROR::LOADING_MESH::__NO DATA__")
            }
            
            vertexBuffer = mtkMeshes[0].vertexBuffers[0].buffer
            
            for i in 0..<mtkMeshes[0].submeshes.count {
                let mtkSubmesh = mtkMeshes[0].submeshes[i]
                let mdlSubmesh = mdlMeshes[0].submeshes![i] as! MDLSubmesh
                
                addMesh(mtkSubmesh: mtkSubmesh, mdlMesh: mdlSubmesh, submeshId: i)
            }
        } catch let error {
            throw error
        }
    }
}

enum MeshError: Error {
    case loadFailed(String)
}
