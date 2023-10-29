//
//  ContentView.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/27/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var events = UserEvents()
    @ObservedObject var cameraData = CameraData()
    
    // Enum to represent the current page
    enum Page {
        case pokedex, camera, social, profile
    }
    
    // State to track the current page
    @State private var currentPage: Page = .camera

    var body: some View {
        VStack {
            // Main content area
            switch currentPage {
            case .pokedex:
                PokedexView()
            case .camera:
                ZStack {
                    CameraView(events: events, cameraData: cameraData, applicationName: "WorldDex")
                    CameraInterfaceView(events: events, cameraData: cameraData)
                }
            case .social:
                SocialPageView()
            case .profile:
                ProfileView()
            }
            
            // Custom bottom bar
            HStack(spacing: 0) {
                Spacer(minLength: 20) // Add some space at the start
                
                Button(action: { currentPage = .pokedex }) {
                    Image(systemName: "book.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .padding()
                        .foregroundColor(currentPage == .pokedex ? Color("theme2") : .gray)
                        .shadow(radius: 5)
                }
                
                Spacer()
                
                Button(action: { currentPage = .camera }) {
                    Image(systemName: "camera.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .padding()
                        .foregroundColor(currentPage == .camera ? Color("theme1") : .gray)
                        .shadow(radius: 5)
                }
                
                Spacer()
                
                Button(action: { currentPage = .social }) {
                    Image(systemName: "person.2.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .padding()
                        .foregroundColor(currentPage == .social ? Color("theme2") : .gray)
                        .shadow(radius: 5)
                }

                Spacer()

                // Added profile button
                Button(action: { currentPage = .profile }) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
                        .padding()
                        .foregroundColor(currentPage == .profile ? Color("theme2") : .gray)
                        .shadow(radius: 5)
                }
                
                Spacer(minLength: 20) // Add some space at the end
            }
            .background(currentPage == .camera ? Color(UIColor.systemBackground) : Color("theme1"))
        }
    }
}
