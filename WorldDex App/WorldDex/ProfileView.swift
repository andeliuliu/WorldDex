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
    @State private var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""

    var body: some View {
        ZStack {
            // Custom background color. Replace with your desired background.
            Color("theme1").edgesIgnoringSafeArea(.all)

            if isLoggedIn {
                // If logged in, display the user's data
                UserDataView(username: username, isLoggedIn: $isLoggedIn)
            } else {
                // If not logged in, display the signup and login buttons
                VStack(spacing: 20) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .padding()
                    Button("Sign Up") {
                        showSignUp.toggle()
                    }
                    .font(Font.custom("Avenir", size: 20))
                    .padding(10)
                    .background(Color("theme2"))
                    .foregroundColor(Color("theme1"))
                    .cornerRadius(5)
                    .sheet(isPresented: $showSignUp) {
                        SignUpView(isLoggedIn: $isLoggedIn, username: $username)
                    }

                    Button("Log In") {
                        showLogIn.toggle()
                    }
                    .font(Font.custom("Avenir", size: 20))
                    .padding(10)
                    .background(Color("theme2"))
                    .foregroundColor(Color("theme1"))
                    .cornerRadius(5)
                    .sheet(isPresented: $showLogIn) {
                        LogInView(isLoggedIn: $isLoggedIn, username: $username)
                    }
                }
            }
        }
    }
}


