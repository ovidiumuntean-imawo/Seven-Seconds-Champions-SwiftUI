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
<<<<<<< HEAD
=======
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

>>>>>>> main
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
<<<<<<< HEAD
=======
        .modelContainer(sharedModelContainer)
>>>>>>> main
    }
}
