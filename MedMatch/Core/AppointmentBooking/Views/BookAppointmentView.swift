import SwiftUI
import Combine

struct BookAppointmentView: View {
    let doctor: Doctor
    let appointmentTime: Date
    @StateObject private var viewModel = BookAppointmentViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        mainNavigationView
    }
    
    // Componente principal de navegación
    private var mainNavigationView: some View {
        NavigationView {
            ZStack {
                // Fondo
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    contentStack
                }
            }
            .navigationTitle("Agendar Cita")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: cancelButton)
            .alert(isPresented: $viewModel.showingAlert) {
                bookingAlert
            }
            .sheet(isPresented: $viewModel.showInsurancePicker) {
                InsurancePickerView(
                    searchText: .constant(""),
                    onSelectInsurance: { insurance in
                        viewModel.selectedInsurance = insurance
                    }
                )
            }
        }
    }
    
    private var cancelButton: some View {
        Button("Cancelar") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var contentStack: some View {
        VStack(alignment: .leading, spacing: 24) {
            appointmentSummary
            insuranceSection
            visitTypeSection
            notesSection
            bookButton
            
            if viewModel.isLoading {
                loadingIndicator
            }
        }
        .padding(.vertical, 20)
    }
    
    private var appointmentSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detalles de la Cita")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.bottom, 4)
                .padding(.horizontal, 16)
            
            VStack(spacing: 16) {
                doctorInfoRow(icon: "person.fill", text: doctor.name)
                doctorInfoRow(icon: "stethoscope", text: doctor.specialty.name)
                doctorInfoRow(icon: "calendar", text: formatDate(appointmentTime))
                doctorInfoRow(icon: "clock.fill", text: formatTime(appointmentTime))
                doctorInfoRow(icon: "mappin.and.ellipse", text: doctor.address.formatted)
            }
            .padding(.vertical, 16)
            .padding(.horizontal)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal)
    }
    
    private func doctorInfoRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.black)
            
            Spacer()
        }
    }
    
    private var insuranceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Seguro Médico")
                .font(.headline)
                .fontWeight(.semibold)
            
            Button(action: {
                viewModel.showInsurancePicker = true
            }) {
                HStack {
                    Text(viewModel.selectedInsurance?.name ?? "Selecciona tu seguro médico")
                        .foregroundColor(viewModel.selectedInsurance != nil ? .black : .gray)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
            }
        }
        .padding(.horizontal)
    }
    
    private var visitTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tipo de Visita")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(VisitType.allCases, id: \.self) { visitType in
                    visitTypeButton(for: visitType)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func visitTypeButton(for visitType: VisitType) -> some View {
        Button(action: {
            viewModel.selectedVisitType = visitType
        }) {
            HStack {
                Text(visitTypeInSpanish(visitType))
                    .font(.subheadline)
                    .foregroundColor(.black)
                
                Spacer()
                
                if viewModel.selectedVisitType == visitType {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 20, height: 20)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                } else {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
            )
        }
    }
    
    private func visitTypeInSpanish(_ visitType: VisitType) -> String {
        switch visitType {
        case .newPatient:
            return "Primera Visita (Paciente Nuevo)"
        case .followUp:
            return "Consulta de Seguimiento"
        case .annualCheckup:
            return "Revisión Anual"
        case .consultation:
            return "Consulta General"
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notas para el médico (opcional)")
                .font(.headline)
                .fontWeight(.semibold)
            
            TextEditor(text: $viewModel.notes)
                .frame(minHeight: 120)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
        }
        .padding(.horizontal)
    }
    
    private var bookButton: some View {
        Button(action: {
            viewModel.bookAppointment(doctorId: doctor.id, date: appointmentTime)
        }) {
            Text("Confirmar Cita")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Group {
                        if viewModel.isFormValid && !viewModel.isLoading {
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color.gray.opacity(0.5)
                        }
                    }
                )
                .cornerRadius(12)
                .shadow(color: viewModel.isFormValid && !viewModel.isLoading ? Color.blue.opacity(0.3) : Color.clear, radius: 5, x: 0, y: 3)
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
    }
    
    private var loadingIndicator: some View {
        HStack {
            Spacer()
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("Procesando...")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
            Spacer()
        }
        .padding()
    }
    
    private var bookingAlert: Alert {
        Alert(
            title: Text(viewModel.alertTitle),
            message: Text(viewModel.alertMessage),
            dismissButton: .default(Text("Aceptar")) {
                if viewModel.appointmentBooked {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
}

enum VisitType: String, CaseIterable {
    case newPatient = "New Patient Visit"
    case followUp = "Follow-up"
    case annualCheckup = "Annual Check-up"
    case consultation = "Consultation"
}
