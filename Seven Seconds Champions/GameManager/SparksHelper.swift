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
        // Get the full frame of the button
        let buttonRect = btnGeo.frame(in: .global)
        
        // Ensure the button dimensions are valid
        guard buttonRect.width > 0, buttonRect.height > 0 else { return }
        
        // Calculate the bottom-center position of the button
        let bottomCenterX = buttonRect.minX + (buttonRect.width / 2)
        let bottomCenterY = buttonRect.minY + buttonRect.height
        
        // Update `buttonFrame` with the new position
        buttonFrame = CGRect(x: bottomCenterX, y: bottomCenterY, width: 0, height: 0)
        
        // Initialize or update the particle emitter
        if emitterLayer == nil {
            // If `emitterLayer` is nil, create the particles
            Sparks.shared.createSparks(
                emitterLayer: &emitterLayer,
                emitterCell: emitterCell,
                buttonFrame: buttonFrame
            )
        }
        
        // Update the particles using `gameManager`
        Sparks.shared.updateSparks(
            emitterLayer: emitterLayer,
            gameManager: gameManager,
            buttonFrame: buttonFrame
        )
    }
}
