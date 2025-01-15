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
    // Game states
    @State private var timeLeft: Int = 7
    @State private var currentScore: Int = 0
    @State private var previousScore: Int = 0
    @State private var isGameOver: Bool = false
    @State private var isGameRunning: Bool = false
    
    // Particles
    @State private var emitterLayerGlobal: CAEmitterLayer?
    @State private var emitterCellGlobal = CAEmitterCell()
    
    @State private var emitterLayer: CAEmitterLayer?
    @State private var emitterCell = CAEmitterCell()
    
    // We'll store just the bottom-center of the big button in absolute screen coords.
    @State private var buttonFrame: CGRect = .zero {
        didSet {
            // If not running, keep sparks in standby
            if buttonFrame != .zero, !isGameRunning {
                Sparks.shared.updateSparks(
                    emitterLayer: emitterLayer,
                    score: currentScore,
                    buttonFrame: buttonFrame,
                    isGameRunning: false
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
    
    // Audio
    private var buttonBeep: AVAudioPlayer? = AudioPlayerFactory.createAudioPlayer(fileName: "button", fileType: "wav")
    private var explodeBeep: AVAudioPlayer? = AudioPlayerFactory.createAudioPlayer(fileName: "explode", fileType: "wav")
    
    var body: some View {
        NavigationStack {
            GeometryReader { containerGeo in
                ZStack {
                    // Background
                    RotatingBackground()
                    
                    /*VisualEffectBlur(style: .dark)
                        .edgesIgnoringSafeArea(.all)*/
                    
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
                        Text("Time left: \(timeLeft) seconds")
                            .font(.system(size: 72, weight: .regular))
                            .foregroundColor(isGameRunning ? Color.orange : (timeLeft <= 3 ? Color.red : Color.white))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main game section: HStack with scores on the left and button on the right
                        HStack(spacing: 20) {
                            // Left: Scores block
                            VStack(spacing: 0) {
                                Text("YOUR SCORE")
                                    .font(.system(size: 36, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Text("\(currentScore)")
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
                                    if !isGameOver {
                                        if !isGameRunning {
                                            startGame()
                                        }
                                        currentScore += 1
                                        buttonBeep?.play()
                                        
                                        Sparks.shared.updateSparks(
                                            emitterLayer: emitterLayer,
                                            score: currentScore,
                                            buttonFrame: buttonFrame,
                                            isGameRunning: true
                                        )
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
                                                    calculateEmitterPosition(containerGeo: containerGeo, btnGeo: btnGeo)
                                                }
                                            }
                                            .onChange(of: btnGeo.size) { _ in
                                                DispatchQueue.main.async {
                                                    calculateEmitterPosition(containerGeo: containerGeo, btnGeo: btnGeo)
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
                        
                        Text("Last score: \(previousScore) hits")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer()
                        
                        // "How other players are doing?" + "VIEW HIGH SCORES"
                        Text("How other players are doing?")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                            .opacity(isGameRunning ? 0 : 1)
                            .animation(.easeInOut(duration: 0.5), value: isGameRunning)
                        
                        Button("View high scores") {
                            showLeaderboard = true
                        }
                        .font(.system(size: 24, weight: .medium))
                        .padding(.horizontal)
                        .frame(height: 54)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .opacity(isGameRunning ? 0 : 1)
                        .animation(.easeInOut(duration: 0.5), value: isGameRunning)
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
            .fullScreenCover(isPresented: $isGameOver) {
                GameOverView_iPad(score: currentScore, previousScore: $previousScore)
                    .onDisappear {
                        resetUI()
                    }
            }
        }
    }
    
    // MARK: - Combine containerGeo + btnGeo
    private func calculateEmitterPosition(containerGeo: GeometryProxy, btnGeo: GeometryProxy) {
        // Full container rect if needed
        let containerRect = containerGeo.frame(in: .global)
        let buttonRect = btnGeo.frame(in: .global)
        
        // If the buttonRect is correct, this is enough
        guard buttonRect.width > 0, buttonRect.height > 0 else { return }
        
        // bottom-center = (minX + width/2, minY + height)
        let buttonWidth  = buttonRect.width
        let buttonHeight = buttonRect.height
        
        let bottomCenterX = buttonRect.minX + (buttonWidth / 2)
        let bottomCenterY = buttonRect.minY + buttonHeight
        
        // If the bounding box is still off, add offset
        // let finalX = bottomCenterX + 10
        let finalX = bottomCenterX
        let finalY = bottomCenterY
    
        let newFrame = CGRect(x: finalX, y: finalY, width: 0, height: 0)
        
        buttonFrame = newFrame
        
        if emitterLayer == nil {
            Sparks.shared.createSparks(
                emitterLayer: &emitterLayer,
                emitterCell: emitterCell,
                buttonFrame: newFrame
            )
            Sparks.shared.updateSparks(
                emitterLayer: emitterLayer,
                score: currentScore,
                buttonFrame: newFrame,
                isGameRunning: false
            )
        } else {
            Sparks.shared.updateSparks(
                emitterLayer: emitterLayer,
                score: currentScore,
                buttonFrame: newFrame,
                isGameRunning: isGameRunning
            )
        }
    }
    
    // MARK: - Game logic
    private func startGame() {
        isGameRunning = true
        currentScore = 0
        timeLeft = 7
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                timer.invalidate()
                endGame()
            }
        }
        
        if let emitterLayer = emitterLayer {
            Sparks.shared.updateSparks(
                emitterLayer: emitterLayer,
                score: currentScore,
                buttonFrame: buttonFrame,
                isGameRunning: true
            )
        }
    }
    
    private func endGame() {
        isGameRunning = false
        explodeBeep?.play()
        isGameOver = true
        
        // Submit score to Game Center
        GameCenterManager.shared.submitScore(with: currentScore)
        
        if let emitterLayer = emitterLayer {
            Sparks.shared.updateSparks(
                emitterLayer: emitterLayer,
                score: currentScore,
                buttonFrame: buttonFrame,
                isGameRunning: false
            )
        }
    }
    
    private func resetUI() {
        timeLeft = 7
        currentScore = 0
        isGameOver = false
        
        if let emitterLayer = emitterLayer {
            Sparks.shared.updateSparks(
                emitterLayer: emitterLayer,
                score: 0,
                buttonFrame: buttonFrame,
                isGameRunning: false
            )
        }
    }
}

#Preview {
    GameView_iPad()
}
