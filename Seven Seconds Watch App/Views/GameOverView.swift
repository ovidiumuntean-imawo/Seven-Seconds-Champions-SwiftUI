//
//  GameOverView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 09.01.2025.
//


import SwiftUI
import AVFoundation
import GameKit

// MARK: - GameOverView_Watch
struct GameOverView_Watch: View {
    var score: Int
    @Binding var previousScore: Int
    @Environment(\.dismiss) private var dismiss
    
    @State private var showLeaderboardFromGameOver = false
    
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
                
                GeometryReader { geo in
                    ParticlesView(particleCount: 50, particleSize: 3)
                        .frame(width: geo.size.width * 2, height: geo.size.height)
                }
                
                VStack(spacing: 0) {
                    Text("game over")
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(.white)
                        .padding(.top, -36)
                        .scaleEffect(scale)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1)) {
                                scale = 1.0
                            }
                        }
                    
                    Spacer()
                    
                    Text("YOU SCORED")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.white)
                        .padding(.top, 8)
                    
                    Text("\(score)")
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.top, -4)
                        .scaleEffect(scaleScore)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1)) {
                                scaleScore = 1.0
                            }
                        }
                    
                    Text("HITS")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.top, -4)
                    
                    Spacer()
                    
                    Button(action: {
                        previousScore = score
                        isAnimationActive = false
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            dismiss()
                        }
                    }) {
                        Text("Play again!")
                    }
                    .padding(.top, 8)
                    
                    Spacer()
                }
                .padding()
            }
            .onAppear {
                
            }
        }
    }
}

#Preview {
    @Previewable @State var previousScore = 0
    return GameOverView_Watch(score: 10, previousScore: $previousScore)
}
