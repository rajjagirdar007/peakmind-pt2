import SwiftUI
import AuthenticationServices

struct SignInWithAppleButtonView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: authViewModel.handleSignInWithAppleRequest,
            onCompletion: authViewModel.handleSignInWithAppleCompletion
        )
        .frame(width: 280, height: 45)
        .signInWithAppleButtonStyle(.black)
    }
}
