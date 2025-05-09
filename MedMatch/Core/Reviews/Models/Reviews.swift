import Foundation

struct Review: Identifiable, Codable {
    let id: String
    let doctorId: String
    let reviewer: String
    let rating: Int
    let comment: String
    let date: Date
}

struct RatingSummary: Codable {
    let averageRating: Double
    let totalReviews: Int
    let ratingDistribution: [Int] // Count of 5-star, 4-star, 3-star, 2-star, 1-star ratings
}
