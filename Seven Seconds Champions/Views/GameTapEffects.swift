//
//  GameTapEffects.swift
//  Seven Seconds Champions
//
//  Created by Assistant on 09.01.2026.
//

import SwiftUI

/// Reusable tap effects for both iPhone and iPad game views.
/// Pass in bindings to the view state you want animated.
enum GameTapEffects {
    static func trigger(
        buttonScale: Binding<CGFloat>,
        screenShakeOffset: Binding<CGFloat>,
        floatingPoints: Binding<[FloatingPoint]>
    ) {
        // 1. Haptic Feedback
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        // 2. Elastic Button Logic
        withAnimation(.interactiveSpring(response: 0.1, dampingFraction: 0.3, blendDuration: 0)) {
            buttonScale.wrappedValue = 0.85
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                buttonScale.wrappedValue = 1.0
            }
        }

        // 3. Screen Shake
        withAnimation(.linear(duration: 0.05)) {
            screenShakeOffset.wrappedValue = CGFloat.random(in: -5...5)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation { screenShakeOffset.wrappedValue = 0 }
        }

        // 4. FLOATING TEXT (+1)
        let newPoint = FloatingPoint(
            x: CGFloat.random(in: -30...30),
            y: 0
        )
        floatingPoints.wrappedValue.append(newPoint)

        // Auto cleanup
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if !floatingPoints.wrappedValue.isEmpty { floatingPoints.wrappedValue.removeFirst() }
        }
    }
}

