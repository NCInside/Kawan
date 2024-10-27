/*
See LICENSE folder for this sample’s licensing information.

Abstract:
ARView subclass for the underwater scene.
*/

import ARKit
import Combine
import SwiftUI
import RealityKit

enum Feature: String, CaseIterable {
    case diverCharacter
    case postProcessing
    case rkSceneUnderstanding

    var key: String { "feature_\(rawValue)" }

    var enabled: Bool? {
        guard UserDefaults.standard.object(forKey: key) != nil else { return nil }
        return UserDefaults.standard.bool(forKey: key)
    }

    static let features: Set<Feature> = { .init(Feature.allCases.filter { $0.enabled ?? true }) }()
}

class UnderwaterView: ARView, ARSessionDelegate {

    required init(frame: CGRect) {
        super.init(frame: frame)
        loadModels()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var gameState = GameState()


    var features: Set<Feature> { Feature.features }

    public var arView: ARView { return self }

//    let settings: Settings

    private var debugThrottle: Cancellable?

    func set(debugThrottle: Bool) {
        let minFPS = 10.0
        let maxFPS = 120.0
        guard debugThrottle else { self.debugThrottle = nil; return }
        var debugThrottleTime = 0.0
        self.debugThrottle = scene.subscribe(to: SceneEvents.Update.self) { event in
            Thread.sleep(forTimeInterval: 1.0 / (minFPS + 0.5 * (1.0 + sin(debugThrottleTime)) * (maxFPS - minFPS)))
            debugThrottleTime += event.deltaTime
        }
    }

    var cancellables = [AnyCancellable]()
    //var gameState = GameState()

    public var character: Character?

    lazy var fishAnchor: AnchorEntity = {
        let fishAnchor = AnchorEntity(world: .zero)
        scene.addAnchor(fishAnchor)
        return fishAnchor
    }()

    var camera: AnchorEntity?

    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        updateAnchors(anchors: anchors)
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        updateAnchors(anchors: anchors)
    }

    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        for anchor in anchors.compactMap({ $0 as? ARMeshAnchor }) {
            //meshAnchorTracker?.remove(anchor)
        }
    }

    func updateAnchors(anchors: [ARAnchor]) {

        for anchor in anchors.compactMap({ $0 as? ARMeshAnchor }) {
            //meshAnchorTracker?.update(anchor)
        }
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        //postProcessing?.update(frame)
        camera?.transform = .init(matrix: frame.camera.transform)
    }

    var debugOptionsSub: Cancellable?

    func setup() {
        //MetalLibLoader.initializeMetal()
        //setupDebugOptionsSubscription()
        configureWorldTracking()
        loadModels()
        setupPhysicsOrigin()
        setupCameraTracker()
    }

//    private func setupDebugOptionsSubscription() {
//        debugOptionsSub = settings.$view.sink { [weak self] in
//            let setDebugOption = { (option: ARView.DebugOptions, value: Bool) -> Void in
//                if value {
//                    self?.debugOptions.insert(option)
//                } else {
//                    self?.debugOptions.remove(option)
//                }
//            }
//            setDebugOption(.showSceneUnderstanding, $0.showSceneUnderstanding)
//            setDebugOption(.showPhysics, $0.showPhysics)
//            setDebugOption(.showStatistics, $0.showStatistics)
//            self?.set(debugThrottle: $0.throttle)
//        }
//    }

    private func setupPhysicsOrigin() {

        // Set up a good scale for physics. For more information see: https://developer.apple.com/documentation/realitykit/handling_different-sized_objects_in_physics_simulations#3694567

        let physicsOrigin = Entity()
        physicsOrigin.scale = .init(repeating: 0.1)
        let anchor = AnchorEntity(world: SIMD3<Float>())
        anchor.addChild(physicsOrigin)
        scene.addAnchor(anchor)
        self.physicsOrigin = physicsOrigin
    }

    private func setupCameraTracker() {
        let camera = AnchorEntity(world: SIMD3<Float>())
        self.camera = camera
        camera.components.set(CameraComponent())
        scene.addAnchor(camera)
    }

    private func configureWorldTracking() {
        let configuration = ARWorldTrackingConfiguration()

        let sceneReconstruction: ARWorldTrackingConfiguration.SceneReconstruction = .mesh
        if ARWorldTrackingConfiguration.supportsSceneReconstruction(sceneReconstruction) {
            configuration.sceneReconstruction = sceneReconstruction
            //meshAnchorTracker = .init(arView: self)
        }

        let frameSemantics: ARConfiguration.FrameSemantics = [.smoothedSceneDepth, .sceneDepth]
        if ARWorldTrackingConfiguration.supportsFrameSemantics(frameSemantics) {
            configuration.frameSemantics.insert(frameSemantics)
//            if features.contains(.postProcessing) {
//                postProcessing = .init(arView: self)
//            }
        }

        configuration.planeDetection.insert(.horizontal)
        session.run(configuration)
        defer { session.delegate = self }

        arView.renderOptions.insert(.disableMotionBlur)
        if features.contains(.rkSceneUnderstanding) {
            arView.environment.sceneUnderstanding.options.insert([.collision, .physics, .receivesLighting, .occlusion])
        }
    }

    public func loadModels() {

        if features.contains(.diverCharacter) {
            setupDiverCharacter()
        }
    }

    public func anchor(for entity: Entity) -> AnchorEntity {
        let bounds = entity.visualBounds(relativeTo: nil)
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: .init(bounds.extents.x, bounds.extents.y)))
        return anchor
    }
}

extension Publisher {

    func sink(_ receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        sink(
            receiveCompletion: { result in
                switch result {
                case .failure(let error): assertionFailure("\(error)")
                default: return
                }
            },
            receiveValue: receiveValue
        )
    }
}

extension Publisher {
    func sink(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        sink(
            receiveCompletion: { result in
                switch result {
                case .failure(let error): assertionFailure("\(error)")
                default: return
                }
            },
            receiveValue: receiveValue
        )
    }
}

struct CameraComponent: Component {

    static let query = EntityQuery(where: .has(Self.self))
}
