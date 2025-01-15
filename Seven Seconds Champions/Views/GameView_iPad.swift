//
//  GameView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 09.01.2025.
//


import SwiftUI
import AVFoundation
import GameKit

// MARK: - GameView_iPad
struct GameView_iPad: View {
    @StateObject private var gameManager = GameManager()
    
    // Particles
    @State private var emitterLayerGlobal: CAEmitterLayer?
    @State private var emitterCellGlobal = CAEmitterCell()
    
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
    
    var body: some View {
        NavigationStack {
            GeometryReader { containerGeo in
                ZStack {
                    // Background
                    RotatingBackground()
                    
                    VStack(spacing: 20) {
                        // Title
                        VStack(spacing: 0) {
                            HStack {
                                Text("7")
                                    .font(.system(size: 172, weight: .heavy))
                                    .foregroundColor(.white)
                                
                                Text("seconds")
                                    .font(.system(size: 128, weight: .light))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, -12)
                            
                            Text("CHAMPIONS")
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.top, -12)
                        
                        // Subtitle
                        Text("Hit that button as fast as you can!")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 48)

                        // Timer
                        Text("Time left: \(gameManager.timeLeft) seconds")
                            .font(.system(size: 72, weight: .regular))
                            .foregroundColor(
                                gameManager.timeLeft > 5 ? Color.white : // Default color
                                gameManager.timeLeft > 3 ? Color.yellow : // Warning color
                                gameManager.timeLeft > 1 ? Color.orange : // High attention
                                Color.red // Critical attention
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main game section: HStack with scores on the left and button on the right
                        HStack(spacing: 20) {
                            // Left: Scores block
                            VStack(spacing: 0) {
                                Text("YOUR SCORE")
                                    .font(.system(size: 36, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Text("\(gameManager.currentScore)")
                                    .font(.system(size: 128, weight: .heavy))
                                    .foregroundColor(.white)
                                
                                Text("HITS")
                                    .font(.system(size: 36, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading) // Left alignment
                            .padding(.top, -48)
                            
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
                                    Image(isPressed ? "button_pressed" : "button_normal")
                                        .resizable()
                                        .frame(width: 280, height: 280)
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
                                .padding(.top, 48)
                            }
                            .padding(.trailing, 72)
                        }
                        
                        Text("Last score: \(gameManager.previousScore) hits")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()
                        
                        // "How other players are doing?" + "VIEW HIGH SCORES"
                        Text("How other players are doing?")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .opacity(gameManager.isGameRunning ? 0 : 1)
                            .animation(.easeInOut(duration: 0.5), value: gameManager.isGameRunning)
                        
                        Button("View high scores") {
                            showLeaderboard = true
                        }
                        .font(.system(size: 24, weight: .medium))
                        .padding(.horizontal)
                        .frame(height: 54)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .opacity(gameManager.isGameRunning ? 0 : 1)
                        .animation(.easeInOut(duration: 0.5), value: gameManager.isGameRunning)
                        .sheet(isPresented: $showLeaderboard) {
                            LeaderboardView()
                                .transition(.move(edge: .bottom))
                                .zIndex(1)
                        }
                        
                        Spacer()
                    }
                    .padding(.leading, 40)
                    .padding(.trailing, 40)
                    .padding(.top, 40)
                    .padding(.bottom, 40)
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
                    Sparks.shared.createSmallSparks(
                        emitterLayerGlobal: &emitterLayerGlobal,
                        emitterCellGlobal: emitterCellGlobal,
                        parentSize: containerGeo.size
                    )
                }
            }
            .fullScreenCover(isPresented: $gameManager.isGameOver) {
                GameOverView_iPad(score: gameManager.currentScore, previousScore: $gameManager.previousScore)
                    .onDisappear {
                        gameManager.resetGame(emitterLayer: emitterLayer, buttonFrame: buttonFrame)
                    }
            }
        }
    }
}

#Preview {
    GameView_iPad()
}
