import SwiftUI

struct MyDoctorsView: View {
    @StateObject private var viewModel = MyDoctorsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Add explicit white background
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if viewModel.isAuthenticated {
                        if viewModel.favoriteDoctors.isEmpty {
                            emptyStateView
                        } else {
                            doctorListView
                        }
                    } else {
                        notLoggedInView
                    }
                }
            }
            .navigationTitle("My doctors")
        }
        .preferredColorScheme(.light)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "stethoscope")
                .font(.system(size: 70))
                .foregroundColor(.gray.opacity(0.5))
                .padding(.bottom, 10)
            
            Text("Keep track of your doctors")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("Easily book again with your favorite doctors")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: viewModel.findDoctor) {
                Text("Find a doctor")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.customGreen)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 40)
            .padding(.top)
        }
        .padding()
    }
    
    private var doctorListView: some View {
        List(viewModel.favoriteDoctors) { doctor in
            DoctorRow(doctor: doctor)
                .listRowBackground(Color.white)
        }
        .background(Color.white)
    }
    
    private var notLoggedInView: some View {
        VStack(spacing: 20) {
            emptyStateView
            
            HStack {
                Text("Already have an account?")
                    .foregroundColor(.gray)
                
                Button("Log in") {
                    viewModel.showLogin()
                }
                .foregroundColor(.blue)
            }
            .padding(.top)
        }
    }
}

struct DoctorRow: View {
    let doctor: Doctor
    
    var body: some View {
        HStack(spacing: 16) {
            if let imageURL = doctor.profileImageURL {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.gray)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(doctor.name)
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text(doctor.specialty.name)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.customGreen)
                    
                    Text("\(doctor.rating, specifier: "%.1f") (\(doctor.reviewCount))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color.white)
    }
}
