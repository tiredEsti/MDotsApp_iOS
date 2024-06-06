//
//  ResetView.swift
//  Mdots
//
//  Created by Estela Alvarez on 8/11/23.
//

import SwiftUI

/// A view for resetting the password.
struct ResetView: View {
    @StateObject private var viewModel = ResetViewModel()
    @Binding var showSignUpView : Bool
    @State private var password = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack{
            TextField("Email", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)

            Button {
                Task {
                    do {
                        try await viewModel.sendResetEmail()
                        showSignUpView = true
                        presentationMode.wrappedValue.dismiss()

                    } catch {
                        //errorMessage = error.localizedDescription
                        print(error)
                    }
                }
            } label: {
                Text("Send email to reset password")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Spacer()

        }
        .padding()
        .navigationTitle("Reset Password")

    }

}

#Preview {
    ResetView(showSignUpView: .constant(false))
}
