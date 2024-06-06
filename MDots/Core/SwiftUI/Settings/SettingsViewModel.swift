//
//  SettingsViewModel.swift
//  Mdots
//
//  Created by Estela Alvarez on 10/11/23.
//

import Foundation

/// A view model class for managing settings-related functionality.
///
/// The `SettingsViewModel` class encapsulates methods for retrieving authentication providers,
/// signing out, deleting accounts, updating passwords, updating email addresses, resetting passwords,
/// and reauthenticating users
final class SettingsViewModel : ObservableObject {
    
    /// The authentication providers available to the current user.
    @Published var authProviders: [AuthProviderOptions] = []
    
    /// Retrieves the authentication providers for the current user
    func getAuthProviders() {
        if let providers = try? AuthManager.shared.getProviders() {
            authProviders = providers
        }
    }

    /// Signs out the current user.
    ///
    /// - Throws: An error if the sign-out operation fails.   
    func signOut() throws {
        try AuthManager.shared.signOut()
    }
    
    /// Deletes the current user's account asynchronously.
    ///
    /// - Throws: An error if the deletion operation fails.
    func deleteAccount() async throws {
        try await AuthManager.shared.delete()
    }
    
    /// Updates the current user's password asynchronously.
    ///
    /// - Throws: An error if the password update operation fails.
    func updatePassword() async throws {
        try await AuthManager.shared.updatePassword(password: "newPassword")
    }
    
    /// Updates the current user's email address asynchronously.
    ///
    /// - Throws: An error if the email update operation fails.
    func updateEmail() async throws {
        let authUser = try AuthManager.shared.getAuthUser()
        let user = try await UserManager.shared.getUser(userId: authUser.uid)
        Task {
            try await UserManager.shared.updateEmail(userId: user.userId, email: "newEmail")
            try await AuthManager.shared.updateEmail(email: "newEmail")
        }
    }
    
    /// Resets the current user's password asynchronously.
    ///
    /// - Throws: An error if the password reset operation fails.
    func resetPassword() async throws {
        let authUser = try AuthManager.shared.getAuthUser()
        let email = authUser.email
        try await AuthManager.shared.resetPassword(email: email)

    }
    
    /// Reauthenticates the current user with the specified password asynchronously.
    ///
    /// - Parameter password: The password for reauthentication.
    /// - Throws: An error if the reauthentication operation fails.
    func reauthenticate(password: String) async throws {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw AuthError.noCurrentUser
        }
        _ = EmailAuthProvider.credential(withEmail: email, password: password)
        try AuthManager.shared.reAuth(password: password)
    }
}
