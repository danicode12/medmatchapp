import SwiftUI

struct SearchFormView: View {
    @Binding var searchText: String
    @Binding var locationText: String
    var insuranceText: String?
    let onSearchTap: () -> Void
    let onLocationTap: () -> Void
    let onInsuranceTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onSearchTap) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    Text(searchText.isEmpty ? "Condition, procedure, doctor..." : searchText)
                        .foregroundColor(searchText.isEmpty ? .gray : .black)
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8, corners: [.topLeft, .topRight])
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            
            Divider().padding(.horizontal)
            
            Button(action: onLocationTap) {
                HStack {
                    Image(systemName: "location.fill")
                        .foregroundColor(.gray)
                    Text(locationText)
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding()
                .background(Color.white)
            }
            
            Divider().padding(.horizontal)
            
            Button(action: onInsuranceTap) {
                HStack {
                    Image(systemName: "plus.rectangle.fill")
                        .foregroundColor(.gray)
                    if let insurance = insuranceText, insurance != "Select insurance" {
                        Text(insurance)
                            .foregroundColor(.black)
                    } else {
                        Text("Add health insurance")
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8, corners: [.bottomLeft, .bottomRight])
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
