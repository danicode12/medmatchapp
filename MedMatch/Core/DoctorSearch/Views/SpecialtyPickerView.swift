import SwiftUI

struct SpecialtyPickerView: View {
    @Binding var searchText: String
    let specialties: [Specialty]
    let onSelectSpecialty: (Specialty) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .padding()
                    }
                    
                    Text("Buscar")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                        .frame(width: 40)
                }
                .padding(.top)
                
                TextField("Condition, procedure, doctor...", text: $searchText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                Text("Especialidades populares")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                List {
                    ForEach(specialties) { specialty in
                        Button(action: {
                            onSelectSpecialty(specialty)
                        }) {
                            Text(specialty.name)
                                .foregroundColor(.black)
                                .padding(.vertical, 8)
                        }
                    }
                }
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}
