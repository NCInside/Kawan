//
//  ContentView.swift
//  Kawan
//
//  Created by Nicholas Christian Irawan on 28/05/24.
//

import SwiftUI
import Photos
import RealityKit

struct ContentView : View {
    
    var body: some View {
        TameARViewContainer()
            .edgesIgnoringSafeArea(.all)
            .overlay(
                Button(action: {takeScreenshotAndSaveToGallery()}) {
                    Label("Screenshot", systemImage: "camera.fill")
                    .font(.system(size: 48))
                }
                .labelStyle(.iconOnly)
                .foregroundColor(.white)
                .offset(y: 325)
            )
    }
    
    func takeScreenshotAndSaveToGallery() {
        guard let rootView = UIApplication.shared.windows.first?.rootViewController?.view else {
                return
            }
            
        for subview in rootView.subviews {
            if let arView = subview as? ARView {
                arView.snapshot(saveToHDR: false) { image in
                    guard let image = image else {
                        print("Failed to capture ARView snapshot")
                        return
                    }
                    image.saveToGallery()
                }
                break
            }
        }
    }

}

extension UIImage {
    func saveToGallery() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: self)
        }) { success, error in
            if success {
                print("Image successfully saved to gallery")
            } else if let error = error {
                print("Error saving image to gallery: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
