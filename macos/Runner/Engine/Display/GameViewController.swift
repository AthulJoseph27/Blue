import Cocoa
import MetalKit

class NSLabel: NSTextField {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.isBezeled = false
        self.drawsBackground = false
        self.isEditable = false
        self.isSelectable = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GameViewController: NSViewController {

    var mtkView: MTKView!
    var counterView: NSLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let mtkView = self.view as? MTKView else {
            print("View attached to GameViewController is not an MTKView")
            return
        }

        guard let linearSRGB = CGColorSpace(name: CGColorSpace.linearSRGB) else {
            print("Linear SRGB colour space is not supported on this device")
            return
        }
        mtkView.colorspace = linearSRGB

        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }

        mtkView.device = defaultDevice
        
    }
}
