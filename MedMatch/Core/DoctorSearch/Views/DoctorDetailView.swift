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
                        Text("Sobre")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Dr. \(doctor.name.split(separator: " ").last ?? "") es un \(doctor.specialty.name.lowercased()) certificado con más de 10 años de experiencia. Se enfoca en proporcionar atención integral con un enfoque centrado en el paciente.")
                            .font(.body)
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Location section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ubicación")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(doctor.address.formatted)
                            .font(.body)
                            .foregroundColor(.gray)
                        
                        // Map placeholder with improved styling
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 150)
                                .cornerRadius(12)
                            
                            VStack {
                                Image(systemName: "map")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                                
                                Text("Ver mapa")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.top, 4)
                            }
                        }
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Available appointments with improved selection UI
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Citas disponibles")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        // Date selector with improved visual feedback
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<5) { i in
                                    let date = Calendar.current.date(byAdding: .day, value: i, to: Date())!
                                    AppointmentDateButton(
                                        date: date,
                                        isSelected: viewModel.selectedDate == date,
                                        action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                viewModel.selectedDate = date
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                        
                        // Time slots with improved styling
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(viewModel.availableTimeSlots, id: \.self) { time in
                                Button(action: {
                                    viewModel.selectedTime = time
                                    showingBookingSheet = true
                                }) {
                                    Text(timeFormatter.string(from: time))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(10)
                                        .foregroundColor(.blue)
                                        .font(.system(size: 16, weight: .medium))
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal)
                } else {
                    Text("No se pudieron cargar los detalles del médico")
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .navigationTitle("Detalles del médico")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadDoctorDetails(id: doctorId)
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
        formatter.locale = Locale(identifier: "es_ES") // Spanish locale
        return formatter
    }
}

struct DoctorHeaderView: View {
    let doctor: Doctor
    
    var body: some View {
        VStack(spacing: 20) {
            // Doctor image with improved styling
            if let imageURL = doctor.profileImageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                )
            } else {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                }
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                )
            }
            
            // Doctor info with improved styling
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
                            .foregroundColor(.yellow) // Cambiado de .customGreen a .yellow
                            .font(.system(size: 16))
                    }
                    
                    Text("(\(doctor.reviewCount))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
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
    
    // Formatters with Spanish locale
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Día de la semana (Lun, Mar, etc.)
                Text(dayFormatter.string(from: date).capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .gray)
                
                // Número del día
                Text(dateFormatter.string(from: date))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(isSelected ? .white : .black)
                
                // Mes (May, Jun, etc.)
                Text(monthFormatter.string(from: date))
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white.opacity(0.9) : .gray)
            }
            .frame(width: 70, height: 85)
            .background(
                // Background con gradiente para el botón seleccionado
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color(red: 0.0, green: 0.5, blue: 1.0)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.blue.opacity(0.4), radius: 6, x: 0, y: 3)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                }
            )
            .overlay(
                // Borde indicador adicional para el botón seleccionado
                ZStack {
                    if isSelected {
                        // Indicador de selección en la parte superior
                        Rectangle()
                            .fill(Color.yellow)
                            .frame(width: 30, height: 4)
                            .cornerRadius(2)
                            .offset(y: -39)
                    }
                    
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
                }
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
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
            
            Text("Cargando...")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 100)
    }
}
