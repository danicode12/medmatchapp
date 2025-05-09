import SwiftUI

struct AccountView: View {
    @StateObject private var viewModel = AccountViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if viewModel.isAuthenticated {
                        Button(action: viewModel.showProfile) {
                            HStack {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.title2)
                                Text("Profile")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        Button(action: viewModel.login) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Log in")
                            }
                        }
                        
                        Button(action: viewModel.signUp) {
                            HStack {
                                Image(systemName: "person")
                                Text("Sign up")
                            }
                        }
                    }
                }
                .listRowBackground(Color.white)
                
                Section {
                    Button(action: viewModel.contactUs) {
                        HStack {
                            Text("Contact us")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: viewModel.showTerms) {
                        HStack {
                            Text("Terms of use")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: viewModel.showPrivacyPolicy) {
                        HStack {
                            Text("Privacy policy")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: viewModel.showPrivacyChoices) {
                        HStack {
                            Text("Privacy choices")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .listRowBackground(Color.white)
                
                Section {
                    Button(action: viewModel.sendFeedback) {
                        Text("Send app feedback")
                    }
                    
                    Button(action: viewModel.shareApp) {
                        Text("Share MedMatch")
                    }
                }
                .listRowBackground(Color.white)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("My account")
        }
    }
}
