// Core/DoctorSearch/Services/DoctorService.swift
import Foundation
import Combine

protocol DoctorServiceProtocol {
    func searchDoctors(query: String, location: String, specialty: Specialty?, insurance: String?) -> AnyPublisher<[Doctor], Error>
    func getFavoriteDoctors() -> AnyPublisher<[Doctor], Never>
    func getDoctorDetails(id: String) -> AnyPublisher<Doctor, Error>
    func mockDoctorData() -> AnyPublisher<[Doctor], Error>
}

class DoctorService: DoctorServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func searchDoctors(query: String, location: String, specialty: Specialty?, insurance: String?) -> AnyPublisher<[Doctor], Error> {
        // In a real app, you would make an API call here
        // For demo purposes, we'll return mock data
        
        return mockDoctorData()
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func getFavoriteDoctors() -> AnyPublisher<[Doctor], Never> {
        // In a real app, you would make an API call here
        // For demo purposes, we'll return mock data
        
        return mockDoctorData()
            .replaceError(with: [])
            .delay(for: .seconds(0.5), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func getDoctorDetails(id: String) -> AnyPublisher<Doctor, Error> {
        // In a real app, you would make an API call here
        // For demo purposes, we'll return mock data
        
        return mockDoctorData()
            .compactMap { doctors in
                doctors.first(where: { $0.id == id }) ?? doctors.first
            }
            .eraseToAnyPublisher()
    }
    
    func mockDoctorData() -> AnyPublisher<[Doctor], Error> {
        let mockDoctors = [
            Doctor(
                id: "doctor1",
                name: "Dr. Miguel De Jesús",
                specialty: Specialty.primaryCare,
                profileImageURL: nil,
                rating: 4.8,
                reviewCount: 153,
                address: Doctor.Address(
                    street: "123 Medical Plaza",
                    city: "San Francisco",
                    state: "CA",
                    zipCode: "94102"
                ),
                availableTimes: [
                    Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                    Calendar.current.date(byAdding: .day, value: 2, to: Date())!
                ]
            ),
            Doctor(
                id: "doctor2",
                name: "Dr. José López",
                specialty: Specialty.dentist,
                profileImageURL: nil,
                rating: 4.9,
                reviewCount: 208,
                address: Doctor.Address(
                    street: "456 Dental Suite",
                    city: "San Francisco",
                    state: "CA",
                    zipCode: "94103"
                ),
                availableTimes: [
                    Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
                    Calendar.current.date(byAdding: .day, value: 4, to: Date())!
                ]
            )
        ]
        
        return Just(mockDoctors)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
