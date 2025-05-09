import Foundation
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var location: CLLocation?
    @Published var locationString: String = "Near me"
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isRequestingLocation: Bool = false
    @Published var error: Error?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocation() {
        isRequestingLocation = true
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            // Handle case when permission is denied
            isRequestingLocation = false
            print("Location access denied")
        @unknown default:
            isRequestingLocation = false
            break
        }
    }
    
    func geocodeLocation() {
        guard let location = location else { return }
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                self?.error = error
                self?.isRequestingLocation = false
                return
            }
            
            guard let placemark = placemarks?.first else {
                self?.isRequestingLocation = false
                return
            }
            
            if let city = placemark.locality, let state = placemark.administrativeArea {
                self?.locationString = "\(city), \(state)"
            } else if let name = placemark.name {
                self?.locationString = name
            }
            
            self?.isRequestingLocation = false
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        geocodeLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
        self.isRequestingLocation = false
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        } else if status == .denied || status == .restricted {
            isRequestingLocation = false
        }
    }
}
