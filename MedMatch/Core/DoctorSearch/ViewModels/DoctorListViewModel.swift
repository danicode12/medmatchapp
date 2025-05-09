import Foundation
import Combine

enum SortOption: String, CaseIterable {
    case recommended = "Recommended"
    case availability = "Soonest Available"
    case rating = "Highest Rated"
    case distance = "Closest"
}

enum DoctorGender: String, CaseIterable {
    case any = "Any"
    case male = "Male"
    case female = "Female"
}

enum Availability: String, CaseIterable {
    case anytime = "Any time"
    case today = "Today"
    case tomorrow = "Tomorrow"
    case thisWeek = "This week"
    case nextWeek = "Next week"
}

class DoctorListViewModel: ObservableObject {
    @Published var doctors: [Doctor] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var error: Error?
    @Published var canLoadMore = false
    
    // Filter options
    @Published var sortOption: SortOption = .recommended
    @Published var availability: Availability = .anytime
    @Published var gender: DoctorGender = .any
    @Published var languages: [String] = []
    @Published var minimumRating: Double = 0.0
    @Published var maximumDistance: Double = 50.0 // in miles
    
    private var currentPage = 1
    private var totalPages = 1
    private var currentQuery = ""
    private var currentLocation = ""
    private var currentSpecialty: Specialty?
    private var currentInsuranceId: String?
    private let doctorService: DoctorServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(doctorService: DoctorServiceProtocol = DoctorService()) {
        self.doctorService = doctorService
    }
    
    func searchDoctors(query: String, location: String, specialty: Specialty?, insurance: Insurance?) {
        currentQuery = query
        currentLocation = location
        currentSpecialty = specialty
        currentInsuranceId = insurance?.id.uuidString
        
        currentPage = 1
        doctors = []
        isLoading = true
        error = nil
        
        performSearch()
    }
    
    func loadMoreDoctors() {
        guard !isLoadingMore && currentPage < totalPages else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        performSearch()
    }
    
    func applyFilters() {
        currentPage = 1
        doctors = []
        isLoading = true
        error = nil
        
        performSearch()
    }
    
    private func performSearch() {
        doctorService.searchDoctors(
            query: currentQuery,
            location: currentLocation,
            specialty: currentSpecialty,
            insurance: currentInsuranceId
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                if let self = self {
                    self.isLoading = false
                    self.isLoadingMore = false
                    
                    if case .failure(let error) = completion {
                        self.error = error
                    }
                }
            },
            receiveValue: { [weak self] doctors in
                if let self = self {
                    // Apply filters
                    var filteredDoctors = doctors
                    
                    // Filter by gender
                    if self.gender != .any {
                        // In a real app, you would have a gender property on Doctor
                        // This is for demonstration purposes
                        filteredDoctors = filteredDoctors.filter { doctor in
                            if self.gender == .male {
                                return !doctor.name.contains("Sarah") && !doctor.name.contains("Emily")
                            } else {
                                return doctor.name.contains("Sarah") || doctor.name.contains("Emily")
                            }
                        }
                    }
                    
                    // Filter by minimum rating
                    if self.minimumRating > 0 {
                        filteredDoctors = filteredDoctors.filter { $0.rating >= self.minimumRating }
                    }
                    
                    // Sort doctors
                    switch self.sortOption {
                    case .rating:
                        filteredDoctors.sort { $0.rating > $1.rating }
                    case .availability:
                        filteredDoctors.sort {
                            guard let date1 = $0.availableTimes.first, let date2 = $1.availableTimes.first else {
                                return false
                            }
                            return date1 < date2
                        }
                    case .distance:
                        // Would require actual distance calculations
                        break
                    case .recommended:
                        // Default ordering
                        break
                    }
                    
                    // Append to existing list if loading more
                    if self.isLoadingMore {
                        self.doctors.append(contentsOf: filteredDoctors)
                    } else {
                        self.doctors = filteredDoctors
                    }
                    
                    // For demo purposes, always allow loading more until we have 20+ doctors
                    self.canLoadMore = self.doctors.count < 20
                    self.totalPages = 3
                }
            }
        )
        .store(in: &cancellables)
    }
}
