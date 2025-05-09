import Foundation
import Combine
import UIKit

class BookAppointmentViewModel: ObservableObject {
    @Published var selectedInsurance: Insurance?
    @Published var selectedVisitType: VisitType = .newPatient
    @Published var notes = ""
    @Published var isLoading = false
    @Published var showingAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var appointmentBooked = false
    @Published var showInsurancePicker = false
    
    let availableInsurances: [Insurance] = [
        Insurance(name: "Blue Cross Blue Shield", planType: "PPO"),
        Insurance(name: "Aetna", planType: "HMO"),
        Insurance(name: "UnitedHealthcare", planType: "EPO"),
        Insurance(name: "Cigna", planType: "PPO"),
        Insurance(name: "Medicare"),
        Insurance(name: "Medicaid"),
        Insurance(name: "Kaiser Permanente", planType: "HMO")
    ]
    
    private let appointmentService: AppointmentServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var isFormValid: Bool {
        return selectedInsurance != nil
    }
    
    init(appointmentService: AppointmentServiceProtocol = AppointmentService()) {
        self.appointmentService = appointmentService
    }
    
    func bookAppointment(doctorId: String, date: Date) {
        guard isFormValid else {
            showAlert(title: "Missing Information", message: "Please select your insurance to continue")
            return
        }
        
        isLoading = true
        
        appointmentService.bookAppointment(doctorId: doctorId, date: date, notes: notes.isEmpty ? nil : notes)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.appointmentBooked = true
                    self?.showAlert(title: "Success", message: "Your appointment has been booked successfully!")
                }
            )
            .store(in: &cancellables)
    }
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
}
