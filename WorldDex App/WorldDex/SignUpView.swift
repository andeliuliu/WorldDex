//
//  SignUpView.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/28/23.
//

import SwiftUI

struct SignUpView: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    let url = URL(string: "http://192.168.0.113:3000/signup")! // TODO: UPDATE TO CORRECT HOST

    var body: some View {
        ZStack {
            // Custom background color. Replace with your desired background.
            Color("theme1").edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(Color("theme2"))
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(Color("theme2"))
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(Color("theme2"))
                
                Button("Sign Up") {
                    // Call the function to POST request
                    signUp()
                }
            }
            .padding()
        }
    }

    func signUp() {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data: [String: Any] = ["user_id": username,
                                   "email": email,
                                   "password": password]
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Handle response here
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                print(data)
            }
        }.resume()
    }
}

