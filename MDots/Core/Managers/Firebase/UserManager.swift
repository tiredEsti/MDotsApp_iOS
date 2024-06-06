//
//  UserManager.swift
//  Mdots
//
//  Created by Estela Alvarez on 10/11/23.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/// A model representing a user in the database.
///
/// The `DBUser` struct conforms to the `Codable` protocol, allowing it to be easily encoded and decoded
/// for storage in Firestore. It contains user information such as ID, email, name, surname, and the date
/// the user was created.
struct DBUser: Codable {
    let userId : String
    let email : String
    let dateCreated : Date?
    let name : String
    let surname : String
    
    /// Initializes a new `DBUser` instance using authentication data and user details.
    ///
    /// - Parameters:
    ///   - auth: The authentication data result model containing the user's UID and email.
    ///   - name: The user's first name.
    ///   - surname: The user's last name.
    init(auth: AuthDataResultModel, name: String, surname: String){
        self.userId = auth.uid
        self.email = auth.email
        self.name = name
        self.surname = surname
        self.dateCreated = Date()
    }
    
    /// Initializes a new `DBUser` instance with explicit user details.
    ///
    /// - Parameters:
    ///   - userId: The user's unique identifier.
    ///   - email: The user's email address.
    ///   - dateCreated: The date the user was created. Defaults to `nil`.
    ///   - name: The user's first name.
    ///   - surname: The user's last name.
    init(userId: String, email: String, dateCreated: Date? = nil, name: String, surname: String){
        self.userId = userId
        self.email = email
        self.name = name
        self.surname = surname
        self.dateCreated = dateCreated
    }
    
}

/// A singleton class for managing user data in Firestore.
///
/// The `UserManager` class provides methods to create, retrieve, update, and manage user data in Firestore.
/// It uses Firestore's `Encoder` and `Decoder` for encoding and decoding `DBUser` instances.
final class UserManager {
    
    static let shared = UserManager()

    /// Initializes the `UserManager` singleton instance.
    ///
    /// This initializer is private to enforce the singleton pattern, preventing the creation of multiple instances.
    private init() {}
    
    private let userCollection = Firestore.firestore().collection("users")
    
    /// Returns a reference to a specific user's document in Firestore.
    ///
    /// - Parameter userId: The unique identifier of the user.
    /// - Returns: A `DocumentReference` for the specified user's document.
    private func userDocument(userId: String) -> DocumentReference {
       userCollection.document(userId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    

    /// Creates a new user in Firestore.
    ///
    /// This method encodes the provided `DBUser` instance and stores it in Firestore.
    ///
    /// - Parameter user: The `DBUser` instance to create.
    /// - Throws: An error if the operation fails.
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)

    }

    /// Retrieves a user from Firestore.
    ///
    /// This method decodes the user document from Firestore into a `DBUser` instance.
    ///
    /// - Parameter userId: The unique identifier of the user to retrieve.
    /// - Returns: A `DBUser` instance.
    /// - Throws: An error if the operation fails.
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self, decoder: decoder)
    }

    /// Updates a user's email in Firestore.
    ///
    /// - Parameters:
    ///   - userId: The unique identifier of the user to update.
    ///   - email: The new email address to set.
    /// - Throws: An error if the operation fails.
    func updateEmail(userId: String, email: String) async throws {
        let data: [String:Any] = [
            "email" : email
            //DBUser.CodingKeys.email.rawValue : email
        ]
        try await userDocument(userId: userId).updateData(data)
    }
    
    /// Adds patient data for a specific user in Firestore.
    ///
    /// - Parameters:
    ///   - user: The `DBUser` instance representing the user.
    ///   - patientData: A dictionary containing the patient data to add.
    /// - Throws: An error if the operation fails.
    func addPatient(user: DBUser, patientData: [String: Any]) async throws {
            let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.userId)
            let patientsRef = userRef.collection("patients")

            try await patientsRef.addDocument(data: patientData)
        }
    
    /// Deletes a patient document for a specific user from Firestore.
    ///
    /// - Parameters:
    ///   - user: The `DBUser` instance representing the user.
    ///   - patientID: The ID of the patient document to delete.
    /// - Throws: An error if the operation fails.
    func deletePatient(user: DBUser, patientID: String) async throws {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.userId)
        let patientRef = userRef.collection("patients").document(patientID)
        
        try await patientRef.delete()
    }
    
    /// Fetches movement data for a patient and a specific test type from Firestore.
    ///
    /// - Parameters:
    ///   - patient_id: The ID of the patient whose data is being fetched.
    ///   - testType: The type of test for which data is being fetched.
    func fetchData(patient_id: String, testType: String, completion: @escaping ([MovementData]) -> Void) {
        let db = Firestore.firestore()
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Error: Current user ID not available")
            completion([])
            return
        }

        let patientRef = db.collection("users").document(currentUserID).collection("patients").document(patient_id)

        patientRef.collection(testType).order(by: "testDate").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching patients: \(error.localizedDescription)")
                completion([])
                return
            }
            if let documents = querySnapshot?.documents {
                let fetchedData = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: MovementData.self)
                }
                completion(fetchedData)
            } else {
                completion([])
            }
        }
    }

    /// Deletes a specific movement data item from Firestore.
    ///
    /// - Parameters:
    ///   - patient_id: The ID of the patient whose data is being deleted.
    ///   - testType: The type of test for which data is being deleted.
    ///   - item: The movement data item to be deleted.
    func deleteData(patient_id: String, testType: String, item: MovementData, data: [MovementData], completion: @escaping ([MovementData]) -> Void) {
        let db = Firestore.firestore()
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Error: Current user ID not available")
            return
        }

        guard let itemId = item.id else {
            print("Error: Item ID not available")
            return
        }

        let patientRef = db.collection("users").document(currentUserID).collection("patients").document(patient_id)
        
        patientRef.collection(testType).document(itemId).delete { error in
            if let error = error {
                print("Error removing document: \(error.localizedDescription)")
            } else {
                var updatedData = data
                updatedData.removeAll { $0.id == item.id }
                completion(updatedData)
            }
        }
    }
}
