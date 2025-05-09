import SwiftUI
import Combine

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Add explicit white background
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .padding()
                    }
                    
                    Spacer()
                }
                
                Text("Create an account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                VStack(spacing: 16) {
                    TextField("Full Name", text: $viewModel.name)
                        .autocapitalization(.words)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    
                    SecureField("Password", text: $viewModel.password)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    
                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Button(action: {
                    viewModel.signUp()
                }) {
                    Text("Sign up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .disabled(!viewModel.isFormValid)
                .opacity(viewModel.isFormValid ? 1.0 : 0.6)
                
                if viewModel.showingError {
                    Text(viewModel.errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
                
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        viewModel.showLogin()
                    }) {
                        Text("Log in")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .alert(isPresented: $viewModel.showingAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .preferredColorScheme(.light)
    }
}
