// File: UI/Components/Cards/SpecialtyCardView.swift
import SwiftUI

struct SpecialtyCardView: View {
    let specialty: Specialty
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            VStack {
                Image(systemName: specialty.iconName)
                    .font(.system(size: 36))
                    .foregroundColor(.customGreen)
                    .padding(.bottom, 8)
                
                Text(specialty.name.components(separatedBy: " ").first ?? specialty.name)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SpecialtyCardView(
        specialty: Specialty.primaryCare,
        onTap: {}
    )
    .frame(width: 150, height: 120)
    .padding()
    .previewLayout(.sizeThatFits)
}
