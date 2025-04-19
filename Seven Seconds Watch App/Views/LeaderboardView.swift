//
//  LeaderboardView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 09.01.2025.
//


import SwiftUI
import GameKit

// MARK: - SwiftUI Leaderboard Wrapper
/*struct LeaderboardView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = context.coordinator
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = "seven.seconds.leaderboard"
        return gcVC
    }
    
    func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, GKGameCenterControllerDelegate {
        let parent: LeaderboardView
        init(_ parent: LeaderboardView) { self.parent = parent }
        
        func gameCenterViewControllerDidFinish(_ gcViewController: GKGameCenterViewController) {
            gcViewController.dismiss(animated: true)
        }
    }
}*/
