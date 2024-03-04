//
//  CameraView.swift
//  Sequre
//
//  Created by Kazao TM on 24/05/23.
//

import SwiftUI
import AVFoundation
import TensorFlowLiteTaskVision

struct SequreCameraView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = UIViewController
    
    let cameraService: SequreCameraService
    let didFinishProcessingPhoto: (SequreResult) -> ()
    let onEvent: (Color, String, String) -> ()
        
    func makeUIViewController(context: Context) -> UIViewController {
        
        cameraService.start(delegate: context.coordinator, videoOutputDelegate: context.coordinator, metadataDelegate: context.coordinator) { error in
            if let error = error {
                var result = SequreResult()
                result.error = error
                didFinishProcessingPhoto(result)
                return
            }
        }
        
        let viewController = UIViewController()
        viewController.view.backgroundColor = .black
        viewController.view.layer.addSublayer(cameraService.previewLayer)
        cameraService.previewLayer.frame = CGRect(x: 0, y: 0, width: viewController.view.bounds.width, height: viewController.view.bounds.width / (3 / 4))
        return viewController
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, didFinishProcessingPhoto: didFinishProcessingPhoto, onEvent: onEvent)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate {
        let parent: SequreCameraView
        private var didFinishProcessingPhoto: (SequreResult) -> ()
        private var onEvent: (Color, String, String) -> ()
        private var processing: Bool = false
        private var distances = [CGFloat]()
        private var qrcode: String = ""
        
        private var x = CGFloat.zero, y = CGFloat.zero
        
        let objectDetectionHelper = ObjectDetectionHelper(
            modelFileInfo: ObjectConstants.modelType.modelFileInfo,
            threadCount: ObjectConstants.threadCount,
            scoreThreshold: ObjectConstants.scoreThreshold,
            maxResults: ObjectConstants.maxResults
        )
        
        let objectDetectionHelperV2 = ObjectDetectionHelper(
            modelFileInfo: ObjectConstantsV2.modelType.modelFileInfo,
            threadCount: ObjectConstantsV2.threadCount,
            scoreThreshold: ObjectConstantsV2.scoreThreshold,
            maxResults: ObjectConstantsV2.maxResults
        )
                
        let classificationHelper = ClassificationHelper(
            modelFileInfo: ClassificationConstants.modelType.modelFileInfo,
            threadCount: ClassificationConstants.threadCount,
            resultCount: ClassificationConstants.resultCount,
            scoreThreshold: ClassificationConstants.scoreThreshold
        )
        
        init(parent: SequreCameraView, didFinishProcessingPhoto: @escaping (SequreResult) -> (), onEvent: @escaping (Color, String, String) -> ()) {
            self.parent = parent
            self.didFinishProcessingPhoto = didFinishProcessingPhoto
            self.onEvent = onEvent
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
//                NSLog("qrcode: \(stringValue.uppercased().prefix(15))")
                self.qrcode = stringValue
                if stringValue.uppercased().prefix(15) != "HTTP://QTRU.ST/" {
                    var result = SequreResult()
                    result.qr = stringValue
                    self.didFinishProcessingPhoto(result)
                }
            }
        }
        
        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            DispatchQueue.global(qos: .background).async { [self] in
                self.parent.cameraService.stop()
                NSLog("photoOutput")
                var result = SequreResult()
                result.error = error
                result.image = photo.cgImageRepresentation()
                result.qr = qrcode
                if let error = error {
                    self.didFinishProcessingPhoto(result)
                    self.processing = false
                    return
                }
                
                guard var image = photo.cgImageRepresentation() else {
                    self.didFinishProcessingPhoto(result)
                    self.processing = false
                    return
                }
                image = (UIImage(cgImage: image).rotate(radians: 1.5708)?.cgImage)!
//                UIImageWriteToSavedPhotosAlbum(UIImage(cgImage: image),nil,nil,nil)
                 
                var pixelBuffer = self.pixelBufferFromCGImage(image: image)
                                
                // object detection
                guard let objectResults = self.objectDetectionHelperV2?.detect(frame: pixelBuffer!) else {
                    self.didFinishProcessingPhoto(result)
                    self.processing = false
                    return
                }
                NSLog("objectDetection: highres")
                if objectResults.detections.count > 0 {
                    let detection = objectResults.detections[0]
                    let cropped = image.cropping(to: detection.boundingBox)
                    let scaled = UIImage(cgImage: cropped!).scale()?.cgImage
//                    UIImageWriteToSavedPhotosAlbum(UIImage(cgImage: scaled!),nil,nil,nil)

                    // classification
                    pixelBuffer = self.pixelBufferFromCGImage(image: scaled!)
                    //                print("pixelBuffer: \(pixelBuffer)")
                    guard let classificationResults = self.classificationHelper?.classify(frame: pixelBuffer!) else {
                        self.didFinishProcessingPhoto(result)
                        self.processing = false
                        return
                    }
                    image = (UIImage(cgImage: image).box(bound:detection.boundingBox, color: UIColor.red)?.cgImage)!
                    if classificationResults.classifications.categories.count == 0 {
                        NSLog("objectDetection: not found")
                        self.didFinishProcessingPhoto(result)
                        self.processing = false
                        return
                    }
                    let category = classificationResults.classifications.categories[0]
                    
                    var genuine: Bool? = false
                    if category.label == "genuine" && category.score >= 0.85 {
                        image = (UIImage(cgImage: image).box(bound:detection.boundingBox, color: UIColor.green)?.cgImage)!
                        genuine = true
                    }
//                    UIImageWriteToSavedPhotosAlbum(UIImage(cgImage: image),nil,nil,nil)
                    NSLog("objectDetection: \(category.score)")
                    result.genuine = genuine!
                    result.label = category.label!
                    result.score = category.score
                    self.didFinishProcessingPhoto(result)
                    self.processing = false
                    return
                }
                self.didFinishProcessingPhoto(result)
                self.processing = false
            }
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            if processing {
                return
            }
            DispatchQueue.global(qos: .background).async {
                self.processing = true
//                NSLog("objectDetection")
                let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
                guard let pixelBuffer = pixelBuffer else {
                    self.processing = false
                    return
                }
                let results = self.objectDetectionHelper?.detect(frame: pixelBuffer)
                guard let displayResult = results else {
                    self.processing = false
                    return
                }
                if displayResult.detections.count > 0 {
                    var detection: Detection? = nil
                    for result in displayResult.detections {
                        if detection == nil {
                            detection = result
                        } else {
                            if result.categories[0].score > (detection?.categories[0].score)! {
                                detection = result
                            }
                        }
                    }
                    guard let detection = detection else {
                        self.processing = false
                        return
                    }
                    let screenSize: CGRect = UIScreen.main.bounds
                    self.parent.cameraService.focus(point: CGPoint(x: screenSize.width / 2, y: screenSize.height / 2))
                    var moveCloser = 0.6
                    if self.parent.cameraService.isIphoneLarge() {
                        moveCloser = 0.7
                    }
                    var moveFuther = 0.8
                    
                    let previewSize = CGRect(x: 0, y: 0, width: CVPixelBufferGetHeight(pixelBuffer), height: CVPixelBufferGetWidth(pixelBuffer))
                    let ratio = 2.0 / 4.0
                    let frame = 0.6
                    let width = previewSize.width * frame
                    let height = width / ratio
                    let left = (previewSize.width - width) / 2
                    let top = (previewSize.height - height) / 2
                    
                    let boundingBox = detection.boundingBox.tranform()
                    var debug = "image: (\(CVPixelBufferGetHeight(pixelBuffer)),\(CVPixelBufferGetWidth(pixelBuffer))) boundingBox: (\(Int(boundingBox.width)),\(Int(boundingBox.height)))"
                    self.onEvent(Color.white, "QR found", debug)

                    if !(boundingBox.minX >= left && boundingBox.maxX <= left + width &&
                         boundingBox.minY >= top && boundingBox.maxY <= top + height) {
                        self.onEvent(Color.white, "Place qr inside frame", debug)
                        self.processing = false
                    } else {
                        let percentage = boundingBox.width / width
                        debug = "image: (\(CVPixelBufferGetHeight(pixelBuffer)),\(CVPixelBufferGetWidth(pixelBuffer))) boundingBox: (\(Int(boundingBox.width)),\(Int(boundingBox.height))) percentage: \(percentage)"
                        NSLog(debug)
                        
                        if percentage < moveCloser {
                            self.onEvent(Color.white, "Move Closer", debug)
                            self.processing = false
                        } else if percentage > 0.8 {
                            self.onEvent(Color.white, "Move Further", debug)
                            self.processing = false
                        } else {
                            
//                            NSLog("with: \(screenSize.width) height: \(screenSize.height)")
//                            NSLog("x1: \(boundingBox.minX) y1: \(boundingBox.minY) x2: \(boundingBox.maxX ) y2: \(boundingBox.maxY) width: \(boundingBox.width) height: \(boundingBox.height)")
//                            NSLog("left: \(left) top: \(top) right: \(left + width) bottom: \(top + height)")
                            
                            let distance = sqrt(pow(boundingBox.minX - self.x, 2) + pow(boundingBox.minY - self.y, 2))
                            let length = 3
                            let max = 40.0
                            if self.distances.count >= length {
                                self.distances.removeFirst()
                            }
                            self.distances.append(distance)
                            if self.distances.count == length {
                                // find average
                                var total = CGFloat.zero
                                for distance in self.distances {
                                    total += distance
                                }
                                let average = total / CGFloat(length)
                                NSLog("average: \(average)")
                                debug = "image: (\(CVPixelBufferGetHeight(pixelBuffer)),\(CVPixelBufferGetWidth(pixelBuffer))) boundingBox: (\(Int(detection.boundingBox.width)),\(Int(detection.boundingBox.height))) percentage: \(percentage) average: \(average)"
                                self.onEvent(Color.green, "Hold Steady", debug)
                                
                                if  average <= max {
                                    NSLog("capturePhoto")
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                                        self.parent.cameraService.capturePhoto()
//                                        self.processing = false
                                    }
                                } else {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        self.processing = false
                                    }
                                }
                            } else {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    self.processing = false
                                }
                            }
                            self.x = boundingBox.minX
                            self.y = boundingBox.minY
                        }
                    }
                } else {
                    self.onEvent(Color.gray, "Find QR", "")
                    self.processing = false
                }
            }
        }
        
        func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            //
        }
        
        func pixelBufferFromCGImage(image:CGImage) -> CVPixelBuffer? {
            let options = [
                kCVPixelBufferCGImageCompatibilityKey as String: NSNumber(value: true),
                kCVPixelBufferCGBitmapContextCompatibilityKey as String: NSNumber(value: true),
                kCVPixelBufferIOSurfacePropertiesKey as String: [:]
            ] as CFDictionary

            let size:CGSize = .init(width: image.width, height: image.height)
            var pxbuffer: CVPixelBuffer? = nil
            let status = CVPixelBufferCreate(
                kCFAllocatorDefault,
                Int(size.width),
                Int(size.height),
                kCVPixelFormatType_32BGRA,
                options,
                &pxbuffer)
            guard let pxbuffer = pxbuffer else { return nil }

            CVPixelBufferLockBaseAddress(pxbuffer, [])
            guard let pxdata = CVPixelBufferGetBaseAddress(pxbuffer) else {return nil}

            let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)

            guard let context = CGContext(data: pxdata, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pxbuffer), space: CGColorSpaceCreateDeviceRGB(), bitmapInfo:bitmapInfo.rawValue) else {
                return nil
            }
            context.concatenate(CGAffineTransformIdentity)
            context.draw(image, in: .init(x: 0, y: 0, width: size.width, height: size.height))

            ///error: CGContextRelease' is unavailable: Core Foundation objects are automatically memory managed
            ///maybe CGContextRelease should not use it
//            CGContextRelease(context)
            CVPixelBufferUnlockBaseAddress(pxbuffer, [])
            return pxbuffer
        }
    }
}

enum ModelType: CaseIterable {
    case sequreLite
    case sequreLiteV2
    case classification
    var modelFileInfo: ObjectFileInfo {
        switch self {
            case .sequreLite:
                return ObjectFileInfo("tflite/sequre_object-20230123-me", "tflite")
            case .sequreLiteV2:
                return ObjectFileInfo("tflite/sequre_crop_canvas-20230510hi", "tflite")
            case .classification:
                return ObjectFileInfo("tflite/model_classification_20230308", "tflite")
        }
        var title: String {
            switch self {
                case .sequreLite:
                    return "Sequre-v1"
                case .sequreLiteV2:
                    return "Sequre-v2"
                case .classification:
                    return "Classification-v1"
            }
        }
    }
}
      
struct ObjectConstants {
    static let modelType: ModelType = .sequreLite
    static let threadCount = 1
    static let scoreThreshold: Float = 0.5
    static let maxResults: Int = 3
    static let theadCountLimit = 10
}

struct ObjectConstantsV2 {
    static let modelType: ModelType = .sequreLiteV2
    static let threadCount = 1
    static let scoreThreshold: Float = 0.5
    static let maxResults: Int = 3
    static let theadCountLimit = 10
}

struct ClassificationConstants {
    static let modelType: ModelType = .classification
    static let threadCount = 1
    static let scoreThreshold: Float = 0.5
    static let resultCount: Int = 3
}

extension CGRect {
    func tranform() -> CGRect {
        var newRect = CGRect(x: self.minY, y: self.minX, width: self.height, height: self.width)
        return newRect
    }
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func scale() -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: CGSize(width: self.cgImage!.width, height: self.cgImage!.width)).size
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        // draw white background
        UIColor.white.set()
        withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: newSize))
        
        self.draw(in: CGRect(x: 0, y: self.size.width / 2 - self.size.height / 2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
    func box(bound: CGRect, color: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        draw(at: CGPoint.zero)
        
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(20)
        context.addRect(bound)
        context.drawPath(using: .stroke)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
