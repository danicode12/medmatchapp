import Foundation

struct Appointment: Identifiable, Codable {
    let id: String
    let doctor: Doctor
    let date: Date
    let notes: String?
    
    var isPast: Bool {
        return date < Date()
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
