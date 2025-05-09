// Models/Specialty.swift
import Foundation
import SwiftUI

struct Specialty: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let iconName: String
    
    static let primaryCare = Specialty(id: "primary-care", name: "Primary Care Doctor", iconName: "heart.fill")
    static let obgyn = Specialty(id: "obgyn", name: "OB-GYN", iconName: "person.fill")
    static let dermatologist = Specialty(id: "dermatologist", name: "Dermatologist", iconName: "allergens")
    static let dentist = Specialty(id: "dentist", name: "Dentist", iconName: "staroflife.fill")
    static let ent = Specialty(id: "ent", name: "Ear, Nose & Throat Doctor", iconName: "ear.fill")
    static let eyeDoctor = Specialty(id: "eye-doctor", name: "Eye Doctor", iconName: "eye.fill")
    static let psychiatrist = Specialty(id: "psychiatrist", name: "Psychiatrist", iconName: "brain.head.profile")
    
    static let allSpecialties = [
        primaryCare, obgyn, dermatologist, dentist, ent, eyeDoctor, psychiatrist
    ]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Specialty, rhs: Specialty) -> Bool {
        lhs.id == rhs.id
    }
}
