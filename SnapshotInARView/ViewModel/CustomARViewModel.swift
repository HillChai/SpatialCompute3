//
//  CustomARViewModel.swift
//  SnapshotInARView
//
//  Created by cccc on 2024/3/20.
//

import ARKit
import RealityKit
import SwiftUI

class CustomARViewModel: ARView, ARSessionDelegate, ObservableObject {
    
    @Published var sessionInfolLabel: String = ""
    
    @Published var snapFlag: Bool = false
    
    //savePath
    @Published var recordingTime: String  = ""
    
    //attitudes, photos, BLE
    var jsonObject: [attitudesPhotosBLE] = []
    let BLE = BlueToothViewModel.instance
    
    @AppStorage("isAutoFocus") var isAutoFocus = true
    
    func StartSession(completionHandler: @escaping () -> Void) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.isAutoFocusEnabled = isAutoFocus
        session.delegate = self
        session.run(configuration)
        completionHandler()
    }
    
    // 3. Save it
    func SavePhotos(currentFrame: ARFrame, pixelBuffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            print("Error getting cgImage.")
            return
        }
        
        let uiImage = UIImage(cgImage: cgImage, scale: 1, orientation: .right).jpegData(compressionQuality: 1.0)
        
        let currentTime = String(format: "%f", currentFrame.timestamp)
        
        guard let path = getPathForImage(folderName: recordingTime, name: currentTime) else { return }
        
        DispatchQueue.global(qos: .utility).async {
            do {
                try uiImage?.write(to: path)
    //            print("Image wrote successfully!!")
            } catch let error {
                print("Error saving. \(error)")
            }
        }
    }
    
    func SaveAttitudes(currentframe: ARFrame) {
        let currentTime = String(format: "%f", currentframe.timestamp)
        let arCamera = currentframe.camera
        let positions = positionFromTransform(arCamera.transform)
        let eulerAngles = arCamera.eulerAngles
        let BLEmessages = BLE.completemessage
        let frameData = attitudesPhotosBLE(id: currentTime, position: [positions.x, positions.y, positions.z], eulerAngle: [eulerAngles.x, eulerAngles.y, eulerAngles.z], BLEmessage: BLEmessages)
        
        jsonObject.append(frameData)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        CameraState = frame.camera.trackingState.presentationString
        
        if snapFlag == true {
            
            SavePhotos(currentFrame: frame, pixelBuffer: frame.capturedImage)
            SaveAttitudes(currentframe: frame)
            
            snapFlag = false
        }
        
    }
 
}

// Mark: Private Method
extension CustomARViewModel {
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String

        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect horizontal and vertical surfaces."
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""

        }

        sessionInfolLabel = message
    }
    
}
