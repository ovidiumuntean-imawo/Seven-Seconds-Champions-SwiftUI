//
//  GameView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 15.01.2025.
//

import SwiftUI
import AVFoundation
import GameKit

// MARK: - 1. EXTENSIONS (Culori Neon)
extension Color {
    static let neonCyan = Color(red: 0, green: 1, blue: 1)
    static let neonBlue = Color(red: 0, green: 0.5, blue: 1)
    static let neonPurple = Color(red: 0.5, green: 0, blue: 1)
    static let neonRed = Color(red: 1, green: 0.1, blue: 0.1)
    static let neonOrange = Color(red: 1, green: 0.5, blue: 0) // <--- Culoarea nouă pentru gradient
    static let deepSpace = Color(red: 0.05, green: 0.05, blue: 0.1)
}

// MARK: - 2. DATA MODELS
struct FloatingPoint: Identifiable {
    let id = UUID()
    var x: CGFloat = 0
    var y: CGFloat = 0
    var scale: CGFloat = 0.5
    var opacity: Double = 1.0
}

// MARK: - 3. UI COMPONENTS (Timer & Button)
struct RadialTimerView: View {
    var timeLeft: Int
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
        let width: CGFloat = 300
        let height: CGFloat = 300
        let thickness: CGFloat = 20 // Grosimea tubului
        
        ZStack {
            // 1. TRACK-UL (Fundalul gri)
            Circle()
                .trim(from: 0.5, to: 1.0)
                .stroke(
                    Color.white.opacity(0.1),
                    style: StrokeStyle(lineWidth: thickness, lineCap: .round)
                )
                .frame(width: width, height: height)
            
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
                .font(.system(size: 85, weight: .black, design: .rounded))
                .foregroundColor(.neonCyan.opacity(isAnimating ? 0.3 : 0.1))
                .blur(radius: 15)
                .scaleEffect(isAnimating ? 1.1 : 1.0)

            // 2. Stratul "Shadow" (Flicker persistent)
            Text("\(score)")
                .font(.system(size: 85, weight: .black, design: .rounded))
                .foregroundColor(.neonBlue)
                .offset(x: offsetCyan * 0.3)
                .opacity(isAnimating ? 0.4 : 0)

            // 3. Glitch Slices (Feliile care sar)
            ForEach(0..<3) { i in
                Text("\(score)")
                    .font(.system(size: 85, weight: .black, design: .rounded))
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
                .font(.system(size: 85, weight: .black, design: .rounded))
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

struct GlitchScoreView2: View {
    let score: Int
    @State private var offsetRed: CGFloat = 0
    @State private var offsetCyan: CGFloat = 0
    @State private var opacityGlitch: Double = 0
    
    // Timer pentru glitch-ul permanent
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // 1. Stratul CYAN (Decalat stânga)
            Text("\(score)")
                .font(.system(size: 85, weight: .black, design: .rounded))
                .foregroundColor(.neonCyan)
                .offset(x: offsetCyan)
                .mask(
                    VStack(spacing: 4) {
                        ForEach(0..<10) { _ in
                            Rectangle().frame(height: CGFloat.random(in: 2...8))
                                .opacity(Double.random(in: 0...1))
                        }
                    }
                )
                .opacity(opacityGlitch)

            // 2. Stratul ROȘU (Decalat dreapta)
            Text("\(score)")
                .font(.system(size: 85, weight: .black, design: .rounded))
                .foregroundColor(.neonRed)
                .offset(x: offsetRed)
                .mask(
                    VStack(spacing: 4) {
                        ForEach(0..<10) { _ in
                            Rectangle().frame(height: CGFloat.random(in: 2...8))
                                .opacity(Double.random(in: 0...1))
                        }
                    }
                )
                .opacity(opacityGlitch)
            
            // 3. Stratul GALBEN (Random sparks)
            Text("\(score)")
                .font(.system(size: 85, weight: .black, design: .rounded))
                .foregroundColor(.yellow)
                .offset(x: offsetRed * 1.5, y: offsetCyan)
                .opacity(opacityGlitch * 0.5)
                .blur(radius: 2)

            // 4. Scorul PRINCIPAL (Alb, stabil)
            Text("\(score)")
                .font(.system(size: 85, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .shadow(color: .neonCyan.opacity(0.5), radius: 10)
        }
        .onReceive(timer) { _ in
            updateGlitch()
        }
    }
    
    private func updateGlitch() {
        // Șansă de 30% să avem un glitch la fiecare 0.1 secunde
        if Double.random(in: 0...1) > 0.7 {
            withAnimation(.interactiveSpring()) {
                offsetRed = CGFloat.random(in: -12...12)
                offsetCyan = CGFloat.random(in: -12...12)
                opacityGlitch = Double.random(in: 0.4...1.0)
            }
            
            // Revenire rapidă (după 0.05 secunde) pentru a crea efectul de flicker
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation {
                    if Double.random(in: 0...1) > 0.5 {
                        offsetRed = 0
                        offsetCyan = 0
                        opacityGlitch = 0
                    }
                }
            }
        } else {
            // Majoritatea timpului stă cuminte sau cu un flicker mic
            if opacityGlitch > 0 {
                withAnimation {
                    opacityGlitch = 0
                }
            }
        }
    }
}

// MARK: - COMPONENTA: VORTEX ELECTRIC
struct ArcButton: View {
    var isPressed: Bool
    var isDeployed: Bool
    var isGameRunning: Bool
    
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
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .offset(y: 45)
                .tracking(3)
                .opacity(isPressed ? 0.5 : 1.0)

            // 6. FLASH-UL DE LANSARE
            Circle()
                .fill(Color.white)
                .frame(width: 200, height: 200)
                .opacity(flashOpacity)
        }
        // --- LOGICA DE PERSPECTIVĂ ---
        .id(isGameRunning ? "turbo" : "idle")
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
        let speed1 = isGameRunning ? 0.8 : 5.0
        let speed2 = isGameRunning ? 1.5 : 7.0
        
        // Rotații asimetrice pentru firișoare
        withAnimation(.linear(duration: speed1).repeatForever(autoreverses: false)) {
            rotation1 = 360
        }
        withAnimation(.linear(duration: speed2).repeatForever(autoreverses: false)) {
            rotation2 = 360
        }
        
        // Pulsul de standby al reactorului
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
        }
        
        // Jitter-ul electric (Vibrația tăioasă)
        withAnimation(.easeInOut(duration: 0.06).repeatForever(autoreverses: true)) {
            arcJitter = 1.04
        }
    }
}

// MARK: - 4. MAIN VIEW
struct GameView_iPhone: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var gameManager = GameManager()
    
    @State private var isButtonDeployed = false
    @State private var areParticlesActive: Bool = false
    @State private var emitterLayer: CAEmitterLayer?
    @State private var emitterCell = CAEmitterCell()
    @State private var buttonFrame: CGRect = .zero {
        didSet {
            // Conectăm logica veche la butonul nou
            if buttonFrame != .zero, !gameManager.isGameRunning {
                Sparks.shared.updateSparks(
                    emitterLayer: emitterLayer,
                    gameManager: gameManager,
                    buttonFrame: buttonFrame
                )
            }
        }
    }
    
    // --- EFECTE UI ---
    @State private var floatingPoints: [FloatingPoint] = []
    @State private var screenShakeOffset: CGFloat = 0.0
    @GestureState private var isPressed: Bool = false
    
    @State private var showLeaderboard = false
    @State private var isAnimationActive: Bool = false
    
    // Haptics (Vibrații Premium)
    let impactGen = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        NavigationStack {
            GeometryReader { containerGeo in
                ZStack {
                    NormalBackground()
                            .ignoresSafeArea()
                    
                    Color.black.opacity(0.0)
                            .ignoresSafeArea()

                    // PARTICULE GENERICE (Praf Stelar)
                    ParticleView(isActive: $areParticlesActive)
                        .ignoresSafeArea()
                    
                    VStack {
                        // --- ZONA DE SUS: HUD RADIAL ---
                        ZStack {
                            RadialTimerView(timeLeft: gameManager.timeLeft)
                                .padding(.top, 50)
                            
                            // Scorul
                            VStack(spacing: -5) {
                                Text("SCORE")
                                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    .foregroundColor(.neonCyan.opacity(0.8))
                                    .tracking(8)
                                
                                /*Text("\(gameManager.currentScore)")
                                    .font(.system(size: 72, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: .neonBlue, radius: 15) // Glow puternic*/
                                
                                GlitchScoreView(
                                    score: gameManager.currentScore,
                                    isAnimating: gameManager.isGameRunning
                                )
                            }
                            .offset(y: 60)
                        }
                        
                        Spacer()
                        
                        // --- ZONA CENTRALA: REACTORUL ---
                        ZStack {
                            // Butonul Reactor
                            ArcButton(
                                isPressed: isPressed,
                                isDeployed: isButtonDeployed,
                                isGameRunning: gameManager.isGameRunning
                            )
                            // GESTURI: Aici capturăm tap-ul rapid
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .updating($isPressed) { _, pressed, _ in
                                        pressed = true
                                    }
                                    .onEnded { _ in
                                        handleTap()
                                    }
                            )
                            // INTEGRATE PARTICULE: Aici "citim" poziția butonului pentru Sparks.swift
                            .background(
                                GeometryReader { btnGeo in
                                    Color.clear.onAppear {
                                        updateSparksPosition(containerGeo: containerGeo, btnGeo: btnGeo)
                                    }
                                    .onChange(of: btnGeo.frame(in: .global)) { _ in
                                        updateSparksPosition(containerGeo: containerGeo, btnGeo: btnGeo)
                                    }
                                }
                            )
                            
                            // Floating Points (+1)
                            ForEach(floatingPoints) { point in
                                Text("+1")
                                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 2)
                                    .scaleEffect(point.scale)
                                    .opacity(point.opacity)
                                    .offset(x: point.x, y: point.y)
                                    .onAppear {
                                        animateFloatingPoint(point)
                                    }
                            }
                        }
                        
                        Spacer()
                        
                        // --- ZONA DE JOS: TARGET & INFO ---
                        VStack(spacing: 20) {
                            if let target = appState.challengeScoreToBeat {
                                Text("TARGET: \(target)")
                                    .font(.system(size: 28, weight: .heavy, design: .monospaced))
                                    .foregroundColor(.yellow)
                                    .shadow(color: .orange, radius: 5)
                            } else {
                                // Timer Digital de siguranță
                                Text(String(format: "%.1f s", Double(gameManager.timeLeft)))
                                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                                    .foregroundColor(gameManager.timeLeft <= 3 ? .neonRed : .gray)
                            }
                            
                            Button {
                                showLeaderboard = true
                                if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                                    GameCenterManager.shared.showLeaderboard(from: rootVC)
                                }
                            } label: {
                                Text("LEADERBOARD")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.neonBlue)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.neonBlue.opacity(0.1))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.neonBlue.opacity(0.5), lineWidth: 1)
                                    )
                            }
                            .opacity(gameManager.isGameRunning ? 0 : 1)
                        }
                        .padding(.bottom, 40)
                    }
                }
                .onAppear {
                    // Inițializări
                    GameCenterManager.shared.authenticateLocalPlayer { success, _ in
                        print("GC Auth: \(success)")
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        areParticlesActive = true
                    }
                    
                    impactGen.prepare()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            isButtonDeployed = true
                        }
                    }
                }
                .fullScreenCover(isPresented: $gameManager.isGameOver) {
                    // Aici apelăm GameOverView (poți să-l refaci și pe el Neon mai târziu)
                    GameOverView_iPhone(
                        gameManager: gameManager,
                        previousScore: $gameManager.previousScore
                    )
                    .onAppear { isAnimationActive = false }
                    .onDisappear {
                        gameManager.resetGame(emitterLayer: emitterLayer, buttonFrame: buttonFrame)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // --- LOGICA JOCULUI ---
    
    private func handleTap() {
        if !gameManager.isGameRunning {
            // START JOC
            gameManager.startGame(
                emitterLayer: emitterLayer,
                buttonFrame: buttonFrame,
                challengeTarget: appState.challengeScoreToBeat
            )
            isAnimationActive = true
            impactGen.impactOccurred()
        } else {
            // TAP ÎN JOC
            gameManager.currentScore += 1
            gameManager.buttonPressed()
            
            // Efecte Fizice
            impactGen.impactOccurred(intensity: 1.0)
            triggerShake()
            spawnFloatingPoint()
            
            // Update la sistemul tău de particule (viteză, culori)
            Sparks.shared.updateSparks(
                emitterLayer: emitterLayer,
                gameManager: gameManager,
                buttonFrame: buttonFrame
            )
        }
    }
    
    private func updateSparksPosition(containerGeo: GeometryProxy, btnGeo: GeometryProxy) {
        // Trimitem coordonatele noului buton către SparksHelper
        DispatchQueue.main.async {
            SparksHelper.calculateEmitterPosition(
                containerGeo: containerGeo,
                btnGeo: btnGeo,
                buttonFrame: &buttonFrame,
                emitterLayer: &emitterLayer,
                emitterCell: emitterCell,
                gameManager: gameManager
            )
        }
    }
    
    private func triggerShake() {
        let intensity: CGFloat = 8.0
        withAnimation(.linear(duration: 0.05)) { screenShakeOffset = -intensity }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.linear(duration: 0.05)) { screenShakeOffset = intensity }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.linear(duration: 0.05)) { screenShakeOffset = 0 }
        }
    }
    
    private func spawnFloatingPoint() {
        let newPoint = FloatingPoint(
            x: CGFloat.random(in: -30...30), // Variație stânga-dreapta
            y: 0
        )
        floatingPoints.append(newPoint)
    }
    
    private func animateFloatingPoint(_ point: FloatingPoint) {
        if let index = floatingPoints.firstIndex(where: { $0.id == point.id }) {
            withAnimation(.easeOut(duration: 0.6)) {
                floatingPoints[index].y = -180 // Zboară în sus
                floatingPoints[index].opacity = 0
                floatingPoints[index].scale = 1.5
            }
            
            // Curățenie automată
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                if let idx = floatingPoints.firstIndex(where: { $0.id == point.id }) {
                    floatingPoints.remove(at: idx)
                }
            }
        }
    }
}

// Preview
#Preview {
    GameView_iPhone()
        .environmentObject(AppState())
}
