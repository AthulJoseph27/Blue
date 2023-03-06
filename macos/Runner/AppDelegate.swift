import Cocoa
import SwiftUI
import FlutterMacOS

class AppDelegate: FlutterAppDelegate {    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

@main
struct BlueApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        FlutterView.initialize()

        let device = MTLCreateSystemDefaultDevice()!
        Engine.start(device: device)
        RendererManager.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1080, minHeight: 720)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
