//
//  CameraData.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/28/23.
//

import SwiftUI

public class CameraData: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var formattedTime: String?
    @Published var locationString: String?
    @Published var transcription: String?
}
