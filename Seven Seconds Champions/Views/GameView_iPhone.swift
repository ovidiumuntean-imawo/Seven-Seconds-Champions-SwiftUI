//
//  GameView 2.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 15.01.2025.
//

import SwiftUI
import AVFoundation
import GameKit

// MARK: - GameView_iPhone
struct GameView_iPhone: View {
    @StateObject private var gameManager = GameManager()
    
    // Particles
    @State private var areParticlesActive: Bool = false
    @State private var emitterLayer: CAEmitterLayer?
    @State private var emitterCell = CAEmitterCell()
    
    // We'll store just the bottom-center of the big button in absolute screen coords.
    @State private var buttonFrame: CGRect = .zero {
        didSet {
            // If not running, keep sparks in standby
            if buttonFrame != .zero, !gameManager.isGameRunning {
                Sparks.shared.updateSparks(
                                    emitterLayer: emitterLayer,
                                    gameManager: gameManager,
                                    buttonFrame: buttonFrame
                                )
            }
        }
    }
    
    // Leaderboard
    @State private var showLeaderboard = false
    
    // Pressed button effect
    @GestureState private var isPressed: Bool = false
    
    // Game Center Authentication
    @State private var showAuthenticationSheet = false
    @State private var gameCenterAuthViewController: UIViewController? = nil
    @State private var showAuthErrorAlert = false
    @State private var authErrorMessage: String = ""
    
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    
    @State private var isAnimationActive: Bool = false
    @State private var currentImage: String = "button_normal"
    
    @State private var offsetX: CGFloat = 0.0
    @State private var offsetY: CGFloat = 0.0
    @State private var rotationEffect: Double = 0.0
    
    var body: some View {
        NavigationStack {
            GeometryReader { containerGeo in
                ZStack {
                    // Background
                    RotatingBackground(isAnimating: isAnimationActive)
                        .ignoresSafeArea()
                    
                    ParticleView(isActive: $areParticlesActive)
                                    .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        // Title
                        VStack(spacing: 0) {
                            HStack {
                                Text("7")
                                    .font(.system(size: 96, weight: .heavy))
                                    .foregroundColor(.white)
                                
                                Text("seconds")
                                    .font(.system(size: 64, weight: .light))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, -12)
                            
                            Text("CHAMPIONS")
                                .font(.system(size: 32, weight: .light))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.top, -12)
                        
                        // Subtitle
                        Text("Hit that button as fast as you can!")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 24)

                        // Timer
                        Text("Time left: \(gameManager.timeLeft) seconds")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(
                                gameManager.timeLeft > 5 ? Color.white : // Default color
                                gameManager.timeLeft > 3 ? Color.yellow : // Warning color
                                gameManager.timeLeft > 2 ? Color.orange : // High attention
                                Color.red // Critical attention
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main game section: HStack with scores on the left and button on the right
                        HStack(spacing: 20) {
                            // Left: Scores block
                            VStack(spacing: 10) {
                                Text("YOUR SCORE")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Text("\(gameManager.currentScore)")
                                    .font(.system(size: 64, weight: .heavy))
                                    .foregroundColor(.white)
                                    .padding(.top, -8)
                                
                                Text("HITS")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.top, -8)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading) // Left alignment
                            .padding(.top, -16)
                            
                            // Right: The Big Button
                            ZStack {
                                Button {
                                    if !gameManager.isGameOver {
                                        if !gameManager.isGameRunning {
                                            gameManager.startGame(emitterLayer: emitterLayer, buttonFrame: buttonFrame)
                                        } else {
                                            gameManager.currentScore += 1
                                            gameManager.buttonPressed()
                                            
                                            Sparks.shared.updateSparks(
                                                emitterLayer: emitterLayer,
                                                gameManager: gameManager,
                                                buttonFrame: buttonFrame
                                            )
                                        }
                                    }
                                } label: {
                                    Image(ButtonImage.shared.getButtonImage(for: gameManager.timeLeft, isPressed: isPressed))
                                        .resizable()
                                        .frame(width: 171, height: 171)
                                        .rotationEffect(.degrees(rotationEffect))
                                            .offset(x: offsetX, y: offsetY)
                                            .onChange(of: gameManager.timeLeft) { newTimeLeft in
                                                handleImageChange(timeLeft: newTimeLeft)
                                            }
                                }
                                .buttonStyle(.plain)
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 0)
                                        .updating($isPressed) { _, pressed, _ in
                                            pressed = true
                                        }
                                )
                                .background(
                                    GeometryReader { btnGeo in
                                        Color.clear
                                            .onAppear {
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
                                            .onChange(of: btnGeo.size) { _ in
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
                                    }
                                )
                                /*.scaleEffect(scale)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                        scale = 1.04
                                    }
                                }*/
                                .padding(.top, 16)
                            }
                            .padding(.trailing, 24)
                        }
                        .padding(.bottom, 8)
                    
                        Text("Last score: \(gameManager.previousScore) hits")
                            .font(.system(size: 26, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()
                        
                        // "How other players are doing?" + "VIEW HIGH SCORES"
                        Text("How other players are doing?")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .opacity(gameManager.isGameRunning ? 0 : 1)
                            .animation(.easeInOut(duration: 0.5), value: gameManager.isGameRunning)
                        
                        Button("View high scores") {
                            showLeaderboard = true
                            
                            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                                GameCenterManager.shared.showLeaderboard(from: rootVC)
                            }
                        }
                        .padding(.horizontal)
                        .frame(height: 44)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .opacity(gameManager.isGameRunning ? 0 : 1)
                        .animation(.easeInOut(duration: 0.5), value: gameManager.isGameRunning)
                        
                        Spacer()
                    }
                    .padding()
                }
                .onAppear {
                    // Authenticate Game Center
                    GameCenterManager.shared.authenticateLocalPlayer { success, viewControllerGame in
                        if success {
                            print("Game Center authenticated successfully.")
                        } else {
                            if let viewControllerGame = viewControllerGame {
                                // Set the viewController to present
                                self.gameCenterAuthViewController = viewControllerGame
                                self.showAuthenticationSheet = true
                            } else {
                                print("Failed to authenticate Game Center.")
                                authErrorMessage = "Game Center is not enabled on your device or authentication failed."
                                showAuthErrorAlert = true
                            }
                        }
                    }
                    
                    // Create small background sparks
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                        areParticlesActive = true
                    }
                }
                .onDisappear {
                    areParticlesActive = false
                }
            }
            .fullScreenCover(isPresented: $gameManager.isGameOver) {
                GameOverView_iPhone(
                    score: gameManager.currentScore,
                    previousScore: $gameManager.previousScore,
                    achievementMessage: gameManager.achievementMessage
                )
                .onAppear {
                    isAnimationActive = false
                }
                .onDisappear {
                    gameManager.resetGame(emitterLayer: emitterLayer, buttonFrame: buttonFrame)
                }
            }
        }
    }
    
    private func handleImageChange(timeLeft: Int) {
        let newImage = ButtonImage.shared.getButtonImage(for: timeLeft, isPressed: isPressed)
        if newImage != currentImage {
            // Actualizăm imaginea la noua stare
            currentImage = newImage

            // Aplicăm vibrația
            withAnimation(.easeInOut(duration: 0.02)) {
                rotationEffect = Double.random(in: -7...7) // Rotire subtilă
                offsetX = CGFloat.random(in: -3...3)      // Deplasare mică pe X
                offsetY = CGFloat.random(in: -3...3)      // Deplasare mică pe Y
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: 0.05)) {
                    rotationEffect = Double.random(in: -8...8) // Rotire mai intensă
                    offsetX = CGFloat.random(in: -5...5)
                    offsetY = CGFloat.random(in: -5...5)
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.05)) {
                    rotationEffect = 0.0
                    offsetX = 0.0
                    offsetY = 0.0
                }
            }
        }
    }
}


#Preview {
    GameView_iPhone()
}

