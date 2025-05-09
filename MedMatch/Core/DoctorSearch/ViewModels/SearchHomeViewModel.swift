import Foundation
import Combine

class SearchHomeViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var locationText = "Near me"
    @Published var locationSearchText = ""
    @Published var selectedSpecialty: Specialty?
    @Published var selectedInsurance: Insurance?
    @Published var insuranceSearchText = ""
    @Published var topSpecialties: [Specialty] = [
        .primaryCare,
        .dentist
    ]
    
    private let doctorService: DoctorServiceProtocol
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()
    
    init(doctorService: DoctorServiceProtocol = DoctorService(),
         locationManager: LocationManager = LocationManager()) {
        self.doctorService = doctorService
        self.locationManager = locationManager
        
        setupBindings()
    }
    
    private func setupBindings() {
        locationManager.$locationString
            .filter { !$0.isEmpty && $0 != "Near me" }
            .assign(to: &$locationText)
    }
    
    func findCare() {
        // Implementation of search functionality would go here
        print("Finding care with query: \(searchQuery), location: \(locationText), insurance: \(selectedInsurance?.name ?? "None")")
    }
    
    func showInsurancePicker() {
        // This method is now replaced by direct sheet presentation in the view
        print("Show insurance picker")
    }
}
