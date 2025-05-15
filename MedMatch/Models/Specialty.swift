// Models/Specialty.swift
import Foundation
import SwiftUI

struct Specialty: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let iconName: String
    
    static let primaryCare = Specialty(id: "primary-care", name: "Generalista", iconName: "heart.fill")
    static let dermatologist = Specialty(id: "dermatologist", name: "Dermatología", iconName: "allergens")
    static let dentist = Specialty(id: "dentist", name: "Dentista", iconName: "staroflife.fill")
    static let ent = Specialty(id: "ent", name: "Otorrinolaringología", iconName: "ear.fill")
    static let eyeDoctor = Specialty(id: "eye-doctor", name: "Oftalmología", iconName: "eye.fill")
    static let psychiatrist = Specialty(id: "psychiatrist", name: "Psiquiatría", iconName: "brain.head.profile")
    
    static let allSpecialties = [
        primaryCare, dermatologist, dentist, ent, eyeDoctor, psychiatrist
    ]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Specialty, rhs: Specialty) -> Bool {
        lhs.id == rhs.id
    }
}
