import SwiftUI

struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .sentences
    var validation: ((String) -> Bool)? = nil
    var errorMessage: String = ""
    
    @State private var isValid: Bool = true
    @State private var showPassword: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            if isSecure {
                HStack {
                    if showPassword {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                            .autocapitalization(autocapitalization)
                            .disableAutocorrection(true)
                    } else {
                        SecureField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                            .autocapitalization(autocapitalization)
                            .disableAutocorrection(true)
                    }
                    
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(Constants.UI.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                        .stroke(isValid ? Color.clear : Color.red, lineWidth: 1)
                )
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(autocapitalization)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(Constants.UI.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                            .stroke(isValid ? Color.clear : Color.red, lineWidth: 1)
                    )
            }
            
            if !isValid {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .onChange(of: text) { newValue in
            if let validation = validation {
                isValid = validation(newValue)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        FormField(
            title: "Email",
            placeholder: "Enter your email",
            text: .constant("user@example.com"),
            keyboardType: .emailAddress,
            autocapitalization: .none,
            validation: { email in
                let emailRegex = Constants.Validation.emailRegex
                let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
                return emailPredicate.evaluate(with: email)
            },
            errorMessage: "Please enter a valid email address"
        )
        
        FormField(
            title: "Password",
            placeholder: "Enter your password",
            text: .constant("password"),
            isSecure: true,
            validation: { password in
                return password.count >= Constants.Validation.passwordMinLength
            },
            errorMessage: "Password must be at least 8 characters"
        )
        
        FormField(
            title: "Name",
            placeholder: "Enter your full name",
            text: .constant("John Doe")
        )
        
        FormField(
            title: "Phone",
            placeholder: "Enter your phone number",
            text: .constant(""),
            keyboardType: .phonePad,
            validation: { phone in
                let phoneRegex = Constants.Validation.phoneRegex
                let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
                return phone.isEmpty || phonePredicate.evaluate(with: phone)
            },
            errorMessage: "Please enter a valid 10-digit phone number"
        )
    }
    .padding()
}
