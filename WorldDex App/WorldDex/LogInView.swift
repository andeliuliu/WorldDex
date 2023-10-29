//
//  LogInView.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/28/23.
//

import SwiftUI

struct LogInView: View {
    @State private var user_id: String = ""
    @State private var password: String = ""
    @State private var showUserData = false
    @State private var showError = false
    @Binding var isLoggedIn: Bool
    @Binding var username: String
    
    let url = URL(string: "http://192.168.0.113:3000/login")! // TODO: UPDATE TO CORRECT HOST

    var body: some View {
        ZStack {
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
                SecureField("Password", text: $password)
                    .font(Font.custom("Avenir", size: 16))
                    .padding(10)
                    .background(Color("theme2"))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                if showError {
                    Text("Incorrect credentials!")
                        .foregroundColor(.red)
                }
                Button(action: logIn) {
                    Text("Log In")
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

    func logIn() {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let parameters: [String: String] = [
            "user_id": user_id,
            "user_password": password
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    print("SUCCESSFUL LOGIN")
                    DispatchQueue.main.async {
                        self.isLoggedIn = true
                        self.username = user_id
                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                        UserDefaults.standard.set(user_id, forKey: "username")
                        self.showError = false
                    }
                } else {
                    print("FAIL LOGIN")
                    DispatchQueue.main.async {
                        self.showError = true
                    }
                }
            } else if let error = error {
                print("Error fetching data: \(error)")
            }
        }.resume()
    }
}


