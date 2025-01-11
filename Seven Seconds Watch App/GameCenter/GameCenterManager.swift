//
//  GameCenterManager.swift
//  seven.seconds
//
//  Created by Ovidiu Muntean on 09.01.2025.
//

import UIKit
import AVFoundation
import GameKit

class GameCenterManager {
    private var isGameCenterEnabled = false
    private var leaderboardID = "seven.seconds.leaderboard"
    
    static let shared = GameCenterManager()
    private init() {}
    
    /*func authenticateLocalPlayer(completion: @escaping (Bool, UIViewController?) -> Void) {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { viewControllerGame, error in
            guard error == nil else {
                print("Game Center auth error:", error?.localizedDescription ?? "")
                completion(false, nil)
                return
            }
            if let viewControllerGame = viewControllerGame {
                // Autentificarea necesită prezentarea unui UIViewController
                completion(false, viewControllerGame)
            } else if localPlayer.isAuthenticated {
                self.isGameCenterEnabled = true
                localPlayer.loadDefaultLeaderboardIdentifier { (leaderboardIdentifier, error) in
                    if let leaderboardID = leaderboardIdentifier, error == nil {
                        self.leaderboardID = leaderboardID
                        completion(true, nil)
                    } else {
                        print("Error loading leaderboard identifier:", error?.localizedDescription ?? "Unknown error")
                        completion(false, nil)
                    }
                }
            } else {
                self.isGameCenterEnabled = false
                print("Game center is not enabled on the user's device")
                completion(false, nil)
            }
        }
    }*/
    
    func submitScore(with value: Int) {
        guard isGameCenterEnabled else {
            print("Game Center Not Enabled")
            return
        }
        
        let score = GKScore(leaderboardIdentifier: leaderboardID)
        score.value = Int64(value)
        GKScore.report([score]) { (error) in
            if let error = error {
                print("Error reporting score:", error.localizedDescription)
            } else {
                print("Score submitted successfully.")
            }
        }
    }
    /*func showLeaderboard(viewController: UIViewController) {
        let gcViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = viewController as? GKGameCenterControllerDelegate
        gcViewController.viewState = .leaderboards
        gcViewController.leaderboardIdentifier = leaderboardID
        viewController.present(gcViewController, animated: true)
    }*/
    
    func gameCenterEnabled() -> Bool {
        return isGameCenterEnabled
    }
}
