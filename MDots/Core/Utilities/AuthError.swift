//
//  Errors.swift
//  MDots
//
//  Created by Estela Alvarez on 16/5/24.
//

import Foundation


/// An enumeration representing various authentication errors that can occur.
///
/// The `AuthError` enum conforms to the `Error` and `LocalizedError` protocols, providing detailed
/// descriptions for each error case that can be used for displaying user-friendly error messages.
enum AuthError: Error, LocalizedError {
    case missingName
    case missingSurname
    case missingTopViewController
    case missingIDToken
    case badServerResponse
    case noCurrentUser
    case unknownProvider(String)
    case wrongPassword
    case userNotFound
    case unknown
    case invalidEmail
    case emailAlreadyInUse
    case wrongCredential
    

    /// A description of the error, suitable for displaying to the user.
    ///
    /// This property provides a localized description for each error case, making it easier to
    /// understand what went wrong during the authentication process.
    var errorDescription: String? {
        switch self {
            case .missingName:
                return "The user's name is missing from the Google sign-in tokens."
            case .missingSurname:
                return "The user's surname is missing from the Google sign-in tokens."
            case .missingTopViewController:
                return "The top view controller could not be found."
            case .missingIDToken:
                return "The ID token is missing from the Google sign-in result."
            case .badServerResponse:
                return "Bad server response."
            case .noCurrentUser:
                return "There is no currently signed-in user."
            case .unknownProvider(let providerID):
                return "Provider option not found: \(providerID)"
            case .wrongPassword:
                return "Incorrect password. Please try again."
            case .userNotFound:
                return "No user found with this email. Please check the email or sign up."
            case .unknown:
                return "An unknown error occurred. Please try again."
            case .invalidEmail:
                return "The email address is badly formatted."
            case .emailAlreadyInUse:
                return "The email address is already in use by another account."
            case .wrongCredential:
                return "Incorrect email or password. Please try again."
        }
        
    }
}
