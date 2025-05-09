import SwiftUI
import Combine

struct WriteReviewView: View {
    let doctorId: String
    let onSubmit: () -> Void
    
    @StateObject private var viewModel = WriteReviewViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rating")) {
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: viewModel.rating >= star ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                                .font(.title2)
                                .onTapGesture {
                                    viewModel.rating = star
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Your Review")) {
                    TextEditor(text: $viewModel.comment)
                        .frame(minHeight: 150)
                }
                
                Section(header: Text("Your Name")) {
                    TextField("Name", text: $viewModel.reviewer)
                }
                
                if viewModel.showingError {
                    Section {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: {
                        viewModel.submitReview(doctorId: doctorId) {
                            presentationMode.wrappedValue.dismiss()
                            onSubmit()
                        }
                    }) {
                        HStack {
                            Spacer()
                            
                            if viewModel.isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Submit Review")
                                    .fontWeight(.bold)
                            }
                            
                            Spacer()
                        }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isSubmitting)
                }
            }
            .navigationTitle("Write a Review")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

class WriteReviewViewModel: ObservableObject {
    @Published var rating = 0
    @Published var comment = ""
    @Published var reviewer = ""
    @Published var isSubmitting = false
    @Published var showingError = false
    @Published var errorMessage = ""
    
    private let reviewService: ReviewServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    var isFormValid: Bool {
        rating > 0 && !comment.isEmpty && !reviewer.isEmpty
    }
    
    init(reviewService: ReviewServiceProtocol = ReviewService()) {
        self.reviewService = reviewService
    }
    
    func submitReview(doctorId: String, onSuccess: @escaping () -> Void) {
        guard isFormValid else {
            showError(message: "Please fill in all fields and provide a rating")
            return
        }
        
        isSubmitting = true
        showingError = false
        
        reviewService.submitReview(
            doctorId: doctorId,
            rating: rating,
            comment: comment,
            reviewer: reviewer
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isSubmitting = false
                
                if case .failure(let error) = completion {
                    self?.showError(message: error.localizedDescription)
                }
            },
            receiveValue: { [weak self] _ in
                self?.isSubmitting = false
                onSuccess()
            }
        )
        .store(in: &cancellables)
    }
    
    private func showError(message: String) {
        showingError = true
        errorMessage = message
    }
}
