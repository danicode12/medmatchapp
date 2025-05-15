import SwiftUI

struct AppointmentsView: View {
    @StateObject private var viewModel = AppointmentsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo general
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if viewModel.isAuthenticated {
                        if viewModel.appointments.isEmpty {
                            emptyStateView
                        } else {
                            appointmentListView
                        }
                    } else {
                        notLoggedInView
                    }
                }
            }
            .navigationTitle("Mis Citas")
        }
        .preferredColorScheme(.light)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 28) {
            // Ícono estilizado en un círculo
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "calendar")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
            .padding(.bottom, 10)
            
            Text("No tienes citas")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("Cuando tengas citas aparecerán aquí")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: viewModel.findDoctor) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Encuentra un médico")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .padding(.horizontal, 40)
            .padding(.top, 10)
        }
        .padding(.horizontal)
        .padding(.vertical, 40)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
    
    private var appointmentListView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Próximas citas
                VStack(alignment: .leading, spacing: 16) {
                    Text("Próximas citas")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                    
                    if viewModel.upcomingAppointments.isEmpty {
                        HStack {
                            Spacer()
                            Text("No tienes citas próximas")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.vertical, 20)
                            Spacer()
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                    } else {
                        ForEach(viewModel.upcomingAppointments) { appointment in
                            AppointmentCard(appointment: appointment, isPast: false)
                                .padding(.horizontal, 16)
                        }
                    }
                }
                
                // Citas pasadas
                if !viewModel.pastAppointments.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Citas pasadas")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        
                        ForEach(viewModel.pastAppointments) { appointment in
                            AppointmentCard(appointment: appointment, isPast: true)
                                .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .padding(.vertical, 16)
        }
    }
    
    private var notLoggedInView: some View {
        VStack(spacing: 24) {
            // Ícono estilizado en un círculo
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "calendar")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
            .padding(.bottom, 10)
            
            Text("Regístrate para ver tus citas")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("Tus citas aparecerán aquí cuando te registres")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(spacing: 16) {
                Button(action: viewModel.login) {
                    Text("Iniciar sesión")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal, 40)
                
                Button(action: viewModel.signUp) {
                    Text("Crear cuenta")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
                .padding(.horizontal, 40)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 40)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
    }
}

struct AppointmentCard: View {
    let appointment: Appointment
    let isPast: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Fecha y hora
            HStack {
                // Icono de calendario con fondo
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "calendar")
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(appointment.formattedDate)
                        .font(.headline)
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // Indicador de estado
                if isPast {
                    Text("Completada")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(6)
                } else {
                    Text("Pendiente")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            
            Divider()
            
            // Información del doctor
            HStack(spacing: 16) {
                // Imagen o icono del médico
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(appointment.doctor.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text(appointment.doctor.specialty.name)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            // Botones de acción solo para citas futuras
            if !isPast {
                Divider()
                
                HStack(spacing: 12) {
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "arrow.2.squarepath")
                                .font(.system(size: 14))
                            Text("Reprogramar")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "xmark")
                                .font(.system(size: 14))
                            Text("Cancelar")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// Estructura para previsualizar
#Preview {
    AppointmentsView()
}
