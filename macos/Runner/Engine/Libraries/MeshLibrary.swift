import MetalKit
import simd

enum MeshTypes {
    case None
    case Plane
    case Cube
    case Sphere
    case Icosphere
    case Cylinder
    case Cone
    case Torus
    case Monkey
    case Ocean
    case Chest
    case Custom
}

class MeshLibrary {
    private static var meshes: [MeshTypes: Mesh] = [:]
    
    public static func initialize() {
        createDefaultMeshes()
    }
    
    private static func createDefaultMeshes() {
        meshes.updateValue(Mesh(modelName: "Plane"), forKey: .Plane)
        meshes.updateValue(Mesh(modelName: "Cube"), forKey: .Cube)
        meshes.updateValue(Mesh(modelName: "Sphere"), forKey: .Sphere)
        meshes.updateValue(Mesh(modelName: "Icosphere"), forKey: .Icosphere)
        meshes.updateValue(Mesh(modelName: "Cylinder"), forKey: .Cylinder)
        meshes.updateValue(Mesh(modelName: "Cone"), forKey: .Cone)
        meshes.updateValue(Mesh(modelName: "Torus"), forKey: .Torus)
        meshes.updateValue(Mesh(modelName: "Monkey"), forKey: .Monkey)
        meshes.updateValue(Mesh(modelName: "Ocean_100"), forKey: .Ocean)
        meshes.updateValue(Mesh(modelName: "chest"), forKey: .Chest)
    }
    
    public static func loadMesh(filePath: String) throws {
        do {
            let mesh = try Mesh(modelPath: filePath)
            meshes.updateValue(mesh, forKey: .Custom)
        } catch let error {
            throw error
        }
    }
    
    public static func mesh(_ meshTypes: MeshTypes)->Mesh{
        return meshes[meshTypes]!
    }
}
