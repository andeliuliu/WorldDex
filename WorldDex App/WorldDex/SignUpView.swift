//
//  SignUpView.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/28/23.
//

import SwiftUI

struct SignUpView: View {
    @State private var user_id: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @Binding var isLoggedIn: Bool
    @Binding var username: String
    
    let url = URL(string: "http://192.168.0.113:3000/signup")! // TODO: UPDATE TO CORRECT HOST

    var body: some View {
        ZStack {
            // Custom background color. Replace with your desired background.
            Color("theme1").edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding()
                TextField("Username", text: $user_id)
                    .font(Font.custom("Avenir", size: 16))
                    .padding(10)
                    .background(Color("theme2"))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                TextField("Email", text: $email)
                    .font(Font.custom("Avenir", size: 16))
                    .padding(10)
                    .background(Color("theme2"))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                SecureField("Password", text: $password)
                    .font(Font.custom("Avenir", size: 16))
                    .padding(10)
                    .background(Color("theme2"))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                Button(action: signUp) {
                    Text("Sign Up")
                        .font(Font.custom("Avenir", size: 20))
                        .padding(10)
                        .background(Color("theme2"))
                        .foregroundColor(Color("theme1"))
                        .cornerRadius(5)
                }
            }
            .padding()
        }
    }

    func signUp() {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let data: [String: Any] = ["user_id": user_id,
                                   "email": email,
                                   "user_password": password]
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            // Handle response here
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                self.isLoggedIn = true
                self.username = user_id
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                UserDefaults.standard.set(user_id, forKey: "username")
                print(data)
            }
        }.resume()
    }
}

