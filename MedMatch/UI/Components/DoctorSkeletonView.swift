import SwiftUI

struct DoctorSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                // Doctor image placeholder
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                VStack(alignment: .leading, spacing: 8) {
                    // Name placeholder
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                        .frame(width: 200)
                        .cornerRadius(4)
                    
                    // Specialty placeholder
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 16)
                        .frame(width: 150)
                        .cornerRadius(4)
                }
            }
            
            // Rating placeholders
            HStack {
                ForEach(0..<3, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 16)
                        .frame(width: 16)
                        .cornerRadius(2)
                }
            }
            
            // Additional info placeholders
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 16)
                .frame(width: 300)
                .cornerRadius(4)
            
            // Availability placeholders
            HStack {
                ForEach(0..<4, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 60)
                        .frame(width: 80)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    DoctorSkeletonView()
        .padding()
        .background(Color.gray.opacity(0.1))
}
