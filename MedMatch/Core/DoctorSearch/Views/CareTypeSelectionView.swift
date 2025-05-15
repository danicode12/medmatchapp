import SwiftUI

struct CareTypeSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedType: String?
    var onComplete: ((String?) -> Void)?
    
    var body: some View {
        ZStack {
            // Clean white background
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                // Progress bar with improved styling
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: UIScreen.main.bounds.width * 0.33, height: 6)
                        .cornerRadius(3)
                }
                .padding(.top, 12)
                
                Text("¿Qué tipo de atención médica estás buscando?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Option 1: Annual physical
                        CareOptionButton(
                            isSelected: selectedType == "Examen físico anual",
                            title: "Examen físico anual",
                            description: "Evaluación preventiva integral para valorar el estado general de salud",
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedType = "Examen físico anual"
                                }
                            }
                        )
                        
                        // Option 2: Specific issue
                        CareOptionButton(
                            isSelected: selectedType == "Problema o condición médica",
                            title: "Necesito atención para un problema o condición médica",
                            description: "Encuentra tratamiento para un nuevo problema o atención continua para una condición diagnosticada",
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedType = "Problema o condición médica"
                                }
                            }
                        )
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    // Continue button with improved styling
                    Button(action: {
                        // Dismiss the view with haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        
                        presentationMode.wrappedValue.dismiss()
                        
                        // Call the onComplete closure with the selected type
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onComplete?(selectedType)
                        }
                    }) {
                        Text("Continuar")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(selectedType != nil ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: selectedType != nil ? Color.blue.opacity(0.3) : Color.clear, radius: 4, x: 0, y: 2)
                    }
                    .disabled(selectedType == nil)
                    .padding(.horizontal)
                    
                    // Skip button with improved styling
                    Button(action: {
                        // Dismiss the view
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        
                        presentationMode.wrappedValue.dismiss()
                        
                        // Call the onComplete closure with nil to indicate skip
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onComplete?(nil)
                        }
                    }) {
                        Text("Omitir y mostrar resultados")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .foregroundColor(.gray)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.light)
    }
}

// Extracted component for better reusability and consistency
struct CareOptionButton: View {
    let isSelected: Bool
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                // Radio button with animation
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.5), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.05) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
