//
//  UIApplication+Extensions.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 16.01.2025.
//

import UIKit
import SwiftUI

extension UIApplication {
    static func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        return window.rootViewController
    }
}

