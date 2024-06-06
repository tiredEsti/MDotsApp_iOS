//
//  HistoryView.swift
//  MDots
//
//  Created by Estela Alvarez on 26/4/24.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

/// Model for Movement Data.
struct MovementData: Codable, Hashable, Identifiable {
    @DocumentID var id: String?
    var side: String
    var testDate: Date
    var value: Double
}

/// View for displaying and managing a patient's movement data history.
struct HistoryView: View {
    @State private var testType: TestType = (TestType.allCases.first ?? TestType.isquio)
    @State private var id: String
    @State private var data: [MovementData] = []
    @State private var showAlert = false
    @State private var selectedItem: MovementData?
    
    /// Initializes the view with a patient ID.
    /// - Parameter id: The ID of the patient whose history is being displayed.
    init(id: String) {
        self.id = id
    }
    
    var body: some View {
        VStack (alignment: .leading) {
            Picker("Test Type: ", selection: $testType) {
                ForEach(TestType.allCases, id: \.self) { testTypeCase in
                    Text(testTypeCase.rawValue).tag(testTypeCase)
                }
            }
            .onChange(of: testType){ newValue in
                UserManager.shared.fetchData(patient_id: id, testType: newValue.rawValue) { fetchedData in self.data = fetchedData }
            }
            .pickerStyle(.menu)
            .padding()
            
            ChartView(data: data)
            
            List {
                Spacer()
                
                ForEach(data, id: \.self) { item in
                    HStack {
                        LazyHStack {
                            Text("Side: \(formattedSide(item.side))")
                                .padding()
                                .cornerRadius(8)
                            Text("Date: \(formattedDate(item.testDate))")
                                .padding()
                                .cornerRadius(8)
                            Text("Value: \(item.value)")
                                .padding()
                                .cornerRadius(8)
                        }
                        Spacer()
                        Button(action: {
                            selectedItem = item
                            showAlert = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Delete Data"),
                        message: Text("Are you sure you want to delete this data?"),
                        primaryButton: .destructive(Text("Delete")) {
                            if let item = selectedItem {
                                UserManager.shared.deleteData(patient_id: id, testType: testType.rawValue, item: item, data: data) { updatedData in self.data = updatedData }
                            }
                        },
                    secondaryButton: .cancel()
                )
            }
        }
        .onAppear{
            UserManager.shared.fetchData(patient_id: id, testType: testType.rawValue) { fetchedData in self.data = fetchedData }
        }
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }
}

extension HistoryView {
    /// Formats a date to a medium style string.
    ///
    /// - Parameter date: The date to be formatted.
    /// - Returns: A formatted date string.
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    /// Formats the side information into a readable string.
    ///
    /// - Parameter side: The side code (S, R, L).
    /// - Returns: A formatted side string.
    private func formattedSide(_ side: String) -> String {
        switch side {
        case "S":
            return "Single"
        case "R":
            return "Right"
        default:
            return "Left"
        }
    }
}




#Preview {
    NavigationStack{
        HistoryView(id: "0XA2MNokX9qXXq3UZVRw")
    }
}
