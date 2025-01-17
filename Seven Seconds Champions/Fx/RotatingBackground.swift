//
//  RotatingBackground.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 14.01.2025.
//

import SwiftUI

struct RotatingBackground: View {
    var isAnimating: Bool
    @State private var rotation: Double = 0

    var body: some View {
        GeometryReader { geometry in
            let screenSize = max(geometry.size.width, geometry.size.height)
            let imageSize = screenSize * sqrt(2) // Ensures the image is large enough to cover corners during rotation

            Image("background")
                .resizable()
                .scaledToFill()
                .frame(width: imageSize, height: imageSize) // Enlarges the image to cover the screen
                .clipped()
                .rotationEffect(.degrees(rotation)) // Applies the rotation effect
                .blur(radius: 18)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // Centers the image on the screen
                .onAppear {
                    if isAnimating {
                        startAnimation()
                    }
                }
                .onChange(of: isAnimating) { newValue in
                    if newValue {
                        startAnimation()
                    } else {
                        rotation = rotation.truncatingRemainder(dividingBy: 360) // Freeze at the current rotation
                    }
                }
                .zIndex(-1) // Ensures the background stays behind other views
        }
        .ignoresSafeArea() // Ignores safe area insets to cover the entire screen
    }

    private func startAnimation() {
        withAnimation(
            Animation.linear(duration: 72)
                .repeatForever(autoreverses: false)
        ) {
            rotation += 360
        }
    }
}
