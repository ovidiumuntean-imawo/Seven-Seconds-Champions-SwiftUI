//
//  RotatingBackground.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 14.01.2025.
//

import SwiftUI

struct NormalBackground: View {
    var body: some View {
        GeometryReader { geometry in
            Image("background_cosmic")
                .resizable()
                .scaledToFill() // Umple ecranul păstrând proporțiile corecte (nu turtește)
                .frame(width: geometry.size.width, height: geometry.size.height) // Se forțează exact pe dimensiunea ecranului
                .clipped() // Taie orice surplus care iese din ecran
        }
        .ignoresSafeArea() // Acoperă tot, inclusiv zona ceasului și bara de jos
    }
}

struct RotatingBackground: View {
    var isAnimating: Bool
    // Două variabile pentru mișcare pe X și Y
    @State private var moveX: CGFloat = -20
    @State private var moveY: CGFloat = -20

    var body: some View {
        GeometryReader { geometry in
            Image("background_cosmic")
                .resizable()
                .scaledToFill()
                // O facem doar puțin mai mare decât ecranul (10%) ca să aibă loc să se miște
                .frame(width: geometry.size.width * 1.1, height: geometry.size.height * 1.1)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .offset(x: moveX, y: moveY) // Aici e mișcarea
                .onAppear {
                    if isAnimating {
                        startFloating()
                    }
                }
                .onChange(of: isAnimating) { newValue in
                    if newValue { startFloating() }
                }
        }
        .ignoresSafeArea()
    }

    private func startFloating() {
        // Mișcare pe X (stânga-dreapta)
        withAnimation(
            Animation.easeInOut(duration: 15).repeatForever(autoreverses: true)
        ) {
            moveX = 20
        }
        
        // Mișcare pe Y (sus-jos) - durată diferită pentru haos natural
        withAnimation(
            Animation.easeInOut(duration: 25).repeatForever(autoreverses: true)
        ) {
            moveY = 20
        }
    }
}
