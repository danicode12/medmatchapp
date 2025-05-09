import SwiftUI
import Combine

struct DoctorDetailView: View {
    let doctorId: String
    @StateObject private var viewModel = DoctorDetailViewModel()
    @State private var showingBookingSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.isLoading {
                    LoadingView()
                } else if let doctor = viewModel.doctor {
                    // Doctor header
                    DoctorHeaderView(doctor: doctor)
                    
                    Divider()
                    
                    // About section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About")
                            .font(.headline)
                        
                        Text("Dr. \(doctor.name.split(separator: " ").last ?? "") is a board-certified \(doctor.specialty.name.lowercased()) with over 10 years of experience. They focus on providing comprehensive care with a patient-centered approach.")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Location section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location")
                            .font(.headline)
                        
                        Text(doctor.address.formatted)
                            .font(.body)
                            .foregroundColor(.gray)
                        
                        // Map placeholder
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 150)
                            .cornerRadius(8)
                            .overlay(
                                Image(systemName: "map")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Available appointments
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Available appointments")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(0..<5) { i in
                                    let date = Calendar.current.date(byAdding: .day, value: i, to: Date())!
                                    AppointmentDateButton(date: date, isSelected: viewModel.selectedDate == date) {
                                        viewModel.selectedDate = date
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Time slots
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(viewModel.availableTimeSlots, id: \.self) { time in
                                Button(action: {
                                    viewModel.selectedTime = time
                                    showingBookingSheet = true
                                }) {
                                    Text(timeFormatter.string(from: time))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(8)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                } else {
                    Text("Could not load doctor details")
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .navigationTitle("Doctor Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadDoctorDetails(id: doctorId)
        }
        .sheet(isPresented: $showingBookingSheet) {
            if let doctor = viewModel.doctor, let selectedTime = viewModel.selectedTime {
                BookAppointmentView(doctor: doctor, appointmentTime: selectedTime)
            }
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}

struct DoctorHeaderView: View {
    let doctor: Doctor
    
    var body: some View {
        VStack(spacing: 16) {
            // Doctor image
            if let imageURL = doctor.profileImageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .frame(width: 100, height: 100)
                    .background(Color.gray)
                    .clipShape(Circle())
            }
            
            // Doctor info
            VStack(spacing: 8) {
                Text(doctor.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(doctor.specialty.name)
                    .font(.headline)
                    .foregroundColor(.gray)
                
                HStack {
                    ForEach(0..<5) { i in
                        Image(systemName: i < Int(doctor.rating) ? "star.fill" : "star")
                            .foregroundColor(.customGreen)
                    }
                    
                    Text("(\(doctor.reviewCount))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

struct AppointmentDateButton: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(dayFormatter.string(from: date))
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .gray)
                
                Text(dateFormatter.string(from: date))
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .black)
            }
            .frame(width: 60, height: 70)
            .background(isSelected ? Color.blue : Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
                .padding()
            
            Text("Loading...")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 100)
    }
}
