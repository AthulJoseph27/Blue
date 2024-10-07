import MetalKit

public enum ClearColors {
    static let White: MTLClearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let Black: MTLClearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1.0)
}

class Preferences {
    public static var ClearColor: MTLClearColor = ClearColors.Black
    public static var MainPixelFormat: MTLPixelFormat = .rgba16Float
    public static var MainDepthPixelFormat: MTLPixelFormat = MTLPixelFormat.depth32Float
}
