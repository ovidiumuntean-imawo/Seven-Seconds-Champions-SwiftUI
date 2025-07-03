//
//  GameOverView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 15.01.2025.
//

import SwiftUI
import AVFoundation
import GameKit
import StoreKit

// MARK: - GameOverView_iPhone
struct GameOverView_iPhone: View {
    @ObservedObject var gameManager: GameManager
    
    @Binding var previousScore: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) var requestReview
    
    @State private var showAchievementAlert = false
    @State private var showNewHighScoreAlert = false
    
    // Particles
    @State private var areParticlesActive: Bool = false
    @State private var emitterLayer: CAEmitterLayer?
    @State private var emitterCell = CAEmitterCell()
    
    @State private var scale: CGFloat = 3.0
    @State private var scaleScore: CGFloat = 0
    @State private var rotation: Double = 0
    
    @State private var isAnimationActive: Bool = false
    
    private var challengeText: String {
        "I challenge you to 7 Seconds! I scored \(gameManager.currentScore) taps. Can you beat that? sevenseconds://challenge?score=\(gameManager.currentScore)"
    }
    
    var body: some View {
        GeometryReader { containerGeo in
            ZStack {
                // Background
                RotatingBackground(isAnimating: isAnimationActive)
                    .ignoresSafeArea()
                
                ParticleView(isActive: $areParticlesActive)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("game over")
                        .font(.system(size: 64, weight: .light))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                        .scaleEffect(scale)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1)) {
                                scale = 1.0
                            }
                        }
                    
                    Text("YOU SCORED")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                    
                    Text("\(gameManager.currentScore)")
                        .font(.system(size: 72, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.top, -24)
                        .scaleEffect(scaleScore)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1)) {
                                scaleScore = 1.0
                            }
                        }
                    
                    Text("TAPS")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.top, -24)
                    
                    Button(action: {
                        previousScore = gameManager.currentScore
                        isAnimationActive = false
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            dismiss()
                        }
                    }) {
                        Text("Play again")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 32)
                    
                    ShareLink(item: challengeText) {
                        Label("Challenge Your Friends!", systemImage: "gamecontroller.fill")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    Text("How other players are doing?")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        previousScore = gameManager.currentScore
                        isAnimationActive = false
                        
                        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                            GameCenterManager.shared.showLeaderboard(from: rootVC)
                        }
                    }) {
                        Text("View high scores")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                    
                    /*Text("Share your best screenshots!")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                    
                    Button("Visit our FB Group") {
                        if let encodedURLString = "https://facebook.com/groups/sevensecondschampions"
                            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                           let url = URL(string: encodedURLString) {
                            UIApplication.shared.open(url)
                        } else {
                            print("Invalid URL")
                        }
                    }
                    .padding(.horizontal)
                    .frame(height: 44)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Spacer()*/
                }
                .padding()
            }
            .onAppear {
                // Create small background sparks
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    areParticlesActive = true
                }
                
                if gameManager.isNewHighScore {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showNewHighScoreAlert = true
                    }
                } else if let achievement = gameManager.achievementMessage, gameManager.currentScore >= 35 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        showAchievementAlert = true
                    }
                }
            }
            .onDisappear {
                areParticlesActive = false
            }
            .alert(isPresented: $showNewHighScoreAlert) {
                Alert(
                    title: Text("PHENOMENAL! 🚀"),
                    message: Text("Congrats, you’ve just set a new record: \(gameManager.currentScore) taps! \n\nYou're a legend — part human, part lightning! ⚡️"),
                    dismissButton: .default(Text("Thanks!"), action: {
                        requestReview()
                    })
                )
            }
            .alert(
                "Achievement Unlocked!",
                isPresented: $showAchievementAlert,
                presenting: gameManager.achievementMessage
            ) { message in
                Button("Back to game", role: .cancel) {
                    previousScore = gameManager.currentScore
                }
                Button("Show My Achievements") {
                    previousScore = gameManager.currentScore
                    isAnimationActive = false
                    
                    if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                        GameCenterManager.shared.showAchievements(from: rootVC)
                    }
                }
                Button("View High Scores") {
                    isAnimationActive = false
                    previousScore = gameManager.currentScore
                    
                    if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                        GameCenterManager.shared.showLeaderboard(from: rootVC)
                    }
                }
            } message: { message in
                Text("\n\(message)\n")
                    .multilineTextAlignment(.center)
                    .padding()

            }
        }
    }
}

#Preview {
    let mockGameManager = GameManager()
    mockGameManager.currentScore = 100
    mockGameManager.achievementMessage = "Ai deblocat realizarea 'Maestru Zen'!"

    return GameOverView_iPhone(
        gameManager: mockGameManager,
        previousScore: .constant(80)
    )
}
