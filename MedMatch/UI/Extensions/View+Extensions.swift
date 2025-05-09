import SwiftUI

extension View {

    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func primaryButton() -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("PrimaryColor"))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
    
    func secondaryButton() -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .foregroundColor(Color("PrimaryColor"))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color("PrimaryColor"), lineWidth: 1)
            )
    }
    
    func inputField() -> some View {
        self
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
    }
}
