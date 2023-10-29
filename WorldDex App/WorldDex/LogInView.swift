//
//  LogInView.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/28/23.
//

import SwiftUI

struct LogInView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showUserData = false
    @State private var showError = false
    
    let url = URL(string: "http://192.168.0.113:3000/catch")! // TODO: UPDATE TO CORRECT HOST

    var body: some View {
        ZStack {
            Color("theme1").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(Color("theme2"))
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(Color("theme2"))
                if showError {
                    Text("Incorrect credentials!")
                        .foregroundColor(.red)
                }
                Button("Log In") {
                    logIn()
                }
            }
            .padding()
            .sheet(isPresented: $showUserData) {
                UserDataView(username: username)
            }
        }
    }

    func logIn() {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let parameters: [String: Any] = [
            "username": username,
            "password": password
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("Error fetching data: \(error!)")
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let status = jsonResponse["status"] as? Bool, status == true {
                        DispatchQueue.main.async {
                            self.showUserData = true
                            self.showError = false
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.showError = true
                        }
                    }
                }
            } catch {
                print("Error decoding: \(error)")
            }
        }.resume()
    }
}


