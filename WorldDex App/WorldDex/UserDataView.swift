//
//  UserDataView.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/28/23.
//

import SwiftUI

struct UserDataView: View {
    var username: String
    @State private var email: String = ""
    
    var url: URL {
        return URL(string: "http://192.168.0.113:3000/catch?username=\(username)")! // TODO: UPDATE TO CORRECT IP
    }
    
    var body: some View {
        ZStack {
            Color("theme1").edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Text("Username: \(username)")
                Text("Email: \(email)")
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
}


