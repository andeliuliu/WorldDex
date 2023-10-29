//
//  SocialPageView.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/27/23.
//

import SwiftUI
import SwiftyGif

struct SocialPageView: View {
    @State private var friendsPokemons: [Pokemon] = []
    var userId: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var isLoading: Bool = true
    @State private var isEmpty: Bool = true
    
    func fetchFriendsPokemon() {
        // Assuming your API supports excluding by user ID with the 'exclude_user_id' parameter.
        let url = URL(string: "http://192.168.0.113:3000/excludeUserImages?user_id=\(userId)")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let fetchedPokemons = try JSONDecoder().decode(ImageResponse.self, from: data)
                    let sortedPokemons = fetchedPokemons.imagePaths.sorted(by: {
                        $0.date_added > $1.date_added
                    })
                    DispatchQueue.main.async {
                        self.friendsPokemons = sortedPokemons
                        self.isLoading = false
                        self.isEmpty = false
                    }
                } catch {
                    print("Error decoding: \(error)")
                    self.isLoading = false
                    self.isEmpty = true
                }
            } else if let error = error {
                print("Error fetching data: \(error)")
                self.isLoading = false
                self.isEmpty = true
            }
        }.resume()
    }
    
    var body: some View {
        ZStack {
            Color("theme1").edgesIgnoringSafeArea(.all)
            if isEmpty {
                VStack {
                    Image("worldexIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .onAppear {
                            self.fetchFriendsPokemon()
                        }
                    if isLoading {
                        GifImageView(gifName: "loading", desiredWidth: 50, desiredHeight: 50)
                            .frame(width: 50, height: 50)
                    }
                }
            } else {
                VStack {
                    Text("Community")
                        .font(.custom("Avenir", size: 26))
                        .bold()
                        .foregroundColor(.black)
                        .padding(.top, 10)
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(friendsPokemons, id: \.id) { pokemon in
                                PokemonPostView(pokemon: pokemon)
                            }
                        }
                        .padding(.top)
                    }
                }
                .background(Color("theme1").edgesIgnoringSafeArea(.all))
            }
        }
    }
}
