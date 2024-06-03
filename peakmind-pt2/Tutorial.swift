//
//  Tutorial.swift
//  peakmind-pt2
//
//  Created by Raj Jagirdar on 6/3/24.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

struct TutorialPage {
    var view: AnyView
    var text: String
}

class TutorialViewModel: ObservableObject {
    @Published var currentPage = 0
}

struct TutorialView: View {
    @EnvironmentObject var tutorialViewModel: TutorialViewModel
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var isShowingTutorial: Bool

    // Initialize tutorial pages with the viewModel
    var tutorialPages: [TutorialPage] {
        [
            TutorialPage(view: AnyView(ChatView().environmentObject(viewModel)), text: "Welcome to our app! This is the chat view."),
            TutorialPage(view: AnyView(SelfCareHome().environmentObject(viewModel)), text: "This is the self care home!"),
            TutorialPage(view: AnyView(HomeDashboard(selectedTab: .constant(2)).environmentObject(viewModel)), text: "This is the home dashboard!"),
            TutorialPage(view: AnyView(AnxietyCommunityView()), text: "Talk to people here!"),

            // Add more pages as necessary
        ]
    }

    func next() {
        if tutorialViewModel.currentPage < tutorialPages.count - 1 {
            tutorialViewModel.currentPage += 1
        } else {
            isShowingTutorial = false  // Close tutorial after the last page
            completeTutorial()
        }
    }
    
    var body: some View {
        VStack {
            TabView(selection: $tutorialViewModel.currentPage) {
                ForEach(0..<tutorialPages.count, id: \.self) { index in
                    tutorialPageView(tutorialPages[index])
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.5))
            .edgesIgnoringSafeArea(.all)
        }
    }

    @ViewBuilder
    private func tutorialPageView(_ page: TutorialPage) -> some View {
        ZStack {
            page.view
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                SherpaTutorialBox(tutorialText: page.text, continueAction: next)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.5))
            .edgesIgnoringSafeArea(.all)
        }
    }

    private func completeTutorial() {
        guard let user = viewModel.currentUser else {
            print("No authenticated user found.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id ?? "")
        userRef.updateData(["hasCompletedTutorial": true]) { error in
            if let error = error {
                print("Error updating tutorial completion flag: \(error)")
            } else {
                print("Tutorial completion flag updated successfully.")
                Task {
                    await viewModel.fetchUser()  // Refresh user data
                }
            }
        }
    }
}

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView(isShowingTutorial: .constant(true))
            .environmentObject(TutorialViewModel())
            .environmentObject(AuthViewModel())
    }
}
