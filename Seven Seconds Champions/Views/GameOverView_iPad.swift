//
//  GameOverView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 09.01.2025.
//


import SwiftUI
import AVFoundation
import GameKit

// MARK: - GameOverView_iPad
struct GameOverView_iPad: View {
    var score: Int
    @Binding var previousScore: Int
    @Environment(\.dismiss) private var dismiss
    
    var achievementMessage: String?
    
    @State private var showLeaderboardFromGameOver = false
    @State private var showAchievementAlert = false
    
    // Particles
    @State private var areParticlesActive: Bool = false
    @State private var emitterLayer: CAEmitterLayer?
    @State private var emitterCell = CAEmitterCell()
    
    @State private var scale: CGFloat = 3.0
    @State private var scaleScore: CGFloat = 0
    @State private var rotation: Double = 0
    
    @State private var isAnimationActive: Bool = true
    
    var body: some View {
        GeometryReader { containerGeo in
            ZStack {
                // Background
                RotatingBackground(isAnimating: isAnimationActive)
                    .ignoresSafeArea()
                
                ParticleView(isActive: $areParticlesActive)
                                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Text("game over")
                        .font(.system(size: 128, weight: .light))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                        .scaleEffect(scale)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1)) {
                                scale = 1.0
                            }
                        }
                        /*.onAppear {
                            withAnimation(.easeInOut(duration: 1), {
                                scale = 1.6
                            })
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation(.easeInOut(duration: 1)) {
                                    scale = 1.0
                                }
                            }
                        }*/
                    
                    Text("YOU SCORED")
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                    
                    Text("\(score)")
                        .font(.system(size: 128, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.top, -24)
                        .scaleEffect(scaleScore)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1)) {
                                scaleScore = 1.0
                            }
                        }
                    
                    Text("HITS")
                        .font(.system(size: 36, weight: .medium))
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
                            .font(.system(size: 24, weight: .medium))
                            .frame(width: 320)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    Text("How other players are doing?")
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                    
                    Button("View high scores") {
                        showLeaderboardFromGameOver = true
                    }
                    .font(.system(size: 24, weight: .medium))
                    .padding(.horizontal)
                    .frame(height: 54)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .sheet(isPresented: $showLeaderboardFromGameOver) {
                        LeaderboardView()
                    }
                    
                    Spacer()
                    
                    Text("Share your best screenshots!")
                        .font(.system(size: 32))
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
                    .font(.system(size: 24, weight: .medium))
                    .padding(.horizontal)
                    .frame(height: 54)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Spacer()
                }
                .padding()
                .background(
                    Image("backgroundGameOver")
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 4)
                        .edgesIgnoringSafeArea(.all)
                )
            }
            .onAppear {
                // Create small background sparks
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                    areParticlesActive = true
                }
                
                if let achievementMessage = achievementMessage {
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
                // Butoanele din alertă
                Button("Back to game", role: .cancel) {}
                Button("Show My Achievements") {
                    if let rootVC = UIApplication.getRootViewController() {
                        GameCenterManager.shared.showAchievements(from: rootVC)
                    }
                }
                Button("View High Scores") {
                    if let rootVC = UIApplication.getRootViewController() {
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
    return GameOverView_iPad(score: 10, previousScore: $previousScore)
}
