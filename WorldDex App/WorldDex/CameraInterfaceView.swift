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

struct GifImageView: UIViewRepresentable {
    var gifName: String

    func makeUIView(context: Context) -> UIImageView {
        let gifImageView = UIImageView()
        gifImageView.contentMode = .scaleAspectFit
        if let gif = try? UIImage(gifName: gifName) {
            gifImageView.setGifImage(gif)
        }
        return gifImageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        // No update needed for now
    }
}

struct CameraInterfaceView: View, CameraActions {
    @ObservedObject var events: UserEvents
    
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
    @State private var capturedObject: Bool? = false // TODO: SET TO NIL
    @State var item: String = "Bulbasaur"
    @State var croppedImage: UIImage? = UIImage(named: "bulbasaur")
    @State var location: String = "CalHacks"
    @State var timestamp: String = "4:20AM"
    
    var body: some View {
        if showProbabilityView {
            probabilityView
        } else if showResultView {
            if capturedObject ?? false {
                SuccessView(item: item, image: croppedImage, location: location, timestamp: timestamp) {
                    self.showResultView = false
                }
            } else {
                FailView(item: item, image: capturedImage!) {
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
                GifImageView(gifName: "diceroll")
                    .frame(width: 10, height: 10) // Adjust the size as needed
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
                if let img = UIImage(named: "test") { // TODO: GET IMAGE FROM DATABASE
                    capturedImage = img
                    showProbabilityView = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) { // TODO: Sage Maker API call
                        showProbabilityView = false
                        showResultView = true
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
                print(self.recognizedText) // Log the recognized text
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

