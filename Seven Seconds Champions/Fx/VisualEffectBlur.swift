//
//  VisualEffectBlur.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 09.01.2025.
//


import SwiftUI
import UIKit

/// Wrapper SwiftUI pentru UIVisualEffectView (stil UIKit blur).
struct VisualEffectBlur: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        // nu avem update
    }
}
