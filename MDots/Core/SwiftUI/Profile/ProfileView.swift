//
//  ProfileView.swift
//  Mdots
//
//  Created by Estela Alvarez on 10/11/23.
//

import SwiftUI

/// A view that displays the user's profile information.
///
/// The `ProfileView` shows the current user's name and email. It also provides a navigation link to the settings view.
/// The profile data is fetched asynchronously when the view appears.
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignUpView: Bool
    
    var body: some View {
        List{
            if let user = viewModel.user {
                Text("Welcome, \(user.name) \(user.surname)")
                Text("Email: \(user.email)")
            }
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(showSignUpView: $showSignUpView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
            }
        }
    }
}

#Preview {
    NavigationStack{
        ProfileView(showSignUpView: .constant(false))
    }
}
