//
//  AddPatientView.swift
//  Mdots
//
//  Created by Estela Alvarez on 14/11/23.
//

import SwiftUI

/// A view for adding a new patient's information.
struct AddPatientView: View {
    @StateObject private var viewModel = AddPatientViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack{
            List {
                Section {
                    TextField("Name", text: $viewModel.name)
                        .padding()
                        .cornerRadius(10)
                    
                    TextField("Surname", text: $viewModel.surname)
                        .padding()
                        .cornerRadius(10)
                    DatePicker("Date of Birth", selection: $viewModel.birthDate, displayedComponents: [.date])
                } header: {
                    Text("Basic Information")
                }
                
                Section {
                    Picker("Height", selection: $viewModel.height) {
                        ForEach(100..<250) { index in
                            Text("\(index) cm")
                        }
                    }
                    .padding()
                    .cornerRadius(10)
                    TextField("Weight Kg", text: $viewModel.weight)
                        .keyboardType(.decimalPad)
                    
                } header: {
                    Text("Body Measurements")
                }
                
                Section {
                    TextField("Observations", text: $viewModel.observations)
                    
                } header: {
                    Text("Further Information")
                }
                Button {
                    if(viewModel.name.isEmpty) {
                        Alert(title: Text("Error"), message: Text("Name field cannot be empty"), dismissButton: .default(Text("OK")))
                    } else {
                        Task {
                            do {
                                try await viewModel.addPatient()
                                presentationMode.wrappedValue.dismiss()
                            } catch {
                                print(error)
                            }
                        }
                    }
                } label: {
                        
                        
                         Text("Add patient")
                         .font(.headline)
                         .foregroundColor(.white)
                         .frame(height: 55)
                         .frame(maxWidth: .infinity)
                         .background(Color.blue)
                         .cornerRadius(10)
                         
                    
                }
            }
        }
        .navigationTitle("Add new patient info")
        
    }
}

#Preview {
    AddPatientView()
}
