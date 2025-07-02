//
//  GameView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 09.01.2025.
//


import SwiftUI
import AVFoundation
import QuartzCore

// MARK: - GameView_Watch
struct GameView_Watch: View {
    @StateObject private var gameManager = GameManager()
    
    // Leaderboard
    @State private var showLeaderboard = false
    
    // Pressed button effect
    @GestureState private var isPressed: Bool = false
    
    // Game Center Authentication
    @State private var showAuthenticationSheet = false
    // @State private var gameCenterAuthViewController: UIViewController? = nil
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
                    
                    GeometryReader { geo in
                        ParticlesView(particleCount: 50, particleSize: 3)
                            .frame(width: geo.size.width * 2, height: geo.size.height)
                    }
                    
                    VStack(spacing: 20) {
                        // Title
                        VStack(spacing: 0) {
                            HStack {
                                Text("7")
                                    .font(.system(size: 36, weight: .heavy))
                                    .foregroundColor(.white)
                                
                                Text("seconds")
                                    .font(.system(size: 24, weight: .light))
                                    .foregroundColor(.white)
                                    .padding(.top, 8)
                                    .padding(.leading, -4)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("CHAMPIONS")
                                .font(.system(size: 12, weight: .light))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, -4)
                        }
                        .padding(.top, -32)
                        
                        // Timer
                        Text("Time left: \(gameManager.timeLeft) seconds")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(
                                gameManager.timeLeft > 5 ? Color.white : // Default color
                                gameManager.timeLeft > 3 ? Color.yellow : // Warning color
                                gameManager.timeLeft > 1 ? Color.orange : // High attention
                                Color.red // Critical attention
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, -12)
                        
                        // Main game section: HStack with scores on the left and button on the right
                        HStack(spacing: 0) {
                            // Left: Scores block
                            VStack(spacing: 0) {
                                Text("YOUR SCORE")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.white)
                                
                                Text("\(gameManager.currentScore)")
                                    .font(.system(size: 48, weight: .heavy))
                                    .foregroundColor(.white)
                                    .padding(.top, -4)
                                
                                Text("HITS")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.top, -4)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading) // Left alignment
                            .padding(.top, -12)
                            
                            // Right: The Big Button
                            ZStack {
                                Button {
                                    if !gameManager.isGameOver {
                                        if !gameManager.isGameRunning {
                                            gameManager.startGame()
                                        } else {
                                            gameManager.currentScore += 1
                                            gameManager.buttonPressed()
                                        }
                                    }
                                } label: {
                                    Image(ButtonImage.shared.getButtonImage(for: gameManager.timeLeft, isPressed: isPressed))
                                        .resizable()
                                        .frame(width: 92, height: 92)
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
                                /*.scaleEffect(scale)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                        scale = 1.02
                                    }
                                }*/
                            }
                            .padding(.trailing, 0)
                        }
                        .frame(maxHeight: .infinity) // Ensure vertical alignment
                        .padding(.top, -8)
                        
                        Text("Last score: \(gameManager.previousScore) hits")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, -24)
                        
                        Spacer()
                    }
                    .padding()
                }
                .onAppear {
                    // Authenticate Game Center
                    GameCenterManager.shared.authenticateLocalPlayer()
                }
            }
            .fullScreenCover(isPresented: $gameManager.isGameOver) {
                GameOverView_Watch(
                    score: gameManager.currentScore,
                    previousScore: $gameManager.previousScore
                )
                .onAppear {
                    isAnimationActive = false
                }
                .onDisappear {
                    gameManager.resetGame()
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
                rotationEffect = Double.random(in: -5...5) // Rotire subtilă
                offsetX = CGFloat.random(in: -1...1)      // Deplasare mică pe X
                offsetY = CGFloat.random(in: -1...1)      // Deplasare mică pe Y
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
    GameView_Watch()
}
