import Foundation

struct User: Identifiable, Codable {
    let id: String
    let name: String?
    let email: String
    let dateOfBirth: Date?
    let gender: Gender?
    
    enum Gender: String, Codable {
        case male = "Male"
        case female = "Female"
    }
}
