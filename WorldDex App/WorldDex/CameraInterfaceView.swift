//
//  CameraInterfaceView.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/27/23.
//

import SwiftUI
import AVFoundation
import Speech
import CoreLocation
import SwiftyGif
import UIKit

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

func uploadImageWithTranscription(image: UIImage, transcription: String, completion: @escaping (Result<Data, Error>) -> Void) {
    
    // Convert the UIImage to Data (JPEG format)
    guard let imageData = image.jpegData(compressionQuality: 1.0) else {
        print("Failed to convert image to Data")
        return
    }
    
    // Prepare the request
    let url = URL(string: "http://18.236.216.2:5000/predict")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // Generate boundary string using a unique string
    let boundary = UUID().uuidString
    let contentType = "multipart/form-data; boundary=\(boundary)"
    request.setValue(contentType, forHTTPHeaderField: "Content-Type")
    
    // Convert the image and transcription data into a Data object using a multipart/form-data format
    var body = Data()
    
    // Append transcription data
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"transcription\"\r\n\r\n")
    body.append(transcription.data(using: .utf8)!)
    body.append("\r\n")
    
    // Append image data
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
    body.append("Content-Type: image/jpeg\r\n\r\n")
    body.append(imageData)
    body.append("\r\n")
    body.append("--\(boundary)--\r\n")
    
    request.httpBody = body
    
    // Make the POST request
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        guard let data = data else {
            print("Data is missing from the response")
            return
        }
        completion(.success(data))
    }
    
    task.resume()
}


struct GifImageView: UIViewRepresentable {
    var gifName: String
    var desiredWidth: CGFloat = 5
    var desiredHeight: CGFloat = 5

    func makeUIView(context: Context) -> UIView {
        let container = UIView(frame: CGRect(x: 0, y: 0, width: desiredWidth, height: desiredHeight))
        let gifImageView = UIImageView()
        gifImageView.contentMode = .scaleAspectFit
        if let gif = try? UIImage(gifName: gifName) {
            gifImageView.setGifImage(gif)
        }

        gifImageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(gifImageView)

        NSLayoutConstraint.activate([
            gifImageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            gifImageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            gifImageView.widthAnchor.constraint(equalTo: container.widthAnchor),
            gifImageView.heightAnchor.constraint(equalTo: container.heightAnchor)
        ])

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.frame.size = CGSize(width: desiredWidth, height: desiredHeight)
    }
}


struct CameraInterfaceView: View, CameraActions {
    @ObservedObject var events: UserEvents
    @ObservedObject var cameraData: CameraData
    
    // For recording audio and recognizing speech
    @State private var isRecording = false
    @State private var recognizedText = ""
    private let speechRecognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()
    @State private var recordingProgress: Double = 0.0
    @State private var isProgressBarVisible: Bool = false
    
    private let flashImages = ["flashOutline", "flashauto", "flash"]
    @State private var currentFlashIndex = 0
    
    // probability view
    @State private var showProbabilityView = false
    @State private var capturedImage: UIImage? = nil
    
    @State private var showResultView = false
    
    // Object info variables
    @State private var capturedObject: Bool? = nil
    @State var item: String = "Bulbasaur"
    @State var croppedImage: UIImage? = UIImage(named: "bulbasaur")
    @State var probability: Float = 0.0
    @State var location: String = "CalHacks"
    @State var timestamp: String = "4:20AM"
    
    var body: some View {
        if showProbabilityView {
            probabilityView
        } else if showResultView {
            if capturedObject ?? false {
                SuccessView(item: item, originalImage: capturedImage, croppedImage: croppedImage, location: location, timestamp: timestamp, probability: probability) {
                    self.showResultView = false
                }
            } else {
                FailView(item: item, image: capturedImage!, probability: probability) {
                    self.showResultView = false
                }
            }
        } else {
            VStack {
                HStack {
                    rotateButton().onTapGesture {
                        self.rotateCamera(events: events)
                    }
                    Spacer()
                    flashButton()
                }
                .background(Color.clear)
                Spacer()
                if isProgressBarVisible {
                    MicProgressBar(progress: recordingProgress)
                }
                captureButton().onTapGesture {
                    self.takePhoto(events: events)
                    self.startRecording()
                }
                .onAppear(perform: requestSpeechAuthorization)
            }
        }
    }
    
    var probabilityView: some View {
        ZStack {
            Image(uiImage: capturedImage!)
                .resizable()
                .scaledToFit()
            VStack {
                GifImageView(gifName: "diceroll", desiredWidth: 200, desiredHeight: 200)
                    .frame(width: 200, height: 200)
            }
        }
    }
}

extension CameraInterfaceView {

    func startRecording() {
        if isRecording {
            stopRecording()
        } else {
            isProgressBarVisible = true
            startSpeechRecognition()
            withAnimation(.linear(duration: 3)) {
                recordingProgress = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.stopRecording()
                if let image = self.cameraData.capturedImage, let transcriptionText = self.cameraData.transcription {
                    capturedImage = image
                    location = self.cameraData.locationString ?? "No location found"
                    timestamp = self.cameraData.formattedTime ?? "No time found"
                    showProbabilityView = true
                    uploadImageWithTranscription(image: image, transcription: transcriptionText) { result in
                        switch result {
                        case .success(let data):
                            // Handle successful response, convert data to your model if needed
                            // Assuming `responseJSON` is the dictionary representing the JSON you've shown
                            if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {

                                // Extracting 'chances' and converting it to Float
                                if let chances = responseJSON["chances"] as? Int {
                                    self.probability = Float(chances) / 10.0
                                }

                                // Extracting 'item_name'
                                if let itemName = responseJSON["item_name"] as? String {
                                    self.item = itemName
                                }

                                // Extracting 'success'
                                if let success = responseJSON["success"] as? Bool {
                                    self.capturedObject = success
                                }

                                // Decoding base64 'cropped_image' to UIImage
                                if let base64ImageString = responseJSON["cropped_image"] as? String,
                                   let imageData = Data(base64Encoded: base64ImageString) {
                                    self.croppedImage = UIImage(data: imageData)
                                }
                                
                                showProbabilityView = false
                                showResultView = true
                            }
                        case .failure(let error):
                            // Handle errors
                            print("Error:", error)
                        }
                    }
                }
            }
            isRecording = true
        }
    }
        
    func startSpeechRecognition() {
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        
        guard let recognitionTask = try? speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            if let result = result {
                self.recognizedText = result.bestTranscription.formattedString
                print(self.recognizedText)
                self.cameraData.transcription = self.recognizedText
            }
        }) else { return }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
        
        recognitionTask.isCancelled // To silence warning. Handle recognition task as per requirement.
    }
    
    func stopRecording() {
        if !isRecording { return }
        isRecording = false
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        isProgressBarVisible = false
        recordingProgress = 0.0
    }

    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            // Handle authorization status here. For simplicity, we're just printing it.
            print(authStatus)
        }
    }
}

extension CameraInterfaceView {
    
    // Button to rotate the camera (switch between front and back cameras)
    func rotateButton() -> some View {
        Image("flipCamera")
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .padding()
    }
    
    // Button to toggle flash mode
    func flashButton() -> some View {
        return Image(flashImages[currentFlashIndex])
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .padding()
            .onTapGesture {
                self.changeFlashMode(events: events)
                currentFlashIndex = (currentFlashIndex + 1) % flashImages.count
            }
    }
    
    // Button to capture the photo
    func captureButton() -> some View {
        Image("focus")
            .resizable()
            .scaledToFit()
            .frame(width: 60, height: 60)
            .padding()
    }
}

