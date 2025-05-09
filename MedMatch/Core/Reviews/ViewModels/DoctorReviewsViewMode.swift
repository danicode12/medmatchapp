import Foundation
import Combine

class DoctorReviewsViewModel: ObservableObject {
    @Published var reviews: [Review] = []
    @Published var ratingSummary: RatingSummary?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let reviewService: ReviewServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(reviewService: ReviewServiceProtocol = ReviewService()) {
        self.reviewService = reviewService
    }
    
    func loadReviews(doctorId: String) {
        isLoading = true
        error = nil
        
        reviewService.getReviews(doctorId: doctorId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        self?.error = error
                    }
                },
                receiveValue: { [weak self] reviews in
                    self?.reviews = reviews
                    self?.calculateRatingSummary(reviews: reviews)
                }
            )
            .store(in: &cancellables)
    }
    
    private func calculateRatingSummary(reviews: [Review]) {
        guard !reviews.isEmpty else {
            ratingSummary = nil
            return
        }
        
        var distribution = [0, 0, 0, 0, 0] // 5-star to 1-star
        
        var totalRating = 0
        for review in reviews {
            totalRating += review.rating
            distribution[5 - review.rating] += 1
        }
        
        let average = Double(totalRating) / Double(reviews.count)
        
        ratingSummary = RatingSummary(
            averageRating: average,
            totalReviews: reviews.count,
            ratingDistribution: distribution
        )
    }
}
