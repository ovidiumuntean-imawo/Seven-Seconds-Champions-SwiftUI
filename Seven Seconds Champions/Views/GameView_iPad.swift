//
//  GameView_iPad.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 09.01.2025.
//

import SwiftUI
import AVFoundation
import GameKit

// MARK: - GameView_iPad
struct GameView_iPad: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var gameManager = GameManager()
    
    // --- PARTICULE & STATE ---
    @State private var areParticlesActive: Bool = false
    @State private var emitterLayer: CAEmitterLayer?
    @State private var emitterCell = CAEmitterCell()
    
    // Stocăm poziția exactă a butonului pentru scântei
    @State private var buttonFrame: CGRect = .zero {
        didSet {
            // Dacă butonul s-a mutat sau redimensionat, actualizăm emitter-ul
            if buttonFrame != .zero, !gameManager.isGameRunning {
                Sparks.shared.updateSparks(
                    emitterLayer: emitterLayer,
                    gameManager: gameManager,
                    buttonFrame: buttonFrame
                )
            }
        }
    }
    
    // --- STATES PENTRU UI & ANIMATII ---
    @State private var isButtonDeployed = false
    @State private var floatingPoints: [FloatingPoint] = []
    @State private var screenShakeOffset: CGFloat = 0.0
    @GestureState private var isPressed: Bool = false
    
    // Leaderboard
    @State private var showLeaderboard = false
    @State private var isAnimationActive: Bool = false
    
    // Haptics (Deși iPad-ul nu are Taptic Engine ca iPhone, păstrăm generatorul pentru compatibilitate)
    let impactGen = UIImpactFeedbackGenerator(style: .heavy)
    
    // Game Center
    @State private var gameCenterAuthViewController: UIViewController? = nil
    
    var body: some View {
        NavigationStack {
            GeometryReader { containerGeo in
                ZStack {
                    // 1. FUNDAL & PARTICULE
                    // Folosim fundalul nou "NormalBackground" definit în fișierul de iPhone
                    NormalBackground()
                        .ignoresSafeArea()
                        .offset(x: screenShakeOffset, y: screenShakeOffset) // Shake pe tot ecranul
                    
                    // Stratul de particule cosmice
                    ParticleView(isActive: $areParticlesActive)
                        .ignoresSafeArea()
                    
                    // 2. LAYOUT PRINCIPAL (VStack Mare)
                    VStack(spacing: 40) {
                        
                        // --- A. ZONA DE SUS (HEADER & TIMER DIGITAL) ---
                        // Aici păstrăm stilul tău vechi cu text mare, dar digitalizat
                        VStack(spacing: 10) {
                            if let target = appState.challengeScoreToBeat {
                                // MODE: CHALLENGE
                                VStack(spacing: 0) {
                                    Text("CHALLENGE")
                                        .font(.system(size: 80, weight: .black, design: .rounded))
                                        .foregroundColor(.neonRed)
                                        .shadow(color: .neonRed, radius: 10)
                                    
                                    Text("BEAT: \(target)")
                                        .font(.system(size: 60, weight: .bold, design: .monospaced))
                                        .foregroundColor(.yellow)
                                        .shadow(color: .orange, radius: 5)
                                }
                            } else {
                                // MODE: STANDARD
                                Text("7 SECONDS")
                                    .font(.system(size: 80, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: .neonBlue, radius: 10)
                                    .opacity(0.8)
                            }
                            
                            // TIMERUL DIGITAL URIAȘ (Central)
                            Group {
                                if gameManager.isGameRunning {
                                    Text(String(format: "%.1f s", gameManager.timeLeft))
                                } else {
                                    Text("\(Int(gameManager.timeLeft)) s")
                                }
                            }
                            .font(.system(size: 120, weight: .black, design: .monospaced)) // Masiv pe iPad
                            .foregroundColor(gameManager.timeLeft <= 3 && gameManager.isGameRunning ? .neonRed : .white)
                            .shadow(color: gameManager.timeLeft <= 3 && gameManager.isGameRunning ? .neonRed : .neonCyan, radius: 20)
                            .scaleEffect(gameManager.isGameRunning ? 1.05 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: gameManager.timeLeft)
                        }
                        .padding(.top, 40)
                        
                        Spacer()
                        
                        // --- B. ZONA CENTRALĂ (HSTACK: SCOR STÂNGA - BUTON DREAPTA) ---
                        // Aici e inima layout-ului de iPad, separat stânga-dreapta
                        HStack(spacing: 120) {
                            
                            // B1. STÂNGA: RADARUL (Scor + Timer Radial)
                            // Înlocuim lista veche de text cu Radarul Neon
                            VStack(spacing: 20) {
                                Text("YOUR SCORE")
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.7))
                                    .tracking(5)
                                
                                ZStack {
                                    // Timerul Radial Scalat pentru iPad (1.6x)
                                    RadialTimerView(timeLeft: gameManager.timeLeft)
                                        .scaleEffect(1.6)
                                    
                                    // Scorul cu Glitch în mijloc
                                    GlitchScoreView(
                                        score: gameManager.currentScore,
                                        isAnimating: gameManager.isGameRunning
                                    )
                                    .scaleEffect(1.5)
                                    .offset(y: 10)
                                }
                                .frame(width: 400, height: 400) // Container fix pentru aliniere
                                
                                // Last Score sub radar
                                Text("LAST: \(gameManager.previousScore)")
                                    .font(.system(size: 28, weight: .medium, design: .monospaced))
                                    .foregroundColor(.neonBlue)
                                    .padding(.top, 40)
                            }
                            
                            // B2. DREAPTA: REACTORUL (ArcButton)
                            ZStack {
                                // Butonul Neon (folosim componenta din iPhone)
                                ArcButton(
                                    isPressed: isPressed,
                                    isDeployed: isButtonDeployed
                                )
                                .scaleEffect(1.5) // Mult mai mare pe iPad
                                
                                // GESTURI & INTERACȚIUNE
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 0)
                                        .updating($isPressed) { _, pressed, _ in
                                            pressed = true
                                        }
                                        .onEnded { _ in
                                            handleTap()
                                        }
                                )
                                // LOCALIZARE PENTRU PARTICULE
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
                                
                                // FLOATING POINTS (+1)
                                // Le afișăm peste buton
                                ForEach(floatingPoints) { point in
                                    Text("+1")
                                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                                        .foregroundColor(.white)
                                        .shadow(color: .black, radius: 4)
                                        .scaleEffect(point.scale)
                                        .opacity(point.opacity)
                                        .offset(x: point.x, y: point.y)
                                        .onAppear {
                                            animateFloatingPoint(point)
                                        }
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        
                        Spacer()
                        
                        // --- C. ZONA DE JOS (LEADERBOARD) ---
                        VStack(spacing: 20) {
                            Text("How do you stack up?")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .opacity(gameManager.isGameRunning ? 0 : 1)
                            
                            Button {
                                showLeaderboard = true
                                if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                                    GameCenterManager.shared.showLeaderboard(from: rootVC)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "trophy.fill")
                                    Text("GLOBAL LEADERBOARD")
                                }
                                .font(.system(size: 20, weight: .black))
                                .foregroundColor(.deepSpace)
                                .padding(.horizontal, 60)
                                .padding(.vertical, 20)
                                .background(Color.neonCyan)
                                .cornerRadius(30)
                                .shadow(color: .neonCyan, radius: 10)
                                .scaleEffect(showLeaderboard ? 0.95 : 1.0)
                            }
                            .opacity(gameManager.isGameRunning ? 0 : 1)
                            .animation(.easeInOut, value: gameManager.isGameRunning)
                        }
                        .padding(.bottom, 60)
                    }
                }
                .onAppear {
                    // --- INITIALIZĂRI ---
                    
                    // Game Center
                    GameCenterManager.shared.authenticateLocalPlayer { success, viewControllerGame in
                        if !success, let vc = viewControllerGame {
                            self.gameCenterAuthViewController = vc
                        }
                    }
                    
                    // Activăm particulele cu o mică întârziere
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        areParticlesActive = true
                    }
                    
                    impactGen.prepare()
                    
                    // Lansăm butonul pe ecran
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            isButtonDeployed = true
                        }
                    }
                }
                .fullScreenCover(isPresented: $gameManager.isGameOver) {
                    // Folosim ecranul de GameOver de iPad (presupunem că există sau folosim varianta generică)
                    // Dacă nu ai GameOverView_iPad specific, poți folosi GameOverView_iPhone adaptat
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
        .onDisappear {
            appState.challengeScoreToBeat = nil
        }
    }
    
    // MARK: - GAME LOGIC (Importată din arhitectura nouă)
    
    private func handleTap() {
        if !gameManager.isGameRunning {
            // START GAME
            gameManager.startGame(
                emitterLayer: emitterLayer,
                buttonFrame: buttonFrame,
                challengeTarget: appState.challengeScoreToBeat
            )
            isAnimationActive = true
            impactGen.impactOccurred()
        } else {
            // TAP IN-GAME
            gameManager.currentScore += 1
            gameManager.buttonPressed()
            
            // Feedback fizic
            impactGen.impactOccurred(intensity: 1.0)
            triggerShake()
            spawnFloatingPoint()
            
            // Actualizăm particulele (viteza crește cu scorul)
            Sparks.shared.updateSparks(
                emitterLayer: emitterLayer,
                gameManager: gameManager,
                buttonFrame: buttonFrame
            )
        }
    }
    
    // Calculăm poziția emitter-ului de particule relativ la butonul mare
    private func updateSparksPosition(containerGeo: GeometryProxy, btnGeo: GeometryProxy) {
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
    
    // Efectul de cutremur al ecranului
    private func triggerShake() {
        let intensity: CGFloat = 12.0 // Mai intens pe iPad
        withAnimation(.linear(duration: 0.05)) { screenShakeOffset = -intensity }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.linear(duration: 0.05)) { screenShakeOffset = intensity }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.linear(duration: 0.05)) { screenShakeOffset = 0 }
        }
    }
    
    // Generăm punctele plutitoare (+1)
    private func spawnFloatingPoint() {
        let newPoint = FloatingPoint(
            x: CGFloat.random(in: -60...60), // Zonă mai largă pe iPad
            y: 0
        )
        floatingPoints.append(newPoint)
    }
    
    // Animăm punctele în sus
    private func animateFloatingPoint(_ point: FloatingPoint) {
        if let index = floatingPoints.firstIndex(where: { $0.id == point.id }) {
            withAnimation(.easeOut(duration: 0.8)) {
                floatingPoints[index].y = -400 // Zboară mai sus pe ecranul mare
                floatingPoints[index].opacity = 0
                floatingPoints[index].scale = 2.0 // Se măresc mai mult
            }
            
            // Curățăm memoria
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if let idx = floatingPoints.firstIndex(where: { $0.id == point.id }) {
                    floatingPoints.remove(at: idx)
                }
            }
        }
    }
}

#Preview("iPad Standard") {
    GameView_iPad()
        .environmentObject(AppState())
        .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch)"))
}
