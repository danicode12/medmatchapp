import SwiftUI

struct SearchHomeView: View {
    @StateObject private var viewModel = SearchHomeViewModel()
    @State private var showingLocationPicker = false
    @State private var showingSpecialtyPicker = false
    @State private var showingInsurancePicker = false
    @State private var showingCareTypeSelection = false
    @State private var navigateToDoctorList = false
    @State private var selectedSpecialtyForNavigation: Specialty?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Add explicit white background
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Find a doctor")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        SearchFormView(
                            searchText: $viewModel.searchQuery,
                            locationText: $viewModel.locationText,
                            insuranceText: viewModel.selectedInsurance?.name,
                            onSearchTap: { showingSpecialtyPicker = true },
                            onLocationTap: { showingLocationPicker = true },
                            onInsuranceTap: { showingInsurancePicker = true }
                        )
                        
                        Button(action: {
                            showingCareTypeSelection = true
                        }) {
                            Text("Find care")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.customGreen)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Top-searched specialties")
                                .font(.headline)
                                .foregroundColor(.black)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(viewModel.topSpecialties) { specialty in
                                    SpecialtyCardView(
                                        specialty: specialty,
                                        onTap: {
                                            selectedSpecialtyForNavigation = specialty
                                            navigateToDoctorList = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .background(
                NavigationLink(
                    destination: Group {
                        if let specialty = selectedSpecialtyForNavigation {
                            DoctorListView(
                                searchQuery: "",
                                location: viewModel.locationText,
                                specialty: specialty,
                                insurance: viewModel.selectedInsurance
                            )
                        } else {
                            DoctorListView(
                                searchQuery: viewModel.searchQuery,
                                location: viewModel.locationText,
                                specialty: viewModel.selectedSpecialty,
                                insurance: viewModel.selectedInsurance
                            )
                        }
                    },
                    isActive: $navigateToDoctorList
                ) {
                    EmptyView()
                }
            )
            .sheet(isPresented: $showingCareTypeSelection) {
                CareTypeSelectionView(onComplete: { selectedType in
                    // When the care type selection is complete, navigate to the doctor list
                    selectedSpecialtyForNavigation = viewModel.selectedSpecialty ?? Specialty.primaryCare
                    navigateToDoctorList = true
                })
                .preferredColorScheme(.light)
            }
            .sheet(isPresented: $showingLocationPicker) {
                LocationPickerView(
                    searchText: $viewModel.locationSearchText,
                    onSelectLocation: { location in
                        viewModel.locationText = location
                        showingLocationPicker = false
                    }
                )
                .preferredColorScheme(.light)
            }
            .sheet(isPresented: $showingSpecialtyPicker) {
                SpecialtyPickerView(
                    searchText: $viewModel.searchQuery,
                    specialties: Specialty.allSpecialties,
                    onSelectSpecialty: { specialty in
                        viewModel.selectedSpecialty = specialty
                        viewModel.searchQuery = specialty.name
                        showingSpecialtyPicker = false
                    }
                )
                .preferredColorScheme(.light)
            }
            .sheet(isPresented: $showingInsurancePicker) {
                InsurancePickerView(
                    searchText: $viewModel.insuranceSearchText,
                    onSelectInsurance: { insurance in
                        viewModel.selectedInsurance = insurance
                        showingInsurancePicker = false
                    }
                )
                .preferredColorScheme(.light)
            }
        }
        .preferredColorScheme(.light)
    }
}
