//
//  GameComponents.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 04.02.2026.
//

import SwiftUI
import AVFoundation
import GameKit

// MARK: EXTENSIONS (Culori Neon)
extension Color {
    static let neonCyan = Color(red: 0, green: 1, blue: 1)
    static let neonBlue = Color(red: 0, green: 0.5, blue: 1)
    static let neonPurple = Color(red: 0.5, green: 0, blue: 1)
    static let neonRed = Color(red: 1, green: 0.1, blue: 0.1)
    static let neonOrange = Color(red: 1, green: 0.5, blue: 0) // <--- Culoarea nouă pentru gradient
    static let deepSpace = Color(red: 0.05, green: 0.05, blue: 0.1)
}

// MARK: DATA MODELS
struct FloatingPoint: Identifiable {
    let id = UUID()
    var x: CGFloat = 0
    var y: CGFloat = 0
    var scale: CGFloat = 0.5
    var opacity: Double = 1.0
}

// MARK: UI COMPONENTS (Timer & Button)
struct RadialTimerView: View {
    var timeLeft: Double
    var totalTime: Double = 7.0
    
    // Animații
    @State private var gradientRotation: Double = 0
    @State private var sparkRotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.5
    
    var body: some View {
        // Calculăm progresul (0.0 -> 1.0)
        let progress = Double(timeLeft) / totalTime
        
        // Dimensiuni
        let width: CGFloat = 320
        let height: CGFloat = 320
        let thickness: CGFloat = 22 // Grosimea tubului
        
        ZStack {
            // 1. TRACK-UL
            Circle()
                .trim(from: 0.5, to: 1.0)
                .stroke(
                    Color.neonOrange.opacity(0.3),
                    style: StrokeStyle(lineWidth: thickness, lineCap: .round)
                )
                .frame(width: width, height: height)
                .blur(radius: 2)
            
            // 2. ARCUL ACTIV (PLASMA)
            ZStack {
                AngularGradient(
                    gradient: Gradient(colors: [
                        .neonBlue,   // Stânga
                        .neonCyan,
                        .white,
                        .neonOrange,
                        .neonRed     // Dreapta
                    ]),
                    center: .center,
                    startAngle: .degrees(180 + gradientRotation),
                    endAngle: .degrees(360 + gradientRotation)
                )
                .blur(radius: 5)
                .mask(
                    Circle()
                        .trim(from: 0.5, to: 0.5 + (0.5 * progress))
                        .stroke(
                            Color.black,
                            style: StrokeStyle(lineWidth: thickness, lineCap: .round)
                        )
                        .frame(width: width, height: height)
                )
                
                // 3. GLOW EXTERIOR
                Circle()
                    .trim(from: 0.5, to: 0.5 + (0.5 * progress))
                    .stroke(
                        AngularGradient(
                            colors: [.neonBlue, .neonCyan, .white, .neonOrange, .neonRed],
                            center: .center,
                            startAngle: .degrees(180),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: thickness, lineCap: .round)
                    )
                    .frame(width: width, height: height)
                    .blur(radius: 15)
                    .opacity(0.5)
            }
            
            // 4. OVERLAY ALB (Miezul 3D)
            Circle()
                .trim(from: 0.5, to: 0.5 + (0.5 * progress))
                .stroke(Color.white.opacity(0.4), lineWidth: 3)
                .frame(width: width, height: height)
                .blur(radius: 2)
            
            // 5. CAPUL DE PLASMĂ (HYPER-BULB)
            GeometryReader { geo in
                let radius = width / 2
                let centerX = geo.size.width / 2
                let centerY = geo.size.height / 2
                
                // Calculăm poziția vârfului
                let angleDegrees = 180 + (180 * progress)
                let angleRadians = angleDegrees * .pi / 180
                
                let x = centerX + radius * cos(angleRadians)
                let y = centerY + radius * sin(angleRadians)
                
                ZStack {
                    // a. ATMOSFERA (Glow Uriaș Roșu)
                    Circle()
                        .fill(Color.neonRed)
                        .frame(width: 60, height: 60) // Foarte mare
                        .blur(radius: 24) // Foarte difuz
                        .opacity(glowOpacity) // Pulsează opacitatea
                    
                    // b. HALO INTENS (Glow concentrat)
                    Circle()
                        .fill(Color.neonOrange)
                        .frame(width: 32, height: 32)
                        .blur(radius: 24)
                    
                    // c. SCÂNTEIA ROTATIVĂ (Electricitate)
                    /*Image(systemName: "sun.max.fill") // Simbol mai plin decât sparkle
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(sparkRotation))
                        .shadow(color: .neonRed, radius: 2)
                        .opacity(0.9)*/
                    
                    // d. MIEZUL DE PLASMĂ (Gradientul Roșu Strălucitor)
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    .white,       // Miez fierbinte (Sudură)
                                    .yellow,      // Margine interioară
                                    .neonRed,     // Corpul principal
                                    .clear        // Fade out
                                ]),
                                center: .center,
                                startRadius: 2,
                                endRadius: 18 // Raza vizibilă a bilei
                            )
                        )
                        .frame(width: 36, height: 36) // Dimensiunea fizică a bilei
                        .shadow(color: .neonRed, radius: 5) // Glow pe bilă
                        .scaleEffect(pulseScale) // Bătăile inimii
                }
                .position(x: x, y: y)
                .opacity(timeLeft == 0 ? 0 : 1)
                .animation(.linear(duration: 1.0), value: x)
                .animation(.linear(duration: 1.0), value: y)
            }
            .frame(width: width, height: height)
            
        }
        .onAppear {
            // Animații
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                gradientRotation = 15
            }
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                sparkRotation = 360
            }
            // Puls rapid și agresiv
            withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                pulseScale = 1.25
                glowOpacity = 0.8
            }
        }
        .animation(.linear(duration: 1.0), value: timeLeft)
    }
}

struct GlitchScoreView: View {
    let score: Int
    let isAnimating: Bool
    
    @State private var offsetRed: CGFloat = 0
    @State private var offsetCyan: CGFloat = 0
    @State private var opacityGlitch: Double = 0
    @State private var lineY: CGFloat = 0
    @State private var showLine: Bool = false
    
    // Timer foarte rapid pentru vibrație constantă
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // 1. Aura de fundal (Glow constant care pulsează)
            Text("\(score)")
                .font(.system(size: 96, weight: .black, design: .rounded))
                .foregroundColor(.neonCyan.opacity(isAnimating ? 0.3 : 0.1))
                .blur(radius: 15)
                .scaleEffect(isAnimating ? 1.1 : 1.0)

            // 2. Stratul "Shadow" (Flicker persistent)
            Text("\(score)")
                .font(.system(size: 96, weight: .black, design: .rounded))
                .foregroundColor(.neonBlue)
                .offset(x: offsetCyan * 0.3)
                .opacity(isAnimating ? 0.4 : 0)

            // 3. Glitch Slices (Feliile care sar)
            ForEach(0..<3) { i in
                Text("\(score)")
                    .font(.system(size: 96, weight: .black, design: .rounded))
                    .foregroundColor(i % 2 == 0 ? .neonRed : .neonCyan)
                    .offset(x: CGFloat.random(in: -20...20) * opacityGlitch)
                    .mask(
                        Rectangle()
                            .frame(height: CGFloat.random(in: 5...15))
                            .offset(y: CGFloat.random(in: -40...40))
                    )
                    .blendMode(.screen)
                    .opacity(isAnimating ? opacityGlitch : 0)
            }

            // 4. Scorul PRINCIPAL (Are un tremurat mic permanent)
            Text("\(score)")
                .font(.system(size: 96, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .offset(x: isAnimating ? CGFloat.random(in: -1...1) : 0,
                                        y: isAnimating ? CGFloat.random(in: -1...1) : 0)
                .shadow(color: .neonCyan.opacity(0.8), radius: 5)

            // 5. Scântei Orizontale (Liniile alea de "Digital Noise")
            if showLine && isAnimating {
                Rectangle()
                    .fill(LinearGradient(colors: [.clear, .white, .neonCyan, .clear], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 200, height: 2)
                    .offset(y: lineY)
                    .blendMode(.plusLighter)
            }
        }
        .onReceive(timer) { _ in
            guard isAnimating else {
                // Dacă jocul s-a oprit, curățăm resturile de glitch
                if opacityGlitch > 0 {
                    offsetRed = 0
                    offsetCyan = 0
                    opacityGlitch = 0
                    showLine = false
                }
                return
            }
            
            withAnimation(.none) {
                // Vibrație permanentă (foarte mică)
                if Double.random(in: 0...1) > 0.8 {
                    offsetRed = CGFloat.random(in: -15...15)
                    offsetCyan = CGFloat.random(in: -15...15)
                    opacityGlitch = Double.random(in: 0.5...1.0)
                    
                    // Poziție random pentru linia de scanare
                    lineY = CGFloat.random(in: -40...40)
                    showLine = true
                } else {
                    // Micro-ajustări pentru "nervozitate"
                    offsetRed *= 0.5
                    offsetCyan *= 0.5
                    opacityGlitch *= 0.5
                    showLine = false
                }
            }
        }
    }
}

// MARK: - COMPONENTA: VORTEX ELECTRIC
struct ArcButton: View {
    var isPressed: Bool
    var isDeployed: Bool
    
    // --- STATE PENTRU ANIMAȚII ELECTRICE ---
    @State private var rotation1: Double = 0
    @State private var rotation2: Double = 0
    @State private var rotation3: Double = 0
    @State private var flashOpacity: Double = 0.0
    @State private var arcJitter: CGFloat = 1.0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // 1. AURA EXTERIOARĂ (Glow-ul care "încălzește" grid-ul)
            Circle()
                .fill(RadialGradient(colors: [.neonCyan.opacity(0.3), .clear], center: .center, startRadius: 0, endRadius: 140))
                .frame(width: 280, height: 280)
                .scaleEffect(isPressed ? 1.2 : 1.0)
            
            // 2. SISTEMUL DE ARCURI ELECTRICE (Firișoarele "nervoase")
            Group {
                // Inel rapid exterior
                Circle()
                    .stroke(Color.white.opacity(0.6), style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [2, 40, 10, 30]))
                    .rotationEffect(.degrees(rotation1))
                
                // Inel mediu cyan
                Circle()
                    .stroke(Color.neonCyan, style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [5, 50, 20, 40]))
                    .rotationEffect(.degrees(-rotation2))
                    .blur(radius: 1)
            }
            .frame(width: 205, height: 205)
            .blendMode(.plusLighter)
            
            // 3. CORPUL REACTORULUI (Miezul 3D din ArcButton)
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                .white,            // Miez fierbinte
                                .neonCyan,         // Energie pură
                                .neonBlue.opacity(0.8),
                                .black             // Adâncime
                            ]),
                            center: .center,
                            startRadius: 2,
                            endRadius: 90
                        )
                    )
                
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    .blur(radius: 1)
            }
            .frame(width: 180, height: 180)
            .shadow(color: .neonCyan, radius: 20)
            .scaleEffect(pulseScale)
            
            // 4. SIMBOLUL CENTRAL (Fulgerul cu Jitter electric)
            ZStack {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 60, weight: .black))
                    .foregroundColor(.white)
                    .blur(radius: 4)
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: 60, weight: .black))
                    .foregroundStyle(LinearGradient(colors: [.white, .neonCyan], startPoint: .top, endPoint: .bottom))
            }
            .scaleEffect(isPressed ? 0.8 : 1.0)
            .scaleEffect(arcJitter) // Vibrația aia mică și tăioasă
            .shadow(color: .white, radius: 10)
            
            // 5. TEXTUL "TAP"
            Text("TAP")
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .offset(y: 55)
                .tracking(3)
                .opacity(isPressed ? 0.5 : 1.0)
            
            // 6. FLASH-UL DE LANSARE
            Circle()
                .fill(Color.white)
                .frame(width: 200, height: 200)
                .opacity(flashOpacity)
        }
        // --- LOGICA DE PERSPECTIVĂ ---
        .scaleEffect(isDeployed ? 1.0 : 0.01)
        .opacity(isDeployed ? 1.0 : 0.0)
        .offset(y: isDeployed ? -60 : -120)
        .animation(.interpolatingSpring(stiffness: 50, damping: 12), value: isDeployed)
        .onAppear {
            startElectricAnimations()
        }
        .onChange(of: isDeployed) { deployed in
            if deployed {
                flashOpacity = 1.0
                withAnimation(.easeOut(duration: 0.6)) { flashOpacity = 0 }
            }
        }
    }
    
    // --- LOGICA DE ANIMAȚIE COMBINATĂ ---
    private func startElectricAnimations() {
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            rotation1 = 360
        }
        withAnimation(.linear(duration: 4.5).repeatForever(autoreverses: false)) {
            rotation2 = 360
        }
        
        // Fără puls în joc ca să nu te încurce
        pulseScale = 1.0
        
        withAnimation(.easeInOut(duration: 0.04).repeatForever(autoreverses: true)) {
            arcJitter = 1.04
        }
    }
}
