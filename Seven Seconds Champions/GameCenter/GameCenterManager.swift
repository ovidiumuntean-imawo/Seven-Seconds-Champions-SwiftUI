//
//  GameCenterManager.swift
//  seven.seconds
//
//  Created by Ovidiu Muntean on 09.01.2025.
//

import UIKit
import GameKit

class GameCenterManager: NSObject, GKGameCenterControllerDelegate {
    private var isGameCenterEnabled = false
    private var leaderboardID = "seven.seconds.leaderboard"

    static let shared = GameCenterManager()
    private override init() {
        super.init()
    }
    
    // MARK: - Authentication
    func authenticateLocalPlayer(completion: @escaping (Bool, UIViewController?) -> Void) {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { viewController, error in
            if let error = error {
                print("Game Center auth error:", error.localizedDescription)
                completion(false, nil)
                return
            }
            if let viewController = viewController {
                // Present authentication view controller
                completion(false, viewController)
            } else if localPlayer.isAuthenticated {
                self.isGameCenterEnabled = true
                localPlayer.loadDefaultLeaderboardIdentifier { leaderboardIdentifier, error in
                    if let leaderboardIdentifier = leaderboardIdentifier {
                        self.leaderboardID = leaderboardIdentifier
                        completion(true, nil)
                    } else {
                        print("Error loading leaderboard identifier:", error?.localizedDescription ?? "Unknown error")
                        completion(false, nil)
                    }
                }
            } else {
                self.isGameCenterEnabled = false
                print("Game Center is not enabled.")
                completion(false, nil)
            }
        }
    }
    
    // MARK: - Leaderboard
    func submitScore(with value: Int) {
        guard isGameCenterEnabled else {
            print("Game Center is not enabled.")
            return
        }
        let score = GKScore(leaderboardIdentifier: leaderboardID)
        score.value = Int64(value)
        GKScore.report([score]) { error in
            if let error = error {
                print("Error reporting score:", error.localizedDescription)
            } else {
                print("Score submitted successfully.")
            }
        }
    }
    
    func showLeaderboard(from viewController: UIViewController) {
        guard GKLocalPlayer.local.isAuthenticated else {
            presentGameCenterUnavailableAlert(from: viewController)
            return
        }

        if viewController.presentedViewController != nil {
            viewController.dismiss(animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.presentLeaderboard(from: viewController)
                }
            }
        } else {
            presentLeaderboard(from: viewController)
        }
    }
    
    private func presentLeaderboard(from viewController: UIViewController) {
        let gcViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = .leaderboards
        gcViewController.leaderboardIdentifier = leaderboardID
        viewController.present(gcViewController, animated: true)
    }
    
    // MARK: - Achievements
    func reportAchievement(achievementID: String, percentComplete: Double) {
        guard GKLocalPlayer.local.isAuthenticated else {
            print("Player is not authenticated.")
            return
        }
        
        let achievement = GKAchievement(identifier: achievementID)
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true
        
        GKAchievement.report([achievement]) { error in
            if let error = error {
                print("Error reporting achievement:", error.localizedDescription)
            } else {
                print("Achievement \(achievementID) reported successfully.")
            }
        }
    }
    
    func showAchievements(from viewController: UIViewController) {
        guard GKLocalPlayer.local.isAuthenticated else {
            presentGameCenterUnavailableAlert(from: viewController)
            return
        }

        if viewController.presentedViewController != nil {
            viewController.dismiss(animated: true) {
                self.presentAchievements(from: viewController)
            }
        } else {
            presentAchievements(from: viewController)
        }
    }

    private func presentAchievements(from viewController: UIViewController) {
        let gcViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = .achievements
        viewController.present(gcViewController, animated: true)
    }
    
    // MARK: - Alerts    
    private func presentGameCenterUnavailableAlert(from viewController: UIViewController) {
        if viewController.presentedViewController != nil {
            viewController.dismiss(animated: true) {
                self.presentAlert(from: viewController)
            }
        } else {
            presentAlert(from: viewController)
        }
    }

    private func presentAlert(from viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Game Center is not available",
            message: "Please sign in to Game Center to view High-Scores!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }


    // MARK: - GKGameCenterControllerDelegate
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
    
    // MARK: - Helper
    func isGameCenterActive() -> Bool {
        return isGameCenterEnabled
    }
}
