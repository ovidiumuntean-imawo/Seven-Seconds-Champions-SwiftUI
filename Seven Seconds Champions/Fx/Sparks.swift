//
//  Sparks.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 09.01.2025.
//

import UIKit

class Sparks {
    static let shared = Sparks()
    private init() {}
    
    // Particule globale (small sparks) - dacă vrei să le păstrezi
    func createSmallSparks(emitterLayerGlobal: inout CAEmitterLayer?,
                           emitterCellGlobal: CAEmitterCell,
                           parentSize: CGSize) {
        guard let image = UIImage(named: "spark.png")?.cgImage else {
            print("Failed loading spark image.")
            return
        }
        
        emitterLayerGlobal = CAEmitterLayer()
        emitterLayerGlobal?.name = "EmitterGlobal"
        
        // Poziționare deasupra ecranului
        emitterLayerGlobal?.emitterPosition.x = parentSize.width / 2 - 10
        emitterLayerGlobal?.emitterPosition.y = -50
        
        // Parametri particule globale
        emitterCellGlobal.color = CGColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        emitterCellGlobal.contents = image
        emitterCellGlobal.name = "cellGlobal"
        
        emitterCellGlobal.birthRate = 120
        emitterCellGlobal.lifetime = 20
        emitterCellGlobal.velocity = 42
        
        emitterCellGlobal.scale = 0.05
        emitterCellGlobal.scaleRange = 0.1
        emitterCellGlobal.emissionRange = CGFloat.pi * 2.0
        
        emitterLayerGlobal?.emitterCells = [emitterCellGlobal]
        
        if let emitterLayerGlobal = emitterLayerGlobal,
           let window = UIApplication.shared.windows.first {
            window.layer.addSublayer(emitterLayerGlobal)
        }
    }
    
    // Particulele butonului
    func createSparks(emitterLayer: inout CAEmitterLayer?,
                      emitterCell: CAEmitterCell,
                      buttonFrame: CGRect) {
        guard let image = UIImage(named: "spark.png")?.cgImage else {
            print("Failed to load spark image.")
            return
        }
        
        emitterLayer = CAEmitterLayer()
        emitterLayer?.name = "ButtonEmitter"
        emitterLayer?.emitterShape = .circle
        
        // Poziția inițială (centrul butonului)
        emitterLayer?.emitterPosition = CGPoint(x: buttonFrame.midX, y: buttonFrame.midY)
        emitterLayer?.emitterSize = CGSize(width: 10, height: 10)
        
        emitterCell.contents = image
        emitterCell.name = "cell"
        
        // Valorile inspirate direct din codul UIKit:
        // Lente în standby, dar totuși active
        emitterCell.birthRate = 20
        emitterCell.lifetime = 16
        emitterCell.velocity = 22
        
        emitterCell.scale = 0.18
        emitterCell.scaleRange = 0.2
        emitterCell.emissionLongitude = .pi / 2.0
        emitterCell.emissionRange = CGFloat.pi / 4.0
        
        // Culoare inițială albă
        emitterCell.color = UIColor.white.cgColor
        
        emitterLayer?.emitterCells = [emitterCell]
        
        // Adăugăm la fereastra principală
        if let emitterLayer = emitterLayer,
           let window = UIApplication.shared.windows.first {
            window.layer.addSublayer(emitterLayer)
        }
    }
    
    /*func updateSparks(emitterLayer: CAEmitterLayer?,
                      score: Int,
                      buttonFrame: CGRect,
                      isGameRunning: Bool) {
        guard let emitterLayer = emitterLayer else { return }

        emitterLayer.emitterPosition = CGPoint(x: buttonFrame.midX, y: buttonFrame.midY)

        if isGameRunning {
            // Menținem aceeași logică pentru culoare și dimensiune,
            // dar pornim de la o viteză puțin mai mare
            let newBirthRate = Float(20 + score * 2)
            let newVelocity = CGFloat(40 + score * 3) // mărit de la 30 la 40 ca bază
            let hue = CGFloat.random(in: 0.0...0.18)
            
            let newColor = UIColor(
                hue: hue,
                saturation: 1.0,
                brightness: 1.0,
                alpha: 1.0
            ).cgColor

            emitterLayer.setValue(newBirthRate, forKeyPath: "emitterCells.cell.birthRate")
            emitterLayer.setValue(newVelocity,  forKeyPath: "emitterCells.cell.velocity")
            emitterLayer.setValue(newColor,     forKeyPath: "emitterCells.cell.color")
        } else {
            // Standby
            emitterLayer.setValue(20,                   forKeyPath: "emitterCells.cell.birthRate")
            emitterLayer.setValue(22,                   forKeyPath: "emitterCells.cell.velocity")
            emitterLayer.setValue(UIColor.white.cgColor,forKeyPath: "emitterCells.cell.color")
        }
    }*/
    
    func updateSparks(emitterLayer: CAEmitterLayer?,
                      score: Int,
                      buttonFrame: CGRect,
                      isGameRunning: Bool) {
        guard let emitterLayer = emitterLayer else { return }

        emitterLayer.emitterPosition = CGPoint(x: buttonFrame.midX, y: buttonFrame.midY)

        if isGameRunning {
            // Particule colorate când jocul rulează
            let newBirthRate = Float(20 + score * 2)
            let newVelocity = CGFloat(40 + score * 3)
            let hue = CGFloat.random(in: 0.0...0.18)

            let newColor = UIColor(
                hue: hue,
                saturation: 1.0,
                brightness: 1.0,
                alpha: 1.0
            ).cgColor

            emitterLayer.setValue(newBirthRate, forKeyPath: "emitterCells.cell.birthRate")
            emitterLayer.setValue(newVelocity,  forKeyPath: "emitterCells.cell.velocity")
            emitterLayer.setValue(newColor,     forKeyPath: "emitterCells.cell.color")
        } else {
            // Standby: Alb și verde într-o singură celulă
            emitterLayer.setValue(20, forKeyPath: "emitterCells.cell.birthRate")
            emitterLayer.setValue(22, forKeyPath: "emitterCells.cell.velocity")
            
            // Setăm culoarea de bază albă
            emitterLayer.setValue(UIColor.white.cgColor, forKeyPath: "emitterCells.cell.color")
            
            // Variere culoare: Alb -> Verde
            emitterLayer.setValue(1.0, forKeyPath: "emitterCells.cell.greenSpeed")
            emitterLayer.setValue(0.5, forKeyPath: "emitterCells.cell.greenRange")
        }
    }
}
