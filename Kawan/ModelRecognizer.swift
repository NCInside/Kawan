//
//  ModelRecognizer.swift
//  testVisionKit
//
//  Created by Nicholas Dylan Lienardi on 30/05/24.
//
import SwiftUI
import RealityKit
import CoreML
import Vision
import SceneKit
import ARKit


class ModelRecognizer: ObservableObject {
    private init() { }
    
    static let shared = ModelRecognizer()
    
    @Published var aView = ARView(frame: .zero)
    @Published var isPinching: Bool = false
    
    // call the continuouslyUpdate function every half second
    var timer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true, block: { _ in
        continuouslyUpdate()
    })
}

func continuouslyUpdate() {
    
    @ObservedObject var recogd: ModelRecognizer = .shared
    var visionRequest = VNDetectHumanHandPoseRequest()
    
    // access what we need from the observed object
    let v = recogd.aView
    let sess = v.session
    
    // access the current frame as an image
    let tempImage: CVPixelBuffer? = sess.currentFrame?.capturedImage
    if let tempImage{
        let handler = VNImageRequestHandler(cvPixelBuffer: tempImage, options: [:])
        do {
            try handler.perform([visionRequest])
            if let results = visionRequest.results?.first {
                do {
                    let thumbTip = try results.recognizedPoints(.thumb)[.thumbTip]
                    let indexTip = try results.recognizedPoints(.indexFinger)[.indexTip]

                    if thumbTip?.confidence ?? 0.0 > 0.5 && indexTip?.confidence ?? 0.0 > 0.5 {
                        // Do something with the points
                        print(thumbTip!.confidence)
                        print(indexTip!.confidence)

                        let thumbTipPosition = CGPoint(x: thumbTip!.location.x, y: 1 - thumbTip!.location.y)
                        let indexTipPosition = CGPoint(x: indexTip!.location.x, y: 1 - indexTip!.location.y)

                        // Check for a pinch gesture
                        let distance = hypot(thumbTipPosition.x - indexTipPosition.x, thumbTipPosition.y - indexTipPosition.y)
                        if distance < 0.08 {
                            DispatchQueue.main.async {
                                recogd.isPinching = true
                            }
                        } else {
                            DispatchQueue.main.async {
                                recogd.isPinching = false
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            recogd.isPinching = false
                        }
                    }
                } catch {
                    print("Error processing hand pose observation: \(error.localizedDescription)")
                }
            } else {
                DispatchQueue.main.async {
                    recogd.isPinching = false
                }
            }
        } catch {
            print("Error performing vision request: \(error.localizedDescription)")
        }
    }
}

