//
//  ResetViewModel.swift
//  Mdots
//
//  Created by Estela Alvarez on 10/11/23.
//

import Foundation

/// View model for handling password reset functionality.
@MainActor
final class ResetViewModel: ObservableObject {
    /// Email address for password reset.
    @Published var email = ""
    
    /// Resets the user's password asynchronously.
    /// - Throws: An error if the email field is empty or if there's an issue with resetting the password.
    func sendResetEmail() async throws {
        guard !email.isEmpty else {
            print("Empty field found.")
            return
        }
        
        try await AuthManager.shared.resetPassword(email: email)

    }
    
    /// Reauthenticates the user and then resets the password asynchronously.
    /// - Parameter password: The user's current password.
    /// - Throws: An error if there's no current user, or if there's an issue with reauthentication or resetting the password.
    func reauthenticateAndResetPassword(password: String) async throws {
            guard let user = Auth.auth().currentUser, let email = user.email else {
                throw AuthError.noCurrentUser
            }

            let credential = EmailAuthProvider.credential(withEmail: email, password: password)

            try await user.reauthenticate(with: credential)
            try await AuthManager.shared.resetPassword(email: email)
    }
}
