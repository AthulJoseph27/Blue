import MetalKit
import SwiftUI

class GameView: MTKView {
    
    var renderer: Renderer!

    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.device = Engine.device // MTLCreateSystemDefaultDevice()!
        

        self.clearColor = Preferences.ClearColor
        self.colorPixelFormat = Preferences.MainPixelFormat
        self.depthStencilPixelFormat = Preferences.MainDepthPixelFormat
        self.sampleCount = 1
        self.delegate = renderer
        self.framebufferOnly = false
    }
}

//--- Keyboard Input ---
extension GameView {
    override var acceptsFirstResponder: Bool { return true }

    override func keyDown(with event: NSEvent) {
        Keyboard.setKeyPressed(event.keyCode, isOn: true)
    }

    override func keyUp(with event: NSEvent) {
        Keyboard.setKeyPressed(event.keyCode, isOn: false)
    }
}

//--- Mouse Button Input ---
extension GameView {
    override func mouseDown(with event: NSEvent) {
         Mouse.setMouseButtonPressed(button: event.buttonNumber, isOn: true)
    }

    override func mouseUp(with event: NSEvent) {
         Mouse.setMouseButtonPressed(button: event.buttonNumber, isOn: false)
    }

    override func rightMouseDown(with event: NSEvent) {
         Mouse.setMouseButtonPressed(button: event.buttonNumber, isOn: true)
    }

    override func rightMouseUp(with event: NSEvent) {
         Mouse.setMouseButtonPressed(button: event.buttonNumber, isOn: false)
    }

    override func otherMouseDown(with event: NSEvent) {
         Mouse.setMouseButtonPressed(button: event.buttonNumber, isOn: true)
    }

    override func otherMouseUp(with event: NSEvent) {
         Mouse.setMouseButtonPressed(button: event.buttonNumber, isOn: false)
    }
}

// --- Mouse Movement ---
extension GameView {
    override func mouseMoved(with event: NSEvent) {
         setMousePositionChanged(event: event)
    }

    override func scrollWheel(with event: NSEvent) {
        Mouse.scrollMouse(delta: SIMD2<Float>(Float(event.deltaX), Float(event.deltaY)))
    }

    override func mouseDragged(with event: NSEvent) {
         setMousePositionChanged(event: event)
    }

    override func rightMouseDragged(with event: NSEvent) {
         setMousePositionChanged(event: event)
    }

    override func otherMouseDragged(with event: NSEvent) {
         setMousePositionChanged(event: event)
    }

    private func setMousePositionChanged(event: NSEvent){
         let overallLocation = SIMD2<Float>(Float(event.locationInWindow.x),
                                      Float(event.locationInWindow.y))
         let deltaChange = SIMD2<Float>(Float(event.deltaX),
                                  Float(event.deltaY))
         Mouse.setMousePositionChange(overallPosition: overallLocation,
                                      deltaPosition: deltaChange)
    }

    override func updateTrackingAreas() {
         let area = NSTrackingArea(rect: self.bounds,
                                   options: [NSTrackingArea.Options.activeAlways,
                                             NSTrackingArea.Options.mouseMoved,
                                             NSTrackingArea.Options.enabledDuringMouseDrag],
                                   owner: self,
                                   userInfo: nil)
         self.addTrackingArea(area)
    }
}

