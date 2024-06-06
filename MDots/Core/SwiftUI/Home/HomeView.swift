//
//  HomeView.swift
//  Mdots
//
//  Created by Estela Alvarez on 14/11/23.
//

import SwiftUI
import UIKit
import MovellaDotSdk
import Firebase
import FirebaseFirestoreSwift


/// The bridging coordinator to manage communication with UIKit.
class BridgingCoordinator: ObservableObject {
    var vc: MainViewController!
}

/// Function to create the main UIViewController.
/// - Returns: The created MainViewController.
func makeUIViewController() -> MainViewController {
        let view = MainViewController()
        return view
    }

/// View representing the home screen of the application.
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var coordinator = BridgingCoordinator()
    
    @State private var patients: [Patient] = []
    @State private var selectedPatient: Patient? = nil
    
    @Binding var showSignUpView: Bool
    
    var body: some View {
        List{
            if let user = viewModel.user {
                Text("Welcome, \(user.name) \(user.surname)")

            }
            newPatientSection
            patientsSection
            
        }
        .task {
            try? await viewModel.loadCurrentUser()
        }
        .navigationTitle("Home")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(showSignUpView: $showSignUpView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                NavigationLink {
                    ProfileView(showSignUpView: $showSignUpView)
                } label: {
                    Image(systemName: "person")
                        .font(.headline)
                }
            }
        }
        .onAppear {
            fetchPatients()
        }
    }
}





extension HomeView {
    /// View section for adding a new patient.
    private var newPatientSection: some View {
        Section {
            NavigationLink {
                AddPatientView()
            } label: {
                Image(systemName: "person.badge.plus")
                Text("Add patient")
            }
        } header: {
            Text("New patient")
        }
    }
    /// View section for displaying existing patients.
    private var patientsSection: some View {
        Section {
            ForEach(patients) { patient in
                NavigationLink {
                    PatientDetailView(patient: patient)
                } label: {
                    Text("\(patient.name) \(patient.surname)")
                }
            }
        } header: {
            Text("Patient Management")
        }
    }
    
    /// Fetches patients from Firestore and updates the local state.
    private func fetchPatients() {
        let db = Firestore.firestore()
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Error: Current user ID not available")
            return
        }
        
        let userRef = db.collection("users").document(currentUserID)
        userRef.collection("patients").getDocuments { querySnapshot, error in
            if let error = error {
                print("Error fetching patients: \(error.localizedDescription)")
                return
            }
            if let documents = querySnapshot?.documents {
                patients = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: Patient.self)
                }
            }
        }
    }
    
}



#Preview {
    NavigationStack{
        HomeView(showSignUpView: .constant(false))
    }
}
