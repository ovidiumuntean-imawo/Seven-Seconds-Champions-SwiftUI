//
//  GameView_iPad.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 09.01.2025.
//
//
//  GameView_iPad.swift
//  Seven Seconds Champions
//
//  Created by Boseanu on 04.02.2026.
//

import SwiftUI
import AVFoundation
import GameKit

struct GameView_iPad: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var gameManager = GameManager()
    
    // --- FACTOR DE SCALARE PENTRU IPAD ---
    let scale: CGFloat = 1.6
    
    @State private var isButtonDeployed = false
    @State private var areParticlesActive: Bool = false
    @State private var emitterLayer: CAEmitterLayer?
    @State private var buttonFrame: CGRect = .zero
    
    // --- EFECTE UI ---
    @State private var floatingPoints: [FloatingPoint] = []
    @State private var screenShakeOffset: CGFloat = 0.0
    @GestureState private var isPressed: Bool = false
    
    @State private var showLeaderboard = false
    @State private var isAnimationActive: Bool = false
    
    // Haptics (Deși iPad-ul nu are vibrații ca iPhone, lăsăm codul să nu crape)
    let impactGen = UIImpactFeedbackGenerator(style: .heavy)
    
    var body: some View {
        NavigationStack {
            GeometryReader { containerGeo in
                ZStack {
                    NormalBackground()
                        .ignoresSafeArea()
                    
                    // PARTICULE (Le lăsăm pe tot ecranul)
                    ParticleView(isActive: $areParticlesActive)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        
                        // --- 1. ZONA TIMER DIGITAL ---
                        VStack(spacing: 10 * scale) { // Spacing mai mare
                            if let target = appState.challengeScoreToBeat {
                                Text("TARGET: \(target)")
                                    .font(.system(size: 16 * scale, weight: .black, design: .monospaced)) // Font x 1.6
                                    .foregroundColor(.yellow)
                                    .shadow(color: .orange, radius: 4 * scale)
                            }
                            
                            Group {
                                if gameManager.isGameRunning {
                                    Text(String(format: "%.1f s", Double(gameManager.timeLeft)))
                                } else {
                                    Text(String(format: "%.0f SECONDS", Double(gameManager.timeLeft)))
                                }
                            }
                            .font(.system(size: 32 * scale, weight: .black, design: .monospaced)) // Font Uriaș
                            .foregroundColor(gameManager.timeLeft <= 3 && gameManager.isGameRunning ? .neonRed : .white)
                            .shadow(color: gameManager.timeLeft <= 3 && gameManager.isGameRunning ? .neonRed : .neonCyan, radius: 10 * scale)
                        }
                        .padding(.top, 20 * scale) // Padding de sus mai mare
                        
                        // Spațiu generos între Timer și Arc
                        Spacer().frame(height: 60 * scale)
                        
                        // --- 2. ZONA ARCULUI RADIAL ---
                        ZStack {
                            // Mărim Timer-ul grafic
                            RadialTimerView(timeLeft: gameManager.timeLeft)
                                .scaleEffect(scale) // <--- AICI E MAGIA (Mărește desenul)
                            
                            VStack(spacing: 0) {
                                Text("SCORE")
                                    .font(.system(size: 20 * scale, weight: .bold, design: .monospaced))
                                    .foregroundColor(.neonCyan.opacity(0.8))
                                    .tracking(10)
                                    .padding(.bottom, 20 * scale)
                                
                                GlitchScoreView(
                                    score: gameManager.currentScore,
                                    isAnimating: gameManager.isGameRunning
                                )
                                .scaleEffect(scale) // Mărim și scorul glitchuit
                            }
                            .offset(y: -10 * scale)
                        }
                        .frame(height: 260 * scale) // Rezervăm loc fizic pentru elementul scalat
                        
                        Spacer()
                        
                        // --- ZONA CENTRALA: REACTORUL ---
                        ZStack {
                            ArcButton(
                                isPressed: isPressed,
                                isDeployed: isButtonDeployed
                            )
                            .scaleEffect(scale) // Mărim Butonul Reactor
                            // GESTURI
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .updating($isPressed) { _, pressed, _ in
                                        pressed = true
                                    }
                                    .onEnded { _ in
                                        handleTap()
                                    }
                            )
                            
                            // Floating Points (+1)
                            ForEach(floatingPoints) { point in
                                Text("+1")
                                    .font(.system(size: 40 * scale, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 2)
                                    .scaleEffect(point.scale)
                                    .opacity(point.opacity)
                                    .offset(x: point.x, y: point.y) // Coordonatele sunt deja setate pt iPad în funcție
                                    .onAppear {
                                        animateFloatingPoint(point)
                                    }
                            }
                        }
                        .frame(height: 240 * scale) // Rezervăm loc fizic pentru butonul mare
                        
                        Spacer()
                        
                        // --- ZONA DE JOS: RANKS ---
                        VStack(spacing: 20 * scale) {
                            Button {
                                showLeaderboard = true
                                if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                                    GameCenterManager.shared.showLeaderboard(from: rootVC)
                                }
                            } label: {
                                VStack(spacing: 6 * scale) {
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: 28 * scale)) // Icoană mare
                                    Text("RANKS")
                                        .font(.system(size: 14 * scale, weight: .bold))
                                }
                                .frame(maxWidth: 400 * scale) // Îl limităm să nu fie cât tot iPad-ul
                                .padding(.vertical, 16 * scale)
                                .background(Color.white.opacity(0.05))
                                .foregroundColor(.yellow)
                                .cornerRadius(16 * scale)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16 * scale)
                                        .stroke(Color.yellow.opacity(0.3), lineWidth: 2)
                                )
                            }
                            .opacity(gameManager.isGameRunning ? 0 : 1)
                        }
                        .padding(.bottom, 60 * scale)
                    }
                }
                .onAppear {
                    GameCenterManager.shared.authenticateLocalPlayer { success, _ in }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { areParticlesActive = true }
                    impactGen.prepare()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation { isButtonDeployed = true }
                    }
                }
                .fullScreenCover(isPresented: $gameManager.isGameOver) {
                    // Aici poți face și un GameOverView_iPad dacă vrei
                    GameOverView_iPad(
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
    
    // --- LOGICA (Aceeași, dar ajustată spațial) ---
    
    private func handleTap() {
        if !gameManager.isGameRunning {
            gameManager.startGame(
                emitterLayer: emitterLayer,
                buttonFrame: buttonFrame,
                challengeTarget: appState.challengeScoreToBeat
            )
            isAnimationActive = true
            impactGen.impactOccurred()
        } else {
            gameManager.currentScore += 1
            gameManager.buttonPressed()
            impactGen.impactOccurred(intensity: 1.0)
            triggerShake()
            spawnFloatingPoint()
        }
    }
    
    private func triggerShake() {
        // Shake mai amplu pe iPad
        let intensity: CGFloat = 12.0
        withAnimation(.linear(duration: 0.05)) { screenShakeOffset = -intensity }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.linear(duration: 0.05)) { screenShakeOffset = intensity }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.linear(duration: 0.05)) { screenShakeOffset = 0 }
        }
    }
    
    private func spawnFloatingPoint() {
        // Zonă de spawn mai largă pe iPad (-80...80)
        let newPoint = FloatingPoint(
            x: CGFloat.random(in: -80 ... 80),
            y: CGFloat.random(in: (-100 * scale) ... (-60 * scale))
        )
        floatingPoints.append(newPoint)
    }
    
    private func animateFloatingPoint(_ point: FloatingPoint) {
        if let index = floatingPoints.firstIndex(where: { $0.id == point.id }) {
            withAnimation(.easeOut(duration: 0.8)) {
                // Zboară mai sus pe iPad
                floatingPoints[index].y = -450 * scale
                floatingPoints[index].opacity = 0
                floatingPoints[index].scale = 2.0 // Textul devine mai mare când dispare
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if let idx = floatingPoints.firstIndex(where: { $0.id == point.id }) {
                    floatingPoints.remove(at: idx)
                }
            }
        }
    }
}

// Preview pe iPad
#Preview {
    GameView_iPad()
        .environmentObject(AppState())
        .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch)"))
}
