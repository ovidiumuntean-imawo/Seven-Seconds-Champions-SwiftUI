//
//  ParticleView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 16.01.2025.
//

import SwiftUI
import UIKit

struct ParticleView: UIViewRepresentable {
    @Binding var isActive: Bool
    
    var emitterCellGlobal = CAEmitterCell()
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        setupEmitterLayer(for: view)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let emitterLayer = uiView.layer.sublayers?.first(where: { $0.name == "EmitterGlobal" }) as? CAEmitterLayer {
            emitterLayer.isHidden = !isActive
        }
    }
    
    private func setupEmitterLayer(for view: UIView) {
        guard let image = UIImage(named: "spark.png")?.cgImage else {
            print("Failed loading spark image.")
            return
        }
        
        let emitterLayerGlobal = CAEmitterLayer()
        emitterLayerGlobal.name = "EmitterGlobal"
        emitterLayerGlobal.emitterPosition = CGPoint(x: view.bounds.midX, y: -50)
        emitterLayerGlobal.emitterSize = CGSize(width: view.bounds.width, height: 1)
        emitterLayerGlobal.emitterShape = .line
        
        emitterCellGlobal.color = UIColor.white.cgColor
        emitterCellGlobal.contents = image
        emitterCellGlobal.birthRate = 80
        emitterCellGlobal.lifetime = 20
        emitterCellGlobal.velocity = 42
        emitterCellGlobal.scale = 0.05
        emitterCellGlobal.scaleRange = 0.1
        emitterCellGlobal.emissionRange = CGFloat.pi * 2.0
        
        emitterLayerGlobal.emitterCells = [emitterCellGlobal]
        view.layer.addSublayer(emitterLayerGlobal)
    }
}
