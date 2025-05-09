import Foundation
import Combine

class AppointmentsViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var appointments: [Appointment] = []
    @Published var upcomingAppointments: [Appointment] = []
    @Published var pastAppointments: [Appointment] = []
    
    private let authService: AuthenticationServiceProtocol
    private let appointmentService: AppointmentServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService(),
         appointmentService: AppointmentServiceProtocol = AppointmentService()) {
        self.authService = authService
        self.appointmentService = appointmentService
        
        setupBindings()
    }
    
    private func setupBindings() {
        authService.authStatePublisher
            .map { $0.isAuthenticated }
            .assign(to: &$isAuthenticated)
        
        authService.authStatePublisher
            .filter { $0.isAuthenticated }
            .flatMap { [weak self] _ -> AnyPublisher<[Appointment], Never> in
                guard let self = self else {
                    return Just([]).eraseToAnyPublisher()
                }
                return self.appointmentService.getAppointments()
            }
            .assign(to: &$appointments)
        
        $appointments
            .map { appointments in
                appointments.filter { !$0.isPast }
            }
            .assign(to: &$upcomingAppointments)
        
        $appointments
            .map { appointments in
                appointments.filter { $0.isPast }
            }
            .assign(to: &$pastAppointments)
    }
    
    func findDoctor() {
        // Navigate to doctor search
        print("Navigate to doctor search")
    }
    
    func login() {
        // Navigate to login screen
        print("Navigate to login")
    }
    
    func signUp() {
        // Navigate to sign up screen
        print("Navigate to sign up")
    }
}
