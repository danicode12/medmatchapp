import Foundation
import Combine

class MyDoctorsViewModel: ObservableObject {
    @Published var isAuthenticated = true
    @Published var favoriteDoctors: [Doctor] = []
    
    private let authService: AuthenticationServiceProtocol
    private let doctorService: DoctorServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService(),
         doctorService: DoctorServiceProtocol = DoctorService()) {
        self.authService = authService
        self.doctorService = doctorService
        
        setupBindings()
    }
    
    private func setupBindings() {
        authService.authStatePublisher
            .map { $0.isAuthenticated }
            .assign(to: &$isAuthenticated)
        
        authService.authStatePublisher
            .filter { $0.isAuthenticated }
            .flatMap { [weak self] _ -> AnyPublisher<[Doctor], Never> in
                guard let self = self else {
                    return Just([]).eraseToAnyPublisher()
                }
                return self.doctorService.getFavoriteDoctors()
            }
            .assign(to: &$favoriteDoctors)
    }
    
    func findDoctor() {
        // Navigate to doctor search
        print("Navigate to doctor search")
    }
    
    func showLogin() {
        // Show login screen
        print("Show login screen")
    }
}
