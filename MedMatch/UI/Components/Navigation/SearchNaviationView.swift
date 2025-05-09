import SwiftUI

struct SearchNavigationView: View {
    var searchQuery: String
    var location: String
    var onBackToSearch: () -> Void
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            // Search bar
            HStack {
                Button(action: {
                    // Go back
                    onBackToSearch()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .padding()
                }
                
                Spacer()
                
                Button(action: {
                    // Show map
                }) {
                    Text("Map")
                        .foregroundColor(.black)
                        .padding()
                }
            }
            
            // Search field - clicking this takes you back to search
            Button(action: {
                onBackToSearch()
            }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading) {
                        Text(searchQuery)
                            .foregroundColor(.black)
                            .font(.headline)
                        
                        Text(location)
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                .padding(.horizontal)
            }
            
            // Loading skeleton or search results
            ScrollView {
                if isLoading {
                    // Loading skeleton
                    ForEach(0..<2, id: \.self) { _ in
                        DoctorSkeletonView()
                            .padding(.vertical, 8)
                    }
                } else {
                    // We'd show actual search results here
                    // For now, just examples
                    ForEach(0..<2, id: \.self) { index in
                        DoctorCard(
                            doctor: Doctor(
                                id: "doctor\(index+1)",
                                name: index == 0 ? "Dr. Sarah Johnson" : "Dr. Michael Chen",
                                specialty: index == 0 ? Specialty.primaryCare : Specialty.dentist,
                                profileImageURL: nil,
                                rating: index == 0 ? 4.8 : 4.9,
                                reviewCount: index == 0 ? 153 : 208,
                                address: Doctor.Address(
                                    street: index == 0 ? "123 Medical Plaza" : "456 Dental Suite",
                                    city: "San Francisco",
                                    state: "CA",
                                    zipCode: index == 0 ? "94102" : "94103"
                                ),
                                availableTimes: [
                                    Calendar.current.date(byAdding: .day, value: index+1, to: Date())!,
                                    Calendar.current.date(byAdding: .day, value: index+2, to: Date())!
                                ]
                            ),
                            onTap: {}
                        )
                        .padding(.vertical, 8)
                    }
                }
            }
            .padding(.horizontal)
            .onAppear {
                // Simulate loading
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isLoading = false
                }
            }
            
            Spacer()
        }
        .background(Color.gray.opacity(0.05))
        .navigationBarHidden(true)
    }
}
