import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
            if authViewModel.isSignedIn {
                Text("Welcome, \(authViewModel.user?.username ?? "User")!")
                Button(action: {
                    authViewModel.signOut()
                }) {
                    Text("Sign Out")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                VStack {
                    LoginView()
                    SignInWithAppleButtonView()
                }
            }
        }
        .padding()
    }
}
