import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        TabView(selection: $appCoordinator.selectedTab) {
            SearchHomeView()
                .tabItem {
                    Label("Buscar", systemImage: "magnifyingglass")
                }
                .tag(TabSelection.search)
            
            AppointmentsView()
                .tabItem {
                    Label("Citas", systemImage: "calendar")
                }
                .tag(TabSelection.appointments)
            
            MyDoctorsView()
                .tabItem {
                    Label("Mis Doctores", systemImage: "stethoscope")
                }
                .tag(TabSelection.myDoctors)
            
            AccountView()
                .tabItem {
                    Label("Mi Cuenta", systemImage: "person.circle")
                }
                .tag(TabSelection.account)
        }
    }
}
