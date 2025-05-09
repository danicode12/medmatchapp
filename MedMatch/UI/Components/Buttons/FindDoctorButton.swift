import SwiftUI

struct FindDoctorButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                
                Text("Find a Doctor")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Constants.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(Constants.UI.cornerRadius)
        }
        .padding(.horizontal)
    }
}

#Preview {
    FindDoctorButton(action: {})
        .previewLayout(.sizeThatFits)
        .padding()
}
