//
//  SignInGoogleHelper.swift
//  Mdots
//
//  Created by Estela Alvarez on 8/11/23.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

/// A model representing the result of a Google Sign-In operation.
///
/// This struct contains the ID token, access token, and optionally the user's name, surname, and email.
struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
    let name: String?
    let surname : String?
    let email: String?
}


/// A helper class for managing Google Sign-In operations.
///
/// The `SignInGoogleHelper` class provides a method to sign in with Google asynchronously, handling
/// token extraction and error management.
final class SignInGoogleHelper {
    
    /// Signs in with Google and returns the result containing tokens and user information.
    ///
    /// This method uses the top view controller to present the Google Sign-In interface.
    /// It extracts the ID token, access token, and user profile information upon successful sign-in.
    ///
    /// - Throws: An `AuthError` if the top view controller is missing or the ID token is not available.
    /// - Returns: A `GoogleSignInResultModel` containing the ID token, access token, name, surname, and email.
    @MainActor
    func signIn() async throws -> GoogleSignInResultModel {
        guard let topVC = Utilities.shared.topViewController() else {
            throw AuthError.missingTopViewController
        }
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let id = result.user.idToken?.tokenString else {
            throw AuthError.missingIDToken
        }
        
        let accessToken = result.user.accessToken.tokenString
        let name = result.user.profile?.givenName
        let surname = result.user.profile?.familyName
        let email = result.user.profile?.email
        
        let tokens = GoogleSignInResultModel(idToken: id, accessToken: accessToken, name: name, surname: surname, email: email)
        
        return tokens
    }
}
