import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var showingError = false
    @Published var errorMessage = ""
    @Published var showingAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var isLoading = false
    
    private let authService: AuthenticationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
    }
    
    var isFormValid: Bool {
        return isValidEmail(email) && password.count >= 6
    }
    
    func login() {
        guard isFormValid else {
            showError(message: "Please enter a valid email and password")
            return
        }
        
        isLoading = true
        showingError = false
        
        authService.signIn(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.showError(message: error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.isLoading = false
                    // Successfully logged in
                }
            )
            .store(in: &cancellables)
    }
    
    func forgotPassword() {
        if !isValidEmail(email) {
            showAlert(title: "Invalid Email", message: "Please enter your email address first")
            return
        }
        
        showAlert(title: "Reset Password", message: "A password reset link has been sent to your email")
    }
    
    func showSignUp() {
        // Navigation to Sign Up would be handled by the parent view
    }
    
    private func showError(message: String) {
        showingError = true
        errorMessage = message
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
