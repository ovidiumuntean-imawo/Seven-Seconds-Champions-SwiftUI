//
//  GameOverView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 15.01.2025.
//

import SwiftUI
import AVFoundation
import GameKit

// MARK: - GameOverView_iPhone
struct GameOverView_iPhone: View {
    var score: Int
    @Binding var previousScore: Int
    @Environment(\.dismiss) private var dismiss
    
    var achievementMessage: String?
    
    @State private var showAchievementAlert = false
    
    // Particles
    @State private var areParticlesActive: Bool = false
    @State private var emitterLayer: CAEmitterLayer?
    @State private var emitterCell = CAEmitterCell()
    
    @State private var scale: CGFloat = 3.0
    @State private var scaleScore: CGFloat = 0
    @State private var rotation: Double = 0
    
    @State private var isAnimationActive: Bool = false
    
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
                    
                    Text("\(score)")
                        .font(.system(size: 72, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.top, -24)
                        .scaleEffect(scaleScore)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1)) {
                                scaleScore = 1.0
                            }
                        }
                    
                    Text("HITS")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.top, -24)
                    
                    Button(action: {
                        previousScore = score
                        isAnimationActive = false
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            dismiss()
                        }
                    }) {
                        Text("Play again!")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    Text("How other players are doing?")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                    
                    Button("View high scores") {
                        previousScore = score
                        isAnimationActive = false
                        
                        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                            GameCenterManager.shared.showLeaderboard(from: rootVC)
                        }
                    }
                    .padding(.horizontal)
                    .frame(height: 44)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Text("Share your best screenshots!")
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
                    
                    Spacer()
                }
                .padding()
            }
            .onAppear {
                // Create small background sparks
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    areParticlesActive = true
                }
                
                if let achievementMessage = achievementMessage, score >= 35 {
                    showAchievementAlert = true
                }
            }
            .onDisappear {
                areParticlesActive = false
            }
            .alert(
                "Achievement Unlocked!",
                isPresented: $showAchievementAlert,
                presenting: achievementMessage
            ) { message in
                Button("Back to game", role: .cancel) {
                    previousScore = score
                }
                Button("Show My Achievements") {
                    previousScore = score
                    isAnimationActive = false
                    
                    if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                        GameCenterManager.shared.showAchievements(from: rootVC)
                    }
                }
                Button("View High Scores") {
                    isAnimationActive = false
                    previousScore = score
                    
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
    @Previewable @State var previousScore = 0
    return GameOverView_iPhone(score: 10, previousScore: $previousScore)
}
