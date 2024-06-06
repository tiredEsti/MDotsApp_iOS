//
//  AuthView.swift
//  Mdots
//
//  Created by Estela Alvarez on 7/11/23.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

/// A view for handling authentication methods.
struct AuthView: View {
    
    @StateObject private var viewModel = AuthViewModel()
    @Binding var showSignUpView: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Image(.noBackground)
                .resizable()
                .scaledToFit()
                .padding(.bottom, 32)
            NavigationLink{
                SignUpView(showSignUpView: $showSignUpView)
            } label: {
                Text("Sign Up with Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .light, style: .wide, state: .normal)){
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        showSignUpView = false
                    } catch {
                        print(error)
                    }
                }
                
            }
            Spacer()
            NavigationLink{
                SignInView(showSignUpView: $showSignUpView)
            } label: {
                Text("Already have an account? Sign In")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(10)
            }
        }
        .padding()
        //.navigationTitle("Sign Up")
    }
}

#Preview {
    NavigationStack{
        AuthView(showSignUpView: .constant(false))
    }
}
