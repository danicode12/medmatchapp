import SwiftUI
import Combine

class AppCoordinator: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var selectedTab: TabSelection = .search
    
    private let authService: AuthenticationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
        setupBindings()
    }
    
    private func setupBindings() {
        authService.authStatePublisher
            .sink { [weak self] authState in
                self?.isAuthenticated = authState.isAuthenticated
                self?.currentUser = authState.user
            }
            .store(in: &cancellables)
    }
}

enum TabSelection {
    case search, appointments, myDoctors, account
}
