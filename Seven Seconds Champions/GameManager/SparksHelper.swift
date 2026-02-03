//
//  SparksHelper.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 15.01.2025.
//

import SwiftUI

struct SparksHelper {
    static func calculateEmitterPosition(
        containerGeo: GeometryProxy,
        btnGeo: GeometryProxy,
        buttonFrame: inout CGRect,
        emitterLayer: inout CAEmitterLayer?,
        emitterCell: CAEmitterCell,
        gameManager: GameManager
    ) {
        let buttonRect = btnGeo.frame(in: .global)
        
        guard buttonRect.width > 0, buttonRect.height > 0 else { return }
        
        let centerX = buttonRect.midX
        let centerY = buttonRect.midY
        
        buttonFrame = CGRect(x: centerX, y: centerY, width: 0, height: 0)
        
        if emitterLayer == nil {
            Sparks.shared.createSparks(
                emitterLayer: &emitterLayer,
                emitterCell: emitterCell,
                buttonFrame: buttonFrame
            )
        }
        
        Sparks.shared.updateSparks(
            emitterLayer: emitterLayer,
            gameManager: gameManager,
            buttonFrame: buttonFrame
        )
    }
}
