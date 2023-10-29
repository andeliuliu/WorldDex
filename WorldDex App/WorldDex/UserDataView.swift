//
//  UserDataView.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/28/23.
//

import SwiftUI

struct UserDataView: View {
    var username: String
    @Binding var isLoggedIn: Bool
    @State private var email: String = ""
    
    var url: URL {
        return URL(string: "http://192.168.0.113:3000/userData?user_id=\(username)")! // TODO: UPDATE TO CORRECT IP
    }
    
    var body: some View {
        ZStack {
            Color("theme1").edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding()
                Text("Username: \(username)")
                    .font(Font.custom("Avenir", size: 20))
                    .foregroundColor(Color("theme2"))
                Text("Email: \(email)")
                    .font(Font.custom("Avenir", size: 20))
                    .foregroundColor(Color("theme2"))
                Button("Logout") {
                    logOut()
                }
                .font(Font.custom("Avenir", size: 20))
                .padding(10)
                .background(Color("theme2"))
                .foregroundColor(Color("theme1"))
                .cornerRadius(5)
            }
            .padding()
            .onAppear {
                fetchUserData()
            }
        }
    }
    
    func fetchUserData() {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("Error fetching data: \(error!)")
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let userEmail = jsonResponse["email"] as? String {
                        DispatchQueue.main.async {
                            self.email = userEmail
                        }
                    }
                }
            } catch {
                print("Error decoding: \(error)")
            }
        }.resume()
    }
    
    func logOut() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        isLoggedIn = false
    }
}


