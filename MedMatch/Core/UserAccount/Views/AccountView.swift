import SwiftUI

struct AccountView: View {
    @StateObject private var viewModel = AccountViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo general
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Sección de perfil con diseño mejorado
                        VStack(spacing: 0) {
                            if viewModel.isAuthenticated {
                                // Vista de usuario autenticado
                                AccountMenuButton(
                                    icon: "person.crop.circle.fill",
                                    iconColor: .blue,
                                    title: "Perfil",
                                    showChevron: true,
                                    action: viewModel.showProfile
                                )
                            } else {
                                // Opciones de inicio de sesión/registro
                                VStack(spacing: 0) {
                                    AccountMenuButton(
                                        icon: "lock.open",
                                        iconColor: .blue,
                                        title: "Iniciar sesión",
                                        showChevron: false,
                                        action: viewModel.login
                                    )
                                    
                                    Divider()
                                        .padding(.leading, 54)
                                    
                                    AccountMenuButton(
                                        icon: "person.badge.plus",
                                        iconColor: .blue,
                                        title: "Crear cuenta",
                                        showChevron: false,
                                        action: viewModel.signUp
                                    )
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        // Sección de información
                        VStack(spacing: 0) {
                            AccountMenuButton(
                                icon: "bubble.left.and.bubble.right",
                                iconColor: .green,
                                title: "Contáctanos",
                                showChevron: true,
                                action: viewModel.contactUs
                            )
                            
                            Divider()
                                .padding(.leading, 54)
                            
                            AccountMenuButton(
                                icon: "doc.text",
                                iconColor: .orange,
                                title: "Términos de uso y servicio",
                                showChevron: true,
                                action: viewModel.showTerms
                            )
                            
                            Divider()
                                .padding(.leading, 54)
                            
                            AccountMenuButton(
                                icon: "hand.raised",
                                iconColor: .purple,
                                title: "Política de privacidad",
                                showChevron: true,
                                action: viewModel.showPrivacyPolicy
                            )
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        // Versión de la aplicación
                        Text("Versión 1.0.0")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.top, 30)
                            .padding(.bottom, 20)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Mi cuenta")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// Componente reutilizable para botones de menú
struct AccountMenuButton: View {
    let icon: String
    let iconColor: Color
    let title: String
    let showChevron: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Icono con fondo
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.gray.opacity(0.6))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AccountView()
}
