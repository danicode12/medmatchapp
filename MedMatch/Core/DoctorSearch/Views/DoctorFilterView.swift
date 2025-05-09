import SwiftUI

struct DoctorFilterView: View {
    @Binding var sortOption: SortOption
    @Binding var availability: Availability
    @Binding var gender: DoctorGender
    @Binding var languages: [String]
    @Binding var rating: Double
    @Binding var distance: Double
    
    let onApplyFilters: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    let availableLanguages = ["English", "Spanish", "Mandarin", "French", "Arabic", "Russian", "Portuguese", "Japanese"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sort by")) {
                    Picker("Sort by", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Availability")) {
                    Picker("Availability", selection: $availability) {
                        ForEach(Availability.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Gender")) {
                    Picker("Doctor Gender", selection: $gender) {
                        ForEach(DoctorGender.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Languages")) {
                    ForEach(availableLanguages, id: \.self) { language in
                        Button(action: {
                            if languages.contains(language) {
                                languages.removeAll { $0 == language }
                            } else {
                                languages.append(language)
                            }
                        }) {
                            HStack {
                                Text(language)
                                Spacer()
                                if languages.contains(language) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Section(header: Text("Minimum Rating")) {
                    HStack {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: rating >= Double(star) ? "star.fill" : "star")
                                .foregroundColor(.customGreen)
                                .onTapGesture {
                                    rating = Double(star)
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Maximum Distance")) {
                    VStack {
                        Slider(value: $distance, in: 1...100, step: 1)
                        HStack {
                            Text("1 mile")
                            Spacer()
                            Text("\(Int(distance)) miles")
                            Spacer()
                            Text("100 miles")
                        }
                        .font(.caption)
                        .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Filter Options")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Apply") {
                    onApplyFilters()
                }
            )
        }
    }
}
