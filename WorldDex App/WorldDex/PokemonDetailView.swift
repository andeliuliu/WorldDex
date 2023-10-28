//
//  PokemonDetailView.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/27/23.
//

import SwiftUI

struct PokemonDetailView: View {
    let pokemon: Pokemon

    var body: some View {
        VStack(spacing: 20) {
            Image(pokemon.image)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            Text(pokemon.name)
                .font(.largeTitle)
            
            VStack(alignment: .leading) {
                Text("Location: \(pokemon.location)")
                Text("Timestamp: \(pokemon.time)")
            }
            .font(.subheadline)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Live Observations:")
                    .font(.title2)
                Text(pokemon.details)
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

struct PokemonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonDetailView(pokemon: Pokemon(id: 1, name: "Bulbasaur", location: "Grassy areas", time: "12:45 PM, 27th Oct", image: "bulbasaur", details: "Often found sleeping in bright sunlight."))
    }
}

