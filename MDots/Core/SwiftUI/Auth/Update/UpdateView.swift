//
//  UpdateView.swift
//  Mdots
//
//  Created by Estela Alvarez on 9/11/23.
//

import SwiftUI
import UIKit

/// View for updating user information.
struct UpdateView: View {
    /// View model for handling update operations.
    @StateObject private var viewModel = UpdateViewModel()
    /// Indicates whether to show the sign-up view.
    @Binding var showSignUpView : Bool
    /// Indicates the option to update: email or password.
    @Binding var option: Bool
    /// Indicates whether to show the password prompt.
    @State private var showPasswordPrompt = false
    /// Current password entered by the user.
    @State private var currentPassword = ""
    
    var body: some View {
        VStack{
            
            if option {
                emailUpdateSection
            } else {
                passwordUpdateSection
            }

        }
        .onAppear {
               showPasswordPrompt = true
           }
           .alert("Confirm your identity", isPresented: $showPasswordPrompt, actions: {
               SecureField("Password", text: $currentPassword)
               NavigationLink {
                   SettingsView(showSignUpView: $showSignUpView)
               } label: {
                   Text("Cancel")
                       .foregroundColor(.blue)
               }
               Button("OK") {
                   Task {
                       do {
                           try await viewModel.reauthenticate(password: currentPassword)
                       } catch {
                           print(error)
                       }
                   }
               }
           }, message: {
               Text("Reenter your current password")
        })
        .padding()

    }

}

#Preview {
    UpdateView(showSignUpView: .constant(false), option: .constant(true))
}

/// Extension to UpdateView for defining different update sections.
extension UpdateView {
    /// View section for updating email.
    private var emailUpdateSection: some View {
        Section {
            TextField("New Email", text: $viewModel.newCredential)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            Button {
                Task {
                    do {
                        try await viewModel.updateEmail()
                        showSignUpView = false
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Update Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .navigationTitle("Change your email")
    }
    /// View section for updating password.
    private var passwordUpdateSection: some View {
        Section {
            TextField("New Password", text: $viewModel.newCredential)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            Button {
                Task {
                    do {
                        try await viewModel.updatePassword()
                        showSignUpView = false
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Update Password")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            Spacer()
        }
        .navigationTitle("Change your password")
    }
    
}
