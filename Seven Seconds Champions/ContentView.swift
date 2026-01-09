//
//  ContentView.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 08.01.2025.
//

import SwiftUI
import AVFoundation
import GameKit

// MARK: - ContentView
struct ContentView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        Group {
            if sizeClass == .compact {
                // iPhone layout
                GameView_iPhone()
            } else {
                // iPad layout
                GameView_iPad()
            }
        }
        .fontDesign(.rounded)
    }
}
        
#Preview {
    ContentView()
}
