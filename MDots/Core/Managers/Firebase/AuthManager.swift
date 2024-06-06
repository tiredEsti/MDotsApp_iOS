//
//  AuthManager.swift
//  Mdots
//
//  Created by Estela Alvarez on 7/11/23.
//

import Foundation
import FirebaseAuth

/// A model representing the authentication result data.
///
/// The `AuthDataResultModel` struct encapsulates the user's UID and email, providing a simple
/// data structure for managing authenticated user information.
struct AuthDataResultModel {
    let uid : String
    let email : String
    
    /// Initializes a new `AuthDataResultModel` instance using a Firebase `User` object.
    ///
    /// - Parameter user: The Firebase `User` object containing the user's authentication data.
    init(user : User){
        self.uid = user.uid
        self.email = user.email ?? "default@email"
    }
        
}

/// Enum representing the different authentication provider options.
///
/// The `AuthProviderOptions` enum defines the available authentication providers such as email and Google.
enum AuthProviderOptions: String {
    case email = "password"
    case google = "google.com"
}

/// A singleton class for managing authentication using Firebase.
///
/// The `AuthManager` class provides methods for signing in, signing out, deleting users, and managing authentication
/// providers. It also includes extensions for email-based and SSO (single sign-on) authentication methods.
final class AuthManager {
    static let shared = AuthManager()
    
    /// Initializes the `AuthManager` singleton instance.
    ///
    /// This initializer is private to enforce the singleton pattern, preventing the creation of multiple instances.
    private init() { }
    
    /// Retrieves the currently authenticated user.
    ///
    /// - Throws: An `AuthError` if there is no currently signed-in user.
    /// - Returns: An `AuthDataResultModel` containing the authenticated user's data.
    func getAuthUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noCurrentUser
        }
        return AuthDataResultModel(user: user)
    }
    
    /// Signs out the currently authenticated user.
    ///
    /// - Throws: An error if the sign-out operation fails.
    func signOut() throws {
       try Auth.auth().signOut()
    }
    
    /// Deletes the currently authenticated user and their data from Firestore.
    ///
    /// - Throws: An `AuthError` if there is no currently signed-in user or if the deletion operation fails.
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noCurrentUser
        }
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(user.uid)
        try await userDocRef.delete()
        try await user.delete()
    }
    
    /// Retrieves the authentication providers for the currently authenticated user.
    ///
    /// - Throws: An `AuthError` if the provider data is unavailable or if an unknown provider is encountered.
    /// - Returns: An array of `AuthProviderOptions` representing the authentication providers.
    /// - Note: The provider options are represented as strings, such as https: google.com or password
    func getProviders() throws -> [AuthProviderOptions] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw AuthError.badServerResponse
        }
        
        var providers: [AuthProviderOptions] = []
        
        for provider in providerData {
            if let option = AuthProviderOptions(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                throw AuthError.unknownProvider(provider.providerID)

            }
        }
        
        return providers
    }
}



//SIGN IN EMAIL
extension AuthManager {
    
    /// Creates a new user with the specified email and password.
    ///
    /// - Parameters:
    ///   - email: The email address of the new user.
    ///   - password: The password for the new user.
    /// - Throws: An error if the creation operation fails.
    /// - Returns: An `AuthDataResultModel` containing the new user's data.
    @discardableResult
    func createUser(email: String, password: String) async throws  -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    /// Signs in a user with the specified email and password.
    ///
    /// - Parameters:
    ///   - email: The email address of the user.
    ///   - password: The password for the user.
    /// - Throws: An error if the sign-in operation fails.
    /// - Returns: An `AuthDataResultModel` containing the signed-in user's data.
    @discardableResult
    func signIn(email: String, password: String) async throws -> AuthDataResultModel {
        do {
            let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
            return AuthDataResultModel(user: authDataResult.user)
        } catch let error as NSError {
            throw error
        }
    }
    
    /// Sends a password reset email to the specified email address.
    ///
    /// - Parameter email: The email address to send the password reset to.
    /// - Throws: An error if the operation fails.
    func resetPassword(email : String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    /// Updates the password for the currently authenticated user.
    ///
    /// - Parameter password: The new password to set.
    /// - Throws: An `AuthError` if there is no currently signed-in user or if the update operation fails.
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noCurrentUser
        }
        try await user.updatePassword(to: password)
    }
    
    /// Updates the email for the currently authenticated user.
    ///
    /// - Parameter email: The new email address to set.
    /// - Throws: An `AuthError` if there is no currently signed-in user or if the update operation fails.
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noCurrentUser
        }
        try await user.sendEmailVerification(beforeUpdatingEmail: email)
    }
    
    /// Reauthenticates the currently authenticated user with the specified password.
    ///
    /// - Parameter password: The password for reauthentication.
    /// - Throws: An `AuthError` if there is no currently signed-in user or if the reauthentication fails.
    func reAuth(password: String) throws {
        let user = Auth.auth().currentUser
        
        guard let email = user?.email else {
            throw AuthError.noCurrentUser
        }
        
        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        user?.reauthenticate(with: credential) { (result, error) in
            if error != nil {
                print("Reauthentication failed")
            } else {
                print("Reauthentication successful")
            }
        }
    }
}


//SIGN IN SSO
extension AuthManager {
    /// Signs in a user with Google using the provided tokens.
    ///
    /// - Parameter tokens: The `GoogleSignInResultModel` containing the Google ID and access tokens.
    /// - Throws: An error if the sign-in operation fails.
    /// - Returns: An `AuthDataResultModel` containing the signed-in user's data.
    @discardableResult
    func signInGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)

        return try await signIn(credential: credential)
    }
    
    /// Signs in a user with the specified authentication credential.
    ///
    /// - Parameter credential: The `AuthCredential` to use for signing in.
    /// - Throws: An error if the sign-in operation fails.
    /// - Returns: An `AuthDataResultModel` containing the signed-in user's data
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
}
