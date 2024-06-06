//
//  SignInView.swift
//  Mdots
//
//  Created by Estela Alvarez on 8/11/23.
//

import SwiftUI


/// A view for signing in.
struct SignInView: View {
    /// View model for sign-in functionality.
    @StateObject private var viewModel = SignInViewModel()
    /// Binding to control the visibility of the sign-up view.
    @Binding var showSignUpView: Bool
    /// Error message to display if sign-in fails.
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        VStack{
            TextField("Email", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)

            SecureField("Password", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            if let errorMessage = errorMessage {
               Text(errorMessage) // Display the error message
                   .foregroundColor(.red)
                   .padding()
           }
            Button {
                Task {
                    do {
                        if viewModel.email.isEmpty || viewModel.password.isEmpty {
                            errorMessage = "Empty field found."
                        } else {
                            try await viewModel.signIn()
                            showSignUpView = false
                        }

                    } catch {
                        errorMessage = error.localizedDescription
                        print(error)
                    }
                }
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Spacer()
            
            NavigationLink{
                ResetView(showSignUpView: .constant(true))
            } label: {
                Text("Forgot your password? Reset")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
            }

        }
        .padding()
        .navigationTitle("Sign In")

    }

}

#Preview {
    SignInView(showSignUpView: .constant(false))
}
