//
//  TameView.swift
//  Kawan
//
//  Created by Nicholas Dylan Lienardi on 30/05/24.
//


import SwiftUI
import RealityKit
import ARKit
import Combine
import AVFoundation
import Vision
import simd


struct TameView : View {
    @State private var isPinching = false
    @State private var isOpen = false
    @State private var position = Float()
    @ObservedObject var recogd: ModelRecognizer = .shared

    var body: some View {

        TameARViewContainer()
                    .edgesIgnoringSafeArea(.all)
    }
}

struct TameARViewContainer: UIViewRepresentable {
    @ObservedObject var recogd: ModelRecognizer = .shared

    func makeUIView(context: Context) -> ARView {
        let arView = recogd.aView
        
        // Create an AR session configuration
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)
        
        // Load the model and add it to the scene
        let modelEntity = try! Entity.loadModel(named: "Shiba.usdz")
        let anchorEntity = AnchorEntity(world: [0, 0, 0]) // Initially place the model 0.5 meters in front of the camera
        anchorEntity.addChild(modelEntity)
        arView.scene.addAnchor(anchorEntity)
        
        // Store the ARView, model, and anchor entities in the context coordinator
        context.coordinator.arView = arView
        context.coordinator.modelEntity = modelEntity
        context.coordinator.anchorEntity = anchorEntity
        
        // Add a tap gesture recognizer
//        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.moveModelToUserPosition))
//        arView.addGestureRecognizer(tapGesture)
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
            if recogd.isPinching{
                context.coordinator.moveModelToUserPosition()
            }
        })
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate{
        var arView: ARView?
        var modelEntity: ModelEntity?
        var anchorEntity: AnchorEntity?
        
        @objc func moveModelToUserPosition() {
            guard let arView = arView,
                  let currentFrame = arView.session.currentFrame,
                  let anchorEntity = anchorEntity,
                  let modelEntity = modelEntity else { return }
            
            // Get the current camera transform
            let cameraTransform = currentFrame.camera.transform
            
            // Extract the translation component from the matrix (which represents the position)
            let cameraPosition = SIMD3<Float>(x: cameraTransform.columns.3.x, y: cameraTransform.columns.3.y, z: cameraTransform.columns.3.z)

            // Calculate the forward direction vector based on the camera's rotation
            let forwardDirection = SIMD3<Float>(x: -cameraTransform.columns.2.x, y: -cameraTransform.columns.2.y, z: -cameraTransform.columns.2.z)
            
            // Calculate the direction from the entity to the camera
            let cameraDirection = normalize(cameraTransform.translation - anchorEntity.position)
            
            // Calculate the rotation quaternion to face the camera
            let lookAtRotation = simd_quatf(from: [0, 0, 1], to: cameraDirection)

            // Calculate the position in front of the camera
            let targetPosition = cameraPosition + forwardDirection * 7 // Move 1.5 meters in front of the camera
            
            let lookPos = cameraPosition + forwardDirection * 100

            
            // Animate the model's position to the camera's position
            moveEntity(modelEntity, to: targetPosition, rotation: lookAtRotation, duration: 1.4, cameraPos: lookPos) {
                // Update the anchor's position in the world coordinates
                anchorEntity.position = targetPosition
                // Now that the model is positioned relative to the world, it won't follow the camera anymore
            }
        }
        
        func moveEntity(_ entity: Entity, to targetPosition: SIMD3<Float>, rotation: simd_quatf, duration: TimeInterval, cameraPos: SIMD3<Float>, completion: (() -> Void)?) {
            // Create a new transform with the target position
            var targetTransform = entity.transform
            targetTransform.translation = targetPosition
            //targetTransform.rotation = rotation
            
            // Perform the move animation
            entity.move(to: targetTransform, relativeTo: entity.parent, duration: duration, timingFunction: .easeInOut)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.425) {
                entity.look(at: cameraPos, from: targetPosition, relativeTo: nil)
            }
            
        }
    }
}


extension matrix_float4x4 {
    var translation: SIMD3<Float> {
        return SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z)
    }
}
