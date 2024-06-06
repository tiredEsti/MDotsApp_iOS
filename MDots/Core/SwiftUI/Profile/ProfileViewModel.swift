//
//  ProfileViewModel.swift
//  MDots
//
//  Created by Estela Alvarez on 29/11/23.
//

import Foundation

/// A view model for managing the user's profile information.
///
/// The `ProfileViewModel` is responsible for loading and storing the current user's profile data.
/// It interacts with the `AuthManager` to get the authenticated user's ID and with the `UserManager`
/// to retrieve the user details from the database.
@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    /// Loads the current user's profile data.
    ///
    /// This method fetches the authenticated user's ID using the `AuthManager`, and then retrieves the user's
    /// profile information from the `UserManager`. The fetched user data is stored in the `user` property.
    ///
    /// - Throws: An error if there is an issue with fetching the authenticated user's ID or retrieving the user data.
    func loadCurrentUser() async throws {
        let authDataResult = try AuthManager.shared.getAuthUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
}
