import Foundation
import Combine
import CoreLocation

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
    
    // Add coordinate storage for enhanced location functionality
    @Published var selectedCoordinates: CLLocation?
    
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
        // You can keep this binding if you still want to use LocationManager events
        // to update locationText in some scenarios
        locationManager.$locationString
            .filter { !$0.isEmpty && $0 != "Near me" }
            .assign(to: &$locationText)
        
        // Remove the problematic binding that was trying to access $currentLocation
        // We'll handle coordinates explicitly in the updateLocation method
    }
    
    // Call this method when the user selects a location from the enhanced picker
    func updateLocation(address: String, coordinates: CLLocation?) {
        locationText = address
        selectedCoordinates = coordinates
    }
    
    func findCare() {
        // Updated implementation can now use coordinates for more precise searching
        print("Finding care with query: \(searchQuery), location: \(locationText)")
        
        if let coordinates = selectedCoordinates {
            print("Using coordinates: \(coordinates.coordinate.latitude), \(coordinates.coordinate.longitude)")
            // You can now use these coordinates for more precise searching
        }
    }
    
    func showInsurancePicker() {
        // This method is now replaced by direct sheet presentation in the view
        print("Show insurance picker")
    }
}
