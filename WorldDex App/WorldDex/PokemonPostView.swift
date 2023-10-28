//
//  PokemonPostView.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/27/23.
//

import SwiftUI

struct PokemonPostView: View {
    let pokemon: Pokemon
    let username: String

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text(username)
                        .font(.headline)
                    Text(pokemon.location)
                        .font(.subheadline)
                }
                Spacer()
                Text(pokemon.time)
                    .font(.subheadline)
            }

            Image(pokemon.image)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
            
            Text(pokemon.name)
                .font(.title2)
            
            Text(pokemon.details)
                .font(.body)
            
            Divider()
        }
        .padding()
    }
}

