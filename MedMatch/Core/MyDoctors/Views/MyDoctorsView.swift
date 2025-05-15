import SwiftUI

struct MyDoctorsView: View {
    @StateObject private var viewModel = MyDoctorsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo general
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if viewModel.isAuthenticated {
                        if viewModel.favoriteDoctors.isEmpty {
                            emptyStateView
                        } else {
                            doctorListView
                        }
                    } else {
                        notLoggedInView
                    }
                }
            }
            .navigationTitle("Mis médicos")
        }
        .preferredColorScheme(.light)
    }
    
    private var emptyStateView: some View {
        // Contenido para estado vacío, simplificado para este ejemplo
        VStack {
            Text("Seguimiento de tus médicos")
        }
        .padding()
    }
    
    private var doctorListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.favoriteDoctors) { doctor in
                    DoctorRow(doctor: doctor)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 16)
        }
    }
    
    private var notLoggedInView: some View {
        // Vista simplificada para usuarios no logueados
        VStack {
            Text("Por favor inicia sesión")
        }
    }
}

struct DoctorRow: View {
    let doctor: Doctor
    
    var body: some View {
        // Nueva estructura de tarjeta de doctor que corrige el problema del número vertical
        HStack {
            // Imagen del doctor
            if let imageURL = doctor.profileImageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                }
            }
            
            // Información del médico
            VStack(alignment: .leading, spacing: 6) {
                Text("\(doctor.name)")
                    .font(.title3)
                    .fontWeight(.medium)
                
                Text(doctor.specialty.name)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // CORRECCIÓN IMPORTANTE: Poner las estrellas y el conteo en un HStack para evitar el número vertical
                HStack(spacing: 2) {
                    // Estrellas
                    ForEach(0..<5) { i in
                        Image(systemName: i < Int(doctor.rating) ? "star.fill" : "star")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)
                    }
                    
                    // Número de reseñas CON ESPACIADO EXPLÍCITO y sin uso de paréntesis que puedan romper el layout
                    Text(" \(doctor.reviewCount)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.leading, 4)
                }
            }
            
            Spacer()
            
            // Botón de agendar en un tamaño fijo para evitar problemas de layout
            Button(action: {}) {
                Text("Agendar")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .frame(width: 90, height: 36)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// Estructura para previsualizar
#Preview {
    MyDoctorsView()
}
