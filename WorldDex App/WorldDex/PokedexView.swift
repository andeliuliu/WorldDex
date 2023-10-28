//
//  PokedexView.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/27/23.
//
import SwiftUI

struct PokedexView: View {
    var pokemons: [Pokemon] = samplePokemons

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach(pokemons) { pokemon in
                        NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                            VStack {
                                Image(pokemon.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                Text(pokemon.name)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(15)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("WorldDex")
        }
    }
}

