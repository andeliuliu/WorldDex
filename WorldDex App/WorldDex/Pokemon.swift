//
//  Pokemon.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/27/23.
//

struct Pokemon: Identifiable {
    let id: Int
    let name: String
    let location: String
    let time: String
    let image: String
    let details: String // live observations
}

//struct PokemonDetails {
//    let species: String
//    let height: Double
//    let weight: Double
//    let abilities: [String]
//    let baseStats: [Stat]
//}

//struct Stat {
//    let name: String
//    let value: Int
//}

