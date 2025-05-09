import Foundation
import Combine

class DoctorDetailViewModel: ObservableObject {
    @Published var doctor: Doctor?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var selectedDate: Date = Date()
    @Published var selectedTime: Date?
    @Published var availableTimeSlots: [Date] = []
    
    private let doctorService: DoctorServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(doctorService: DoctorServiceProtocol = DoctorService()) {
        self.doctorService = doctorService
        
        // Observe changes to selected date and update available time slots
        $selectedDate
            .sink { [weak self] date in
                self?.generateTimeSlots(for: date)
            }
            .store(in: &cancellables)
    }
    
    func loadDoctorDetails(id: String) {
        isLoading = true
        error = nil
        
        doctorService.getDoctorDetails(id: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] doctor in
                    self?.doctor = doctor
                    self?.generateTimeSlots(for: self?.selectedDate ?? Date())
                }
            )
            .store(in: &cancellables)
    }
    
    private func generateTimeSlots(for date: Date) {
        let calendar = Calendar.current
        var timeSlots: [Date] = []
        
        // Start with 9:00 AM
        let startHour = 9
        let startComponents = DateComponents(year: calendar.component(.year, from: date),
                                           month: calendar.component(.month, from: date),
                                           day: calendar.component(.day, from: date),
                                           hour: startHour,
                                           minute: 0)
        
        if let startTime = calendar.date(from: startComponents) {
            // Generate slots every 30 minutes until 5:00 PM
            for i in 0..<16 {
                if let timeSlot = calendar.date(byAdding: .minute, value: i * 30, to: startTime) {
                    // Randomly make some slots unavailable
                    if Int.random(in: 0...10) > 3 {
                        timeSlots.append(timeSlot)
                    }
                }
            }
        }
        
        availableTimeSlots = timeSlots
    }
}
