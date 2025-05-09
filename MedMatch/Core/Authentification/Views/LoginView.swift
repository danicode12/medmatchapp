import SwiftUI
import Combine

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
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
                
                Text("Log in to MedMatch")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                VStack(spacing: 16) {
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
                }
                .padding(.horizontal)
                
                Button(action: {
                    viewModel.forgotPassword()
                }) {
                    Text("Forgot password?")
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal)
                
                Button(action: {
                    viewModel.login()
                }) {
                    Text("Log in")
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
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        viewModel.showSignUp()
                    }) {
                        Text("Sign up")
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
