import SwiftUI

struct LocationPickerView: View {
    @Binding var searchText: String
    @StateObject private var locationManager = LocationManager()
    @Environment(\.presentationMode) var presentationMode
    let onSelectLocation: (String) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                // White background
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                                .padding()
                        }
                        
                        Text("Location")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.black)
                        
                        Spacer()
                            .frame(width: 40)
                    }
                    .padding(.top)
                    
                    TextField("Address, zip code, or city", text: $searchText)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    Button(action: {
                        locationManager.requestLocation()
                        
                        // If permission is notDetermined, wait for the prompt response
                        if locationManager.authorizationStatus == .notDetermined {
                            // The didChangeAuthorization callback will handle the result
                        }
                        // If already authorized, wait for location update then dismiss
                        else if locationManager.authorizationStatus == .authorizedWhenInUse ||
                                locationManager.authorizationStatus == .authorizedAlways {
                            // Wait for location update completion
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                onSelectLocation(locationManager.locationString)
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                        // If denied, just dismiss with "Current location"
                        else {
                            onSelectLocation("Near me")
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        HStack {
                            Text("Current location")
                                .foregroundColor(.black)
                            Spacer()
                            if locationManager.isRequestingLocation {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: {
                        if !searchText.isEmpty {
                            onSelectLocation(searchText)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Done")
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding()
                    }
                }
            }
            .navigationBarHidden(true)
            .preferredColorScheme(.light) // Force light mode
            .onReceive(locationManager.$authorizationStatus) { status in
                // When authorization changes to allowed, wait a bit for location to update
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if !locationManager.isRequestingLocation {
                            onSelectLocation(locationManager.locationString)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
}
