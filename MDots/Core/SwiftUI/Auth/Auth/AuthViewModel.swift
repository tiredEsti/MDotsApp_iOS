//
//  AuthViewModel.swift
//  Mdots
//
//  Created by Estela Alvarez on 10/11/23.
//

import Foundation

/// A view model for handling authentication-related operations.
@MainActor
final class AuthViewModel: ObservableObject {
    /// Signs in using Google authentication.
    ///
    /// - throws: An error if there's an issue with Google sign-in or user creation.
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let user = try await AuthManager.shared.signInGoogle(tokens: tokens)
        guard let name = tokens.name else { throw AuthError.missingName }
        guard let surname = tokens.surname else { throw AuthError.missingSurname }
        
        try await UserManager.shared.createNewUser(user: DBUser(auth: user, name: name, surname: surname))

    }
}
