/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 The app's content view.
 */

import SwiftUI
import RealityKit
import ARKit
import Combine
import MetalKit

struct GameState {
    var characterSpeed: SIMD2<Float>? // Length between 0 and 1.
    var jumpIndex: UInt = 0
}

struct ContentView: View {
    
    @State private var gameState = GameState()
    @ObservedObject var recogd: ModelRecognizer = .shared
    @State var spawnFood = false
    @GestureState private var isLongPressing = false
    
    var body: some View {
        // Scene
        ZStack {
            
            // Viewport
            ARViewContainer(gameState: gameState, spawnFood: $spawnFood)
                .edgesIgnoringSafeArea(.all)
            
            
            if spawnFood{
                VStack{
                    Spacer()
                    HStack{
                        Button(action: {
                            // Action to perform when the button is tapped
                        }) {
                            Image("vegBag")
                                .resizable()
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
        .onTapGesture(count: 2) {
            // Call your function here
            //            recogd.aView.loadModels()
            print("load models")
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    //    var modelName: String = "dogidle1"
    @ObservedObject var recogd: ModelRecognizer = .shared
    var gameState: GameState
    @Binding var spawnFood : Bool
    
    @State var foodName: String?
    @State var showMeat = false
    @State var showVeg = false
    
    //
    //    public init(gameState: GameState) {
    //        self.gameState = gameState
    //        //self.spawnFood = spawnfood
    //    }
    
    func makeUIView(context: Context) -> UnderwaterView {
        let arView = recogd.aView
        //arView.setup()
        arView.gameState = gameState
        
        
        ///please dont fuck this up
        
        
        let meatEntity = try! Entity.loadModel(named: "Meat.usdz")
        meatEntity.name = "meat"
        meatEntity.scale = SIMD3<Float>(0.0008, 0.0008, 0.0008)
        
        let anchorMeat = AnchorEntity(world: [0, -0.8, -1.16])
        anchorMeat.addChild(meatEntity)
        anchorMeat.isEnabled = false
        
        arView.scene.addAnchor(anchorMeat)
        
        let carrotEntity = try! Entity.loadModel(named: "Carrot.usdz")
        carrotEntity.name = "carrot"
        carrotEntity.scale = SIMD3<Float>(0.0008, 0.0008, 0.0008)
        
        let anchorVeg = AnchorEntity(world: [-0.35, -0.9, -1.21])
        anchorVeg.addChild(carrotEntity)
        anchorVeg.isEnabled = false
        arView.scene.addAnchor(anchorVeg)
        
        // Store the ARView, model, and anchor entities in the context coordinator
        recogd.aView.character?.characterModel.position = SIMD3<Float>(-0.3, -0.65, -2.41)
        
        
        context.coordinator.arView = arView
        context.coordinator.modelEntity = recogd.aView.character?.characterModel
        context.coordinator.anchorEntity = recogd.aView.character?.characterModel.parent as? AnchorEntity
        
        ///please dont fuck this up
        ///
        
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true, block: { _ in
            
            if context.coordinator.modelEntity == nil{
                print("attempt at loading into coordinator")
                recogd.aView.character?.characterModel.position = SIMD3<Float>(0.5, -0.65, -2.41)
                
                context.coordinator.modelEntity = recogd.aView.character?.characterModel
                context.coordinator.anchorEntity = recogd.aView.character?.characterModel.parent as? AnchorEntity
            } else {
                if recogd.spawnMeat || recogd.spawnVeggie{
                    
                    if recogd.spawnMeat {
                        recogd.spawnMeat = false
                        var rotated = false
                        
                        if rotated == false {
                            print("walking to meat and eating")
                            rotated = true
                            anchorMeat.isEnabled = true
                            
                            recogd.aView.character!.stateMachine.enter(eatState.self)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                                recogd.aView.character!.stateMachine.enter(rightState.self)
                            }
                        }
                    } else if recogd.spawnVeggie{
                        recogd.spawnVeggie = false
                        var rotated = false
                        
                        if rotated == false {
                            print("walking to veggie and eating")
                            rotated = true
                            anchorVeg.isEnabled = true
                            
                            recogd.aView.character!.stateMachine.enter(eatState.self)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                                recogd.aView.character!.stateMachine.enter(wrongState.self)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3.01) {
                                    recogd.aView.character!.stateMachine.enter(sleepState.self)
                                }
                            }
                        }
                    }
                    
                    
                } else if recogd.isPinching{
                    var stood = false
                    
                    if stood == false {
                        print("Stood and looking at user")
                        stood = true
                        
                        //recogd.aView.character!.stateMachine.enter(standState.self)
                        
                        let targetPosition = SIMD3<Float>(0, -0.5, -1.35)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            recogd.aView.character!.stateMachine.enter(walkState.self)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                context.coordinator.rotateEntityTowardsTarget(entity: recogd.aView.character!.characterModel, target: targetPosition, duration: 2) {
                                    // This block will be executed after the rotation is complete
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Optional delay before moving
                                        context.coordinator.cobaMoveEntityBaru(recogd.aView.character!.characterModel, target: targetPosition, duration: 7)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 7.1){
                                            recogd.aView.character!.stateMachine.enter(idle2State.self)
                                        }
                                    }
                                }
                            }
                        }
                        
                        spawnFood = true
                        
                    }
                }else {
//                    print(context.coordinator.modelEntity ?? "none")
                }
            }
        })
        
        return arView
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func updateUIView(_ view: UnderwaterView, context: Context) {
        view.gameState = gameState
    }
    
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate{
        var arView: ARView?
        var modelEntity: Entity?
        var anchorEntity: AnchorEntity?
        
        
        func cobaMoveEntityBaru(_ entity: Entity, target: SIMD3<Float>, duration: TimeInterval) {
            // Move to the target position after rotation is complete
            let newTransform = Transform(translation: target)
            entity.move(to: newTransform, relativeTo: entity.parent as? AnchorEntity, duration: duration)
        }
        
        func rotateEntityTowardsTarget(entity: Entity, target: SIMD3<Float>, duration: TimeInterval, completion: @escaping () -> Void) {
            let currentPosition = entity.position(relativeTo: nil)
            
            // Calculate direction vector to the target
            let direction = normalize(target - currentPosition)
            
            // Calculate the angle to rotate around the Y-axis
            let angleY = atan2(direction.x, direction.z) // Y-axis rotation
            
            // Create a quaternion for the rotation
            let targetRotation = simd_quatf(angle: angleY, axis: SIMD3<Float>(0, 1, 0))
            
            // Animate rotation over time
            let animationDuration: Float = Float(duration)
            let steps = 60 * Int(duration) // Number of frames for the animation
            let stepDuration = animationDuration / Float(steps)
            
            for i in 0..<steps {
                let t = Float(i) / Float(steps)
                let interpolatedRotation = simd_slerp(entity.transform.rotation, targetRotation, t)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * Double(stepDuration)) {
                    entity.transform.rotation = interpolatedRotation
                    
                    // Call completion handler when last step is reached
                    if i == steps - 1 {
                        completion()
                    }
                }
            }
        }
    }
    
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
