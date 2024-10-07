import SwiftUI
import AVFoundation

enum RenderEngine: String {
    case aurora = "aurora"
    case comet = "comet"
}

enum InterpolationCurve {
    case linear
}

class RenderImageModel {
    static var rendering = false
    let quality = RenderQuality.high
    var renderEngine = RenderEngine.comet
    var samples = 400
    var resolution = SIMD2<Int>(x: 512, y: 512)
    var maxBounce = 1
    var alphaTesting = false
    var saveLocation = "/Users/Personal/Downloads/"
    
    init(json: [String : Any]) {
        renderEngine = RenderEngine(rawValue: (json["renderEngine"] as? String) ?? "") ?? renderEngine
      
        let resolution = (json["resolution"] as? [String : Any]) ?? ["x" : 1080, "y": 720]
        self.resolution = SIMD2<Int>(resolution["x"] as! Int, resolution["y"] as! Int)
        
        alphaTesting = (json["alphaTesting"] as? Bool) ?? false
        samples = (json["samples"] as? Int) ?? samples
        maxBounce = (json["maxBounce"] as? Int) ?? maxBounce
        saveLocation = (json["saveLocation"] as? String) ?? saveLocation
    }
    
    func getRenderingSettings() -> RenderingSettings {
        if renderEngine == .comet {
            return VertexShadingSettings()
        } else {
            return RayTracingSettings(quality: quality, samples: samples, maxBounce: maxBounce, alphaTesting: alphaTesting, tileSize: MTLSize(width: 16, height: 16, depth: 1))
        }
    }
    
    func saveRenderImage() {
        guard let texture = RendererManager.getRenderedTexture() else { return }

        let image = texture.toCGImage()
        
        let bitmap = NSBitmapImageRep(cgImage: image!)
        let pngData = bitmap.representation(using: .png, properties: [:])
        
        do {
            if #available(macOS 13.0, *) {
                try pngData?.write(to: URL(filePath: "\(saveLocation)\(Int(Date().timeIntervalSince1970)).png"))
            } else {
                print("Couldn't save image, URL version error. min required macOS 13.0")
            }
        } catch {
            print("\(error)")
        }
    }
}

class RenderAnimationModel {
    static var rendering = false
    let quality = RenderQuality.high
    var renderEngine = RenderEngine.comet
    var samples = 400
    var resolution = SIMD2<Int>(x: 512, y: 512)
    var maxBounce = 1
    var fps = 24
    var alphaTesting = false
    var dynamicScene = false
    var saveLocation = "/Users/Personal/Downloads/Animation/";
    var videoFrameCount = 0
    
    init(json: [String : Any]) {
        renderEngine = RenderEngine(rawValue: (json["renderEngine"] as? String) ?? "") ?? renderEngine
        
        let resolution = (json["resolution"] as? [String : Any]) ?? ["x" : 1080, "y": 720]
        self.resolution = SIMD2<Int>(resolution["x"] as! Int, resolution["y"] as! Int)
        
        dynamicScene = (json["dynamicScene"] as? Bool) ?? false
        alphaTesting = (json["alphaTesting"] as? Bool) ?? false
        samples = (json["samples"] as? Int) ?? samples
        fps = (json["fps"] as? Int) ?? fps
        maxBounce = (json["maxBounce"] as? Int) ?? maxBounce
        saveLocation = (json["saveLocation"] as? String) ?? saveLocation
    }
    
    func getRenderingSettings() -> RenderingSettings {
        if renderEngine == .comet {
            return VertexShadingSettings()
        } else {
            return RayTracingSettings(quality: quality, samples: samples, maxBounce: maxBounce, alphaTesting: alphaTesting, tileSize: MTLSize(width: 16, height: 16, depth: 1))
        }
    }
    
    func saveRenderImage(frame: Int) {
        guard let texture = RendererManager.getRenderedTexture() else { return }
        
        let image = texture.toCGImage()
        
        let bitmap = NSBitmapImageRep(cgImage: image!)
        let pngData = bitmap.representation(using: .png, properties: [:])
        
        videoFrameCount = frame
        
        let directoryPath = "\(NSTemporaryDirectory())tmp"
        
        if !FileManager.default.fileExists(atPath: directoryPath) {
            do {
                try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating directory: \(error)")
            }
        }
        
        do {
            if #available(macOS 13.0, *) {
                try pngData?.write(to: URL(filePath: "\(NSTemporaryDirectory())tmp/\(frame).png"))
            } else {
                print("Couldn't save image, URL version error. min required macOS 13.0")
            }
        } catch {
            print("\(error)")
        }
    }
    
    func saveVideo() {
        let outputURL = URL(fileURLWithPath: "\(saveLocation)/\(Date().timeIntervalSince1970).mp4")
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: resolution.x,
            AVVideoHeightKey: resolution.y,
        ]
        
        print(resolution.x)
        print(resolution.y)
        
        do {
            let assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mp4)
            let videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
            let videoInputAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoInput, sourcePixelBufferAttributes: nil)
            //add the input to the asset writer
            assetWriter.add(videoInput)
            assetWriter.startWriting()
            assetWriter.startSession(atSourceTime: CMTime.zero)
            
            print("Saved frames: \(videoFrameCount)")
            
            for i in 1..<(videoFrameCount + 1) {
                let presentationTime = CMTimeMake(value: Int64(i), timescale: Int32(fps))
                
                let url = URL(fileURLWithPath: "\(NSTemporaryDirectory())tmp/\(i).png")
                
                if let image = NSImage(contentsOf: url) {
                    let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
                    if videoInput.isReadyForMoreMediaData {
                        let pixelBuffer = try pixelBufferFromCGImage(cgImage: cgImage, size: resolution)
                        videoInputAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                    }
                } else {
                    print("Unable to load image from URL")
                }
            }
                
            // Finish writing the video
            videoInput.markAsFinished()
            assetWriter.finishWriting {
                switch assetWriter.status {
                    case .completed:
                        print("Video creation completed")
                    case .failed:
                        print("Video creation failed: \(String(describing: assetWriter.error))")
                    case .cancelled:
                        print("Video creation cancelled")
                    default:
                        break
                    }
            }
            
//            do {
//                try FileManager.default.removeItem(atPath: "\(NSTemporaryDirectory())tmp/")
//            } catch {
//                print("Error removing file: \(error)")
//            }
            
            videoFrameCount = 0
        } catch {
            // Handle errors
        }
        
        print("\(NSTemporaryDirectory())tmp/")
    }
    
    static func getKeyframeAt(at: Double, keyframes: [KeyFrame]) -> KeyFrame {
        if keyframes.isEmpty {
            fatalError("Error rendering animation. Key frames is empty!")
        }
        
        if at >= keyframes.last!.time {
            return KeyFrame(time: at, sceneTime: keyframes.last!.sceneTime, position: keyframes.last!.position, rotation: keyframes.last!.rotation)
        }
        
        if at <= keyframes.first!.time {
            return KeyFrame(time: at, sceneTime: keyframes.first!.sceneTime, position: keyframes.first!.position, rotation: keyframes.first!.rotation)
        }
        
        // `at` time should be between any 2 keyframe
        // do binary search to find the surrounding frames
        var st = 0
        var en = keyframes.count - 1
        
        while st <= en {
            let mid = (st + en) / 2
            if keyframes[mid].time == at {
                st = mid
                break
            } else if keyframes[mid].time > at {
                en = mid - 1
            } else {
                st = mid + 1
            }
        }
        
        // st is the actual position to insert
        assert(st != 0)
        
        let prev = keyframes[st - 1]
        let nxt = keyframes[st]
        
        let ratio = Float((at - prev.time) / (nxt.time - at))
        
        return KeyFrame(time: at, sceneTime: interpolate(a: prev.sceneTime, b: nxt.sceneTime, ratio: ratio), position: interpolate(a: prev.position, b: nxt.position, ratio: ratio), rotation: interpolate(a: prev.rotation, b: nxt.rotation, ratio: ratio))
    }
    
    private static func interpolate(a: SIMD3<Float>, b: SIMD3<Float>, ratio: Float, curve: InterpolationCurve = .linear) -> SIMD3<Float> {
        
        // A______.___________B -> r : 1
        // P = (r * B + A) / (r + 1)
        
        if curve == .linear {
            return (ratio * b + a) / (ratio + 1.0)
        }
        
        fatalError("Unsupported Interpolation")
    }
    
    private static func interpolate(a: Float, b: Float, ratio: Float, curve: InterpolationCurve = .linear) -> Float {
        
        // A______.___________B -> r : 1
        // P = (r * B + A) / (r + 1)
        
        if curve == .linear {
            return (ratio * b + a) / (ratio + 1.0)
        }
        
        fatalError("Unsupported Interpolation")
    }
    
    private func pixelBufferFromCGImage(cgImage: CGImage, size: SIMD2<Int>) throws -> CVPixelBuffer {
        let options = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         size.x,
                                         size.y,
                                         kCVPixelFormatType_32ARGB,
                                         options,
                                         &pixelBuffer)
        guard let buffer = pixelBuffer, status == kCVReturnSuccess else {
            throw NSError(domain: "Error creating pixel buffer", code: 0, userInfo: nil)
        }
        
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: data,
                                width: size.x,
                                height: size.y,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.x, height: size.y))
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return buffer
    }
}
