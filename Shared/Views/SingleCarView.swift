//
//  SingleCarView.swift
//  F1 mac app
//
//  Created by Parineet Vernekar on 22/02/2022.
//

import SwiftUI
import ARKit
import RealityKit
import FocusEntity

struct SingleCarView: View {
    
    var car : String
    var carModel : Car
    var body: some View {
        ZStack {
            VStack{
                CarARViewContainer(car: car)
            }
//            Text("\(carModel.info)")
//            .background(RoundedRectangle(cornerRadius: 15).fill(.white))
//            .frame(maxWidth: 150, maxHeight: 100, alignment:.bottomLeading)
//            .foregroundColor(.black)
        }
    }
}

struct SingleCarView_Previews: PreviewProvider {
    static var previews: some View {
        SingleCarView(car: "redbullcar", carModel: cars[1])
    }
}

struct CarARViewContainer : UIViewRepresentable{
    var car : String
    func makeUIView(context: Context) -> some UIView {
        let arView = ARView()
        context.coordinator.view = arView
        arView.session.delegate = context.coordinator

        arView.addGestureRecognizer(
            UITapGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.handleTap)
            )
        )

        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(car : car)
    }
}

class Coordinator: NSObject, ARSessionDelegate {
    weak var view: ARView?
    var focusEntity: FocusEntity?
    var car : String
    
    init(car : String){
        self.car = car
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let view = self.view else { return }
        debugPrint("Anchors added to the scene: ", anchors)
        self.focusEntity = FocusEntity(on: view, style: .classic(color: .yellow))
    }
    
    @objc func handleTap() {
        guard let view = self.view, let focusEntity = self.focusEntity else { return }

        let anchor = AnchorEntity()
        view.scene.anchors.append(anchor)

        if car == "redbullcar" {
            let redbullScene = try! Redbull.loadScene()
            let redbull = redbullScene.redbull!
            redbull.position = focusEntity.position
            anchor.addChild(redbull)
        } else if car == "mclarencar" {
            let mclarenScene = try! Mclaren.loadScene()
            let mclaren = mclarenScene.mclaren!
            mclaren.position = focusEntity.position
            mclaren.transform.scale = [1, 1, 1] * 0.75
            anchor.addChild(mclaren)
        } else if car == "f1generic" {
            let genericScene = try! F1Generic.loadScene()
            let genericCar = genericScene.generic!
            genericCar.position = focusEntity.position
            genericCar.transform.scale = [1, 1, 1] * 0.75
            anchor.addChild(genericCar)
        }

    }
}



class CustomARView : ARView{
    var focusEntity : FocusEntity?
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        focusEntity = FocusEntity(on: self, focus: .classic)
        configute()
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configute(){
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal, .vertical]
        guard ARWorldTrackingConfiguration.supportsFrameSemantics(.personSegmentationWithDepth) else {
            session.run(config)
            fatalError("People occlusion is not supported on this device.")
        }
        config.frameSemantics.insert(.personSegmentationWithDepth)
        session.run(config)
    }
}
