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
    // Game states
    @State private var timeLeft: Int = 7
    @State private var currentScore: Int = 0
    @State private var previousScore: Int = 0
    @State private var isGameOver: Bool = false
    @State private var isGameRunning: Bool = false
    
    // Leaderboard
    @State private var showLeaderboard = false
    
    // Pressed button effect
    @GestureState private var isPressed: Bool = false
    
    // Game Center Authentication
    @State private var showAuthenticationSheet = false
    // @State private var gameCenterAuthViewController: UIViewController? = nil
    @State private var showAuthErrorAlert = false
    @State private var authErrorMessage: String = ""
    
    // Audio
    private var buttonBeep: AVAudioPlayer? = AudioPlayerFactory.createAudioPlayer(fileName: "button", fileType: "wav")
    private var explodeBeep: AVAudioPlayer? = AudioPlayerFactory.createAudioPlayer(fileName: "explode", fileType: "wav")
    
    var body: some View {
        NavigationStack {
            GeometryReader { containerGeo in
                ZStack {
                    // Background
                    Image("background")
                        .resizable()
                        .scaledToFill()
                        .frame(width: containerGeo.size.width,
                               height: containerGeo.size.height)
                        .edgesIgnoringSafeArea(.all)
                        .blur(radius: 10)
                    
                    VStack(spacing: 20) {
                        // Title
                        VStack(spacing: 0) {
                            HStack {
                                Text("7")
                                    .font(.system(size: 32, weight: .heavy))
                                    .foregroundColor(.white)
                                
                                Text("seconds")
                                    .font(.system(size: 18, weight: .light))
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
                        .padding(.top, -36)
                        
                        // Timer
                        Text("Time left: \(timeLeft) seconds")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(isGameRunning ? Color.orange : (timeLeft <= 3 ? Color.red : Color.white))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, -12)
                        
                        // Main game section: HStack with scores on the left and button on the right
                        HStack(spacing: 0) {
                            // Left: Scores block
                            VStack(spacing: 0) {
                                Text("YOUR SCORE")
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(.white)
                                
                                Text("\(currentScore)")
                                    .font(.system(size: 36, weight: .heavy))
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
                                    if !isGameRunning {
                                        startGame()
                                    }
                                    currentScore += 1
                                    buttonBeep?.play()
                                } label: {
                                    Image(isPressed ? "button_pressed" : "button_normal")
                                        .resizable()
                                        .frame(width: 92, height: 92)
                                }
                                .buttonStyle(.plain)
                                .simultaneousGesture(
                                    DragGesture(minimumDistance: 0)
                                        .updating($isPressed) { _, pressed, _ in
                                            pressed = true
                                        }
                                )
                            }
                            .padding(.trailing, 0)
                        }
                        .frame(maxHeight: .infinity) // Ensure vertical alignment
                        .padding(.top, -8)
                        
                        Text("Previous score: \(previousScore) hits")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, -18)
                        
                        Spacer()
                    }
                    .padding()
                }
                .onAppear {
                    // Authenticate Game Center
                    /*GameCenterManager.shared.authenticateLocalPlayer { success, viewControllerGame in
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
                    }*/
                }
            }
            .fullScreenCover(isPresented: $isGameOver) {
                GameOverView_Watch(score: currentScore, previousScore: $previousScore)
                    .onDisappear {
                        resetUI()
                    }
            }
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
    }
    
    private func endGame() {
        isGameRunning = false
        explodeBeep?.play()
        isGameOver = true
        
        // Submit score to Game Center
        GameCenterManager.shared.submitScore(with: currentScore)
    }
    
    private func resetUI() {
        timeLeft = 7
        currentScore = 0
    }
}

#Preview {
    GameView_Watch()
}
