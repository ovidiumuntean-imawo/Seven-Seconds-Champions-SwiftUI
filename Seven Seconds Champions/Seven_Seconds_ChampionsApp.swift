//
//  Seven_Seconds_ChampionsApp.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 08.01.2025.
//

import SwiftUI
import SwiftData

@main
struct Seven_Seconds_ChampionsApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onOpenURL { url in
                    // Codul care se execută când deschizi un link de provocare
                    guard url.scheme == "sevenseconds", url.host == "challenge" else { return }
                    
                    let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
                    if let scoreItem = components?.queryItems?.first(where: { $0.name == "score" }) {
                        if let scoreValue = scoreItem.value, let score = Int(scoreValue) {
                            // Setăm scorul de batut
                            appState.challengeScoreToBeat = score
                            // Tragem semnalul de alarmă, generând un ID unic pentru eveniment
                            appState.newChallengeReceived = UUID()
                        }
                    }
                }
        }
    }
    
    /*var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }*/
}
