import SwiftUI
import UIKit

final class AppearanceManager {
    static func setupAppearance() {
        // Force light mode for the entire app
        if #available(iOS 15.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScenes = scenes.compactMap { $0 as? UIWindowScene }
            windowScenes.forEach { windowScene in
                windowScene.windows.forEach { window in
                    window.overrideUserInterfaceStyle = .light
                }
            }
        } else {
            // For iOS 14 and earlier
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
        }
        
        // Set global appearance settings
        UITableView.appearance().backgroundColor = .white
        UITableViewCell.appearance().backgroundColor = .white
        UINavigationBar.appearance().backgroundColor = .white
        UINavigationBar.appearance().barTintColor = .white
        
        // Add this for iOS 15+
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            
            // Set list appearance
            let listAppearance = UICollectionView.appearance()
            listAppearance.backgroundColor = .white
        }
    }
}
