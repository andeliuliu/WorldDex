//
//  ProfileView.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/28/23.
//

import SwiftUI

struct ProfileView: View {
    @State private var showSignUp = false
    @State private var showLogIn = false

    var body: some View {
        ZStack {
            // Custom background color. Replace with your desired background.
            Color("theme1").edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Button("Sign Up") {
                    showSignUp.toggle()
                }
                .sheet(isPresented: $showSignUp) {
                    SignUpView()
                }

                Button("Log In") {
                    showLogIn.toggle()
                }
                .sheet(isPresented: $showLogIn) {
                    LogInView()
                }
            }
        }
    }
}

