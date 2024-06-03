//
//  Avatar:Igloo.swift
//  peakmind-pt2
//
//  Created by Raj Jagirdar on 6/3/24.
//

import Foundation
//
//  AvatarMenuView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/15/24.
//

import SwiftUI
import FirebaseFirestore

struct AvatarMenuView: View {
    let avatarIcons = ["IndianIcon", "AsianIcon", "WhiteIcon", "Girl1Icon", "Girl2Icon", "Girl3Icon"]
    let avatarImages = ["Raj", "Mikey", "Trevor", "Girl1", "Girl2", "Girl3"]
    @State private var selectedAvatarIndex = 0
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToIglooView = false
    @EnvironmentObject var viewModel: AuthViewModel
    @State var isUpdateSuccessful = false // Control the presentation of the sheet
    



    var body: some View {
        NavigationView {
            ZStack {
                Image("MainBG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Select Your Avatar")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Spacer()

                    ZStack {
                        Color.black.opacity(0.6)
                            .cornerRadius(20)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 40)
                        
                        VStack(spacing: 10) {
                            // Display avatar icons in rows of 3
                            ForEach(0..<avatarIcons.count/3 + (avatarIcons.count % 3 > 0 ? 1 : 0), id: \.self) { rowIndex in
                                HStack {
                                    ForEach(0..<3) { colIndex in
                                        let index = rowIndex * 3 + colIndex
                                        if index < avatarIcons.count {
                                            Button(action: {
                                                selectedAvatarIndex = index
                                            }) {
                                                Image(avatarIcons[index])
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 95, height: 85)
                                                    .clipShape(Circle())
                                                    .overlay(
                                                        Circle().stroke(Color.white, lineWidth: selectedAvatarIndex == index ? 3 : 0)
                                                    )
                                            }
                                        }
                                    }
                                }
                                .padding(.top, rowIndex == 0 ? 20 : 0)
                            }
                            
                            Image(avatarImages[selectedAvatarIndex])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .clipShape(Circle())
                                .padding(.top, 20)
                                .padding(.bottom, 30)
                            
                            HStack(spacing: 12) {
                                Button("Cancel") {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                                .padding()
                                .frame(maxWidth: 140)
                                .foregroundColor(.white)
                                .background(Color("Pink"))
                                .cornerRadius(10)
                                
                                Button("Confirm") {
                                    Task {
                                        try await updateBackgroundAvatar()
                                    }
                                }
                                .padding()
                                .frame(maxWidth: 140)
                                .foregroundColor(.white)
                                .background(Color("Medium Blue"))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 10)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .background(
                // NavigationLink that triggers when navigateToIglooView is true
                NavigationLink(
                    destination: IglooMenuView().environmentObject(viewModel),
                    isActive: $navigateToIglooView
                ) {
                    EmptyView()
                }
            )
        }
        .onReceive(viewModel.$currentUser) { currentUser in
            if isUpdateSuccessful {
                self.presentationMode.wrappedValue.dismiss() // Dismiss the sheet after successful update
            }
        }
    }
    func updateBackgroundAvatar() async throws {
        guard let user = viewModel.currentUser else {
            print("No authenticated user found.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id)

        do {
            try await userRef.setData([
                "selectedAvatar": avatarImages[selectedAvatarIndex],
            ], merge: true)

            print(avatarImages[selectedAvatarIndex])
            print("User fields updated successfully. Avatar!!!!!!!")
            isUpdateSuccessful = true // Set the update flag to true

            // Assuming fetchUser is also an asynchronous function
            await viewModel.fetchUser()
            
            navigateToIglooView = true // Set the state to trigger navigation

        } catch {
            print("Error updating user fields: \(error)")
        }
    }

    
}

// Preview
struct AvatarMenuSheet_Previews: PreviewProvider {
    static var previews: some View {
        AvatarMenuView()
    }
}


//
//  IglooMenuView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/15/24.
//

import SwiftUI
import FirebaseFirestore

struct IglooMenuView: View {
    let iglooIcons = ["BlueIcon", "PinkIcon", "OrangeIcon"]
    let iglooImages = ["Blue Igloo", "Pink Igloo", "Orange Igloo"]
    @State private var selectedIglooIndex = 0
    @State private var isIglooSelection = true
    @State private var navigateToTabView = false

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isUpdateSuccessful = false // Control the presentation of the sheet



    var body: some View {
        NavigationView{
            ZStack {
                Image("MainBG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Select Your Igloo")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    ZStack {
                        Color.black.opacity(0.6)
                            .cornerRadius(20)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 40)
                        
                        VStack(spacing: 10) {
                            HStack {
                                ForEach(0..<iglooIcons.count, id: \.self) { index in
                                    Button(action: {
                                        selectedIglooIndex = index
                                    }) {
                                        Image(iglooIcons[index])
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 95, height: 85)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle().stroke(Color.white, lineWidth: selectedIglooIndex == index ? 3 : 0)
                                            )
                                    }
                                }
                            }
                            .padding(.top, 20)
                            
                            Image(iglooImages[selectedIglooIndex])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .padding(.top, 20)
                                .padding(.bottom, 30)
                            
                            HStack(spacing: 12) {
                                Button("Back") {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                                .padding()
                                .frame(maxWidth: 140)
                                .foregroundColor(.white)
                                .background(Color("Pink"))
                                .cornerRadius(10)
                                
                                Button("Confirm") {
                                    // Confirm action: FIREBASE CONNECTION PLZ and make it navigate to the avatar screen after selected
                                    Task {
                                        try await updateBackgroundAvatar()
                                        try await viewModel.fetchUser()
                                        navigateToTabView = true
                                    }
                                    
                                }
                                .padding()
                                .frame(maxWidth: 140)
                                .foregroundColor(.white)
                                .background(Color("Medium Blue"))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 10)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .background(
            // NavigationLink that triggers when navigateToIglooView is true
            NavigationLink(
                destination: TabViewMain().environmentObject(viewModel),
                isActive: $navigateToTabView
            ) {
                EmptyView()
            }
        )
//        .onReceive(viewModel.$currentUser) { currentUser in
//            if isUpdateSuccessful {
//                self.presentationMode.wrappedValue.dismiss() // Dismiss the sheet after successful update
//            }
//        }
    }
    func updateBackgroundAvatar() async throws {
        guard let user = viewModel.currentUser else {
            print("No authenticated user found.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id)

        do {
            try await userRef.setData([
                "selectedBackground": iglooImages[selectedIglooIndex],
                "hasSetInitialAvatar": true
            ], merge: true)

            print("User fields updated successfully.")
            isUpdateSuccessful = true // Set the update flag to true


            // Assuming fetchUser is also an asynchronous function
            await viewModel.fetchUser()
        } catch {
            print("Error updating user fields: \(error)")
        }
    }

}

// Preview
struct IglooMenuView_Previews: PreviewProvider {
    static var previews: some View {
        IglooMenuView()
    }
}

import SwiftUI
import FirebaseFirestore

struct AvatarScreen: View {
    let avatarOptions = ["Mikey", "Raj", "Trevor", "Girl1", "Girl2", "Girl3"]
    let backgroundOptions = ["Pink Igloo", "Orange Igloo", "Blue Igloo", "Navy Igloo"]
    @State private var selectedAvatar = "Mikey"
    @State private var selectedBackground = "Navy Igloo"
    @State private var showPicker = false
    @State private var username: String = ""
    @State private var newUsername = ""
    @State private var isEditingUsername = false
    @State private var isNavigatingToProfileView = false
    @State private var isNavigatingToAvatarEdit = false
    @State private var isNavigatingToIglooEdit = false

    @State private var isIglooMenuPresented = false
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        if let user = viewModel.currentUser {
            ZStack(alignment: .center) { // Align the ZStack content to the top
                Image("MainBG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)

                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.black.opacity(0.5))
                    .padding(.horizontal, 20)
                    .frame(height: 650)
                    .overlay(
                        VStack {
                            Text("Your Profile")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.bottom, 20)

                            ZStack {
                                Image(user.selectedBackground)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 300, height: 300)
                                    .cornerRadius(15)
                                    .clipped()

                                Image(user.selectedAvatar)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 280, height: 280)
                            }
                            .padding(.bottom, 20)

                            HStack(spacing: 10) {
                                Button(action: {
                                    isNavigatingToProfileView = true
                                }) {
                                    VStack {
                                        Image(systemName: "gear")
                                            .frame(width: 24, height: 24) // Set to same size as other icons
                                        Text("General")
                                            .font(.system(size: 12)) // Adjust font size
                                    }
                                }
                                .padding()
                                .frame(width: 80, height: 60)
                                .background(Color.gray)
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                                .sheet(isPresented: $isNavigatingToProfileView) { // Present ProfileView as a sheet
                                    ProfileView()
                                }

                                Button(action: {
                                    isNavigatingToAvatarEdit = true
                                }) {
                                    VStack {
                                        Image(systemName: "person.crop.circle")
                                            .frame(width: 24, height: 24) // Set to same size as other icons
                                        Text("Avatar")
                                            .font(.system(size: 12)) // Adjust font size
                                    }
                                }
                                .padding()
                                .frame(width: 80, height: 60)
                                .background(Color("Medium Blue"))
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                                .sheet(isPresented: $isNavigatingToAvatarEdit) {
                                    AvatarMenuSheet()
                                }

                                Button(action: {
                                    isNavigatingToIglooEdit = true
                                }) {
                                    VStack {
                                        Image("iglooIcon") // Use your igloo icon image name
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 24) // Set to same size as system image
                                        Text("Igloo")
                                            .font(.system(size: 12)) // Adjust font size
                                    }
                                }
                                .padding()
                                .frame(width: 80, height: 60)
                                .background(Color("Ice Blue"))
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                                .sheet(isPresented: $isNavigatingToIglooEdit) {
                                    IglooMenuSheet()
                                }
                            }
                            .frame(maxWidth: 300)
                        }
                        .padding()
                    )
                    .padding(.top, 20) // Adjust top padding to move the box closer to the top
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    func updateBackgroundAvatar() async throws {
        guard let user = viewModel.currentUser else {
            print("No authenticated user found.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id)

        do {
            try await userRef.setData([
                "selectedAvatar": selectedAvatar,
                "selectedBackground": selectedBackground
            ], merge: true)

            print("User fields updated successfully.")

            // Assuming fetchUser is also an asynchronous function
            await viewModel.fetchUser()
        } catch {
            print("Error updating user fields: \(error)")
        }
    }

    func updateUsername() async throws {
        guard let user = viewModel.currentUser else {
            print("No authenticated user found.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id)

        do {
            try await userRef.setData([
                "username": username,
            ], merge: true)

            print("User fields updated successfully.")

            // Assuming fetchUser is also an asynchronous function
            await viewModel.fetchUser()
        } catch {
            print("Error updating user fields: \(error)")
        }
    }
}

// Preview
struct AvatarScreen_Previews: PreviewProvider {
    static var previews: some View {
        AvatarScreen().environmentObject(AuthViewModel())
    }
}

//
//  AvatarMenuView.swift
//  peakmind-mvp
//
//  Created by Mikey Halim on 3/15/24.
//

import SwiftUI
import FirebaseFirestore

struct AvatarMenuSheet: View {
    let avatarIcons = ["IndianIcon", "AsianIcon", "WhiteIcon", "Girl1Icon", "Girl2Icon", "Girl3Icon"]
    let avatarImages = ["Raj", "Mikey", "Trevor", "Girl1", "Girl2", "Girl3"]
    @State private var selectedAvatarIndex = 0
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToIglooView = false
    @EnvironmentObject var viewModel: AuthViewModel
    @State var isUpdateSuccessful = false // Control the presentation of the sheet
    
    @EnvironmentObject var CommunitiesViewModel: CommunitiesViewModel



    var body: some View {
        NavigationView {
            ZStack {
                Image("MainBG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Select Your Avatar")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Spacer()

                    ZStack {
                        Color.black.opacity(0.6)
                            .cornerRadius(20)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 40)
                        
                        VStack(spacing: 10) {
                            // Display avatar icons in rows of 3
                            ForEach(0..<avatarIcons.count/3 + (avatarIcons.count % 3 > 0 ? 1 : 0), id: \.self) { rowIndex in
                                HStack {
                                    ForEach(0..<3) { colIndex in
                                        let index = rowIndex * 3 + colIndex
                                        if index < avatarIcons.count {
                                            Button(action: {
                                                selectedAvatarIndex = index
                                            }) {
                                                Image(avatarIcons[index])
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 95, height: 85)
                                                    .clipShape(Circle())
                                                    .overlay(
                                                        Circle().stroke(Color.white, lineWidth: selectedAvatarIndex == index ? 3 : 0)
                                                    )
                                            }
                                        }
                                    }
                                }
                                .padding(.top, rowIndex == 0 ? 20 : 0)
                            }
                            
                            Image(avatarImages[selectedAvatarIndex])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .clipShape(Circle())
                                .padding(.top, 20)
                                .padding(.bottom, 30)
                            
                            HStack(spacing: 12) {
                                Button("Cancel") {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                                .padding()
                                .frame(maxWidth: 140)
                                .foregroundColor(.white)
                                .background(Color("Pink"))
                                .cornerRadius(10)
                                
                                Button("Confirm") {
                                    Task {
                                        try await updateBackgroundAvatar()
                                    }
                                }
                                .padding()
                                .frame(maxWidth: 140)
                                .foregroundColor(.white)
                                .background(Color("Medium Blue"))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 10)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)

        }
        .onReceive(viewModel.$currentUser) { currentUser in
            if isUpdateSuccessful {
                self.presentationMode.wrappedValue.dismiss() // Dismiss the sheet after successful update
            }
        }
    }
    func updateBackgroundAvatar() async throws {
        guard let user = viewModel.currentUser else {
            print("No authenticated user found.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id)

        do {
            try await userRef.setData([
                "selectedAvatar": avatarImages[selectedAvatarIndex],
            ], merge: true)

            print(avatarImages[selectedAvatarIndex])
            print("User fields updated successfully. Avatar!!!!!!!")
            isUpdateSuccessful = true // Set the update flag to true

            // Assuming fetchUser is also an asynchronous function
            await viewModel.fetchUser()
            
            navigateToIglooView = true // Set the state to trigger navigation

        } catch {
            print("Error updating user fields: \(error)")
        }
    }

    
}

// Preview
struct AvatarMenuView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarMenuView()
    }
}


//
//  IglooMenuSheet.swift
//  peakmind-mvp
//
//  Created by Raj Jagirdar on 4/1/24.
//

import SwiftUI
import FirebaseFirestore

struct IglooMenuSheet: View {
    let iglooIcons = ["BlueIcon", "PinkIcon", "OrangeIcon"]
    let iglooImages = ["Blue Igloo", "Pink Igloo", "Orange Igloo"]
    @State private var selectedIglooIndex = 0
    @State private var isIglooSelection = true
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isUpdateSuccessful = false // Control the presentation of the sheet

    var body: some View {
        NavigationView {
            ZStack {
                Image("MainBG")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Select Your Igloo")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    ZStack {
                        Color.black.opacity(0.6)
                            .cornerRadius(20)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 40)
                        
                        VStack(spacing: 10) {
                            HStack {
                                ForEach(0..<iglooIcons.count, id: \.self) { index in
                                    Button(action: {
                                        selectedIglooIndex = index
                                    }) {
                                        Image(iglooIcons[index])
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 95, height: 85)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle().stroke(Color.white, lineWidth: selectedIglooIndex == index ? 3 : 0)
                                            )
                                    }
                                }
                            }
                            .padding(.top, 20)
                            
                            Image(iglooImages[selectedIglooIndex])
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .padding(.top, 20)
                                .padding(.bottom, 30)
                            
                            HStack(spacing: 12) {
                                Button("Back") {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                                .padding()
                                .frame(maxWidth: 140)
                                .foregroundColor(.white)
                                .background(Color("Pink"))
                                .cornerRadius(10)
                                
                                Button("Confirm") {
                                    // Confirm action: FIREBASE CONNECTION PLZ and make it navigate to the avatar screen after selected
                                    Task {
                                        try await updateBackgroundAvatar()
                                    }
                                }
                                .padding()
                                .frame(maxWidth: 140)
                                .foregroundColor(.white)
                                .background(Color("Medium Blue"))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal, 10)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onReceive(viewModel.$currentUser) { currentUser in
            if isUpdateSuccessful {
                self.presentationMode.wrappedValue.dismiss() // Dismiss the sheet after successful update
            }
        }
    }

    func updateBackgroundAvatar() async throws {
        guard let user = viewModel.currentUser else {
            print("No authenticated user found.")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.id)

        do {
            try await userRef.setData([
                "selectedBackground": iglooImages[selectedIglooIndex],
                "hasSetInitialAvatar": true
            ], merge: true)

            print("User fields updated successfully.")
            isUpdateSuccessful = true // Set the update flag to true

            // Assuming fetchUser is also an asynchronous function
            await viewModel.fetchUser()
        } catch {
            print("Error updating user fields: \(error)")
        }
    }
}

#Preview {
    IglooMenuSheet()
}
