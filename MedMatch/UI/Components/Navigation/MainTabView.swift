import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        TabView(selection: $appCoordinator.selectedTab) {
            SearchHomeView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(TabSelection.search)
            
            AppointmentsView()
                .tabItem {
                    Label("Appointments", systemImage: "calendar")
                }
                .tag(TabSelection.appointments)
            
            MyDoctorsView()
                .tabItem {
                    Label("My Doctors", systemImage: "stethoscope")
                }
                .tag(TabSelection.myDoctors)
            
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
                .tag(TabSelection.account)
        }
    }
}
