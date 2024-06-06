//
//  SignInViewModel.swift
//  Mdots
//
//  Created by Estela Alvarez on 10/11/23.
//

import Foundation

/// View model for sign-in functionality.
@MainActor
final class SignInViewModel: ObservableObject {
    /// Email entered by the user for sign-in.
    @Published var email = ""
    /// Password entered by the user for sign-in.
    @Published var password = ""
    
    /// Attempts to sign in the user asynchronously.
    /// - Throws: An `AuthError` if there's an issue with the sign-in process.
    func signIn() async throws {
        
        do {
            try await AuthManager.shared.signIn(email: email, password: password)
        } catch let error as NSError {
            if let authErrorCode = AuthErrorCode.Code(rawValue: error.code) {
                print(authErrorCode.rawValue)
                switch authErrorCode.rawValue {
                    case 17004:
                        throw AuthError.wrongCredential
                    case 17008:
                        throw AuthError.wrongCredential
                    case 17009:
                        throw AuthError.wrongPassword
                    default:
                        throw AuthError.unknown
                }
            } else {

                throw AuthError.unknown
            }
        }
    }
}

