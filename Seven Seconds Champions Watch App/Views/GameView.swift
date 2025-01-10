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
                        Text("Time left: \(timeLeft) seconds")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundColor(isGameRunning ? Color.orange : (timeLeft <= 3 ? Color.red : Color.white))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Main game section: HStack with scores on the left and button on the right
                        HStack(spacing: 20) {
                            // Left: Scores block
                            VStack(spacing: 10) {
                                Text("YOUR SCORE")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Text("\(currentScore)")
                                    .font(.system(size: 64, weight: .heavy))
                                    .foregroundColor(.white)
                                    .padding(.top, -8)
                                
                                Text("HITS")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.top, -8)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading) // Left alignment
                            
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
                                        .frame(width: 171, height: 171)
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
                                                    // calculateEmitterPosition(containerGeo: containerGeo, btnGeo: btnGeo)
                                                }
                                            }
                                            .onChange(of: btnGeo.size) { _ in
                                                DispatchQueue.main.async {
                                                    // calculateEmitterPosition(containerGeo: containerGeo, btnGeo: btnGeo)
                                                }
                                            }
                                    }
                                )
                            }
                            .frame(height: 171)
                            .padding(.trailing, 24)
                        }
                        .frame(maxHeight: .infinity) // Ensure vertical alignment
                        
                        Text("Previous score: \(previousScore) hits")
                            .font(.system(size: 26, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                        
                        // "How other players are doing?" + "VIEW HIGH SCORES"
                        Text("How other players are doing?")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .opacity(isGameRunning ? 0 : 1)
                            .animation(.easeInOut(duration: 0.5), value: isGameRunning)
                        
                        Button("View high scores") {
                            showLeaderboard = true
                        }
                        .padding(.horizontal)
                        .frame(height: 44)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .opacity(isGameRunning ? 0 : 1)
                        .animation(.easeInOut(duration: 0.5), value: isGameRunning)
                        .sheet(isPresented: $showLeaderboard) {
                            /*LeaderboardView()
                                .transition(.move(edge: .bottom))
                                .zIndex(1)*/
                        }
                        
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
