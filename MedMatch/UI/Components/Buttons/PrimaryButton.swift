import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Button text
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .opacity(isLoading ? 0 : 1)
                
                // Loading indicator
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isDisabled ? Color.gray : Constants.Colors.primary)
            .cornerRadius(Constants.UI.cornerRadius)
        }
        .disabled(isDisabled || isLoading)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Button text
                Text(title)
                    .font(.headline)
                    .foregroundColor(Constants.Colors.primary)
                    .opacity(isLoading ? 0 : 1)
                
                // Loading indicator
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.primary))
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(Constants.UI.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                    .stroke(isDisabled ? Color.gray : Constants.Colors.primary, lineWidth: 1)
            )
        }
        .disabled(isDisabled || isLoading)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Sign In", action: {})
        PrimaryButton(title: "Loading", action: {}, isLoading: true)
        PrimaryButton(title: "Disabled", action: {}, isDisabled: true)
        
        SecondaryButton(title: "Cancel", action: {})
        SecondaryButton(title: "Loading", action: {}, isLoading: true)
        SecondaryButton(title: "Disabled", action: {}, isDisabled: true)
    }
    .padding()
}
