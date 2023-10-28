//
//  ContentView.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/27/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var events = UserEvents()
    
    // Enum to represent the current page
    enum Page {
        case pokedex, camera, social
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
                    CameraView(events: events, applicationName: "WorldDex")
                    CameraInterfaceView(events: events)
                }
            case .social:
                SocialPageView()
            }
            
            // Custom bottom bar
            HStack(spacing: 0) {
                Spacer(minLength: 20) // Add some space at the start
                
                Button(action: { currentPage = .pokedex }) {
                    Image(systemName: "book.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24) // Adjust this value as needed
                        .padding()
                        .foregroundColor(currentPage == .pokedex ? .blue : .gray)
                        .shadow(radius: 5)
                }
                
                Spacer() // Space out the buttons evenly
                
                Button(action: { currentPage = .camera }) {
                    Image(systemName: "camera.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24) // Adjust this value as needed
                        .padding()
                        .foregroundColor(currentPage == .camera ? .blue : .gray)
                        .shadow(radius: 5)
                }
                
                Spacer() // Space out the buttons evenly
                
                Button(action: { currentPage = .social }) {
                    Image(systemName: "person.2.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24) // Adjust this value as needed
                        .padding()
                        .foregroundColor(currentPage == .social ? .blue : .gray)
                        .shadow(radius: 5)
                }
                
                Spacer(minLength: 20) // Add some space at the end
            }
            .background(Color(UIColor.systemBackground))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
