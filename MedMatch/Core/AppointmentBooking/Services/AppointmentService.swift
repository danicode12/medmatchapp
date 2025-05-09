import Foundation
import Combine

protocol AppointmentServiceProtocol {
    func getAppointments() -> AnyPublisher<[Appointment], Never>
    func bookAppointment(doctorId: String, date: Date, notes: String?) -> AnyPublisher<Appointment, Error>
    func cancelAppointment(id: String) -> AnyPublisher<Void, Error>
    func rescheduleAppointment(id: String, newDate: Date) -> AnyPublisher<Appointment, Error>
}

class AppointmentService: AppointmentServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func getAppointments() -> AnyPublisher<[Appointment], Never> {
        // In a real app, you would make an API call here
        // For demo purposes, we'll return mock data
        
        let doctorService = DoctorService()
        
        return doctorService.mockDoctorData()
            .map { doctors in
                guard let doctor = doctors.first else { return [] }
                
                let pastDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
                let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
                
                return [
                    Appointment(
                        id: "appointment1",
                        doctor: doctor,
                        date: pastDate,
                        notes: "Regular checkup"
                    ),
                    Appointment(
                        id: "appointment2",
                        doctor: doctors[1],
                        date: futureDate,
                        notes: "Teeth cleaning"
                    )
                ]
            }
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    func bookAppointment(doctorId: String, date: Date, notes: String?) -> AnyPublisher<Appointment, Error> {
        // In a real app, you would make an API call here
        // For demo purposes, we'll return mock data
        
        let doctorService = DoctorService()
        
        return doctorService.getDoctorDetails(id: doctorId)
            .map { doctor in
                Appointment(
                    id: UUID().uuidString,
                    doctor: doctor,
                    date: date,
                    notes: notes
                )
            }
            .eraseToAnyPublisher()
    }
    
    func cancelAppointment(id: String) -> AnyPublisher<Void, Error> {
        // Implementation would make an API call to cancel the appointment
        
        return Just(())
            .setFailureType(to: Error.self)
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func rescheduleAppointment(id: String, newDate: Date) -> AnyPublisher<Appointment, Error> {
        // Implementation would make an API call to reschedule the appointment
        
        let doctorService = DoctorService()
        
        return doctorService.mockDoctorData()
            .compactMap { doctors in
                guard let doctor = doctors.first else { return nil }
                
                return Appointment(
                    id: id,
                    doctor: doctor,
                    date: newDate,
                    notes: "Rescheduled appointment"
                )
            }
            .eraseToAnyPublisher()
    }
}
