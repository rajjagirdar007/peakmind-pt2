import SwiftUI


struct HomeView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationStack {
            Text("Home Screen")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Log out") {
                            print("Log out tapped!")
                            authService.regularSignOut { error in
                                
                                if let e = error {
                                    print(e.localizedDescription)
                                }
                            }
                        }
                    }
                }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
