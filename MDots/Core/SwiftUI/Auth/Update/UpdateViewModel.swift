//
//  UpdateViewModel.swift
//  Mdots
//
//  Created by Estela Alvarez on 10/11/23.
//

import Foundation

/// ViewModel for updating user credentials.
@MainActor
final class UpdateViewModel: ObservableObject {
    /// New credential value.
    @Published var newCredential = ""
    /// Current email.
    @Published var email = ""
    /// Current password.
    @Published var password = ""
    
    /// Updates the user's email address.
    /// - Throws: An error if the new credential is empty or if the update fails.
    func updateEmail() async throws {
        guard !newCredential.isEmpty else {
            print("Empty field found.")
            return
        }
        try await AuthManager.shared.updateEmail(email: newCredential)
    }
    
    /// Updates the user's password.
    /// - Throws: An error if the new credential is empty or if the update fails.
    func updatePassword() async throws {
        guard !newCredential.isEmpty else {
            print("Empty field found.")
            return
        }
        try await AuthManager.shared.updatePassword(password: newCredential)
    }
    
    /// Re-authenticates the user with the provided password.
    /// - Parameter password: The user's current password.
    /// - Throws: An error if there is no current user or if re-authentication fails.
    func reauthenticate(password: String) async throws {
        guard let user = Auth.auth().currentUser, let email = user.email else {
            throw AuthError.noCurrentUser
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)
    }
}
