//
//  SignUpViewModel.swift
//  Mdots
//
//  Created by Estela Alvarez on 10/11/23.
//

import Foundation
/// View model for sign-up functionality.
@MainActor
final class SignUpViewModel: ObservableObject {
    /// New user email.
    @Published var email = ""
    /// New user password.
    @Published var password = ""
    /// Password confirmation.
    @Published var passwordConfirmation = ""
    /// User's first name.
    @Published var name = ""
    /// User's last name.
    @Published var surname = ""
    
    /// Warning message for password requirements.
    @Published var passwordWarning: String = ""
    /// Warning message for password confirmation.
    @Published var passwordConfirmationWarning: String = ""
    /// Warning message for email format.
    @Published var emailWarning: String = ""
    /// General error message.
    @Published var generalError: String = ""

    /// Attempts to sign up a new user.
    /// - Returns: A boolean value indicating success or failure.
    func signUp() async -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            generalError = "Email and Password fields cannot be empty."
            return false
        }

        do {
            let user = try await AuthManager.shared.createUser(email: email, password: password)
            try await UserManager.shared.createNewUser(user: DBUser(auth: user, name: name, surname: surname))
            return true
        } catch let error as NSError {
            handleFirebaseError(error)
            return false
        } catch {
            generalError = AuthError.unknown.localizedDescription
            return false
        }
    }
    /// Handles Firebase authentication errors.
    /// - Parameter error: The error received.
    private func handleFirebaseError(_ error: NSError) {
        if let errorCode = AuthErrorCode.Code(rawValue: error.code) {
            switch errorCode {
                case .emailAlreadyInUse:
                    emailWarning = "The email address is already in use by another account."
                case .invalidEmail:
                    emailWarning = "The email address is badly formatted."
                default:
                    generalError = error.localizedDescription
            }
        } else {
            generalError = AuthError.unknown.localizedDescription
        }
    }

    /// Checks if the password meets the security requirements.
    /// - Returns: A boolean value indicating whether the password is secure.
    func isPasswordSecure() -> Bool {
            let password = self.password
            
            let passwordRegex = #"(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}"#
            
            let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
            
            if password.count < 8 {
                passwordWarning = "Password should be at least 8 characters long."
                return false
            } else if !passwordPredicate.evaluate(with: password) {
                passwordWarning = "Password should contain at least one uppercase letter, one lowercase letter, one digit, and one special character (@$!%*?&)."
                return false
            } else {
                passwordWarning = ""
            }
            
            return true
     }
    /// Checks if the entered email address is valid.
    /// - Returns: A boolean value indicating the validity of the email address.
    func isEmailValid() -> Bool {
        let emailRegex = #"\b[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        if !emailPredicate.evaluate(with: email) {
            emailWarning = "Please enter a valid email address."
            return false
        } else {
            emailWarning = ""
            return true
        }
    }
    /// Checks if the password and its confirmation match.
    /// - Returns: A boolean value indicating whether the passwords match.
    func passwordsMatch() -> Bool {
        if password != passwordConfirmation {
            passwordConfirmationWarning = "Passwords do not match."
            return false
        } else {
            passwordConfirmationWarning = ""
            return true
        }
    }
}
