import SwiftUI

struct DoctorCard: View {
    let doctor: Doctor
    var onTap: () -> Void
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.TimeFormats.dayMonth
        return formatter
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    // Doctor image
                    if let imageURL = doctor.profileImageURL {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(Color.gray)
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(doctor.name)
                            .font(.headline)
                        
                        Text(doctor.specialty.name)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // Rating
                        HStack {
                            ForEach(0..<5) { i in
                                Image(systemName: i < Int(doctor.rating) ? "star.fill" : "star")
                                    .font(.caption)
                                    .foregroundColor(.customGreen)
                            }
                            
                            Text("(\(doctor.reviewCount))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        // Location
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("\(doctor.address.city), \(doctor.address.state)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // Next available appointment
                    if let nextAvailable = doctor.availableTimes.first {
                        Text(dateFormatter.string(from: nextAvailable))
                            .font(.caption)
                            .foregroundColor(Constants.Colors.primary)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Constants.Colors.primary.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(Constants.UI.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DoctorCard(
        doctor: Doctor(
            id: "doctor1",
            name: "Dr. Sarah Johnson",
            specialty: Specialty.primaryCare,
            profileImageURL: nil,
            rating: 4.8,
            reviewCount: 153,
            address: Doctor.Address(
                street: "123 Medical Plaza",
                city: "San Francisco",
                state: "CA",
                zipCode: "94102"
            ),
            availableTimes: [
                Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                Calendar.current.date(byAdding: .day, value: 2, to: Date())!
            ]
        ),
        onTap: {}
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}
