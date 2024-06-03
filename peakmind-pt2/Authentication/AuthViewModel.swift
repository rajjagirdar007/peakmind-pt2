import SwiftUI
import AuthenticationServices
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: UserData?
    @Published var isSignedIn: Bool = false

    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()

    init() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let user = user {
                self.fetchUserData(userId: user.uid)
            } else {
                self.isSignedIn = false
                self.currentUser = nil
            }
        }
    }

    func fetchUserData(userId: String) {
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                do {
                    self.currentUser = try document.data(as: UserData.self)
                    self.isSignedIn = true
                } catch {
                    print("Error decoding user data: \(error.localizedDescription)")
                }
            } else {
                print("User document does not exist")
            }
        }
    }

    func signInWithEmail(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                print("Failed to sign in with email: \(error.localizedDescription)")
                return
            }
            if let user = result?.user {
                self.fetchUserData(userId: user.uid)
            }
        }
    }

    func signUpWithEmail(email: String, password: String, username: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                print("Failed to sign up with email: \(error.localizedDescription)")
                return
            }
            if let user = result?.user {
                let userData = UserData(
                    id: user.uid,
                    email: email,
                    username: username,
                    selectedAvatar: "",
                    selectedBackground: "",
                    hasCompletedInitialQuiz: false,
                    hasSetInitialAvatar: false,
                    inventory: [],
                    LevelOneCompleted: false,
                    LevelTwoCompleted: false,
                    selectedWidgets: [],
                    lastCheck: nil,
                    weeklyStatus: [],
                    hasCompletedTutorial: false,
                    completedLevels: [],
                    completedLevels2: [],
                    dailyCheckInStreak: 0
                )
                do {
                    try self.db.collection("users").document(user.uid).setData(from: userData)
                    self.currentUser = userData
                    self.isSignedIn = true
                } catch {
                    print("Error saving user data: \(error.localizedDescription)")
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            self.userSession = nil
        } catch {
            print("Failed to sign out: \(error.localizedDescription)")
        }
    }

    // Sign In with Apple Functions
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                let credential = OAuthProvider.credential(
                    withProviderID: "apple.com",
                    idToken: idTokenString,
                    rawNonce: nil
                )
                Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                    guard let self = self else { return }
                    if let error = error {
                        print("Apple sign in error: \(error.localizedDescription)")
                        return
                    }
                    if let user = authResult?.user {
                        self.fetchUserDataOrCreateNew(user: user, email: appleIDCredential.email)
                    }
                }
            }
        case .failure(let error):
            print("Authorization failed: \(error.localizedDescription)")
        }
    }

    private func fetchUserDataOrCreateNew(user: User, email: String?) {
        let userRef = db.collection("users").document(user.uid)
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                do {
                    self.currentUser = try document.data(as: UserData.self)
                    self.isSignedIn = true
                } catch {
                    print("Error decoding user data: \(error.localizedDescription)")
                }
            } else {
                let userData = UserData(
                    id: user.uid,
                    email: user.email ?? "",
                    username: user.email ?? "User",
                    selectedAvatar: "",
                    selectedBackground: "",
                    hasCompletedInitialQuiz: false,
                    hasSetInitialAvatar: false,
                    inventory: [],
                    LevelOneCompleted: false,
                    LevelTwoCompleted: false,
                    selectedWidgets: [],
                    lastCheck: nil,
                    weeklyStatus: [],
                    hasCompletedTutorial: false,
                    completedLevels: [],
                    completedLevels2: [],
                    dailyCheckInStreak: 0
                )
                do {
                    try self.db.collection("users").document(user.uid).setData(from: userData)
                    self.currentUser = userData
                    self.isSignedIn = true
                } catch {
                    print("Error saving user data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteAccount() async {
        guard let user = Auth.auth().currentUser else {
            print("DEBUG: No user is currently signed in.")
            return
        }
        
        do {
            // Delete user data from Firestore first
            let userId = user.uid
            try await Firestore.firestore().collection("users").document(userId).delete()
            
            // Proceed with deleting the user account
            try await user.delete()
            signOut()
            // Clear any related user data in the app
            DispatchQueue.main.async { [weak self] in
                self?.userSession = nil
                self?.currentUser = nil
            }
            
            print("User account and data successfully deleted.")
        } catch let error {
            print("DEBUG: Failed to delete account with error \(error.localizedDescription)")
        }
    }

    func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        _ = GIDConfiguration(clientID: clientID)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
            guard let signInResult = signInResult else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }

            let user = signInResult.user
            let idToken = user.idToken?.tokenString
            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idToken!, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { [weak self] (_, error) in
                guard let self = self else { return }
                if let error = error {
                    print(error.localizedDescription)
                } else if let user = Auth.auth().currentUser {
                    self.fetchUserDataOrCreateNew(user: user, email: user.email)
                }
            }
        }
    }

    
    
    
    //Level Functions
    func markLevelCompleted(levelID: String) async throws {
        guard let currentUserID = currentUser?.id else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserID)

        // Update the local model first
        if let index = currentUser?.completedLevels.firstIndex(where: { $0 == levelID }) {
            print("Level already marked as completed.")
        } else {
            currentUser?.completedLevels.append(levelID)
        }

        // Synchronize with Firestore
        try await userRef.updateData([
            "completedLevels": FieldValue.arrayUnion([levelID])
        ]) { error in
            if let error = error {
                print("Error updating completed levels: \(error.localizedDescription)")
            } else {
                print("Level marked as completed successfully.")
            }
        }

        // Refresh user data to ensure UI is updated
        await fetchUser()
    }
    
    func markLevelCompleted2(levelID: String) async throws {
        guard let currentUserID = currentUser?.id else {
            throw NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserID)

        // Update the local model first
        if let index = currentUser?.completedLevels.firstIndex(where: { $0 == levelID }) {
            print("Level already marked as completed.")
        } else {
            currentUser?.completedLevels2.append(levelID)
        }

        // Synchronize with Firestore
        try await userRef.updateData([
            "completedLevels2": FieldValue.arrayUnion([levelID])
        ]) { error in
            if let error = error {
                print("Error updating completed levels: \(error.localizedDescription)")
            } else {
                print("Level marked as completed successfully.")
            }
        }

        // Refresh user data to ensure UI is updated
        await fetchUser()
    }
    
    
    func saveSelectedWidgets(selected: [String]) async {
        guard let user = currentUser else {
            print("No authenticated user found.")
            return
        }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id ?? "")
        
        do {
            try await userRef.setData(["selectedWidgets": selected], merge: true)
            // Update local user data and refresh
            Task{
                await fetchUser()

            }
            print("Widget selection updated successfully.")
        } catch {
            print("Error updating widget selection: \(error)")
        }
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else {return}
    
        self.currentUser = try? snapshot.data(as: UserData.self)
        
        print("Debug current user is \(String(describing: self.currentUser))")
        
    }
    
    
    func setUserDetails(result_fetch: AuthDataResult) async throws {
        print("called the setUserDetails func")
        self.userSession = result_fetch.user
        Task{
            await fetchUser()
        }
    }
    
    
    func resetPassword(email : String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let err = error {
                print("Error: \(err.localizedDescription)")
            }
        }
    }
    
    

}
