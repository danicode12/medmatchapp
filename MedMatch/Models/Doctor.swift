// Models/Doctor.swift
import Foundation

struct Doctor: Identifiable, Codable {
    let id: String
    let name: String
    let specialty: Specialty
    let profileImageURL: URL?
    let rating: Double
    let reviewCount: Int
    let address: Address
    let availableTimes: [Date]
    
    struct Address: Codable {
        let street: String
        let city: String
        let state: String
        let zipCode: String
        
        var formatted: String {
            return "\(street), \(city), \(state) \(zipCode)"
        }
    }
}
