//
//  DataModel.swift
//  DataModel
//
//  Created by Bogdan Farca on 26.08.2021.
//

import Foundation
import Combine
import RealityKit
import SwiftUI
import ARKit
import FocusEntity

final class LapDataModel: ObservableObject {
    
    static var shared = LapDataModel()
        
    @Published var arView: ARView!
    
    @Published var currentSpeed: Int = 0
    @Published var currentRPM: Int = 0
    @Published var currentGear: Int = 0
    @Published var currentSector: Int = 0
    @Published var currentLap: Int = 0
        
    private var carPositions: [Motion] = []
    private var fastestLapPositions: [Motion] = []

    private var currentFrame = 0
    
    private var sceneEventsUpdateSubscription: Cancellable!
    private var carAnchor: AnchorEntity?
    private var focusEntity: FocusEntity?

    private var cancellable = Set<AnyCancellable>()
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
         guard let view = self.arView else { return }
         debugPrint("Anchors added to the scene: ", anchors)
         self.focusEntity = FocusEntity(on: view, style: .classic(color: .yellow))
     }
    
    init () {
        // load the fastest lap
        //loadFastestLap()
        
        // Create the 3D view
        arView = ARView(frame: .zero)
        configure()
        #if !targetEnvironment(simulator) && !os(macOS)
        arView.addCoaching()
        #endif

        // • The reference track, positioned in Reality Composer to match the API coordinated
        let carScene = try! COTA.loadTrack()
        // Hidding the reference track
        let myTrack = carScene.track3!
        myTrack.isEnabled = false
        
        // • Loading the nice track from the usdc file
        let myTrackTransformed = try! Entity.load(named: "1960Final")
        
        let trackAnchor = AnchorEntity(world: .zero)
        trackAnchor.name = "track3"
        trackAnchor.addChild(myTrackTransformed)
        
        myTrackTransformed.orientation = simd_quatf(angle: .pi/4, axis: [0,1,0])
        
        
        arView.scene.addAnchor(trackAnchor)
        arView.scene.addAnchor(carScene)

        trackAnchor.isEnabled = false
        // • The camera
        #if os(macOS)
        let cameraEntity = PerspectiveCamera()
        cameraEntity.camera.fieldOfViewInDegrees = 60
        let cameraAnchor = AnchorEntity(world: .zero)
        cameraAnchor.name = "camera"
        cameraAnchor.addChild(cameraEntity)
        arView.scene.addAnchor(cameraAnchor)
        #endif
        
        // • The car
        let myCar = carScene.car!
        myCar.name = "car"
        
        
        
        print(myCar)
        myCar.transform.scale = [1, 1, 1] * 0.00001
        myCar.orientation = simd_quatf(angle: .pi/2, axis: [0,1,0])
        let trackingCone = carScene.trackingCone!

        //        let fastestCar = myCar.clone(recursive: true)
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recogniser:))))

        // Initially position the camera
        #if os(macOS)
        cameraEntity.look(at: myTrack.position, from: [0,50,0], relativeTo: nil)
        #endif
                
        sceneEventsUpdateSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) { _ in
            guard AppModel.shared.appState == .playing else { return }
                                    
            let cp = self.carPositions[self.currentFrame]
            self.currentSpeed = cp.mSpeed
            self.currentRPM = cp.mEngineRPM
            self.currentGear = cp.mGear
            self.currentSector = cp.mSector
            self.currentLap = cp.mCurrentLap
//            
//            let box = MeshResource.generateBox(size: 0.05, cornerRadius: 0.005)
//            let material = SimpleMaterial(color: .blue, isMetallic: true)
//            let spot = AnchorEntity(world: .zero)
//            spot.addChild(ModelEntity(mesh: box, materials: [material]))
//            spot.position = myCar.position
//            self.arView.scene.addAnchor(spot)
//            
            myCar.position = SIMD3<Float>([cp.mWorldposy, cp.mWorldposz, cp.mWorldposx]/1960)
            myCar.transform.rotation = Transform(pitch: cp.mPitch, yaw: cp.mYaw, roll: cp.mRoll).rotation
            myCar.transform = myTrackTransformed.convert(transform: myCar.transform, to: myTrack)

            #if os(macOS)
            cameraEntity.look(at: myCar.position, from: [0.1,0.1,0], relativeTo: nil)
            #else
            trackingCone.position = [myCar.position.x, myCar.position.y + 0.05, myCar.position.z]
            #endif

            self.currentFrame = (self.currentFrame < self.carPositions.count - 1) ? (self.currentFrame + 1) : 0
        }
    }
    
    @objc
    func handleTap(recogniser: UITapGestureRecognizer){
        let location = recogniser.location(in:arView)

        let results = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = results.first {
            print(firstResult)
            
            for anchor in arView.scene.anchors{
                print(anchor.isEnabled)
                print(anchor.name)
            }
//            print(arView.scene.anchors
            let carEntity = arView.scene.findEntity(named: "car")
            let trackEntity = arView.scene.findEntity(named: "track3")
            
            carEntity?.isEnabled = true
            trackEntity?.isEnabled = true

            
        } else {
            print("No Horizontal Plane Found!")
        }
        
    }
    
    
    private func loadFastestLap() {
        self.fastestLapPositions = []
        
        URLSession.shared
            .dataTaskPublisher(for: URL(string: "https://apigw.withoracle.cloud/livelaps/carData/fastestlap")!)
            .map (\.data)
            .decode(type: LapData.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .sink { completion in
                print (completion)

                switch completion {
                    case .finished: () // done, nothing to do
                    case let .failure(error) : AppModel.shared.appState = .error(msg: error.localizedDescription)
                }
            } receiveValue: { items in
                self.fastestLapPositions.append(contentsOf: items)
                print("*-")
            }
            .store(in: &self.cancellable)
    }
    
    func load(session: Session) {
        AppModel.shared.appState = .loadingTrack
        self.cancellable = []
        self.carPositions = []
        self.currentFrame = 0
        
        fetchPositionData(for: session)
            .receive(on: RunLoop.main)
            .sink { completion in
                print (completion)
                
                switch completion {
                    case .finished: () // done, nothing to do
                    case let .failure(error) : AppModel.shared.appState = .error(msg: error.localizedDescription)
                }
            } receiveValue: { items in
                self.carPositions.append(contentsOf: items)
                
                if self.carPositions.count > 0 {
                    AppModel.shared.appState = .stopped // we start playing after the first lap is loaded, the rest are coming in the background
                }
                
                print("*")
            }
            .store(in: &self.cancellable)
    }
    
    private func fetchPositionData(for session: Session) -> AnyPublisher<[Motion], Error>{
        (1...session.laps)
            .map { URL(string: "https://apigw.withoracle.cloud/formulaai/carData/\(session.mSessionid)/\($0)")! }
            .map { URLSession.shared.dataTaskPublisher(for: $0) }
            .publisher
            .flatMap(maxPublishers: .max(1)) { $0 } // we serialize the request because we want the laps in the correct order
            .map (\.data)
            .decode(type: LapData.self, decoder: JSONDecoder())
            //.map { $0.sorted { $0.mFrame < $1.mFrame } }
            .eraseToAnyPublisher()
    }
    // https://apigw.withoracle.cloud/formulaai/trackData/1127492326198450576/1
    
    private func configure(){
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        
        arView.session.run(config)
    }
}
