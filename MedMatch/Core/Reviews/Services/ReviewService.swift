import Foundation
import Combine

protocol ReviewServiceProtocol {
    func getReviews(doctorId: String) -> AnyPublisher<[Review], Error>
    func submitReview(doctorId: String, rating: Int, comment: String, reviewer: String) -> AnyPublisher<Review, Error>
}

class ReviewService: ReviewServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func getReviews(doctorId: String) -> AnyPublisher<[Review], Error> {
        // In a real app, you would make an API call here
        // For demo purposes, we'll return mock data
        
        return mockReviews(doctorId: doctorId)
            .delay(for: .seconds(1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func submitReview(doctorId: String, rating: Int, comment: String, reviewer: String) -> AnyPublisher<Review, Error> {
        // In a real app, you would make an API call here
        // For demo purposes, we'll simulate a successful submission
        
        return Future<Review, Error> { promise in
            // Simulate network delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let review = Review(
                    id: UUID().uuidString,
                    doctorId: doctorId,
                    reviewer: reviewer,
                    rating: rating,
                    comment: comment,
                    date: Date()
                )
                
                promise(.success(review))
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func mockReviews(doctorId: String) -> AnyPublisher<[Review], Error> {
        let reviews = [
            Review(
                id: "review1",
                doctorId: doctorId,
                reviewer: "John Smith",
                rating: 5,
                comment: "Dr. Johnson is excellent! She took the time to listen to all my concerns and explained everything clearly. The office staff was also very friendly and efficient.",
                date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!
            ),
            Review(
                id: "review2",
                doctorId: doctorId,
                reviewer: "Emma Wilson",
                rating: 4,
                comment: "Very professional and knowledgeable. The only reason I'm not giving 5 stars is because I had to wait a bit longer than expected, but the care itself was top-notch.",
                date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!
            ),
            Review(
                id: "review3",
                doctorId: doctorId,
                reviewer: "Michael Brown",
                rating: 5,
                comment: "I've been seeing this doctor for years and have always received excellent care. Highly recommended!",
                date: Calendar.current.date(byAdding: .day, value: -30, to: Date())!
            ),
            Review(
                id: "review4",
                doctorId: doctorId,
                reviewer: "Sophia Garcia",
                rating: 3,
                comment: "The doctor was good but the office was disorganized. Had to fill out the same paperwork twice and there was confusion about my appointment time.",
                date: Calendar.current.date(byAdding: .day, value: -45, to: Date())!
            )
        ]
        
        return Just(reviews)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
