import SwiftUI

struct InsurancePickerView: View {
    @Binding var searchText: String
    @State private var insurances: [Insurance] = Insurance.popularInsurances
    @Environment(\.dismiss) var dismiss
    var onSelectInsurance: (Insurance) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("Select insurance")
                    .font(.headline)
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Done")
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            SearchBar(text: $searchText, placeholder: "Search for insurance", showScanButton: true)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Already have an account?")
                            .font(.headline)
                        Text("Use your saved insurance")
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Handle login action
                    }) {
                        Text("Log in")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.customGreen)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                HStack {
                    Text("Popular options")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("#")
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(insurances) { insurance in
                            InsuranceRow(insurance: insurance) {
                                onSelectInsurance(insurance)
                                dismiss()
                            }
                            Divider()
                                .padding(.leading, 76)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .preferredColorScheme(.light)
    }
}

struct InsuranceRow: View {
    let insurance: Insurance
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Replace image with a placeholder or icon
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(insurance.name.prefix(1)))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                    )
                
                Text(insurance.name)
                    .font(.body)
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String
    var showScanButton: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 8)
            
            TextField(placeholder, text: $text)
                .padding(.vertical, 10)
            
            if showScanButton {
                Button(action: {
                    // Handle scan action
                }) {
                    Image(systemName: "qrcode.viewfinder")
                        .foregroundColor(.gray)
                        .padding(.trailing, 8)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                .background(Color.white)
        )
        .cornerRadius(20)
    }
}
