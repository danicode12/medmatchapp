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
            // Background color that extends to all edges
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 12) {
                // Search filters summary bar
                HStack {
                    Button(action: {
                        showingFilterSheet = true
                    }) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.black)
                            Text("Filtros")
                                .foregroundColor(.black)
                                .fontWeight(.medium)
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
                        Text("\(viewModel.doctors.count) médicos encontrados")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
                
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
                        
                        Text("No se encontraron médicos")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("Intente ajustar sus criterios de búsqueda")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.doctors) { doctor in
                                NavigationLink(destination: DoctorDetailView(doctorId: doctor.id)) {
                                    DoctorListItemView(doctor: doctor)
                                        .padding(.horizontal)
                                        .padding(.vertical, 10)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            if viewModel.canLoadMore {
                                Button(action: {
                                    viewModel.loadMoreDoctors()
                                }) {
                                    HStack {
                                        Spacer()
                                        
                                        if viewModel.isLoadingMore {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle())
                                        } else {
                                            Text("Cargar Más")
                                                .fontWeight(.medium)
                                                .foregroundColor(.blue)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                }
            }
        }
        .navigationTitle("\(specialty?.name ?? "Médicos") cerca de \(location)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.searchDoctors(
                query: searchQuery,
                location: location,
                specialty: specialty,
                insurance: insurance
            )
            
            // Ensure we have a consistent background appearance
            UIScrollView.appearance().backgroundColor = UIColor.systemGroupedBackground
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
            
            VStack(alignment: .leading, spacing: 6) {
                Text(doctor.name)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(doctor.specialty.name)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 2) {
                    ForEach(0..<5) { i in
                        Image(systemName: i < Int(doctor.rating) ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(.yellow) // Changed from .customGreen to .yellow
                    }
                    
                    Text("(\(doctor.reviewCount))")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 2)
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
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
}
