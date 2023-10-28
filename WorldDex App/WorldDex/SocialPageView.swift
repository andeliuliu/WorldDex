//
//  SocialPageView.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/27/23.
//

import SwiftUI

struct SocialPageView: View {
    // Sample data, replace with data fetched from the database
    let friendsPokemons: [Pokemon] = [
        Pokemon(id: 1, name: "Bulbasaur", location: "Grassy areas", time: "12:45 PM, 27th Oct", image: "bulbasaur", details: "Often found sleeping in bright sunlight."),
        // ... add more sample data
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(friendsPokemons, id: \.id) { pokemon in
                    PokemonPostView(pokemon: pokemon, username: "FriendUsername")
                }
            }
            .padding(.top)
        }
    }
}
