//
//  UIViewControllerWrapper.swift
//  Seven Seconds Champions
//
//  Created by Ovidiu Muntean on 09.01.2025.
//

import UIKit
import SwiftUI

// MARK: - UIViewControllerWrapper to present UIKit view controllers
struct UIViewControllerWrapper: UIViewControllerRepresentable {
    var viewController: UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
