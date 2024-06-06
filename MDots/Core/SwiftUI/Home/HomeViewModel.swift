//
//  HomeViewModel.swift
//  MDots
//
//  Created by Emilka Kurowicka on 17/04/2024.
//

import Foundation


/// Manages the data and functionality for the home view.
///
/// The `HomeViewModel` is responsible for loading the current user asynchronously and updating the user property accordingly.
@MainActor
final class HomeViewModel: ObservableObject  {
    
    /// Published property representing the current user.
    @Published private(set) var user: DBUser? = nil
    
    /// Loads the current user asynchronously.
    ///
    /// - Throws: An error if the current user cannot be retrieved.
    func loadCurrentUser() async throws {
        let authDataResult = try AuthManager.shared.getAuthUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }

}
