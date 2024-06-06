//
//  SettingsView.swift
//  Mdots
//
//  Created by Estela Alvarez on 7/11/23.
//

import SwiftUI

/// A view for managing user settings, including credentials updates, sign-out, and account deletion.
///
/// The `SettingsView` provides a user interface for users to update their email and password,
/// sign out of their account, and delete their account with confirmation prompts.
struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignUpView: Bool
    @State private var showPasswordPrompt = false
    @State private var showDeleteConfirmation = false
    @State private var currentPassword = ""
    
    var body: some View {
        List {
            
            if viewModel.authProviders.contains(.email) {
                credentialsSection
            }
            
            Button("Sign out"){
                Task {
                    do {
                        try viewModel.signOut()
                        showSignUpView = true
                    } catch {
                        print(error)
                    }
                }
            }
            Button(role: .destructive){
                showPasswordPrompt = true
            } label: {
                Text("Delete account")
            }
                
        }
        .onAppear {
            viewModel.getAuthProviders()
        }
        .alert("Confirm your identity", isPresented: $showPasswordPrompt, actions: {
            SecureField("Password", text: $currentPassword)
            Button("Cancel", role: .cancel) { }
            Button("OK") {
                Task {
                    do {
                        try await viewModel.reauthenticate(password: currentPassword)
                        showDeleteConfirmation = true
                    } catch {
                        print(error)
                    }
                }
            }
        }, message: {
            Text("Reenter your current password")
        })
        .alert("Are you sure?", isPresented: $showDeleteConfirmation, actions: {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        showSignUpView = true
                    } catch {
                        print(error)
                    }
                }
            }
        }, message: {
            Text("This action cannot be undone")
        })
        .navigationBarTitle("Settings")
    }
}

extension SettingsView {

    /// A section for updating email and password credentials.
    private var credentialsSection: some View {
        Section {
            
            NavigationLink{
                UpdateView(showSignUpView: .constant(true), option: .constant(true))
            } label: {
                Text("Update your email")
                    .foregroundColor(.blue)
            }
            NavigationLink{
                UpdateView(showSignUpView: .constant(true), option: .constant(false))
            } label: {
                Text("Update your password")
                    .foregroundColor(.blue)
            }
            
        } header: {
            Text("Credentials")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView(showSignUpView: .constant(false))
    }
}
