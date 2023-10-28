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
            HStack {
                Button(action: { currentPage = .pokedex }) {
                    Image(systemName: "book.fill")
                    Text("WorldDex")
                }
                .padding()
                
                Button(action: { currentPage = .camera }) {
                    Image(systemName: "camera.fill")
                    Text("Camera")
                }
                .padding()
                
                Button(action: { currentPage = .social }) {
                    Image(systemName: "person.2.fill")
                    Text("Social")
                }
                .padding()
            }
            .background(Color.clear)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
