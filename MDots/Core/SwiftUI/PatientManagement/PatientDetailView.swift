//
//  ViewPatientsView.swift
//  Mdots
//
//  Created by Estela Alvarez on 14/11/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

/// Represents a patient with various attributes.
struct Patient: Identifiable, Codable, Hashable {
    @DocumentID var id: String? // Firestore document ID
    let name: String
    let surname: String
    let birthDate: Date
    let height: Int
    let weight: String
    let observations: String
}

/// A view that displays the details of a patient.
struct PatientDetailView: View {
    let patient: Patient
    @StateObject private var viewModel = PatientDetailViewModel()
    @State private var showingAlert = false
    @State private var isPopoverShowing = false
    @State private var test = "Isquiotibial"
    @Environment(\.presentationMode) var presentationMode
    

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Name: \(patient.name) \(patient.surname)")
                .font(.title)
                .fontWeight(.bold)
            
            HStack {
                Text("Birth Date:")
                    .foregroundColor(.primary)
                    .font(.headline)
                Text(formattedDate(patient.birthDate))
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Height:")
                    .foregroundColor(.primary)
                    .font(.headline)
                Text("\(patient.height) cm")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Weight:")
                    .foregroundColor(.primary)
                    .font(.headline)
                Text("\(patient.weight) Kg")
                    .foregroundColor(.secondary)
            }
            
            Text("Observations:")
                .foregroundColor(.primary)
                .font(.headline)
            Text(patient.observations)
                .foregroundColor(.secondary)
            
            //let testtype: TestType = .isquio
            
            NavigationLink(destination: HistoryView(id: patient.id ?? "")) {
                  HStack {
                      Image(systemName: "chart.xyaxis.line")
                          .resizable()
                          .frame(width: 20, height: 20)
                      Text("View history")
                          .font(.headline)
                  }
                  .foregroundColor(.blue)
                  .padding(.vertical, 8)
                  .padding(.horizontal, 16)
                  .background(Color.blue.opacity(0.2))
                  .cornerRadius(8)
              }


            Menu {
                ForEach(TestType.allCases, id: \.self) { testTypeCase in
                    NavigationLink(destination: StartView(testType: testTypeCase, patientID: patient.id ?? "")) {
                        Text(testTypeCase.rawValue)
                    }
                        
                }
            } label: {
                Label("New measure", systemImage: "angle")
            }
            .foregroundColor(.blue)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(8)
            .font(.headline)
            Spacer()
            
            Button(action: {
                   showingAlert = true
               }) {
                   HStack {
                           Image(systemName: "trash")
                               .resizable()
                               .frame(width: 20, height: 20)
                               .foregroundColor(.white)
                           
                           Text("Delete Patient")
                               .font(.headline)
                               .foregroundColor(.white)
                       }
                       .padding(.vertical, 8)
                       .padding(.horizontal, 16)
                       .cornerRadius(8)
                       .background(Color.red)
                       .cornerRadius(8)
               }
               .alert(isPresented: $showingAlert) {
                   Alert(
                       title: Text("Delete Patient"),
                        message: Text("Are you sure you want to delete this patient?"),
                           primaryButton: .destructive(Text("Delete")) {
                               Task {
                                   do {
                                       try await viewModel.deletePatient(patientID: patient.id ?? "")
                                       presentationMode.wrappedValue.dismiss()
                                   } catch {
                                       print(error)
                                   }
                               }
                           },
                       secondaryButton: .cancel()
                   )
               }
            Spacer()
        }
        .navigationTitle("Patient Details")
        .padding(25)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
        
    /// Formats a date into a readable string.
    /// - Parameter date: The date to format.
    /// - Returns: A formatted date string.
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
   
    
    
    struct PatientDetailView_Previews: PreviewProvider {
        static var previews: some View {
            let randomPatient = Patient(id: "1", name: "John", surname: "Doe", birthDate: Date(), height: 180, weight: "70", observations: "Random observations")
            PatientDetailView(patient: randomPatient)
        }
    }
    
}
