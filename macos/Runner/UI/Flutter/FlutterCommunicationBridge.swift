import FlutterMacOS
import SwiftUI

enum FlutterBridgingMethod: String {
    case sendMessage = "send_message"
}

enum SwiftBridgingMethodName: String {
    case renderImage = "renderImage"
    case renderAnimation = "renderAnimation"
    case switchCamera = "switchCamera"
    case queryKeyframeCount = "queryKeyframeCount"
    case getCameraSettings = "getCameraSettings"
    case updateViewportSettings = "updateViewportSettings"
    case updateSceneSettings = "updateSceneSettings"
    case updateCameraSettings = "updateCameraSettings"
    case importScene = "importScene"
    case importSkybox = "importSkybox"
    case switchToStaticRTViewport = "switchToStaticRTViewport"
    case switchToDynamicRTViewport = "switchToDynamicRTViewport"
}

enum SwiftBridgingEvents: String {
    case setPage = "setPage"
    case updateCurrentScene = "updateCurrentScene"
}

enum FlutterPage: String {
    case Settings = "Settings"
    case RenderImage = "RenderImage"
    case RenderAnimation = "RenderAnimation"
}

class FlutterCommunicationBridge: NSObject, FlutterPlugin, FlutterStreamHandler {
    static var METHOD_CHANNEL_NAME: String = "flutter_method_channel"
    static var EVENT_CHANNEL_NAME: String = "flutter_event_channel"
    private var eventSink: FlutterEventSink?
    
    // From Flutter
    public static func register(with registrar: FlutterPluginRegistrar) {}
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = decodeArguments(call.arguments) as [String: Any]? {
            switch call.method {
                case SwiftBridgingMethodName.renderImage.rawValue:
                    SwiftBridgingMethods.renderImage(arguments: args)
                    result(true)
                    break
                case SwiftBridgingMethodName.renderAnimation.rawValue:
                    SwiftBridgingMethods.renderAnimation(arguments: args)
                    result(true)
                    break
                case SwiftBridgingMethodName.queryKeyframeCount.rawValue:
                    let keyframeCount = SwiftBridgingMethods.queryKeyframeCount()
                    result(keyframeCount)
                    break
                case SwiftBridgingMethodName.getCameraSettings.rawValue:
                    let json = SwiftBridgingMethods.getCameraSettings()
                    result(encodeArguments(json))
                    break
                case SwiftBridgingMethodName.updateViewportSettings.rawValue:
                    SwiftBridgingMethods.updateViewportSettings(arguments: args)
                    result(true)
                    break
                case SwiftBridgingMethodName.updateSceneSettings.rawValue:
                    SwiftBridgingMethods.updateScenetSettings(arguments: args)
                    result(true)
                    break
                case SwiftBridgingMethodName.updateCameraSettings.rawValue:
                    SwiftBridgingMethods.updateCameraSettings(arguments: args)
                    result(true)
                    break
                case SwiftBridgingMethodName.importScene.rawValue:
                    let _result = SwiftBridgingMethods.importScene(arguments: args)
                    result(_result)
                    break
                case SwiftBridgingMethodName.importSkybox.rawValue:
                    let _result = SwiftBridgingMethods.importSkybox(arguments: args)
                    result(_result)
                    break
                case SwiftBridgingMethodName.switchCamera.rawValue:  SwiftBridgingMethods.switchCamera(arguments: args)
                    result(true)
                    break
                case SwiftBridgingMethodName.switchToStaticRTViewport.rawValue:
                    SwiftBridgingMethods.switchToStaticRTViewPort()
                    result(true)
                    break
                case SwiftBridgingMethodName.switchToDynamicRTViewport.rawValue:
                    SwiftBridgingMethods.switchToDynamicRTViewPort()
                    result(true)
                    break
                default:
                    result(FlutterMethodNotImplemented)
            }
        }
    }
    
    // To Flutter
    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    func setPage(page: FlutterPage) {
        let argument = ["function" : SwiftBridgingEvents.setPage.rawValue, "page" : page.rawValue]
        sendEvent(arguments: argument)
    }
    
    func sendEvent(arguments: [String: Any]) {
        if(self.eventSink == nil) {
            print("Swift: Event Sink is nil")
        }
        self.eventSink?(encodeArguments(arguments))
    }
    
    // Helper Functions
    private func encodeArguments(_ argument: [String: Any]) -> String {
        
        let jsonData = try? JSONSerialization.data(withJSONObject: argument)
        
        if let jsonData = jsonData, let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return ""
    }
    
    private func decodeArguments(_ argument: Any?) -> [String: Any] {
        if argument == nil {
            return [:]
        }
        
        let jsonString = argument as! String
        let jsonData = jsonString.data(using: .utf8)!
        
        do {
            if let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                return dictionary
            }
        } catch {
            print("Error converting JSON data to dictionary: \(error.localizedDescription)")
        }
        
        return [:]
    }
}

class SwiftBridgingMethods {
    
    static func renderImage(arguments: [String: Any]) {
        if RenderImageModel.rendering {
            return
        }
        
        let model = RenderImageModel(json: arguments)
        
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: model.resolution.x, height: model.resolution.y),
                              styleMask: [.titled, .miniaturizable],
                              backing: .buffered,
                              defer: false)
        
        let rendererType = (model.renderEngine == .aurora) ? RendererType.StaticRT : RendererType.PhongShader
        window.center()
        window.title = "Rendering"
        window.contentView = NSHostingView(rootView: RendererManager.getRendererView(rendererType: rendererType, settings: model.getRenderingSettings()))
        
        let windowController = NSWindowController(window: window)
        windowController.showWindow(nil)
        RendererManager.setRenderMode(settings: model.getRenderingSettings()) {
            model.saveRenderImage()
            DispatchQueue.main.async {
                RenderImageModel.rendering = false
                window.close()
            }
        }
    }
    
    static func renderAnimation(arguments: [String: Any]) {
        if RenderAnimationModel.rendering {
            return
        }
        
        let model = RenderAnimationModel(json: arguments)
        
        let camera =  CameraManager.currentCamera as! AnimationCamera
        var keyframes = camera.getKeyframes()
        
        let offsetTime = keyframes[0].time
        
        if !keyframes.isEmpty {
            for i in 0..<keyframes.count {
                let frame = KeyFrame(time: keyframes[i].time - offsetTime, sceneTime: keyframes[i].sceneTime, position: keyframes[i].position, rotation: keyframes[i].rotation)
                keyframes[i] = frame
            }
        }
        
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: model.resolution.x, height: model.resolution.y),
                              styleMask: [.titled, .miniaturizable],
                              backing: .buffered,
                              defer: false)
        
        window.center()
        window.title = "Rendering"
        
        let rendererType = (model.renderEngine == .aurora) ? RendererType.StaticRT : RendererType.PhongShader
        window.contentView = NSHostingView(rootView: RendererManager.getRendererView(rendererType: rendererType, settings: model.getRenderingSettings()))
       
        let windowController = NSWindowController(window: window)
        windowController.showWindow(nil)
        
        let infoPanel = NSView()
        infoPanel.wantsLayer = true
        infoPanel.layer?.backgroundColor = .white
        infoPanel.layer?.cornerRadius = 10
        infoPanel.frame = CGRect(x: window.contentView!.bounds.width - 200, y: window.contentView!.bounds.height - 80, width: 400, height: 80)
        windowController.window!.contentView!.addSubview(infoPanel)
        
        let timePerFrame = 1.0 / Double(model.fps)
        let totalFrames = Int(ceil(keyframes.last!.time / timePerFrame))
        let frameLabel = NSTextField(labelWithString: "  Frame: 1 / \(totalFrames)")
        frameLabel.font = NSFont.menuFont(ofSize: 16)
        frameLabel.textColor = .black
        frameLabel.frame = NSRect(x: 0, y: -10, width: 200, height: 40)
        frameLabel.alignment = .left
        infoPanel.addSubview(frameLabel)
        
        let ETRLabel = NSTextField(labelWithString: "  ETR: Calculating...")
        ETRLabel.font = NSFont.menuFont(ofSize: 16)
        ETRLabel.textColor = .black
        ETRLabel.frame = NSRect(x: 0, y: 20, width: 200, height: 40)
        ETRLabel.alignment = .left
        infoPanel.addSubview(ETRLabel)
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let renderingQueue = DispatchQueue(label: "com.Blue4.renderingQueue")
        
        renderingQueue.async {
            renderAnimationLoop(model: model, keyframes: keyframes, totalFrames: totalFrames, semaphore: semaphore, window: window, windowController: windowController)
        }
        
    }
    
    static func switchCamera(arguments: [String: Any]) {
        let recordMode = arguments["recordMode"] as? Bool ?? false
        
        if recordMode {
            CameraManager.setCamera(.Animation)
            RendererManager.updateAnimCameraToolBar(recording: false)
        } else {
            if let camera = CameraManager.currentCamera as? AnimationCamera {
                camera.clearKeyframes()
            }
            CameraManager.setCamera(.Debug)
        }
    }
    
    static func queryKeyframeCount() -> Int {
        if let camera = CameraManager.currentCamera as? AnimationCamera {
            return camera.getKeyframes().count
        }
        
        return 0
    }
    
    static func getCameraSettings() -> [String: Any] {
        var json: [String: Any] = [:]
        var positionObject: [String: Float] = [:]
        var rotationObject: [String: Float] = [:]
        
        let position = CameraManager.currentCamera.position
        let rotation = CameraManager.currentCamera.rotation
        
        positionObject["x"] = position.x
        positionObject["y"] = position.y
        positionObject["z"] = position.z
        
        rotationObject["x"] = rotation.x
        rotationObject["y"] = rotation.y
        rotationObject["z"] = rotation.z
        
        json["position"] = positionObject
        json["rotation"] = rotationObject
        
        json["focalLength"] = CameraManager.currentCamera.focalLength
        json["dofBlurStrength"] = CameraManager.currentCamera.dofBlurStrength
        
        return json
    }
    
    static func updateScenetSettings(arguments: [String: Any]) {
        SceneManager.updateSceneSettings(arguments: arguments)
    }
    
    static func updateViewportSettings(arguments: [String: Any]) {
        updateAuroraViewportSettings(arguments: arguments["aurora"] as? ([String: Any]))
        updateCometViewportSettings(arguments: arguments["comet"] as? ([String: Any]))
    }
    
    static func updateCameraSettings(arguments: [String: Any]) {
        var position = CameraManager.currentCamera.position
        if let positionObject = arguments["position"] as? [String: Any] {
            position.x = (positionObject["x"] as? Float) ?? position.x
            position.y = (positionObject["y"] as? Float) ?? position.y
            position.z = (positionObject["z"] as? Float) ?? position.z
            CameraManager.currentCamera.position = position
        }
        
        var rotation = CameraManager.currentCamera.rotation
        if let rotationObject = arguments["rotation"] as? [String: Any] {
            rotation.x = Float((rotationObject["x"] as? Double) ?? Double(rotation.x))
            rotation.y = Float((rotationObject["y"] as? Double) ?? Double(rotation.y))
            rotation.z = Float((rotationObject["z"] as? Double) ?? Double(rotation.z))
            CameraManager.currentCamera.rotation = rotation
        }
        
        if let focalLength = arguments["focalLength"] as? Double {
            CameraManager.currentCamera.focalLength = Float(focalLength)
        }
        
        if let dofBlurStrength = arguments["dofBlurStrength"] as? Double {
            CameraManager.currentCamera.dofBlurStrength = Float(dofBlurStrength)
        }
    }
    
    static func importScene(arguments: [String: Any]) -> Bool {
        do {
            if let filePath = arguments["filePath"] as? String {
                try MeshLibrary.loadMesh(filePath: filePath)
                updateScenetSettings(arguments: ["scene" : "Custom"])
                return true
            }
        } catch {}
        
        return false
    }
    
    static func importSkybox(arguments: [String: Any]) -> Bool {
        do {
            if let filePath = arguments["filePath"] as? String {
                try Skyboxibrary.loadSkyboxFromPath(path: filePath)
                updateScenetSettings(arguments: ["skybox" : "Custom"])
                return true
            }
        } catch {}
        
        return false
    }
    
    static func switchToStaticRTViewPort() -> Void {
        RendererManager.currentRTViewPortType = .StaticRT
    }
    
    static func switchToDynamicRTViewPort() -> Void {
        RendererManager.currentRTViewPortType = .DynamicRT
    }
    
    private static func updateAuroraViewportSettings(arguments: [String: Any]?) {
        if let json = arguments {
            let maxBounce = max((json["maxBounce"] as? Int ?? 6), 1)
            let alphaTesting = json["alphaTesting"] as? Bool ?? false
            let quality = RenderQuality(rawValue: json["resolution"] as? String ?? "high") ?? .high
            
            var tileSize = MTLSize(width: 16, height: 16, depth: 1)
            if let tileSizeJson = json["tileSize"] as? [String: Any] {
                tileSize.width = Int(tileSizeJson["x"] as? Int ?? 16)
                tileSize.height = Int(tileSizeJson["y"] as? Int ?? 16)
            }
            
            RendererManager.updateViewPortSettings(viewPortType: .StaticRT, settings: RayTracingSettings(quality: quality, samples: 400, maxBounce: maxBounce, alphaTesting: alphaTesting, tileSize: tileSize))
            RendererManager.updateViewPortSettings(viewPortType: .DynamicRT, settings: RayTracingSettings(quality: quality, samples: 400, maxBounce: maxBounce, alphaTesting: alphaTesting, tileSize: tileSize))
            
            let settings = ControllSensitivity.fromJson(json: json["controlSensitivity"] as? [String: Any] ?? [:])
            
            RendererManager.updateCameraControllSensitivity(viewPortType: .StaticRT, controllSettings: settings)
            RendererManager.updateCameraControllSensitivity(viewPortType: .DynamicRT, controllSettings: settings)
        }
    }
    
    private static func updateCometViewportSettings(arguments: [String: Any]?) {
        if let json = arguments {
            
            let settings = ControllSensitivity.fromJson(json: json["controlSensitivity"] as? [String: Any] ?? [:])
            RendererManager.updateCameraControllSensitivity(viewPortType: .PhongShader, controllSettings: settings)
        }
    }
    
    private static func renderAnimationLoop(model: RenderAnimationModel, keyframes: [KeyFrame], totalFrames: Int, semaphore: DispatchSemaphore, window: NSWindow, windowController: NSWindowController) {
        
        let rendererType = (model.renderEngine == .aurora) ? (model.dynamicScene ? RendererType.DynamicRT : RendererType.StaticRT) : RendererType.PhongShader
        
        let deltaTime = 1.0 / Double(model.fps)
        let endTime = keyframes.last!.time
        
        var iter = 0
        var time = 0.0
        
//        let startTimestamp = Date().timeIntervalSince1970
        var lastTimestamp = Date().timeIntervalSince1970
        
        while(time <= endTime) {
            time += deltaTime
            iter += 1
            
            let keyframe = RenderAnimationModel.getKeyframeAt(at: time, keyframes: keyframes)
            
            CameraManager.currentCamera.position = keyframe.position
            CameraManager.currentCamera.rotation = keyframe.rotation
            
            SceneManager.setSceneToTick(time: keyframe.sceneTime)
            
            RendererManager.setRenderMode(settings: model.getRenderingSettings()) {
                model.saveRenderImage(frame: iter)
                DispatchQueue.main.async {
                    window.contentView = NSHostingView(rootView: RendererManager.getRendererView(rendererType: rendererType, settings: model.getRenderingSettings()))
                    
                    let currentTimestamp = Date().timeIntervalSince1970
                    let lastTimePerFrame = currentTimestamp - lastTimestamp
                    lastTimestamp = currentTimestamp
                    let estimatedTimeRemaing = Int(ceil(Double(totalFrames - (iter + 1)) * lastTimePerFrame))
                    
                    let infoPanel = NSView()
                    infoPanel.wantsLayer = true
                    infoPanel.layer?.backgroundColor = .white
                    infoPanel.layer?.cornerRadius = 10
                    infoPanel.frame = CGRect(x: window.contentView!.bounds.width - 200, y: window.contentView!.bounds.height - 80, width: 200, height: 80)
                    windowController.window!.contentView!.addSubview(infoPanel)
                    
                    let frameLabel = NSTextField(labelWithString: "  Frame: \(iter + 1) / \(totalFrames)")
                    frameLabel.font = NSFont.menuFont(ofSize: 16)
                    frameLabel.textColor = .black
                    frameLabel.frame = NSRect(x: 0, y: -10, width: 200, height: 40)
                    frameLabel.alignment = .left
                    infoPanel.addSubview(frameLabel)
                    
                    let ETRLabel = NSTextField(labelWithString: "  ETR: \(formatEstimatedTime(time: estimatedTimeRemaing))")
                    ETRLabel.font = NSFont.menuFont(ofSize: 16)
                    ETRLabel.textColor = .black
                    ETRLabel.frame = NSRect(x: 0, y: 20, width: 200, height: 40)
                    ETRLabel.alignment = .left
                    infoPanel.addSubview(ETRLabel)
                    
                    semaphore.signal()
                }
            }
            
            semaphore.wait()
        }
        
        RenderAnimationModel.rendering = false
        model.saveVideo()
        
        DispatchQueue.main.async {
            window.close()
        }
    }
    
    private static func formatEstimatedTime(time: Int) -> String {
        let hour = time / 3600
        let min = (time % 3600) / 60
        let sec = time % 60
        
        var label = ""
        
        if hour > 0 {
            if hour == 1 {
                label += "\(hour) hr "
            } else {
                label += "\(hour) hrs "
            }
        }
        
        if hour > 0 || min > 0 {
            if min <= 1 {
                label += "\(min) min "
            } else {
                label += "\(min) mins "
            }
        }
        
        label += "\(sec) s"
        
        return label
    }
}
