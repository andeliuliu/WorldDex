//
//  Pokemon.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/27/23.
//

import SwiftUI

struct ImageResponse: Decodable {
    let imagePaths: [Pokemon]
}

struct Pokemon: Identifiable, Decodable {
    let image_id: String // ITEM_ID
    let user_id: String
    let blockchain_url: String
    let date_added: String // TIME
    let location_taken: String
    var cropped_image: String
    var image: String
    let details: String // live observations
    let probability: String
    
    // Computed property for Identifiable conformance
    var id: String { image_id }
}
