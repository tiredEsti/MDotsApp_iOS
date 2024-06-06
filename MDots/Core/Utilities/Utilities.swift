//
//  Utilities.swift
//  Mdots
//
//  Created by Estela Alvarez on 8/11/23.
//

import Foundation
import UIKit


/// A singleton class providing utility functions for the application.
///
/// The `Utilities` class contains shared methods that can be used throughout the app, such as finding the top view controller.
final class Utilities {
        static let shared = Utilities()
        
        /// Initializes the `Utilities` singleton instance.
        ///
        /// This initializer is private to enforce the singleton pattern, preventing the creation of multiple instances.
        private init() {    }
        
        
        
        /// Finds the top view controller in the view hierarchy.
        ///
        /// This method recursively traverses the view hierarchy to find the top-most view controller,
        /// starting from the specified controller or the root view controller of the key window if no controller is provided.
        ///
        /// - Parameter controller: The starting view controller. If `nil`, the search starts from the root view controller.
        /// - Returns: The top view controller, or `nil` if no view controller is found.
        @MainActor
        func topViewController(controller: UIViewController? = nil) -> UIViewController? {
            
            let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
            
            if let navigationController = controller as? UINavigationController {
                return topViewController(controller: navigationController.visibleViewController)
            }
            if let tabController = controller as? UITabBarController {
                if let selected = tabController.selectedViewController {
                    return topViewController(controller: selected)
                }
            }
            if let presented = controller?.presentedViewController {
                return topViewController(controller: presented)
            }
            return controller
        }
    }
    
    /* FOR TESTING PURPOSES
    func saveMovementDataToFirestore(movementData: [String: Any], forPatientWithID patientID: String) {
            guard let currentUserID = Auth.auth().currentUser?.uid else {
                print("Error: Current user ID not available")
                return
            }
            
            let db = Firestore.firestore()
            let usersRef = db.collection("users")
            let userPatientsRef = usersRef.document(currentUserID).collection("patients")
            let patientDocRef = userPatientsRef.document(patientID)
            let lungeTestRef = patientDocRef.collection("lungeTest")
            
            lungeTestRef.addDocument(data: movementData) { error in
                if let error = error {
                    print("Error saving movement data: \(error.localizedDescription)")
                } else {
                    print("Movement data saved successfully")
                }
            }
        }
        */
