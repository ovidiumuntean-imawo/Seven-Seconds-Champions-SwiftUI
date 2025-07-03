//
//  AppState.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 03.07.2025.
//

import SwiftUI

class AppState: ObservableObject {
    // Aici vom stoca scorul de bătut când primim o provocare
    @Published var challengeScoreToBeat: Int? = nil
}
