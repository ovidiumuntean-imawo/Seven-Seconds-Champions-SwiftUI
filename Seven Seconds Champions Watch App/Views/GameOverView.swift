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
    
    var body: some View {
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
                
                VStack(spacing: 30) {
                    Text("game over")
                        .font(.system(size: 64, weight: .light))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    Text("YOU SCORED")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                    
                    Text("\(score)")
                        .font(.system(size: 72, weight: .heavy))
                        .foregroundColor(.white)
                        .padding(.top, -24)
                    
                    Text("HITS")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.top, -24)
                    
                    Button(action: {
                        previousScore = score
                        dismiss()
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
                        showLeaderboardFromGameOver = true
                    }
                    .padding(.horizontal)
                    .frame(height: 44)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .sheet(isPresented: $showLeaderboardFromGameOver) {
                        // LeaderboardView()
                    }
                    
                    Spacer()
                    
                    Text("Share your best screenshots!")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                    
                    Button("Visit our FB Group") {
                        if let encodedURLString = "https://facebook.com/groups/sevensecondschampions"
                                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                               let url = URL(string: encodedURLString) {
                                // UIApplication.shared.open(url)
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
                .background(
                    Image("backgroundGameOver")
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 4)
                        .edgesIgnoringSafeArea(.all)
                )
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
