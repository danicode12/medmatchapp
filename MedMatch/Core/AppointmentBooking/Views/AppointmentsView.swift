import SwiftUI

struct AppointmentsView: View {
    @StateObject private var viewModel = AppointmentsViewModel()
    
    var body: some View {
        NavigationView {
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
            .navigationTitle("Appointments")
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .font(.system(size: 70))
                .foregroundColor(.gray.opacity(0.5))
                .padding(.bottom, 10)
            
            Text("No appointments")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("When you book appointments, they'll appear here")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: viewModel.findDoctor) {
                Text("Find a doctor")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.customGreen)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 40)
            .padding(.top)
        }
        .padding()
    }
    
    private var appointmentListView: some View {
        List {
            Section(header: Text("Upcoming")) {
                ForEach(viewModel.upcomingAppointments) { appointment in
                    AppointmentRow(appointment: appointment)
                }
            }
            
            if !viewModel.pastAppointments.isEmpty {
                Section(header: Text("Past")) {
                    ForEach(viewModel.pastAppointments) { appointment in
                        AppointmentRow(appointment: appointment)
                    }
                }
            }
        }
    }
    
    private var notLoggedInView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .font(.system(size: 70))
                .foregroundColor(.gray.opacity(0.5))
                .padding(.bottom, 10)
            
            Text("Sign in to view your appointments")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Your appointments will appear here after you sign in")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: viewModel.login) {
                Text("Log in")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 40)
            .padding(.top)
            
            Button(action: viewModel.signUp) {
                Text("Sign up")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

struct AppointmentRow: View {
    let appointment: Appointment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(appointment.formattedDate)
                .font(.headline)
            
            Text(appointment.doctor.name)
                .font(.subheadline)
            
            Text(appointment.doctor.specialty.name)
                .font(.caption)
                .foregroundColor(.gray)
            
            if !appointment.isPast {
                HStack(spacing: 10) {
                    Button(action: {}) {
                        Label("Reschedule", systemImage: "arrow.2.squarepath")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {}) {
                        Label("Cancel", systemImage: "xmark")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }
}
