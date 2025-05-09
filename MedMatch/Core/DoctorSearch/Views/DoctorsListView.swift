import SwiftUI
import Combine

struct DoctorListView: View {
    let searchQuery: String
    let location: String
    let specialty: Specialty?
    let insurance: Insurance?
    
    @StateObject private var viewModel = DoctorListViewModel()
    @State private var showingFilterSheet = false
    
    var body: some View {
        ZStack {
            // Add explicit white background
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // Search filters summary bar
                HStack {
                    Button(action: {
                        showingFilterSheet = true
                    }) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.black)
                            Text("Filters")
                                .foregroundColor(.black)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("\(viewModel.doctors.count) doctors found")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                if viewModel.isLoading && viewModel.doctors.isEmpty {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                    Spacer()
                } else if viewModel.doctors.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No doctors found")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("Try adjusting your search criteria")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.doctors) { doctor in
                            NavigationLink(destination: DoctorDetailView(doctorId: doctor.id)) {
                                DoctorListItemView(doctor: doctor)
                            }
                            .listRowBackground(Color.white)
                        }
                        
                        if viewModel.canLoadMore {
                            HStack {
                                Spacer()
                                Button(action: {
                                    viewModel.loadMoreDoctors()
                                }) {
                                    if viewModel.isLoadingMore {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                    } else {
                                        Text("Load More")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                Spacer()
                            }
                            .listRowBackground(Color.white)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .background(Color.white)
                    .onAppear {
                        UITableView.appearance().backgroundColor = .white
                    }
                }
            }
        }
        .navigationTitle("\(specialty?.name ?? "Doctors") near \(location)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.searchDoctors(
                query: searchQuery,
                location: location,
                specialty: specialty,
                insurance: insurance
            )
        }
        .sheet(isPresented: $showingFilterSheet) {
            DoctorFilterView(
                sortOption: $viewModel.sortOption,
                availability: $viewModel.availability,
                gender: $viewModel.gender,
                languages: $viewModel.languages,
                rating: $viewModel.minimumRating,
                distance: $viewModel.maximumDistance,
                onApplyFilters: {
                    viewModel.applyFilters()
                    showingFilterSheet = false
                }
            )
            .preferredColorScheme(.light)
        }
        .preferredColorScheme(.light)
    }
}

struct DoctorListItemView: View {
    let doctor: Doctor
    
    var body: some View {
        HStack(spacing: 16) {
            if let imageURL = doctor.profileImageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 70, height: 70)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(Color.gray)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(doctor.name)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(doctor.specialty.name)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    ForEach(0..<5) { i in
                        Image(systemName: i < Int(doctor.rating) ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(.customGreen)
                    }
                    
                    Text("(\(doctor.reviewCount))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("\(doctor.address.city), \(doctor.address.state)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Next available appointment
                if let nextAvailable = doctor.availableTimes.first {
                    Text(formatDate(nextAvailable))
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color.white)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
