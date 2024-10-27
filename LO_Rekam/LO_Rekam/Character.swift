/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The underwater diver character.
*/

import Combine
import RealityKit
import SwiftUI
import GameController
import GameplayKit

class Character {
    
    let stateMachine: GKStateMachine
    
    enum AnimationAssets: String, AnimationAssetNames {
        
        case dogeat
        case dogidle1
        case dogidle2
        case dogNLA
        case dogright
        case dogsleep
        case dogstand
        case dogwalk
        case dogwrong
        
        //var assetName: String { "Dog/\(rawValue)" }
        var assetName: String { "\(rawValue)" }

    }
    
    let entity: Entity
    let characterModel: Entity
    let animationRoot: Entity
    
    let height: Float = 0.4
    let animationScale: Float = 1.5 // scale from the rest pose to the animation
    var characterVerticalSpeed: Float = 0
    
    
//    struct Options {
//        
//        // independent from the character size
//        var gravity: Float = 1.0 // (not yet) in N/Kg
//        
//        // relative to the character size
//        var jumpSpeed: Float = 1.5
//        var walkingSpeed: Float = 0.5
//        var transitionDuration: Float = 1.0
//        var angularSpeed: Float = 100.0
//        var resetTransform: Bool = false
//    }
    
    let animations: [AnimationAssets: AnimationResource]
    
    var lastJump: UInt?
    var controllerJump = false
    var controllerLeftStick: SIMD2<Float> = .init()
    
    init(
        _ view: UnderwaterView,
        model originalModel: Entity,
        animations: [AnimationAssets: AnimationResource]
    ) {
        self.animations = animations
        
        let radius: Float
        characterModel = Entity()
        let clone = originalModel.clone(recursive: true)
        self.animationRoot = clone
        let unscaledModel = clone
        let bounds = unscaledModel.visualBounds(relativeTo: nil)
        let scale = height / bounds.extents.y / animationScale
        radius = sqrt(bounds.extents.x * bounds.extents.x + bounds.extents.z * bounds.extents.z) / 2 * scale
        unscaledModel.scale *= .init(repeating: scale)
        unscaledModel.position.y -= bounds.center.y * unscaledModel.scale.y
        characterModel.addChild(unscaledModel)
        characterModel.position.y -= height / 2
        
        let entity = Entity()
        self.entity = entity
        entity.position.y = height / 2
        entity.addChild(characterModel)
        let anchor = AnchorEntity(
            plane: .horizontal,
            classification: .any,
            minimumBounds: 1.0 * .init(radius, radius)
        )
        anchor.addChild(entity)
        view.scene.addAnchor(anchor)
        entity.components[CharacterControllerComponent.self] = CharacterControllerComponent(
            radius: radius,
            height: height
        )
        
        self.stateMachine = GKStateMachine(states: [
            
            eatState(jumpAnim: animations[.dogeat]!,
                     scene: view.scene,
                     animationRoot: animationRoot),
            idleState(jumpAnim: animations[.dogidle1]!,
                      scene: view.scene,
                      animationRoot: animationRoot),
            idle2State(jumpAnim: animations[.dogidle2]!,
                       scene: view.scene,
                       animationRoot: animationRoot),
            NLAState(jumpAnim: animations[.dogNLA]!,
                     scene: view.scene,
                     animationRoot: animationRoot),
            rightState(jumpAnim: animations[.dogright]!,
                       scene: view.scene,
                       animationRoot: animationRoot),
            sleepState(jumpAnim: animations[.dogsleep]!,
                       scene: view.scene,
                       animationRoot: animationRoot),
            standState(jumpAnim: animations[.dogstand]!,
                       scene: view.scene,
                       animationRoot: animationRoot),
            walkState(jumpAnim: animations[.dogwalk]!,
                      scene: view.scene,
                      animationRoot: animationRoot),
            wrongState(jumpAnim: animations[.dogwrong]!,
                       scene: view.scene,
                       animationRoot: animationRoot),
            
        ])
        
        stateMachine.enter(sleepState.self)
        
        let originalPosition = entity.position(relativeTo: nil)
        //setupUpdate(view: view, originalPosition: originalPosition)
    }
}
extension UnderwaterView {

    func setupDiverCharacter() {
        Entity.loadModelAsync(Character.AnimationAssets.self).sink(receiveValue: {
            let idle = $0[.dogsleep]!
            self.character = Character(
                self,
                model: idle,
                animations: $0.mapValues { $0.availableAnimations.first! }
            )
        }).store(in: &cancellables)
    }
}

protocol AnimationAssetNames: Hashable, CaseIterable {
    var assetName: String { get }
}


extension Entity {

    static func loadAsync<T>(
        _ type: T.Type
    ) -> Publishers.Map<Publishers.Collect<Publishers.MergeMany<Publishers.Map<LoadRequest<Entity>, (T, Entity)>>>, [T: Entity]>
        where T: AnimationAssetNames {
        let anims = type.allCases.map { anim in Entity.loadAsync(named: anim.assetName).map { (anim, $0) } }
        return Publishers.MergeMany(anims).collect().map { [T: Entity](uniqueKeysWithValues: $0) }
    }

    static func loadModelAsync<T>(
        _ type: T.Type
    ) -> Publishers.Map<Publishers.Collect<Publishers.MergeMany<Publishers.Map<LoadRequest<ModelEntity>, (T, ModelEntity)>>>, [T: ModelEntity]>
        where T: AnimationAssetNames {
        let anims = type.allCases.map { anim in Entity.loadModelAsync(named: anim.assetName).map { (anim, $0) } }
        return Publishers.MergeMany(anims).collect().map { [T: ModelEntity](uniqueKeysWithValues: $0) }
    }
}
