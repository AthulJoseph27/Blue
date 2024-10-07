import Cocoa
import SwiftUI
import FlutterMacOS

struct WindowViewController: NSViewControllerRepresentable {
    let viewController: NSViewController
    
    func makeNSViewController(context: Context) -> NSViewController {
        return viewController
    }
    
    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {}
    
}

class FlutterView {
    static var flutterViewController: FlutterViewController!
    static var communicationBridge: FlutterCommunicationBridge!
    static var flutterView: WindowViewController!
    
    static func initialize() {
        FlutterView.flutterViewController = FlutterViewController.init()
        communicationBridge = FlutterCommunicationBridge()
        setUpCommunicationBridge()
        RegisterGeneratedPlugins(registry: FlutterView.flutterViewController)
        flutterView = WindowViewController(viewController: FlutterView.flutterViewController)
    }
    
    private static func setUpCommunicationBridge() {
        let methodChannel = FlutterMethodChannel(name: FlutterCommunicationBridge.METHOD_CHANNEL_NAME, binaryMessenger: FlutterView.flutterViewController.engine.binaryMessenger)
        methodChannel.setMethodCallHandler(communicationBridge.handle)
        
        let eventChannel = FlutterEventChannel(name: FlutterCommunicationBridge.EVENT_CHANNEL_NAME, binaryMessenger: FlutterView.flutterViewController.engine.binaryMessenger)
        eventChannel.setStreamHandler(communicationBridge)
    }
}
