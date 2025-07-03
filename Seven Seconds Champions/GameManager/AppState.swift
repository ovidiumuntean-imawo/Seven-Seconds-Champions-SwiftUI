// AppState.swift
import SwiftUI

class AppState: ObservableObject {
    // Aici vom stoca scorul de bătut când primim o provocare
    @Published var challengeScoreToBeat: Int? = nil
}