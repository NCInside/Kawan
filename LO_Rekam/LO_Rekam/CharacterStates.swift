/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The states for the underwater diver character.
*/

import Foundation
import RealityKit
import Combine
import GameplayKit

class CharacterState: GKState {
    let animationRoot: Entity
    let animationResource: AnimationResource
    let scene: RealityKit.Scene
    var animationCancellable: Cancellable?
    var animController: AnimationPlaybackController?

    init(jumpAnim: AnimationResource, scene: RealityKit.Scene, animationRoot: Entity) {
        self.scene = scene
        self.animationResource = jumpAnim
        self.animationRoot = animationRoot
    }
}

class eatState: CharacterState {
    override func didEnter(from previousState: GKState?) {
        animController = animationRoot.playAnimation(
            animationResource.repeat(),
            transitionDuration: TimeInterval(3)
        )

    }
}

class idleState: CharacterState {
    override func didEnter(from previousState: GKState?) {
        animController = animationRoot.playAnimation(
            animationResource.repeat(),
            transitionDuration: 3
        )
    }
}

class idle2State: CharacterState {
    override func didEnter(from previousState: GKState?) {
        animController = animationRoot.playAnimation(
            animationResource.repeat(),
            transitionDuration: 3
        )
    }
}

class NLAState: CharacterState {
    override func didEnter(from previousState: GKState?) {
        animController = animationRoot.playAnimation(
            animationResource.repeat(),
            transitionDuration: 3
        )
    }
}

class rightState: CharacterState {
    override func didEnter(from previousState: GKState?) {
        animController = animationRoot.playAnimation(
            animationResource.repeat(),
            transitionDuration: 3
        )
    }
}

class sleepState: CharacterState {
    override func didEnter(from previousState: GKState?) {
        animController = animationRoot.playAnimation(
            animationResource.repeat(),
            transitionDuration: 3
        )
    }
}

class standState: CharacterState {
    override func didEnter(from previousState: GKState?) {
        animController = animationRoot.playAnimation(
            animationResource.repeat(),
            transitionDuration: 3
        )
    }
}


class wrongState: CharacterState {
    override func didEnter(from previousState: GKState?) {
        animController = animationRoot.playAnimation(
            animationResource.repeat(),
            transitionDuration: 3
        )
    }
}

class walkState: CharacterState {
    override func didEnter(from previousState: GKState?) {
        animController = animationRoot.playAnimation(
            animationResource.repeat(),
            transitionDuration: 3
        )
    }
}

