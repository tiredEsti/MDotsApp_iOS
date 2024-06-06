//
//  PatientDetailViewModel.swift
//  MDots
//
//  Created by Estela Alvarez on 5/6/24.
//

import Foundation

/// ViewModel for adding a new patient.
@MainActor
class PatientDetailViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    /// It fetches the authenticated user's data from the AuthManager and UserManager.
    func loadCurrentUser() async throws {
        let authDataResult = try AuthManager.shared.getAuthUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func deletePatient(patientID: String) async throws {
        try await loadCurrentUser()
        
        guard let user = user else {
            throw NSError(domain: "AddPatientViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not available"])
        }
        
        try await UserManager.shared.deletePatient(user: user, patientID: patientID)
    }
}
