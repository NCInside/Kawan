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
    var modelName: String?
    @ObservedObject var recogd: ModelRecognizer = .shared
    @State var spawnFood = false
    @Binding var deleteOldAnimal: Bool
    @GestureState private var isLongPressing = false

    var body: some View {
            ZStack {
                TameARViewContainer(modelName: modelName, spawnFood: $spawnFood, deleteOldAnimal: $deleteOldAnimal)
                
                if spawnFood{
                    VStack{
                        Spacer()
                        HStack{
                            Button(action: {
                                // Action to perform when the button is tapped
                            }) {
                                Image("vegBag")
                                    .resizable()
                                    .frame(width:150, height: 150)
                                    .padding(.leading)
                            }
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 1.0).onEnded { _ in
                                    // Your action for long press
                                    recogd.spawnVeggie = true
                                    spawnFood = false
                                    print("Fed Veg")
                                }
                            )
                            
                            Spacer()
                            
                            Button(action: {
                                // Action to perform when the button is tapped
                            }) {
                                Image("metBag")
                                    .resizable()
                                    .frame(width:150, height: 150)
                                    .padding(.trailing)
                            }
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 1.0).onEnded { _ in
                                    // Your action for long press
                                    recogd.spawnMeat = true
                                    spawnFood = false
                                    print("Fed Meat")
                                }
                            )
                        }
                    }
                }
            }
        }
}


struct TameARViewContainer: UIViewRepresentable {
    var modelName: String?
    @EnvironmentObject var animalBlueprint: AnimalBlueprint
    @ObservedObject var recogd: ModelRecognizer = .shared
    @Binding var spawnFood: Bool
    @Binding var deleteOldAnimal: Bool
    @State var foodName: String?
    @State var showMeat = false
    @State var showVeg = false

    func makeUIView(context: Context) -> ARView {
        let arView = recogd.aView
        // Create an AR session configuration
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)
        
        
//        if deleteOldAnimal{
//            for anchor in recogd.aView.scene.anchors {
//                recogd.aView.scene.removeAnchor(anchor)
//            }
//            deleteOldAnimal = false
//        }
        
        
        // Load the model and add it to the scene
        let modelEntity = try! Entity.loadModel(named: modelName!)
        modelEntity.name = "Animal"
        
        let carrotEntity = try! Entity.loadModel(named: "Carrot.usdz")
        carrotEntity.name = "carrot"
        let meatEntity = try! Entity.loadModel(named: "Meat.usdz")
        meatEntity.name = "meat"
        
        if modelName!.contains("Cow.usdz"){
            modelEntity.scale = SIMD3<Float>(0.3, 0.3, 0.3)
            for anim in modelEntity.availableAnimations {
                modelEntity.playAnimation(anim.repeat(duration: .infinity),
                                          transitionDuration: 1.25,
                                          startsPaused: false)
            }
        }
        
        carrotEntity.scale = SIMD3<Float>(0.5, 0.5, 0.5)
        meatEntity.scale = SIMD3<Float>(0.5, 0.5, 0.5)

        
        let anchorEntity = AnchorEntity(world: [0, 0, 0])
        let anchorCarrot = AnchorEntity(world: [0, 0, 0])
        let anchorMeat = AnchorEntity(world: [0, 0, 0])
        
        anchorEntity.addChild(modelEntity)
        anchorCarrot.addChild(carrotEntity)
        anchorMeat.addChild(meatEntity)
        
        arView.scene.addAnchor(anchorEntity)
        arView.scene.addAnchor(anchorCarrot)
        arView.scene.addAnchor(anchorMeat)
        
        // Store the ARView, model, and anchor entities in the context coordinator
        context.coordinator.arView = arView
        context.coordinator.modelEntity = modelEntity
        context.coordinator.anchorEntity = anchorEntity
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { _ in
            if recogd.spawnMeat || recogd.spawnVeggie{
                context.coordinator.moveModelToFeedPosition()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                    recogd.feedMeat = false
//                    recogd.feedVeg = false
//                }
                if recogd.spawnMeat{
                    showMeat = true
                    showVeg = false
                }
                if recogd.spawnVeggie{
                    showVeg = true
                    showMeat = false
                }
                
                //animate eating here
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    context.coordinator.moveModelToFeedPosition()

                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4){
                        if recogd.spawnMeat{
                            let key = modelName!.replacingOccurrences(of: ".usdz", with: "")
                            if animalBlueprint.animalDict[key]!.diet.contains("Carnivore"){
                                recogd.feedMeat = true
                                recogd.caught = true
                            }else{
                                recogd.escape = true
                            }
                        }
                        if recogd.spawnVeggie{
                            let key = modelName!.replacingOccurrences(of: ".usdz", with: "")
                            if animalBlueprint.animalDict[key]!.diet.contains("Herbivore"){
                                recogd.feedVeg = true
                                recogd.caught = true
                            }else{
                                recogd.escape = true
                            }
                        }
                    }
                }
                
            } else if recogd.isPinching{
                context.coordinator.moveModelToUserPosition()
                spawnFood = true
            }
        })
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if !uiView.scene.anchors.isEmpty {
            if uiView.scene.anchors.indices.contains(1) {
                uiView.scene.anchors[1].isEnabled = showVeg
            }
            if uiView.scene.anchors.indices.contains(2) {
                uiView.scene.anchors[2].isEnabled = showMeat
            }
        }
        

    }
    
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
                  let modelEntity = modelEntity?.findEntity(named: "Animal")
            else { return }
            
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
            let targetPosition = cameraPosition + forwardDirection * 3.5 // Move 1.5 meters in front of the camera
            
            let lookPos = cameraPosition + forwardDirection * 100

            
            // Animate the model's position to the camera's position
            moveEntity(modelEntity, to: targetPosition, rotation: lookAtRotation, duration: 1.4, cameraPos: lookPos) {
                // Update the anchor's position in the world coordinates
                anchorEntity.position = targetPosition
                // Now that the model is positioned relative to the world, it won't follow the camera anymore
            }
        }
        
        @objc func moveModelToFeedPosition() {
            guard let arView = arView,
                  let currentFrame = arView.session.currentFrame,
                  let anchorEntity = anchorEntity,
                  let modelEntity = modelEntity?.findEntity(named: "Animal")
            else { return }
            
            // Get the current camera transform
            let cameraTransform = currentFrame.camera.transform
            
            // Extract the translation component from the matrix (which represents the position)
            let cameraPosition = SIMD3<Float>(0, 0, -2)

            // Calculate the forward direction vector based on the camera's rotation
            let forwardDirection = SIMD3<Float>(x: -cameraTransform.columns.2.x, y: -cameraTransform.columns.2.y, z: -cameraTransform.columns.2.z)
            
            // Calculate the direction from the entity to the camera
            let cameraDirection = normalize(cameraTransform.translation - anchorEntity.position)
            
            // Calculate the rotation quaternion to face the camera
            let lookAtRotation = simd_quatf(from: [0, 0, 1], to: cameraDirection)

            // Calculate the position in front of the camera
            let targetPosition = cameraPosition + forwardDirection * 1.5
            
            let lookPos = cameraPosition + forwardDirection * 100

            
            // Animate the model's position to the camera's position
            moveEntity(modelEntity, to: targetPosition, rotation: lookAtRotation, duration: 1.95, cameraPos: lookPos) {
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
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

