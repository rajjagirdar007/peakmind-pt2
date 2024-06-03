//
//  ProfileView.swift
//  peakmind-pt2
//
//  Created by Raj Jagirdar on 6/3/24.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel : AuthViewModel
    @State private var isModule1Active = false
    @State private var isModule2Active = false
    @State private var isModule3Active = false
    @State private var isTentPurchaseActive = false
    @State private var isStoreViewActive = false
    @State private var isAnxietyQuizActive = false
    @State private var isSetHabitsActive = false
    @State private var isAvatarScreenActive = false
    @State private var isNightfallFlavorActive = false
    @State private var isDangersOfNightfallActive = false
    @State private var isSherpaFullMoonIDActive = false
    @State private var isBreathingExerciseViewActive = false
    @State private var isFeedbackFormPresented = false

    var body: some View {
        NavigationView {
            if let user = viewModel.currentUser {
                List {
                    Section {
                        HStack {
                            Text(user.username)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 72, height: 72)
                                .background(Color.blue)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.username)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.top, 4)
                                
                                Text(user.email)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Section("General") {
                        HStack {
                            SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
                            
                            Spacer()
                            
                            Text("1.0.0")
                        }
                    }
                    
                    Section("Account") {
                        Button {
                            viewModel.signOut()
                        } label: {
                            SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                        }
                        
                        Button {
                            Task {
                               try await viewModel.deleteAccount()
                            }
                        } label: {
                            SettingsRowView(imageName: "xmark.circle.fill", title: "Delete Account", tintColor: .red)
                        }
                    }
                    
                    Section("Feedback Form") {
                        Button("Provide Feedback") {
                            isFeedbackFormPresented.toggle()
                        }
                        .sheet(isPresented: $isFeedbackFormPresented) {
                            FeedbackFormView().environmentObject(viewModel)
                        }
                    }
                }
                .environment(\.colorScheme, .light)
            }
        }
    }
}


struct SettingsPreview: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

struct SettingsRowView: View {
    let imageName : String
    let title: String
    let tintColor : Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
        }
    }
}

#Preview {
    SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
}
