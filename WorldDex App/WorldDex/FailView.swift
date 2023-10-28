//
//  FailView.swift
//  
//
//  Created by Anthony Qin on 10/28/23.
//

import SwiftUI

struct FailView: View {
    var item: String
    var image: UIImage
    var probability: Float
    var callback: (() -> Void)?

    init(item: String, image: UIImage, probability: Float, callback: (() -> Void)? = nil) {
        self.item = item
        self.image = image
        self.probability = probability
        self.callback = callback
    }

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Oh no! Your \(item) has escaped!")
                    .font(.largeTitle)
                    .foregroundColor(Color.black)
                    .padding([.top, .leading, .trailing])
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 500)
                    .padding([.leading, .trailing])
                
                Text("You had a \(probability)% chance of capturing it!")

                Button(action: {
                    self.callback?()
                }) {
                    Image(systemName: "arrow.clockwise") // This is a restart icon in SF Symbols
                        .resizable()
                        .frame(width: 100, height: 100)
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(40)
                }
            }
        }
    }
}
