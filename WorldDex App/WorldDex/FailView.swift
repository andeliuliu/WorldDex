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
            Color("theme1").edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Oh no! Your \(item) has escaped!")
                    .font(Font.custom("Avenir", size: 28))
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding([.top, .leading, .trailing])
                
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 400)
                    .padding([.leading, .trailing])
                
                Text("You had a \(String(format: "%.1f", probability))% chance of capturing it!")

                Button(action: {
                    self.callback?()
                }) {
                    Image(systemName: "arrow.clockwise") // This is a restart icon in SF Symbols
                        .resizable()
                        .frame(width: 80, height: 80)
                        .padding()
                        .background(Color("theme1").opacity(0.1))
                        .cornerRadius(40)
                }
            }
        }
    }
}
