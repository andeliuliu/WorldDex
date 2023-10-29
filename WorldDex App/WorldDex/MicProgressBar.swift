//
//  MicProgressBar.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/27/23.
//

import SwiftUI

struct MicProgressBar: View {
    var progress: Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 20)
            HStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("theme1"))
                    .frame(width: CGFloat(self.progress) * UIScreen.main.bounds.width, height: 20)
                Spacer()
            }
            Text("Name the object!")
                .foregroundColor(Color.white)
                .fontWeight(.bold)
                .padding(.horizontal, 10)
        }
    }
}
