import SwiftUI

@main
struct MedMatchApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    
    init() {
        // Setup light mode appearance for the entire app
        AppearanceManager.setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appCoordinator)
                .preferredColorScheme(.light) // Force light mode at SwiftUI level
        }
    }
}
