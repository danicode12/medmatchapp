import SwiftUI

struct DoctorReviewsView: View {
    let doctorId: String
    @StateObject private var viewModel = DoctorReviewsViewModel()
    @State private var showingWriteReview = false
    
    var body: some View {
        VStack {
            // Rating summary
            if let ratingSummary = viewModel.ratingSummary {
                RatingSummaryView(summary: ratingSummary)
                    .padding()
                
                Divider()
            }
            
            // Write review button
            Button(action: {
                showingWriteReview = true
            }) {
                HStack {
                    Image(systemName: "square.and.pencil")
                    Text("Write a review")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
            }
            
            // Reviews list
            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                Spacer()
            } else if viewModel.reviews.isEmpty {
                Spacer()
                Text("No reviews yet")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(viewModel.reviews) { review in
                        ReviewItemView(review: review)
                    }
                }
            }
        }
        .navigationTitle("Reviews")
        .onAppear {
            viewModel.loadReviews(doctorId: doctorId)
        }
        .sheet(isPresented: $showingWriteReview) {
            WriteReviewView(doctorId: doctorId, onSubmit: {
                viewModel.loadReviews(doctorId: doctorId)
            })
        }
    }
}

struct RatingSummaryView: View {
    let summary: RatingSummary
    
    var body: some View {
        VStack(spacing: 16) {
            // Overall rating
            HStack(alignment: .bottom, spacing: 4) {
                Text(String(format: "%.1f", summary.averageRating))
                    .font(.system(size: 48, weight: .bold))
                
                Text("/ 5")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(.bottom, 8)
            }
            
            // Stars
            HStack {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: summary.averageRating >= Double(star) - 0.5 ? "star.fill" : "star")
                        .foregroundColor(.customGreen)
                }
            }
            
            Text("\(summary.totalReviews) reviews")
                .foregroundColor(.gray)
            
            // Rating breakdown
            VStack(spacing: 8) {
                ForEach(5...1, id: \.self) { rating in
                    HStack {
                        Text("\(rating)")
                            .frame(width: 20)
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .frame(width: geometry.size.width, height: 8)
                                    .opacity(0.1)
                                    .foregroundColor(.gray)
                                
                                Rectangle()
                                    .frame(width: geometry.size.width * CGFloat(summary.ratingDistribution[rating - 1]) / CGFloat(summary.totalReviews), height: 8)
                                    .foregroundColor(.green)
                            }
                            .cornerRadius(4)
                        }
                        .frame(height: 8)
                        
                        Text("\(summary.ratingDistribution[rating - 1])")
                            .frame(width: 30)
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

struct ReviewItemView: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Stars
                HStack {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: review.rating >= star ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                // Date
                Text(formatDate(review.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Reviewer
            Text(review.reviewer)
                .font(.headline)
            
            // Comment
            Text(review.comment)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
