import SwiftUI

struct CareTypeSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedType: String?
    var onComplete: ((String?) -> Void)?
    
    var body: some View {
        ZStack {
            // Add explicit white background
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Progress bar at top
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: UIScreen.main.bounds.width * 0.33, height: 4)
                }
                
                Text("What type of care are you looking for?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                
                // Option 1: Annual physical
                Button(action: {
                    selectedType = "Annual physical / checkup"
                }) {
                    HStack {
                        Circle()
                            .stroke(selectedType == "Annual physical / checkup" ? Color.blue : Color.gray, lineWidth: 2)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .fill(selectedType == "Annual physical / checkup" ? Color.blue : Color.clear)
                                    .frame(width: 12, height: 12)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Annual physical / checkup")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Text("Comprehensive preventative examination to assess overall health")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.leading, 8)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedType == "Annual physical / checkup" ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                
                // Option 2: Specific issue
                Button(action: {
                    selectedType = "Issue, condition or problem"
                }) {
                    HStack {
                        Circle()
                            .stroke(selectedType == "Issue, condition or problem" ? Color.blue : Color.gray, lineWidth: 2)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .fill(selectedType == "Issue, condition or problem" ? Color.blue : Color.clear)
                                    .frame(width: 12, height: 12)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("I need care for an issue, condition or problem")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Text("Find treatment for a new issue or ongoing care for a diagnosed condition")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.leading, 8)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(selectedType == "Issue, condition or problem" ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Continue button
                Button(action: {
                    // Dismiss the view
                    presentationMode.wrappedValue.dismiss()
                    
                    // Call the onComplete closure with the selected type
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onComplete?(selectedType)
                    }
                }) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedType != nil ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(selectedType == nil)
                .padding(.horizontal)
                
                // Skip button
                Button(action: {
                    // Dismiss the view
                    presentationMode.wrappedValue.dismiss()
                    
                    // Call the onComplete closure with nil to indicate skip
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onComplete?(nil)
                    }
                }) {
                    Text("Skip and show search results")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.light)
    }
}
