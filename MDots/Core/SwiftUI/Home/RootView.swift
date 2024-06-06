//
//  RootView.swift
//  Mdots
//
//  Created by Estela Alvarez on 7/11/23.
//

import SwiftUI

/// Represents the root view of the MDots application.
///
/// The `RootView` manages the initial presentation of the app, determining whether to display the home view or the authentication view based on the authentication status.
struct RootView: View {
    
    @State private var showSignUpView: Bool = false
    
    var body: some View {
        ZStack {
            if !showSignUpView {
                NavigationStack {
                    HomeView(showSignUpView: $showSignUpView)
                }
            }
        }
        .onAppear{
            let authUser = try? AuthManager.shared.getAuthUser()
            self.showSignUpView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignUpView) {
            NavigationStack {
                AuthView(showSignUpView: $showSignUpView)
            }
        }
        
    }
}

#Preview {
    RootView()
}
