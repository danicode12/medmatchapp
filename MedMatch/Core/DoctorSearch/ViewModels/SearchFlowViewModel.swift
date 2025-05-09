import Foundation
import Combine

class SearchFlowViewModel: ObservableObject {
    @Published var searchQuery = ""
    @Published var location = "Near me"
    @Published var selectedSpecialty: Specialty?
    @Published var selectedInsurance: Insurance?
    @Published var selectedCareType: CareType?
    @Published var showingCareTypeSelection = false
    @Published var showingSearchResults = false
    @Published var isSearching = false
    
    enum CareType: String {
        case annualPhysical = "Annual physical / checkup"
        case specificIssue = "Issue, condition or problem"
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let doctorService: DoctorServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    
    init(doctorService: DoctorServiceProtocol = DoctorService(),
         analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared) {
        self.doctorService = doctorService
        self.analyticsService = analyticsService
    }
    
    func startFindDoctorFlow() {
        // Reset flow state
        searchQuery = ""
        selectedCareType = nil
        showingCareTypeSelection = true
        showingSearchResults = false
        
        // Log analytics event
        analyticsService.logEvent(.buttonClick, parameters: ["button": "find_doctor"])
    }
    
    func selectCareType(_ careType: CareType) {
        selectedCareType = careType
        
        // Update search query based on care type
        switch careType {
        case .annualPhysical:
            if let specialty = selectedSpecialty {
                searchQuery = "\(specialty.name) • Annual Physical"
            } else {
                searchQuery = "Primary Care Doctor • Annual Physical"
            }
        case .specificIssue:
            if let specialty = selectedSpecialty {
                searchQuery = "\(specialty.name) • Consultation"
            } else {
                searchQuery = "Doctor • Consultation"
            }
        }
        
        // Log analytics event
        analyticsService.logEvent(.search, parameters: [
            "care_type": careType.rawValue,
            "query": searchQuery,
            "location": location
        ])
    }
    
    func continueToDoctorSearch() {
        showingCareTypeSelection = false
        showingSearchResults = true
        isSearching = true
        
        // In a real app, we would perform the search here
        // For demo purposes, simulate a network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isSearching = false
        }
    }
    
    func skipToDoctorSearch() {
        showingCareTypeSelection = false
        showingSearchResults = true
        isSearching = true
        
        // In a real app, we would perform the search here
        // For demo purposes, simulate a network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isSearching = false
        }
    }
}
