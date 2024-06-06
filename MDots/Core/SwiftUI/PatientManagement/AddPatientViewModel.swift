//
//  AddPatientViewModel.swift
//  MDots
//
//  Created by Estela Alvarez on 8/4/24
//

import Foundation

/// ViewModel for adding a new patient.
@MainActor
final class AddPatientViewModel: ObservableObject {
    /// @Published properties store the patient's information and notify observers about changes.
    @Published var name = ""
    @Published var surname = ""
    @Published var birthDate = Date()
    @Published var height = 100
    @Published var weight = ""
    @Published var observations = ""
    
    /// This published property holds the current authenticated user.
    /// It is private(set) so it can only be set within this class, but it can be read from outside.
    @Published private(set) var user: DBUser? = nil
    
    /// It fetches the authenticated user's data from the AuthManager and UserManager.
    func loadCurrentUser() async throws {
        let authDataResult = try AuthManager.shared.getAuthUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    /// This function first loads the current user, then constructs a dictionary with the patient's data, and finally calls `UserManager` to add the patient.
    /// - Throws: An error if the user is not available or if adding the patient fails.
    func addPatient() async throws {
        try await loadCurrentUser()
        
        guard let user = user else {
            throw NSError(domain: "AddPatientViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not available"])
        }
        
        let patientData: [String: Any] = [
            "name": name,
            "surname": surname,
            "birthDate": birthDate,
            "height": height,
            "weight": weight,
            "observations": observations
        ]

        try await UserManager.shared.addPatient(user: user, patientData: patientData)
    }
}

