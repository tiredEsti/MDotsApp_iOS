//
//  SignInView.swift
//  Mdots
//
//  Created by Estela Alvarez on 7/11/23.
//

import SwiftUI

/// View for signing up with email.
struct SignUpView: View {
    /// View model for sign-up functionality.
    @StateObject private var viewModel = SignUpViewModel()
    /// Binding to control the visibility of the sign-up view.
    @Binding var showSignUpView : Bool
    
    var body: some View {
        VStack{
            
            Section {
                TextField("Name", text: $viewModel.name)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                
                TextField("Surname", text: $viewModel.surname)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
            } header: {
                Text("Basic Information")
            }
            
            Section {
                TextField("Email", text: $viewModel.email)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                if !viewModel.emailWarning.isEmpty {
                    Text(viewModel.emailWarning)
                        .foregroundColor(.red)
                        .padding(.leading)
                }
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .background(Color.gray.opacity(0.4))
                    .cornerRadius(10)
                if !viewModel.passwordWarning.isEmpty {
                    Text(viewModel.passwordWarning)
                        .foregroundColor(.red)
                        .padding(.leading)
                }
                SecureField("Confirm Password", text: $viewModel.passwordConfirmation)
                                .padding()
                                .background(Color.gray.opacity(0.4))
                                .cornerRadius(10)
                if !viewModel.passwordConfirmationWarning.isEmpty {
                    Text(viewModel.passwordConfirmationWarning)
                        .foregroundColor(.red)
                        .padding(.leading)
                }
            } header: {
                Text("Credentials")
            }
            
            Button {
                
                if viewModel.isPasswordSecure() && viewModel.isEmailValid() && viewModel.passwordsMatch() {
                    Task {
                        let success = await viewModel.signUp()
                        if success {
                            showSignUpView = false
                        }
                    }
                    //print("Sign up successful")
                }
            } label: {
                Text("Sign Up")
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
        .navigationTitle("Sign Up with Email")

    }

}

#Preview {
    SignUpView(showSignUpView: .constant(false))
}

