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
    
    // Break up into smaller components
    private var mainNavigationView: some View {
        NavigationView {
            ScrollView {
                contentStack
            }
            .navigationTitle("Book Appointment")
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
        Button("Cancel") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var contentStack: some View {
        VStack(alignment: .leading, spacing: 20) {
            appointmentSummary
            insuranceSection
            visitTypeSection
            notesSection
            bookButton
            
            if viewModel.isLoading {
                loadingIndicator
            }
        }
        .padding(.vertical)
    }
    
    private var appointmentSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Appointment Details")
                .font(.headline)
                .padding(.bottom, 4)
            
            doctorInfoRow(icon: "person.fill", text: doctor.name)
            doctorInfoRow(icon: "stethoscope", text: doctor.specialty.name)
            doctorInfoRow(icon: "calendar", text: formatDate(appointmentTime))
            doctorInfoRow(icon: "clock", text: formatTime(appointmentTime))
            doctorInfoRow(icon: "location.fill", text: doctor.address.formatted)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func doctorInfoRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.subheadline)
        }
    }
    
    private var insuranceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insurance")
                .font(.headline)
            
            Button(action: {
                viewModel.showInsurancePicker = true
            }) {
                HStack {
                    Text(viewModel.selectedInsurance?.name ?? "Select your insurance")
                        .foregroundColor(viewModel.selectedInsurance != nil ? .black : .gray)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal)
    }
    
    private var visitTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Visit Type")
                .font(.headline)
            
            ForEach(VisitType.allCases, id: \.self) { visitType in
                visitTypeButton(for: visitType)
            }
        }
        .padding(.horizontal)
    }
    
    private func visitTypeButton(for visitType: VisitType) -> some View {
        Button(action: {
            viewModel.selectedVisitType = visitType
        }) {
            HStack {
                Text(visitType.rawValue)
                    .foregroundColor(.black)
                
                Spacer()
                
                if viewModel.selectedVisitType == visitType {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes for the doctor (optional)")
                .font(.headline)
            
            TextEditor(text: $viewModel.notes)
                .frame(minHeight: 100)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(.horizontal)
    }
    
    private var bookButton: some View {
        Button(action: {
            viewModel.bookAppointment(doctorId: doctor.id, date: appointmentTime)
        }) {
            Text("Book Appointment")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
        .opacity(viewModel.isFormValid && !viewModel.isLoading ? 1.0 : 0.6)
    }
    
    private var loadingIndicator: some View {
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            Spacer()
        }
        .padding()
    }
    
    private var bookingAlert: Alert {
        Alert(
            title: Text(viewModel.alertTitle),
            message: Text(viewModel.alertMessage),
            dismissButton: .default(Text("OK")) {
                if viewModel.appointmentBooked {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

enum VisitType: String, CaseIterable {
    case newPatient = "New Patient Visit"
    case followUp = "Follow-up"
    case annualCheckup = "Annual Check-up"
    case consultation = "Consultation"
}
