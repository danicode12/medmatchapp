import Foundation
import Combine

class AccountViewModel: ObservableObject {
    @Published var isAuthenticated = false
    
    private let authService: AuthenticationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
        
        authService.authStatePublisher
            .map { $0.isAuthenticated }
            .assign(to: &$isAuthenticated)
    }
    
    func login() {
        // Navigate to login screen
        print("Navigate to login")
    }
    
    func signUp() {
        // Navigate to sign up screen
        print("Navigate to sign up")
    }
    
    func showProfile() {
        // Navigate to profile
        print("Navigate to profile")
    }
    
    func contactUs() {
        // Show contact us screen
        print("Show contact us")
    }
    
    func showTerms() {
        // Show terms of use
        print("Show terms")
    }
    
    func showPrivacyPolicy() {
        // Show privacy policy
        print("Show privacy policy")
    }
    
    func showPrivacyChoices() {
        // Show privacy choices
        print("Show privacy choices")
    }
    
    func sendFeedback() {
        // Send feedback
        print("Send feedback")
    }
    
    func shareApp() {
        // Share app
        print("Share app")
    }
}
