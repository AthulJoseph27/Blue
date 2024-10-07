import MetalKit
import simd

enum SkyboxTypes: String {
    case Sky = "Sky"
    case Beach = "Beach"
    case NightCity = "NightCity"
    case Jungle = "Jungle"
    case Custom = "Custom"
}

class Skyboxibrary {
    private static var skyboxes: [SkyboxTypes : MTLTexture] = [:]
    
    public static func initialize() {
        loadSkyboxes()
    }
    
    public static func skybox(_ skyboxType: SkyboxTypes) -> MTLTexture {
        return skyboxes[skyboxType]!
    }
    
    public static func loadSkyboxFromPath(path: String) throws {
        let url = URL(fileURLWithPath: path)
        do {
            if let texture = try? loadTextureFromURL(url: url) {
                skyboxes.updateValue(texture, forKey: .Custom)
            } else {
                throw SkyboxError.loadError("Failed to load texture at \(path)")
            }
        } catch let error {
            throw error
        }
    }
    
    private static func loadSkyboxes() {
        skyboxes.updateValue(loadTextureFromBundle(textureName: "Beach", ext: "jpeg"), forKey: .Beach)
        skyboxes.updateValue(loadTextureFromBundle(textureName: "Jungle", ext: "jpg"), forKey: .Jungle)
        skyboxes.updateValue(loadTextureFromBundle(textureName: "NightCity", ext: "jpg"), forKey: .NightCity)
        skyboxes.updateValue(loadTextureFromBundle(textureName: "Sky", ext: "jpg"), forKey: .Sky)
        skyboxes.updateValue(loadTextureFromBundle(textureName: "Sky", ext: "jpg"), forKey: .Custom)
    }
    
    private static func loadTextureFromBundle(textureName: String, ext: String) -> MTLTexture {
        var result: MTLTexture!
        
        if let url = Bundle.main.url(forResource: textureName, withExtension: ext) {
            result = try! loadTextureFromURL(url: url)!
            return result
        } else {
            print("ERROR::CREATING::TEXTURE::__\(textureName) doesn't exist")
        }
        
        return result
    }
    
    private static func loadTextureFromURL(url: URL) throws -> MTLTexture? {
        var result: MTLTexture?
        
        let textureLoader = Engine.textureLoader
        let options: [MTKTextureLoader.Option : Any] = [MTKTextureLoader.Option.origin: MTKTextureLoader.Origin.topLeft]
        
        do {
            result = try textureLoader?.newTexture(URL: url, options:  options)
            result?.label = url.lastPathComponent.replacingOccurrences(of: ".\(url.pathExtension)", with: "")
        } catch let error {
            throw error
        }
        
        return result
    }
    
}

enum SkyboxError: Error {
    case loadError(String)
}
